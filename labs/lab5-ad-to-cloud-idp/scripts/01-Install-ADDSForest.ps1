# IAM Lab 5 - Step 2/3: install AD DS and promote the first domain controller.
# Run in an elevated PowerShell on the Windows Server 2025 Evaluation VM.
# Creates the NEW forest meridianlab.local. Lab only. Never run in production.
$ErrorActionPreference = 'Stop'
Start-Transcript -Path "$PSScriptRoot\01-adds.log" -Append

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

$dsrm = Read-Host 'Enter a Directory Services Restore Mode (DSRM) password' -AsSecureString
Import-Module ADDSDeployment
Install-ADDSForest `
    -DomainName 'meridianlab.local' `
    -DomainNetbiosName 'MERIDIAN' `
    -ForestMode 'WinThreshold' `
    -DomainMode 'WinThreshold' `
    -InstallDns:$true `
    -SafeModeAdministratorPassword $dsrm `
    -Force:$true

# The server reboots itself. After it comes back, sign in as MERIDIAN\Administrator
# and run 02-Create-OU-Structure.ps1.
Stop-Transcript
