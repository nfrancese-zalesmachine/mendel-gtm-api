-- ============================================
-- Mendel GTM API - Seed Data
-- Initial data for Mendel client
-- ============================================

-- ============================================
-- INSERT MENDEL CLIENT
-- ============================================
INSERT INTO clients (slug, name, description) VALUES
('mendel', 'Mendel', 'Plataforma de gestión de gastos corporativos para empresas enterprise en Latinoamérica');

-- Get Mendel client ID for foreign keys
DO $$
DECLARE
  mendel_id UUID;
BEGIN
  SELECT id INTO mendel_id FROM clients WHERE slug = 'mendel';

  -- ============================================
  -- PERSONAS
  -- ============================================
  INSERT INTO personas (client_id, slug, titles, role, reports_to, pains, cares_about, questions, objections) VALUES
  (mendel_id, 'CFO',
    ARRAY['CFO', 'Director de Finanzas', 'VP Finance', 'Director Financiero'],
    'Decisor final',
    'CEO / Board',
    ARRAY[
      'No real-time visibility - encuentra overspending al cierre de mes',
      'Gastos no deducibles - facturas faltantes o incorrectas cuestan impuestos',
      'Riesgo de fraude - tarjetas compartidas, sin controles',
      'Estrés de auditoría - procesos manuales crean gaps de compliance'
    ],
    ARRAY[
      'Visibilidad en tiempo real por área, proyecto, centro de costo',
      'Deducibilidad - recuperar más facturas (MX)',
      'Control preventivo antes del gasto',
      'Eficiencia del equipo de finanzas'
    ],
    ARRAY[
      '¿Cómo manejan la visibilidad de gastos antes del cierre de mes?',
      '¿Qué porcentaje de sus gastos terminan siendo no deducibles? (MX)',
      '¿Cuánto tiempo les toma el cierre mensual?'
    ],
    '{"Excel + tarjetas bancarias funcionan bien": "Funciona hasta que escalan; costos ocultos en horas, errores, no deducibles", "La implementación va a romper nuestro cierre": "Se integra con ERP, no lo reemplaza; partnership con SAP Concur lo valida", "Es muy caro": "ROI de deducibilidad + ahorro de tiempo, payback <9 meses"}'::jsonb
  ),
  (mendel_id, 'Controller',
    ARRAY['Controller', 'Contralor', 'Finance Controller', 'Gerente de Control de Gestión'],
    'Champion operativo',
    'CFO',
    ARRAY[
      'Horas en conciliación manual - extractos vs Excel vs ERP = semanas',
      'Errores en clasificaciones - centro de costo incorrecto, impuestos mal aplicados',
      'Perseguir facturas - pedir comprobantes a empleados que no responden',
      'Cierres de mes extensos - proceso reactivo, no proactivo'
    ],
    ARRAY[
      'Automatización - eliminar captura manual y doble trabajo',
      'Precisión - clasificación correcta desde el origen',
      'Velocidad de cierre - de semanas a días',
      'Auditorías tranquilas - todo documentado y trazable'
    ],
    ARRAY[
      '¿Cuántas horas al mes dedican a conciliación de gastos?',
      '¿Cómo manejan cuando un empleado no entrega su comprobante?',
      '¿Qué tan frecuentes son los errores de clasificación?'
    ],
    '{"Va a ser difícil integrarlo con nuestro ERP": "Conectores nativos con SAP, Oracle, NetSuite; implementación en 6-8 semanas", "Mi equipo ya tiene su proceso": "Libera tiempo para trabajo de valor vs perseguir tickets", "El cambio va a ser caótico": "Piloto controlado de 30 días con un departamento"}'::jsonb
  ),
  (mendel_id, 'Tesoreria',
    ARRAY['Gerente de Tesorería', 'Tesorero', 'Treasury Manager', 'Cash Manager'],
    'Champion - control de tarjetas y pagos',
    'CFO / Controller',
    ARRAY[
      'Tarjetas sin controles - compartidas, sin reglas, difícil saber quién gastó qué',
      'Riesgo de fraude - uso inapropiado difícil de detectar hasta el cierre',
      'Aprobaciones manuales lentas - correos, WhatsApp, Excel',
      'Relación compleja con bancos - procesos manuales para emitir/bloquear tarjetas'
    ],
    ARRAY[
      'Control de tarjetas - reglas por persona, área, horario, comercio',
      'Prevención de fraude - detectar y bloquear antes de que ocurra',
      'Visibilidad de cash flow - saber qué se gastó en tiempo real',
      'Presupuestos dinámicos - ajustar límites sin depender del banco'
    ],
    ARRAY[
      '¿Cómo controlan el uso de tarjetas corporativas hoy?',
      '¿Qué tan fácil es emitir o bloquear una tarjeta?',
      '¿Han tenido casos de uso inapropiado de tarjetas?'
    ],
    '{"Ya tenemos tarjetas con el banco": "Mendel complementa: control + software que el banco no ofrece", "No queremos cambiar de banco": "Las tarjetas Mendel son complementarias, no reemplazan la relación bancaria", "Es un proveedor más que manejar": "Consolida múltiples tarjetas bancarias en una sola plataforma"}'::jsonb
  ),
  (mendel_id, 'Contabilidad',
    ARRAY['Gerente de Contabilidad', 'Contador General', 'Accounting Manager', 'Líder de Contabilidad'],
    'Champion - registro contable y deducibilidad',
    'Controller / CFO',
    ARRAY[
      'Facturas faltantes - empleados no entregan comprobantes = gasto no deducible',
      'Captura manual - horas ingresando datos al ERP transacción por transacción',
      'Errores de clasificación - centro de costo incorrecto, IVA mal calculado',
      'Perseguir empleados - ¿Ya me mandaste la factura? x 100 empleados',
      'Cierres estresantes - correr al final del mes para completar información'
    ],
    ARRAY[
      'Deducibilidad - maximizar facturas recuperadas y validadas',
      'Automatización - eliminar captura manual',
      'Precisión - clasificación correcta desde el origen',
      'Auditorías tranquilas - todo documentado y trazable'
    ],
    ARRAY[
      '¿Qué porcentaje de facturas logran recuperar hoy? (MX)',
      '¿Cuánto tiempo dedican a la captura manual de gastos?',
      '¿Es frecuente que lleguen a cierre sin comprobantes?'
    ],
    '{"Los empleados no van a usar la app": "App sencilla: toma foto, listo. Más fácil que el proceso actual", "Nuestro ERP es muy específico": "APIs abiertas + conectores para SAP, Oracle, NetSuite, etc.", "Ya tenemos nuestro proceso": "¿Cuántas horas dedica tu equipo a perseguir facturas?"}'::jsonb
  ),
  (mendel_id, 'FPA',
    ARRAY['FP&A Manager', 'Director de Planeación Financiera', 'Financial Analyst Sr.', 'Head of FP&A'],
    'Influenciador - presupuestos y forecasting',
    'CFO',
    ARRAY[
      'Datos llegan tarde - información de gastos solo al cierre, no sirve para forecast',
      'Múltiples fuentes - consolidar Excel + banco + ERP = horas de trabajo',
      'Presupuestos desactualizados - se fijan al inicio del año, imposible ajustar',
      'Sin drill-down - sabe que se gastó X, pero no puede ver el detalle rápido'
    ],
    ARRAY[
      'Datos en tiempo real - gastos actualizados diariamente',
      'Granularidad - drill-down por área, proyecto, centro de costo',
      'Presupuestos vivos - ajustar límites según necesidad del negocio',
      'Análisis predictivo - detectar tendencias y anomalías'
    ],
    ARRAY[
      '¿Qué tan actualizada está su información de gasto para forecast?',
      '¿De cuántas fuentes consolidan datos de gastos?',
      '¿Pueden ajustar presupuestos en tiempo real?'
    ],
    '{"Ya tenemos herramientas de BI": "Mendel alimenta tu BI con datos limpios y en tiempo real", "Solo cubre parte del gasto": "Cubre gastos operativos + viajes, que suelen ser puntos ciegos", "No es mi decisión": "Pero es tu dolor; podemos armar business case para CFO"}'::jsonb
  ),
  (mendel_id, 'FinanzasOperativas',
    ARRAY['Director de Finanzas Operativas', 'Gerente de Procesos Financieros', 'Finance Operations Manager'],
    'Champion - rendiciones y reembolsos',
    'CFO / Controller',
    ARRAY[
      'Rendiciones por correo/WhatsApp - información dispersa, sin trazabilidad',
      'Reembolsos tardíos - empleados molestos, pagan con dinero personal',
      'Aprobaciones manuales - el jefe tiene que aprobar por correo, se olvida',
      'Políticas que nadie sigue - existen en PDF pero no se aplican',
      'Fricción con otras áreas - Finanzas siempre retrasa mis gastos'
    ],
    ARRAY[
      'Digitalización - eliminar correos, WhatsApp, Excel',
      'Flujos automáticos - aprobaciones que fluyen sin intervención manual',
      'Experiencia del empleado - que el proceso sea fácil para todos',
      'Políticas que se cumplen - control automático, no solo documentos'
    ],
    ARRAY[
      '¿Cuánto tiempo tarda un reembolso hoy?',
      '¿Cómo manejan las aprobaciones de gastos?',
      '¿Reciben quejas de empleados por el proceso?'
    ],
    '{"Los empleados no van a adoptar": "App intuitiva + beneficio directo (reembolsos más rápidos)", "Nuestras políticas son complejas": "Políticas configurables por área, proyecto, monto, categoría", "Ya tenemos un proceso que funciona": "¿Cuántas quejas recibes por reembolsos? ¿Cuánto tiempo dedicas a esto?"}'::jsonb
  ),
  (mendel_id, 'TravelRRHH',
    ARRAY['Travel Manager', 'Gerente de Viajes Corporativos', 'Director de RR.HH.', 'HR Manager'],
    'Influenciador - viajes corporativos',
    'CFO / Director de RR.HH.',
    ARRAY[
      'Reservas dispersas - cada quien reserva por su lado: OTAs, agencias, tarjetas personales',
      'Políticas que no se cumplen - límite de hotel pero nadie lo respeta',
      'Falta de datos consolidados - no puede negociar mejores tarifas sin data histórica',
      'Experiencia fragmentada - empleados frustrados con proceso de viajes'
    ],
    ARRAY[
      'Centralización - una plataforma para todo: reservas, políticas, reportes',
      'Cumplimiento de políticas - que se apliquen automáticamente',
      'Experiencia del empleado - proceso fácil de reserva y rendición',
      'Datos para negociar - información de gasto consolidada'
    ],
    ARRAY[
      '¿Cómo aseguran que se cumplan las políticas de viaje?',
      '¿Tienen visibilidad consolidada del gasto de viajes?',
      '¿Cada quien reserva por su cuenta o hay un proceso?'
    ],
    '{"Ya tenemos agencia de viajes": "Mendel complementa: políticas + control + datos que la agencia no da", "Los empleados prefieren reservar solos": "Pueden reservar, pero con políticas automáticas y visibilidad", "Es decisión de Finanzas": "Tu sufres el problema; podemos ayudarte a armar el caso"}'::jsonb
  );

  -- ============================================
  -- COUNTRIES / VALUE PROPS
  -- ============================================
  INSERT INTO countries (client_id, code, name, specific_value_props, unique_features, pain_emphasis, compliance, metrics, scoring_weight) VALUES
  (mendel_id, 'MX', 'México',
    ARRAY[
      '30% más recupero de facturas via validación SAT con IA',
      '70% reducción de gastos no deducibles',
      'Recuperación automática de facturas SAT',
      'Validación CFDI automática'
    ],
    ARRAY[
      'Recupero automático de facturas SAT',
      'Validación SAT integrada',
      'Foto del ticket -> factura SAT automática'
    ],
    'deducibilidad fiscal y recupero de facturas',
    'SAT / CFDI',
    '{"invoice_recovery": "De 40-60% a 80-90% de facturas recuperadas", "non_deductibles": "Reducción del 70% en gastos no deducibles", "close_time": "Cierre mensual de 2-3 semanas a 3-5 días"}'::jsonb,
    5
  ),
  (mendel_id, 'AR', 'Argentina',
    ARRAY[
      'Control de gastos multi-moneda (pesos/USD)',
      'Visibilidad en contexto inflacionario',
      'Tarjetas emitidas por Banco CMF',
      'Integración con sistemas locales (Finnegans)'
    ],
    ARRAY[
      'Manejo multi-moneda ARS/USD',
      'Control en contexto de alta volatilidad'
    ],
    'control en contexto inflacionario y multi-moneda',
    'AFIP',
    NULL,
    3
  ),
  (mendel_id, 'CL', 'Chile',
    ARRAY[
      'Control de gastos multi-entidad',
      'Tarjetas VISA corporativas',
      'Cumplimiento fiscal local',
      'Políticas regionalizadas'
    ],
    NULL,
    'control multi-entidad y cumplimiento fiscal',
    'SII',
    NULL,
    3
  ),
  (mendel_id, 'CO', 'Colombia',
    ARRAY[
      'Control de gastos multi-entidad',
      'Tarjetas VISA corporativas',
      'Cumplimiento fiscal local',
      'Políticas personalizables'
    ],
    NULL,
    'control y cumplimiento fiscal',
    'DIAN',
    NULL,
    3
  ),
  (mendel_id, 'PE', 'Perú',
    ARRAY[
      'Control de gastos corporativos',
      'Tarjetas VISA corporativas',
      'Integración ERP',
      'Políticas personalizables'
    ],
    NULL,
    'control y visibilidad de gastos',
    'SUNAT',
    NULL,
    2
  );

  -- Add notes to non-Mexico countries
  UPDATE countries SET note = 'NO hay recupero automático de facturas tipo SAT'
  WHERE client_id = mendel_id AND code != 'MX';

  -- ============================================
  -- INDUSTRIES
  -- ============================================
  INSERT INTO industries (client_id, slug, name, tier, pains, reference_clients, reason, scoring_weight) VALUES
  (mendel_id, 'retail', 'Retail / E-commerce', 1,
    ARRAY['gastos distribuidos en múltiples tiendas/sucursales', 'control de trade marketing y activaciones', 'viáticos de equipos de campo'],
    ARRAY['Mercado Libre', 'FEMSA'],
    'Field teams, trade marketing, multiple locations',
    5
  ),
  (mendel_id, 'logistica', 'Logística / Distribución', 1,
    ARRAY['gastos de conductores y rutas', 'combustible, peajes, viáticos', 'control por ruta o centro de distribución'],
    ARRAY['empresas de distribución'],
    'Drivers, route coordinators, fuel expenses',
    5
  ),
  (mendel_id, 'consumo', 'Consumo Masivo', 1,
    ARRAY['equipos de campo dispersos', 'activaciones y promociones', 'trade marketing'],
    ARRAY['FEMSA', 'Unilever'],
    'Field sales, promotions, activations',
    5
  ),
  (mendel_id, 'food', 'Food & Beverage', 1,
    ARRAY['múltiples ubicaciones', 'gastos operativos distribuidos', 'control por sucursal'],
    ARRAY['McDonalds'],
    'Distribution, activations, multiple outlets',
    5
  ),
  (mendel_id, 'tecnologia', 'Tecnología / SaaS', 2,
    ARRAY['suscripciones dispersas', 'equipos distribuidos', 'viajes a eventos y clientes'],
    ARRAY['Mercado Libre'],
    'Distributed teams, SaaS subscriptions, travel',
    3
  ),
  (mendel_id, 'servicios', 'Servicios Profesionales', 2,
    ARRAY['gastos por proyecto/cliente', 'viajes, comidas, representación', 'facturación al cliente basada en gasto real'],
    ARRAY['Adecco'],
    'Billable travel, client expenses',
    3
  ),
  (mendel_id, 'manufactura', 'Manufactura / Energía', 2,
    ARRAY['gastos en plantas y operaciones de campo', 'mantenimiento y repuestos', 'control por línea de negocio'],
    ARRAY['Grupo Omer'],
    'Field operations, maintenance, multiple plants',
    3
  );

  -- ============================================
  -- GLOBAL CONFIG
  -- ============================================
  INSERT INTO global_config (client_id, core_value_props, differentiators, reference_clients, features, company_description) VALUES
  (mendel_id,
    ARRAY[
      'Visibilidad real-time de gastos vs sorpresas de fin de mes',
      'Control de tarjetas con reglas por persona/área/horario',
      'Enterprise-first (vs Clara/Jeeves que apuntan a SMBs)',
      'Integración ERP nativa con SAP, Oracle, NetSuite'
    ],
    '{
      "vs_clara": "Enfoque enterprise, compliance fiscal más profundo",
      "vs_jeeves": "Integración local, partnership con SAP",
      "vs_concur": "Tarjetas nativas + capa de compliance local",
      "vs_banks": "Software-first, control en tiempo real"
    }'::jsonb,
    ARRAY['Mercado Libre', 'FEMSA', 'McDonalds', 'Unilever', 'Adecco'],
    '{
      "cards": "Tarjetas corporativas VISA físicas y virtuales",
      "control": "Políticas y presupuestos por área/proyecto",
      "approvals": "Flujos de aprobación configurables",
      "erp": "Integración con SAP, Oracle, NetSuite, TOTVS",
      "reimbursements": "Reembolsos instantáneos en 24-72 hrs",
      "travel": "Mendel Viajes - reservas con IA"
    }'::jsonb,
    'Plataforma de gestión de gastos corporativos para empresas enterprise en Latinoamérica'
  );

  -- ============================================
  -- ICP CONFIG
  -- ============================================
  INSERT INTO icp_config (client_id, firmographics, qualifying_signals, scoring_criteria) VALUES
  (mendel_id,
    '{
      "size": {
        "minimum": 500,
        "sweet_spot": "1,000-5,000+",
        "note": "200-500 puede funcionar pero les puede parecer caro"
      },
      "geography": {
        "tier1": ["MX"],
        "tier2": ["AR", "CO", "CL", "PE"]
      },
      "structure": ["Multi-location", "Distributed teams", "Field operations"]
    }'::jsonb,
    '{
      "include": [
        "Alto volumen de gastos corporativos (viáticos, viajes, operaciones)",
        "Múltiples subsidiarias/ubicaciones delegando gasto a equipos de campo",
        "Alta exposición fiscal SAT/AFIP (impuestos altos, auditorías frecuentes)",
        "ERP corporativo (SAP, Oracle, NetSuite, TOTVS)",
        "Viajes de negocio frecuentes (equipos regionales, comerciales)"
      ],
      "exclude": [
        "<200 empleados (costo no justifica)",
        "Gobierno, ONGs, Bancos (complejidad de compliance)",
        "Sin cultura de formalización de gastos",
        "Contabilidad completamente tercerizada"
      ]
    }'::jsonb,
    '{
      "company_size": {
        "500-999": 2,
        "1000-2999": 3,
        "3000-4999": 4,
        "5000+": 5
      },
      "country": {
        "MX": 5,
        "AR": 3,
        "CO": 3,
        "CL": 3,
        "PE": 2
      },
      "industry_tier1": 5,
      "industry_tier2": 3,
      "has_erp": 3,
      "has_field_teams": 3,
      "growth_signal": 2,
      "funding_signal": 2
    }'::jsonb
  );

  -- ============================================
  -- EMAIL FRAMEWORK
  -- ============================================
  INSERT INTO email_framework (client_id, principles, structure, dont_do, templates) VALUES
  (mendel_id,
    '{
      "tone": "Conversacional + Directo - como si hablaras con un colega",
      "never_salesy": "No increíble oportunidad ni solución revolucionaria",
      "no_flattery": "No admiro tu trayectoria sin razón específica",
      "ask_dont_assume": "Preguntar, no afirmar que tienen X problema"
    }'::jsonb,
    '{
      "max_words": 100,
      "one_idea": "Una idea por email, no lista de features",
      "cta": "Baja fricción: Te hace sentido? > Agendamos 45 min?"
    }'::jsonb,
    ARRAY[
      'Empezar con Espero que estés bien',
      'Me encantaría presentarme...',
      'Listar 5+ features',
      'Asumir que tienen un problema específico',
      'Usar superlativos (la mejor, líder del mercado)',
      'Hablar de Mendel antes de hablar de ellos'
    ],
    '{
      "open_question": "Pregunta abierta - para primer contacto sin señal clara",
      "signal_trigger": "Basado en señal - cuando detectas algo específico",
      "case_study": "Caso de estudio - cuando tienes un caso relevante similar",
      "validation": "Pregunta de validación - para refinar targeting",
      "super_short": "Super corto - follow-up o reengagement"
    }'::jsonb
  );

END $$;
