$Users = Import-Csv ".\users.csv"
foreach ($User in $Users)
{
    New-Mailbox -Name $User.Name -Alias $User.MailboxAlias `
        -OrganizationalUnit $User.OU `
        -UserPrincipalName $User.UPN -SamAccountName $User.UserName `
        -FirstName $User.First -Initials $USer.Initial -LastName $User.Last `
        -Password $User.Password -ResetPasswordOnNextLogon $false `
        -Database 'MailboxDatabaseFilename'
}
