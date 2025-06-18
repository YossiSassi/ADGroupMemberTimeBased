# ADGroupMemberTimeBased
a <b>PowerShell module for managing Time-Based Group Membership - Add/Get temporary group members</b>.<br>
This set of bundled cmdlets allows you to perform 'Privileged Access Management' with temporary/time-based group membership tasks (account is automatically removed from the group after XX minutes). Sort of a 'Simple Living-off-the-land PAM', harnessing Active Directory's TTL group membership optional feature</b>.
Includes functions to test the pre-requisites, add a TTL member to a group and get expiration information of temporary member(s), for a specific group or the entire groups in the AD domain.<br>
(NOTE: for a history of adding/removing members from groups, including TTL members, check out <b><a title="Get-ADGroupChanges - https://github.com/YossiSassi/Get-ADGroupChanges" href="https://github.com/YossiSassi/Get-ADGroupChanges" target="_blank">Get-ADGroupChanges - https://github.com/YossiSassi/Get-ADGroupChanges</a></b>)<BR><BR>
The module includes 4 functions / cmdlets:<br><br>
The cmdlets <b>Test-ADGroupMemberTimeBasedPreRequisites</b>, <b>Get-ADGroupMemberTimeBased</b> and <b>Get-ADGroupMemberTimeBasedReport</b> do not require special permissions.<br>
The cmdlet <b>Add-ADGroupMemberTimeBased</b> requires permissions to add member to the specified group.<br><br>
## Test-ADGroupMemberTimeBasedPreRequisites
<BR>The function validates the pre-requisites in the domain and forest/Configuration-wide, before you can add a time-based group member.<br>
It checks domain & forest functional levels and verifies that 'Privileged Access Management Feature' is enabled.<br>
It can also optionally Enable the 'Privileged Access Management' Feature forest-wide.<br>
<br>
EXAMPLE:
```
Test-ADGroupMemberTimeBasedPreRequisites
```
### Add-ADGroupMemberTimeBased
<br>Adds a Time-Based Group Member, temporarily to an Active Directory group, using the TTL optional feature of AD (Windows2016ForestMode+).<br>
The function validates the pre-requisites, adds a time-based member to a group, and gets the status the temporarily added member in order to verify success.<br>
<br>
.PARAMETER GroupName<br>
The domain group name, to which you want to add a temporary member.
<br><br>
.PARAMETER MemberSamAccountName<br>
The AD Account name (e.g. administrator, PC1$) to be temporarily added to the AD group.
<br><br>
.PARAMETER TTLinMinutes<br>
The duration of the account's membership in the specified group, in minutes.
<br><br>
.EXAMPLE<br><br>
Temporarily add user MonitorSvc to the group "Domain Admins" for 30 minutes only<br>
```
Add-ADGroupMemberTimeBased -GroupName "domain admins" -MemberSamAccountName MonitorSvc -TTLinMinutes 30
```
### Get-ADGroupMemberTimeBased
<br>Lists an Active Directory group's membership, including its temporary members which were added using the TTL optional feature of AD.<br>
The function gets the status of the temporarily added member(s) and shows the time remaining until the membership expires.<br>
<br>
.PARAMETER GroupName<br>
The domain group to list its members, including temporary/expiring members
<br><br>
.EXAMPLE<br>
List group members of "Domain Admins", including temporary accounts and their TTL remaining.
<br>
```
Get-ADGroupMemberTimeBased -GroupName "domain admins"
```
### Get-ADGroupMemberTimeBasedReport
<br>Gets all temporary members of all Active Directory groups in the domain, and shows the time remaining until the membership expires.<br>
<br>
.EXAMPLE<br>
Get all temporary group members in all Active Directory groups in the domain:<br>
```
Get-ADGroupMemberTimeBasedReport
```
