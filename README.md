$Path = "C:\users.csv"                                                                  #Путь к файлу user.csv
$Users = Import-Csv -Delimiter ";" -Path $Path                                          #Импорт csv-файла
$CN = "OU=Users,OU=watom,OU=hq,OU=Users,DC=watom26,DC=local"                                     #Путь в AD
Foreach ($User in $Users)
{	
    $Password = "P@ssw0rd_2026!"                                                         #Пароль пользователя
    $DisplayName = $User.LastName + " " + $User.FirstName + " " + $User.MiddleName     	#Полное имя
    $UserFirstName = $User.FirstName                                                    #Имя
    $UserLastName = $User.LastName                                                      #Фамилия
    $Department = $User.Department                                                      #Отдел
    $Company =  $User.Company                                                               #Компания (Организация)
    $Title = $User.Title                                                                #Должность
    $SAM= $User.Login 
 $TargetOU = $BaseOU                     
    if ($User.net_admin -eq 'True') {
        $TargetOU = "OU=NetAdmins,$BaseOU"  
    } elseif ($User.net_1line -eq 'True') {
        $TargetOU = "OU=Net1Line,$BaseOU"  
    }
