SHELL := /bin/bash

up:
	docker compose up -d --build

down:
	docker compose down

ps:
	docker compose ps

logs:
	docker compose logs -f --tail=200

logs-controller:
	docker compose logs -f controller

logs-emulator:
	docker compose logs -f emulator

logs-playflow:
	docker compose logs -f playflow

compose-config:
	docker compose config

pf-build:
	docker compose build playflow

pf-build-cache:
	docker buildx build playflow --tag playflow:test --load \
	        --cache-from type=local,src=.buildx-cache \
	        --cache-to type=local,dest=.buildx-cache,mode=max

sh-controller:
	docker compose exec controller bash

ctrl-shell: sh-controller


sh-playflow:
	docker compose exec playflow bash

pf-shell: sh-playflow

sh-emulator:
	docker compose exec emulator bash

emu-shell: sh-emulator	

emu-open:
	@echo "noVNC: http://localhost:6080"

pf-open:
	@echo "PlayFlow: http://localhost:5000"

metrics:
	@echo "cAdvisor: http://localhost:8080"

adb-devices:
	docker compose exec controller adb devices

adb-killstart:
	docker compose exec controller bash -lc 'adb kill-server || true; adb start-server'

emu-connect:
	docker compose exec controller adb connect droid_emulator:5555

pf-restart:
	docker compose restart playflow

clean-volumes:
	@read -p "Remove volumes adb_keys and playflow_data? [y/N] " ans; \
	if [[ $$ans =~ ^[Yy]$ ]]; then \
	project=$$(basename "$$PWD" | tr '[:upper:]' '[:lower:]'); \
	docker volume rm -f $${project}_adb_keys $${project}_playflow_data 2>/dev/null || true; \
	else \
	echo "skipping"; \
	fi

health:
	@for c in droid_controller droid_emulator droid_playflow; do \
	status=$$(docker inspect -f '{{.State.Health.Status}}' $$c 2>/dev/null || echo "missing"); \
	echo "$$c: $$status"; \
	done

status:
	@$(MAKE) -s health
	@docker compose ps --format 'table {{.Name}}\t{{.State}}\t{{.Ports}}'

doctor:
	@echo "docker:"
	@docker --version || { echo "  missing docker"; exit 1; }
	@echo "docker compose:"
	@docker compose version || { echo "  missing Docker Compose plugin"; echo "  install with: sudo apt-get install docker-compose-plugin"; exit 1; }
	@echo "docker ps:"
	@docker ps >/dev/null || { echo "  cannot run docker ps (check permissions)"; exit 1; }

onboard:
	@echo "Install Docker Engine and ensure your user is in the docker group (Linux)."
	@echo "After installation, restart your shell."
	@$(MAKE) doctor

restart:
	docker compose restart

rebuild:
	docker compose down
	docker compose up -d --build

clean:
	docker compose down -v --rmi all --remove-orphans