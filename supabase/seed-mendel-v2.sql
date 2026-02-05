-- =============================================
-- Mendel GTM API - Seed V2
-- Datos adicionales de raw-context
-- =============================================

DO $$
DECLARE
  mendel_id UUID;
BEGIN
  -- Obtener ID de Mendel
  SELECT id INTO mendel_id FROM clients WHERE slug = 'mendel';

  -- =============================================
  -- COMPETITORS - Benchmark competitivo
  -- =============================================

  INSERT INTO competitors (client_id, name, type, target_segment, features, our_advantage, website, linkedin_url) VALUES

  -- Clara (competidor directo)
  (mendel_id, 'Clara', 'direct', 'SMBs y Scaleups',
   '{
     "saas_realtime": true,
     "mobile_app": true,
     "integrations": false,
     "invoice_recovery": false,
     "budgets": false,
     "expense_policies": "Solo límite de monto",
     "expense_registration": false,
     "dashboard_reporting": true,
     "multi_entity": true,
     "unlimited_cards": true,
     "supplier_payments": true,
     "tax_payments": true,
     "credit_line": "Pago semanal, LOC para PYMES"
   }'::jsonb,
   'Mendel tiene enfoque enterprise con compliance fiscal profundo (SAT), alianza SAP Concur, y casos con grandes corporativos (Mercado Libre, FEMSA). Clara prioriza facilidad de emisión y flexibilidad de crédito para startups.',
   'https://www.clara.com.mx',
   'https://www.linkedin.com/company/claracc/'),

  -- Jeeves (competidor directo)
  (mendel_id, 'Jeeves', 'direct', 'Startups globales',
   '{
     "saas_realtime": true,
     "mobile_app": true,
     "integrations": false,
     "invoice_recovery": false,
     "budgets": false,
     "expense_policies": "Solo límite de monto",
     "expense_registration": false,
     "dashboard_reporting": true,
     "multi_entity": false,
     "unlimited_cards": true,
     "supplier_payments": true,
     "tax_payments": true,
     "credit_line": "Pago semanal, LOC para PYMES",
     "multicurrency": true
   }'::jsonb,
   'Mendel apuesta por integración contable local y cumplimiento fiscal (SAT, ERPs locales, alianza SAP Concur). Jeeves enfatiza multicurrency y disponibilidad global, pero sin profundidad fiscal local.',
   'https://www.tryjeeves.com',
   'https://www.linkedin.com/company/tryjeeves/'),

  -- SAP Concur (competidor/partner)
  (mendel_id, 'SAP Concur', 'indirect', 'Enterprise global',
   '{
     "saas_realtime": false,
     "mobile_app": true,
     "integrations": true,
     "invoice_recovery": false,
     "budgets": true,
     "expense_policies": true,
     "expense_registration": true,
     "dashboard_reporting": true,
     "multi_entity": true,
     "unlimited_cards": false,
     "supplier_payments": false,
     "tax_payments": false,
     "credit_line": false
   }'::jsonb,
   'Mendel complementa y localiza Concur con validación de facturas SAT y cumplimiento fiscal mexicano. Para empresas que ya usan Concur, Mendel es la capa de compliance fiscal y tarjetas locales.',
   'https://www.concur.com.mx',
   'https://www.linkedin.com/company/sap-concur/'),

  -- Corporate AMEX
  (mendel_id, 'AMEX Corporate', 'indirect', 'Enterprise',
   '{
     "saas_realtime": false,
     "mobile_app": false,
     "integrations": false,
     "invoice_recovery": false,
     "budgets": false,
     "expense_policies": true,
     "expense_registration": false,
     "dashboard_reporting": false,
     "multi_entity": false,
     "unlimited_cards": false,
     "supplier_payments": true,
     "tax_payments": false,
     "credit_line": true
   }'::jsonb,
   'AMEX ofrece tarjeta y extracto pero no resuelve recuperación de facturas, políticas de gasto ni flujos de aprobación. Mendel es plataforma completa de gestión.',
   'https://www.americanexpress.com',
   'https://www.linkedin.com/company/american-express-global-business-travel/'),

  -- Banca Tradicional
  (mendel_id, 'Banca Tradicional (BBVA, Citi, Santander)', 'indirect', 'Todos los segmentos',
   '{
     "saas_realtime": false,
     "mobile_app": false,
     "integrations": false,
     "invoice_recovery": false,
     "budgets": false,
     "expense_policies": false,
     "expense_registration": false,
     "dashboard_reporting": false,
     "multi_entity": false,
     "unlimited_cards": false,
     "supplier_payments": false,
     "tax_payments": false,
     "credit_line": true
   }'::jsonb,
   'Los bancos proveen crédito y tarjetas pero sin profundidad de integración fiscal ni flujos de aprobación. Mendel es software-first con control real-time.',
   NULL,
   NULL),

  -- Edenred
  (mendel_id, 'Edenred Empresarial', 'indirect', 'Enterprise',
   '{
     "saas_realtime": false,
     "mobile_app": "Solo administrativo",
     "integrations": true,
     "invoice_recovery": true,
     "budgets": false,
     "expense_policies": true,
     "expense_registration": true,
     "dashboard_reporting": false,
     "multi_entity": false,
     "unlimited_cards": false,
     "supplier_payments": false,
     "tax_payments": false,
     "credit_line": false
   }'::jsonb,
   'Mendel ofrece plataforma más completa con tarjetas VISA globales, gestión multi-empresa, y mejor UX móvil.',
   'https://www.edenred.mx',
   'https://www.linkedin.com/company/edenred/'),

  -- Tribal Credit
  (mendel_id, 'Tribal Credit', 'indirect', 'SMBs LATAM',
   '{
     "saas_realtime": true,
     "mobile_app": true,
     "integrations": true,
     "invoice_recovery": true,
     "budgets": true,
     "expense_policies": true,
     "expense_registration": false,
     "dashboard_reporting": true,
     "multi_entity": false,
     "unlimited_cards": true,
     "supplier_payments": false,
     "tax_payments": false,
     "credit_line": true
   }'::jsonb,
   'Tribal enfocado en crédito para SMBs. Mendel es enterprise-first con mayor profundidad en compliance fiscal y casos con grandes corporativos.',
   'https://www.tribal.credit',
   'https://www.linkedin.com/company/tribalcredit/'),

  -- Ramp (aspiracional)
  (mendel_id, 'Ramp', 'indirect', 'Mid-market US',
   '{
     "saas_realtime": true,
     "mobile_app": true,
     "integrations": true,
     "invoice_recovery": false,
     "budgets": true,
     "expense_policies": true,
     "expense_registration": true,
     "dashboard_reporting": true,
     "multi_entity": true,
     "unlimited_cards": true,
     "supplier_payments": true,
     "tax_payments": false,
     "credit_line": true
   }'::jsonb,
   'Ramp no opera en LATAM. Mendel tiene localización profunda para normativas fiscales y operación en Latinoamérica.',
   'https://www.ramp.com',
   'https://www.linkedin.com/company/ramp-business/'),

  -- Brex (aspiracional)
  (mendel_id, 'Brex', 'indirect', 'Enterprise US',
   '{
     "saas_realtime": true,
     "mobile_app": true,
     "integrations": true,
     "invoice_recovery": false,
     "budgets": true,
     "expense_policies": true,
     "expense_registration": true,
     "dashboard_reporting": true,
     "multi_entity": true,
     "unlimited_cards": true,
     "supplier_payments": true,
     "tax_payments": true,
     "credit_line": true
   }'::jsonb,
   'Brex no opera en México/LATAM. Mendel tiene compliance fiscal local (SAT), multi-moneda regional, y casos enterprise en la región.',
   'https://www.brex.com',
   'https://www.linkedin.com/company/brexhq/');

  -- =============================================
  -- OBJECTIONS - Objeciones y respuestas
  -- =============================================

  INSERT INTO objections (client_id, objection, category, response, evidence, persona_slugs) VALUES

  -- Objeción de costo
  (mendel_id,
   'Es más caro que seguir con Excel y tarjetas bancarias normales',
   'price',
   'El costo visible de la plataforma se compensa con ahorros por reducción de no deducibles (hasta 70%), menos fraude y ahorro de horas administrativas. El payback típico es menor a 9 meses.',
   'Casos reales donde se reporta incremento de 30% en recuperación de comprobantes y reducción del 70% en no deducibles.',
   NULL),

  -- Ya tienen otra solución
  (mendel_id,
   'Ya usamos otra plataforma de gastos (SAP Concur, solución bancaria, AMEX)',
   'competition',
   'Mendel puede complementar y localizar, especialmente para cumplimiento fiscal mexicano y tarjetas corporativas inteligentes. La alianza con SAP Concur valida este posicionamiento complementario.',
   'Anuncio de alianza estratégica SAP Concur + Mendel para manejo de gastos corporativos y cumplimiento fiscal en México.',
   NULL),

  -- Preocupación por datos
  (mendel_id,
   'Nos preocupa compartir datos financieros sensibles con una fintech',
   'trust',
   'Mendel opera con encriptación, estándares de seguridad SOC2/PCI-DSS, data centers en LATAM, y está respaldado por emisores de tarjetas como Visa. Compañías como Mercado Libre, FEMSA, Unilever y McDonald''s confían en la plataforma.',
   'Listado de clientes enterprise y su uso de Mendel como herramienta crítica de gestión de gastos.',
   NULL),

  -- Empresa joven
  (mendel_id,
   'No queremos depender de una startup joven para procesos tan críticos',
   'trust',
   'Aunque fundada en 2021, Mendel ya ha levantado rondas significativas (Series A y B de 35 MUSD), opera con >500 clientes enterprise, tiene ARR creciendo 2.5x y márgenes brutos >75%.',
   'Series B de 35 MUSD liderada por Base10 Partners; ~500 clientes enterprise.',
   NULL),

  -- Implementación compleja
  (mendel_id,
   'Implementar una nueva plataforma va a ser complejo, podemos romper el cierre de mes',
   'implementation',
   'Mendel está diseñado como capa que se integra al ERP/sistemas existentes, con conectores contables y experiencia en corporativos. Go-live típico en 6-8 semanas con equipo de onboarding dedicado. Para empresas >3,000 empleados, máximo 3 meses.',
   'Alianza con SAP Concur demuestra capacidad de integrarse a tech stacks complejos de T&E.',
   NULL),

  -- Ya funciona bien
  (mendel_id,
   'Ya tenemos tarjetas corporativas con nuestro banco y controlamos todo en Excel, nos funciona bien',
   'timing',
   'El esquema banco + Excel funciona hasta cierto nivel de complejidad. Cuando hay cientos o miles de transacciones mensuales, el costo oculto son horas hombre, errores y no deducibles. Mendel no reemplaza al banco, lo complementa con control en tiempo real, recuperación automática de facturas y conexión contable.',
   'Grandes corporativos como Mercado Libre ya validaron este enfoque con mejoras significativas en recuperación de facturas.',
   NULL),

  -- No es el momento
  (mendel_id,
   'No es el momento / Tenemos otras prioridades',
   'timing',
   'Entendemos. Vale la pena prepararse para el cierre fiscal con un business case ahora para el siguiente ciclo. La implementación puede iniciar post-cierre y estar lista para el próximo período.',
   NULL,
   NULL),

  -- Múltiples stakeholders
  (mendel_id,
   'Tenemos múltiples stakeholders y el ciclo de decisión es largo',
   'implementation',
   'Podemos hacer un POC de 30 días con un departamento piloto. Tenemos materiales específicos por stakeholder (CFO, Contralor, IT) y casos de éxito relevantes para cada uno.',
   NULL,
   NULL),

  -- No cambiar banco
  (mendel_id,
   'No queremos cambiar de banco ni agregar otro proveedor financiero',
   'implementation',
   'Mendel se integra con bancos y tarjetas existentes. Las tarjetas Mendel son un complemento, no un reemplazo. Muchos clientes mantienen sus tarjetas bancarias para ciertos gastos y usan Mendel para control granular.',
   NULL,
   NULL),

  -- Pain específico CFO
  (mendel_id,
   'Como CFO no tengo tiempo para ver demos de herramientas operativas',
   'timing',
   'Totalmente. Por eso ofrecemos una sesión ejecutiva de 20 minutos enfocada en el business case: cuánto están perdiendo en no deducibles, cuántas horas dedica el equipo a conciliación, y qué visibilidad estratégica ganarían. El Contralor puede evaluar el detalle operativo.',
   NULL,
   ARRAY['CFO']);

  -- =============================================
  -- CASE_STUDIES - Casos de éxito
  -- =============================================

  INSERT INTO case_studies (client_id, company_name, industry, company_size, buyer_persona, acquisition_channel, problem, before_state, main_pain, outcome, metrics, objections_faced, is_public) VALUES

  -- Mercado Libre
  (mendel_id,
   'Mercado Libre',
   'E-commerce / Tech',
   '10,000+',
   'CFO / Tesorería / Finanzas corporativas',
   'Partnership / Caso de éxito público',
   'Reducir no deducibles y mejorar recuperación de facturas en gastos corporativos recurrentes y servicios (telco, movilidad, etc.)',
   'Tarjetas corporativas + procesos internos manuales de recuperación de CFDI + Concur + Excel',
   'Alto volumen de gastos sin comprobante fiscal adecuado; no deducibles elevados; cierre de mes lento',
   'Incremento significativo en recuperación de facturas, mejor deducibilidad, visibilidad consolidada multi-país',
   '{"recovery_increase": "30%", "deductibility_improvement": "significativo", "month_close": "3 días"}'::jsonb,
   ARRAY['Dudas sobre si una fintech externa podría integrarse a procesos internos tan críticos y de gran escala', 'Costos de implementación'],
   true),

  -- FEMSA
  (mendel_id,
   'FEMSA',
   'Consumo Masivo / Bebidas',
   '300,000+',
   'Tesorería / Contabilidad',
   'Partner SAP',
   'Controlar gastos distribuidos en múltiples unidades de negocio, con alto volumen de viáticos y gastos de operación',
   'Mezcla de sistemas internos, bancos y herramientas manuales. Tarjetas compartidas.',
   'Falta de visibilidad consolidada, riesgo de fraude interno, uso ineficiente de presupuesto, gastos sin factura',
   'Control centralizado, reducción de fraude, mejor visibilidad por unidad de negocio',
   '{"fraud_reduction": "significativo", "visibility": "tiempo real"}'::jsonb,
   ARRAY['Preocupación por el esfuerzo de integración con el ERP', 'Impacto en el cierre de mes', 'Cambio de procesos'],
   true),

  -- Unilever
  (mendel_id,
   'Unilever',
   'Consumo Masivo',
   '10,000+',
   'CFO / Global/Regional Finance',
   'Enterprise outbound / Referidos VC',
   'Modernizar la gestión de gastos y alinear procesos regionales en Latam con estándares globales',
   'Sistemas heredados + soluciones de bancos internacionales',
   'Fragmentación de herramientas, poca estandarización regional',
   'Procesos estandarizados en la región, mejor compliance',
   '{}'::jsonb,
   ARRAY['Temor a añadir otra herramienta más al stack de finanzas', 'Dudas sobre soporte enterprise'],
   true),

  -- McDonald''s
  (mendel_id,
   'McDonald''s (Latam)',
   'Food Service / Retail',
   '10,000+',
   'Director de Finanzas Regional',
   'Outbound / Aliados estratégicos',
   'Gestionar gastos de múltiples restaurantes, equipos de campo y operaciones corporativas con mejor control y deducibilidad',
   'Tarjetas bancarias, procesos propios, herramientas dispares. Proveedores fragmentados.',
   'Complejidad para controlar gasto por unidad y asegurar comprobación fiscal correcta. Sin consolidación multi-país.',
   'Control consolidado por restaurante, mejor compliance fiscal, visibilidad regional',
   '{"deductibility": "90%+"}'::jsonb,
   ARRAY['Preocupación por la curva de aprendizaje', 'Adopción por cientos de usuarios en tiendas', 'Estandarización regional'],
   true),

  -- Adecco
  (mendel_id,
   'Adecco',
   'Servicios Profesionales / RRHH',
   '5,000+',
   'CFO / Controller',
   'Evento / Outbound',
   'Control de gastos por proyecto y cliente, facturación correcta de gastos a clientes',
   'Concur + AMEX + QuickBooks',
   'Pérdida de revenue por gastos no facturados a clientes, alta carga administrativa',
   'Mejor asignación de gastos por proyecto, facturación correcta, reducción de pérdidas',
   '{}'::jsonb,
   ARRAY['Ya tienen Concur', 'Costo de cambio'],
   true),

  -- Grupo Omer
  (mendel_id,
   'Grupo Omer',
   'Manufactura',
   '2,000+',
   'Contabilidad',
   'Referido',
   'Mejorar deducibilidad y digitalizar procesos manuales',
   'WhatsApp + procesos manuales + Excel',
   '65% de deducibilidad solamente, mucho proceso manual',
   'Incremento significativo en deducibilidad, procesos digitalizados',
   '{"deductibility_before": "65%", "deductibility_after": "90%+"}'::jsonb,
   ARRAY['Resistencia al cambio', 'Preocupación por integración'],
   true),

  -- Intertek
  (mendel_id,
   'Intertek',
   'Desarrollo de comercio internacional',
   '10,000+',
   'CFO',
   'Inbound (Ads)',
   'Eliminar procesos manuales, tarjeta corporativa solo para directivos, varias personas haciendo recupero de facturas',
   'Manualmente, Excel, correos electrónicos, carga manual directo al ERP',
   'Tiempo perdido, errores frecuentes, fuga de dinero difícil de trackear',
   'Automatización de procesos, tarjetas para más colaboradores, mejor tracking',
   '{}'::jsonb,
   NULL,
   true);

  -- =============================================
  -- SIGNALS - Señales de oportunidad
  -- =============================================

  INSERT INTO signals (client_id, category, signal_name, description, why_relevant, how_to_detect, priority) VALUES

  -- Señales fiscales
  (mendel_id, 'fiscal', 'Problemas de deducibilidad SAT',
   'Empresas que mencionan problemas para recuperar CFDIs o se quejan por alto nivel de no deducibles',
   'Dolor directo que Mendel resuelve con recuperación automática de facturas y validación SAT',
   'Notas en prensa, webinars de fiscalistas, menciones de auditorías SAT, LinkedIn posts de equipos de finanzas',
   10),

  (mendel_id, 'fiscal', 'Auditoría financiera próxima',
   'Empresa que tiene auditoría fiscal o financiera en los próximos meses',
   'Urgencia por tener mejor compliance y documentación de gastos',
   'Menciones en earnings calls, noticias de la empresa, Q1/cierre fiscal',
   9),

  (mendel_id, 'fiscal', 'Declaraciones sobre disciplina financiera',
   'CFOs que hablan públicamente sobre necesidad de transparencia en el gasto o disciplina financiera',
   'Indica prioridad estratégica en control de gastos',
   'LinkedIn posts, entrevistas en medios, presentaciones en eventos',
   8),

  -- Señales de crecimiento
  (mendel_id, 'growth', 'Expansión geográfica en LATAM',
   'Corporativos mexicanos o argentinos expandiéndose a nuevos países de Latam',
   'Necesidad de estandarizar gestión de gastos en múltiples jurisdicciones fiscales',
   'Noticias de expansión, aperturas de oficinas, contrataciones en nuevos países',
   9),

  (mendel_id, 'growth', 'Ronda de financiamiento reciente',
   'Empresa que acaba de levantar capital (Series B+)',
   'Startups que pasan de decenas a cientos de colaboradores necesitan formalizar procesos',
   'Crunchbase, noticias de funding, TechCrunch, Contxto',
   8),

  (mendel_id, 'growth', 'Crecimiento acelerado de headcount',
   'Empresa contratando agresivamente (+20% headcount en 6 meses)',
   'Más empleados = más gastos = más complejidad = necesitan mejor control',
   'LinkedIn jobs, noticias de contratación, crecimiento en LinkedIn company page',
   8),

  (mendel_id, 'growth', 'Nuevo CFO contratado',
   'Empresa que acaba de contratar nuevo CFO o Director de Finanzas',
   'CFOs nuevos buscan implementar mejoras y dejar su marca, están abiertos a nuevas herramientas',
   'LinkedIn cambios de trabajo, noticias de nombramientos',
   10),

  -- Señales de digitalización
  (mendel_id, 'digital', 'Migración a ERP moderno',
   'Adopción de ERPs modernos o migraciones a la nube (SAP S/4HANA, Oracle NetSuite)',
   'Integración de gastos es prioridad en proyectos de ERP, buen momento para Mendel',
   'Noticias de implementación, partners de SAP/Oracle, menciones en LinkedIn',
   9),

  (mendel_id, 'digital', 'Alianzas con herramientas T&E o HR',
   'Empresa que anuncia alianza o implementación de Concur, Workday, etc.',
   'Buen encaje para Mendel como capa complementaria de compliance fiscal',
   'Comunicados de prensa, LinkedIn de proveedores',
   7),

  (mendel_id, 'digital', 'Búsquedas de alternativas',
   'Señales de búsqueda activa: "SAP Concur alternativa LATAM", "mejor que Clara", etc.',
   'Intent data directo - están evaluando opciones',
   'Google Ads, intent data providers, búsquedas en G2/Capterra',
   10),

  -- Señales de fricción interna
  (mendel_id, 'friction', 'Quejas de empleados sobre reembolsos',
   'Quejas en Glassdoor/LinkedIn sobre reembolsos tardíos o procesos de viáticos engorrosos',
   'Dolor interno visible que genera presión para cambiar',
   'Reviews en Glassdoor, posts en LinkedIn de empleados',
   7),

  (mendel_id, 'friction', 'Contratación de Finance Transformation',
   'Empresas que contratan Gerente de Finanzas Digitales, Finance Transformation Lead',
   'Indica disposición a renovar procesos y presupuesto asignado para cambios',
   'LinkedIn jobs con títulos de transformación digital en finanzas',
   9),

  (mendel_id, 'friction', 'Muchas áreas con gastos distribuidos',
   'Empresas con múltiples sucursales, tiendas, equipos de campo (ventas, trade marketing)',
   'Alta complejidad = mayor valor de Mendel',
   'Estructura organizacional visible, múltiples ubicaciones en LinkedIn',
   8),

  -- Señales de viajes
  (mendel_id, 'travel', 'Alto presupuesto de viajes corporativos',
   'Empresas con operaciones regionales que reportan altos presupuestos de T&E',
   'Candidatos para Mendel Viajes además de Expenses',
   'Reportes anuales, menciones de gastos de viaje, alianzas con aerolíneas/hoteles',
   7),

  (mendel_id, 'travel', 'Contratación de Travel Manager',
   'Empresa creando o contratando para rol de Travel Manager',
   'Indica que viajes es prioridad y hay budget para soluciones',
   'LinkedIn jobs, estructura organizacional',
   8);

END $$;
