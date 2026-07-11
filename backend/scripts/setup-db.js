#!/usr/bin/env node
/**
 * ChillFi — Database Setup Script
 * Runs schema.sql then seed.sql against the configured PostgreSQL database.
 *
 * Usage:
 *   node scripts/setup-db.js           → schema + seed
 *   node scripts/setup-db.js --schema  → schema only
 *   node scripts/setup-db.js --seed    → seed only
 */

require('dotenv').config();
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

const args = process.argv.slice(2);
const schemaOnly = args.includes('--schema');
const seedOnly   = args.includes('--seed');
const runSchema  = !seedOnly;
const runSeed    = !schemaOnly;

const pool = process.env.DATABASE_URL
  ? new Pool({ connectionString: process.env.DATABASE_URL, ssl: { rejectUnauthorized: false } })
  : new Pool({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT || 5432,
      database: process.env.DB_NAME,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
    });

const dbDir = path.join(__dirname, '..', 'src', 'db');

async function run() {
  const client = await pool.connect();
  try {
    if (runSchema) {
      console.log('\n📦 Running schema.sql...');
      const schema = fs.readFileSync(path.join(dbDir, 'schema.sql'), 'utf8');
      await client.query(schema);
      console.log('✅ Schema applied');
    }

    if (runSeed) {
      console.log('\n🌱 Running seed.sql...');
      const seed = fs.readFileSync(path.join(dbDir, 'seed.sql'), 'utf8');
      await client.query(seed);
      console.log('✅ Seed data inserted');
    }

    console.log('\n🎉 Database setup complete!\n');

    // Show a quick summary
    const tables = ['users','brands','categories','products','coupons','banners','store_settings'];
    for (const t of tables) {
      const { rows } = await client.query(`SELECT COUNT(*) FROM ${t}`);
      console.log(`   ${t.padEnd(20)} ${rows[0].count} rows`);
    }
    console.log('');
  } catch (err) {
    console.error('\n❌ Setup failed:', err.message);
    if (err.detail) console.error('   Detail:', err.detail);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

run();
