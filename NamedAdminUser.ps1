$username = $ENV:AdminUserName
$Password = $ENV:AdminPassword | convertto-securestring -force -AsPlainText

$version = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentVersion
if ($Version -lt "6.3") {
    Write-Error "Unsupported OS. Only Server 2012R2/W8.1 and up are supported."
    exit 1
}


function Set-NamedAccount ($Username, $Password, $type) {
    switch ($type) {
        'Local' {
            $ExistingUser = get-localuser $Username -ErrorAction SilentlyContinue
            if (!$ExistingUser) { 
                write-host "Creating new user admin $username" -ForegroundColor green
                New-LocalUser -Name $Username -Password $Password -PasswordNeverExpires
                Add-LocalGroupMember -Member $Username -SID 'S-1-5-32-544'
            }
            else {
                write-host "Setting password for admin $username" -ForegroundColor Green
                Set-LocalUser -Name $Username -Password $Password
            }
        }
        'Domain' { 
            $ExistingUser = get-aduser -filter * | Where-Object { $_.SamAccountName -eq $Username } -ErrorAction SilentlyContinue
            if (!$ExistingUser) { 
                write-host "Creating new domain admin for $username" -ForegroundColor Green
                New-ADUser -Name $Username -SamAccountName $Username -AccountPassword $Password -Enabled $True
                $ExistingUser = get-aduser -filter * | Where-Object { $_.SamAccountName -eq $Username }
                $Groups = @("Domain Admins", "Administrators", "Schema Admins", "Enterprise Admins")
                $groups | Add-ADGroupMember -members $ExistingUser -erroraction SilentlyContinue
            }
            else {
                write-host "Setting password for admin $username" -ForegroundColor green
                $ExistingUser | Set-adaccountpassword -newPassword $Password
            }
        }
    }
}
 
$DomainCheck = Get-CimInstance -ClassName Win32_OperatingSystem
switch ($DomainCheck.ProductType) {
    1 { Set-NamedAccount -Username $Username -Password $Password -type "Local" }
    2 { Set-NamedAccount -Username $Username -Password $Password -type "Domain" }
    3 { Set-NamedAccount -Username $Username -Password $Password -type "Local" }
    Default { Write-Error -message "Could not get Server Type. Quitting script." }
}
