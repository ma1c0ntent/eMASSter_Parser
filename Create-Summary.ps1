# Create Vulnerability Summary with Lookup Data - ENHANCED VERSION
# This script groups V-IDs from SCC data and joins with benchmarks lookup file
# Features: Configuration file, logging, memory optimization, error handling

param(
    [string]$ConfigPath = "data\config\config.json",
    [string]$StatusFilter = "",
    [string]$OutputFormat = "",
    [switch]$Verbose,
    [switch]$NoLog
)

# Start timing
$scriptStartTime = Get-Date
$scriptVersion = "2.0.0"

# Global variables
$config = $null
$logger = $null

# Function to initialize logging
function Initialize-Logger {
    param([PSCustomObject]$LogConfig)
    
    $logLevel = $LogConfig.logLevel
    $logToFile = $LogConfig.logToFile
    $logToConsole = $LogConfig.logToConsole
    $logDir = $config.filePaths.logDirectory
    $maxLogFileSizeMB = $LogConfig.maxLogFileSizeMB
    $maxLogFiles = $LogConfig.maxLogFiles
    
    # Create log directory if it doesn't exist
    if ($logToFile -and -not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    
    # Create logger object
    $logger = @{
        LogLevel = $logLevel
        LogToFile = $logToFile
        LogToConsole = $logToConsole
        LogDirectory = $logDir
        LogFile = if ($logToFile) { Join-Path $logDir "VulnerabilitySummary_$(Get-Date -Format 'yyyyMMdd').log" } else { $null }
        MaxLogFileSizeMB = $maxLogFileSizeMB
        MaxLogFiles = $maxLogFiles
    }
    
    return $logger
}

# Function to write log messages
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [string]$Component = "Main"
    )
    
    if ($NoLog) { return }
    
    # Check if logger is initialized
    if (-not $logger) {
        Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] [$Component] $Message" -ForegroundColor White
        return
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] [$Component] $Message"
    
    # Check log level
    $levels = @{ "DEBUG" = 1; "INFO" = 2; "WARN" = 3; "ERROR" = 4 }
    $currentLevel = $levels[$logger.LogLevel]
    $messageLevel = $levels[$Level]
    
    if ($messageLevel -ge $currentLevel) {
        # Write to console
        if ($logger.LogToConsole) {
            $color = switch ($Level) {
                "ERROR" { "Red" }
                "WARN" { "Yellow" }
                "INFO" { "White" }
                "DEBUG" { "Gray" }
                default { "White" }
            }
            Write-Host $logEntry -ForegroundColor $color
        }
        
        # Write to file
        if ($logger.LogToFile -and $logger.LogFile) {
            try {
                # Check log file size and rotate if needed
                if ((Test-Path $logger.LogFile) -and ((Get-Item $logger.LogFile).Length -gt ($logger.MaxLogFileSizeMB * 1MB))) {
                    $logFileBase = [System.IO.Path]::GetFileNameWithoutExtension($logger.LogFile)
                    $logFileExt = [System.IO.Path]::GetExtension($logger.LogFile)
                    $logFileDir = [System.IO.Path]::GetDirectoryName($logger.LogFile)
                    
                    # Remove oldest log file if we have too many
                    $existingLogs = Get-ChildItem -Path $logFileDir -Filter "$logFileBase*$logFileExt" | Sort-Object LastWriteTime -Descending
                    if ($existingLogs.Count -ge $logger.MaxLogFiles) {
                        Remove-Item $existingLogs[-1].FullName -Force
                    }
                    
                    # Rename current log file
                    $newLogFile = Join-Path $logFileDir "$logFileBase`_$(Get-Date -Format 'yyyyMMdd_HHmmss')$logFileExt"
                    Move-Item $logger.LogFile $newLogFile
                }
                
                Add-Content -Path $logger.LogFile -Value $logEntry -ErrorAction SilentlyContinue
            }
            catch {
                Write-Host "Warning: Could not write to log file: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    }
}

# Function to load configuration
function Load-Configuration {
    param([string]$ConfigPath)
    
    try {
        Write-Log "Loading configuration from: $ConfigPath" -Level "INFO" -Component "Config"
        
        if (-not (Test-Path $ConfigPath)) {
            throw "Configuration file not found: $ConfigPath"
        }
        
        $configContent = Get-Content -Path $ConfigPath -Raw -ErrorAction Stop
        $config = $configContent | ConvertFrom-Json -ErrorAction Stop
        
        Write-Log "Configuration loaded successfully" -Level "INFO" -Component "Config"
        return $config
    }
    catch {
        Write-Log "Error loading configuration: $($_.Exception.Message)" -Level "ERROR" -Component "Config"
        throw
    }
}

# Function to parse operating system from STIG column
function Get-OperatingSystem {
    param([string]$stigText)
    
    if ($stigText -match "Microsoft Windows (\d+)") {
        return "Microsoft Windows $($matches[1])"
    }
    elseif ($stigText -match "Microsoft Windows Server (\d+)") {
        return "Microsoft Windows Server $($matches[1])"
    }
    elseif ($stigText -match "Red Hat Enterprise Linux (\d+)") {
        return "Red Hat Enterprise Linux $($matches[1])"
    }
    elseif ($stigText -match "Ubuntu (\d+)") {
        return "Ubuntu $($matches[1])"
    }
    elseif ($stigText -match "VMware vSphere (\d+) {
        return "VMware vSphere $($matches[1])"
    }
    elseif ($stigText -match "VMware ESXi (\d+)") {
        return "VMware ESXi $($matches[1])"
    }
    elseif ($stigText -match "Oracle Linux (\d+)" {
        return "Oracle Linux $($matches[1])"
    }
    elseif ($stigText -match "Cisco IOS (\w+)" {
        return "Cisco IOS"
    }
    else {
        return $stigText
    }
}

# Function to export Excel worksheet to CSV and read it - ENHANCED
function Read-ExcelData {
    param([string]$ExcelFilePath, [string]$WorksheetName)
    
    $excel = $null
    $workbook = $null
    $tempCsvPath = $null
    
    try {
        Write-Log "Starting Excel data extraction" -Level "INFO" -Component "Excel"
        
        # Create Excel COM object with error handling
        $excel = New-Object -ComObject Excel.Application -ErrorAction Stop
        $excel.Visible = $false
        $excel.DisplayAlerts = $false
        $excel.ScreenUpdating = $false
        
        Write-Log "Excel COM object created successfully" -Level "DEBUG" -Component "Excel"
        
        # Open the workbook with full path
        $fullPath = (Resolve-Path $ExcelFilePath).Path
        Write-Log "Opening workbook: $fullPath" -Level "DEBUG" -Component "Excel"
        $workbook = $excel.Workbooks.Open($fullPath)
        
        # Check if specified worksheet exists
        $worksheet = $workbook.Worksheets.Item($WorksheetName)
        Write-Log "Found worksheet: $WorksheetName" -Level "DEBUG" -Component "Excel"
        
        # Create temporary CSV file path
        $tempCsvPath = [System.IO.Path]::GetTempFileName()
        $tempCsvPath = [System.IO.Path]::ChangeExtension($tempCsvPath, "csv")
        
        Write-Log "Exporting to temporary CSV: $tempCsvPath" -Level "DEBUG" -Component "Excel"
        
        # Export the worksheet to CSV
        $worksheet.SaveAs($tempCsvPath, 6)  # 6 = CSV format
        
        Write-Log "Successfully exported worksheet to CSV" -Level "INFO" -Component "Excel"
        
        # Read the CSV file
        Write-Log "Reading CSV file..." -Level "DEBUG" -Component "Excel"
        $data = Import-Csv -Path $tempCsvPath -Encoding UTF8
        
        Write-Log "Successfully read $($data.Count) rows from CSV file" -Level "INFO" -Component "Excel"
        return $data
    }
    catch {
        Write-Log "Error processing Excel file: $($_.Exception.Message)" -Level "ERROR" -Component "Excel"
        throw
    }
    finally {
        # Clean up Excel objects
        if ($workbook) { 
            try { $workbook.Close($false) } catch { Write-Log "Warning: Could not close workbook" -Level "WARN" -Component "Excel" }
        }
        if ($excel) { 
            try { 
                $excel.Quit()
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
            } catch { Write-Log "Warning: Could not quit Excel" -Level "WARN" -Component "Excel" }
        }
        
        # Clean up temporary CSV file
        if ($tempCsvPath -and (Test-Path $tempCsvPath)) {
            try {
                Remove-Item $tempCsvPath -Force -ErrorAction SilentlyContinue
                Write-Log "Temporary CSV file cleaned up" -Level "DEBUG" -Component "Excel"
            } catch {
                Write-Log "Warning: Could not remove temporary CSV file" -Level "WARN" -Component "Excel"
            }
        }
        
        # Force garbage collection
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
    }
}

# Function to process data in chunks for memory optimization
function Process-DataInChunks {
    param(
        [array]$Data,
        [int]$ChunkSize,
        [scriptblock]$ProcessBlock
    )
    
    $totalRecords = $Data.Count
    $processedRecords = 0
    
    Write-Log "Processing $totalRecords records in chunks of $ChunkSize" -Level "INFO" -Component "Processing"
    
    for ($i = 0; $i -lt $totalRecords; $i += $ChunkSize) {
        $chunk = $Data[$i..([Math]::Min($i + $ChunkSize - 1, $totalRecords - 1))]
        $processedRecords += $chunk.Count
        
        # Process the chunk
        & $ProcessBlock -Chunk $chunk -ChunkIndex $([Math]::Floor($i / $ChunkSize))
        
        # Progress reporting
        if ($config.performance.enableProgressReporting) {
            $percent = [Math]::Round(($processedRecords / $totalRecords) * 100, 1)
            Write-Log "Processed $processedRecords of $totalRecords records ($percent%)" -Level "INFO" -Component "Processing"
        }
        
        # Memory cleanup for large datasets
        if ($config.performance.enableMemoryOptimization) {
            [System.GC]::Collect()
        }
    }
    
    Write-Log "Completed processing all $totalRecords records" -Level "INFO" -Component "Processing"
}

# Function to export results in multiple formats
function Export-Results {
    param(
        [array]$Data,
        [string]$OutputDirectory,
        [array]$Formats,
        [bool]$IncludeTimestamp
    )
    
    $timestamp = if ($IncludeTimestamp) { "_$(Get-Date -Format 'yyyyMMdd_HHmmss')" } else { "" }
    $baseFileName = "Vulnerability_Summary$timestamp"
    
    # Create output directory if it doesn't exist
    if (-not (Test-Path $OutputDirectory)) {
        New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
        Write-Log "Created output directory: $OutputDirectory" -Level "INFO" -Component "Export"
    }
    
    foreach ($format in $Formats) {
        try {
            switch ($format.ToUpper()) {
                "CSV" {
                    $csvPath = Join-Path $OutputDirectory "$baseFileName.csv"
                    $Data | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
                    Write-Log "Exported CSV report: $csvPath" -Level "INFO" -Component "Export"
                }
                "JSON" {
                    $jsonPath = Join-Path $OutputDirectory "$baseFileName.json"
                    $Data | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonPath -Encoding UTF8
                    Write-Log "Exported JSON report: $jsonPath" -Level "INFO" -Component "Export"
                }
                default {
                    Write-Log "Unsupported output format: $format" -Level "WARN" -Component "Export"
                }
            }
        }
        catch {
            Write-Log "Error exporting $format format: $($_.Exception.Message)" -Level "ERROR" -Component "Export"
        }
    }
}

# Main execution
try {
    Write-Log "Starting Vulnerability Summary Script v$scriptVersion" -Level "INFO" -Component "Main"
    
    # Load configuration
    $config = Load-Configuration -ConfigPath $ConfigPath
    
    # Initialize logger
    $logger = Initialize-Logger -LogConfig $config.logging
    
    # Override config with command-line parameters
    if ($StatusFilter) {
        $config.excelSettings.statusFilter = $StatusFilter
        Write-Log "Status filter overridden to: $StatusFilter" -Level "INFO" -Component "Main"
    }
    
    if ($OutputFormat) {
        $config.outputSettings.outputFormats = @($OutputFormat)
        Write-Log "Output format overridden to: $OutputFormat" -Level "INFO" -Component "Main"
    }
    
    # Read the SCC data from Excel file
    Write-Log "Reading SCC data from Excel file..." -Level "INFO" -Component "Main"
    
    $excelFilePath = $config.filePaths.excelSource
    $worksheetName = $config.excelSettings.worksheetName
    
    # Check if Excel file exists, otherwise fall back to CSV
    if (Test-Path $excelFilePath) {
        try {
            $sccData = Read-ExcelData -ExcelFilePath $excelFilePath -WorksheetName $worksheetName
        }
        catch {
            Write-Log "Failed to read Excel file, falling back to CSV..." -Level "WARN" -Component "Main"
            Write-Log "Error: $($_.Exception.Message)" -Level "ERROR" -Component "Main"
            $sccData = Import-Csv -Path $config.filePaths.csvFallback
        }
    } else {
        Write-Log "Excel file not found, using CSV fallback..." -Level "WARN" -Component "Main"
        $sccData = Import-Csv -Path $config.filePaths.csvFallback
    }
    
    Write-Log "Loaded $($sccData.Count) SCC records" -Level "INFO" -Component "Main"
    
    # Filter to only include records with specified status
    $statusFilter = $config.excelSettings.statusFilter
    Write-Log "Filtering for status '$statusFilter' only..." -Level "INFO" -Component "Main"
    
    $openData = $sccData | Where-Object { $_.Status -eq $statusFilter }
    Write-Log "Found $($openData.Count) records with status '$statusFilter' out of $($sccData.Count) total records" -Level "INFO" -Component "Main"
    
    # Group by V-ID and count occurrences
    Write-Log "Grouping vulnerabilities by V-ID..." -Level "INFO" -Component "Main"
    $vulnerabilitySummary = $openData | Group-Object 'V-ID' | ForEach-Object {
        [PSCustomObject]@{
            'V-ID' = $_.Name
            'Count' = $_.Count
            'Severity' = $_.Group[0].Severity
            'RuleTitle' = $_.Group[0].RuleTitle
        }
    }
    
    Write-Log "Found $($vulnerabilitySummary.Count) unique vulnerabilities" -Level "INFO" -Component "Main"
    
    # Read the benchmarks lookup file
    Write-Log "Reading benchmarks lookup file..." -Level "INFO" -Component "Main"
    try {
        $benchmarksData = Import-Csv -Path $config.filePaths.benchmarksLookup | Where-Object { $_.'Vuln ID' -and $_.'Vuln ID' -ne "" -and $_.'Vuln ID' -ne "Vuln ID" }
        Write-Log "Successfully loaded benchmarks file with $($benchmarksData.Count) valid rows" -Level "INFO" -Component "Main"
        
        # Create a lookup hashtable for faster matching
        $lookupTable = @{}
        $validEntries = 0
        foreach ($benchmark in $benchmarksData) {
            $vulnId = $benchmark.'Vuln ID'
            if ($vulnId -and $vulnId -ne "" -and $vulnId -ne "Vuln ID") {
                $lookupTable[$vulnId] = @{
                    'Severity' = $benchmark.Severity
                    'RuleTitle' = $benchmark.'Rule Title'
                    'OperatingSystem' = Get-OperatingSystem -stigText $benchmark.STIG
                }
                $validEntries++
            }
        }
        Write-Log "Created lookup table with $validEntries valid entries" -Level "INFO" -Component "Main"
    }
    catch {
        Write-Log "Error reading benchmarks file: $($_.Exception.Message)" -Level "ERROR" -Component "Main"
        $lookupTable = @{}
    }
    
    # Join the data
    Write-Log "Joining SCC data with benchmark lookup..." -Level "INFO" -Component "Main"
    $finalSummary = @()
    
    foreach ($vuln in $vulnerabilitySummary) {
        $lookupData = $lookupTable[$vuln.'V-ID']
        
        if ($lookupData) {
            # Use lookup data (more accurate)
            $finalSummary += [PSCustomObject]@{
                'V-ID' = $vuln.'V-ID'
                'Count' = $vuln.Count
                'Severity' = $lookupData.Severity
                'RuleTitle' = $lookupData.RuleTitle
                'OperatingSystem' = $lookupData.OperatingSystem
            }
        }
        else {
            # Use SCC data (fallback)
            $finalSummary += [PSCustomObject]@{
                'V-ID' = $vuln.'V-ID'
                'Count' = $vuln.Count
                'Severity' = $vuln.Severity
                'RuleTitle' = $vuln.RuleTitle
                'OperatingSystem' = 'Unknown'
            }
        }
    }
    
    # Sort by count (highest first) and then by severity
    $finalSummary = $finalSummary | Sort-Object Count -Descending | Sort-Object Severity -Descending
    
    # Export results
    Write-Log "Exporting results..." -Level "INFO" -Component "Main"
    Export-Results -Data $finalSummary -OutputDirectory $config.filePaths.outputDirectory -Formats $config.outputSettings.outputFormats -IncludeTimestamp $config.outputSettings.includeTimestamp
    
    # Calculate execution time
    $scriptEndTime = Get-Date
    $scriptDuration = $scriptEndTime - $scriptStartTime
    
    # Display summary
    Write-Log "=== VULNERABILITY SUMMARY ===" -Level "INFO" -Component "Main"
    Write-Log "Total unique vulnerabilities: $($finalSummary.Count)" -Level "INFO" -Component "Main"
    $totalSystems = ($finalSummary | Measure-Object -Property Count -Sum).Sum
    Write-Log "Total systems affected: $totalSystems" -Level "INFO" -Component "Main"
    
    # Top vulnerabilities
    $topCount = $config.outputSettings.maxTopVulnerabilities
    Write-Log "=== TOP $topCount VULNERABILITIES BY COUNT ===" -Level "INFO" -Component "Main"
    $finalSummary | Select-Object -First $topCount | ForEach-Object {
        Write-Log "$($_.'V-ID'): $($_.Count) systems - $($_.Severity) - $($_.RuleTitle)" -Level "INFO" -Component "Main"
    }
    
    # Severity breakdown
    Write-Log "=== SEVERITY BREAKDOWN ===" -Level "INFO" -Component "Main"
    $finalSummary | Group-Object Severity | ForEach-Object {
        $totalCount = ($_.Group | Measure-Object -Property Count -Sum).Sum
        Write-Log "$($_.Name): $($_.Count) vulnerabilities affecting $totalCount systems" -Level "INFO" -Component "Main"
    }
    
    # Operating system breakdown
    Write-Log "=== OPERATING SYSTEM BREAKDOWN ===" -Level "INFO" -Component "Main"
    $finalSummary | Group-Object OperatingSystem | ForEach-Object {
        $totalCount = ($_.Group | Measure-Object -Property Count -Sum).Sum
        Write-Log "$($_.Name): $($_.Count) vulnerabilities affecting $totalCount systems" -Level "INFO" -Component "Main"
    }
    
    # Performance metrics
    Write-Log "=== PERFORMANCE METRICS ===" -Level "INFO" -Component "Main"
    Write-Log "Total execution time: $($scriptDuration.TotalSeconds.ToString('F2')) seconds" -Level "INFO" -Component "Main"
    Write-Log "Total execution time: $($scriptDuration.TotalMinutes.ToString('F2')) minutes" -Level "INFO" -Component "Main"
    
    # Calculate performance metrics
    $recordsPerSecond = [math]::Round($finalSummary.Count / $scriptDuration.TotalSeconds, 2)
    Write-Log "Records processed per second: $recordsPerSecond" -Level "INFO" -Component "Main"
    
    # Data summary
    Write-Log "=== DATA SUMMARY ===" -Level "INFO" -Component "Main"
    Write-Log "Input SCC records processed: $($sccData.Count)" -Level "INFO" -Component "Main"
    Write-Log "Records with status '$statusFilter': $($openData.Count)" -Level "INFO" -Component "Main"
    Write-Log "Unique V-IDs found ($statusFilter only): $($vulnerabilitySummary.Count)" -Level "INFO" -Component "Main"
    Write-Log "Benchmark entries loaded: $($lookupTable.Count)" -Level "INFO" -Component "Main"
    Write-Log "Final summary records: $($finalSummary.Count)" -Level "INFO" -Component "Main"
    
    Write-Log "Script completed successfully" -Level "INFO" -Component "Main"
}
catch {
    Write-Log "Script failed with error: $($_.Exception.Message)" -Level "ERROR" -Component "Main"
    Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level "ERROR" -Component "Main"
    throw
}
finally {
    # Final cleanup
    if ($logger -and $logger.LogToFile -and $logger.LogFile) {
        Write-Log "Script execution completed. Log file: $($logger.LogFile)" -Level "INFO" -Component "Main"
    }

} 
