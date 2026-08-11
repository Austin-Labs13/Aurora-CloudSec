# Aurora CloudSec Offboarding Script

$Username = (Read-Host "Enter username of employee to offboard").Trim()
$User = Get-ADUser -Filter "SamAccountName -eq '$Username'"
if ($null -eq $User) {
Write-Host "User not found. Please check the username and try again."
exit
}

Write-Host "Employee found:"
Write-Host "Name: $($User.Name)"
Write-Host "Username: $($User.SamAccountName)"

$Confirm = Read-Host "Type YES to confirm offboarding"
if ($Confirm.ToUpper() -ne "YES") {
Write-Host "Offboarding Cancelled."
exit
}

Disable-ADAccount -Identity $User
Write-Host "Account disabled succesfully."

$Groups = Get-ADPrincipalGroupMembership -Identity $User | Where-Object { $_.Name -ne "Domain Users" }
foreach ($Group in $Groups) {
Remove-ADGroupMember -Identity $Group.DistinguishedName -Members $Username
}

Move-ADObject -Identity $User.DistinguishedName -TargetPath "OU=Disabled Users,DC=aurora,DC=local"
Write-Host "User moved to Disabled Users."

Write-Host "Offboarding complete. Final account state:"

Get-ADUser -Identity $Username |
Select-Object Name, SamAccountName, Enabled, DistinguishedName

Get-ADPrincipalGroupMembership -Identity $Username |
Select-Object Name
