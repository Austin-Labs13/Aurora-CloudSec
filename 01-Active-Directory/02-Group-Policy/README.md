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

## Lessons Learned

- Group Policies are best applied to Organizational Units rather than individual users.
- Proper OU design is critical for scalable enterprise administration.
- Separating **Users** and **Computers** into dedicated departmental OUs provides greater flexibility for future policies.
- `gpresult /r` is an essential troubleshooting tool for verifying GPO application.
- Testing with a standard user account confirms that policies function as intended.

---

## Enterprise Relevance

This project demonstrates practical Windows Server administration skills including:

- Active Directory administration
- Organizational Unit design
- Group Policy deployment
- Enterprise password policy management
- Account lockout configuration
- User based policy targeting
- Group Policy troubleshooting
- Policy verification using gpresult

---

## Screenshots
<img width="1088" height="804" alt="Screenshot (884)" src="https://github.com/user-attachments/assets/64105feb-ccd6-45c2-8886-ca4b6785cd45" />
<img width="1193" height="707" alt="Screenshot (895)" src="https://github.com/user-attachments/assets/960e5cc7-5c38-43bc-b5e4-1d58007a95e1" />



