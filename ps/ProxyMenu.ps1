
# $ServerPortUP = ''

$reg='HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
$ServerPort = "$($server):$($Port)"
$string = "$ServerPortUP"
$string -match '(?<Server>.+)\:(?<Port>.+)\:(?<Username>.+)\:(?<Pass>.+)'


function Get-Proxy() {
    Get-ItemProperty -Path $reg | Select-Object ProxyServer, ProxyEnable;Start-Sleep -S 2
}

function Rem-Proxy() {
    Write-Host -ForegroundColor Yellow -NoNewline "Отключаем.";
    Start-Sleep -S 2;
    Set-ItemProperty -path $reg ProxyEnable -value 0;
    Write-Host -ForegroundColor Yellow ".. и удаляем.";
    Start-Sleep -S 2;
    Remove-ItemProperty -path $reg -name ProxyServer;
    Write-Host -ForegroundColor RED "Прокси Removed!";
    Start-Sleep -S 2;
}


function Set-Proxy() {
    Write-Host -ForegroundColor Yellow "..добавляем [server:Port] и включаем.";
    Start-Sleep -S 2;
    Set-ItemProperty -path $reg ProxyServer -value $ServerPort;
    Set-ItemProperty -path $reg ProxyEnable -value 1;
    #Set-ItemProperty -Path $reg -name ProxyUser -Value "$Username";
    #Set-ItemProperty -Path $reg -name ProxyPass -Value "$pass";
}


function F2()
{
    Clear-Host
    Get-ItemProperty -Path $reg | Select-Object ProxyServer, ProxyEnable;
    while( -not ( ($choice= (Read-Host "Отключить прокси на ПК?")) -match "y|n")){ "Да или Нет"}; 
    if ($choice -eq "y") {
        Set-ItemProperty -Path $reg -name ProxyEnable -Value 0
        Get-ItemProperty -Path $reg | Select-Object ProxyServer, ProxyEnable;
        Start-Sleep -S 3;
    }
    if ($choice -eq "n") {
        Write-Host -ForegroundColor GREEN "Ну НЕТ , дак НЕТ...";
        Get-ItemProperty -Path $reg | Select-Object ProxyServer, ProxyEnable;
        Start-Sleep -S 3;
    }

}

function F3() {
    Clear-Host
    $server = $Matches.Server
    $port = $Matches.Port
    $username = $Matches.username
    $pass = $Matches.pass

    Write-Host -BackgroundColor Black -ForegroundColor Yellow -NoNewline -Object "Получаем настройки proxy server."
    $proxyServer = Get-ItemProperty -path $reg ProxyServer -ErrorAction SilentlyContinue
    if([string]::IsNullOrEmpty($proxyServer)) {
	    If ((Test-NetConnection -ComputerName $server -Port "$Port").TcpTestSucceeded) {
        Set-ItemProperty -Path $reg -name ProxyEnable -Value 0
        Set-ItemProperty -path $reg -name ProxyEnable -value 1;
        Get-Proxy;
            Write-Host -ForegroundColor GREEN -NoNewline ".. прокси ON-Line [$ServerPort]";
            Start-Sleep -S 2;
            Get-Proxy;
	    } else {
            Write-Error -Message "НЕВЕРНЫЕ настройки прокси-сервера: $($server):$($Port)";
            Start-Sleep -S 2;
        }
    } else {
        $ServerPortUP = "$(Read-Host 'Введите [ex.: Server:Port:Name:Pass]')";
        Write-Host -ForegroundColor GREEN ".. прокси ON-Line.";
        Start-Sleep -S 2;
        Set-Proxy;
        Get-Proxy;
    }
}


function Add-Proxy ($server,$Port,$Username,$Pass) {
    Clear-Host;
    $server = $Matches.Server
    $port = $Matches.Port
    $username = $Matches.Username
    $pass = $Matches.Pass

    Write-Host -BackgroundColor Black -ForegroundColor Yellow -NoNewline -Object "Получаем настройки proxy server."
    $proxyServer = Get-ItemProperty -path $reg ProxyServer -ErrorAction SilentlyContinue
    if([string]::IsNullOrEmpty($proxyServer)) {
	    If ((Test-NetConnection -ComputerName $server -Port "$Port").TcpTestSucceeded) {
            Write-Host -ForegroundColor Yellow -NoNewline "прокси Off-Line.";
            Start-Sleep -S 2;
            Set-Proxy;
            Write-Host -ForegroundColor GREEN -NoNewline ".. прокси ON-Line [$ServerPort]";
            Start-Sleep -S 2;
            Get-Proxy;
	    } else {
            Write-Error -Message "НЕВЕРНЫЕ настройки прокси-сервера: $($server):$($Port)";
            Start-Sleep -S 2;
        }
    } else {
        Write-Host -ForegroundColor GREEN ".. прокси ON-Line.";
        Start-Sleep -S 2;
        Rem-Proxy;
        Get-Proxy;
    }
}



function MENU()
{
$Menu = "
1. Proxy HTTP(S) [ Add ]
2. Proxy HTTP(S) [ OFF ]
3. Proxy HTTP(S) [ ON  ]
=================
0. ВЫХОД"
#===================
$Again = "Неправильный выбор, попробуйте еще раз!";
$input = read-host ${Menu} "Введите";
  switch ($input) {
    default {write-host "${Again}";Start-Sleep -s 3; MENU };
    "0"  {write-host "Отмена"; break };
    "1" {$ServerPortUP = "$(Read-Host 'Введите [ex.: Server:Port:Name:Pass]')";Add-Proxy "$ServerPortUP";MENU};
    "2" {F2;MENU};
    "3" {F3;MENU};
  }
}



#------  Start as ADMIN  ---------
$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
$testadmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if ($testadmin -eq $false) {Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition)); exit $LASTEXITCODE};

#=================================
MENU
exit




#Get-ChildItem $pshome\PowerShell.exe | Format-List -Property *
