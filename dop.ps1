# Импортируем модуль Active Directory (требуется RSAT)
Import-Module ActiveDirectory -ErrorAction Stop

# Путь к файлу user.csv
$Path = "C:\users.csv"
$Users = Import-Csv -Delimiter ";" -Path $Path

# Базовый путь в Active Directory (OU, куда помещаются обычные пользователи)
$BaseOU = "OU=Users,OU=watom,OU=hq,OU=Users,DC=watom26,DC=local"

# Общий пароль для всех новых пользователей
$PlainPassword = "P@ssw0rd_2026!"
$SecurePassword = ConvertTo-SecureString -String $PlainPassword -AsPlainText -Force

# Перебираем всех пользователей из CSV
foreach ($User in $Users) {
    # Формируем атрибуты
    $DisplayName = "$($User.LastName) $($User.FirstName) $($User.MiddleName)".Trim()
    $GivenName   = $User.FirstName
    $Surname     = $User.LastName
    $Department  = $User.Department
    $Company     = $User.Company
    # Внимание: в CSV столбец называется JobTitle, а не Title
    $Title       = $User.JobTitle
    $SAM         = $User.Login                     # sAMAccountName (без домена)
    $UPN         = "$($User.Login)@watom26.local"  # UserPrincipalName

    # Определяем целевое подразделение на основе флагов net_admin и net_1line
    $TargetOU = $BaseOU   # по умолчанию
    if ($User.net_admin -eq 'True') {
        $TargetOU = "OU=NetAdmins,$BaseOU"  # для сетевых администраторов
    } elseif ($User.net_1line -eq 'True') {
        $TargetOU = "OU=Net1Line,$BaseOU"   # для первой линии поддержки
    }

    # Проверяем, существует ли уже пользователь с таким sAMAccountName
    if (Get-ADUser -Filter "SamAccountName -eq '$SAM'") {
        Write-Warning "Пользователь с логином $SAM уже существует. Пропускаем."
        continue
    }

    # Создаём учётную запись
    try {
        New-ADUser `
            -Name $DisplayName `
            -DisplayName $DisplayName `
            -GivenName $GivenName `
            -Surname $Surname `
            -SamAccountName $SAM `
            -UserPrincipalName $UPN `
            -Department $Department `
            -Company $Company `
            -Title $Title `
            -AccountPassword $SecurePassword `
            -Enabled $true `
            -Path $TargetOU `
            -PassThru -ErrorAction Stop

        Write-Host "Пользователь $DisplayName ($SAM) успешно создан в $TargetOU." -ForegroundColor Green
    }
    catch {
        Write-Error "Не удалось создать пользователя $DisplayName : $_"
    }
}
