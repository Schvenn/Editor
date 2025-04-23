function edit ($file){# Set Notepad++ to the default editor, if available and edit files passed to it.
$global:edit = "notepad"; $npp = "Notepad++\notepad++.exe"; $paths = @("$env:ProgramFiles", "$env:ProgramFiles(x86)")

foreach ($path in $paths) {$test = Join-Path $path $npp}; if (Test-Path $test) {$global:edit = $test; break}
& $global:edit $file}

function editprofile{# Edit this Powershell profile.
& edit $profile}
sal -name ep -value editprofile

function editmodule ($script) { # Create/edit a new or existing PowerShell module file.
if (!($script)) {$mods="$env:UserProfile\Documents\PowerShell\Modules"; $files=Get-ChildItem $mods -Recurse -Include *.ps1,*.psm1,*.psd1 -File; $grouped=$files|Group-Object{($_.FullName -replace [regex]::Escape($mods),'').Split('\')[1]}|Sort-Object Name; $flat=@(); $folderIndex=0; 
$grouped|%{if ($_.Group.Count -eq 1) {$flat+=@{Display=$_.Group[0].Name; Path=$_.Group[0].FullName; Folder=''; GroupSize=1}} 
else {$_.Group|Sort-Object FullName|%{$folderPath=($_.FullName -replace [regex]::Escape($mods+'\'),'').Split('\')[0]; $displayText="$folderPath\$($_.Name)"; $flat+=@{Display=$displayText; Path=$_.FullName; Folder=$folderPath; GroupSize=$_.Group.Count}}}}

# Provide a selection menu when no module name was provided.
Write-Host -ForegroundColor Yellow "`nSelect a module to edit:`n"; $i=0; $prevFolder=''; $flat|%{if ($_.Folder -ne $prevFolder) {$folderIndex++; $prevFolder=$_.Folder}; $color = if ($_.Folder -eq '' -or $_.GroupSize -eq 1) {'Gray'} else {if ($folderIndex % 2 -eq 0) {'Yellow'} else {'Green'}}; 
Write-Host "$i. " -NoNewline -ForegroundColor Cyan; Write-Host "$($_.Display)" -ForegroundColor $color; $i++}; font Yellow; $sel=Read-Host "`nSelect module"; ""; $index=[int]$sel; if ($index -lt 0 -or $index -ge $flat.Count) {Write-Host "Invalid selection`n" -ForegroundColor Red; return}; edit $flat[$index].Path; return}

# If a module name was provided, edit it.
$path="$env:userprofile\documents\powershell\modules\$script\$script.psm1"; if (Test-Path $path) {edit "$path"}

# Offer to create the module, if it doesn't already exist.
if (!(Test-Path $path)) {Write-Host "`nPath '$path' does not exist." -ForegroundColor Yellow; $response=Read-Host "Create it now? (Y/N)"; 
if ($response -match '^[Yy]') {try {New-Item -ItemType Directory -Path ([System.IO.Path]::GetDirectoryName($path)) -Force | Out-Null; 
New-Item -ItemType File -Path $path -Force | Out-Null; Write-Host "Created: $path`n" -ForegroundColor Green} catch {Write-Host "Failed to create: $_`n" -ForegroundColor Red; return}} 
else {""; return}}}
sal -name em -value editmodule
