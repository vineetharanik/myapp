import sqlite3
import json
from datetime import datetime
from typing import List, Dict, Optional, Any
from pathlib import Path

class Database:
    def __init__(self, db_path: str = "devbalance.db"):
        self.db_path = db_path
        self.init_database()
    
    def init_database(self):
        """Initialize database tables"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Users table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                email TEXT UNIQUE NOT NULL,
                name TEXT NOT NULL,
                password_hash TEXT NOT NULL,
                goals TEXT,
                skills TEXT,  -- JSON array
                stress_assessment TEXT,  -- JSON object
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Journal entries table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS journal_entries (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                text TEXT NOT NULL,
                analysis TEXT NOT NULL,  -- JSON object with full analysis
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users (id)
            )
        ''')
        
        # Study hours tracking
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS study_hours (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                date DATE NOT NULL,
                hours REAL NOT NULL,
                target_hours REAL DEFAULT 8.0,
                focus_quality TEXT,  -- high, medium, low
                notes TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users (id),
                UNIQUE(user_id, date)
            )
        ''')
        
        # Skills progress tracking
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS skills_progress (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                skill_name TEXT NOT NULL,
                progress_percentage REAL DEFAULT 0.0,
                last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users (id),
                UNIQUE(user_id, skill_name)
            )
        ''')
        
        # AI generated plans
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS weekly_plans (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                week_start DATE NOT NULL,
                plan_content TEXT NOT NULL,  -- JSON object
                generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users (id),
                UNIQUE(user_id, week_start)
            )
        ''')
        
        conn.commit()
        conn.close()
    
    def create_user(self, email: str, name: str, password_hash: str, 
                    goals: str, skills: List[str], stress_assessment: Dict) -> int:
        """Create a new user"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                INSERT INTO users (email, name, password_hash, goals, skills, stress_assessment)
                VALUES (?, ?, ?, ?, ?, ?)
            ''', (email, name, password_hash, goals, json.dumps(skills), json.dumps(stress_assessment)))
            
            user_id = cursor.lastrowid
            
            # Initialize skills progress
            for skill in skills:
                cursor.execute('''
                    INSERT INTO skills_progress (user_id, skill_name, progress_percentage)
                    VALUES (?, ?, 0.0)
                ''', (user_id, skill))
            
            conn.commit()
            return user_id
        except sqlite3.IntegrityError:
            conn.close()
            raise ValueError("Email already exists")
        finally:
            conn.close()
    
    def get_user_by_email(self, email: str) -> Optional[Dict]:
        """Get user by email"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT id, email, name, password_hash, goals, skills, stress_assessment
            FROM users WHERE email = ?
        ''', (email,))
        
        row = cursor.fetchone()
        conn.close()
        
        if row:
            return {
                'id': row[0],
                'email': row[1],
                'name': row[2],
                'password_hash': row[3],
                'goals': row[4],
                'skills': json.loads(row[5]) if row[5] else [],
                'stress_assessment': json.loads(row[6]) if row[6] else {}
            }
        return None
    
    def create_journal_entry(self, user_id: int, text: str, analysis: Dict) -> int:
        """Create a new journal entry"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO journal_entries (user_id, text, analysis)
            VALUES (?, ?, ?)
        ''', (user_id, text, json.dumps(analysis)))
        
        entry_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        return entry_id
    
    def get_journal_history(self, user_id: int, limit: int = 50) -> List[Dict]:
        """Get journal history for a user"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT text, analysis, timestamp
            FROM journal_entries 
            WHERE user_id = ?
            ORDER BY timestamp DESC
            LIMIT ?
        ''', (user_id, limit))
        
        rows = cursor.fetchall()
        conn.close()
        
        return [
            {
                'text': row[0],
                'analysis': json.loads(row[1]),
                'timestamp': row[2]
            }
            for row in rows
        ]
    
    def get_latest_journal_analysis(self, user_id: int) -> Optional[Dict]:
        """Get the latest journal analysis for a user"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT analysis, timestamp
            FROM journal_entries 
            WHERE user_id = ?
            ORDER BY timestamp DESC
            LIMIT 1
        ''', (user_id,))
        
        row = cursor.fetchone()
        conn.close()
        
        if row:
            return {
                'analysis': json.loads(row[0]),
                'timestamp': row[1]
            }
        return None
    
    def update_study_hours(self, user_id: int, date: str, hours: float, 
                          focus_quality: str = None, notes: str = None, target_hours: float = 8.0):
        """Update or create study hours record"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT OR REPLACE INTO study_hours (user_id, date, hours, target_hours, focus_quality, notes)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (user_id, date, hours, target_hours, focus_quality, notes))
        
        conn.commit()
        conn.close()
    
    def get_weekly_study_hours(self, user_id: int, week_start: str) -> List[Dict]:
        """Get study hours for a week"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT date, hours, target_hours, focus_quality, notes
            FROM study_hours 
            WHERE user_id = ? AND date >= ? AND date < date(?, '+7 days')
            ORDER BY date
        ''', (user_id, week_start, week_start))
        
        rows = cursor.fetchall()
        conn.close()
        
        return [
            {
                'date': row[0],
                'hours': row[1],
                'target_hours': row[2],
                'focus_quality': row[3],
                'notes': row[4]
            }
            for row in rows
        ]
    
    def update_skills_progress(self, user_id: int, skill_updates: Dict[str, float]):
        """Update skills progress"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        for skill_name, progress in skill_updates.items():
            cursor.execute('''
                INSERT OR REPLACE INTO skills_progress (user_id, skill_name, progress_percentage, last_updated)
                VALUES (?, ?, ?, CURRENT_TIMESTAMP)
            ''', (user_id, skill_name, progress))
        
        conn.commit()
        conn.close()
    
    def get_skills_progress(self, user_id: int) -> List[Dict]:
        """Get skills progress for a user"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT skill_name, progress_percentage, last_updated
            FROM skills_progress 
            WHERE user_id = ?
            ORDER BY skill_name
        ''', (user_id,))
        
        rows = cursor.fetchall()
        conn.close()
        
        return [
            {
                'skill_name': row[0],
                'progress_percentage': row[1],
                'last_updated': row[2]
            }
            for row in rows
        ]
    
    def save_weekly_plan(self, user_id: int, week_start: str, plan_content: Dict):
        """Save AI generated weekly plan"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT OR REPLACE INTO weekly_plans (user_id, week_start, plan_content)
            VALUES (?, ?, ?)
        ''', (user_id, week_start, json.dumps(plan_content)))
        
        conn.commit()
        conn.close()
    
    def get_current_weekly_plan(self, user_id: int) -> Optional[Dict]:
        """Get current weekly plan"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT plan_content, generated_at
            FROM weekly_plans 
            WHERE user_id = ? 
            ORDER BY week_start DESC
            LIMIT 1
        ''', (user_id,))
        
        row = cursor.fetchone()
        conn.close()
        
        if row:
            return {
                'plan_content': json.loads(row[0]),
                'generated_at': row[1]
            }
        return None

# Global database instance
db = Database()
