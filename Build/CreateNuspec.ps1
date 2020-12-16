param(
    $root = [System.IO.Path]::GetFullPath("$PSScriptRoot\..\"),
    [switch]$Release,
    $dxVersion = "20.2.4",
    $branch = "lab"
)

$ErrorActionPreference = "Stop"
# Import-XpandPwsh


[version]$modulesVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$root\bin\Xpand.XAF.Modules.Reactive.dll" ).FileVersion
$versionConverterPath = "$root\tools\Xpand.VersionConverter\Xpand.VersionConverter.nuspec"
[xml]$nuspec = Get-Content $versionConverterPath
[version]$vv = $nuspec.package.metadata.version
$nuspec.package.metadata.version = "$($vv.major).$($modulesVersion.Minor).$($vv.build)"
$nuspec.Save($versionConverterPath)

$allProjects = Get-ChildItem $root *.csproj -Recurse | Select-Object -ExpandProperty BaseName
$filter="test"
if ($dxVersion -lt "20.2.0"){
    $filter += "|blazor|hangfire"
}

Get-ChildItem "$root\src\" -Include "*.csproj" -Recurse | Where-Object { $_ -notmatch $filter} | Invoke-Parallel -VariablesToImport @("allProjects", "root", "Release") -Script {
    # Get-ChildItem "$root\src\" -Include "*.csproj" -Recurse | Where-Object { $_ -notmatch $filter} | foreach {
    $addTargets = {
        param (
            $name   
        )
        $a = [ordered]@{
            src    = "..\build\Targets\$name.targets"
            target = "build\$($nuspec.package.metadata.id).targets" 
        }
        if ($nuspecFileName -like "*Client*") {
            $a.src = "..\$($a.src)"
        }
        Add-XmlElement -Owner $nuspec -elementname "file" -parent "files"-Attributes $a | Out-Null
        $a = [ordered]@{
            src    = "..\build\Targets\$name.ps1"
            target = "build\$name.ps1" 
        }
        if ($nuspecFileName -like "*Client*") {
            $a.src = "..\$($a.src)"
        }
        Add-XmlElement -Owner $nuspec -elementname "file" -parent "files"-Attributes $a | Out-Null
    }
    Set-Location $root
    $projectPath = $_.FullName
    
    Write-Output "Creating Nuspec for $($_.baseName)" 
    $uArgs = @{
        NuspecFilename           = "$root\build\nuspec\$($_.baseName).nuspec"
        ProjectFileName          = $projectPath
        ReferenceToPackageFilter = "Xpand*"
        PublishedSource          = (Get-PackageFeed -Xpand)
        Release                  = $Release
        ReadMe                   = $false
        AllProjects              = $allProjects
    }
    if (!(Test-Path $uArgs.NuspecFilename)) {
        Set-Location $root\build\nuspec
        & (Get-NugetPath) spec $_.BaseName
    }
    if ($Release) {
        $uArgs.PublishedSource = (Get-PackageFeed -Nuget)
    }
    
    & "$root\build\Update-Nuspec.ps1" @uArgs 

    $nuspecFileName = "$root\build\nuspec\$($_.BaseName).nuspec"
    [xml]$nuspec = Get-Content $nuspecFileName
    $psTarget = "CopySymbols"
    if (Test-Path "..\build\Targets\$($_.BaseName).targets") {
        $psTarget = $_.BaseName
    }
    & $addTargets $psTarget
    Add-XmlElement -Owner $nuspec -elementname "file" -parent "files"-Attributes $a | Out-Null
    $readMePath = "$($_.DirectoryName)\ReadMe.md"
    if (Test-Path $readMePath) {
        $readMe = Get-Content $readMePath -Raw
        if ($readMe -cmatch '# About([^#]*)') {
            $nuspec.package.metaData.description = "$($matches[1])".Trim()
        }
        else {
            $nuspec.package.metaData.description = $nuspec.package.metaData.id
        }
    }
    else {
        $nuspec.package.metaData.description = $nuspec.package.metaData.id
    }

    $relativeLocation = $_.DirectoryName.Replace($root, "").Replace("\", "/")
    $nuspec.package.metaData.projectUrl = "https://github.com/eXpandFramework/DevExpress.XAF/blob/master/$relativeLocation"
    $nuspec.package.metaData.licenseUrl = "https://github.com/eXpandFramework/DevExpress.XAF/blob/master/LICENSE"
    $nuspec.package.metaData.iconUrl = "http://sign.expandframework.com"
    $nuspec.package.metaData.authors = "eXpandFramework"
    $nuspec.package.metaData.owners = "eXpandFramework"
    $nuspec.package.metaData.releaseNotes = "https://github.com/eXpandFramework/DevExpress.XAF/releases"
    $nuspec.package.metaData.copyright = "eXpandFramework.com"
    $nameTag = $nuspec.package.metaData.id.Replace("Xpand.XAF.Modules.", "").Replace("Xpand.XAF.Extensions.", "")
    $nuspec.package.metaData.tags = "DevExpress XAF modules, eXpandFramework, XAF, eXpressApp,  $nameTag"
    
    $ns = New-Object System.Xml.XmlNamespaceManager($nuspec.NameTable)
    $ns.AddNamespace("ns", $nuspec.DocumentElement.NamespaceURI)
    
    if ($nuspec.package.metaData.id -like "Xpand.XAF*" -or $nuspec.package.metaData.id -like "Xpand.Extensions.XAF*") {
        
        $versionConverter = [PSCustomObject]@{
            id              = "Xpand.VersionConverter"
            version         = ([xml](Get-Content "$root\Tools\Xpand.VersionConverter\Xpand.VersionConverter.nuspec")).package.metadata.version
            targetFramework = "netstandard2.0"
        }
        
        Add-NuspecDependency $versionConverter.Id $versionConverter.Version $nuspec "netstandard2.0"| Out-Null
         
    }
    
    
    $nuspec.Save($nuspecFileName)
    Format-Xml -Path $nuspecFileName
} 

& "$root\build\UpdateAllNuspec.ps1" $root $Release $branch $dxVersion
if ($branch -eq "master") {
    Write-HostFormatted "Checking nuspec versions" -Section
    $labnuspecs = Get-ChildItem "$root\build\nuspec" *.nuspec -Recurse | ForEach-Object {
        [xml]$n = Get-xmlContent $_.FullName
        $v = [version]$n.package.metadata.version
        if ($v.Revision -gt 0) {
            [PSCustomObject]@{
                Id = $n.package.metadata.id
                Version=$n.package.metadata.Version
            }
        }
    }
    $labnuspecs
    if ($labnuspecs) {
        throw "labNuspec found in a release build"
    }
}