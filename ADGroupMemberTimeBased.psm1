# PowerShell module for managing Time-Based Group Membership - temporarily get/add group members using the TTL optional feature of AD (Windows2016ForestMode+)
# Includes functions to test the pre-requisites, adding a time-based member to a group and getting status on temporary member(s) of a group
# Module Version: 1.0.0
# Comments to 1nTh35h311 (yossis@protonmail.com)

function Test-ADGroupMemberTimeBasedPreRequisites {
<#
.DESCRIPTION
The function validates the pre-requisites in the domain and forest/Configuration-wide, before you can add a time-based group member.
It checks domain & forest functional levels and verifies that 'Privileged Access Management Feature' is enabled.
It can also optionally Enable the 'Privileged Access Management' Feature forest-wide.

ADGroupMemberTimeBased Function: Test-ADGroupMemberTimeBasedPreRequisites
Author: 1nTh35h311 (yossis@protonmail.com, @Yossi_Sassi)
Version: 1.0.0
Required Dependencies: ActiveDirectory module

.SYNOPSIS
The function validates the pre-requisites in the domain and forest/Configuration-wide, before you can add a time-based group member.

.EXAMPLE
Test-ADGroupMemberTimeBasedPreRequisites
#>

#Requires -modules ActiveDirectory

# First, Verify supported Domain and Forest functional levels
$UnsupportedModes = '2000','2003','2008','2012';
$ForestMode = (Get-ADForest).ForestMode;
$DomainMode = (Get-ADDomain).DomainMode;

$UnsupportedModes | foreach {
    if ($ForestMode -like "*$_*") {
            Write-Host "[!] Forest Functional Level '$ForestMode' does Not support Time-Based Group membership." -ForegroundColor Yellow;
            break
        }
}

$UnsupportedModes | foreach {
    if ($DomainMode -like "*$_*") {
            Write-Host "[!] Forest Functional Level '$DomainMode' does Not support Time-Based Group membership." -ForegroundColor Yellow;
            break
        }
}

# Continue with supported Forest Functional level
Write-Host "[x] Forest Functional Level '$ForestMode' is Ok for Time-Based group membership operations." -ForegroundColor Green

# Check if PAM optional feature is enabled
$PAMstatus = Get-ADOptionalFeature -filter "name -eq 'privileged access management feature'";

if ($PAMstatus.EnabledScopes.length -lt 1) {
	Write-Host "[!] PAM Optional Feature is Not enabled.`n" -ForegroundColor Yellow;

	# Suggest how to Enable feature if Domain/Forest levels are OK
    $ForestFQDN = $((Get-ADDomain).Forest);
    $choice = Read-Host "[?] Do you want to Enable 'Privileged Access Management Feature' for the entire $ForestFQDN Forest?`n(YES to Continue, any other key to skip)";

    if ($choice -eq "YES") {
	    Enable-ADOptionalFeature 'Privileged Access Management Feature' -Scope ForestOrConfigurationSet -Target $ForestFQDN;
	    if ($?) 
		    {
                Write-Host "[x] 'Privileged Access Management Feature' Enabled successfully for Forest $ForestFQDN." -ForegroundColor Cyan
            }
	    elseif ($Error[0].exception -like "*specified method is not supported*") {
                "[!] Ensure forestMode 2016 or higher is Set, and has replicated to all the forest.";
                break
            }
        }
    }
else
{
    Write-Host "[x] Time-Based Group membership feature is Enabled in the Forest Level." -ForegroundColor Green
}

}

function Add-ADGroupMemberTimeBased {
<#
.DESCRIPTION
Adds a Time-Based Group Member, temporarily to an Active Directory group, using the TTL optional feature of AD (Windows2016ForestMode+).
The function validates the pre-requisites, adds a time-based member to a group, and gets the status the temporarily added member in order to verify success.

ADGroupMemberTimeBased Function: Add-ADGroupMemberTimeBased
Author: 1nTh35h311 (yossis@protonmail.com, @Yossi_Sassi)
Version: 1.0.0
Required Dependencies: ActiveDirectory module

.SYNOPSIS
Adds a Time-Based Group Member, temporarily to an Active Directory group, using the TTL optional feature of AD (Windows2016ForestMode+).
The function validates the pre-requisites, adds a time-based member to a group, and gets the status the on temporary added member to verify.

.PARAMETER GroupName
The domain group name, to which you want to add a temporary member.

.PARAMETER MemberSamAccountName
The AD Account name (e.g. administrator, PC1$) to be temporarily added to the AD group.

.PARAMETER TTLinMinutes
The duration of the account's membership in the specified group, in minutes.

.EXAMPLE
Temporarily add user MonitorSvc to the group "Domain Admins" for 30 minutes only

Add-ADGroupMemberTimeBased -GroupName "domain admins" -MemberSamAccountName MonitorSvc -TTLinMinutes 30
#>

#Requires -modules ActiveDirectory

param (
    [cmdletbinding()]
    [Parameter(Mandatory = $true)]
	[string]$GroupName,
    [Parameter(Mandatory = $true)]
	[string]$MemberSamAccountName,
    [Parameter(Mandatory = $true)]
	[int]$TTLinMinutes
)

# First, Verify supported Domain and Forest functional levels
$UnsupportedModes = '2000','2003','2008','2012';
$ForestMode = (Get-ADForest).ForestMode;
$DomainMode = (Get-ADDomain).DomainMode;

$UnsupportedModes | foreach {
    if ($ForestMode -like "*$_*") {
            Write-Host "[!] Forest Functional Level '$ForestMode' does Not support Time-Based Group membership." -ForegroundColor Yellow;
            break
        }
}

$UnsupportedModes | foreach {
    if ($DomainMode -like "*$_*") {
            Write-Host "[!] Forest Functional Level '$DomainMode' does Not support Time-Based Group membership." -ForegroundColor Yellow;
            break
        }
}

# Continue with supported Forest Functional level
Write-Host "[x] Forest Functional Level '$ForestMode' is Ok for Time-Based group membership operations." -ForegroundColor Green

# Check if PAM optional feature is enabled
$PAMstatus = Get-ADOptionalFeature -filter "name -eq 'privileged access management feature'";

if ($PAMstatus.EnabledScopes.length -lt 1) {
	Write-Host "[!] PAM Optional Feature is Not enabled.`n" -ForegroundColor Yellow;

	# Suggest how to Enable feature if Domain/Forest levels are OK
    $ForestFQDN = $((Get-ADDomain).Forest);
    $choice = Read-Host "[?] Do you want to Enable 'Privileged Access Management Feature' for the entire $ForestFQDN Forest?`n(YES to Continue, any other key to skip)";

    if ($choice -eq "YES") {
	    Enable-ADOptionalFeature 'Privileged Access Management Feature' -Scope ForestOrConfigurationSet -Target $ForestFQDN;
	    if ($?) 
		    {
                Write-Host "[x] 'Privileged Access Management Feature' Enabled successfully for Forest $ForestFQDN." -ForegroundColor Cyan
            }
	    elseif ($Error[0].exception -like "*specified method is not supported*") {
                "[!] Ensure forestMode 2016 or higher is Set, and has replicated to all the forest.";
                break
            }
        }
    }
else
{
    Write-Host "[x] Time-Based Group membership feature is Enabled in the Forest Level." -ForegroundColor Green
}

# Set group, member & TTL in minutes
Add-ADGroupMember -Identity $GroupName -Members $MemberSamAccountName -MemberTimeToLive $(New-TimeSpan -Minutes $TTLinMinutes);

if ($?) {
    Write-Host "`[x] Successfully added $MemberSamAccountName as Temporary member of group $GroupName" -ForegroundColor Cyan
}
    elseif ($Error[0].exception -like "*parameter*incorrect*") {
        Write-Warning "[!] An error occured. Ensure the Domain/Forest are setup correctly and TTL enabled/'PAM Feature'.";
        break
}

# Get the group members
$Members = Get-ADGroup $GroupName -Property member –ShowMemberTimeToLive | select -ExpandProperty member;

if ($Members) {
    "`n[x] Updated group members:"
    $Members
}

# Show only members with TTL, and their TTL (sort of a 'sanity check')
"`n[x] Temporary group members:"
$TTLMembers = $Members | where {$_ -like "*<TTL=*>*"}
if ($TTLMembers)
	{
	$TTLMembers | ForEach-Object {
        $MinutesLeft = $($($_.split(",")[0].replace('<TTL=','').replace('>',''))/60);
        #$Split = $_.Split(",");
        #$TTLmemberDN = $_.Split(",")[1..$($Split.Count - 1)] -join ',';
        #$TTLmemberDN
        Write-Host "Account $MemberSamAccountName has $([math]::Round($MinutesLeft,1)) minutes left as member of $GroupName." -ForegroundColor Yellow
    }
  }
}

function Get-ADGroupMemberTimeBased {
<#
.DESCRIPTION
Lists an Active Directory group's membership, including its temporary members which were added using the TTL optional feature of AD.
The function gets the status of the temporarily added member(s) and shows the time remaining until the membership expires.

ADGroupMemberTimeBased Function: Get-ADGroupMemberTimeBased
Author: 1nTh35h311 (yossis@protonmail.com, @Yossi_Sassi)
Version: 1.0.0
Required Dependencies: ActiveDirectory module

.SYNOPSIS
Gets the status of temporarily added member(s) to an AD group, and shows the time remaining until the membership expires.

.PARAMETER GroupName
The domain group to list its members, including temporary/expiring members

.EXAMPLE
List group members of "Domain Admins", including temporary accounts and their TTL remaining.

Get-ADGroupMemberTimeBased -GroupName "domain admins"
#>

#Requires -modules ActiveDirectory

param (
    [cmdletbinding()]
    [Parameter(Mandatory = $true)]
	[string]$GroupName
)

# Get the group members
$Members = Get-ADGroup $GroupName -Property member –ShowMemberTimeToLive | select -ExpandProperty member;

if (!$?) {   
    Write-Warning "[!] An error occured: $($Error[0].exception)";
    break
}

if ($Members) {
    "`n[x] Group members for $($GroupName):"
    $Members
}

# Show members with TTL, and their expiring information
$TTLMembers = $Members | where {$_ -like "*<TTL=*>*"}

if ($TTLMembers)
	{
    "`n[x] Temporary group members:"
	$TTLMembers | ForEach-Object {
        $SecondsLeft = $($($_.split(",")[0].replace('<TTL=','').replace('>','')));
        $Split = $_.Split(",");
        $TTLmemberDN = $_.Split(",")[1..$($Split.Count - 1)] -join ',';
        $Object = Get-ADObject -Identity $TTLmemberDN -Properties samaccountname;
        Write-Host "Account " -NoNewline -ForegroundColor Cyan; Write-Host $($Object.samaccountname) -NoNewline -ForegroundColor Green; Write-Host -NoNewline " ($TTLmemberDN) has " -ForegroundColor Cyan; Write-Host -NoNewline $([math]::Round($SecondsLeft/60,1)) -ForegroundColor Yellow; Write-Host -NoNewline " minutes ($SecondsLeft seconds) until its membership expires in group $GroupName." -ForegroundColor Cyan;
        Clear-Variable SecondsLeft, Split, TTLmemberDN, Object
    }
  }
else
    {
    Write-Host "`[!] No temporary members found for group $GroupName." -ForegroundColor Cyan
    }
}