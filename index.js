require('dotenv').config();
const express = require('express');
const cors = require('cors');
const Anthropic = require('@anthropic-ai/sdk');

const {
  getPersonaContext,
  getValueProps,
  getEmailFramework,
  getICP,
  getIndustrySnippets,
  listClients,
  clearCache,
  getCompetitors,
  getObjections,
  getCaseStudies,
  getSignals,
  getSalesPlaybook,
  getProductFeatures,
  getEmailTemplates
} = require('./lib/context');
const { buildEmailPrompt, buildResearchPrompt, buildScoringPrompt, buildCustomPrompt, buildSnippetPrompt } = require('./lib/prompts');

const app = express();
app.use(cors());
app.use(express.json());

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

// Health check
app.get('/', async (req, res) => {
  const clients = await listClients();
  res.json({
    status: 'ok',
    service: 'Mendel GTM API',
    version: '2.3.0',
    database: process.env.SUPABASE_URL ? 'supabase' : 'json-fallback',
    clients: clients.map(c => c.slug),
    endpoints: [
      'POST /api/generate-email',
      'POST /api/research-brief',
      'POST /api/score-lead',
      'POST /api/generate (flexible)',
      'POST /api/snippet',
      'GET /api/clients',
      'GET /api/playbook',
      'GET /api/features',
      'GET /api/templates',
      'GET /api/competitors',
      'GET /api/objections',
      'GET /api/case-studies',
      'GET /api/signals',
      'POST /api/cache/clear'
    ]
  });
});

// ============================================
// GET /api/clients
// List available clients
// ============================================
app.get('/api/clients', async (req, res) => {
  try {
    const clients = await listClients();
    res.json({ success: true, clients });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// POST /api/cache/clear
// Clear context cache (after updating Supabase data)
// ============================================
app.post('/api/cache/clear', (req, res) => {
  clearCache();
  res.json({ success: true, message: 'Cache cleared' });
});

// ============================================
// GET /api/playbook
// Sales playbook / battlecard
// ============================================
app.get('/api/playbook', async (req, res) => {
  try {
    const { client } = req.query;
    const clientSlug = client || 'mendel';
    const playbook = await getSalesPlaybook(clientSlug);
    res.json({ success: true, client: clientSlug, playbook });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// GET /api/features
// Product features with details
// ============================================
app.get('/api/features', async (req, res) => {
  try {
    const { client, slug } = req.query;
    const clientSlug = client || 'mendel';
    const features = await getProductFeatures(clientSlug, slug);
    res.json({ success: true, client: clientSlug, features });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// GET /api/templates
// Email templates and follow-up sequences
// ============================================
app.get('/api/templates', async (req, res) => {
  try {
    const { client, type } = req.query;
    const clientSlug = client || 'mendel';
    const templates = await getEmailTemplates(clientSlug, type);
    res.json({ success: true, client: clientSlug, templates });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// GET /api/competitors
// Lista competidores y benchmark
// ============================================
app.get('/api/competitors', async (req, res) => {
  try {
    const { client, name } = req.query;
    const clientSlug = client || 'mendel';
    const competitors = await getCompetitors(clientSlug, name);
    res.json({ success: true, client: clientSlug, competitors });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// GET /api/objections
// Lista objeciones y cómo manejarlas
// ============================================
app.get('/api/objections', async (req, res) => {
  try {
    const { client, category } = req.query;
    const clientSlug = client || 'mendel';
    const objections = await getObjections(clientSlug, category);
    res.json({ success: true, client: clientSlug, objections });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// GET /api/case-studies
// Lista casos de éxito
// ============================================
app.get('/api/case-studies', async (req, res) => {
  try {
    const { client, industry } = req.query;
    const clientSlug = client || 'mendel';
    const caseStudies = await getCaseStudies(clientSlug, industry);
    res.json({ success: true, client: clientSlug, case_studies: caseStudies });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// GET /api/signals
// Lista señales de oportunidad (buying triggers)
// ============================================
app.get('/api/signals', async (req, res) => {
  try {
    const { client, category } = req.query;
    const clientSlug = client || 'mendel';
    const signals = await getSignals(clientSlug, category);
    res.json({ success: true, client: clientSlug, signals });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// POST /api/generate-email
// Genera cold emails personalizados
// ============================================
app.post('/api/generate-email', async (req, res) => {
  try {
    const {
      client,         // Client slug (default: 'mendel')
      persona,        // CFO, Controller, Tesorería, etc.
      country,        // MX, AR, CL, CO, PE
      industry,       // Retail, Logística, Tech, etc.
      company_name,
      contact_name,
      company_size,   // número de empleados (opcional)
      signal,         // trigger detectado - string (opcional)
      signals,        // triggers detectados - array (opcional)
      additional_context, // info extra del prospecto (opcional)
      custom_fields,  // campos personalizados de Clay (opcional)
      ...extraFields  // cualquier otro campo se captura aquí
    } = req.body;

    const clientSlug = client || 'mendel';

    // Validación básica
    if (!persona || !country || !company_name || !contact_name) {
      return res.status(400).json({
        error: 'Campos requeridos: persona, country, company_name, contact_name'
      });
    }

    // Combinar signals: soporta string, array, o ambos
    const allSignals = [
      ...(signal ? [signal] : []),
      ...(Array.isArray(signals) ? signals : signals ? [signals] : [])
    ].filter(s => s && s.trim());

    // Combinar campos custom con cualquier campo extra no reconocido
    const allCustomFields = {
      ...(custom_fields || {}),
      ...extraFields
    };

    // Fetch context from Supabase (async)
    const [personaContext, valueProps, emailFramework, industrySnippets] = await Promise.all([
      getPersonaContext(persona, clientSlug),
      getValueProps(country, clientSlug),
      getEmailFramework(clientSlug),
      getIndustrySnippets(industry, clientSlug)
    ]);

    const prompt = buildEmailPrompt({
      persona,
      country,
      industry,
      company_name,
      contact_name,
      company_size,
      signals: allSignals,
      additional_context,
      custom_fields: Object.keys(allCustomFields).length > 0 ? allCustomFields : null,
      personaContext,
      valueProps,
      emailFramework,
      industrySnippets
    });

    const message = await anthropic.messages.create({
      model: 'claude-3-5-haiku-20241022',
      max_tokens: 1024,
      messages: [{ role: 'user', content: prompt }]
    });

    const email = message.content[0].text;

    res.json({
      success: true,
      email,
      metadata: { client: clientSlug, persona, country, industry, company_name }
    });

  } catch (error) {
    console.error('Error generating email:', error);
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// POST /api/research-brief
// Genera research brief de la cuenta
// ============================================
app.post('/api/research-brief', async (req, res) => {
  try {
    const {
      client,           // Client slug (default: 'mendel')
      company_name,
      country,
      industry,
      company_size,
      company_description,  // descripción de Clay/LinkedIn
      recent_news,          // noticias recientes (opcional)
      technologies,         // tech stack detectado (opcional)
      key_contacts          // contactos identificados (opcional)
    } = req.body;

    const clientSlug = client || 'mendel';

    if (!company_name || !country) {
      return res.status(400).json({
        error: 'Campos requeridos: company_name, country'
      });
    }

    // Fetch context from Supabase (async)
    const [valueProps, icp] = await Promise.all([
      getValueProps(country, clientSlug),
      getICP(clientSlug)
    ]);

    const prompt = buildResearchPrompt({
      company_name,
      country,
      industry,
      company_size,
      company_description,
      recent_news,
      technologies,
      key_contacts,
      valueProps,
      icp
    });

    const message = await anthropic.messages.create({
      model: 'claude-3-5-haiku-20241022',
      max_tokens: 2048,
      messages: [{ role: 'user', content: prompt }]
    });

    const brief = message.content[0].text;

    res.json({
      success: true,
      brief,
      metadata: { client: clientSlug, company_name, country, industry }
    });

  } catch (error) {
    console.error('Error generating research brief:', error);
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// POST /api/score-lead
// Scoring y qualification del lead
// ============================================
app.post('/api/score-lead', async (req, res) => {
  try {
    const {
      client,           // Client slug (default: 'mendel')
      company_name,
      country,
      industry,
      company_size,
      company_description,
      persona,              // rol del contacto
      seniority,            // nivel de seniority
      technologies,         // tech stack (ERP, etc.)
      signals               // señales detectadas (array)
    } = req.body;

    const clientSlug = client || 'mendel';

    if (!company_name || !country || !company_size) {
      return res.status(400).json({
        error: 'Campos requeridos: company_name, country, company_size'
      });
    }

    // Fetch ICP from Supabase (async)
    const icp = await getICP(clientSlug);

    const prompt = buildScoringPrompt({
      company_name,
      country,
      industry,
      company_size,
      company_description,
      persona,
      seniority,
      technologies,
      signals,
      icp
    });

    const message = await anthropic.messages.create({
      model: 'claude-3-5-haiku-20241022',
      max_tokens: 1024,
      messages: [{ role: 'user', content: prompt }]
    });

    // Parsear respuesta estructurada
    const responseText = message.content[0].text;
    let scoring;

    try {
      // Intentar parsear JSON de la respuesta
      const jsonMatch = responseText.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        scoring = JSON.parse(jsonMatch[0]);
      } else {
        scoring = { raw_analysis: responseText };
      }
    } catch {
      scoring = { raw_analysis: responseText };
    }

    res.json({
      success: true,
      scoring,
      metadata: { client: clientSlug, company_name, country, industry, company_size }
    });

  } catch (error) {
    console.error('Error scoring lead:', error);
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// POST /api/generate
// Endpoint flexible - define tu propio output
// ============================================
app.post('/api/generate', async (req, res) => {
  try {
    const {
      // Client
      client,           // Client slug (default: 'mendel')

      // Contexto del prospecto
      persona,
      country,
      industry,
      company_name,
      contact_name,
      company_size,
      signal,
      signals,
      additional_context,
      custom_fields,

      // Configuración del output
      task,             // Instrucción de qué generar (REQUERIDO)
      output_format,    // "text" | "json" | "markdown" (default: text)
      max_tokens,       // Límite de tokens (default: 1024)
      include_context,  // true/false - incluir contexto Mendel (default: true)

      ...extraFields
    } = req.body;

    const clientSlug = client || 'mendel';

    // Validación
    if (!task) {
      return res.status(400).json({
        error: 'Campo requerido: task (instrucción de qué generar)',
        example: 'task: "Genera 3 subject lines para este prospecto"'
      });
    }

    // Combinar signals
    const allSignals = [
      ...(signal ? [signal] : []),
      ...(Array.isArray(signals) ? signals : signals ? [signals] : [])
    ].filter(s => s && s.trim());

    // Combinar campos custom
    const allCustomFields = {
      ...(custom_fields || {}),
      ...extraFields
    };

    // Fetch context from Supabase (async) - only if needed
    const [personaContext, valueProps, icp] = await Promise.all([
      persona ? getPersonaContext(persona, clientSlug) : Promise.resolve(null),
      country ? getValueProps(country, clientSlug) : Promise.resolve(null),
      getICP(clientSlug)
    ]);

    const prompt = buildCustomPrompt({
      task,
      output_format: output_format || 'text',
      include_context: include_context !== false,
      persona,
      country,
      industry,
      company_name,
      contact_name,
      company_size,
      signals: allSignals,
      additional_context,
      custom_fields: Object.keys(allCustomFields).length > 0 ? allCustomFields : null,
      personaContext,
      valueProps,
      icp
    });

    const message = await anthropic.messages.create({
      model: 'claude-3-5-haiku-20241022',
      max_tokens: max_tokens || 1024,
      messages: [{ role: 'user', content: prompt }]
    });

    const output = message.content[0].text;

    // Si pidieron JSON, intentar parsearlo
    let result = output;
    if (output_format === 'json') {
      try {
        const jsonMatch = output.match(/\{[\s\S]*\}|\[[\s\S]*\]/);
        if (jsonMatch) {
          result = JSON.parse(jsonMatch[0]);
        }
      } catch {
        // Si falla el parse, devolver como texto
      }
    }

    res.json({
      success: true,
      output: result,
      metadata: {
        client: clientSlug,
        task,
        output_format: output_format || 'text',
        persona,
        country,
        company_name
      }
    });

  } catch (error) {
    console.error('Error in custom generate:', error);
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// POST /api/snippet
// Genera snippets cortos (max 30 palabras) para insertar en cold emails
// ============================================
app.post('/api/snippet', async (req, res) => {
  try {
    const {
      // Client
      client,

      // Tipo de snippet
      snippet_type,    // standard (default), opener, signal_hook, case_study, cta, ps_line
      task,            // Instrucción específica (opcional)

      // Contexto del prospecto
      persona,
      country,
      industry,
      company_name,
      contact_name,
      company_size,
      signal,
      signals,
      additional_context,
      custom_fields,

      ...extraFields
    } = req.body;

    const clientSlug = client || 'mendel';

    // Combinar signals
    const allSignals = [
      ...(signal ? [signal] : []),
      ...(Array.isArray(signals) ? signals : signals ? [signals] : [])
    ].filter(s => s && s.trim());

    // Combinar campos custom
    const allCustomFields = {
      ...(custom_fields || {}),
      ...extraFields
    };

    // Fetch context from Supabase (async) - solo lo que necesitamos
    const [personaContext, valueProps, industrySnippets, caseStudies, signalsData] = await Promise.all([
      persona ? getPersonaContext(persona, clientSlug) : Promise.resolve(null),
      country ? getValueProps(country, clientSlug) : Promise.resolve(null),
      industry ? getIndustrySnippets(industry, clientSlug) : Promise.resolve(null),
      getCaseStudies(clientSlug, industry),
      allSignals.length > 0 ? getSignals(clientSlug) : Promise.resolve([])
    ]);

    const prompt = buildSnippetPrompt({
      task,
      snippet_type: snippet_type || 'standard',
      persona,
      country,
      industry,
      company_name,
      contact_name,
      company_size,
      signals: allSignals,
      additional_context,
      custom_fields: Object.keys(allCustomFields).length > 0 ? allCustomFields : null,
      personaContext,
      valueProps,
      industrySnippets,
      caseStudies,
      signalsData
    });

    const message = await anthropic.messages.create({
      model: 'claude-3-5-haiku-20241022',
      max_tokens: 150,  // Snippets son cortos
      messages: [{ role: 'user', content: prompt }]
    });

    // Devolver solo el snippet en texto plano
    const snippet = message.content[0].text.trim();

    res.json({
      success: true,
      snippet
    });

  } catch (error) {
    console.error('Error generating snippet:', error);
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Mendel GTM API running on port ${PORT}`);
  console.log(`Database: ${process.env.SUPABASE_URL ? 'Supabase' : 'JSON fallback'}`);
});
