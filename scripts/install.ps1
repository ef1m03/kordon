# Kordon installer for Windows. Run in PowerShell:
#
#   irm https://raw.githubusercontent.com/ef1m03/kordon/main/scripts/install.ps1 | iex
#
# To uninstall:
#
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/ef1m03/kordon/main/scripts/install.ps1))) -Uninstall
#
# No admin rights needed: Kordon lives in %LOCALAPPDATA%\Programs\Kordon.
# No param() block: the script also runs through `irm | iex`, where one isn't allowed.
$Uninstall = [bool]($args | Where-Object { $_ -eq '-Uninstall' })
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$dir = Join-Path $env:LOCALAPPDATA 'Programs\Kordon'
$exe = Join-Path $dir 'kordon.exe'
$lnk = Join-Path ([Environment]::GetFolderPath('Programs')) 'Kordon.lnk'

Get-Process kordon -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 500

if ($Uninstall) {
    Remove-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name Kordon -ErrorAction SilentlyContinue
    Remove-Item $lnk, $dir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Kordon удалён. Настройки остались в $env:APPDATA\Kordon." -ForegroundColor Green
    return
}

$arch = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { 'arm64' } else { 'amd64' }
$base = 'https://github.com/ef1m03/kordon/releases/latest/download'
$name = "kordon-windows-$arch.exe"
New-Item -ItemType Directory -Force $dir | Out-Null
Write-Host 'Скачиваю Kordon…'
$tmp = Join-Path $env:TEMP "kordon-$PID.exe"
$sumsFile = "$tmp.sums"
# Defender (or another antivirus) may take the fresh, unsigned .exe away while
# it's being saved or read: say what it is and what to do, not a red trace.
function Test-AvBlock($err) {
    $m = "$($err.Exception.Message)"
    return ($err.Exception.HResult -in -2147024671, -2147024670) -or ($m -match 'вирус|virus|нежелательн|unwanted')
}
try {
    Invoke-WebRequest "$base/$name" -OutFile $tmp -UseBasicParsing
    # Compare with the release's SHA256SUMS.txt: a damaged or swapped file is never installed.
    Invoke-WebRequest "$base/SHA256SUMS.txt" -OutFile $sumsFile -UseBasicParsing
    $line = Get-Content $sumsFile | Where-Object { $_ -match ('  ' + [regex]::Escape($name) + '$') }
    $want = if ($line) { ($line -split '\s+')[0] } else { '' }
    $got = (Get-FileHash $tmp -Algorithm SHA256).Hash.ToLower()
    if (-not $want -or $want -ne $got) {
        Write-Host "Контрольная сумма $name не совпала - файл повреждён или подменён, ничего не установлено." -ForegroundColor Red
        return
    }
    Move-Item $tmp $exe -Force
    Unblock-File $exe
} catch {
    if (Test-AvBlock $_) {
        Write-Host ''
        Write-Host 'Антивирус Windows заблокировал файл Kordon.' -ForegroundColor Yellow
        Write-Host 'Это ложное срабатывание: сборка для Windows пока без сертификата подписи, а Kordon ставит другие программы на паузу - так антивирусы оценивают незнакомые программы.'
        Write-Host ''
        Write-Host 'Что сделать:'
        Write-Host '  1. Безопасность Windows -> Защита от вирусов и угроз -> Журнал защиты.'
        Write-Host '  2. Запись про kordon -> Действия -> Разрешить на устройстве.'
        Write-Host '  3. Запустите эту команду ещё раз.'
        Write-Host ''
        Write-Host 'Проверить файл самому: https://github.com/ef1m03/kordon#официальные-сборки-и-проверки'
        Write-Host 'Вопросы - в боте: https://t.me/kordon_security_bot'
        return
    }
    Write-Host "Не получилось скачать Kordon: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host 'Проверьте интернет и запустите команду ещё раз. Не выходит - напишите в бот: https://t.me/kordon_security_bot'
    return
} finally {
    Remove-Item $sumsFile, $tmp -Force -ErrorAction SilentlyContinue
}

$sh = New-Object -ComObject WScript.Shell
$s = $sh.CreateShortcut($lnk)
$s.TargetPath = $exe
$s.Save()

Start-Process $exe
Write-Host 'Готово: значок Kordon у часов (если не видно - он под стрелкой ^, его можно перетащить на панель).' -ForegroundColor Green
