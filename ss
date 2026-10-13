# 🌐 Basic Networking in Linux

## Overview of Networking Fundamentals

Networking is the process of connecting computers and devices so they can communicate and share data over a network such as a **LAN (Local Area Network)** or the **Internet**.

### Examples

- Your laptop accesses a website.
- A Linux server connects to a database server.
- Two servers communicate in a Kubernetes cluster.

> **All of this happens through networking.**

---

# 1. IP Address

An **IP (Internet Protocol) Address** is a unique address assigned to every device on a network. It identifies where data should be sent.

### Example

```text
192.168.1.10
```

### Real-World Analogy

Think of an IP address like your **home address**.

- If someone wants to send you a parcel, they need your address.
- Similarly, when one computer sends data to another, it needs the destination IP address.

## Types of IP Addresses

### Private IP Address

Used inside organizations and private networks.

```text
192.168.x.x
10.x.x.x
172.16.x.x - 172.31.x.x
```

### Public IP Address

Used on the Internet.

```text
8.8.8.8
142.250.183.14
```

---

# 2. Subnet Mask

A **Subnet Mask** tells the computer:

- Which part of the IP address represents the **Network**
- Which part represents the **Host (Device)**

### Example

```text
IP Address : 192.168.1.25
Subnet Mask: 255.255.255.0
```

This means:

```text
Network Part : 192.168.1
Host Part    : 25
```

All devices with the following IP range belong to the same network:

```text
192.168.1.x
```

---

# 3. Gateway (Default Gateway)

A **Gateway** is the router that connects your local network to other networks such as the Internet.

### Real-World Analogy

Think of it as the **main exit gate** of your office or apartment.

### Example

**Your PC**

```text
192.168.1.10
```

**Router (Gateway)**

```text
192.168.1.1
```

**Google Server**

```text
142.250.183.14
```

Since Google is outside your local network, the communication flow is:

```text
PC
 │
 ▼
Gateway
 │
 ▼
Internet
 │
 ▼
Google
```

> **Without a gateway, your computer can communicate only with devices on the same local network.**

## Linux Command

```bash
ip route
```

### Example Output

```text
default via 192.168.1.1 dev eth0
```

Here,

```text
192.168.1.1
```

is the **Default Gateway**.

---

# 4. DNS (Domain Name System)

Humans remember names better than numbers.

Instead of typing:

```text
142.250.183.14
```

we type:

```text
google.com
```

A **DNS (Domain Name System)** converts the domain name into its corresponding IP address.

### DNS Resolution

```text
www.google.com
        │
        ▼
   DNS Server
        │
        ▼
142.250.183.14
```

## Linux Commands

```bash
dig google.com
```

or

```bash
nslookup google.com
```

### Example Output

```text
google.com. IN A 142.250.183.14
```

---

# How These Components Work Together

Suppose you open:

```text
https://google.com
```

The following steps occur:

### Step 1

Your browser asks the DNS server:

> **"What is the IP address of google.com?"**

### Step 2

The DNS server replies:

```text
142.250.183.14
```

### Step 3

Your computer checks:

- Is this IP in my local network?
- **No**

### Step 4

The packet is sent to the **Default Gateway**.

### Step 5

The Gateway forwards the packet through the Internet.

### Step 6

Google's server receives the request and sends back the webpage.

---

# Complete Flow

```text
               https://google.com
                       │
                       ▼
                Browser Request
                       │
                       ▼
                  DNS Server
      (Resolves google.com to IP)
                       │
                       ▼
                142.250.183.14
                       │
                       ▼
             Is it in Local Network?
                       │
                 No ───┘
                       │
                       ▼
             Default Gateway (Router)
                       │
                       ▼
                  Internet
                       │
                       ▼
                 Google Server
                       │
                       ▼
             Sends Response Back
                       │
                       ▼
                    Browser
```

---

# Summary

| Component | Purpose |
|-----------|---------|
| **IP Address** | Identifies a device on the network. |
| **Subnet Mask** | Separates the Network ID and Host ID. |
| **Gateway** | Routes traffic from the local network to other networks. |
| **DNS** | Converts domain names into IP addresses. |

---

## Linux Commands Reference

| Command | Description |
|----------|-------------|
| `ip addr` | Display IP addresses of network interfaces |
| `hostname -I` | Show the system's IP address |
| `ip route` | Display the routing table and default gateway |
| `ping google.com` | Test network connectivity |
| `curl https://google.com` | Test HTTP/HTTPS connectivity |
| `dig google.com` | Query DNS records |
| `nslookup google.com` | Resolve domain names to IP addresses |

---

## Key Takeaways

- Every device on a network has an **IP Address**.
- A **Subnet Mask** determines the network and host portions of an IP.
- A **Gateway** allows devices to communicate with external networks.
- **DNS** translates domain names into IP addresses.
- Together, these components make communication over the Internet possible.
