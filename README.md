# Mendel GTM API v2.0

API multi-tenant para generar contenido GTM personalizado usando Supabase como base de datos. Diseñada para integrarse con Clay.com.

## Novedades v2.0

- **Multi-tenant**: Soporte para múltiples clientes con su propio contexto GTM
- **Supabase**: Base de datos en la nube para contexto dinámico
- **Fallback**: Si Supabase no está configurado, usa archivos JSON locales
- **Cache**: Cache de 5 minutos para optimizar performance

---

## Endpoints

### `GET /`
Health check. Devuelve status, versión, y lista de clientes disponibles.

### `GET /api/clients`
Lista todos los clientes disponibles en la base de datos.

### `POST /api/cache/clear`
Limpia el cache de contexto (usar después de actualizar datos en Supabase).

### `POST /api/generate-email`
Genera cold emails personalizados por persona, país e industria.

### `POST /api/research-brief`
Genera research briefs de cuentas para el equipo de ventas.

### `POST /api/score-lead`
Puntúa y califica leads según el ICP del cliente.

### `POST /api/generate`
Endpoint flexible - define tu propio output con el parámetro `task`.

---

## Setup Rápido (Sin Supabase)

Si solo quieres usar Mendel como cliente, puedes correr sin Supabase:

```bash
# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env
# Editar .env y agregar tu ANTHROPIC_API_KEY

# Iniciar servidor
npm start
```

La API funcionará con los archivos JSON en `/context/` como fallback.

---

## Setup con Supabase (Multi-tenant)

### 1. Crear proyecto en Supabase

1. Ve a [supabase.com](https://supabase.com) y crea un proyecto
2. Una vez creado, ve a **Settings > API**
3. Copia:
   - `Project URL` → `SUPABASE_URL`
   - `service_role` key → `SUPABASE_SERVICE_KEY` (¡no uses la anon key!)

### 2. Ejecutar migraciones

En el SQL Editor de Supabase, ejecuta en orden:

```sql
-- 1. Primero el schema
-- Contenido de supabase/schema.sql

-- 2. Luego los datos de Mendel
-- Contenido de supabase/seed-mendel.sql
```

### 3. Configurar variables de entorno

```bash
cp .env.example .env
```

Edita `.env`:
```
ANTHROPIC_API_KEY=sk-ant-xxxxx
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIs...
```

### 4. Iniciar servidor

```bash
npm install
npm start
```

---

## Deploy en Railway

1. Crea cuenta en [railway.app](https://railway.app)
2. Conecta tu repositorio de GitHub
3. Agrega las variables de entorno:
   - `ANTHROPIC_API_KEY`
   - `SUPABASE_URL`
   - `SUPABASE_SERVICE_KEY`
4. Railway hace deploy automáticamente

---

## Integración con Clay

### Nuevo parámetro: `client`

Todos los endpoints ahora aceptan un parámetro `client` para especificar qué cliente usar:

```json
{
  "client": "mendel",  // Opcional, default: "mendel"
  "persona": "CFO",
  "country": "MX",
  "company_name": "Empresa ABC",
  "contact_name": "María"
}
```

### Ejemplo: Generar Cold Email

**URL:** `POST /api/generate-email`

**Body (JSON):**
```json
{
  "client": "mendel",
  "persona": "/Title",
  "country": "/Country Code",
  "industry": "/Industry",
  "company_name": "/Company Name",
  "contact_name": "/First Name",
  "company_size": "/Employee Count",
  "signal": "/Recent News",
  "additional_context": "/Company Description"
}
```

**Campos requeridos:**
- `persona` - CFO, Controller, Tesorería, Contabilidad, FPA, FinanzasOperativas, TravelRRHH
- `country` - MX, AR, CL, CO, PE
- `company_name` - Nombre de la empresa
- `contact_name` - Nombre del contacto

**Campos opcionales:**
- `client` - Slug del cliente (default: "mendel")
- `industry` - Retail, Logística, Tech, Manufactura, Servicios, Consumo, Food
- `company_size` - Número de empleados
- `signal` / `signals` - Triggers detectados
- `additional_context` - Info adicional
- `custom_fields` - Campos personalizados

---

## Agregar un Nuevo Cliente

### 1. Insertar cliente en Supabase

```sql
INSERT INTO clients (slug, name, description) VALUES
('acme', 'ACME Corp', 'Software de gestión empresarial');
```

### 2. Agregar su contexto

```sql
-- Obtener el ID del cliente
DO $$
DECLARE
  acme_id UUID;
BEGIN
  SELECT id INTO acme_id FROM clients WHERE slug = 'acme';

  -- Insertar personas
  INSERT INTO personas (client_id, slug, titles, role, pains, cares_about, questions)
  VALUES (acme_id, 'CTO',
    ARRAY['CTO', 'VP Engineering'],
    'Decisor técnico',
    ARRAY['Deuda técnica', 'Escalabilidad'],
    ARRAY['Performance', 'Arquitectura'],
    ARRAY['¿Cómo manejan la deuda técnica?']
  );

  -- Insertar países
  INSERT INTO countries (client_id, code, name, specific_value_props)
  VALUES (acme_id, 'MX', 'México', ARRAY['Soporte local 24/7', 'Integraciones mexicanas']);

  -- Insertar global config
  INSERT INTO global_config (client_id, core_value_props, reference_clients)
  VALUES (acme_id,
    ARRAY['Automatización de procesos', 'Integraciones nativas'],
    ARRAY['Cliente 1', 'Cliente 2']
  );

  -- Insertar ICP
  INSERT INTO icp_config (client_id, firmographics, qualifying_signals, scoring_criteria)
  VALUES (acme_id,
    '{"size": {"minimum": 100, "sweet_spot": "500-2000"}}'::jsonb,
    '{"include": ["Usa SAP"], "exclude": ["<50 empleados"]}'::jsonb,
    '{"company_size": {"100-499": 2, "500+": 5}}'::jsonb
  );

  -- Insertar email framework
  INSERT INTO email_framework (client_id, principles, structure, dont_do)
  VALUES (acme_id,
    '{"tone": "Profesional pero cercano"}'::jsonb,
    '{"max_words": 80, "cta": "¿Tienes 15 min?"}'::jsonb,
    ARRAY['Ser muy técnico', 'Mencionar competidores']
  );
END $$;
```

### 3. Limpiar cache

```bash
curl -X POST https://tu-api.railway.app/api/cache/clear
```

### 4. Usar el nuevo cliente

```json
{
  "client": "acme",
  "persona": "CTO",
  "country": "MX",
  "company_name": "TechCorp",
  "contact_name": "Juan"
}
```

---

## Schema de Base de Datos

### Tablas principales

| Tabla | Descripción |
|-------|-------------|
| `clients` | Clientes/empresas usando la API |
| `personas` | Buyer personas por cliente |
| `countries` | Value props por país por cliente |
| `industries` | Snippets de industria por cliente |
| `global_config` | Config global por cliente |
| `icp_config` | Criterios de ICP por cliente |
| `email_framework` | Framework de email por cliente |

### Vista útil

```sql
SELECT * FROM client_full_context WHERE client_slug = 'mendel';
```

---

## Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| 400 Bad Request | Campos requeridos faltantes | Verificar body del request |
| 500 Internal Error | API key inválida o rate limit | Verificar ANTHROPIC_API_KEY |
| "Client not found" | Slug de cliente no existe | Verificar que el cliente esté en Supabase |
| "Using fallback" | Supabase no configurado | Agregar SUPABASE_URL y SUPABASE_SERVICE_KEY |

---

## Soporte

Repositorio: [mendel-gtm-api](https://github.com/nfrancese-zalesmachine/mendel-gtm-api)
