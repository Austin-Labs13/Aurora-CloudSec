# 05 – Active Directory User Provisioning with PowerShell

## Overview

Developed a reusable PowerShell script to automate Active Directory user provisioning within the Aurora CloudSec environment.

The script replaces repetitive manual user creation through Active Directory Users and Computers (ADUC) with a consistent automated workflow.

---

## Implementation

The PowerShell script collects:

- First name
- Last name
- Department
- Temporary password

It then automatically:

- Generates the user's `SamAccountName`
- Generates the User Principal Name (UPN)
- Determines the correct departmental Organizational Unit (OU)
- Creates and enables the Active Directory account
- Adds the user to the appropriate departmental security group
- Verifies account creation and group membership

---

## Department-Based Provisioning

A PowerShell `switch` statement maps each department to its corresponding OU and security group.

```powershell
switch ($Department) {

    "HR" {
        $OU = "OU=Users,OU=HR,DC=aurora,DC=local"
        $Group = "HR Staff"
    }

    "Finance" {
        $OU = "OU=Users,OU=Finance,DC=aurora,DC=local"
        $Group = "Finance Staff"
    }

    "Sales" {
        $OU = "OU=Users,OU=Sales,DC=aurora,DC=local"
        $Group = "Sales Staff"
    }

    "IT" {
        $OU = "OU=Users,OU=IT,DC=aurora,DC=local"
        $Group = "IT Support"
    }

    default {
        Write-Host "Invalid department. Please use HR, Finance, Sales, or IT."
        exit
    }
}
```

This allows a single script to provision users across multiple departments without modifying the script for each employee.

---

## Automated Account Creation

User account attributes are generated from the information supplied to the script.

```powershell
$Username = ($FirstName.Substring(0,1) + $LastName).ToLower()
$UPN = "$Username@aurora.local"
$FullName = "$FirstName $LastName"
```

The account is then created using:

```powershell
New-ADUser `
-Name $FullName `
-GivenName $FirstName `
-Surname $LastName `
-SamAccountName $Username `
-UserPrincipalName $UPN `
-Path $OU `
-AccountPassword $Password `
-Enabled $true
```

Departmental group membership is automatically assigned:

```powershell
Add-ADGroupMember -Identity $Group -Members $Username
```

---

## Validation

The script verifies the account after provisioning:

```powershell
Get-ADUser -Identity $Username |
Select-Object Name, SamAccountName, Enabled

Get-ADPrincipalGroupMembership -Identity $Username |
Select-Object Name
```

The script was successfully tested across multiple departments to confirm dynamic OU placement and security group assignment.

---

## Outcome

Implemented a reusable Active Directory onboarding workflow that reduces repetitive administration and provides consistent user provisioning based on departmental requirements.

<img width="987" height="1055" alt="Screenshot (1129)" src="https://github.com/user-attachments/assets/db6186c9-fe8e-4869-8e41-f642829803ca" />

<img width="957" height="1042" alt="Screenshot (1125)" src="https://github.com/user-attachments/assets/29ea94a3-a440-462d-b3ce-e4452fde1998" />

<img width="961" height="1009" alt="Screenshot (1108)" src="https://github.com/user-attachments/assets/01bcfb50-a79f-4b78-a61a-03b0ae7c5c77" />

