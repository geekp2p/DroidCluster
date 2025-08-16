SHELL := /bin/bash

up:
	docker compose up -d --build

down:
	docker compose down

ps:
	docker compose ps

logs:
	docker compose logs -f --tail=200

sh-controller:
	docker compose exec controller bash

sh-playflow:
	docker compose exec playflow bash

sh-emulator:
	docker compose exec emulator bash

adb-devices:
	docker compose exec controller adb devices

emu-connect:
	docker compose exec controller adb connect droid_emulator:5555

pf-logs:
	docker compose logs -f playflow

pf-restart:
	docker compose restart playflow
