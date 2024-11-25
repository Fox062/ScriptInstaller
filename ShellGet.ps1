#===================== No Shell =====================================
$t = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
add-type -name win -member $t -namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess()).MainWindowHandle, 0)
#===================== Shell as Admin ===============================
if (-NOT([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Exit
}
#=============== Run Scripts Free ===============
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Check do winget;
Write-Host "Looking for winget..."
if (Test-Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe") {
    Write-Host "Winget already installed"
}
else {
    $ComputerInfo = Get-ComputerInfo
    $OSName = if ($ComputerInfo.OSName) {
        $ComputerInfo.OSName
    } else {
        $ComputerInfo.WindowsProductName
    }
    
    if (((($OSName.IndexOf("LTSC")) -ne -1) -or ($OSName.IndexOf("Server") -ne -1)) -and (($ComputerInfo.WindowsVersion) -ge "1809")) {
        Write-Host "Running Alternative Installer for LTSC/Server Editions"
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-command irm https://raw.githubusercontent.com/ChrisTitusTech/winutil/$BranchToUse/winget.ps1 | iex | Out-Host" -WindowStyle Normal
    }
    elseif (((Get-ComputerInfo).WindowsVersion) -lt "1809") {
        # Check para saber se o Windows é muito antigo para o Winget
        Write-Host "Winget is not supported below the Windows version (pre-1809)"
    }
    else {
        # Instalando Winget da loja
        Write-Host "Instalando Winget..."
        Start-Process "ms-appinstaller:?source=https://aka.ms/getwinget"
        $nid = (Get-Process AppInstaller).Id
        Wait-Process -Id $nid
        Write-Host "Winget Instalado"
    }
}

Write-Host "Installing..."

winget install Git.Git -h --accept-package-agreements --accept-source-agreements
winget install Valve.Steam -h --accept-package-agreements --accept-source-agreements
winget install  CrystalDewWorld.CrystalDiskInfo -h --accept-package-agreements --accept-source-agreements
winget install Mozilla.Firefox -h --accept-package-agreements --accept-source-agreements
winget install Bitwarden.Bitwarden -h --accept-package-agreements --accept-source-agreements
winget install VideoLan.VLC -h --accept-package-agreements --accept-source-agreements
winget install winrar -h --accept-package-agreements --accept-source-agreements
winget install Microsoft.VisualStudioCode -h --accept-package-agreements --accept-source-agreements
winget install Telegram.TelegramDesktop -h --accept-package-agreements --accept-source-agreements
winget install Python.Python.3.12 -h --accept-package-agreements --accept-source-agreements
winget install Whatsapp -h --accept-package-agreements --accept-source-agreements
winget install Docker.DockerDesktop -h --accept-package-agreements --accept-source-agreements

cmd /c pause