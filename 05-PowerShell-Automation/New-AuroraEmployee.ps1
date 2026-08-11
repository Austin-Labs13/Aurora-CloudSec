# Aurora CloudSec - New Employee Onboarding Script
do {
$FirstName = (Read-Host "Enter first name").Trim()
if ([string]::IsNullOrWhiteSpace($FirstName)) {
Write-Host "No first name entered. Please try again."
}
} until (-not [string]::IsNullOrWhiteSpace($FirstName))
do {
$LastName = (Read-Host "Enter last name").Trim()
if ([string]::IsNullOrWhiteSpace($LastName)) {
Write-Host "No last name entered. Please try again."
}
} until (-not [string]::IsNullOrWhiteSpace($LastName))

do {
$Department = (Read-Host "Enter department").Trim().ToUpper()
if ($Department -notin @("HR", "Finance", "Sales", "IT")) {
Write-Host "Invalid department. Please enter HR, Finance, Sales, or IT."
}
} until ($Department -in @("HR", "Finance", "Sales", "IT"))
$Username = ($FirstName.Substring(0,1) + $LastName).ToLower()
$UPN = "$Username@aurora.local"
$FullName = "$FirstName $LastName"
if (Get-ADUser -Filter "SamAccountName -eq '$Username'") {
Write-Host "A user with the username $Username already exists."
exit
}
# Select department OU and security group

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

#Ask for temporary password

$Password = Read-Host "Enter temporary password" -AsSecureString


# Create the Active Directory user
New-ADUser `
-Name $FullName `
-GivenName $FirstName `
-Surname $LastName `
-SamAccountName $Username `
-UserPrincipalName $UPN `
-Path $OU `
-AccountPassword $Password `
-Enabled $true

# Add user to department security group
Add-ADGroupMember -Identity $Group -Members $Username

#Verify account creation
Get-ADUser -Identity $Username | Select-Object Name, SamAccountName, Enabled
Get-ADPrincipalGroupMembership -Identity $Username | Select-Object Name