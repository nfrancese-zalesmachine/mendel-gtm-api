const personas = require('../context/personas.json');
const valueProps = require('../context/value-props.json');
const icp = require('../context/icp.json');

/**
 * Get persona context by role name
 * @param {string} personaName - CFO, Controller, Tesoreria, Contabilidad, FPA, FinanzasOperativas, TravelRRHH
 */
function getPersonaContext(personaName) {
  // Normalize persona name
  const normalized = personaName
    .toLowerCase()
    .replace(/\s+/g, '')
    .replace('finanzas', 'finanzasoperativas')
    .replace('fp&a', 'fpa')
    .replace('travel', 'travelrrhh')
    .replace('rrhh', 'travelrrhh')
    .replace('contralor', 'controller');

  // Find matching persona
  const key = Object.keys(personas).find(k =>
    k.toLowerCase() === normalized ||
    personas[k].titles.some(t => t.toLowerCase().includes(normalized))
  );

  if (!key) {
    // Return a generic context if persona not found
    return {
      role: personaName,
      pains: ["Control de gastos", "Visibilidad financiera", "Procesos manuales"],
      cares_about: ["Eficiencia", "Control", "Automatizacion"],
      questions: ["Como manejan los gastos corporativos actualmente?"]
    };
  }

  return personas[key];
}

/**
 * Get value props by country code
 * @param {string} countryCode - MX, AR, CL, CO, PE
 */
function getValueProps(countryCode) {
  const country = countryCode?.toUpperCase() || 'MX';
  const countryProps = valueProps[country] || valueProps['MX'];

  return {
    global: valueProps.global,
    country: countryProps,
    isMexico: country === 'MX'
  };
}

/**
 * Get email framework guidelines
 */
function getEmailFramework() {
  return {
    principles: {
      tone: "Conversacional + Directo - como si hablaras con un colega",
      never_salesy: "No 'increible oportunidad' ni 'solucion revolucionaria'",
      no_flattery: "No 'admiro tu trayectoria' sin razon especifica",
      ask_dont_assume: "Preguntar, no afirmar que tienen X problema"
    },
    structure: {
      max_words: 100,
      one_idea: "Una idea por email, no lista de features",
      cta: "Baja friccion: 'Te hace sentido?' > 'Agendamos 45 min?'"
    },
    dont_do: [
      "Empezar con 'Espero que estes bien'",
      "Me encantaria presentarme...",
      "Listar 5+ features",
      "Asumir que tienen un problema especifico",
      "Usar superlativos (la mejor, lider del mercado)",
      "Hablar de Mendel antes de hablar de ellos"
    ],
    templates: {
      open_question: "Pregunta abierta - para primer contacto sin senal clara",
      signal_trigger: "Basado en senal - cuando detectas algo especifico",
      case_study: "Caso de estudio - cuando tienes un caso relevante similar",
      validation: "Pregunta de validacion - para refinar targeting",
      super_short: "Super corto - follow-up o reengagement"
    }
  };
}

/**
 * Get ICP criteria for scoring
 */
function getICP() {
  return icp;
}

/**
 * Get industry snippets for email personalization
 */
function getIndustrySnippets(industry) {
  const snippets = {
    "retail": {
      pains: ["gastos distribuidos en multiples tiendas/sucursales", "control de trade marketing y activaciones", "viaticos de equipos de campo"],
      reference: "Mercado Libre, FEMSA"
    },
    "logistica": {
      pains: ["gastos de conductores y rutas", "combustible, peajes, viaticos", "control por ruta o centro de distribucion"],
      reference: "empresas de distribucion"
    },
    "tecnologia": {
      pains: ["suscripciones dispersas", "equipos distribuidos", "viajes a eventos y clientes"],
      reference: "Mercado Libre"
    },
    "manufactura": {
      pains: ["gastos en plantas y operaciones de campo", "mantenimiento y repuestos", "control por linea de negocio"],
      reference: "Grupo Omer"
    },
    "servicios": {
      pains: ["gastos por proyecto/cliente", "viajes, comidas, representacion", "facturacion al cliente basada en gasto real"],
      reference: "Adecco"
    },
    "consumo": {
      pains: ["equipos de campo dispersos", "activaciones y promociones", "trade marketing"],
      reference: "FEMSA, Unilever"
    },
    "food": {
      pains: ["multiples ubicaciones", "gastos operativos distribuidos", "control por sucursal"],
      reference: "McDonald's"
    }
  };

  const normalized = industry?.toLowerCase() || '';

  for (const [key, value] of Object.entries(snippets)) {
    if (normalized.includes(key)) {
      return value;
    }
  }

  return {
    pains: ["gastos corporativos distribuidos", "control de viaticos", "visibilidad financiera"],
    reference: "Mercado Libre, FEMSA, McDonald's"
  };
}

module.exports = {
  getPersonaContext,
  getValueProps,
  getEmailFramework,
  getICP,
  getIndustrySnippets
};
