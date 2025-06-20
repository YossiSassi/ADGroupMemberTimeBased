# ADGroupMemberTimeBased
###  (aka 'Mini-PAM') ⏳💻
a <b>PowerShell module for managing Time-Based Group Membership - Add/Get temporary group members</b>.<br>
This set of bundled cmdlets allows you to perform 'Privileged Access Management' with temporary/time-based group membership tasks (account is automatically removed from the group after XX minutes *). Sort of a 'Simple Living-off-the-land PAM', harnessing Active Directory's TTL group membership optional feature</b>.
Includes functions to test the pre-requisites, add a TTL member to a group and get expiration information of temporary member(s), for a specific group or the entire groups in the AD domain.<br>
*<b> Note:</b> Technically, you can set the TTL for X seconds, or even Hours. It's fairly easy to change it inside the script.<br><br>
By default, this feature is not enabled. You need to Enable it Forest-Wide. The script(s) provide the option to Enable the feature. You also need to have Domain/Forest functional level of Windows 2016 or higher. The script(s) also verifies those conditions are met.<br><BR>
The module includes 5 functions / cmdlets:<br>
The cmdlets <b>Test-ADGroupMemberTimeBasedPreRequisites</b>, <b>Get-ADGroupMemberTimeBased</b> and <b>Get-ADGroupMemberTimeBasedReport</b> do not require special permissions.<br>
The cmdlets <b>Add-ADGroupMemberTimeBased</b> and <b>Add-ADGroupMemberTimeBased_GUI</b> require permissions to add member to the specified group.<br><br>
To begin using the cmdlets inside the module, you'll need first to import it, of course:
```
Import-Module .\ADGroupMemberTimeBased.psm1
```
## Test-ADGroupMemberTimeBasedPreRequisites
<BR>This command validates the pre-requisites in the domain and forest/Configuration-wide, before you can add a time-based group member.<br>
It checks domain & forest functional levels and verifies that 'Privileged Access Management Feature' is enabled.<br>
It can also optionally Enable the 'Privileged Access Management' Feature forest-wide.<br>
<br>
EXAMPLE:
```
Test-ADGroupMemberTimeBasedPreRequisites
```
![Sample results](/screenshots/adgroupmembertimebased_ss1.png) <br><br>
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
.SAMPLE SCREENSHOT:<br>
Get all temporary group members in the domain (shows just 1 account). Then add user JaneD to the distribution group "Dev_Email" for 10 minutes. Then run the report of temporary group members again (showing 2 accounts).<br>
![Sample results](/screenshots/adgroupmembertimebased_ss2.png) <br><br>
### Add-ADGroupMemberTimeBased_GUI
<br>The GUI based version (thanks to Adi Machluf for the initiative!) to add a Time-Based Group Member, the 'Mini-PAM' GUI, based on windows form.<br>
Note that this function assumes that the forest-wide pre-requisites are met. It simply adds a time-based member to a group :wink:<br>
Just launch the GUI by running the command:<br>
```
Add-ADGroupMemberTimeBased_GUI
```
![Sample results](/screenshots/adgroupmembertimebased_ss3.png) <br><br>
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
![Sample results](/screenshots/adgroupmembertimebased_ss4.png) <br><br>
### Get-ADGroupMemberTimeBasedReport
<br>Gets all temporary members of all Active Directory groups in the domain, and shows the time remaining until the membership expires.<br>
<br>
.EXAMPLE<br>
Get all temporary group members in all Active Directory groups in the domain:<br>
```
Get-ADGroupMemberTimeBasedReport
```
![Sample results](/screenshots/adgroupmembertimebased_ss5.png) <br>

### Some final thoughts about detection (and Forensic investigations)
The addition (and especially removal/'disappearing') of temporary group members can be a particularly elusive operation for SecOps.<BR>
For example: if you add a non-privileged member to 'Domain Admins' for 5 minutes - and even perform some privileged tasks with that account - the account won't receive admincount=1, and the removal won't appear in monitoring products, only the add to group.<br><br>
So while at it - I updated my forensic investigation script <b>Get-ADGroupChanges</b> for getting add/remove history of group members in all AD groups, since the dawn of your domain :wink:<br>
v1.5.3 of Get-ADGroupChanges includes identifying temporary members (TTL operations) - It took a small research since removal does not appear in logs, AND no replication metadata value of RemoveDate exists. The updated tool identifies there was an addition of temporary member that expired - See <b><a title="Get-ADGroupChanges - https://github.com/YossiSassi/Get-ADGroupChanges" href="https://github.com/YossiSassi/Get-ADGroupChanges" target="_blank">Get-ADGroupChanges - https://github.com/YossiSassi/Get-ADGroupChanges</a></b>)<BR><BR>
<b>NOTE:</b> Get-ADGroupChanges is part of the <b><a title="Hacktive Directory Forensics Toolkit" href="https://github.com/YossiSassi/hAcKtive-Directory-Forensics" target="_blank">Hacktive Directory Forensics Toolkit</a></b> which you should check, if you haven't already done so.<br>
🙉🙈🙊
