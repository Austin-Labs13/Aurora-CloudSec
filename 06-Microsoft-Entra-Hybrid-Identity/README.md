# Microsoft Entra ID – Hybrid Identity & Security

## Overview

This phase of the Aurora CloudSec project extended the existing on-premises Active Directory environment into Microsoft Entra ID, creating a hybrid identity environment using Microsoft Entra Connect Sync.

The goal was not only to synchronize identities to the cloud, but to understand and validate how identity administration changes in a hybrid environment. This included synchronization scope, Password Hash Synchronization (PHS), security groups, administrative roles, MFA, authentication monitoring, and identity lifecycle management.

The environment was tested through practical administrative and troubleshooting scenarios rather than configuration alone. Changes were made within on-premises Active Directory, synchronized to Microsoft Entra ID, and then verified using Entra administrative portals, sign-in logs, audit logs, and synchronization tools.

Key areas covered included:

- Microsoft Entra Connect Sync
- Hybrid identity and source of authority
- Organizational Unit (OU) filtering
- Password Hash Synchronization
- User and security group synchronization
- Role-Based Access Control (RBAC)
- Least-privilege administration
- Multi-Factor Authentication (MFA)
- Entra sign-in and audit logs
- Joiner, Mover, Leaver, and recovery scenarios
- Hybrid identity troubleshooting

## Environment

The hybrid identity environment consisted of an existing Windows Server Active Directory domain integrated with a Microsoft Entra ID tenant.

### On-Premises Infrastructure

- **Domain:** `aurora.local`
- **Domain Controller:** `AUR-DC01`
- **File Server:** `AUR-FS01`
- **Windows Client:** `AUR-CL01`
- **Directory Service:** Active Directory Domain Services (AD DS)
- **Synchronization:** Microsoft Entra Connect Sync

### Microsoft Entra ID

Microsoft Entra ID was introduced as the cloud identity platform for the Aurora environment. Selected on-premises identities and security groups were synchronized from Active Directory rather than recreated manually in the cloud.

This created a hybrid identity model where Active Directory remained the authoritative source for synchronized objects while Microsoft Entra ID provided cloud identity, authentication, administrative roles, and security monitoring.

## Hybrid Identity Architecture

Microsoft Entra Connect was installed and configured to synchronize selected Active Directory objects from `aurora.local` into the Aurora Microsoft Entra tenant.

The environment followed this identity flow:

`On-Premises Active Directory → Microsoft Entra Connect → Microsoft Entra ID`

Rather than synchronizing the entire Active Directory environment, Organizational Unit filtering was used to control which identities were included in the synchronization scope.

This provided several benefits:

- Reduced unnecessary cloud identities
- Maintained control over which objects entered Microsoft Entra ID
- Demonstrated synchronization scope as part of identity lifecycle management
- Preserved Active Directory as the source of authority for synchronized identities

<img width="940" height="826" alt="Screenshot (1392)" src="https://github.com/user-attachments/assets/cf0dd83f-66ca-4a46-a483-307f62af25cc" />
*Microsoft Entra Connect configuration linking the on-premises `aurora.local` Active Directory environment with Microsoft Entra ID.*

## Microsoft Entra Connect Sync

Microsoft Entra Connect Sync was configured on `AUR-DC01` to provide synchronization between the on-premises Active Directory environment and Microsoft Entra ID.

Rather than creating separate cloud identities manually, existing Active Directory users and security groups could be synchronized into Entra ID and managed through a hybrid identity model.

### Organizational Unit Filtering

OU filtering was configured to limit synchronization to objects that required a cloud identity.

This was an intentional design decision. Synchronizing only selected OUs reduced unnecessary cloud objects and provided greater control over the identity lifecycle.

The synchronization scope included the operational user OUs required by the Aurora environment, while infrastructure and administrative OUs that did not require cloud identities were excluded.

This filtering later became important during lifecycle testing, where moving a user outside the synchronization scope demonstrated how Entra Connect responds when an on-premises identity is no longer eligible for synchronization.

### Password Hash Synchronization

Password Hash Synchronization (PHS) was enabled as the authentication method for synchronized users.

PHS allows users to authenticate to Microsoft Entra ID using credentials derived from their on-premises Active Directory password. A cryptographically transformed hash of the existing AD password hash is synchronized rather than the user's plaintext password.

This provided Aurora with a straightforward hybrid authentication model while allowing Active Directory to remain the source of authority for synchronized user credentials.

Synchronization was validated using both scheduled synchronization and manually initiated delta synchronization cycles during testing.

## User and Security Group Synchronization

Following the initial Microsoft Entra Connect synchronization, selected Active Directory users and security groups were successfully provisioned into Microsoft Entra ID.

The synchronized security groups included:

- Finance Staff
- HR Staff
- IT Support
- Sales Staff

Group membership continued to be managed within on-premises Active Directory. Changes made to membership were then propagated to Microsoft Entra ID through Entra Connect.

This demonstrated an important characteristic of the hybrid environment: although synchronized objects were visible within Entra ID, their authoritative configuration remained within the on-premises Active Directory environment.

### Synchronization Validation

Synchronization was validated by comparing users, groups, and group memberships between Active Directory and Microsoft Entra ID.

Delta synchronization cycles were also manually initiated during testing to verify changes without waiting for the next scheduled synchronization cycle.

The Entra Connect synchronization service and scheduler were later checked to confirm that synchronization remained operational:

- `ADSync` service: **Running**
- `SyncCycleEnabled`: **True**
- `MaintenanceEnabled`: **True**
- `StagingModeEnabled`: **False**
- `SchedulerSuspended`: **False**
- `SyncCycleInProgress`: **False**

These checks confirmed that Entra Connect was running normally and that scheduled synchronization remained enabled.

<img width="972" height="867" alt="Screenshot (1403)" src="https://github.com/user-attachments/assets/d041a21b-8348-4dae-a5d0-5b3e86e47034" />

![Synchronized security groups](screenshots/entra-synchronized-security-groups.png)

*On-premises Active Directory security groups successfully synchronized into Microsoft Entra ID through Entra Connect.*

## Source of Authority in Hybrid Identity

A key part of testing the hybrid environment was determining where synchronized identities should be administered.

Users and groups synchronized through Microsoft Entra Connect appeared within Microsoft Entra ID, but their on-premises Active Directory objects remained the authoritative source for synchronized attributes.

### Testing the Source of Authority

Administrative changes were tested from both sides of the hybrid environment.

When attempting to modify synchronized identity information directly within Microsoft Entra ID, certain attributes could not be managed from the cloud because the object was sourced from Windows Server Active Directory.

The appropriate workflow was therefore:

`Active Directory → Modify Object → Entra Connect Sync → Microsoft Entra ID`

Changes were made to the corresponding object in Active Directory and a delta synchronization was initiated. The updated information was then verified within Microsoft Entra ID.

This demonstrated that synchronization does not make Entra ID the authoritative directory for an on-premises synchronized identity. Administrators must understand the object's source of authority before making identity changes.

### Administrative Significance

Understanding source of authority prevents conflicting administration and helps determine where identity issues should be investigated.

For the Aurora hybrid environment:

- On-premises AD remained authoritative for synchronized users and groups.
- Entra Connect propagated eligible directory changes to Microsoft Entra ID.
- Cloud-specific configuration, such as Entra administrative role assignments, remained managed within Entra ID.
- Synchronization scope could directly affect whether an on-premises identity continued to exist in the cloud.

- ## Role-Based Access Control and Least Privilege

Role-Based Access Control (RBAC) was implemented to avoid using the Global Administrator role for routine administrative tasks.

Rather than assigning broad privileges to every administrative account, separate accounts were given roles aligned with their intended responsibilities.

### Administrative Role Design

The following administrative model was implemented:

| Account | Entra Role | Purpose |

| Primary Administrator | Global Administrator | Full tenant administration |
| Aurora Cloud Admin | Hybrid Identity Administrator | Hybrid identity and Entra Connect administration |
| Aurora Helpdesk Admin | User Administrator | User administration and helpdesk testing |

This provided a practical demonstration of the principle of least privilege. Administrative identities were granted the permissions required for their function without automatically receiving unrestricted tenant access.

### RBAC Validation

The assigned roles were tested rather than relying solely on successful role assignment.

The Aurora Helpdesk Admin account was used in a separate browser session to verify the permissions available to a User Administrator. Administrative actions permitted by the role could be accessed, while operations outside the account's assigned privileges remained restricted.

The Hybrid Identity Administrator role was assigned separately to Aurora Cloud Admin, providing administrative capability for hybrid identity services without requiring the account to hold Global Administrator.

This separation reduced unnecessary privilege and demonstrated how Entra roles can be aligned with different administrative responsibilities.


<img width="932" height="896" alt="Screenshot (1415)" src="https://github.com/user-attachments/assets/10a3c875-942b-4317-afd3-0bbd9e8aac37" />

*Aurora Cloud Admin assigned the Hybrid Identity Administrator role, providing dedicated hybrid identity administration without relying on Global Administrator.*

## Multi-Factor Authentication and Authentication Security

Multi-Factor Authentication (MFA) was tested as part of securing administrative access to the Aurora Microsoft Entra environment.

Microsoft Security Defaults were enabled within the tenant, providing baseline identity protections including MFA requirements for administrative accounts.

### MFA Registration and Validation

The Aurora Helpdesk Admin account was used to test the authentication process from a separate private browser session.

During the first successful sign-in, Microsoft Entra required the account to register an additional authentication method. Microsoft Authenticator was configured and the registration process was completed successfully.

Authentication activity was then reviewed through Microsoft Entra sign-in logs.

The authentication details confirmed that:

- Security Defaults were applied to the authentication request.
- MFA requirements were enforced for the administrative account.
- The MFA requirement was successfully satisfied.
- Authentication events could be investigated through Entra sign-in telemetry.

This demonstrated that creating an administrative role was only one part of securing privileged access. Authentication controls and sign-in monitoring were also required to protect administrative identities.

## Monitoring and Audit Logs

Microsoft Entra sign-in and audit logs were used to monitor identity activity and investigate changes within the hybrid environment.

### Sign-In Monitoring

Interactive sign-in events were reviewed to understand how authentication activity is recorded within Microsoft Entra ID.

The sign-in logs provided visibility into information including:

- User principal name
- Authentication status
- Authentication requirements
- Sign-in date and time
- Application and session information
- Device and browser information
- Failure details and error codes

Rather than treating failed authentication as a generic login problem, individual sign-in events could be opened and investigated to determine where the authentication process failed.

### Audit Log Investigation

Entra audit logs were also used to investigate directory changes generated through the hybrid environment.

During security group testing, membership was changed within on-premises Active Directory and synchronized through Microsoft Entra Connect.

The resulting Entra audit activity recorded the directory change, including the affected object, activity type, status, and initiating service.

This demonstrated how cloud-side audit telemetry can be used to reconstruct administrative and synchronization activity even when the original change occurred within the on-premises environment.

<img width="945" height="925" alt="Screenshot (1404)" src="https://github.com/user-attachments/assets/5c92c8ac-d477-4768-9e94-2c37d0b9303d" />



## Authentication Troubleshooting Case Study

During testing of the Aurora Helpdesk Admin account, an authentication issue occurred where the account could not successfully sign in despite the expected credentials being used.

Rather than repeatedly changing the account configuration, the issue was investigated using Microsoft Entra sign-in and audit telemetry.

### Initial Validation

Before investigating the authentication logs, several basic identity conditions were verified:

- The user account existed in Microsoft Entra ID
- The User Principal Name (UPN) was correct
- The account was enabled
- The expected administrative role was assigned
- A new password had been set by an administrator

Despite these checks, authentication continued to fail.

### Sign-In Log Investigation

The failed authentication attempt was located within Microsoft Entra sign-in logs.

Inspection of the event showed that Microsoft Entra was rejecting the authentication attempt rather than the failure being caused by a missing or disabled account.

The sign-in event returned error code:

`50126`

This indicated that the credentials presented during authentication could not be validated.

At this point, the investigation moved from checking account configuration to verifying whether the administrative password reset had actually been processed.

### Audit Log Correlation

Microsoft Entra audit logs were reviewed for the Aurora Helpdesk Admin account.

A corresponding **Reset password (by admin)** event was identified with a status of **Success**, confirming that Entra had successfully processed the administrative password reset.

Correlating the sign-in and audit events demonstrated an important troubleshooting principle: a successful administrative action does not necessarily mean that a subsequent authentication attempt will succeed.

Using both log sources allowed the investigation to distinguish between:

- Account configuration issues
- Administrative action failures
- Authentication failures
- Credential-related problems

### Outcome

The account was ultimately able to authenticate successfully and complete the required MFA process.

The incident demonstrated a log-driven troubleshooting workflow rather than relying on repeated configuration changes:

`Verify identity → Reproduce failure → Inspect sign-in logs → Identify error → Correlate audit activity → Retest authentication`

This provided practical experience using Microsoft Entra telemetry to investigate an identity and authentication issue.

<img width="966" height="876" alt="Screenshot (1428)" src="https://github.com/user-attachments/assets/bd65fec2-c55a-4806-9ba9-a8e979a48fb8" />
<img width="949" height="930" alt="Screenshot (1429)" src="https://github.com/user-attachments/assets/8312ab14-b09d-469d-b503-30cbbd40b25a" />



## Identity Lifecycle Management

A Joiner–Mover–Leaver scenario was performed to test how an employee identity could be managed throughout its lifecycle across Active Directory and Microsoft Entra ID.

A fictional employee, **Quin Lacie**, was used for the scenario.

### Joiner

Quin was initially created as a new employee within the Sales department in on-premises Active Directory.

The onboarding process included:

- Creating the user within the appropriate Sales OU
- Adding the account to the `Sales Staff` security group
- Initiating an Entra Connect delta synchronization
- Verifying that the identity appeared within Microsoft Entra ID
- Verifying synchronized security group membership

This demonstrated that new employee identities could be provisioned from the existing on-premises directory into the cloud without manually recreating the user within Entra ID.

### Mover

A departmental transfer from **Sales to Finance** was then simulated.

The identity was moved into the appropriate Finance OU and its security group membership was changed from `Sales Staff` to `Finance Staff`.

Following a delta synchronization, the changes were verified within Microsoft Entra ID.

This demonstrated that changes to an existing employee should continue to be performed at the authoritative identity source and allowed Entra Connect to propagate the updated state into the cloud.

### Leaver

An employee offboarding scenario was then considered.

Rather than immediately deleting the Active Directory account, the intended offboarding process was:

`Disable account → Remove unnecessary group memberships → Move to Disabled Users OU → Synchronize`

The `Disabled Users` OU had intentionally been excluded from the Microsoft Entra Connect synchronization scope.

When Quin was moved from a synchronized OU into the non-synchronized `Disabled Users` OU and a delta synchronization was performed, the corresponding cloud identity was removed from the active Entra user directory and appeared within **Deleted users**.

This demonstrated that OU filtering is not simply an initial synchronization setting. Synchronization scope can directly affect the lifecycle of an existing cloud identity.

### Recovery Testing

A recovery scenario was then performed to simulate an incorrect offboarding decision.

Rather than restoring the identity directly within Microsoft Entra ID, the issue was corrected at the authoritative source by returning the on-premises account to the appropriate synchronized OU and restoring its required configuration.

Following synchronization, the identity returned to the active Microsoft Entra user directory.

This reinforced the importance of understanding source of authority when troubleshooting hybrid identities.

### Outcome

The lifecycle exercise demonstrated a complete hybrid identity workflow:

`Joiner → Mover → Leaver → Recovery`

It also showed how Active Directory OU placement, security group membership, Entra Connect synchronization scope, and Microsoft Entra ID are interconnected throughout an employee's identity lifecycle.

## Troubleshooting Case Study – Password Hash Synchronization Health Alert

During operation of the hybrid identity environment, Microsoft Entra generated a critical health alert for `AUR-DC01` stating that the **Password Hash Synchronization heartbeat had been skipped for the previous 120 minutes**.

The alert indicated that Password Hash Synchronization had not recently communicated with Microsoft Entra ID and warned that password changes might not be synchronized to the cloud.

Rather than immediately reconfiguring Entra Connect, the alert was treated as a troubleshooting incident and investigated to determine whether Password Hash Synchronization was actually unhealthy.

### Initial Health Checks

The Microsoft Entra Connect synchronization service and scheduler were checked on `AUR-DC01`.

The following state was confirmed:

- `ADSync` service was running
- `SyncCycleEnabled`: **True**
- `MaintenanceEnabled`: **True**
- `StagingModeEnabled`: **False**
- `SchedulerSuspended`: **False**
- `SyncCycleInProgress`: **False**

Regular directory synchronization was also functioning, indicating that Entra Connect itself was operational.

### Password Hash Synchronization Diagnostics

The built-in ADSync diagnostics module was then used to investigate Password Hash Synchronization directly.

The diagnostic was initiated from an elevated PowerShell session:

`Import-Module ADSyncDiagnostics`

`Invoke-ADSyncDiagnostics -PasswordSync`

The resulting diagnostic confirmed that:

- Password Hash Synchronization cloud configuration was enabled
- Password Hash Synchronization was enabled for the `aurora.local` AD connector
- A recent Password Hash Synchronization heartbeat was detected
- Password synchronization had successfully occurred
- The `aurora.local` domain was reachable

These results provided direct evidence that Password Hash Synchronization was functioning despite the earlier health alert.

### Analysis

The investigation demonstrated the importance of validating an alert against the current state of the affected service.

The original alert was legitimate telemetry indicating that a heartbeat had not been observed within the expected period. However, subsequent diagnostic evidence showed that the synchronization service had recovered and Password Hash Synchronization was operating normally.

Rather than making unnecessary configuration changes based solely on the alert, service state, scheduler configuration, synchronization activity, connectivity, and Password Hash Synchronization diagnostics were examined first.

### Outcome

No Entra Connect reconfiguration was required.

The incident was resolved through verification of the current synchronization state and demonstrated a structured troubleshooting workflow:

`Alert → Verify service health → Check scheduler → Run targeted diagnostics → Validate heartbeat and synchronization → Confirm recovery`

This exercise provided practical experience investigating Microsoft Entra hybrid identity health alerts and distinguishing an active service failure from a recovered or transient synchronization condition.


<img width="940" height="714" alt="Screenshot (1406)" src="https://github.com/user-attachments/assets/10654cd8-60ad-4e19-acdc-237370436f0b" />

*Microsoft Entra health alert reporting that the Password Hash Synchronization heartbeat for `AUR-DC01` had been skipped for 120 minutes.*


<img width="964" height="851" alt="Screenshot (1410)" src="https://github.com/user-attachments/assets/07b9a4dc-8509-4945-a240-b8c4bb6b4dd6" />


*ADSync diagnostics confirming that Password Hash Synchronization was enabled, a recent heartbeat was detected, password synchronization had succeeded, and the `aurora.local` domain was reachable.*

## Outcome

The Aurora environment now operates as a hybrid identity environment integrating the existing `aurora.local` Active Directory domain with Microsoft Entra ID.

Microsoft Entra Connect provides controlled synchronization of selected users and security groups, with Password Hash Synchronization supporting cloud authentication while Active Directory remains the authoritative source for synchronized identities.

The completed environment includes:

- Controlled user and security group synchronization
- Organizational Unit-based synchronization scope
- Password Hash Synchronization
- Microsoft Entra administrative RBAC
- Dedicated administrative accounts with separated privileges
- Multi-Factor Authentication for administrative access
- Microsoft Entra sign-in and audit monitoring
- Joiner, Mover, Leaver, and identity recovery processes
- Entra Connect health and synchronization monitoring
- PowerShell-based synchronization diagnostics

This establishes the identity foundation for future security monitoring and SOC-focused work within the Aurora CloudSec environment.
