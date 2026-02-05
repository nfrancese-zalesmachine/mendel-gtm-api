const { supabase } = require('./supabase');

// Fallback JSON files (for local development or if Supabase is not configured)
const personasJSON = require('../context/personas.json');
const valuePropsJSON = require('../context/value-props.json');
const icpJSON = require('../context/icp.json');

// Cache for client data (TTL: 5 minutes)
const cache = new Map();
const CACHE_TTL = 5 * 60 * 1000;

/**
 * Get cached data or fetch from Supabase
 */
async function getCachedData(key, fetchFn) {
  const cached = cache.get(key);
  if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
    return cached.data;
  }

  const data = await fetchFn();
  cache.set(key, { data, timestamp: Date.now() });
  return data;
}

/**
 * Get client ID by slug
 */
async function getClientId(clientSlug = 'mendel') {
  if (!supabase) return null;

  return getCachedData(`client_id_${clientSlug}`, async () => {
    const { data, error } = await supabase
      .from('clients')
      .select('id')
      .eq('slug', clientSlug)
      .eq('is_active', true)
      .single();

    if (error || !data) {
      console.error(`Client not found: ${clientSlug}`);
      return null;
    }
    return data.id;
  });
}

/**
 * Get persona context by role name
 * @param {string} personaName - CFO, Controller, Tesoreria, etc.
 * @param {string} clientSlug - Client identifier (default: 'mendel')
 */
async function getPersonaContext(personaName, clientSlug = 'mendel') {
  // Normalize persona name
  const normalized = personaName
    .toLowerCase()
    .replace(/\s+/g, '')
    .replace('finanzas', 'finanzasoperativas')
    .replace('fp&a', 'fpa')
    .replace('travel', 'travelrrhh')
    .replace('rrhh', 'travelrrhh')
    .replace('contralor', 'controller');

  // Try Supabase first
  if (supabase) {
    try {
      const clientId = await getClientId(clientSlug);
      if (clientId) {
        const cacheKey = `persona_${clientSlug}_${normalized}`;
        return await getCachedData(cacheKey, async () => {
          const { data, error } = await supabase
            .from('personas')
            .select('*')
            .eq('client_id', clientId)
            .eq('is_active', true);

          if (error || !data || data.length === 0) {
            throw new Error('Persona not found in Supabase');
          }

          // Find matching persona
          const persona = data.find(p =>
            p.slug.toLowerCase() === normalized ||
            p.titles.some(t => t.toLowerCase().includes(normalized))
          );

          if (persona) {
            return {
              role: persona.role,
              pains: persona.pains,
              cares_about: persona.cares_about,
              questions: persona.questions,
              objections: persona.objections,
              titles: persona.titles,
              reports_to: persona.reports_to
            };
          }
          throw new Error('No matching persona found');
        });
      }
    } catch (err) {
      console.warn(`Supabase persona lookup failed, using fallback: ${err.message}`);
    }
  }

  // Fallback to JSON files
  const key = Object.keys(personasJSON).find(k =>
    k.toLowerCase() === normalized ||
    personasJSON[k].titles.some(t => t.toLowerCase().includes(normalized))
  );

  if (!key) {
    return {
      role: personaName,
      pains: ["Control de gastos", "Visibilidad financiera", "Procesos manuales"],
      cares_about: ["Eficiencia", "Control", "Automatización"],
      questions: ["¿Cómo manejan los gastos corporativos actualmente?"]
    };
  }

  return personasJSON[key];
}

/**
 * Get value props by country code
 * @param {string} countryCode - MX, AR, CL, CO, PE
 * @param {string} clientSlug - Client identifier (default: 'mendel')
 */
async function getValueProps(countryCode, clientSlug = 'mendel') {
  const country = countryCode?.toUpperCase() || 'MX';

  // Try Supabase first
  if (supabase) {
    try {
      const clientId = await getClientId(clientSlug);
      if (clientId) {
        const cacheKey = `valueprops_${clientSlug}_${country}`;
        return await getCachedData(cacheKey, async () => {
          // Get country-specific props
          const { data: countryData, error: countryError } = await supabase
            .from('countries')
            .select('*')
            .eq('client_id', clientId)
            .eq('code', country)
            .eq('is_active', true)
            .single();

          // Get global config
          const { data: globalData, error: globalError } = await supabase
            .from('global_config')
            .select('*')
            .eq('client_id', clientId)
            .single();

          if (countryError || globalError || !countryData || !globalData) {
            throw new Error('Value props not found in Supabase');
          }

          return {
            global: {
              core_value_props: globalData.core_value_props,
              differentiators: globalData.differentiators,
              reference_clients: globalData.reference_clients,
              features: globalData.features
            },
            country: {
              country_name: countryData.name,
              specific_value_props: countryData.specific_value_props,
              unique_features: countryData.unique_features,
              pain_emphasis: countryData.pain_emphasis,
              compliance: countryData.compliance,
              metrics: countryData.metrics,
              note: countryData.note
            },
            isMexico: country === 'MX'
          };
        });
      }
    } catch (err) {
      console.warn(`Supabase value props lookup failed, using fallback: ${err.message}`);
    }
  }

  // Fallback to JSON files
  const countryProps = valuePropsJSON[country] || valuePropsJSON['MX'];
  return {
    global: valuePropsJSON.global,
    country: countryProps,
    isMexico: country === 'MX'
  };
}

/**
 * Get email framework guidelines
 * @param {string} clientSlug - Client identifier (default: 'mendel')
 */
async function getEmailFramework(clientSlug = 'mendel') {
  // Try Supabase first
  if (supabase) {
    try {
      const clientId = await getClientId(clientSlug);
      if (clientId) {
        const cacheKey = `emailframework_${clientSlug}`;
        return await getCachedData(cacheKey, async () => {
          const { data, error } = await supabase
            .from('email_framework')
            .select('*')
            .eq('client_id', clientId)
            .single();

          if (error || !data) {
            throw new Error('Email framework not found in Supabase');
          }

          return {
            principles: data.principles,
            structure: data.structure,
            dont_do: data.dont_do,
            templates: data.templates
          };
        });
      }
    } catch (err) {
      console.warn(`Supabase email framework lookup failed, using fallback: ${err.message}`);
    }
  }

  // Fallback to default framework
  return {
    principles: {
      tone: "Conversacional + Directo - como si hablaras con un colega",
      never_salesy: "No 'increíble oportunidad' ni 'solución revolucionaria'",
      no_flattery: "No 'admiro tu trayectoria' sin razón específica",
      ask_dont_assume: "Preguntar, no afirmar que tienen X problema"
    },
    structure: {
      max_words: 100,
      one_idea: "Una idea por email, no lista de features",
      cta: "Baja fricción: '¿Te hace sentido?' > '¿Agendamos 45 min?'"
    },
    dont_do: [
      "Empezar con 'Espero que estés bien'",
      "Me encantaría presentarme...",
      "Listar 5+ features",
      "Asumir que tienen un problema específico",
      "Usar superlativos (la mejor, líder del mercado)",
      "Hablar de Mendel antes de hablar de ellos"
    ],
    templates: {
      open_question: "Pregunta abierta - para primer contacto sin señal clara",
      signal_trigger: "Basado en señal - cuando detectas algo específico",
      case_study: "Caso de estudio - cuando tienes un caso relevante similar",
      validation: "Pregunta de validación - para refinar targeting",
      super_short: "Super corto - follow-up o reengagement"
    }
  };
}

/**
 * Get ICP criteria for scoring
 * @param {string} clientSlug - Client identifier (default: 'mendel')
 */
async function getICP(clientSlug = 'mendel') {
  // Try Supabase first
  if (supabase) {
    try {
      const clientId = await getClientId(clientSlug);
      if (clientId) {
        const cacheKey = `icp_${clientSlug}`;
        return await getCachedData(cacheKey, async () => {
          // Get ICP config
          const { data: icpData, error: icpError } = await supabase
            .from('icp_config')
            .select('*')
            .eq('client_id', clientId)
            .single();

          // Get industries
          const { data: industries, error: indError } = await supabase
            .from('industries')
            .select('*')
            .eq('client_id', clientId)
            .eq('is_active', true)
            .order('tier', { ascending: true });

          if (icpError || !icpData) {
            throw new Error('ICP config not found in Supabase');
          }

          // Group industries by tier
          const tier1 = industries?.filter(i => i.tier === 1).map(i => ({
            name: i.name,
            reason: i.reason
          })) || [];
          const tier2 = industries?.filter(i => i.tier === 2).map(i => ({
            name: i.name,
            reason: i.reason
          })) || [];

          return {
            firmographics: icpData.firmographics,
            industries: {
              tier1_best_fit: tier1,
              tier2_good_fit: tier2
            },
            qualifying_signals: icpData.qualifying_signals,
            scoring_criteria: icpData.scoring_criteria
          };
        });
      }
    } catch (err) {
      console.warn(`Supabase ICP lookup failed, using fallback: ${err.message}`);
    }
  }

  // Fallback to JSON files
  return icpJSON;
}

/**
 * Get industry snippets for email personalization
 * @param {string} industry - Industry name
 * @param {string} clientSlug - Client identifier (default: 'mendel')
 */
async function getIndustrySnippets(industry, clientSlug = 'mendel') {
  const normalized = industry?.toLowerCase() || '';

  // Try Supabase first
  if (supabase) {
    try {
      const clientId = await getClientId(clientSlug);
      if (clientId) {
        const cacheKey = `industries_${clientSlug}`;
        const industries = await getCachedData(cacheKey, async () => {
          const { data, error } = await supabase
            .from('industries')
            .select('slug, pains, reference_clients')
            .eq('client_id', clientId)
            .eq('is_active', true);

          if (error || !data) {
            throw new Error('Industries not found in Supabase');
          }
          return data;
        });

        // Find matching industry
        const match = industries.find(i => normalized.includes(i.slug));
        if (match) {
          return {
            pains: match.pains,
            reference: match.reference_clients?.join(', ') || ''
          };
        }
      }
    } catch (err) {
      console.warn(`Supabase industry lookup failed, using fallback: ${err.message}`);
    }
  }

  // Fallback to hardcoded snippets
  const snippets = {
    "retail": {
      pains: ["gastos distribuidos en múltiples tiendas/sucursales", "control de trade marketing y activaciones", "viáticos de equipos de campo"],
      reference: "Mercado Libre, FEMSA"
    },
    "logistica": {
      pains: ["gastos de conductores y rutas", "combustible, peajes, viáticos", "control por ruta o centro de distribución"],
      reference: "empresas de distribución"
    },
    "tecnologia": {
      pains: ["suscripciones dispersas", "equipos distribuidos", "viajes a eventos y clientes"],
      reference: "Mercado Libre"
    },
    "manufactura": {
      pains: ["gastos en plantas y operaciones de campo", "mantenimiento y repuestos", "control por línea de negocio"],
      reference: "Grupo Omer"
    },
    "servicios": {
      pains: ["gastos por proyecto/cliente", "viajes, comidas, representación", "facturación al cliente basada en gasto real"],
      reference: "Adecco"
    },
    "consumo": {
      pains: ["equipos de campo dispersos", "activaciones y promociones", "trade marketing"],
      reference: "FEMSA, Unilever"
    },
    "food": {
      pains: ["múltiples ubicaciones", "gastos operativos distribuidos", "control por sucursal"],
      reference: "McDonald's"
    }
  };

  for (const [key, value] of Object.entries(snippets)) {
    if (normalized.includes(key)) {
      return value;
    }
  }

  return {
    pains: ["gastos corporativos distribuidos", "control de viáticos", "visibilidad financiera"],
    reference: "Mercado Libre, FEMSA, McDonald's"
  };
}

/**
 * List all available clients
 */
async function listClients() {
  if (!supabase) {
    return [{ slug: 'mendel', name: 'Mendel (fallback)' }];
  }

  try {
    const { data, error } = await supabase
      .from('clients')
      .select('slug, name, description')
      .eq('is_active', true)
      .order('name');

    if (error) throw error;
    return data || [];
  } catch (err) {
    console.error('Error listing clients:', err);
    return [{ slug: 'mendel', name: 'Mendel (fallback)' }];
  }
}

/**
 * Get competitors benchmark
 * @param {string} clientSlug - Client identifier (default: 'mendel')
 * @param {string} competitorName - Optional specific competitor name
 */
async function getCompetitors(clientSlug = 'mendel', competitorName = null) {
  if (!supabase) {
    return [];
  }

  try {
    const clientId = await getClientId(clientSlug);
    if (!clientId) return [];

    const cacheKey = `competitors_${clientSlug}`;
    const competitors = await getCachedData(cacheKey, async () => {
      const { data, error } = await supabase
        .from('competitors')
        .select('*')
        .eq('client_id', clientId)
        .order('name');

      if (error) throw error;
      return data || [];
    });

    if (competitorName) {
      return competitors.filter(c =>
        c.name.toLowerCase().includes(competitorName.toLowerCase())
      );
    }
    return competitors;
  } catch (err) {
    console.error('Error getting competitors:', err);
    return [];
  }
}

/**
 * Get objections and how to handle them
 * @param {string} clientSlug - Client identifier (default: 'mendel')
 * @param {string} category - Optional category filter (price, timing, competition, implementation, trust)
 */
async function getObjections(clientSlug = 'mendel', category = null) {
  if (!supabase) {
    return [];
  }

  try {
    const clientId = await getClientId(clientSlug);
    if (!clientId) return [];

    const cacheKey = `objections_${clientSlug}`;
    const objections = await getCachedData(cacheKey, async () => {
      const { data, error } = await supabase
        .from('objections')
        .select('*')
        .eq('client_id', clientId)
        .order('category');

      if (error) throw error;
      return data || [];
    });

    if (category) {
      return objections.filter(o => o.category === category);
    }
    return objections;
  } catch (err) {
    console.error('Error getting objections:', err);
    return [];
  }
}

/**
 * Get case studies
 * @param {string} clientSlug - Client identifier (default: 'mendel')
 * @param {string} industry - Optional industry filter
 */
async function getCaseStudies(clientSlug = 'mendel', industry = null) {
  if (!supabase) {
    return [];
  }

  try {
    const clientId = await getClientId(clientSlug);
    if (!clientId) return [];

    const cacheKey = `case_studies_${clientSlug}`;
    const caseStudies = await getCachedData(cacheKey, async () => {
      const { data, error } = await supabase
        .from('case_studies')
        .select('*')
        .eq('client_id', clientId)
        .eq('is_public', true)
        .order('company_name');

      if (error) throw error;
      return data || [];
    });

    if (industry) {
      return caseStudies.filter(cs =>
        cs.industry?.toLowerCase().includes(industry.toLowerCase())
      );
    }
    return caseStudies;
  } catch (err) {
    console.error('Error getting case studies:', err);
    return [];
  }
}

/**
 * Get buying signals
 * @param {string} clientSlug - Client identifier (default: 'mendel')
 * @param {string} category - Optional category filter (fiscal, growth, digital, friction, travel)
 */
async function getSignals(clientSlug = 'mendel', category = null) {
  if (!supabase) {
    return [];
  }

  try {
    const clientId = await getClientId(clientSlug);
    if (!clientId) return [];

    const cacheKey = `signals_${clientSlug}`;
    const signals = await getCachedData(cacheKey, async () => {
      const { data, error } = await supabase
        .from('signals')
        .select('*')
        .eq('client_id', clientId)
        .order('priority', { ascending: false });

      if (error) throw error;
      return data || [];
    });

    if (category) {
      return signals.filter(s => s.category === category);
    }
    return signals;
  } catch (err) {
    console.error('Error getting signals:', err);
    return [];
  }
}

/**
 * Get sales playbook (battlecard)
 * @param {string} clientSlug - Client identifier (default: 'mendel')
 */
async function getSalesPlaybook(clientSlug = 'mendel') {
  if (!supabase) {
    return null;
  }

  try {
    const clientId = await getClientId(clientSlug);
    if (!clientId) return null;

    const cacheKey = `playbook_${clientSlug}`;
    return await getCachedData(cacheKey, async () => {
      const { data, error } = await supabase
        .from('sales_playbook')
        .select('*')
        .eq('client_id', clientId)
        .single();

      if (error) throw error;
      return data;
    });
  } catch (err) {
    console.error('Error getting sales playbook:', err);
    return null;
  }
}

/**
 * Get product features
 * @param {string} clientSlug - Client identifier (default: 'mendel')
 * @param {string} featureSlug - Optional specific feature slug
 */
async function getProductFeatures(clientSlug = 'mendel', featureSlug = null) {
  if (!supabase) {
    return [];
  }

  try {
    const clientId = await getClientId(clientSlug);
    if (!clientId) return [];

    const cacheKey = `features_${clientSlug}`;
    const features = await getCachedData(cacheKey, async () => {
      const { data, error } = await supabase
        .from('product_features')
        .select('*')
        .eq('client_id', clientId)
        .order('name');

      if (error) throw error;
      return data || [];
    });

    if (featureSlug) {
      return features.filter(f => f.slug === featureSlug);
    }
    return features;
  } catch (err) {
    console.error('Error getting product features:', err);
    return [];
  }
}

/**
 * Get email templates
 * @param {string} clientSlug - Client identifier (default: 'mendel')
 * @param {string} templateType - Optional filter by type (first_contact, followup, etc.)
 */
async function getEmailTemplates(clientSlug = 'mendel', templateType = null) {
  if (!supabase) {
    return [];
  }

  try {
    const clientId = await getClientId(clientSlug);
    if (!clientId) return [];

    const cacheKey = `templates_${clientSlug}`;
    const templates = await getCachedData(cacheKey, async () => {
      const { data, error } = await supabase
        .from('email_templates')
        .select('*')
        .eq('client_id', clientId)
        .order('sequence_order', { ascending: true, nullsFirst: true });

      if (error) throw error;
      return data || [];
    });

    if (templateType) {
      return templates.filter(t => t.template_type === templateType);
    }
    return templates;
  } catch (err) {
    console.error('Error getting email templates:', err);
    return [];
  }
}

/**
 * Clear cache (useful after data updates)
 */
function clearCache() {
  cache.clear();
  console.log('Context cache cleared');
}

module.exports = {
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
};
