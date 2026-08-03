# aurora-ad-file-shares
Windows Server Active Directory file shares using AGDLP and NTFS permissions.

## Overview

Built secure departmental file shares in a Windows Server 2022 Active Directory environment using Microsoft's AGDLP permission model. Access is managed through Active Directory security groups rather than individual user permissions, providing a scalable and maintainable access control solution.

---

## Technologies & Tools Used

- Windows Server 2022
- Windows 11 Pro
- Active Directory Domain Services (AD DS)
- SMB File Sharing
- NTFS Permissions
- Active Directory Security Groups
- VMware Workstation

---

## Objectives

- Create departmental file shares
- Configure SMB share permissions
- Implement NTFS permissions
- Apply the AGDLP permission model
- Follow the Principle of Least Privilege
- Validate access using departmental user accounts

---

## Validation

Confirmed NTFS permissions by testing access with users from different departments.

---

## Screenshots

### Active Directory Security Groups

Created Global Security Groups for each department to manage permissions through group membership rather than assigning access directly to user accounts.


> <img width="1020" height="781" alt="Screenshot (857)" src="https://github.com/user-attachments/assets/eee7c276-ae1c-4d84-805c-76ba11daec2e" />

### NTFS Permissions

Configured NTFS permissions so only the appropriate department security group has Modify access. Administrators and SYSTEM retain Full Control.

> <img width="1074" height="843" alt="Screenshot (858)" src="https://github.com/user-attachments/assets/2cf55a13-0d06-43bd-bdaf-d9447ad17933" />



### Share Configuration

> <img width="1053" height="804" alt="Screenshot (860)" src="https://github.com/user-attachments/assets/a5513c46-ddca-46f9-972f-a74b5fb3dcf2" />


### Validation

> <img width="1336" height="703" alt="Screenshot (862)" src="https://github.com/user-attachments/assets/56e5ea04-90be-4564-92f6-2d07090c1a3f" />

