package com.example.scamego

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class DatabaseHelper(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    companion object {
        private const val DATABASE_VERSION = 1
        private const val DATABASE_NAME = "scamego_android.db"
        const val TABLE_SCAMS = "scam_log"
        const val COLUMN_ID = "_id"
        const val COLUMN_SENDER = "sender"
        const val COLUMN_MESSAGE = "message"
        const val COLUMN_RISK = "risk_score"
        const val COLUMN_LEVEL = "risk_level"
    }

    override fun onCreate(db: SQLiteDatabase) {
        val createTable = ("CREATE TABLE " + TABLE_SCAMS + "("
                + COLUMN_ID + " INTEGER PRIMARY KEY AUTOINCREMENT,"
                + COLUMN_SENDER + " TEXT,"
                + COLUMN_MESSAGE + " TEXT,"
                + COLUMN_RISK + " INTEGER,"
                + COLUMN_LEVEL + " TEXT" + ")")
        db.execSQL(createTable)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_SCAMS)
        onCreate(db)
    }

    fun logScam(sender: String, message: String, riskScore: Int, riskLevel: String) {
        val db = this.writableDatabase
        val values = ContentValues()
        values.put(COLUMN_SENDER, sender)
        values.put(COLUMN_MESSAGE, message)
        values.put(COLUMN_RISK, riskScore)
        values.put(COLUMN_LEVEL, riskLevel)
        db.insert(TABLE_SCAMS, null, values)
        db.close()
    }
    
    fun getAllLogs(): List<String> {
        val logs = mutableListOf<String>()
        val db = this.readableDatabase
        val cursor = db.rawQuery("SELECT * FROM $TABLE_SCAMS ORDER BY $COLUMN_ID DESC", null)
        if (cursor.moveToFirst()) {
            do {
                val sender = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_SENDER))
                val risk = cursor.getInt(cursor.getColumnIndexOrThrow(COLUMN_RISK))
                val level = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_LEVEL))
                logs.add("$level ($risk): $sender")
            } while (cursor.moveToNext())
        }
        cursor.close()
        db.close()
        return logs
    }
    
    fun clearAllLogs() {
        val db = this.writableDatabase
        db.execSQL("DELETE FROM $TABLE_SCAMS")
        db.close()
    }
}
