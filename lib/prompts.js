/**
 * Build prompt for cold email generation
 */
function buildEmailPrompt({
  persona,
  country,
  industry,
  company_name,
  contact_name,
  company_size,
  signals,           // array de señales
  additional_context,
  custom_fields,     // campos personalizados de Clay
  personaContext,
  valueProps,
  emailFramework,
  industrySnippets   // industry snippets passed from caller
}) {
  const isMexico = valueProps.isMexico;
  // Use provided industrySnippets or fallback
  const snippets = industrySnippets || {
    pains: ["gastos corporativos distribuidos", "control de viáticos", "visibilidad financiera"],
    reference: "Mercado Libre, FEMSA, McDonald's"
  };

  // Formatear signals como lista o texto
  const signalsText = signals && signals.length > 0
    ? signals.length === 1
      ? `- Senal/Trigger: ${signals[0]}`
      : `- Senales detectadas:\n${signals.map(s => `  - ${s}`).join('\n')}`
    : '';

  // Formatear custom fields
  const customFieldsText = custom_fields
    ? `- Datos adicionales:\n${Object.entries(custom_fields)
        .filter(([_, v]) => v && String(v).trim())
        .map(([k, v]) => `  - ${k}: ${v}`)
        .join('\n')}`
    : '';

  return `Eres un SDR senior de Mendel, una plataforma de gestion de gastos corporativos para empresas enterprise en Latinoamerica.

## REGLAS DE EMAIL (OBLIGATORIAS)
${JSON.stringify(emailFramework.principles, null, 2)}

### Estructura
- Maximo ${emailFramework.structure.max_words} palabras en el cuerpo
- ${emailFramework.structure.one_idea}
- CTA: ${emailFramework.structure.cta}

### NUNCA hagas esto
${emailFramework.dont_do.map(d => `- ${d}`).join('\n')}

## CONTEXTO DEL PROSPECTO
- Nombre: ${contact_name}
- Empresa: ${company_name}
- Cargo/Persona: ${persona}
- Pais: ${valueProps.country.country_name}
- Industria: ${industry || 'No especificada'}
${company_size ? `- Tamano: ${company_size} empleados` : ''}
${signalsText}
${additional_context ? `- Contexto adicional: ${additional_context}` : ''}
${customFieldsText}

## DOLOR DE ESTA PERSONA (${persona})
${personaContext.pains.map(p => `- ${p}`).join('\n')}

## LO QUE LE IMPORTA
${personaContext.cares_about.map(c => `- ${c}`).join('\n')}

## PREGUNTAS QUE FUNCIONAN CON ESTA PERSONA
${personaContext.questions.map(q => `- "${q}"`).join('\n')}

## VALUE PROPS PARA ${valueProps.country.country_name.toUpperCase()}
${isMexico ?
    `### Mexico - FUNCIONALIDAD CLAVE
${valueProps.country.specific_value_props.map(v => `- ${v}`).join('\n')}

IMPORTANTE: En Mexico SÍ puedes mencionar recupero de facturas SAT y deducibilidad.` :
    `### ${valueProps.country.country_name}
${valueProps.country.specific_value_props.map(v => `- ${v}`).join('\n')}

IMPORTANTE: En ${valueProps.country.country_name} NO existe recupero automatico de facturas tipo SAT. NO menciones deducibilidad ni facturas SAT.`
  }

## SNIPPETS DE INDUSTRIA (${industry || 'General'})
- Dolores tipicos: ${snippets.pains.join(', ')}
- Clientes referencia: ${snippets.reference}

## CLIENTES REFERENCIA GLOBAL
${valueProps.global.reference_clients.join(', ')}

---

${signals && signals.length > 0 ?
    `TIPO DE EMAIL: Con senal/trigger
Escribe un email que conecte ${signals.length === 1 ? `la senal "${signals[0]}"` : `las senales detectadas (${signals.join(', ')})`} con el valor que Mendel puede aportar. Usa la senal mas relevante como gancho.` :
    `TIPO DE EMAIL: Pregunta abierta
Escribe un email que haga una pregunta relevante al dolor de esta persona, sin asumir que tienen el problema.`
  }

Genera el cold email en espanol. Solo devuelve el email, sin explicaciones adicionales.`;
}

/**
 * Build prompt for research brief generation
 */
function buildResearchPrompt({
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
}) {
  const isMexico = valueProps.isMexico;

  return `Eres un analista de cuentas de Mendel, una plataforma de gestion de gastos corporativos para empresas enterprise en Latinoamerica.

## TU TAREA
Genera un research brief de la cuenta ${company_name} para que el equipo de ventas tenga contexto antes de contactar.

## INFORMACION DE LA EMPRESA
- Nombre: ${company_name}
- Pais: ${valueProps.country.country_name}
- Industria: ${industry || 'No especificada'}
${company_size ? `- Tamano: ${company_size} empleados` : ''}
${company_description ? `- Descripcion: ${company_description}` : ''}
${recent_news ? `- Noticias recientes: ${recent_news}` : ''}
${technologies ? `- Tecnologias detectadas: ${technologies}` : ''}
${key_contacts ? `- Contactos clave: ${JSON.stringify(key_contacts)}` : ''}

## ICP DE MENDEL
- Tamano ideal: ${icp.firmographics.size.sweet_spot} empleados
- Industrias Tier 1: ${icp.industries.tier1_best_fit.map(i => i.name).join(', ')}
- Industrias Tier 2: ${icp.industries.tier2_good_fit.map(i => i.name).join(', ')}
- Senales de calificacion: ${icp.qualifying_signals.include.join(', ')}

## VALUE PROPS PARA ${valueProps.country.country_name.toUpperCase()}
${valueProps.country.specific_value_props.map(v => `- ${v}`).join('\n')}

${!isMexico ? `NOTA: En ${valueProps.country.country_name} NO existe recupero automatico de facturas tipo SAT.` : ''}

## CLIENTES REFERENCIA
${valueProps.global.reference_clients.join(', ')}

---

## FORMATO DEL BRIEF

Genera un research brief con las siguientes secciones:

### 1. Resumen Ejecutivo (2-3 oraciones)
Que hace la empresa y por que podria ser buen fit para Mendel.

### 2. Fit con ICP (Alto/Medio/Bajo)
Evalua que tan bien encaja con nuestro perfil de cliente ideal.

### 3. Angulos de Entrada
Lista 2-3 angulos especificos para iniciar la conversacion basados en:
- Industria y sus dolores tipicos
- Tamano y complejidad probable
- Noticias o senales detectadas (si hay)

### 4. Personas a Contactar
Sugiere 2-3 roles a contactar en orden de prioridad, con razon.

### 5. Preguntas de Discovery Sugeridas
3-4 preguntas especificas para la primera llamada.

### 6. Riesgos / Banderas Rojas
Cualquier razon por la que podrian NO ser buen fit.

---

Genera el brief en espanol. Se conciso y accionable.`;
}

/**
 * Build prompt for lead scoring
 */
function buildScoringPrompt({
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
}) {
  return `Eres un analista de calificacion de leads de Mendel, una plataforma de gestion de gastos corporativos para empresas enterprise en Latinoamerica.

## TU TAREA
Evalua y puntua este lead segun el ICP de Mendel.

## INFORMACION DEL LEAD
- Empresa: ${company_name}
- Pais: ${country}
- Industria: ${industry || 'No especificada'}
- Tamano: ${company_size || 'No especificado'} empleados
${company_description ? `- Descripcion: ${company_description}` : ''}
${persona ? `- Contacto - Rol: ${persona}` : ''}
${seniority ? `- Contacto - Seniority: ${seniority}` : ''}
${technologies ? `- Tecnologias: ${technologies}` : ''}
${signals ? `- Senales detectadas: ${JSON.stringify(signals)}` : ''}

## CRITERIOS DE SCORING DE MENDEL

### Tamano de Empresa (Max 5 pts)
${JSON.stringify(icp.scoring_criteria.company_size, null, 2)}

### Pais (Max 5 pts)
${JSON.stringify(icp.scoring_criteria.country, null, 2)}

### Industria
- Tier 1 (${icp.industries.tier1_best_fit.map(i => i.name).join(', ')}): ${icp.scoring_criteria.industry_tier1} pts
- Tier 2 (${icp.industries.tier2_good_fit.map(i => i.name).join(', ')}): ${icp.scoring_criteria.industry_tier2} pts
- Otra: 1 pt

### Otros Factores
- Tiene ERP (SAP, Oracle, NetSuite): +${icp.scoring_criteria.has_erp} pts
- Tiene equipos de campo: +${icp.scoring_criteria.has_field_teams} pts
- Senal de crecimiento: +${icp.scoring_criteria.growth_signal} pts
- Senal de funding: +${icp.scoring_criteria.funding_signal} pts

### Exclusiones (Descalifica)
${icp.qualifying_signals.exclude.map(e => `- ${e}`).join('\n')}

---

## FORMATO DE RESPUESTA

Responde UNICAMENTE con un JSON valido con esta estructura:

{
  "score": <numero del 1 al 100>,
  "tier": "<A|B|C|D>",
  "fit_summary": "<resumen de 1-2 oraciones del fit>",
  "scoring_breakdown": {
    "company_size": <pts>,
    "country": <pts>,
    "industry": <pts>,
    "erp": <pts>,
    "field_teams": <pts>,
    "signals": <pts>
  },
  "strengths": ["<fortaleza 1>", "<fortaleza 2>"],
  "weaknesses": ["<debilidad 1>", "<debilidad 2>"],
  "recommended_action": "<accion recomendada: contact_now | nurture | disqualify>",
  "best_persona_to_contact": "<CFO | Controller | Tesoreria | etc>",
  "reasoning": "<explicacion breve del scoring>"
}

Tiers:
- A (80-100): Fit excelente, contactar inmediatamente
- B (60-79): Buen fit, prioridad media
- C (40-59): Fit moderado, requiere validacion
- D (0-39): Fit bajo, considerar descalificar

Responde SOLO con el JSON, sin texto adicional.`;
}

/**
 * Build prompt for custom/flexible generation
 */
function buildCustomPrompt({
  task,
  output_format,
  include_context,
  persona,
  country,
  industry,
  company_name,
  contact_name,
  company_size,
  signals,
  additional_context,
  custom_fields,
  personaContext,
  valueProps,
  icp
}) {
  // Construir sección de contexto del prospecto
  let prospectContext = '';
  if (company_name || contact_name || persona || country) {
    prospectContext = `
## DATOS DEL PROSPECTO
${contact_name ? `- Nombre: ${contact_name}` : ''}
${company_name ? `- Empresa: ${company_name}` : ''}
${persona ? `- Cargo/Persona: ${persona}` : ''}
${country && valueProps ? `- País: ${valueProps.country.country_name}` : ''}
${industry ? `- Industria: ${industry}` : ''}
${company_size ? `- Tamaño: ${company_size} empleados` : ''}
${signals && signals.length > 0 ? `- Señales detectadas: ${signals.join(', ')}` : ''}
${additional_context ? `- Contexto adicional: ${additional_context}` : ''}
${custom_fields ? `- Datos extra:\n${Object.entries(custom_fields).filter(([_, v]) => v).map(([k, v]) => `  - ${k}: ${v}`).join('\n')}` : ''}
`.trim();
  }

  // Construir sección de contexto Mendel (opcional)
  let mendelContext = '';
  if (include_context) {
    mendelContext = `
## CONTEXTO DE MENDEL (Plataforma de gestión de gastos corporativos)

### Clientes referencia
Mercado Libre, FEMSA, McDonald's, Unilever, Adecco

### Value props principales
- Visibilidad real-time de gastos (vs sorpresas de fin de mes)
- Tarjetas corporativas con reglas por persona/área/horario
- Integración ERP nativa (SAP, Oracle, NetSuite)
- Enfoque enterprise (vs Clara/Jeeves que son SMB)
${valueProps?.isMexico ? `
### México - Diferenciador clave
- Recupero automático de facturas SAT (+30%)
- Reducción del 70% en gastos no deducibles
- Validación CFDI automática` : valueProps?.country ? `
### ${valueProps.country.country_name}
${valueProps.country.specific_value_props?.map(v => `- ${v}`).join('\n') || ''}
NOTA: NO hay recupero automático de facturas tipo SAT en este país.` : ''}
${personaContext ? `
### Dolor típico de ${persona}
${personaContext.pains?.slice(0, 3).map(p => `- ${p}`).join('\n') || ''}` : ''}
`.trim();
  }

  // Instrucciones de formato
  let formatInstructions = '';
  if (output_format === 'json') {
    formatInstructions = '\n\nIMPORTANTE: Responde ÚNICAMENTE con JSON válido, sin texto adicional antes o después.';
  } else if (output_format === 'markdown') {
    formatInstructions = '\n\nFormatea la respuesta en Markdown.';
  }

  return `Eres un experto en GTM (Go-To-Market) para Mendel, una plataforma de gestión de gastos corporativos para empresas enterprise en Latinoamérica.

${prospectContext}

${mendelContext}

---

## TU TAREA

${task}
${formatInstructions}

Responde en español.`;
}

module.exports = {
  buildEmailPrompt,
  buildResearchPrompt,
  buildScoringPrompt,
  buildCustomPrompt
};
