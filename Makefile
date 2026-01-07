# Makefile para el proyecto dbt demo

# Variables
PROFILE_POSTGRES := ecommerce_postgres
PROFILE_SPARK := ecommerce_spark
DBT_CMD := docker compose exec dbt bash -lc

.PHONY: help install-poetry setup-services run test seed docs clean

help: ## Mostrar ayuda
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install-poetry: ## Instalar dependencias con Poetry
	poetry install

setup-services: ## Levantar servicios con Docker (Postgres, MinIO, Spark, dbt)
	docker compose up -d --build
	@echo "Esperando que los servicios estén listos..."
	@sleep 15

# Funciones genéricas reutilizables
define dbt-run
	$(DBT_CMD) "dbt run --profiles-dir . --profile $(1)"
endef

define dbt-test
	$(DBT_CMD) "dbt test --profiles-dir . --profile $(1)"
endef

define dbt-seed
	$(DBT_CMD) "dbt seed --profiles-dir . --profile $(1)"
endef

# Comandos por defecto (usan perfil configurado en dbt_project.yml)
run: ## Ejecutar dbt run en contenedor
	$(DBT_CMD) "dbt run --profiles-dir ."

test: ## Ejecutar dbt test en contenedor
	$(DBT_CMD) "dbt test --profiles-dir ."

seed: ## Cargar seeds en contenedor
	$(DBT_CMD) "dbt seed --profiles-dir ."

docs: ## Generar y servir documentación en contenedor (accesible en http://localhost:8000)
	$(DBT_CMD) "dbt docs generate --profiles-dir . && dbt docs serve --port 8000 --host 0.0.0.0"

full-run: setup-services seed run test ## Ejecutar pipeline completo (perfil por defecto)

# Comandos específicos para Postgres
run-postgres: ## Ejecutar dbt run con perfil Postgres
	$(call dbt-run,$(PROFILE_POSTGRES))

test-postgres: ## Ejecutar dbt test con perfil Postgres
	$(call dbt-test,$(PROFILE_POSTGRES))

full-postgres: setup-services ## Pipeline completo en Postgres (sin seeds, usa init.sql)
	@echo "Esperando PostgreSQL..."
	@sleep 5
	$(call dbt-run,$(PROFILE_POSTGRES))
	$(call dbt-test,$(PROFILE_POSTGRES))

# Comandos específicos para Spark
run-spark: ## Ejecutar dbt run con perfil Spark
	$(call dbt-run,$(PROFILE_SPARK))

test-spark: ## Ejecutar dbt test con perfil Spark
	$(call dbt-test,$(PROFILE_SPARK))

seed-spark: ## Cargar seeds con perfil Spark
	$(call dbt-seed,$(PROFILE_SPARK))

full-spark: setup-services seed-spark run-spark test-spark ## Pipeline completo en Spark (con seeds)

clean: ## Limpiar archivos temporales y servicios
	$(DBT_CMD) "dbt clean" || true
	docker compose down -v

dev-setup: install-poetry setup-services ## Configurar entorno de desarrollo
