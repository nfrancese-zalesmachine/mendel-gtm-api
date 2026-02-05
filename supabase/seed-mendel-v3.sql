-- =============================================
-- Mendel GTM API - Seed V3
-- Complete knowledge_base migration
-- =============================================

DO $$
DECLARE
  mendel_id UUID;
BEGIN
  SELECT id INTO mendel_id FROM clients WHERE slug = 'mendel';

  -- =============================================
  -- 1. SALES_PLAYBOOK (Battlecard)
  -- =============================================

  INSERT INTO sales_playbook (
    client_id,
    pitch_global,
    pitch_mexico,
    pitch_short,
    target_customer,
    discovery_questions,
    proof_points,
    competitive_summary,
    top_objections
  ) VALUES (
    mendel_id,

    -- pitch_global
    'Mendel is the corporate expense management platform for enterprise companies in Latin America. We combine intelligent VISA corporate cards with real-time controls and ERP integration - giving CFOs visibility before month-end surprises. Companies like Mercado Libre, FEMSA, and McDonald''s use Mendel to control expenses before they happen, not just report on them after.',

    -- pitch_mexico
    '...plus AI-powered invoice recovery that validates directly with SAT - increasing deductibility by 30% and reducing non-deductibles by 70%.',

    -- pitch_short
    'Plataforma de gestion de gastos corporativos con tarjetas VISA inteligentes para empresas enterprise en LATAM.',

    -- target_customer
    '{
      "size": "500-5,000+ employees",
      "geography": "Mexico (primary), Argentina, Colombia, Chile, Peru",
      "industries": ["Retail", "Logistics", "Tech", "F&B", "Services", "Manufacturing"],
      "pain": "High non-deductibles, no visibility, manual processes, shared cards without control"
    }'::jsonb,

    -- discovery_questions
    ARRAY[
      'Que porcentaje de sus gastos son no deducibles hoy?',
      'Cuantas horas le toma a tu equipo el cierre de mes?',
      'Cuando fue la ultima sorpresa en auditoria relacionada con documentacion de gastos?',
      'Como controlan lo que los empleados pueden gastar con tarjetas corporativas?',
      'Como manejan la visibilidad de gastos antes del cierre de mes?',
      'Cuanto tiempo dedican a conciliacion de gastos?',
      'Han tenido casos de uso inapropiado de tarjetas?'
    ],

    -- proof_points
    '{
      "Mercado Libre": "+30% increase in invoice recovery",
      "FEMSA": "Multi-BU expense control across 300,000+ employees",
      "McDonald''s": "90%+ deductibility, regional visibility",
      "Grupo Omer": "From 65% to 90%+ deductibility",
      "enterprise_clients": "500+ enterprise clients",
      "funding": "Series B: $35M from Base10 Partners",
      "growth": "ARR growing 2.5x, gross margins >75%"
    }'::jsonb,

    -- competitive_summary
    '{
      "Clara": "Enterprise focus, deeper fiscal compliance, SAP partnership",
      "Jeeves": "Local integration, SAP Concur alliance, LATAM-first",
      "SAP Concur": "We partner - we add cards + local compliance for Mexico",
      "Banks": "Software-first, real-time control, invoice recovery"
    }'::jsonb,

    -- top_objections
    '{
      "Excel works fine": "Hidden costs: hours, errors, non-deductibles. What % are you losing?",
      "Too expensive": "ROI from deductibility alone, payback <9 months",
      "Complex implementation": "6-8 weeks go-live, SAP connectors pre-built",
      "Already have Concur": "We complement - they partner with us for Mexico compliance"
    }'::jsonb
  )
  ON CONFLICT (client_id) DO UPDATE SET
    pitch_global = EXCLUDED.pitch_global,
    pitch_mexico = EXCLUDED.pitch_mexico,
    pitch_short = EXCLUDED.pitch_short,
    target_customer = EXCLUDED.target_customer,
    discovery_questions = EXCLUDED.discovery_questions,
    proof_points = EXCLUDED.proof_points,
    competitive_summary = EXCLUDED.competitive_summary,
    top_objections = EXCLUDED.top_objections,
    updated_at = NOW();

  -- =============================================
  -- 2. PRODUCT_FEATURES
  -- =============================================

  -- Invoice Recovery SAT (Mexico only)
  INSERT INTO product_features (
    client_id, slug, name, description, how_it_works, metrics,
    why_it_matters, availability_by_country, competitive_advantage,
    related_personas, is_addon
  ) VALUES (
    mendel_id,
    'invoice-recovery-sat',
    'Recupero Automatico de Facturas SAT',
    'AI-powered automatic invoice recovery from a photo of the receipt, validated against SAT (Mexico''s tax authority). Mendel''s killer feature for Mexico.',
    ARRAY[
      'Empleado paga con tarjeta Mendel',
      'Toma foto del ticket en la app',
      'IA de Mendel extrae datos e identifica comercio',
      'Recupera CFDI (factura oficial) del portal del comercio automaticamente',
      'Valida con SAT para asegurar validez fiscal',
      'Entrega PDF + XML a la empresa, taggeado al centro de costo'
    ],
    '{
      "invoice_recovery": {"before": "40-60%", "after": "80-90%", "improvement": "+30% or more"},
      "non_deductibles": {"before": "high", "after": "low", "improvement": "up to 70% reduction"},
      "time_per_employee": {"before": "8-10 hrs/month on expense reports", "after": "minutes", "improvement": "significant"}
    }'::jsonb,
    'In Mexico, every business must issue a CFDI for purchases. Without the CFDI, the expense is NOT tax deductible. Before Mendel, employees either don''t request invoice (lose deductibility), navigate each merchant''s unique portal (time consuming), or submit tickets to finance who chase invoices manually.',
    '{
      "MX": {"available": true, "note": "Funcionalidad completa: foto → factura → validacion SAT"},
      "AR": {"available": false, "note": "No existe equivalente. AFIP no tiene sistema similar al SAT"},
      "CL": {"available": false, "note": "SII opera diferente, no hay recupero automatico"},
      "CO": {"available": false, "note": "DIAN opera diferente"},
      "PE": {"available": false, "note": "SUNAT opera diferente"}
    }'::jsonb,
    '{
      "Clara": "No automatic recovery",
      "Jeeves": "No automatic recovery",
      "Banks": "No recovery capability",
      "SAP Concur": "Partners with Mendel for this in Mexico"
    }'::jsonb,
    ARRAY['Contabilidad', 'CFO', 'Controller'],
    false
  )
  ON CONFLICT (client_id, slug) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    how_it_works = EXCLUDED.how_it_works,
    metrics = EXCLUDED.metrics,
    why_it_matters = EXCLUDED.why_it_matters,
    availability_by_country = EXCLUDED.availability_by_country,
    competitive_advantage = EXCLUDED.competitive_advantage,
    related_personas = EXCLUDED.related_personas,
    updated_at = NOW();

  -- Mendel Viajes
  INSERT INTO product_features (
    client_id, slug, name, description, how_it_works, metrics,
    why_it_matters, availability_by_country, competitive_advantage,
    related_personas, is_addon
  ) VALUES (
    mendel_id,
    'mendel-viajes',
    'Mendel Viajes',
    'Solucion integral para gestion de viajes corporativos: reservas de vuelos, hoteles y autos con politicas automaticas y asistente IA.',
    ARRAY[
      'Empleado busca viaje en plataforma Mendel',
      'Sistema muestra opciones dentro de politica',
      'Reserva con asistente IA que recomienda mejores opciones',
      'Politicas se aplican automaticamente (limite por noche, categorias)',
      'Gasto de viaje integrado con resto de la plataforma',
      'Facturacion y rendicion automatica'
    ],
    '{
      "policy_compliance": {"before": "40-60%", "after": "90%+"},
      "booking_time": {"before": "Multiple platforms, manual", "after": "Single platform, AI-assisted"}
    }'::jsonb,
    'Travel spend is often a blind spot. Employees book through multiple channels (agencies, OTAs, personal cards), policies exist on paper but aren''t enforced, and finance lacks consolidated data to negotiate better rates.',
    '{
      "MX": {"available": true, "note": "Reservas + facturacion automatica SAT"},
      "AR": {"available": true, "note": "Manejo multi-moneda"},
      "CL": {"available": true, "note": "Politicas regionalizadas"},
      "CO": {"available": true, "note": "Politicas regionalizadas"},
      "PE": {"available": true, "note": "Politicas regionalizadas"}
    }'::jsonb,
    '{
      "Traditional Agency": "Manual booking, no policy enforcement",
      "OTAs": "Self-service but no policies, no data",
      "Concur": "Global T&E but Mendel adds local compliance"
    }'::jsonb,
    ARRAY['TravelRRHH', 'CFO', 'FinanzasOperativas'],
    true
  )
  ON CONFLICT (client_id, slug) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    how_it_works = EXCLUDED.how_it_works,
    metrics = EXCLUDED.metrics,
    updated_at = NOW();

  -- Tarjetas Corporativas
  INSERT INTO product_features (
    client_id, slug, name, description, how_it_works, metrics,
    why_it_matters, availability_by_country, competitive_advantage,
    related_personas, is_addon
  ) VALUES (
    mendel_id,
    'corporate-cards',
    'Tarjetas Corporativas VISA Inteligentes',
    'Tarjetas de credito VISA corporativas (fisicas y virtuales ilimitadas) con reglas de uso configurables por persona, area, horario y comercio.',
    ARRAY[
      'Emision instantanea de tarjetas desde plataforma',
      'Configuracion de reglas: dias, horarios, comercios, categorias, limites',
      'Empleado usa tarjeta para gasto',
      'Transaccion validada contra reglas en tiempo real',
      'Si cumple politica: aprobada. Si no: bloqueada',
      'Notificacion inmediata al empleado y finanzas'
    ],
    '{
      "card_issuance": {"before": "Days/weeks via bank", "after": "Instant"},
      "control": {"before": "Only credit limit", "after": "Granular rules"},
      "fraud_prevention": {"improvement": "Real-time blocking"}
    }'::jsonb,
    'Traditional bank cards offer credit but no granular control. Companies either use shared cards (no accountability) or have limited cards for executives only. Mendel enables cards for everyone with controls.',
    '{
      "MX": {"available": true, "note": "Tarjetas VISA emitidas por Mendel"},
      "AR": {"available": true, "note": "Tarjetas emitidas por Banco CMF"},
      "CL": {"available": true, "note": "Tarjetas VISA corporativas"},
      "CO": {"available": true, "note": "Tarjetas VISA corporativas"},
      "PE": {"available": true, "note": "Tarjetas VISA corporativas"}
    }'::jsonb,
    '{
      "Banks": "Only credit limits, no granular rules, manual blocking",
      "Clara": "Basic limits only",
      "Jeeves": "Basic limits only"
    }'::jsonb,
    ARRAY['Tesoreria', 'CFO', 'Controller'],
    false
  )
  ON CONFLICT (client_id, slug) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    how_it_works = EXCLUDED.how_it_works,
    updated_at = NOW();

  -- =============================================
  -- 3. EMAIL_TEMPLATES (Follow-ups)
  -- =============================================

  INSERT INTO email_templates (client_id, slug, name, template_type, when_to_use, template_structure, example, sequence_order, days_after_previous) VALUES

  (mendel_id, 'open-question', 'Pregunta Abierta', 'first_contact',
   'No tienes senal clara, quieres validar si hay dolor. Recomendado para primer contacto.',
   'Hola {FirstName},

Por el tamaño de {CompanyName} quería preguntarte: ¿cómo están manejando actualmente {área de dolor según persona}?

Te lo pregunto porque trabajamos con {CompanyType} en {país} ayudándoles con {value prop resumida}.

Si tiene sentido, me encantaría mostrarte cómo funciona.

{Firma}',
   'Hola María,

Por el tamaño de Grupo Lala quería preguntarte: ¿cómo están manejando actualmente la visibilidad de gastos corporativos antes del cierre de mes?

Te lo pregunto porque trabajamos con empresas de consumo masivo en México ayudándoles a recuperar hasta 30% más facturas del SAT de forma automática.

Si tiene sentido, me encantaría mostrarte cómo funciona.

Saludos, Juan',
   1, 0),

  (mendel_id, 'signal-trigger', 'Senal/Trigger', 'signal_trigger',
   'Cuando detectas algo específico: contratación nueva, nota de prensa, expansión, funding.',
   'Hola {FirstName},

Vi que {señal específica} — {comentario breve, no flattery}.

Me hizo pensar que {conexión con value prop} podría ser relevante para {CompanyName}.

¿Es algo que están considerando o estoy fuera de base?

{Firma}',
   'Hola Carlos,

Vi que están abriendo operaciones en Monterrey — felicidades por la expansión.

Me hizo pensar que el control de gastos en múltiples ubicaciones podría complicarse. Trabajamos con empresas en crecimiento ayudándoles a consolidar todo en una sola plataforma.

¿Es algo que están considerando o estoy fuera de base?

Saludos, Ana',
   1, 0),

  (mendel_id, 'case-study', 'Caso de Estudio', 'case_study',
   'Cuando tienes un caso relevante: empresa similar en industria/tamaño/país.',
   'Hola {FirstName},

Acabamos de ayudar a {Case Study} a {resultado específico} en {timeframe}.

Estaban lidiando con {problema} — me recordó a empresas como {CompanyName}.

¿Te interesa ver si aplica algo similar?

{Firma}',
   'Hola Roberto,

Acabamos de ayudar a una empresa de logística a pasar de tarjetas bancarias compartidas a tarjetas individuales con reglas por conductor — redujeron fraude un 40%.

Estaban lidiando con el control de quién gastaba qué — me recordó a flotas de distribución como la de ustedes.

¿Te interesa ver si aplica algo similar?

Saludos, Pedro',
   1, 0),

  (mendel_id, 'followup-1', 'Follow-up 1', 'followup',
   'Primer follow-up, 3-4 días después del primer contacto.',
   'Hola {FirstName},

¿Tuviste oportunidad de ver mi mensaje anterior?

Si {pain point} es algo que están resolviendo, me encantaría mostrarte cómo lo abordamos con empresas similares.

{Firma}',
   NULL,
   2, 4),

  (mendel_id, 'followup-2', 'Follow-up 2', 'followup',
   'Segundo follow-up, 7 días después del primero.',
   'Hola {FirstName},

Entiendo que probablemente estás ocupado.

Empresas como {cliente similar} usan Mendel para {resultado}.

¿Te hace sentido una llamada de 15 min para ver si aplica?

{Firma}',
   NULL,
   3, 7),

  (mendel_id, 'breakup', 'Breakup Email', 'breakup',
   'Email de cierre, 14 días después. Último intento antes de pausar.',
   'Hola {FirstName},

Tal vez el timing no es el correcto.

Si en algún momento {pain point} se vuelve prioridad, aquí estamos.

{Firma}',
   NULL,
   4, 14);

  -- =============================================
  -- 4. UPDATE COMPETITORS with when_we_win/when_they_win
  -- =============================================

  -- Clara
  UPDATE competitors SET
    positioning = 'Cards + expense control for startups and scaleups in Mexico',
    when_we_win = ARRAY[
      'Company needs enterprise-grade controls',
      'Deep fiscal compliance is critical (high non-deductibles)',
      'SAP/Oracle integration required',
      '500+ employees with complex expense flows'
    ],
    when_they_win = ARRAY[
      'Startups prioritizing easy card issuance',
      'Credit line is the main need',
      '<200 employees'
    ],
    how_we_work_together = NULL
  WHERE client_id = mendel_id AND name = 'Clara';

  -- Jeeves
  UPDATE competitors SET
    positioning = 'Multi-currency cards for globally distributed startups',
    when_we_win = ARRAY[
      'Company is LATAM-focused (not global)',
      'Local fiscal compliance matters more than multi-currency',
      'ERP integration is required'
    ],
    when_they_win = ARRAY[
      'Company has global distributed team',
      'Multi-currency cashback is priority',
      'Cross-border payments main use case'
    ],
    how_we_work_together = NULL
  WHERE client_id = mendel_id AND name = 'Jeeves';

  -- SAP Concur
  UPDATE competitors SET
    positioning = 'Global T&E solution for enterprise',
    when_we_win = ARRAY[
      'Mexican fiscal compliance is a gap',
      'Need cards + expense management in one',
      'Want local LATAM support'
    ],
    when_they_win = ARRAY[
      'Global T&E standardization is priority',
      'Already have Concur globally'
    ],
    how_we_work_together = 'Concur handles global T&E policy, Mendel handles local invoice recovery and cards in Mexico. Official partnership announced.'
  WHERE client_id = mendel_id AND name = 'SAP Concur';

  -- Banks
  UPDATE competitors SET
    positioning = 'Credit line + basic transaction visibility',
    when_we_win = ARRAY[
      'Company needs real-time controls (not just limits)',
      'Invoice recovery is important',
      'Integration with ERP required',
      'Centralized policy management needed'
    ],
    when_they_win = ARRAY[
      'Simple credit line is sufficient',
      'No need for expense management software'
    ],
    how_we_work_together = 'Mendel complements bank relationship, does not replace it. Cards are additional method of payment.'
  WHERE client_id = mendel_id AND name LIKE 'Banca Tradicional%';

  -- =============================================
  -- 5. UPDATE PERSONAS with detailed fields
  -- =============================================

  -- CFO
  UPDATE personas SET
    responsibilities = ARRAY[
      'Budget governance and cash flow management',
      'Fiscal compliance and audit readiness',
      'Bank and financial provider relationships',
      'Profitability and cost optimization'
    ],
    value_props_by_country = '{
      "MX": ["30% mas recupero de facturas SAT", "70% reduccion de no deducibles", "Visibilidad real-time"],
      "AR": ["Conciliacion multi-moneda", "Integracion con sistemas locales", "Visibilidad real-time"],
      "ALL": ["Visibilidad real-time por area, proyecto, centro de costo", "Control preventivo antes del gasto", "Eficiencia del equipo de finanzas"]
    }'::jsonb,
    success_metrics = '{
      "deductibles": {"metric": "% gastos deducibles vs totales", "improvement": "60% → 90%+"},
      "budget_deviation": {"metric": "Desvios de presupuesto", "improvement": "Reduccion significativa"},
      "savings": {"metric": "Ahorros identificados", "improvement": "Nuevo insight"}
    }'::jsonb,
    is_decision_maker = true,
    email_snippets = '{
      "pains_to_mention": ["visibilidad de gastos antes del cierre", "control sobre lo que ya se gasto vs presupuesto", "preparacion para auditorias", "gastos no deducibles (MX)"],
      "questions_that_work": ["Como manejan la visibilidad de gastos antes del cierre de mes?", "Que porcentaje de gastos terminan siendo no deducibles? (MX)", "Cuanto tiempo les toma el cierre mensual?"]
    }'::jsonb
  WHERE client_id = mendel_id AND slug = 'CFO';

  -- Controller
  UPDATE personas SET
    responsibilities = ARRAY[
      'Conciliacion de gastos y estados financieros',
      'Generacion de asientos contables',
      'Relacion operativa con bancos',
      'Cierres mensuales y trimestrales',
      'Preparacion de reportes para direccion'
    ],
    value_props_by_country = '{
      "MX": ["Recuperacion automatica de facturas SAT = menos tiempo persiguiendo CFDIs", "Validacion fiscal automatica = menos errores en auditorias"],
      "AR": ["Conciliacion multi-moneda (pesos, USD)", "Integracion con sistemas locales"],
      "ALL": ["Menos captura manual", "Flujos automaticos hacia el ERP", "Cierres de mes mas rapidos"]
    }'::jsonb,
    relationship_to_others = '{
      "CFO": "CFO decide estrategicamente, Controller valida operativamente",
      "note": "Si el Controller no esta convencido, la implementacion sufre"
    }'::jsonb,
    is_decision_maker = false,
    email_snippets = '{
      "pains_to_mention": ["conciliacion manual", "perseguir facturas/comprobantes", "errores en clasificacion de centros de costo", "cierres de mes extensos"],
      "questions_that_work": ["Cuantas horas al mes dedican a conciliacion de gastos?", "Como manejan cuando un empleado no entrega su comprobante?", "Que tan frecuentes son los errores de clasificacion?"]
    }'::jsonb
  WHERE client_id = mendel_id AND slug = 'Controller';

  -- Tesoreria
  UPDATE personas SET
    responsibilities = ARRAY[
      'Gestion de cuentas bancarias y liquidez',
      'Administracion de tarjetas corporativas',
      'Relacion operativa con bancos',
      'Control de flujo de caja',
      'Aprobacion de pagos y desembolsos'
    ],
    value_props_by_country = '{
      "MX": ["Tarjetas VISA con aceptacion global", "Control granular pre-gasto", "Integracion con recupero de facturas SAT"],
      "AR": ["Tarjetas emitidas por Banco CMF", "Manejo multi-moneda (ARS/USD)", "Control en contexto inflacionario"],
      "ALL": ["Tarjetas con reglas por persona, horario, comercio", "Emision/bloqueo instantaneo", "Visibilidad real-time de cada transaccion"]
    }'::jsonb,
    is_decision_maker = false,
    email_snippets = '{
      "pains_to_mention": ["tarjetas compartidas", "control de quien gasto que", "proceso para emitir/bloquear tarjetas", "fraude interno"],
      "questions_that_work": ["Como controlan el uso de tarjetas corporativas hoy?", "Que tan facil es emitir o bloquear una tarjeta?", "Han tenido casos de uso inapropiado de tarjetas?"]
    }'::jsonb
  WHERE client_id = mendel_id AND slug = 'Tesoreria';

  -- Contabilidad
  UPDATE personas SET
    responsibilities = ARRAY[
      'Registro de asientos contables',
      'Cumplimiento fiscal (SAT/AFIP/SII)',
      'Conciliacion de cuentas',
      'Preparacion para auditorias',
      'Gestion de deducibilidad fiscal'
    ],
    process_before_after = '{
      "before": {
        "steps": ["Empleado gasta con tarjeta", "Guarda ticket (o lo pierde)", "A fin de mes entrega tickets", "Contabilidad entra a portal de cada comercio", "Genera factura manualmente", "Captura en ERP"],
        "result": "40-60% de facturas recuperadas"
      },
      "after": {
        "steps": ["Empleado gasta con tarjeta Mendel", "Toma foto del ticket en la app", "Mendel recupera factura automaticamente", "Valida con SAT", "Sincroniza con ERP"],
        "result": "80-90% de facturas recuperadas"
      }
    }'::jsonb,
    success_metrics = '{
      "invoice_recovery": {"before": "40-60%", "after": "80-90%"},
      "month_close_time": {"before": "2-3 semanas", "after": "3-5 dias"},
      "manual_capture_hours": {"before": "40+ hrs/mes", "after": "<5 hrs/mes"},
      "classification_errors": {"before": "Frecuentes", "after": "Raros"}
    }'::jsonb,
    is_decision_maker = false,
    email_snippets = '{
      "pains_to_mention": ["facturas faltantes", "captura manual al ERP", "deducibilidad (MX)", "perseguir empleados por comprobantes"],
      "questions_that_work": ["Que porcentaje de facturas logran recuperar hoy? (MX)", "Cuanto tiempo dedican a la captura manual de gastos?", "Es frecuente que lleguen a cierre sin comprobantes?"]
    }'::jsonb
  WHERE client_id = mendel_id AND slug = 'Contabilidad';

  -- FP&A
  UPDATE personas SET
    responsibilities = ARRAY[
      'Elaboracion y seguimiento de presupuestos',
      'Forecasting y proyecciones financieras',
      'Analisis de variaciones (real vs presupuesto)',
      'Reportes para direccion y consejo',
      'Identificacion de oportunidades de ahorro'
    ],
    is_decision_maker = false,
    email_snippets = '{
      "pains_to_mention": ["datos de gasto llegan tarde", "consolidar multiples fuentes", "presupuestos desactualizados"],
      "questions_that_work": ["Que tan actualizada esta su informacion de gasto para forecast?", "De cuantas fuentes consolidan datos de gastos?", "Pueden ajustar presupuestos en tiempo real?"]
    }'::jsonb
  WHERE client_id = mendel_id AND slug = 'FPA';

  -- Finanzas Operativas
  UPDATE personas SET
    responsibilities = ARRAY[
      'Gestion de rendiciones de gastos',
      'Procesamiento de reembolsos',
      'Flujos de aprobacion',
      'Digitalizacion de procesos financieros',
      'Relacion con empleados (gastos, viaticos)'
    ],
    process_before_after = '{
      "before": {
        "steps": ["Empleado gasta con dinero personal", "Guarda tickets", "A fin de mes llena formato Excel", "Envia por correo a su jefe", "Jefe aprueba (cuando puede)", "Finanzas revisa", "Se incluye en siguiente nomina"],
        "result": "15-45 dias para reembolso"
      },
      "after": {
        "steps": ["Empleado registra gasto en app", "Sube foto de comprobante", "Flujo de aprobacion automatico", "Reembolso instantaneo a cuenta"],
        "result": "24-72 horas para reembolso"
      }
    }'::jsonb,
    success_metrics = '{
      "reimbursement_time": {"before": "15-45 dias", "after": "24-72 hrs"},
      "employee_complaints": {"before": "Frecuentes", "after": "Raras"},
      "time_on_management": {"before": "20+ hrs/semana", "after": "<5 hrs/semana"},
      "policy_compliance": {"before": "40-60%", "after": "90%+"}
    }'::jsonb,
    relationship_to_others = '{
      "Ventas": "Necesito mis viaticos YA - Solucion: Tarjetas con presupuesto, reembolsos rapidos",
      "Operaciones": "El proceso de gastos es muy lento - Solucion: App movil, flujos automaticos",
      "RRHH": "Empleados se quejan de reembolsos - Solucion: Visibilidad del estatus, tiempos reducidos"
    }'::jsonb,
    is_decision_maker = false,
    email_snippets = '{
      "pains_to_mention": ["rendiciones por correo/WhatsApp", "reembolsos tardios", "aprobaciones manuales", "friccion con otras areas"],
      "questions_that_work": ["Cuanto tiempo tarda un reembolso hoy?", "Como manejan las aprobaciones de gastos?", "Reciben quejas de empleados por el proceso?"]
    }'::jsonb
  WHERE client_id = mendel_id AND slug = 'FinanzasOperativas';

  -- Travel RRHH
  UPDATE personas SET
    responsibilities = ARRAY[
      'Politicas de viajes corporativos',
      'Reservas de vuelos, hoteles, autos',
      'Negociacion con proveedores',
      'Experiencia del colaborador en viajes',
      'Control de presupuesto de viajes'
    ],
    is_decision_maker = false,
    email_snippets = '{
      "pains_to_mention": ["reservas dispersas", "politicas de viaje que no se cumplen", "falta de datos para negociar con proveedores"],
      "questions_that_work": ["Como aseguran que se cumplan las politicas de viaje?", "Tienen visibilidad consolidada del gasto de viajes?", "Cada quien reserva por su cuenta o hay un proceso?"]
    }'::jsonb
  WHERE client_id = mendel_id AND slug = 'TravelRRHH';

END $$;
