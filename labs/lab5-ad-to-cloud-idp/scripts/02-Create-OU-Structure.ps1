# IAM Lab 5 - Steps 5/6: create the tiered OU structure from data\ou-model.json.
# Idempotent: existing OUs are skipped. Run elevated on the domain controller.
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory
Start-Transcript -Path "$PSScriptRoot\02-ous.log" -Append

$model = Get-Content "$PSScriptRoot\..\data\ou-model.json" -Raw | ConvertFrom-Json
$domainDN = 'DC=meridianlab,DC=local'

foreach ($dn in $model.ous) {
    if (Get-ADOrganizationalUnit -Identity $dn -ErrorAction SilentlyContinue) {
        Write-Host "exists: $dn"
        continue
    }
    $name = ($dn -split ',')[0] -replace '^OU=', ''
    $parent = ($dn -split ',', 2)[1]
    New-ADOrganizationalUnit -Name $name -Path $parent -ProtectedFromAccidentalDeletion $true
    Write-Host "created: $dn"
}
Stop-Transcript
