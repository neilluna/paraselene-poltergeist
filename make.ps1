[CmdletBinding()]
Param(
    [switch]$Build,
    [switch]$Clean,
    [switch]$Install,
    [switch]$Uninstall
)

# If nothing is specified, then build.
If (-not $Build -and
    -not $Clean -and
    -not $Install -and
    -not $Uninstall -and
    -not $UninstallData) {
    $Build = $true
}

# Install implies build. Install does an Uninstall first.
If ($Install) {
    $Build = $true
    $Uninstall = $true
}

# Build does a Clean first.
If ($Build) {
    $Clean = $true
}

Add-Type -assembly System.IO.Compression.FileSystem

# Parse an INI file.
Function Parse-IniFile ($iniFile) {
    $ini = @{}

    # Create a default section.
    $section = "NO_SECTION"
    $ini[$section] = @{}

    switch -regex -file $iniFile {
        "^\[(.+)\]$" {
            $section = $matches[1].Trim()
            $ini[$section] = @{}
        }
        "^\s*([^#].+?)\s*=\s*(.*)" {
            $name,$value = $matches[1..2]
            # skip comments that start with semicolon:
            if (!($name.StartsWith(";"))) {
                $ini[$section][$name] = $value.Trim()
            }
        }
    }
    $ini
}

# Set the version in the files of a directory recursively.
Function Set-Version($path, $apiVersion, $majorVersion, $minorVersion, $patchVersion, $schemaVersion) {
    $version = $majorVersion + '.' + $minorVersion + '.' + $patchVersion
    Write-Verbose (
        'Setting ' + $path + ' to api ' + $apiVersion + ', version ' + $version + ', schema ' + $schemaVersion
    )
    ForEach ($file in Get-ChildItem -Path $path -File) {
        $target = $path + '\' + $file.Name
        Write-Verbose ('Processing ' + $target)
        (Get-Content $target).Replace('[API_VERSION]', $apiVersion) | Set-Content $target
        (Get-Content $target).Replace('[MAJOR_VERSION]', $majorVersion) | Set-Content $target
        (Get-Content $target).Replace('[MINOR_VERSION]', $minorVersion) | Set-Content $target
        (Get-Content $target).Replace('[PATCH_VERSION]', $patchVersion) | Set-Content $target
        (Get-Content $target).Replace('[FULL_VERSION]', $version) | Set-Content $target
        (Get-Content $target).Replace('[SCHEMA_VERSION]', $schemaVersion) | Set-Content $target
    }
    ForEach ($dir in Get-ChildItem -Path $path -Directory) {
        Set-Version ($path + '\' + $dir.Name) $apiVersion $majorVersion $minorVersion $patchVersion $schemaVersion
    }
}

$srcDir = $PSScriptRoot + '\src'
$buildDir = $PSScriptRoot + '\obj'
$distDir = $PSScriptRoot + '\dist'
$addOnDir = $env:USERPROFILE + '\Documents\Elder Scrolls Online\live\AddOns'

If ($Clean) {
    @($buildDir, $distDir) | ForEach-Object -Process {
        If (Test-Path -Path $PSItem -PathType Container) {
            # Remove the existing build directories, if they exist.
            Write-Verbose ('Removing ' + $PSItem)
            Remove-Item -Path $PSItem -Recurse -Force
        }
    }
}

If ($Build) {
    # Parse the build information.
    $buildInfoFile = $PSScriptRoot + '\build-info.ini'
    If (-Not (Test-Path -Path $buildInfoFile -PathType Leaf)) {
        Throw ($buildInfoFile + ' not found.')
    }
    $buildInfo = Parse-IniFile $buildInfoFile    
    $majorVersion = $buildInfo['Version']['major']
    $minorVersion = $buildInfo['Version']['minor']
    $patchVersion = $buildInfo['Version']['patch']
    $version = $majorVersion + '.' + $minorVersion + '.' + $patchVersion
    $apiVersion = $buildInfo['Version']['api']
    $schemaVersion = $buildInfo['Version']['schema']

    # Create the new build directory.
    Write-Verbose ('Creating ' + $buildDir)
    New-Item -Path $buildDir -ItemType Directory | out-null

    # Copy the source directories to the build directory.
    ForEach ($dir in Get-ChildItem -Path $srcDir -Directory) {
        Write-Verbose ('Copying ' + $srcDir + '\' + $dir.Name + ' to ' + $buildDir)
        Copy-Item -Path ($srcDir + '\' + $dir.Name) -Destination $buildDir -Recurse

        # Add the readme, changelog, and license files to the build directory.
        Write-Verbose ('Adding README.md, CHANGELOG.md, and LICENSE.txt to ' + ($buildDir + '\' + $dir.Name))
        Copy-Item -Path ($PSScriptRoot + '\README.md') -Destination ($buildDir + '\' + $dir.Name)
        Copy-Item -Path ($PSScriptRoot + '\CHANGELOG.md') -Destination ($buildDir + '\' + $dir.Name)
        Copy-Item -Path ($PSScriptRoot + '\LICENSE.txt') -Destination ($buildDir + '\' + $dir.Name)
    }

    # Version brand the files in the build directory.
    Set-Version $buildDir $apiVersion $majorVersion $minorVersion $patchVersion $schemaVersion

    # Create the new distribution directory.
    Write-Verbose ('Creating ' + $distDir)
    New-Item -Path $distDir -ItemType Directory | out-null

    # Create the zip files.
    ForEach ($dir in Get-ChildItem -Path $buildDir -Directory) {
        $addOnObjDir = $buildDir + '\' + $dir.Name
        $addOnZipFile = $distDir + '\' + $dir.Name + '-' + $version + '.zip'
        Write-Verbose ('Creating ' + $addOnZipFile)
        [System.IO.Compression.ZipFile]::CreateFromDirectory($addOnObjDir, $addOnZipFile, 'Optimal', $True)
    }
}

If ($Uninstall) {
    If (-Not (Test-Path -Path $addOnDir -PathType Container)) {
        Throw ($addOnDir + ' not found.')
    }
    ForEach ($dir in Get-ChildItem -Path $srcDir -Directory) {
        $addOnDir = $addOnDir + '\' + $dir.Name
        If (Test-Path -Path $addOnDir -PathType Container) {
            Write-Verbose ('Removing ' + $addOnDir)
            Remove-Item -Path $addOnDir -Recurse -Force
        }
    }
}

If ($Install) {
    ForEach ($dir in Get-ChildItem -Path $buildDir -Directory) {
        Write-Verbose ('Copying ' + $buildDir + '\' + $dir.Name + ' to ' + $addOnDir)
        Copy-Item -Path ($buildDir + '\' + $dir.Name) -Destination $addOnDir -Recurse
    }
}
