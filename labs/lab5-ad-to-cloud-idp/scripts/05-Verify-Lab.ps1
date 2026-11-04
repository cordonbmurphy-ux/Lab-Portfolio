# IAM Lab 5 - verification queries for the LIVE Active Directory build.
# Run these after scripts 01-04 and compare against validation\validation-log.txt.
# Every query maps to a model check (M-01 to M-09) in validate_model.py.
Import-Module ActiveDirectory

Write-Host '== M-02: Tier0-Admins members (must be adm- accounts only) =='
Get-ADGroupMember -Identity 'Tier0-Admins' | Select-Object SamAccountName, Name

Write-Host '== M-04: accounts in the Disabled OU (leaver test case) =='
Get-ADUser -Filter * -SearchBase 'OU=Disabled,OU=Meridian,DC=meridianlab,DC=local' |
    Select-Object SamAccountName, Enabled

Write-Host '== M-06: department group membership counts =='
'GG_Clinical_Users', 'GG_Revenue_Users', 'GG_IT_Users', 'GG_HR_Users' | ForEach-Object {
    $count = (Get-ADGroupMember -Identity $_).Count
    Write-Host "$_ : $count members"
}

Write-Host '== M-09: Salesforce pilot group (staged migration population) =='
Get-ADGroupMember -Identity 'GG_Salesforce_Users' | Select-Object SamAccountName, Name

Write-Host '== Sync scope preview: accounts under People OU (the only OU synced to Entra) =='
(Get-ADUser -Filter * -SearchBase 'OU=People,OU=Meridian,DC=meridianlab,DC=local').Count
