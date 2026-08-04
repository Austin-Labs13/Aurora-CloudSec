# 04 - DNS & DHCP Infrastructure

---

## Overview

Designed and implemented enterprise DNS and DHCP services within the Aurora CloudSec Active Directory environment.

This project expanded the existing Active Directory infrastructure by configuring DNS name resolution, forward and reverse lookup zones, DNS aliases (CNAME), and enterprise DHCP services for automatic client network configuration.

The deployment concluded with troubleshooting and resolving a VMware Workstation DHCP conflict to ensure all domain clients received network configuration directly from the Windows Server.

---

## Objectives

- Configure DNS services
- Validate forward and reverse name resolution
- Create DNS aliases using CNAME records
- Deploy Windows Server DHCP
- Configure a DHCP scope
- Integrate DHCP with Active Directory and DNS
- Automatically assign network configuration to domain clients
- Validate client connectivity

---

# Environment

| Component | Configuration |
|-----------|---------------|
| Hypervisor | VMware Workstation Pro |
| Domain | aurora.local |
| Domain Controller | AUR-DC01 |
| Client Workstation | AUR-CL01 |
| Operating System | Windows Server 2022 |
| Client OS | Windows 11 Pro |
| Network | 192.168.107.0/24 |
| Gateway | 192.168.107.2 |
| DNS Server | 192.168.107.10 |
| DHCP Scope | 192.168.107.100 - 192.168.107.200 |

---

# DNS Configuration

## Forward Lookup Zone

Verified the Active Directory integrated Forward Lookup Zone for **aurora.local**, confirming automatic registration of domain resources.

---

## Reverse Lookup Zone

Created an IPv4 Reverse Lookup Zone to enable reverse DNS resolution using PTR records.

This allows IP addresses to resolve back to hostnames, improving troubleshooting and administrative visibility.

---

## DNS Alias (CNAME)

Created a DNS alias named:

```text
fileserver
```

The alias was mapped to:

```text
aur-dc01.aurora.local
```

This demonstrates how enterprise environments provide friendly service names that can later be redirected to dedicated servers without changing the client experience.
<img width="836" height="927" alt="Screenshot (917)" src="https://github.com/user-attachments/assets/68ac9953-a680-4e41-83f0-172f2eb40956" />

---

## DNS Validation

Validated DNS functionality using:

```cmd
ping fileserver

nslookup fileserver

nslookup 192.168.107.10
```

Confirmed:

- Forward Name Resolution
- Reverse Name Resolution
- CNAME Resolution
- Active Directory DNS integration

---

# DHCP Configuration

## DHCP Server Deployment

- Installed the DHCP Server role
- Completed post-install configuration
- Authorized DHCP within Active Directory

---

## IPv4 Scope

Created an enterprise DHCP scope.

| Setting | Value |
|---------|-------|
| Network | 192.168.107.0/24 |
| Scope Range | 192.168.107.100 – 192.168.107.200 |
| Lease Duration | 8 Days |

---

## DHCP Options

Configured clients to automatically receive:

| Option | Value |
|---------|-------|
| Default Gateway | 192.168.107.2 |
| DNS Server | 192.168.107.10 |
| Domain Name | aurora.local |

---

## Client Configuration

Converted the Windows 11 workstation from static addressing to DHCP.

Renewed the network lease using:

```cmd
ipconfig /release

ipconfig /renew

ipconfig /all
```

Validated that the client automatically received:

- IPv4 Address
- Subnet Mask
- Default Gateway
- DNS Server
- DNS Suffix

---

# Troubleshooting

## Issue Encountered

Following DHCP deployment, client devices received the following IP addresses

- DHCP Server: **192.168.107.254**
- DNS Server: **192.168.107.2**
- Windows DHCP Address Leases remained empty

---

## Investigation

Client configuration was reviewed using:

```cmd
ipconfig /all
```

The output confirmed that VMware's DHCP service was responding to requests before the Windows DHCP Server.


---

## Resolution

Opened VMware Virtual Network Editor and disabled the VMware local DHCP service while retaining NAT networking.
<img width="940" height="904" alt="Screenshot (927)" src="https://github.com/user-attachments/assets/39e31f8a-5cba-4b24-be29-cde3f693d1ab" />


After renewing the client lease:

```cmd
ipconfig /release

ipconfig /renew
```

The workstation successfully received:

- DHCP Server: **192.168.107.10**
- DNS Server: **192.168.107.10**
- Dynamic IP Address from the configured DHCP scope
<img width="936" height="980" alt="Screenshot (930)" src="https://github.com/user-attachments/assets/52b1feb5-dd37-4d00-b310-efd09a7805fa" />


The Windows DHCP console immediately displayed the active lease for **AUR-CL01**, confirming successful deployment.
<img width="945" height="901" alt="Screenshot (929)" src="https://github.com/user-attachments/assets/c14f6ed2-f5ef-45df-9363-96068eb50c0e" />

---

# Validation

The completed deployment was verified by confirming:

- DNS Forward Lookup functionality
- DNS Reverse Lookup functionality
- DNS Alias resolution
- Automatic DHCP address assignment
- Active DHCP lease creation
- Automatic DNS configuration
- Successful client connectivity
- Active Directory integration



# Lessons Learned

This project demonstrated the close relationship between DNS, DHCP and Active Directory within enterprise Windows environments.

A real-world networking issue occurred when VMware's built-in DHCP service assigned client network settings before the Windows DHCP Server. By systematically reviewing client configuration, DHCP leases and VMware networking, the root cause was identified and resolved.

This reinforced the importance of validating infrastructure services, understanding DHCP behaviour and following a structured troubleshooting methodology rather than assuming a server configuration issue.

---

