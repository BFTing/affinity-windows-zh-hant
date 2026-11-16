[CmdletBinding()]
param([string]$AppPath='C:\Program Files\Affinity\Affinity',[ValidateSet('Install','Verify','Remove')][string]$Mode='Install')
$ErrorActionPreference='Stop'
$pack=$PSScriptRoot
$originalManifest=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'original-manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$app=(Resolve-Path -LiteralPath $AppPath).Path.TrimEnd('\')
if($app -match '(?i)\\WindowsApps(?:\\|$)'){throw 'MSIX installation folders are not supported by this installer.'}
if((Get-Item -LiteralPath $app).Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Junction destination is not supported.'}
if((Get-Item -LiteralPath (Join-Path $app 'Affinity.exe')).VersionInfo.FileVersion -ne '3.3.3.5004'){throw 'Requires Affinity 3.3.3.5004.'}
foreach($f in $originalManifest.files){
  if((Get-FileHash -LiteralPath (Join-Path $app $f.path) -Algorithm SHA256).Hash -ne $f.originalSha256){throw "Original language file differs: $($f.path)"}
}
$payload=(Resolve-Path -LiteralPath (Join-Path $pack 'payload')).Path
$files=@(Get-ChildItem -LiteralPath $payload -Recurse -File)
if($files.Count -ne 24){throw 'Unexpected payload file count.'}
$payloadManifest=Get-Content -LiteralPath (Join-Path $pack 'payload-manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if(@($payloadManifest.files).Count -ne 24){throw 'Unexpected payload manifest.'}
foreach($f in $files){
  $relative=$f.FullName.Substring($payload.Length+1).Replace('\','/')
  if($relative -notmatch '^(zh-Hant/[^/]+\.dll|Resources/Affinity/zh-Hant\.lproj/[^/]+\.strings)$'){throw 'Unexpected resource path.'}
  $record=@($payloadManifest.files | Where-Object {$_.path -ceq $relative})
  if($record.Count -ne 1 -or (Get-FileHash -LiteralPath $f.FullName).Hash -ne $record[0].sha256){throw "Payload checksum mismatch: $relative"}
}
$roots=@((Join-Path $app 'zh-Hant'),(Join-Path $app 'Resources\Affinity\zh-Hant.lproj'))
foreach($parent in @($app,(Join-Path $app 'Resources'),(Join-Path $app 'Resources\Affinity'))){
  if((Get-Item -LiteralPath $parent).Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Reparse point destination is not supported.'}
}
foreach($r in $roots){
  if(-not([IO.Path]::GetFullPath($r).StartsWith($app+'\',[StringComparison]::OrdinalIgnoreCase))){throw 'Invalid destination.'}
  if((Test-Path -LiteralPath $r) -and $Mode -eq 'Install'){throw "Locale folder already exists; use Verify: $r"}
  if((Test-Path -LiteralPath $r) -and ((Get-Item -LiteralPath $r).Attributes -band [IO.FileAttributes]::ReparsePoint)){throw 'Reparse point locale is not supported.'}
}
if($Mode -in @('Verify','Remove')){
  foreach($f in $files){
    $relative=$f.FullName.Substring($payload.Length+1)
    $destination=Join-Path $app $relative
    if((Get-Item -LiteralPath $destination).Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Reparse point resource is not supported.'}
    if((Get-FileHash -LiteralPath $destination).Hash -ne (Get-FileHash -LiteralPath $f.FullName).Hash){throw "Installed resource differs: $relative"}
  }
  if($Mode -eq 'Verify'){Write-Output 'Verified version, unchanged Simplified Chinese, and all 24 installed Traditional Chinese files.'; return}
  if(Get-Process -Name Affinity -ErrorAction SilentlyContinue){throw 'Close Affinity before removing the language pack.'}
  foreach($f in $files){Remove-Item -LiteralPath (Join-Path $app $f.FullName.Substring($payload.Length+1))}
  foreach($r in $roots){if(@(Get-ChildItem -LiteralPath $r -Force).Count -eq 0){Remove-Item -LiteralPath $r}}
  Write-Output 'Removed the 24 matching Traditional Chinese files; original language files were preserved.'
  return
}
if(Get-Process -Name Affinity -ErrorAction SilentlyContinue){throw 'Close Affinity before installing.'}
$created=[Collections.Generic.List[string]]::new()
try {
  foreach($r in $roots){New-Item -ItemType Directory -Path $r -ErrorAction Stop | Out-Null}
  foreach($f in $files){
    $relative=$f.FullName.Substring($payload.Length+1)
    $destination=Join-Path $app $relative
    Copy-Item -LiteralPath $f.FullName -Destination $destination -ErrorAction Stop
    $created.Add($destination)
    if((Get-FileHash -LiteralPath $destination).Hash -ne (Get-FileHash -LiteralPath $f.FullName).Hash){throw 'Installed resource checksum mismatch.'}
  }
  Write-Output 'Installed independent zh-Hant resources. Select Chinese (Traditional) in General > Language and restart.'
} catch {
  foreach($f in $created){if(Test-Path -LiteralPath $f){Remove-Item -LiteralPath $f -ErrorAction SilentlyContinue}}
  foreach($r in $roots){if((Test-Path -LiteralPath $r) -and @(Get-ChildItem -LiteralPath $r -Force).Count -eq 0){Remove-Item -LiteralPath $r -ErrorAction SilentlyContinue}}
  throw
}

