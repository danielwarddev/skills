<#
.SYNOPSIS
  Installs a skill from this repo into a destination directory, optionally
  limited to a subset of its references/ files.

.DESCRIPTION
  Any line in SKILL.md that links only to excluded reference files is dropped;
  lines with no reference link, or with at least one included reference link,
  are kept as-is. When -Refs is omitted, all references are installed.

.EXAMPLE
  ./scripts/install-skill.ps1 csharp-standards ~/proj/.claude/skills -Refs writing-tests,persistence
#>
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$SkillName,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$Dest,

    [string[]]$Refs
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$skillName = Split-Path $SkillName -Leaf
$skillDir = Join-Path $repoRoot $skillName
$skillMd = Join-Path $skillDir "SKILL.md"
$refsDir = Join-Path $skillDir "references"

if (-not (Test-Path $skillMd)) {
    throw "No SKILL.md found at $skillMd"
}

# Allow either -Refs a,b,c or -Refs a -Refs b -Refs c.
if ($Refs -and $Refs.Count -eq 1 -and $Refs[0] -match ',') {
    $Refs = $Refs[0] -split ','
}

if ($Refs) {
    $includeIds = $Refs | ForEach-Object { $_.Trim() -replace '\.md$', '' }
} elseif (Test-Path $refsDir) {
    $includeIds = @(Get-ChildItem $refsDir -Filter *.md | ForEach-Object { $_.BaseName })
} else {
    $includeIds = @()
}

if ($Refs -and (Test-Path $refsDir)) {
    foreach ($id in $includeIds) {
        if (-not (Test-Path (Join-Path $refsDir "$id.md"))) {
            Write-Warning "Reference '$id' not found in $refsDir"
        }
    }
}

$outDir = Join-Path $Dest $skillName
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$includeSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$includeIds)
$refPattern = [regex]'references/([A-Za-z0-9_-]+)\.md'

$filtered = Get-Content $skillMd | Where-Object {
    $lineMatches = $refPattern.Matches($_)
    if ($lineMatches.Count -eq 0) {
        $true
    } else {
        $keep = $false
        foreach ($m in $lineMatches) {
            if ($includeSet.Contains($m.Groups[1].Value)) { $keep = $true }
        }
        $keep
    }
}
Set-Content -Path (Join-Path $outDir "SKILL.md") -Value $filtered

if ((Test-Path $refsDir) -and $includeIds.Count -gt 0) {
    $outRefsDir = Join-Path $outDir "references"
    New-Item -ItemType Directory -Force -Path $outRefsDir | Out-Null
    foreach ($id in $includeIds) {
        $src = Join-Path $refsDir "$id.md"
        if (Test-Path $src) {
            Copy-Item $src (Join-Path $outRefsDir "$id.md")
        }
    }
    if (-not (Get-ChildItem $outRefsDir)) {
        Remove-Item $outRefsDir
    }
}

Write-Host "Installed '$skillName' to $outDir"
$outRefsCheck = Join-Path $outDir "references"
if (Test-Path $outRefsCheck) {
    $names = (Get-ChildItem $outRefsCheck).BaseName -join ", "
    Write-Host "References included: $names"
}
