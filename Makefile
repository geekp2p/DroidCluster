SHELL := /usr/bin/env bash

up:
	docker compose up -d


down:
	docker compose down


logs:
	docker compose logs -f --tail=200


logs-emulator:
	docker compose logs -f pf_emulator


logs-playflow:
	docker compose logs -f pf_droidflow


compose-config:
	docker compose config


pf-build:
	docker compose build pf_droidflow


sh-playflow:
	docker compose exec pf_droidflow bash


sh-emulator:
	docker compose exec pf_emulator bash


emu-open:
	@echo "noVNC: http://localhost:${NOVNC_PORT:-6080}"


pf-open:
	@echo "PlayFlow UI: http://localhost:${PLAYFLOW_PORT:-5000}"


health:
	@for c in pf_emulator pf_droidflow; do \
	  status=$$(docker inspect -f '{{.State.Health.Status}}' $$c 2>/dev/null || echo "missing"); \
	  echo "$$c: $$status"; \
	done


status:
	@$(MAKE) -s health
	@docker compose ps --format 'table {{.Name}}	{{.State}}	{{.Ports}}'

ps:
	docker compose ps

doctor:
	@$(MAKE) -s health
	@docker compose ps