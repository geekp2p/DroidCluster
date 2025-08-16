FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    android-tools-adb \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV ADB_SERVER_SOCKET="tcp:controller:5037"

EXPOSE 5000

CMD ["python", "app.py"]