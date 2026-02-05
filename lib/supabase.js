const { createClient } = require('@supabase/supabase-js');

// Initialize Supabase client
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY; // Use service key for server-side

if (!supabaseUrl || !supabaseKey) {
  console.warn('⚠️  SUPABASE_URL or SUPABASE_SERVICE_KEY not set. Using fallback JSON files.');
}

const supabase = supabaseUrl && supabaseKey
  ? createClient(supabaseUrl, supabaseKey)
  : null;

module.exports = { supabase };
