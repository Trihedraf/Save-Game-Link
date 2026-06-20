param(
    [string]$GameName,
    [switch]$Check,
    [string]$DatabasePath = ".\db.json"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not [System.IO.Path]::IsPathRooted($DatabasePath)) {
    $DatabasePath = Join-Path $ScriptDir $DatabasePath
}
$DatabasePath = [System.IO.Path]::GetFullPath($DatabasePath)

if (-not (Test-Path $DatabasePath)) {
    Write-Error "Database not found at $DatabasePath"
    exit 1
}

$db = Get-Content $DatabasePath -Raw | ConvertFrom-Json

function Resolve-AbsolutePath {
    param([string]$Path)
    $expanded = [System.Environment]::ExpandEnvironmentVariables($Path)
    $expanded = [regex]::Replace($expanded, '\$env:(\w+)', { param($m) [Environment]::GetEnvironmentVariable($m.Groups[1].Value) })
    if (-not [System.IO.Path]::IsPathRooted($expanded)) {
        $expanded = Join-Path $ScriptDir $expanded
    }
    return [System.IO.Path]::GetFullPath($expanded)
}

function New-Symlink {
    param(
        [string]$LinkPath,
        [string]$TargetPath,
        [string]$Label
    )

    $target = Resolve-AbsolutePath $TargetPath
    $link = Resolve-AbsolutePath $LinkPath

    if (Test-Path $link) {
        $item = Get-Item $link -Force
        if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            $actualTarget = [System.IO.Path]::GetFullPath($item.Target)
            if ($actualTarget -eq $target) {
                Write-Host " - [$Label=OK]" -ForegroundColor Green
                return
            }
            Write-Host " - [$Label=WRONG TARGET]" -ForegroundColor Red
            if ($Check) { return }
            Remove-Item $link -Force
        } else {
            Write-Host " - [$Label=NOT A LINK]" -ForegroundColor Yellow
            if ($Check) { return }
            $backup = "$link.bak"
            Move-Item $link $backup -Force
        }
    } else {
        Write-Host " - [$Label=MISSING]" -ForegroundColor Red
        if ($Check) { return }
    }

    if (-not (Test-Path $target)) {
        try {
            New-Item -ItemType Directory -Path $target -Force -ErrorAction Stop | Out-Null
        } catch {
            Write-Host " - [$Label=FAILED](create origin)" -ForegroundColor Red
            return
        }
    }

    try {
        New-Item -ItemType Junction -Path $link -Target $target -ErrorAction Stop | Out-Null
        Write-Host " - [$Label=CREATED]" -ForegroundColor Green
    } catch {
        Write-Host " - [$Label=FAILED](create link)" -ForegroundColor Red
    }
}

if ($GameName) {
    $games = $db.games | Where-Object { $_.name -eq $GameName }
    if (-not $games) { Write-Error "Game '$GameName' not found"; exit 1 }
} else {
    $games = $db.games
}

foreach ($game in $games) {
    Write-Host "$($game.name):" -ForegroundColor Magenta

    if ($game.paths) {
        foreach ($entry in $game.paths.PSObject.Properties) {
            New-Symlink -LinkPath $entry.Value.link -TargetPath $entry.Value.origin -Label $entry.Name
        }
    }
}
