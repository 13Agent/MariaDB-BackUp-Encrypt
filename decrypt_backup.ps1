param(
    [Parameter(Mandatory, Position=0)]
    [string]$KeyEnc,

    [Parameter(Mandatory, Position=1)]
    [string]$DumpEnc,

    [Parameter(Mandatory, Position=2)]
    [string]$Output,

    [string]$PrivateKey = ".\private.pem"
)

if (-not (Get-Command openssl -ErrorAction SilentlyContinue)) {
    Write-Error "OpenSSL не найден. Установите OpenSSL и убедитесь, что он в PATH."
    exit 1
}

Write-Host ">>> Расшифровываем AES ключ..."
$result = & openssl pkeyutl -decrypt -inkey $PrivateKey -in $KeyEnc -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256 2>&1
if ($LASTEXITCODE -ne 0) { Write-Error $result; exit 1 }
$keyIv = ($result | Out-String).Trim()
$aesKey, $aesIv = $keyIv -split ':'

Write-Host ">>> Расшифровываем дамп..."
$tmp = [System.IO.Path]::GetTempFileName()
try {
    & openssl enc -d -aes-256-cbc -K $aesKey -iv $aesIv -in $DumpEnc -out $tmp 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Error "Ошибка расшифровки дампа"; exit 1 }

    Add-Type -AssemblyName System.IO.Compression
    $in = [System.IO.File]::OpenRead($tmp)
    $out = [System.IO.File]::Create($Output)
    $gzip = [System.IO.Compression.GzipStream]::new($in, [System.IO.Compression.CompressionMode]::Decompress)
    $gzip.CopyTo($out)
    $gzip.Close(); $out.Close(); $in.Close()
}
finally {
    Remove-Item $tmp -ErrorAction SilentlyContinue
    Remove-Variable aesKey, aesIv, keyIv -ErrorAction SilentlyContinue
}

$info = Get-Item $Output
Write-Host ">>> Готово: $Output"
Write-Host "    Размер: $($info.Length) байт"
Get-Content $Output -TotalCount 3
