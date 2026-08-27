"""
Instagram Collector Service for ScameGo
Uses Playwright to scrape DMs for spam/scam detection.
Session expires after 15 minutes.
"""
import asyncio
import logging
import threading
import random
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from app.core.config import settings
from app.core.security import decrypt
from app.database.base import SessionLocal
from app.models.instagram import InstagramAccount
from app.models.content import Comment, Message, Conversation, Post
from app.models.user import User
from app.services.scam_analysis_pipeline import analyze_content

logger = logging.getLogger(__name__)

_active_monitors: dict[int, threading.Event] = {}

INSTAGRAM_SESSION_EXPIRE_MINUTES = 15


def is_session_expired(account: InstagramAccount) -> bool:
    if not account.session_started_at:
        return True
    expiry = account.session_started_at + timedelta(minutes=INSTAGRAM_SESSION_EXPIRE_MINUTES)
    return datetime.utcnow() > expiry


async def _dismiss_modals(page):
    """Dismiss notification/save-info popups and any overlay dialogs."""
    try:
        await page.keyboard.press("Escape")
        await page.wait_for_timeout(300)
        await page.keyboard.press("Escape")
        await page.wait_for_timeout(300)
        
        for label in ["Not Now", "Cancel", "Close"]:
            try:
                btns = await page.locator(f"text='{label}'").all()
                for btn in btns:
                    if await btn.is_visible(timeout=400):
                        await btn.click(force=True)
                        await page.wait_for_timeout(700)
            except Exception:
                pass

        # Remove dialog overlays via JS
        await page.evaluate('''
            document.querySelectorAll('div[role="dialog"]').forEach(el => el.remove());
            document.querySelectorAll('div').forEach(el => {
                const style = window.getComputedStyle(el);
                if (style.position === 'fixed' && el.children.length === 0 && style.zIndex > 10) {
                    el.remove();
                }
            });
        ''')
    except Exception as e:
        logger.debug(f"Modal dismiss attempt: {e}")


async def _scrape_dms(page, username: str, password: str) -> list[dict]:
    """
    Scrape DM threads by navigating directly to thread URLs.
    """
    messages = []
    try:
        inbox_url = "https://www.instagram.com/direct/inbox/"
        logger.info(f"Navigating to {inbox_url} ...")
        await page.goto(inbox_url, timeout=30000)
        await page.wait_for_timeout(3000)

        # Dismiss ALL popups before doing anything else
        for attempt in range(5):
            dismissed = False
            
            not_now = page.locator("text='Not Now'")
            try:
                if await not_now.count() > 0:
                    for i in range(await not_now.count()):
                        if await not_now.nth(i).is_visible():
                            logger.info(f"Dismissing 'Not Now' popup (attempt {attempt+1})...")
                            await not_now.nth(i).click(force=True)
                            await page.wait_for_timeout(1500)
                            dismissed = True
            except Exception:
                pass
            
            save_info = page.locator("button:has-text('Save Info'), button:has-text('Not Now')")
            if await save_info.count() > 0 and await save_info.last.is_visible():
                logger.info("Dismissing 'Save login info' popup...")
                await save_info.last.click(force=True)
                await page.wait_for_timeout(1000)
                dismissed = True

            dialog = page.locator("div[role='dialog']")
            if await dialog.count() > 0 and await dialog.first.is_visible():
                logger.info("Removing dialog via JavaScript...")
                await page.evaluate('''
                    document.querySelectorAll('div[role="dialog"]').forEach(el => el.remove());
                ''')
                await page.wait_for_timeout(500)
                dismissed = True
            
            if not dismissed:
                break

        # Wait for threads to load in the sidebar
        logger.info("Waiting for DM threads to load in sidebar...")
        try:
            await page.wait_for_selector("div[role='listitem'], div[aria-label='Thread list']", timeout=10000)
        except Exception:
            logger.warning("Timeout waiting for thread list container.")

        # Find clickable thread elements in the sidebar
        all_listitems = await page.locator("div[role='listitem']").all()
        if len(all_listitems) == 0:
            all_listitems = await page.locator("div[aria-label='Thread list'] div[role='button']").all()

        valid_threads = []
        for item in all_listitems:
            try:
                txt = await item.inner_text(timeout=1000)
                if "Your note" not in txt and "Requests" not in txt:
                    valid_threads.append(item)
            except Exception:
                pass

        logger.info(f"Found {len(valid_threads)} valid threads in the sidebar.")

        if len(valid_threads) == 0:
            logger.warning("No threads found.")
            return messages

        # Process top 5 recent threads
        for i in range(min(5, len(valid_threads))):
            try:
                thread_element = valid_threads[i]
                logger.info(f"Clicking thread #{i+1}...")
                
                inner_text = thread_element.locator("div[dir='auto']").first
                if await inner_text.count() > 0:
                    await inner_text.click(force=True)
                else:
                    await thread_element.click(force=True)
                    
                await page.wait_for_timeout(3000)
                
                current_url = page.url
                if "/direct/t/" not in current_url:
                    logger.warning(f"Click on thread #{i+1} did not navigate to a thread. Current URL: {current_url}")
                    continue
                
                participant_id = current_url.split('/direct/t/')[-1].strip('/')
                
                # Get participant username from chat header
                participant = participant_id
                participant_js = await page.evaluate('''() => {
                    const chatHeader = document.querySelector('div[role="main"] header');
                    if (chatHeader) {
                        const profileLink = chatHeader.querySelector('a[href^="/"]');
                        if (profileLink) {
                            const href = profileLink.getAttribute('href');
                            if (href && href.length > 2 && !href.includes('/direct/')) {
                                return href.replace(/\\//g, '');
                            }
                        }
                        const spans = chatHeader.querySelectorAll('span[dir="auto"]');
                        for (let span of spans) {
                            const text = span.innerText;
                            if (text && text.length > 0 && text.length < 30 && !text.includes('Active') && !text.includes('seen')) {
                                return text;
                            }
                        }
                    }
                    return null;
                }''')
                
                if participant_js and len(participant_js) < 30:
                    participant = participant_js
                        
                logger.info(f"Opened thread with {participant} -> {current_url}")
                
                await page.wait_for_timeout(2000)
                await _dismiss_modals(page)
                
                # Extract messages using JS
                extracted_msgs = await page.evaluate('''() => {
                    const messages = [];
                    const seen = new Set();
                    
                    const inputArea = document.querySelector('div[aria-label="Message"]') 
                                || document.querySelector('div[contenteditable="true"]')
                                || document.querySelector('textarea');
                    
                    let chatContainer = null;
                    if (inputArea) {
                        let curr = inputArea;
                        for(let i = 0; i < 12; i++) {
                            if(curr.parentElement) {
                                curr = curr.parentElement;
                                if(curr.offsetWidth > 300 && curr.offsetHeight > 400) {
                                    chatContainer = curr;
                                    break;
                                }
                            }
                        }
                    }
                    
                    if (!chatContainer) {
                        chatContainer = document.body;
                    }
                    
                    const textElements = chatContainer.querySelectorAll(
                        'div[dir="auto"]:not(div[aria-label="Message"] *), span[dir="auto"]'
                    );
                    textElements.forEach(el => {
                        const hasChildDirAuto = el.querySelector('[dir="auto"]');
                        if (hasChildDirAuto) return;
                        
                        const text = el.innerText ? el.innerText.trim() : "";
                        if (!text || text.length < 3) return;
                        if (seen.has(text)) return;
                        seen.add(text);
                        messages.push(text);
                    });
                    return messages;
                }''')
                
                logger.info(f"Found {len(extracted_msgs)} unique text elements in thread #{i+1} ({participant})")
                
                if len(extracted_msgs) == 0:
                    html = await page.content()
                    safe_name = participant.replace("/", "_").replace("\\", "_")
                    with open(f"thread_{safe_name}_debug.html", "w", encoding="utf-8") as f:
                        f.write(html)
                        
                import re as _re
                SKIP_EXACT = {
                    "Home", "Search", "Explore", "Reels", "Messages", "Notifications",
                    "Create", "Profile", "More", "Also from Meta", "New note",
                    "Your note", "Shared with followers you follow back",
                    "Send a message", "Open Camera", "Voice clip",
                }
                SKIP_CONTAINS = [
                    "Sent an attachment", "Shared a reel", "Liked a message",
                    "Reacted to", "Active now", "new messages", "You replied",
                    "Shared a post", "Shared a story",
                ]
                TIMESTAMP_PATTERN = _re.compile(r'^(\d+[smhdw]|just now|yesterday|\d{1,2}:\d{2}(?: [ap]m)?)$', _re.IGNORECASE)
                
                seen_msgs_in_thread = set()
                for text in extracted_msgs[-50:]:
                    try:
                        clean_text = " ".join(text.split('\n')).strip()
                        
                        if not clean_text or len(clean_text) < 4:
                            continue
                        if clean_text in SKIP_EXACT:
                            continue
                        if TIMESTAMP_PATTERN.match(clean_text):
                            continue
                        if any(p.lower() in clean_text.lower() for p in SKIP_CONTAINS):
                            continue
                        if clean_text.replace(",", "").replace(".", "").isdigit():
                            continue
                        if clean_text in seen_msgs_in_thread:
                            continue
                        seen_msgs_in_thread.add(clean_text)
                        
                        logger.info(f"  Message from {participant}: {clean_text[:60]}...")
                        messages.append({"sender": participant, "content": clean_text})
                    except Exception:
                        continue
            except Exception as e:
                logger.warning(f"Failed to read thread: {e}")
                continue
    except Exception as e:
        logger.error(f"DM scrape error: {e}")
    return messages


async def _run_monitor(account_id: int, stop_event: threading.Event, target_profile_url: str = None):
    from playwright.async_api import async_playwright

    db: Session = SessionLocal()
    try:
        account = db.query(InstagramAccount).filter(InstagramAccount.id == account_id).first()
        if not account:
            return

        username = account.username
        try:
            password = decrypt(account.encrypted_password) if account.encrypted_password else ""
        except Exception:
            logger.error("Could not decrypt Instagram password")
            return

        async with async_playwright() as p:
            browser = await p.chromium.launch(headless=False)
            
            import os
            state_dir = "sessions"
            os.makedirs(state_dir, exist_ok=True)
            state_path = os.path.join(state_dir, f"account_{account_id}.json")
            
            if os.path.exists(state_path):
                context = await browser.new_context(storage_state=state_path)
                logger.info(f"Loaded existing session state for {username}")
            else:
                context = await browser.new_context()

            page = await context.new_page()

            try:
                for retry in range(3):
                    try:
                        await page.goto("https://www.instagram.com/accounts/login/", timeout=30000)
                        break
                    except Exception as goto_err:
                        logger.warning(f"goto login retry {retry}: {goto_err}")
                        await page.wait_for_timeout(2000)
                
                await page.wait_for_timeout(3000)
                
                if "login" not in page.url:
                    logger.info(f"Already logged in as {username} (redirected to {page.url})")
                else:
                    logger.info(f"Login required for {username}. Detecting login screen type...")
                    
                    if os.path.exists(state_path):
                        os.remove(state_path)
                        logger.info("Deleted stale session file.")
                    
                    for cookie_text in ['Allow all cookies', 'Accept all cookies']:
                        btn = page.locator(f"button:has-text('{cookie_text}')")
                        if await btn.count() > 0:
                            logger.info(f"Accepting cookies: {cookie_text}")
                            await btn.first.click()
                            await page.wait_for_timeout(1500)
                            break
                    
                    continue_btn = page.locator("button:has-text('Continue')")
                    if await continue_btn.count() > 0 and await continue_btn.first.is_visible():
                        logger.info("Detected saved profile screen. Clicking 'Continue'...")
                        await continue_btn.first.click()
                        await page.wait_for_timeout(2500)
                    
                    user_input = page.locator("input[name='username'], input[name='email']")
                    if await user_input.count() > 0 and await user_input.first.is_visible():
                        logger.info("Filling username...")
                        await user_input.first.fill(username)
                        await page.wait_for_timeout(500)
                    
                    pass_input = page.locator("input[name='password'], input[name='pass']")
                    logger.info("Waiting for password input...")
                    await pass_input.first.wait_for(timeout=10000)
                    logger.info("Filling password...")
                    await pass_input.first.fill(password)
                    await page.wait_for_timeout(500)
                    
                    logger.info("Submitting login...")
                    await pass_input.first.press("Enter")
                    await page.wait_for_timeout(2000)
                    
                    login_btn = page.locator("button:has-text('Log in'), button:has-text('Log In')")
                    if await login_btn.count() > 0 and await login_btn.first.is_visible():
                        logger.info("Clicking Log In button explicitly...")
                        await login_btn.first.click()
                    
                    logger.info("Waiting for login to complete... (If stuck, solve CAPTCHA/2FA in browser window!)")
                    for _ in range(60):
                        if "login" not in page.url:
                            break
                        await asyncio.sleep(1)
                    
                    if "login" in page.url:
                        logger.error(f"Login failed for {username} after 60s. Stopping monitor.")
                        await browser.close()
                        return
                    
                    logger.info(f"Instagram login succeeded for {username}")
                    await page.screenshot(path="instagram_login_success.png")
                    await context.storage_state(path=state_path)

                # Update session started time
                account.session_started_at = datetime.utcnow()
                account.monitoring_status = "running"
                db.commit()

                # Monitoring loop
                while not stop_event.is_set():
                    db.refresh(account)
                    if is_session_expired(account):
                        logger.info(f"Session expired for account {account_id}")
                        break

                    user = db.query(User).filter(User.id == account.user_id).first()
                    if not user:
                        break

                    await _dismiss_modals(page)

                    # Scrape DMs
                    try:
                        raw_dms = await _scrape_dms(page, username=username, password=password)
                        for dm in raw_dms:
                            conv = db.query(Conversation).filter(
                                Conversation.participant == dm["sender"],
                                Conversation.user_id == user.id
                            ).first()
                            if not conv:
                                conv = Conversation(
                                    user_id=user.id,
                                    participant=dm["sender"]
                                )
                                db.add(conv)
                                db.commit()
                                db.refresh(conv)

                            exists = db.query(Message).filter(
                                Message.conversation_id == conv.id,
                                Message.sender == dm["sender"],
                                Message.content == dm["content"]
                            ).first()
                            if not exists:
                                msg = Message(
                                    conversation_id=conv.id,
                                    user_id=user.id,
                                    sender=dm["sender"],
                                    content=dm["content"],
                                )
                                db.add(msg)
                                db.commit()
                                db.refresh(msg)
                                
                                # Run ML analysis
                                loop = asyncio.get_event_loop()
                                result = await loop.run_in_executor(
                                    None, analyze_content,
                                    user.id, "message", msg.id, dm["content"], dm["sender"]
                                )
                                
                                # Update conversation risk
                                conv.message_count = (conv.message_count or 0) + 1
                                if result and result.get("scam_label") in ("SCAM", "SPAM") and result.get("risk_score", 0) > 30:
                                    conv.flagged_count = (conv.flagged_count or 0) + 1
                                conv.risk_score = int((conv.flagged_count / max(conv.message_count, 1)) * 100)
                                conv.updated_at = datetime.utcnow()
                                db.commit()
                    except Exception as e:
                        logger.error(f"DM scrape error: {e}")

                    # Wait ~60s before next scan with some jitter
                    wait_time = 60 + random.randint(-10, 20)
                    logger.info(f"Finished scraping cycle. Waiting {wait_time}s before next scan...")
                    for _ in range(wait_time):
                        if stop_event.is_set():
                            break
                        await asyncio.sleep(1)

            except Exception as e:
                logger.error(f"Monitor error: {e}")
            finally:
                await browser.close()

    except Exception as e:
        logger.error(f"Monitor error: {e}")
    finally:
        account = db.query(InstagramAccount).filter(InstagramAccount.id == account_id).first()
        if account:
            account.monitoring_status = "stopped"
            db.commit()
        db.close()


def start_monitoring(account: InstagramAccount, target_profile_url: str = None):
    if account.id in _active_monitors:
        return
    stop_event = threading.Event()
    _active_monitors[account.id] = stop_event

    def run():
        import sys
        if sys.platform == 'win32':
            asyncio.set_event_loop_policy(asyncio.WindowsProactorEventLoopPolicy())
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        loop.run_until_complete(_run_monitor(account.id, stop_event, target_profile_url))
        loop.close()
        _active_monitors.pop(account.id, None)

    t = threading.Thread(target=run, daemon=True)
    t.start()


def stop_monitoring(account_id: int):
    ev = _active_monitors.get(account_id)
    if ev:
        ev.set()
        _active_monitors.pop(account_id, None)