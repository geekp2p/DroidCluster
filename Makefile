<<<<<<< HEAD
SHELL := /bin/bash

up:
\tdocker compose up -d --build

down:
\tdocker compose down

ps:
\tdocker compose ps

logs:
\tdocker compose logs -f --tail=200

sh-controller:
\tdocker compose exec controller bash

sh-playflow:
\tdocker compose exec playflow bash

adb-devices:
\tdocker compose exec controller adb devices

emu-connect:
\tdocker compose exec controller adb connect droid_emulator:5555
=======
SHELL := /bin/bash

up:
\tdocker compose up -d --build

down:
\tdocker compose down

ps:
\tdocker compose ps

logs:
\tdocker compose logs -f --tail=200

sh-controller:
\tdocker compose exec controller bash

sh-playflow:
\tdocker compose exec playflow bash

adb-devices:
\tdocker compose exec controller adb devices

emu-connect:
\tdocker compose exec controller adb connect droid_emulator:5555
>>>>>>> 8de3c6bc73da24e02bd0a1b96ad168f6131dc1c5
