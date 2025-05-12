function edit ($file){# Set Notepad++ to the default editor, if available and edit files passed to it.
$global:edit = "notepad"; $npp = "Notepad++\notepad++.exe"; $paths = @("$env:ProgramFiles", "$env:ProgramFiles(x86)")

foreach ($path in $paths) {$test = Join-Path $path $npp}; if (Test-Path $test) {$global:edit = $test; break}
& $global:edit $file}

