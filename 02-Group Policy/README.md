# 03 Group Policy

## Department-Based Group Policy Management

### Overview

Implemented Group Policy Objects (GPOs) within the Aurora Active Directory environment to centrally manage user settings based on departmental Organizational Units (OUs).

This project demonstrates how enterprise administrators use Active Directory and Group Policy to enforce security and configuration standards without modifying each workstation individually.

---

## Objectives

- Create department-specific GPOs
- Link GPOs to Organizational Units
- Apply policies only to targeted users
- Verify GPO processing
- Understand enterprise OU design

---

## Environment

| Component | Configuration |
|-----------|---------------|
| Domain | aurora.local |
| Domain Controller | AUR-DC01 |
| Client | AUR-CL01 |
| Platform | VMware Workstation |
| Active Directory | Windows Server 2022 |
| Client OS | Windows 11 |

---

## Organizational Unit Structure

```text
aurora.local
│
├── Finance
│   ├── Users
│   └── Computers
│
├── HR
│   ├── Users
│   └── Computers
│
├── IT
│   ├── Users
│   └── Computers
│
├── Sales
│   ├── Users
│   └── Computers
```

---

## Policies Configured

### Default Domain Policy

Configured enterprise password policy.

- Minimum password length: **10 characters**
- Password complexity: **Enabled**
- Maximum password age: **90 days**
- Password history: **5 passwords remembered**

Configured account lockout policy.

- Lockout threshold: **5 failed logon attempts**
- Lockout duration: **15 minutes**
- Reset lockout counter: **15 minutes**

---

### Finance Department GPO

Created a dedicated Group Policy Object:

**Finance Disable Control Panel**

Applied to:

```text
Finance
└── Users
```

Policy configured:

```text
User Configuration
└── Policies
    └── Administrative Templates
        └── Control Panel
            └── Prohibit access to Control Panel and PC Settings
```

### Result

- Finance users cannot access Control Panel.
- Policy applies only to Finance department users.
- Other departments remain unaffected.

---

## Testing

Logged into **AUR-CL01** using the Finance user:

Forced a Group Policy update:

```cmd
gpupdate /force
```

Verified applied policies:

```cmd
gpresult /r
```

Output confirmed:

```text
Applied Group Policy Objects

Finance Disable Control Panel
```

Attempting to open Control Panel produced:

```text
This operation has been cancelled due to restrictions in effect on this computer.
Please contact your system administrator.
```

This verified that the Group Policy Object was successfully applied.

---

## Screenshots
<img width="1088" height="804" alt="Screenshot (884)" src="https://github.com/user-attachments/assets/ef0a0a50-9402-4937-9df3-197cdc2f7fff" />
<img width="1193" height="707" alt="Screenshot (895)" src="https://github.com/user-attachments/assets/cc9cfe8f-779b-4898-b77f-fa2432b4b2de" />

