const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

async function migrateV3() {
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

    // Execute schema v3
    console.log('📦 Ejecutando schema-v3.sql...');
    const schemaSQL = fs.readFileSync(
      path.join(__dirname, '../supabase/schema-v3.sql'),
      'utf8'
    );
    await client.query(schemaSQL);
    console.log('✅ Schema V3 creado!\n');

    // Execute seed v3
    console.log('🌱 Ejecutando seed-mendel-v3.sql...');
    const seedSQL = fs.readFileSync(
      path.join(__dirname, '../supabase/seed-mendel-v3.sql'),
      'utf8'
    );
    await client.query(seedSQL);
    console.log('✅ Datos V3 insertados!\n');

    // Verify
    console.log('🔍 Verificando tablas actualizadas...');

    const playbook = await client.query('SELECT COUNT(*) as count FROM sales_playbook');
    console.log(`  - Sales Playbook: ${playbook.rows[0].count} registros`);

    const features = await client.query('SELECT COUNT(*) as count FROM product_features');
    console.log(`  - Product Features: ${features.rows[0].count} registros`);

    const templates = await client.query('SELECT COUNT(*) as count FROM email_templates');
    console.log(`  - Email Templates: ${templates.rows[0].count} registros`);

    // Check updated competitors
    const competitorsUpdated = await client.query(`
      SELECT COUNT(*) as count FROM competitors
      WHERE when_we_win IS NOT NULL
    `);
    console.log(`  - Competitors (con when_we_win): ${competitorsUpdated.rows[0].count} registros`);

    // Check updated personas
    const personasUpdated = await client.query(`
      SELECT COUNT(*) as count FROM personas
      WHERE responsibilities IS NOT NULL
    `);
    console.log(`  - Personas (con responsibilities): ${personasUpdated.rows[0].count} registros`);

    console.log('\n🎉 ¡Migración V3 completada exitosamente!');

  } catch (error) {
    console.error('❌ Error:', error.message);
    if (error.detail) console.error('   Detail:', error.detail);
    process.exit(1);
  } finally {
    await client.end();
  }
}

migrateV3();
