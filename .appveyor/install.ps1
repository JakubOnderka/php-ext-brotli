$ErrorActionPreference = "Stop"

if (-not (Test-Path 'C:\build-cache')) {
    [void](New-Item 'C:\build-cache' -ItemType 'directory')
}

# PHP SDK
$bname = "php-sdk-$env:BIN_SDK_VER.zip"
if (-not (Test-Path C:\build-cache\$bname)) {
    Invoke-WebRequest "https://github.com/microsoft/php-sdk-binary-tools/archive/$bname" -OutFile "C:\build-cache\$bname"
}
$dname0 = "php-sdk-binary-tools-php-sdk-$env:BIN_SDK_VER"
$dname1 = "php-sdk-$env:BIN_SDK_VER"
if (-not (Test-Path "C:\build-cache\$dname1")) {
    Expand-Archive "C:\build-cache\$bname" "C:\build-cache"
    Move-Item "C:\build-cache\$dname0" "C:\build-cache\$dname1"
}

# PHP releases
Invoke-WebRequest "https://windows.php.net/downloads/releases/releases.json" -OutFile "C:\build-cache\releases.json"
$php_version = (Get-Content -Path "C:\build-cache\releases.json" | ConvertFrom-Json | ForEach-Object {
    if ($_."$env:PHP_VER") {
        return $_."$env:PHP_VER".version
    } else {
        return "$env:PHP_VER"
    }
})

# PHP devel pack
$ts_part = ''
if ('0' -eq $env:TS) {
    $ts_part = '-nts'
}
$bname = "php-devel-pack-$php_version$ts_part-Win32-$env:VC-$env:ARCH.zip"
if (-not (Test-Path "C:\build-cache\$bname")) {
    try {
        Invoke-WebRequest "https://windows.php.net/downloads/releases/$bname" -OutFile "C:\build-cache\$bname"
    } catch [System.Net.WebException] {
        Invoke-WebRequest "https://windows.php.net/downloads/releases/archives/$bname" -OutFile "C:\build-cache\$bname"
    }
}
$dname0 = "php-$php_version-devel-$env:VC-$env:ARCH"
$dname1 = "php-$php_version$ts_part-devel-$env:VC-$env:ARCH"
if (-not (Test-Path "C:\build-cache\$dname1")) {
    Expand-Archive "C:\build-cache\$bname" 'C:\build-cache'
    if (-not (Test-Path "C:\build-cache\$dname0")) {
        $php_normalize_version = $php_version.Split("-")[0]
        $dname0 = "php-$php_normalize_version-devel-$env:VC-$env:ARCH"
    }
    if ($dname0 -ne $dname1) {
        Move-Item "C:\build-cache\$dname0" "C:\build-cache\$dname1"
    }
}
$env:PATH = "C:\build-cache\$dname1;$env:PATH"

# PHP binary
$bname = "php-$php_version$ts_part-Win32-$env:VC-$env:ARCH.zip"
if (-not (Test-Path "C:\build-cache\$bname")) {
    try {
        Invoke-WebRequest "https://windows.php.net/downloads/releases/$bname" -OutFile "C:\build-cache\$bname"
    } catch [System.Net.WebException] {
        Invoke-WebRequest "https://windows.php.net/downloads/releases/archives/$bname" -OutFile "C:\build-cache\$bname"
    }
}
$dname = "php-$php_version$ts_part-Win32-$env:VC-$env:ARCH"
if (-not (Test-Path "C:\build-cache\$dname")) {
    Expand-Archive "C:\build-cache\$bname" "C:\build-cache\$dname"
}
$env:PHP_PATH = "C:\build-cache\$dname"
$env:PATH = "$env:PHP_PATH;$env:PATH"

# # library dependency
# $bname = "$env:DEP-$env:VC-$env:ARCH.zip"
# if (-not (Test-Path "C:\build-cache\$bname")) {
#     Invoke-WebRequest "https://windows.php.net/downloads/pecl/deps/$bname" -OutFile "C:\build-cache\$bname"
#     Expand-Archive "C:\build-cache\$bname" 'C:\build-cache\deps'
# }
$env:PATH = "C:\build-cache\deps\bin;$env:PATH"
