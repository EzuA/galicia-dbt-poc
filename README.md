# Demo de dbt - E-commerce Analytics con Postgres, MinIO y Spark

Este proyecto es una demostración completa de dbt (data build tool), mostrando las capacidades principales de la herramienta con datos de e-commerce usando la **estructura recomendada por dbt** (staging, intermediate, marts) con modelos dimensionales y de hechos.

## 🎯 Objetivos del Demo

- **Estructura dbt**: Implementación de staging, intermediate y marts
- **Macros**: Demostrar la reutilización de código SQL
- **Materializaciones**: Mostrar diferentes tipos (view, table, incremental, snapshot)
- **Tests**: Validación de calidad de datos
- **Poetry**: Gestión de dependencias Python moderna
- **Documentación**: Schema y documentación de modelos

## 📊 Datos del Proyecto

El proyecto simula un e-commerce con las siguientes entidades:
- **Usuarios**: Información de clientes
- **Productos**: Catálogo de productos
- **Órdenes**: Transacciones de compra
- **Items de Órdenes**: Detalles de cada compra

## 🏗️ Estructura dbt

### **Staging Layer** (Etapa de Preparación)
- Limpieza básica y estandarización de datos
- Campos calculados y validaciones
- Materialización: `view`

### **Intermediate Layer** (Etapa Intermedia)
- Agregaciones y métricas por entidad
- Preparación para modelos de marts
- Materialización: `table`

### **Marts Layer** (Etapa de Consumo)
- **Dimensiones (dim)**: Entidades de negocio con métricas
- **Hechos (fact)**: Eventos y transacciones
- Materialización: `table` e `incremental`

## 🚀 Inicio Rápido

### Levantar todos los servicios
```bash
docker compose up -d --build
```

Servicios disponibles:
- **PostgreSQL** (puerto 5432): Base de datos con datos precargados vía `init.sql`
- **Adminer** (puerto 8080): Interfaz web para PostgreSQL
- **MinIO** (puerto 9000/9001): Almacenamiento S3-compatible
- **dbt**: Contenedor con dbt-core, dbt-postgres y dbt-spark

### Ejecutar en PostgreSQL (perfil `ecommerce_postgres`)
```bash
# Pipeline completo (sin seeds, usa init.sql)
make full-postgres

# O manual
docker compose exec dbt bash -lc "dbt run --profile ecommerce_postgres"
docker compose exec dbt bash -lc "dbt test --profile ecommerce_postgres"
```

### Ejecutar con Spark (perfil `ecommerce_spark`)
```bash
# Pipeline completo (con seeds)
make full-spark

# O manual
docker compose exec dbt bash -lc "dbt seed --profile ecommerce_spark"
docker compose exec dbt bash -lc "dbt run --profile ecommerce_spark"
docker compose exec dbt bash -lc "dbt test --profile ecommerce_spark"
```

## 🛠️ Comandos Make Útiles

```bash
make help              # Ver todos los comandos disponibles
make setup-services    # Levantar Docker Compose
make clean             # Limpiar y detener servicios

# PostgreSQL
make run-postgres      # Ejecutar en PostgreSQL
make full-postgres     # Pipeline completo en PostgreSQL

# Spark
make run-spark         # Ejecutar en Spark
make full-spark        # Pipeline completo en Spark
```

## 📚 Documentación de dbt (make docs)

- **Generar y servir docs**: usa `make docs` para construir la documentación (`dbt docs generate`) y servirla (`dbt docs serve`).
- **Acceso web**: disponible en http://localhost:8000
- **Qué incluye**: modelos, fuentes, tests, snapshots, y el lineage graph interactivo.
- **Perfil usado**: utiliza el perfil configurado en `dbt_project.yml` (por defecto: `ecommerce_postgres`).
- **Regenerar**: vuelve a correr `make docs` luego de cambios en modelos/macros/tests.

Comando equivalente manual:

```bash
docker compose exec dbt bash -lc "dbt docs generate --profiles-dir . && dbt docs serve --port 8000 --host 0.0.0.0"
```

Forzar un perfil específico (ej. Spark):

```bash
docker compose exec dbt bash -lc "dbt docs generate --profiles-dir . --profile ecommerce_spark && dbt docs serve --port 8000 --host 0.0.0.0"
```

Artefactos generados:
- `target/manifest.json` y `target/catalog.json` se actualizan al generar docs.
- El servidor lee estos artefactos para mostrar la documentación.

## 🐍 Modelos Python en dbt (guía y limitaciones)

- dbt soporta modelos Python en algunos adapters: DuckDB, Databricks/Spark (con métodos soportados), BigQuery, Snowflake.
- En este demo usamos `dbt-spark` con `method: session` (PySpark local). Esta modalidad **no soporta** ejecutar Python models en nuestra configuración, por eso no incluimos un caso listo-para-usar para mantener todo simple y reproducible.
- Aun así, así es como se usaría un modelo Python típico:

Ejemplo mínimo (archivo en `models/.../my_python_model.py`):

```python
def model(dbt, session):
		dbt.config(materialized="table")

		# pandas (DuckDB) o Spark DataFrame (Spark/Databricks), según adapter
		df = dbt.ref("stg_users")

		try:
				import pandas as pd
				out = df.copy()
				out["full_name_upper"] = out["full_name"].str.upper()
				return out
		except Exception:
				from pyspark.sql import functions as F
				return df.withColumn("full_name_upper", F.upper(F.col("full_name")))
```

Declaración en `schema.yml` (opcional):

```yaml
	- name: my_python_model
		description: "Ejemplo de modelo Python"
		columns:
			- name: full_name_upper
				description: "Nombre en mayúsculas"
```

Cómo ejecutarlo por adapter (ejemplos):

```bash
# DuckDB (recomendado para demos locales de Python models)
docker compose exec dbt bash -lc "dbt run --profiles-dir . --profile ecommerce_duckdb --select my_python_model"

# Databricks/Spark (requiere configuración compatible del adapter)
docker compose exec dbt bash -lc "dbt run --profiles-dir . --profile ecommerce_spark --select my_python_model"
```

Nota importante:
- Nuestra configuración actual de Spark usa `method: session` y no proporciona un modo compatible para ejecutar Python models sin una plataforma como Databricks. Por eso no añadimos un modelo real al repo.


## 🔄 Compatibilidad Dual PostgreSQL/Spark

Este proyecto usa **macros de compatibilidad cruzada** que permiten ejecutar los mismos modelos en ambas bases de datos:

### Macros de Compatibilidad (`macros/cross_db_utils.sql`)
- `cast_as_double()`: Tipado numérico (DOUBLE PRECISION en PG, DOUBLE en Spark)
- `cast_as_string()`: Conversión a texto (VARCHAR en PG, STRING en Spark)
- `datediff_days()`: Diferencia de días (compatible con ambas)
- `year_from_date()`: Extracción de año
- `current_date_func()`: Fecha actual
- `round_numeric()`: Redondeo seguro de NUMERIC
- `lpad_string()`: Padding de strings

### Validaciones Específicas
- `validate_email.sql`: Regex condicional (RLIKE en Spark, ~ en PG)
- `calculate_growth_rate.sql`: Cálculos numéricos seguros

Todos los modelos utilizan estas macros, permitiendo que el código se ejecute correctamente en ambas plataformas sin cambios.

## ✅ Tests en dbt

- **Tipos de tests**: Este proyecto incluye tests de esquema (unique/not_null), tests custom mediante macros y unit tests de dbt.
- **Ubicación**:
	- Unit tests: [dbt/tests/unit/stg_orders.yml](dbt/tests/unit/stg_orders.yml) y [dbt/tests/unit/stg_users.yml](dbt/tests/unit/stg_users.yml)
	- Macros de tests custom:
		- [dbt/macros/test_allowed_values_list.sql](dbt/macros/test_allowed_values_list.sql)
		- [dbt/macros/test_value_in_range.sql](dbt/macros/test_value_in_range.sql)
		- [dbt/macros/test_column_match_pattern.sql](dbt/macros/test_column_match_pattern.sql)
		- [dbt/macros/test_column_length_between.sql](dbt/macros/test_column_length_between.sql)
	- Declaración en schema: [dbt/models/schema.yml](dbt/models/schema.yml)

## 🧰 Ejemplo de dbt_utils

Modelo práctico que demuestra dos macros útiles de dbt_utils:

**Modelo**: [models/intermediate/int_users_with_sk.sql](models/intermediate/int_users_with_sk.sql)

**Macros utilizadas**:
- `dbt_utils.surrogate_key(['user_id', 'email'])`: Genera un hash único a partir de múltiples columnas (ideal para Data Vault, SCD o claves compuestas).
- `dbt_utils.star(from=ref('stg_users'))`: Selecciona automáticamente todas las columnas del modelo referenciado. Ventaja: si se agregan/quitan columnas, el modelo se actualiza automáticamente sin necesidad de editar SQL manualmente.

**Cómo probarlo**:

```bash
# PostgreSQL
docker compose exec dbt bash -lc "dbt run --profiles-dir . --profile ecommerce_postgres --select int_users_with_sk"

# Spark
docker compose exec dbt bash -lc "dbt run --profiles-dir . --profile ecommerce_spark --select int_users_with_sk"
```

**Resultado**: tabla con `user_sk` (clave hash) + todas las columnas de `stg_users`.

### Cómo ejecutar

PostgreSQL (perfil `ecommerce_postgres`):

```bash
docker compose exec dbt bash -lc "dbt test --profiles-dir . --profile ecommerce_postgres"
```

Spark (perfil `ecommerce_spark`):

```bash
docker compose exec dbt bash -lc "dbt test --profiles-dir . --profile ecommerce_spark"
```

Ejecutar tests de un modelo específico (incluye unit + data tests):

```bash
docker compose exec dbt bash -lc "dbt test --profiles-dir . --profile ecommerce_postgres --select stg_orders"
```

### Unit tests: formato y ejemplo

- Los unit tests viven en archivos YAML dentro de `dbt/tests/unit/`.
- Estructura: definen `model`, `given` (inputs) y `expect` (salida esperada).
- Importante: los `given` deben usar `ref('...')` o `source('...')`.

Ejemplo sencillo (extraído de [dbt/tests/unit/stg_orders.yml](dbt/tests/unit/stg_orders.yml)):

```yaml
unit_tests:
	- name: test_status_spanish_completed
		model: stg_orders
		given:
			- input: ref('orders')
				rows:
					- {order_id: 1, user_id: 1, order_date: "2023-01-01", status: "completed", total_amount: 100}
		expect:
			rows:
				- {order_id: 1, status: "completed", status_spanish: "Completada"}
```

### Tests custom (macros) y uso

- Los tests custom están implementados como macros y se aplican en `schema.yml` bajo `tests:` de cada columna.
- Ejemplos ya aplicados:
	- `allowed_values_list` en `stg_orders.status_spanish` y `stg_orders.order_size`.
	- `value_in_range` en `stg_orders.total_amount` y `dim_users.total_spent`.
	- `column_match_pattern` en `stg_users.email`.
	- `column_length_between` en `stg_users.full_name`.

Snippet de uso en [dbt/models/schema.yml](dbt/models/schema.yml):

```yaml
	- name: stg_orders
		columns:
			- name: status_spanish
				tests:
					- allowed_values_list:
							values: ['Completada', 'Pendiente', 'Enviada', 'Cancelada', 'Desconocida']
			- name: order_size
				tests:
					- allowed_values_list:
							values: ['Pequeña', 'Mediana', 'Grande']
			- name: total_amount
				tests:
					- value_in_range:
							min_value: 0
							max_value: 100000
					# Ejemplo con dbt_expectations
					- dbt_expectations.expect_column_values_to_be_between:
							min_value: 0
							max_value: 100000
							strictly: false
```

### dbt_expectations

- El paquete `metaplane/dbt_expectations` está incluido vía `packages.yml`.
- Permite declarar tests expresivos similares a Great Expectations.
- Ejemplo aplicado en `stg_orders.total_amount` arriba: `expect_column_values_to_be_between`.
- Más comunes: `expect_column_values_to_not_be_null`, `expect_column_values_to_be_in_set`, `expect_column_proportion_of_unique_values_to_be_between`.


### Troubleshooting

- Error de parsing en unit tests: asegúrate de usar `ref('seed')` o `source(...)` en `given.input`.
- Selección de recursos: usa `--select stg_orders` para ejecutar tanto unit como data tests del modelo.
- Perfiles: si cambias de motor, ajusta `--profile ecommerce_spark`.
