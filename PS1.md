# Legacy Java Application Build System

This repository contains the build setup for a legacy Java application originally developed and compiled using Oracle JDeveloper with JDK 1.6.0_05. This document outlines how to compile the project from the command line using `javac`, which is a prerequisite for setting up an Azure DevOps CI/CD pipeline.

## Project Structure

The main application modules are located under `D:\DeploymentChecking_CURR_DEV\EDI_DEV\Project\`. The key modules are:

*   **AirShipmt**: The main application module (`D:\...\Project\AirShipmt\`).
*   **CommonRef**: Contains common types and utilities (`D:\...\Project\CommonRef\`).
*   **Lib**: Contains utility classes and constants (`D:\...\Project\Lib\`).
*   **Control**: Contains control and listener classes (`D:\...\Project\Control\`).

## Dependencies

The project requires external JAR files. Ensure these are available on the system:
*   **JDK**: `jdk1.6.0_05` (or similar 1.6.x version)
*   **Oracle XDK**: `oracle.xdk_11.1.1.xml.jar`, `oracle.xdk_11.1.1.xmlparserv2.jar`
*   **Oracle JDBC**: `classes12.jar`, `classes12dms.jar`, `nls_charset12.jar` (from `C:\jdbc9051\`)

## Building the Project

The build must follow a specific order due to inter-module dependencies.

### 1. Manual Step-by-Step Build

Execute the following commands in a PowerShell environment **in the specified order**.

```powershell
# Set the JDK 1.6 Home directory. UPDATE THIS PATH TO MATCH YOUR SYSTEM.
$env:JAVA_HOME = "C:\Program Files\Java\jdk1.6.0_45"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

# Set the project root directory. UPDATE THIS PATH TO MATCH YOUR SYSTEM.
$projectRoot = "D:\DeploymentChecking_CURR_DEV\EDI_DEV\Project"

# 1. Compile CommonRef Module (foundation classes)
javac -d "$projectRoot\CommonRef\classes" "$projectRoot\CommonRef\src\*\*.java"
if ($LASTEXITCODE -ne 0) { throw "CommonRef compilation failed" }

# 2. Compile Lib Module (depends on CommonRef)
javac -d "$projectRoot\Lib\classes" -cp "$projectRoot\CommonRef\classes" "$projectRoot\Lib\src\*\*.java"
if ($LASTEXITCODE -ne 0) { throw "Lib compilation failed" }

# 3. Compile Control Module (depends on CommonRef and Lib)
$controlCP = "$projectRoot\CommonRef\classes;$projectRoot\Lib\classes"
javac -d "$projectRoot\Control\classes" -cp $controlCP "$projectRoot\Control\src\*\*.java"
if ($LASTEXITCODE -ne 0) { throw "Control compilation failed" }

# 4. Compile the Main AirShipmt Module (depends on all others and external JARs)
$airShipmtCP = @(
    "$projectRoot\CommonRef\classes",
    "$projectRoot\Lib\classes",
    "$projectRoot\Control\classes",
    "C:\jdbc9051\classes12.jar",          # External JAR
    "C:\jdbc9051\classes12dms.jar",       # External JAR
    "C:\Oracle\Middleware\jdeveloper\modules\oracle.xdk_11.1.1.xmlparserv2.jar" # External JAR
) -join ";"

javac -d "$projectRoot\AirShipmt\classes" -cp $airShipmtCP "$projectRoot\AirShipmt\src\AirShipmtBusiness\*.java"
if ($LASTEXITCODE -ne 0) { throw "AirShipmt compilation failed" }

Write-Host "Build completed successfully!" -ForegroundColor Green



2. Automated Build Script
For convenience, use the provided build.ps1 PowerShell script.

Open the script and update the $JAVA_HOME and $projectRoot variables at the top to match your system's paths.

Run the script from PowerShell:

# Navigate to the script's directory
cd <path-to-this-repo>

# Execute the build script
.\build.ps1


--------

Azure DevOps Pipeline Setup
This command-line build process is designed to be easily ported to an Azure DevOps pipeline. The future pipeline task will need to:

Checkout this repository.

Install a JDK 1.6 toolchain on the agent (or use a self-hosted agent with it pre-installed).

Download the required external JAR dependencies (XDK, JDBC) from a secure file repository (e.g., Azure Artifacts, a private NuGet feed) and place them in the expected directory structure.

Run the build.ps1 script or the individual javac commands as a PowerShell task.

Troubleshooting Common Errors
package ... does not exist: This indicates a missing dependency. Ensure the modules are compiled in the correct order and that the classpath (-cp) includes the classes directory of the required module.

cannot find symbol: Often a symptom of the same missing dependency issue above. Check the import statements in your .java files against the compiled classes.

javac is not recognized: The JAVA_HOME and PATH environment variables are not set correctly for the JDK 1.6 installation.

invalid flag: --release: You are using a modern javac instead of the legacy JDK 1.6 version. Double-check your JAVA_HOME and PATH.



---

### File 2: `build.ps1`

Copy and paste this into a file named `build.ps1` in the root of your project.

```powershell
# build.ps1
# Legacy Java Application Build Script
# Pre-requisite: JDK 1.6 must be installed and paths configured below.

# ===== CONFIGURATION - UPDATE THESE PATHS TO MATCH YOUR SYSTEM =====
# Path to the JDK 1.6 installation
$JAVA_HOME = "C:\Program Files\Java\jdk1.6.0_45"
# Root directory of the EDI project
$projectRoot = "D:\DeploymentChecking_CURR_DEV\EDI_DEV\Project"

# ===== SCRIPT START =====
Write-Host "Setting up environment for JDK 1.6..." -ForegroundColor Yellow
$env:PATH = "$JAVA_HOME\bin;" + $env:PATH

# Function to check if a directory exists
function Test-Directory {
    param([string]$Path, [string]$Name)
    if (!(Test-Path $Path)) {
        Write-Error "Directory not found: $Name ($Path). Please check the `$projectRoot variable." 
        exit 1
    }
}

# Validate crucial directories
Write-Host "Validating project structure..." -ForegroundColor Yellow
Test-Directory -Path "$projectRoot\CommonRef\src" -Name "CommonRef Source"
Test-Directory -Path "$projectRoot\Lib\src" -Name "Lib Source"
Test-Directory -Path "$projectRoot\Control\src" -Name "Control Source"
Test-Directory -Path "$projectRoot\AirShipmt\src" -Name "AirShipmt Source"

# Create 'classes' directories if they don't exist
@("$projectRoot\CommonRef\classes", "$projectRoot\Lib\classes", "$projectRoot\Control\classes", "$projectRoot\AirShipmt\classes") | ForEach-Object {
    if (!(Test-Path $_)) {
        Write-Host "Creating directory: $_" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

# Function to run javac and check for errors
function Invoke-Javac {
    param([string]$Arguments, [string]$ModuleName)
    Write-Host "Compiling $ModuleName..." -ForegroundColor Green
    Write-Host "javac $Arguments" -ForegroundColor Gray

    $process = Start-Process -FilePath "javac" -ArgumentList $Arguments -NoNewWindow -Wait -PassThru

    if ($process.ExitCode -ne 0) {
        Write-Error "Compilation failed for $ModuleName with exit code $($process.ExitCode)."
        exit $process.ExitCode
    }
    Write-Host "$ModuleName compiled successfully." -ForegroundColor Green
}

try {
    # 1. Compile CommonRef Module
    $commonRefArgs = @(
        "-d", "`"$projectRoot\CommonRef\classes`"",
        "`"$projectRoot\CommonRef\src\*\*.java`""
    ) -join " "
    Invoke-Javac -Arguments $commonRefArgs -ModuleName "CommonRef"

    # 2. Compile Lib Module (depends on CommonRef)
    $libCP = "`"$projectRoot\CommonRef\classes`""
    $libArgs = @(
        "-d", "`"$projectRoot\Lib\classes`"",
        "-cp", $libCP,
        "`"$projectRoot\Lib\src\*\*.java`""
    ) -join " "
    Invoke-Javac -Arguments $libArgs -ModuleName "Lib"

    # 3. Compile Control Module (depends on CommonRef and Lib)
    $controlCP = "`"$projectRoot\CommonRef\classes;$projectRoot\Lib\classes`""
    $controlArgs = @(
        "-d", "`"$projectRoot\Control\classes`"",
        "-cp", $controlCP,
        "`"$projectRoot\Control\src\*\*.java`""
    ) -join " "
    Invoke-Javac -Arguments $controlArgs -ModuleName "Control"

    # 4. Compile the Main AirShipmt Module
    $airShipmtCP = @(
        "`"$projectRoot\CommonRef\classes`"",
        "`"$projectRoot\Lib\classes`"",
        "`"$projectRoot\Control\classes`"",
        "`"C:\jdbc9051\classes12.jar`"",
        "`"C:\jdbc9051\classes12dms.jar`"",
        "`"C:\Oracle\Middleware\jdeveloper\modules\oracle.xdk_11.1.1.xmlparserv2.jar`""
    ) -join ";"

    $airShipmtArgs = @(
        "-d", "`"$projectRoot\AirShipmt\classes`"",
        "-cp", "`"$airShipmtCP`"",
        "-source", "1.6",
        "-target", "1.6",
        # "-encoding", "Cp1256", # Uncomment if encoding issues occur
        "`"$projectRoot\AirShipmt\src\AirShipmtBusiness\*.java`""
    ) -join " "
    Invoke-Javac -Arguments $airShipmtArgs -ModuleName "AirShipmt"

    Write-Host "`nBuild completed successfully for all modules!" -ForegroundColor Cyan
}
catch {
    Write-Error "An unexpected error occurred: $($_.Exception.Message)"
    exit 1
}



How to Upload to GitHub
Create a new repository on GitHub.

On your local machine, create a new folder for the project.

Save the two text blocks above as README.md and build.ps1 in that folder.

Crucially, open the build.ps1 file and update the $JAVA_HOME and $projectRoot variables at the top to point to the correct paths on your system.
