#=================================
#     Install OpenSSh 
#=================================
function Get-InstallOpenSSH {

#---------------------------------
#     Variable & Function
#---------------------------------
$SSHkeyPub = Read-Host "Enter public ssh key"

$SSHkFolder = "$env:USERPROFILE\.ssh"
$osarc = "Win$OSb"
$OpenSSHDir = "$env:ProgramFiles\OpenSSH"
$FileOpenSSH = "$env:SYSTEMDRIVE\PS\OpenSSH\OpenSSH-$osarc.zip"
$uriOSSH = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v8.1.0.0p1-Beta/OpenSSH-${osarc}.zip"
#$LoadPath = "$OpenSSHDir\sshd.exe";

#---------------------------------
$TITLE = "Начать установку OpenSSH [y/n] ..?"
$choice = Read-Host ${TITLE}
while($choice -ne "y") {
    if ($choice -eq "n") {exit}
    if ($choice -eq "y") {break}
    $choice = Read-Host "Только  [y/n] ...!"
}

#---------------------------------
Write-Host -ForegroundColor YELLOW "Scan Windows bitrade...";
Start-Sleep -S 2;
if ((Get-WmiObject win32_operatingsystem | select osarchitecture).osarchitecture -like "64*")
    {$OSb = "64"} else {$OSb = "32"}
Write-Host -ForegroundColor GREEN "...it is Windows x$OSb. Start download OpenSSH X$OSb ";
Start-Sleep -S 2;
New-Item -Path "$env:SYSTEMDRIVE\PS\OpenSSH" -ItemType Directory -force
Invoke-WebRequest -Uri $uriOSSH -OutFile $FileOpenSSH;
Write-Host -ForegroundColor YELLOW "UnPack File from $FileOpenSSH";
Start-Sleep -S 2;
Expand-Archive -Path $FileOpenSSH -DestinationPath $env:ProgramFiles\OpenSSH -Force;

#---------------------------------
$reply = Test-Path -Path $OpenSSHDir\sshd.exe;
if ( $reply -in "True" ) {
    Write-Host -ForegroundColor RED "Folder $LoadPath is EXIST!"; Start-Sleep -S 2;
    Write-Host -ForegroundColor YELLOW "--Stop all ssh* service [SSHd, ssh-agent] ..."; Start-Sleep -S 2;
    Stop-Service -Name "ssh*" -Force -NoWait -PassThru -WhatIf;
    #Stop-Service -Name "ssh*" -NoWait -PassThru
    Write-Host -ForegroundColor YELLOW "--Stop Process sshd"; Start-Sleep -S 2;
    Stop-Process -Name sshd -Force -PassThru -WhatIf;
    Remove-NetFirewallRule -Name sshd;
    Write-Host -ForegroundColor RED "Folder $LoadPath is EXIST!";Start-Sleep -S 2;
    . $env:ProgramFiles\OpenSSH\uninstall-sshd.ps1
}
Write-Host -ForegroundColor GREEN "Копирование содержимого в $OpenSSHDir ...";
Start-Sleep -S 2;
Copy-Item -Path $OpenSSHDir\OpenSSH-$osarc\* -Destination $OpenSSHDir -Force -Recurse;
Write-Host -ForegroundColor YELLOW "Install service ...";
Start-Sleep -S 2;
. $env:ProgramFiles\OpenSSH\install-sshd.ps1;
Write-Host -ForegroundColor YELLOW "Set firewall permissions ...";
Start-Sleep -S 2;
New-NetFirewallRule -Name sshd -DisplayName "OpenSSH Server (sshd)" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22;
Write-Host "Set service Automatic startup ...";
Start-Sleep -S 2;
Set-Service sshd -StartupType Automatic;
Start-Service -Name sshd -PassThru;
Get-Service -DependentServices -Name ssh* -RequiredServices| Get-Service -Status Running;
Write-Host -ForegroundColor YELLOW "Set Authentication to public key";
Start-Sleep -S 3;
((Get-Content -path $env:ProgramData\ssh\sshd_config -Raw) ` -replace '#PubkeyAuthentication yes','PubkeyAuthentication yes' ` -replace '#PasswordAuthentication yes','PasswordAuthentication yes' ` -replace 'Match Group administrators','#Match Group administrators' ` -replace 'AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys','#AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys') | Set-Content -Path $env:ProgramData\ssh\sshd_config;
Write-Host "Restart Service Now after changes...";
Start-Sleep -S 3;
Restart-Service -InputObject sshd -Force -PassThru;    
New-Item -Path $SSHkFolder -ItemType Directory -force
New-Item -Path $SSHkFolder -Name "authorized_keys" -ItemType file -Value ${SSHkeyPub} -Force
#Write-Host $SSHkeyPub | Out-File $SSHkFolder\authorized_keys -Encoding ascii;

#---------------------------------
Write-Host " ============== Cleaning ============== ";
Start-Sleep -S 5;
Write-Host -ForegroundColor GREEN "Remove $env:ProgramFiles\OpenSSH\OpenSSH-$osarc";
Start-Sleep -S 2;
Remove-Item -Path $env:ProgramFiles\OpenSSH\OpenSSH-$osarc -Recurse;
Write-Host -ForegroundColor GREEN "Remove $env:SYSTEMDRIVE\PS\OpenSSH";
Start-Sleep -S 2;
Remove-Item -Path $env:SYSTEMDRIVE\PS\OpenSSH -Recurse

    <#
    #---------------------------------
        $id = "$(Get-Random).$env:COMPUTERNAME"
        $comment = "${env:USERNAME}@${env:COMPUTERNAME}"
        $tKey = "ed25519"
        $folder = "$env:USERPROFILE\.ssh\${id}_${tKey}.key"
        $new_pass = "1111"
        ssh-keygen -t ${tKey} -f ${folder} -C ${comment} -N "${new_pass}"
    #---------------------------------
    #>

Write-Host "OpenSSH x$OSb for windows is installed"; Start-Sleep -S 5;

$TITLE = "Перезагрузка";
$question = "Перезагрузить компьютер, Для приминения настроек ..?";
$choices  = 
$decision = $Host.UI.PromptForChoice("$TITLE", "$question", ("&Yes", "&No"), 1)
if ($decision -eq 0) {
    write-host "Перезагрузка компьютера через 10 сек. ";
    Start-Sleep -S 5;
    Restart-Computer -Confirm:$false -Force
}

}


#=================================
#    Rename this Computer
#=================================
function Get-SomeRenameComp {
    echo "This PC Name - $env:COMPUTERNAME";
    $nw = Read-Host 'Enter PC name ';
    $nw = Read-Host "New Name this Computer"
    if ($env:SYSTEMDRIVE -in $nw) {
        Write-Host "This is Computer is $env:ComputerName";
        Write-Host "== Выбраное Имя Совпадает с Текущим ==";
        Start-Sleep -M 5000
        break
    } else {
        while( -not ( ($choice= (Read-Host "Rename this Computer ?")) -match "y|n")){ "Да или Нет"}
        if ($choice -eq "n") {
            Write-Host "=== Rename ==="
            Start-Sleep -S 3;
            pause;
            Rename-Computer -NewName $nw -Force; 
            Restart-Computer -Force -Confirm
            }    
        Write-Host "=== Пропускаем ===";
        Start-Sleep -S 3;
    }
}


#---------------------------------
<#
$LoadPath = "$env:SYSTEMDRIVE\PS\OpenSSH"
    $reply = Test-Path -Path $LoadPath
    if ( $reply -in "False" ) {Write-Host "NOT EXIST $LoadPath";New-Item -Path $LoadPath -ItemType Directory}
    if ( $reply -in "True" ) {Write-Host "Folder $LoadPath is EXIST!";Remove-Item -Path $env:SYSTEMDRIVE\PS\OpenSSH -Recurse
    }
Write-Host "Next $LoadPath"



#New-Item -Path $env:SYSTEMDRIVE\PS -Name "testfile1.txt" -ItemType "file" -Value "This is a text string.PS"
## для перезаписи
#New-Item -Path $env:SYSTEMDRIVE\PS -Name "testfile1.txt" -ItemType "file" -Value "This is a text string.PS" -Force

#>



#=================================
#        ExecutionPolicy
#=================================
function Get-SomeInstallWinGet {
    $TITLE = "Изменить политику выполнения скриптов на Данном ПК?"
    while( -not ( ($choice= (Read-Host $TITLE)) -match "y|n")){ "Да или Нет"} if ($choice -eq "n") {Start-Sleep -S 3;break}
    Start-Sleep -s 3
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

#---------------------------------
    ##           WinGet
    $TITLE = "Установить WinGet на этот Компьютер Y/N"
    while( -not ( ($choice= (Read-Host $TITLE)) -match "y|n")){ "Только y/n"} if ($choice -eq "n") {Start-Sleep -M 5000;break}
    $WinGetVersion = "v-0.3.11102-preview"
    $WinGetStokname = "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe"
    $WinGetExt = "appxbundle"
    $OutDrive = "$env:SYSTEMDRIVE\"
    $OutDir = "PS\WinGet\"
    $OutFile = "WinGet.${WinGetExt}"
    $WinGetLink = "https://github.com/microsoft/winget-cli/releases/download/${WinGetVersion}/${WinGetStokname}.${WinGetExt}"
    $OutLink = "${OutDrive}${OutDir}${OutFile}"
    New-Item -Path $OutDrive -Name $OutDir -ItemType Directory -force
    Invoke-WebRequest -Uri $WinGetLink -OutFile $OutLink
    ## ins
    Add-AppxPackage $OutLink
    Write-Host "Winget install END and OUT"
    winget --info; winget -v
    Start-Sleep -s 5
}


#=================================
#      MENU
#=================================
function Get-SomeInput {
$Menu = "
1. Install OpenSSH
2. Rename this Computer
3. Install WinGet
=================
0. ВЫХОД"
$Again = "Неправильный выбор, попробуйте еще раз!";
$input = read-host ${Menu} "Введите";
switch ($input) {
    "1" { write-host "Install OpenSSH";Get-InstallOpenSSH; Get-SomeInput}
    "2" {write-host "START Rename";Get-SomeRenameComp; Get-SomeInput}
    "3"  {write-host "Install WinGet";Get-SomeInstallWinGet;Get-SomeInput}
    "0"  {write-host "Отмена";break}
    default {write-host "${Again}";Start-Sleep -s 3;Get-SomeInput}
}
}

#---------------------------------
## Start as ADMIN
$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
$testadmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if ($testadmin -eq $false) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    exit $LASTEXITCODE
}; 
Get-SomeInput
Write-Host " ==== EXIT === ";
Start-Sleep -S 2;
exit
