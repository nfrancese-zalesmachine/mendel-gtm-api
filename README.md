# Mendel GTM API

API para generar contenido GTM personalizado usando el contexto de Mendel. Diseñada para integrarse con Clay.com.

## Endpoints

### `GET /`
Health check. Devuelve status y lista de endpoints disponibles.

### `POST /api/generate-email`
Genera cold emails personalizados por persona, país e industria.

### `POST /api/research-brief`
Genera research briefs de cuentas para el equipo de ventas.

### `POST /api/score-lead`
Puntúa y califica leads según el ICP de Mendel.

---

## Setup Local

```bash
# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env
# Editar .env y agregar tu ANTHROPIC_API_KEY

# Iniciar servidor
npm start

# O en modo desarrollo (con auto-reload)
npm run dev
```

---

## Deploy en Railway

1. Crea cuenta en [railway.app](https://railway.app)
2. Conecta tu repositorio de GitHub
3. Agrega la variable de entorno `ANTHROPIC_API_KEY`
4. Railway detecta automáticamente Node.js y hace deploy

**URL resultante:** `https://tu-proyecto.up.railway.app`

---

## Integración con Clay

### Configuración en Clay

1. Crea una columna de tipo **"HTTP Request"**
2. Configura:
   - Method: `POST`
   - URL: `https://tu-api.up.railway.app/api/generate-email`
   - Headers: `Content-Type: application/json`
   - Body: (ver ejemplos abajo)

### Ejemplo: Generar Cold Email

**URL:** `POST /api/generate-email`

**Body (JSON):**
```json
{
  "persona": "{{contact.title}}",
  "country": "{{company.country_code}}",
  "industry": "{{company.industry}}",
  "company_name": "{{company.name}}",
  "contact_name": "{{contact.first_name}}",
  "company_size": "{{company.employee_count}}",
  "signal": "{{company.recent_news}}",
  "additional_context": "{{company.description}}"
}
```

**Campos requeridos:**
- `persona` - CFO, Controller, Tesorería, Contabilidad, FPA, FinanzasOperativas, TravelRRHH
- `country` - MX, AR, CL, CO, PE
- `company_name` - Nombre de la empresa
- `contact_name` - Nombre del contacto

**Campos opcionales:**
- `industry` - Retail, Logística, Tech, Manufactura, Servicios, Consumo, Food
- `company_size` - Número de empleados
- `signal` - Trigger detectado (string único)
- `signals` - Array de triggers detectados (ver abajo)
- `additional_context` - Info adicional del prospecto
- `custom_fields` - Objeto con campos personalizados (ver abajo)
- **Cualquier otro campo** - Se incluye automáticamente como contexto

---

### Múltiples Signals

Puedes enviar signals de dos formas:

**Opción 1: String único**
```json
{
  "signal": "Acaban de cerrar ronda Serie B"
}
```

**Opción 2: Array de signals**
```json
{
  "signals": [
    "Cerraron ronda Serie B de $50M",
    "Expandiendo a Colombia",
    "Contratando CFO"
  ]
}
```

**Opción 3: Ambos (se combinan)**
```json
{
  "signal": "{{company.funding_news}}",
  "signals": ["{{company.expansion_signal}}", "{{company.hiring_signal}}"]
}
```

---

### Campos Personalizados (custom_fields)

Para agregar cualquier dato extra de Clay:

```json
{
  "persona": "CFO",
  "country": "MX",
  "company_name": "Empresa ABC",
  "contact_name": "María",
  "custom_fields": {
    "linkedin_headline": "{{contact.linkedin_headline}}",
    "years_in_role": "{{contact.years_in_position}}",
    "company_growth": "{{company.growth_rate}}",
    "tech_stack": "{{company.technologies}}",
    "mutual_connections": "{{contact.shared_connections}}"
  }
}
```

**También puedes enviar campos extra directamente (sin `custom_fields`):**
```json
{
  "persona": "CFO",
  "country": "MX",
  "company_name": "Empresa ABC",
  "contact_name": "María",
  "linkedin_headline": "{{contact.linkedin_headline}}",
  "erp_detected": "{{company.erp}}",
  "pain_detected": "{{company.pain_signal}}"
}
```

Todos los campos no reconocidos se incluyen automáticamente como contexto para el email.

**Respuesta:**
```json
{
  "success": true,
  "email": "Hola María,\n\nPor el tamaño de Grupo Lala...",
  "metadata": {
    "persona": "CFO",
    "country": "MX",
    "industry": "Consumo",
    "company_name": "Grupo Lala"
  }
}
```

---

### Ejemplo: Research Brief

**URL:** `POST /api/research-brief`

**Body (JSON):**
```json
{
  "company_name": "{{company.name}}",
  "country": "{{company.country_code}}",
  "industry": "{{company.industry}}",
  "company_size": "{{company.employee_count}}",
  "company_description": "{{company.description}}",
  "recent_news": "{{company.news}}",
  "technologies": "{{company.technologies}}",
  "key_contacts": [
    {"name": "{{contact.name}}", "title": "{{contact.title}}"}
  ]
}
```

**Campos requeridos:**
- `company_name`
- `country`

**Respuesta:**
```json
{
  "success": true,
  "brief": "## Resumen Ejecutivo\n\nGrupo Lala es...",
  "metadata": {...}
}
```

---

### Ejemplo: Lead Scoring

**URL:** `POST /api/score-lead`

**Body (JSON):**
```json
{
  "company_name": "{{company.name}}",
  "country": "{{company.country_code}}",
  "industry": "{{company.industry}}",
  "company_size": "{{company.employee_count}}",
  "company_description": "{{company.description}}",
  "persona": "{{contact.title}}",
  "seniority": "{{contact.seniority}}",
  "technologies": "{{company.technologies}}",
  "signals": ["{{company.growth_signal}}", "{{company.funding_signal}}"]
}
```

**Campos requeridos:**
- `company_name`
- `country`
- `company_size`

**Respuesta:**
```json
{
  "success": true,
  "scoring": {
    "score": 85,
    "tier": "A",
    "fit_summary": "Excelente fit: empresa enterprise en México con alto volumen de gastos",
    "scoring_breakdown": {
      "company_size": 4,
      "country": 5,
      "industry": 5,
      "erp": 3,
      "field_teams": 3,
      "signals": 2
    },
    "strengths": ["Tamaño enterprise", "México = recupero SAT"],
    "weaknesses": ["Sin ERP detectado"],
    "recommended_action": "contact_now",
    "best_persona_to_contact": "CFO",
    "reasoning": "..."
  },
  "metadata": {...}
}
```

---

## Flujo Recomendado en Clay

```
1. Enrichment → Obtener datos de empresa/contacto
2. Score Lead → POST /api/score-lead → Filtrar Tier A/B
3. Research Brief → POST /api/research-brief → Contexto para SDR
4. Generate Email → POST /api/generate-email → Email personalizado
5. Outreach → Enviar via secuencia
```

---

## Value Props por País

| País | Value Props Principales |
|------|------------------------|
| 🇲🇽 México | Recupero SAT (+30%), reducción no deducibles (70%), validación CFDI |
| 🇦🇷 Argentina | Multi-moneda, control inflacionario, Banco CMF |
| 🇨🇱 Chile | Multi-entidad, cumplimiento SII |
| 🇨🇴 Colombia | Control, cumplimiento DIAN |
| 🇵🇪 Perú | Control, integración ERP |

**IMPORTANTE:** El recupero automático de facturas SAT es **exclusivo de México**. La API maneja esto automáticamente.

---

## Personas Soportadas

| Persona | Rol | Prioridad |
|---------|-----|-----------|
| CFO | Decisor final | Alta |
| Controller | Champion operativo | Alta |
| Tesorería | Control de tarjetas | Alta |
| Contabilidad | Deducibilidad (MX) | Media |
| FPA | Presupuestos | Media |
| FinanzasOperativas | Rendiciones | Media |
| TravelRRHH | Viajes (upsell) | Baja |

---

## Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| 400 Bad Request | Campos requeridos faltantes | Verificar body del request |
| 500 Internal Error | API key inválida o rate limit | Verificar ANTHROPIC_API_KEY |

---

## Soporte

Repositorio: [mendel-gtm-api](https://github.com/tu-usuario/mendel-gtm-api)
