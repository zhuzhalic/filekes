$Path = "C:\users.csv"                                                                  #Путь к файлу user.csv
$Users = Import-Csv -Delimiter ";" -Path $Path                                          #Импорт csv-файла
$CN = "DC=watom26,DC=local,OU=watom,OU=hq,OU=Users"                                     #Путь в AD
Foreach ($User in $Users)
{	
    $Password = "P@ssw0rd_2026!"                                                         #Пароль пользователя
    $DisplayName = $User.LastName + " " + $User.FirstName + " " + $User.MiddleName     	#Полное имя
    $UserFirstName = $User.FirstName                                                    #Имя
    $UserLastName = $User.LastName                                                      #Фамилия
    $Department = $User.Department                                                      #Отдел
    $Company = "Company"                                                                #Компания (Организация)
    $Title = $User.Title                                                                #Должность
    $SAM= $User.Login + "@watom26.local"                                                #
    Try {
			#Заведение нового пользователя в AD
            New-ADUser -Name $DisplayName -SamAccountName $User.Login -UserPrincipalName $SAM -DisplayName $DisplayName -GivenName $UserFirstName -Surname  $UserLastName -Company $Company -Department $Department -Title $Title  -AccountPassword  (ConvertTo-SecureString -AsPlainText $Password -Force) -PasswordNeverExpires $true -Enabled $true -Path $CN -Verbose
        }
    }
}
