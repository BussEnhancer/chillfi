const fs = require('fs');
const path = require('path');
const pool = require('./pool');

async function initDB() {
  try {
    const sql = fs.readFileSync(path.join(__dirname, 'schema.sql'), 'utf8');
    await pool.query(sql);
    console.log('✅ Database schema initialized');
  } catch (err) {
    console.error('❌ DB init error:', err.message);
    throw err;
  }
}

module.exports = initDB;
