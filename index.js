require('dotenv').config();
const express = require('express');
const cors = require('cors');
const Anthropic = require('@anthropic-ai/sdk');

const { getPersonaContext, getValueProps, getEmailFramework, getICP } = require('./lib/context');
const { buildEmailPrompt, buildResearchPrompt, buildScoringPrompt } = require('./lib/prompts');

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
      'POST /api/score-lead'
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
      signal,         // trigger detectado (opcional)
      additional_context // info extra del prospecto (opcional)
    } = req.body;

    // Validación básica
    if (!persona || !country || !company_name || !contact_name) {
      return res.status(400).json({
        error: 'Campos requeridos: persona, country, company_name, contact_name'
      });
    }

    const prompt = buildEmailPrompt({
      persona,
      country,
      industry,
      company_name,
      contact_name,
      company_size,
      signal,
      additional_context,
      personaContext: getPersonaContext(persona),
      valueProps: getValueProps(country),
      emailFramework: getEmailFramework()
    });

    const message = await anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
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
      model: 'claude-sonnet-4-20250514',
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
      model: 'claude-sonnet-4-20250514',
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

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Mendel GTM API running on port ${PORT}`);
});
