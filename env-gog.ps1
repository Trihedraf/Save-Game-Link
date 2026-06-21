param(
    [switch]$Check,
    [string]$Set,
    [switch]$Remove,
    [switch]$Help
)

$EnvName = "GOGGAMES"

function Show-Help {
    Write-Host "Usage: env-gog.ps1 [-Check] [-Set <path>] [-Remove] [-Help]"
    Write-Host ""
    Write-Host "  (no args)  Show the environment variable current value"
    Write-Host "  -Check     Show the environment variable current value"
    Write-Host "  -Set       Set the environment variable to a path (prompts if path not provided)"
    Write-Host "  -Remove    Remove the environment variable"
    Write-Host "  -Help      Show help"
    exit 0
}

function Get-GogEnv {
    $val = [Environment]::GetEnvironmentVariable($EnvName, "User")
    if ($val) {
        Write-Host "$EnvName = $val" -ForegroundColor Green
    } else {
        Write-Host "$EnvName is not set" -ForegroundColor Yellow
    }
}

function Set-GogEnv {
    param([string]$Path)

    if (-not $Path) {
        $Path = Read-Host "Enter the GOG game install directory path"
    }

    if (-not (Test-Path $Path)) {
        Write-Host "Warning: Path does not exist: $Path" -ForegroundColor Yellow
        $confirm = Read-Host "Set it anyway? (y/N)"
        if ($confirm -ne "y") { exit 1 }
    }

    $resolved = [System.IO.Path]::GetFullPath($Path)
    [Environment]::SetEnvironmentVariable($EnvName, $resolved, "User")
    Write-Host "$EnvName set to $resolved" -ForegroundColor Green

    $refresh = [Environment]::GetEnvironmentVariable($EnvName, "User")
    Write-Host "Verified: $EnvName = $refresh" -ForegroundColor Green
}

function Remove-GogEnv {
    $val = [Environment]::GetEnvironmentVariable($EnvName, "User")
    if (-not $val) {
        Write-Host "$EnvName is not set" -ForegroundColor Yellow
        return
    }

    Write-Host "Current: $EnvName = $val" -ForegroundColor Yellow
    $confirm = Read-Host "Remove $EnvName? (y/N)"
    if ($confirm -ne "y") { exit 1 }

    [Environment]::SetEnvironmentVariable($EnvName, $null, "User")
    Write-Host "$EnvName removed" -ForegroundColor Green
}

if ($Help) { Show-Help }

if ($Remove) { Remove-GogEnv; exit 0 }
if ($Set -or $Set -eq "") { Set-GogEnv -Path $Set; exit 0 }
if ($Check) { Get-GogEnv; exit 0 }

Get-GogEnv
