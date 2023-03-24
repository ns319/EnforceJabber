# Enforce_Jabber

<#
.SYNOPSIS
    Enforce Jabber version 12.9.6.55898.
.DESCRIPTION
    First, override the default 260 character limit for file paths. This extends the limit to 32,767 (approximate).
    I don't exactly know why this is part of this script, but it was in the original Command shell script that my boss wrote, so I assume it's important?
    Next, find the version of Jabber installed on the current host. If it's anything other than 12.9.6.55898, uninstall it.
    If Jabber has been uninstalled, delete cached files in C:\Users\UserName\AppData\Local and \Roaming for all users before proceeding.
    Finally, ensure version 12.9.6.55898 is installed/proceed to install it if necessary.
.NOTES
    Non-interactive. Intended to run at sign-on.
    This script only checks the 64-bit registry path - 32-bit Jabber is unaffected.
    v1.0.0
#>

# Override default character limit for file paths
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name 'LongPathsEnabled' -PropertyType Dword -Value '1' -Force | Out-Null

# Find installed Jabber version
$Jabber = Get-ChildItem -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall' |
    Get-ItemProperty -Name DisplayName,DisplayVersion,UninstallString -ErrorAction SilentlyContinue |
    Where-Object {$_.DisplayName -like '*Jabber*'}

# Compare installed version against 12.9.6.55898. If it's not the same, uninstall Jabber and install correct version
if ($Jabber.DisplayVersion -ne '12.9.6.55898') {
    Write-Host '         ========================================================='
    Write-Host '         =                                                       ='
    Write-Host '         =                Organization Name Here                 ='
    Write-Host '         =                                                       ='
    Write-Host '         ========================================================='
    Write-Host '         ========================================================='
    Write-Host '         =                                                       ='
    Write-Host '         =              Cisco Jabber is installing               ='
    Write-Host '         =               Do not close this window                ='
    Write-Host '         =                                                       ='
    Write-Host "         =========================================================`n"

    # Uninstall incorrect version
    $UninstallString = $Jabber.UninstallString
    Start-Process cmd.exe -ArgumentList "/c $UninstallString /quiet" -Wait -NoNewWindow 2> $null

    # Delete cached data in AppData for all users
    $Users = Get-ChildItem C:\Users
    foreach ($User in $Users) {
        $UserPath1 = "C:\Users\$User\AppData\Local\Cisco\Jabber"
        $UserPath2 = "C:\Users\$User\AppData\Roaming\Cisco\Jabber"
        $UserPath3 = "C:\Users\$User\AppData\Local\Cisco\Unified Communications\Jabber"
        $UserPath4 = "C:\Users\$User\AppData\Roaming\Cisco\Unified Communications\Jabber"
        Remove-Item $UserPath1\*,$UserPath2\*,$UserPath3\*,$UserPath4\* -Recurse -Force 2> $null
    }

    # Install Jabber from SoftwareDist repository
    Start-Process msiexec.exe -ArgumentList "/i \\SoftwareDist\Apps\Cisco\Jabber\CiscoJabberSetup.msi /qn"
}
