
# 05 – Active Directory User Lifecycle Automation with PowerShell

## Overview

Built reusable PowerShell scripts to automate Active Directory user onboarding and offboarding within the Aurora CloudSec environment.

The goal was to reduce repetitive manual administration in Active Directory Users and Computers (ADUC) while introducing validation, error handling, consistent account configuration, and repeatable user lifecycle processes.

---

## Scripts

```text
New-AuroraEmployee.ps1
Disable-AuroraEmployee.ps1
```

---

## User Onboarding Automation

The onboarding script collects:

- First name
- Last name
- Department
- Temporary password

It then automatically:

- Validates first and last name input
- Normalises department input
- Rejects invalid departments
- Generates the `SamAccountName`
- Generates the User Principal Name (UPN)
- Checks for duplicate usernames
- Selects the correct departmental OU
- Creates and enables the Active Directory account
- Adds the user to the correct departmental security group
- Verifies account creation and group membership

---

## Input Validation

The script prevents blank first or last names from being accepted.

```powershell
do {
    $FirstName = (Read-Host "Enter first name").Trim()

    if ([string]::IsNullOrWhiteSpace($FirstName)) {
        Write-Host "No first name entered. Please try again."
    }

} until (-not [string]::IsNullOrWhiteSpace($FirstName))
```

The same validation is applied to the employee's last name.

Department input is also normalised using:

```powershell
.Trim().ToUpper()
```

A `do/until` loop ensures the administrator must enter a valid department before the script continues.

```powershell
do {
    $Department = (Read-Host "Enter department").Trim().ToUpper()

    if ($Department -notin @("HR", "FINANCE", "SALES", "IT")) {
        Write-Host "Invalid department. Please enter HR, Finance, Sales, or IT."
    }

} until ($Department -in @("HR", "FINANCE", "SALES", "IT"))
```

---

## Automated Username Generation

The username is automatically generated using the first letter of the employee's first name followed by their surname.

```powershell
$Username = ($FirstName.Substring(0,1) + $LastName).ToLower()
$UPN = "$Username@aurora.local"
$FullName = "$FirstName $LastName"
```

This provides a consistent naming convention without requiring the administrator to manually create account names.

---

## Duplicate Account Protection

Before creating the account, the script checks Active Directory for an existing matching `SamAccountName`.

```powershell
if (Get-ADUser -Filter "SamAccountName -eq '$Username'") {
    Write-Host "A user with the username $Username already exists."
    exit
}
```

This prevents accidental duplicate account creation.

---

## Department-Based Provisioning

A PowerShell `switch` statement maps each department to the correct Organizational Unit and security group.

```powershell
switch ($Department) {

    "HR" {
        $OU = "OU=Users,OU=HR,DC=aurora,DC=local"
        $Group = "HR Staff"
    }

    "FINANCE" {
        $OU = "OU=Users,OU=Finance,DC=aurora,DC=local"
        $Group = "Finance Staff"
    }

    "SALES" {
        $OU = "OU=Users,OU=Sales,DC=aurora,DC=local"
        $Group = "Sales Staff"
    }

    "IT" {
        $OU = "OU=Users,OU=IT,DC=aurora,DC=local"
        $Group = "IT Support"
    }
}
```

This allows one script to provision users across all departments without modifying the script for each employee.

---

## Active Directory Account Creation

The account is created using `New-ADUser`.

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

The user is then added to the appropriate departmental security group:

```powershell
Add-ADGroupMember -Identity $Group -Members $Username
```
<img width="966" height="867" alt="Screenshot (1199)" src="https://github.com/user-attachments/assets/232dc446-78bc-4295-9ed5-a100ede3fcd7" />

---

## Onboarding Verification

The script verifies the account after creation.

```powershell
Get-ADUser -Identity $Username |
Select-Object Name, SamAccountName, Enabled
```

Group membership is also verified:

```powershell
Get-ADPrincipalGroupMembership -Identity $Username |
Select-Object Name
```

Testing confirmed successful user provisioning across:

- HR
- Finance
- Sales
- IT

---

# User Offboarding Automation

A second PowerShell script was developed to automate employee offboarding.

The script performs the following workflow:

1. Accepts the employee username
2. Searches Active Directory for the account
3. Stops if the user does not exist
4. Displays the matched employee information
5. Requires administrator confirmation
6. Disables the Active Directory account
7. Reviews existing group memberships
8. Removes all non-default access groups
9. Moves the account to the `Disabled Users` OU
10. Verifies the final account state

---

## Account Lookup and Validation

The script first searches for the supplied username.

```powershell
$Username = (Read-Host "Enter username of employee to offboard").Trim()

$User = Get-ADUser -Filter "SamAccountName -eq '$Username'"
```

If the account does not exist, the script stops.

```powershell
if ($null -eq $User) {
    Write-Host "User not found. Please check the username and try again."
    exit
}
```

---

## Administrator Confirmation

Before making any changes, the script displays the matched account and requires explicit confirmation.

```powershell
Write-Host "Employee found:"
Write-Host "Name: $($User.Name)"
Write-Host "Username: $($User.SamAccountName)"

$Confirm = Read-Host "Type YES to confirm offboarding"

if ($Confirm.ToUpper() -ne "YES") {
    Write-Host "Offboarding cancelled."
    exit
}
```

This reduces the risk of disabling the wrong account.

---

## Disable Account

The account is disabled immediately:

```powershell
Disable-ADAccount -Identity $User
```

This prevents further authentication while preserving the Active Directory object.

---

## Remove Access Groups

The script retrieves the user's group memberships while excluding `Domain Users`.

```powershell
$Groups = Get-ADPrincipalGroupMembership -Identity $User |
Where-Object { $_.Name -ne "Domain Users" }
```

It then removes the user from each remaining access group.

```powershell
foreach ($Group in $Groups) {
    Remove-ADGroupMember -Identity $Group.DistinguishedName -Members $Username
}
```

This removes departmental access while retaining the default domain group.

---

## Move Disabled Account

The account is moved into the dedicated `Disabled Users` OU.

```powershell
Move-ADObject `
-Identity $User.DistinguishedName `
-TargetPath "OU=Disabled Users,DC=aurora,DC=local"
```

This separates inactive accounts from active departmental users.

<img width="938" height="873" alt="Screenshot (1200)" src="https://github.com/user-attachments/assets/5fd05b66-0a32-41b8-adbc-0e015695cf7c" />

---

## Offboarding Verification

The script verifies the final account state.

```powershell
Get-ADUser -Identity $Username |
Select-Object Name, SamAccountName, Enabled, DistinguishedName
```

Group membership is also checked:

```powershell
Get-ADPrincipalGroupMembership -Identity $Username |
Select-Object Name
```

Successful testing confirmed:

```text
Enabled: False
OU: Disabled Users
Remaining Group: Domain Users
```

---

## Testing and Troubleshooting

The scripts were tested using multiple Active Directory users across different departments.

Testing included:

- Duplicate username detection
- Blank name validation
- Invalid department input
- Department capitalisation and whitespace handling
- User-not-found handling
- Offboarding cancellation
- Group membership cleanup
- OU movement
- Final-state verification

PowerShell errors were reviewed from the first reported failure to identify root causes rather than relying on later cascading errors.

---
<img width="953" height="885" alt="Screenshot (1201)" src="https://github.com/user-attachments/assets/4b609e54-70e9-477e-81de-9d40a7756b92" />



## Outcome

Implemented reusable PowerShell-based onboarding and offboarding workflows for the Aurora CloudSec Active Directory environment.

The scripts reduced repetitive administrative tasks and introduced consistent:

- Account naming
- OU placement
- Security group assignment
- Input validation
- Duplicate account protection
- Account disabling
- Access removal
- Disabled-account organisation
- Post-change verification

The completed workflow allows common Active Directory user lifecycle tasks to be performed in seconds while maintaining validation and administrative control.

---


