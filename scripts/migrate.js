const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

async function migrate() {
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

    // Execute schema
    console.log('📦 Ejecutando schema.sql...');
    const schemaSQL = fs.readFileSync(
      path.join(__dirname, '../supabase/schema.sql'),
      'utf8'
    );
    await client.query(schemaSQL);
    console.log('✅ Schema creado!\n');

    // Execute seed
    console.log('🌱 Ejecutando seed-mendel.sql...');
    const seedSQL = fs.readFileSync(
      path.join(__dirname, '../supabase/seed-mendel.sql'),
      'utf8'
    );
    await client.query(seedSQL);
    console.log('✅ Datos de Mendel insertados!\n');

    // Verify
    console.log('🔍 Verificando...');
    const result = await client.query('SELECT slug, name FROM clients');
    console.log('Clientes en la base de datos:');
    result.rows.forEach(row => console.log(`  - ${row.slug}: ${row.name}`));

    console.log('\n🎉 ¡Migración completada exitosamente!');

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}

migrate();
