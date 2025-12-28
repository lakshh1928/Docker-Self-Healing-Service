# Auto-Healing Docker Service Monitor

---

## Overview

This project demonstrates a **basic self-healing mechanism** for a Dockerized application using **Bash scripting, Docker Compose, and Nginx**.

The system continuously monitors an application endpoint and:

* Detects service failures (5xx errors or unreachable service)
* Attempts automated recovery via container restarts
* Logs every event with timestamps and severity
* Sends real-time alerts to Discord
* Escalates with a critical alert if recovery fails

This project focuses on **recovery and alerting**, not auto-debugging or runtime configuration changes.

---

## Tech Stack

* Bash scripting
* Docker & Docker Compose
* Nginx (serving a static Simon game)
* curl (health checks)
* Discord Webhooks (alerting)

---

## How It Works

### Health Monitoring

* The script runs in an infinite loop
* Uses `curl` to check HTTP status from the service endpoint

### Decision Logic

| Condition         | Action                                 |
| ----------------- | -------------------------------------- |
| HTTP 200          | Log service as healthy                 |
| HTTP 5xx          | Log issue, alert, attempt recovery     |
| No response (000) | Treat as unreachable, attempt recovery |

### Recovery Strategy

* Restart containers using `docker compose restart`
* Retry up to **3 times** with a cooldown
* Re-check health after every restart

### Escalation

* If service does not recover after retries:

  * Log failure
  * Send **CRITICAL** Discord alert
  * Stop further action

---

## Logging

All events are written to `log.txt` in a structured format:

```
[YYYY-MM-DD HH:MM:SS] [LEVEL] message
```

Example:

```
[2025-01-28 14:35:01] [WARN] HTTP 503 detected
[2025-01-28 14:35:02] [INFO] Restart attempt 1
[2025-01-28 14:35:15] [INFO] Service recovered
```

---

## Failure Scenarios Tested

| Scenario                | Result                         |
| ----------------------- | ------------------------------ |
| Backend dependency down | 502 detected, auto-recovered   |
| Application crash       | Restart attempted              |
| Forced Nginx 503        | Recovery attempts + escalation |
| Nginx stopped           | Service unreachable handled    |

---

## What This Project Does NOT Do

* ❌ Auto-edit Nginx configuration
* ❌ Modify containers at runtime
* ❌ Claim 100% automatic fixes

Persistent failures are intentionally escalated for **human intervention**.

---

## Why This Project Matters

This project reflects **real-world DevOps thinking**:

* Containers are immutable
* Self-healing focuses on recovery, not magic fixes
* Alerting and observability are as important as automation

---

## How to Run

```bash
docker compose up -d
Then change the permission of the script using -> chmod +x monitor.sh
bash monitor.sh
```

---

## Author

Laksh

---
