# 04 - File and Print Services

## Overview

This phase of the Aurora CloudSec lab introduced a dedicated Windows Server 2022 file and print server, **AUR-FS01**, to move shared business services away from the domain controller.

The server was joined to the `aurora.local` domain and configured to provide centralised departmental file storage and network printing.

The implementation focused on:

- Centralised file sharing
- Active Directory-based access control
- NTFS permissions
- Departmental resource separation
- Network drive access
- Windows Print Services
- Network printer configuration
- Group Policy printer deployment
- Client-side validation and troubleshooting

---

## Environment

| System | Role |
|---|---|
| AUR-DC01 | Domain Controller, Active Directory, DNS and DHCP |
| AUR-FS01 | File and Print Server |
| AUR-CL01 | Windows 11 domain workstation |
| AUR-PRN01 | Simulated network printer |
| aurora.local | Active Directory domain |

---

# File Services

## Department Shares

AUR-FS01 was configured as the central file server for the Aurora environment.

Separate network shares were created for:

- HR
- Finance
- Sales
- IT

This provides each department with a central location for storing and accessing business files while allowing access to be controlled through Active Directory.

---

## Active Directory Access Control

Access to departmental resources was controlled using Active Directory security groups rather than assigning permissions directly to individual users.

Department security groups were granted access to their corresponding file shares.

This allows access to be managed through group membership as employees join, leave or move between departments.

---

## NTFS Permissions

NTFS permissions were configured on the departmental folders to restrict access to authorised security groups.

Department groups were granted **Modify** permissions to their respective folders.

Unnecessary broad access was removed to prevent users from accessing departmental data they were not authorised to use.

This separates the availability of a network share from the permissions controlling the underlying files and folders.

---

## Access Validation

File permissions were tested using multiple domain user accounts from AUR-CL01.

Testing confirmed that:

- Authorised department users could access their departmental share.
- Users could create and modify files where permitted.
- Users outside the authorised department were denied access.
- Access was determined by Active Directory group membership.

This validated that the file server permissions were operating as intended.

---

# Print Services

## Print Server Configuration

The **Print and Document Services** role was installed on AUR-FS01 to provide centralised printer management.

A simulated enterprise network printer was configured as:

**Printer Name:** `AUR-PRN01`

**Print Server:** `AUR-FS01`

**Driver:** Canon Generic Plus PCL6

**Shared Printer Path:**

`\\AUR-FS01\AUR-PRN01`

A Canon PCL6 driver was installed on the print server to simulate the process of deploying and centrally managing a business printer.

---

## Network Printer Configuration

AUR-PRN01 was configured as a network printer using a **Standard TCP/IP printer port**.

In a physical production environment, this configuration would allow the print server to communicate with a network printer using its assigned IP address.

For the Aurora virtual environment, the printer was simulated to allow the print-server infrastructure, driver management, sharing and Group Policy deployment process to be implemented without requiring physical printer hardware.

---

## Printer Sharing and Permissions

AUR-PRN01 was shared from AUR-FS01 so domain workstations could connect to the printer through the print server.

Printer security permissions were reviewed to distinguish between:

- **Print** – allows users to submit print jobs.
- **Manage documents** – allows management of print jobs.
- **Manage this printer** – provides administrative control over the printer.

This separates printer access from printer administration.

---

# Group Policy Printer Deployment

## Deployment GPO

To automatically provide the printer to domain workstations, a new Group Policy Object was created:

`Deploy - AUR-PRN01`

The GPO was linked to the **Workstations OU**, which contains AUR-CL01.

The shared printer:

`\\AUR-FS01\AUR-PRN01`

was then deployed through the GPO using a **Per Machine** connection.

This means the printer is assigned to the workstation rather than an individual user.

Any authorised employee using the workstation can therefore access the centrally deployed printer without manually installing it.

---

## Group Policy Validation

Group Policy was refreshed on AUR-CL01 using:

`gpupdate /force`

The resulting computer policy was inspected using:

`gpresult /r`

The following GPO was confirmed under **Applied Group Policy Objects**:

`Deploy - AUR-PRN01`

This verified that AUR-CL01 successfully received the printer deployment policy from the domain.

---

## Client Deployment Validation

After Group Policy processing completed, **AUR-PRN01 automatically appeared on AUR-CL01** as:

`AUR-PRN01 on AUR-FS01`

The printer was not manually installed on the workstation.

A Windows test page was then submitted from AUR-CL01.

Windows confirmed:

> A test page has been sent to your printer.

Because AUR-PRN01 is a simulated printer and no physical printer exists in the lab, the purpose of this test was to verify that the client could recognise the deployed printer and submit a print job through the configured print infrastructure.

---

# Troubleshooting and Validation

During implementation, several components were validated individually rather than assuming successful configuration.

This included:

- Confirming AUR-FS01 remained operational after restart.
- Verifying the printer queue reported a Ready state.
- Checking printer sharing and security permissions.
- Confirming AUR-CL01 was located in the Workstations OU.
- Verifying the printer deployment GPO was linked to the correct OU.
- Forcing Group Policy processing using `gpupdate /force`.
- Using `gpresult /r` to confirm the GPO applied at the computer level.
- Confirming the printer appeared automatically on AUR-CL01.
- Submitting a Windows test page from the client.

This troubleshooting process helped isolate Group Policy deployment from printer and driver configuration rather than changing multiple components simultaneously.

---

## Outcome

AUR-FS01 now provides centralised file and print services for the Aurora CloudSec environment.

Departmental data is separated using Active Directory groups and NTFS permissions, while network printing is centrally managed through the file and print server.

AUR-PRN01 is automatically deployed to domain workstations through Group Policy, demonstrating how centralised Windows infrastructure can provide resources to users without requiring manual configuration on individual endpoints.
