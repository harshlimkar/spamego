package com.example.scamego

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.example.scamego.theme.MyApplicationTheme

class MainActivity : ComponentActivity() {

    private val dbHelper by lazy { DatabaseHelper(this) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        requestPermissionsIfNecessary()

        enableEdgeToEdge()
        setContent {
            MyApplicationTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    ScamLogScreen(dbHelper)
                }
            }
        }
    }

    private fun requestPermissionsIfNecessary() {
        val permissions = arrayOf(
            Manifest.permission.RECEIVE_SMS,
            Manifest.permission.READ_SMS,
            Manifest.permission.POST_NOTIFICATIONS
        )
        val missingPermissions = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        if (missingPermissions.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, missingPermissions.toTypedArray(), 100)
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ScamLogScreen(dbHelper: DatabaseHelper) {
    var logs by remember { mutableStateOf(emptyList<String>()) }
    
    LaunchedEffect(Unit) {
        logs = dbHelper.getAllLogs()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("ScameGo Offline Protection") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer
                )
            )
        }
    ) { padding ->
        Column(modifier = Modifier.padding(padding).padding(16.dp)) {
            Text(
                "Listening for incoming SMS offline...",
                style = MaterialTheme.typography.bodyLarge
            )
            Spacer(modifier = Modifier.height(16.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                Button(onClick = { logs = dbHelper.getAllLogs() }) {
                    Text("Refresh Logs")
                }
                Button(
                    onClick = { 
                        dbHelper.clearAllLogs()
                        logs = emptyList()
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error)
                ) {
                    Text("Clear Logs")
                }
            }
            Spacer(modifier = Modifier.height(16.dp))
            
            if (logs.isEmpty()) {
                Text("No scams detected yet.")
            } else {
                LazyColumn {
                    items(logs) { log ->
                        Card(
                            modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
                            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.errorContainer)
                        ) {
                            Text(text = log, modifier = Modifier.padding(16.dp))
                        }
                    }
                }
            }
        }
    }
}
