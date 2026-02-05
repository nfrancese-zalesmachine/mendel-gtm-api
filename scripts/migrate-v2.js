const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

async function migrateV2() {
  const client = new Client({
    host: 'db.ievuchixmrmrembpvzwp.supabase.co',
    port: 5432,
    database: 'postgres',
    user: 'postgres',
    password: '8V8yST+.2?PumCg',
    ssl: { rejectUnauthorized: false }
  });

  try {
    console.log('🔌 Conectando a Supabase...');
    await client.connect();
    console.log('✅ Conectado!\n');

    // Execute schema v2
    console.log('📦 Ejecutando schema-v2.sql...');
    const schemaSQL = fs.readFileSync(
      path.join(__dirname, '../supabase/schema-v2.sql'),
      'utf8'
    );
    await client.query(schemaSQL);
    console.log('✅ Schema V2 creado!\n');

    // Execute seed v2
    console.log('🌱 Ejecutando seed-mendel-v2.sql...');
    const seedSQL = fs.readFileSync(
      path.join(__dirname, '../supabase/seed-mendel-v2.sql'),
      'utf8'
    );
    await client.query(seedSQL);
    console.log('✅ Datos V2 insertados!\n');

    // Verify
    console.log('🔍 Verificando nuevas tablas...');

    const competitors = await client.query('SELECT COUNT(*) as count FROM competitors');
    console.log(`  - Competitors: ${competitors.rows[0].count} registros`);

    const objections = await client.query('SELECT COUNT(*) as count FROM objections');
    console.log(`  - Objections: ${objections.rows[0].count} registros`);

    const caseStudies = await client.query('SELECT COUNT(*) as count FROM case_studies');
    console.log(`  - Case Studies: ${caseStudies.rows[0].count} registros`);

    const signals = await client.query('SELECT COUNT(*) as count FROM signals');
    console.log(`  - Signals: ${signals.rows[0].count} registros`);

    console.log('\n🎉 ¡Migración V2 completada exitosamente!');

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}

migrateV2();
