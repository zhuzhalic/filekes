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
    Catch {
			#Если пользователь уже существует, то исправление его данных
            Set-ADUser -Identity "CN=$DisplayName,OU=Users,OU=Departament,DC=Organization,DC=local" -Company $Company -Department $Department -Title $Title -Verbose
          }
    Finally {
		#Добавление пользователя к Группе пользователей на основе Отдела
        if ($Department -eq 'Departament1') {Add-ADGroupMember -Identity "Departament1" -Members $User.Login -Verbose}
        elseif ($Department -eq 'Departament2') {Add-ADGroupMember -Identity "Departament2" -Members $User.Login -Verbose}
        elseif ($Department -eq 'Departament3') {Add-ADGroupMember -Identity "Departament3" -Members $User.Login -Verbose}
		#Добавление данных и фотографии юзера в дополнительные поля
		Set-ADUser -Identity "CN=$DisplayName,OU=Users,OU=Departament,DC=Organization,DC=local" -Replace @{$ADSI=$ADSIData;$ADSI2=$ADSIData2;thumbnailPhoto=$photo;jpegPhoto=$photo} -Verbose
    }
}
