# AWS CloudWatch Monitoring with Nginx

## Objective

By the end of this lab, you will be able to:

* Launch an EC2 instance
* Install and configure Nginx
* Create an IAM Role for CloudWatch
* Install the CloudWatch Agent
* Collect CPU, Memory, and Disk metrics
* Send Nginx Access and Error logs to CloudWatch Logs
* Create a CloudWatch Dashboard
* Create a CPU Utilization Alarm (80%)
* Test the alarm

---

# Architecture

```text
                    User
                      │
                      ▼
              Ubuntu EC2 Instance
        ┌──────────────────────────┐
        │         Nginx            │
        │      CloudWatch Agent    │
        └─────────────┬────────────┘
                      │
             Sends Metrics & Logs
                      │
                      ▼
             Amazon CloudWatch
      ┌──────────────────────────────┐
      │ Metrics                      │
      │ Logs                         │
      │ Dashboard                    │
      │ Alarm                        │
      └──────────────────────────────┘
```

---

# Step 1: Launch an EC2 Instance

Create an Ubuntu EC2 instance with the following configuration:

* **AMI:** Ubuntu 24.04 LTS (or latest Ubuntu)
* **Instance Type:** `t2.micro` (Free Tier)
* **Key Pair:** Create or use an existing key pair
* **Security Group**

  * SSH (22) → My IP
  * HTTP (80) → Anywhere (0.0.0.0/0)

Connect to the instance using SSH.

---

# Step 2: Install Nginx

Update the package list.

```bash
sudo apt update
```

Install Nginx.

```bash
sudo apt install nginx -y
```

Enable the Nginx service.

```bash
sudo systemctl enable nginx
```

Start Nginx.

```bash
sudo systemctl start nginx
```

Verify that Nginx is running.

```bash
sudo systemctl status nginx
```

Expected output:

```text
Active: active (running)
```

Open the web browser.

```text
http://<EC2-Public-IP>
```

You should see the **Welcome to nginx!** page.

---

# Step 3: Create an IAM Role

Navigate to:

```
IAM
→ Roles
→ Create Role
```

### Trusted Entity

* AWS Service
* EC2

### Attach Policy

```
CloudWatchAgentServerPolicy
```

### Role Name

```
CloudWatch-Agent-Role
```

Create the role.

---

# Step 4: Attach the IAM Role to the EC2 Instance

Navigate to:

```
EC2
→ Select Instance
→ Actions
→ Security
→ Modify IAM Role
```

Attach the role:

```
CloudWatch-Agent-Role
```

Click **Update IAM Role**.

---

# Step 5: Install the CloudWatch Agent

Download the package.

```bash
wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
```

Install it.

```bash
sudo dpkg -i amazon-cloudwatch-agent.deb
```

Verify installation.

```bash
ls /opt/aws/amazon-cloudwatch-agent/bin/
```

---

# Step 6: Create the CloudWatch Agent Configuration File

Create the configuration file.

```bash
sudo nano /opt/aws/amazon-cloudwatch-agent/bin/config.json
```

Paste the following JSON configuration.

```json
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "namespace": "CWAgent",
    "append_dimensions": {
      "InstanceId": "${aws:InstanceId}"
    },
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used_percent"
        ]
      },
      "disk": {
        "resources": [
          "/"
        ],
        "measurement": [
          "used_percent"
        ]
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "nginx-access-log",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "nginx-error-log",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
```

Save the file.

```
Ctrl + O
Enter
Ctrl + X
```

---

# Step 7: Start the CloudWatch Agent

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
-s
```

Verify that the service is running.

```bash
sudo systemctl status amazon-cloudwatch-agent
```

Expected output:

```text
Active: active (running)
```

---

# Step 8: Verify Metrics

Navigate to:

```
CloudWatch
→ Metrics
→ CWAgent
```

You should see:

* `mem_used_percent`
* `disk_used_percent`

CPU metrics are available under:

```
CloudWatch
→ Metrics
→ EC2
→ Per-Instance Metrics
→ CPUUtilization
```

### Why is CPU under EC2 instead of CWAgent?

AWS automatically publishes CPU metrics for every EC2 instance.

CloudWatch Agent is required only for metrics that EC2 does **not** provide by default, such as:

* Memory Usage
* Disk Usage
* Application Logs

---

# Step 9: Verify Logs

Refresh your website multiple times.

Navigate to:

```
CloudWatch
→ Log Groups
```

You should see:

* `nginx-access-log`
* `nginx-error-log`

Open **nginx-access-log**.

Example:

```text
GET /
GET /index.html
GET /favicon.ico
```

---

# Step 10: Create a Dashboard

Navigate to:

```
CloudWatch
→ Dashboards
→ Create Dashboard
```

Dashboard Name:

```
Nginx-Monitoring
```

## Widget 1

* Type: Metric
* Namespace: EC2
* Metric: CPUUtilization

## Widget 2

* Type: Metric
* Namespace: CWAgent
* Metric: mem_used_percent

## Widget 3

* Type: Metric
* Namespace: CWAgent
* Metric: disk_used_percent

## Widget 4

* Type: Log Widget
* Log Group: nginx-access-log

Your dashboard should display:

* CPU Utilization
* Memory Usage
* Disk Usage
* Latest Nginx Access Logs

---

# Step 11: Create a CPU Alarm

Navigate to:

```
CloudWatch
→ Alarms
→ Create Alarm
```

Choose:

```
EC2
→ CPUUtilization
```

Configure:

* Threshold: Greater than **80%**
* Period: **5 Minutes**
* Evaluation: **1 Datapoint**

(Optional) Configure an SNS topic to receive email notifications.

Alarm Name:

```
CPU-80-Alarm
```

---

# Step 12: Test the Alarm

Install the stress utility.

```bash
sudo apt update
sudo apt install stress -y
```

Generate CPU load.

```bash
stress --cpu 2 --timeout 300
```

Open the CloudWatch Dashboard and monitor the CPU graph.

Once CPU utilization exceeds **80%**, the alarm state changes:

```text
OK
↓
ALARM
```

---

# Final Verification Checklist

| Component         | Status              |
| ----------------- | ------------------- |
| EC2 Instance      | ✅ Running           |
| Nginx             | ✅ Running           |
| CloudWatch Agent  | ✅ Running           |
| CPU Metric        | ✅ EC2 Namespace     |
| Memory Metric     | ✅ CWAgent Namespace |
| Disk Metric       | ✅ CWAgent Namespace |
| Nginx Access Logs | ✅ CloudWatch Logs   |
| Dashboard         | ✅ Created           |
| CPU Alarm         | ✅ Working           |

---

# Key Concepts

### Default EC2 Metrics

AWS automatically collects:

* CPU Utilization
* Network In
* Network Out
* Disk Read Operations
* Disk Write Operations
* Status Check Metrics

### Custom Metrics

CloudWatch Agent collects:

* Memory Utilization
* Disk Utilization
* Swap Usage (optional)
* Process Metrics (optional)

### CloudWatch Logs

CloudWatch Agent uploads:

* Nginx Access Logs
* Nginx Error Logs
* Application Logs
* System Logs

### CloudWatch Dashboard

A dashboard provides a single view of:

* CPU
* Memory
* Disk
* Logs
* Other AWS Metrics

### CloudWatch Alarm

An alarm continuously monitors a metric and performs an action (such as sending an SNS notification) when a threshold is crossed.

---

# Learning Outcome

After completing this practical, you will be able to:

* Monitor EC2 instances using CloudWatch.
* Collect custom metrics using the CloudWatch Agent.
* Monitor Nginx logs in CloudWatch Logs.
* Build a custom CloudWatch Dashboard.
* Create and test CloudWatch Alarms.
* Understand the difference between default AWS metrics and custom metrics.
