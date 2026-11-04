# IAM Lab 5 - Step 6: create the groups from data\ou-model.json and apply the
# memberships listed per account in data\lab-users.csv. Idempotent.
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory
Start-Transcript -Path "$PSScriptRoot\04-groups.log" -Append

$model = Get-Content "$PSScriptRoot\..\data\ou-model.json" -Raw | ConvertFrom-Json
foreach ($g in $model.groups) {
    if (-not (Get-ADGroup -Identity $g.name -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $g.name -GroupScope Global -GroupCategory Security `
            -Path $g.ou -Description $g.purpose
        Write-Host "created group: $($g.name)"
    }
}

$users = Import-Csv "$PSScriptRoot\..\data\lab-users.csv"
foreach ($u in $users) {
    if (-not $u.Groups) { continue }
    foreach ($g in $u.Groups -split ';') {
        $members = Get-ADGroupMember -Identity $g | Select-Object -ExpandProperty SamAccountName
        if ($members -notcontains $u.SamAccountName) {
            Add-ADGroupMember -Identity $g -Members $u.SamAccountName
            Write-Host "added $($u.SamAccountName) to $g"
        }
    }
}
Stop-Transcript
