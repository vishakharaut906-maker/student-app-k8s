# 🚀 Prometheus + Grafana + Node Exporter using Docker Compose

## 📁 1. Create Directory

```bash
mkdir monitoring
cd monitoring
```

## 🐳 2. Create docker-compose.yml

```bash
nano docker-compose.yml
```

Paste:

```yaml
services:

  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"

  node-exporter:
    image: prom/node-exporter
    ports:
      - "9100:9100"
```

💾 Save:

```text
CTRL + O
ENTER
CTRL + X
```

## ⚙️ 3. Create prometheus.yml

```bash
nano prometheus.yml
```

Paste:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "node-exporter"
    static_configs:
      - targets: ["node-exporter:9100"]
```

💾 Save:

```text
CTRL + O
ENTER
CTRL + X
```

## 🚀 4. Start All Containers

```bash
docker compose up -d
```

## 🔍 5. Check Containers

```bash
docker compose ps
```

or:

```bash
docker ps
```

You should see:

```text
prometheus
grafana
node-exporter
```

## 📊 6. Check Node Exporter

Open in browser:

```text
http://SERVER-IP:9100/metrics
```

Example:

```text
http://13.233.XX.XX:9100/metrics
```

## 🔥 7. Open Prometheus

```text
http://SERVER-IP:9090
```

Go to:

```text
Status → Targets
```

You should see:

```text
node-exporter    UP
```

## 📈 8. Open Grafana

```text
http://SERVER-IP:3000
```

🔐 Default login:

```text
Username: admin
Password: admin
```

## 🔗 9. Add Prometheus Data Source in Grafana

Go to:

```text
Connections → Data Sources → Add data source → Prometheus
```

Prometheus URL:

```text
http://prometheus:9090
```

Click:

```text
Save & Test
```

## 🛠️ 10. Useful Docker Compose Commands

▶️ Start:

```bash
docker compose up -d
```

🛑 Stop:

```bash
docker compose down
```

🔍 Check:

```bash
docker compose ps
```

📜 View all logs:

```bash
docker compose logs
```

📊 Prometheus logs:

```bash
docker compose logs prometheus
```

📈 Grafana logs:

```bash
docker compose logs grafana
```

🖥️ Node Exporter logs:

```bash
docker compose logs node-exporter
```

🔄 Restart:

```bash
docker compose restart
```

## 🏗️ Architecture

```text
🖥️ Node Exporter
       ↓
📊 Prometheus
       ↓
📈 Grafana
```

## 🔌 Ports

```text
🖥️ Node Exporter → 9100
📊 Prometheus    → 9090
📈 Grafana       → 3000
```

## ✅ Final Setup

```text
Docker Host
    │
    ├── 🖥️ Node Exporter :9100
    │          ↓
    ├── 📊 Prometheus :9090
    │          ↓
    └── 📈 Grafana :3000
```
