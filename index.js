require('dotenv').config();
const express = require('express');
const cors = require('cors');
const Anthropic = require('@anthropic-ai/sdk');

const { getPersonaContext, getValueProps, getEmailFramework, getICP } = require('./lib/context');
const { buildEmailPrompt, buildResearchPrompt, buildScoringPrompt, buildCustomPrompt } = require('./lib/prompts');

const app = express();
app.use(cors());
app.use(express.json());

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

// Health check
app.get('/', (req, res) => {
  res.json({
    status: 'ok',
    service: 'Mendel GTM API',
    endpoints: [
      'POST /api/generate-email',
      'POST /api/research-brief',
      'POST /api/score-lead',
      'POST /api/generate (flexible - define tu propio output)'
    ]
  });
});

// ============================================
// POST /api/generate-email
// Genera cold emails personalizados
// ============================================
app.post('/api/generate-email', async (req, res) => {
  try {
    const {
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
      personaContext: getPersonaContext(persona),
      valueProps: getValueProps(country),
      emailFramework: getEmailFramework()
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
      metadata: { persona, country, industry, company_name }
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
      company_name,
      country,
      industry,
      company_size,
      company_description,  // descripción de Clay/LinkedIn
      recent_news,          // noticias recientes (opcional)
      technologies,         // tech stack detectado (opcional)
      key_contacts          // contactos identificados (opcional)
    } = req.body;

    if (!company_name || !country) {
      return res.status(400).json({
        error: 'Campos requeridos: company_name, country'
      });
    }

    const prompt = buildResearchPrompt({
      company_name,
      country,
      industry,
      company_size,
      company_description,
      recent_news,
      technologies,
      key_contacts,
      valueProps: getValueProps(country),
      icp: getICP()
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
      metadata: { company_name, country, industry }
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

    if (!company_name || !country || !company_size) {
      return res.status(400).json({
        error: 'Campos requeridos: company_name, country, company_size'
      });
    }

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
      icp: getICP()
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
      metadata: { company_name, country, industry, company_size }
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
      personaContext: persona ? getPersonaContext(persona) : null,
      valueProps: country ? getValueProps(country) : null,
      icp: getICP()
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

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Mendel GTM API running on port ${PORT}`);
});
