# Enhanced Vulnerability Summary Script

## Overview
This enhanced version of the vulnerability summary script includes configuration file support, comprehensive logging, memory optimization, and better error handling.

## Directory Structure

The script uses a centralized `data/` directory structure for better organization:

```
emasster/
├── Create-Summary.ps1                        # Enhanced script
├── tools/                                    # Development utilities
│   └── Generate-ProductionSCCData.ps1        # Data generator
└── data/                                     # Centralized data directory
    ├── config/                               # Configuration files
    │   └── config.json
    ├── database/                             # Database and lookup files
    │   └── benchmarks_fixed.csv
    ├── imports/                              # Input data files
    │   ├── eMASSterOutput.xlsx               # Excel source data
    │   └── SCC_Output_Data_Production.csv    # CSV fallback data
    ├── logs/                                 # Log files
    │   └── VulnerabilitySummary_YYYYMMDD.log
    └── reports/                              # Output reports
        ├── Vulnerability_Summary_YYYYMMDD_HHMMSS.csv
        └── Vulnerability_Summary_YYYYMMDD_HHMMSS.json
```

## Features

### 🔧 Configuration Management
- **config.json**: Centralized configuration for all file paths and settings
- **Command-line parameters**: Override configuration settings at runtime
- **Flexible output formats**: CSV, JSON, and more

### 📊 Logging System
- **Multi-level logging**: DEBUG, INFO, WARN, ERROR
- **File and console output**: Configurable logging destinations
- **Log rotation**: Automatic log file management with size limits
- **Component-based logging**: Track different parts of the script execution

### ⚡ Performance Optimizations
- **Memory management**: Optimized for large datasets
- **Chunked processing**: Process data in configurable chunks
- **Progress reporting**: Optional progress updates during processing

### 🛡️ Error Handling
- **Robust error recovery**: Graceful handling of file access issues
- **Detailed error logging**: Comprehensive error tracking
- **Fallback mechanisms**: Automatic fallback to CSV if Excel fails

## Usage

### Basic Usage
```powershell
# Run with default configuration
.\Create-Summary.ps1

# Run with custom configuration file
.\Create-Summary.ps1 -ConfigPath "data\config\my-config.json"

# Run with different status filter
.\Create-Summary.ps1 -StatusFilter "Not_Reviewed"

# Run with specific output format
.\Create-Summary.ps1 -OutputFormat "JSON"

# Run without logging
.\Create-Summary.ps1 -NoLog
```

### Command-Line Parameters
- `-ConfigPath`: Path to configuration file (default: config.json)
- `-StatusFilter`: Override status filter from config
- `-OutputFormat`: Override output format from config
- `-Verbose`: Enable verbose output
- `-NoLog`: Disable logging

## Configuration File (config.json)

### File Paths
```json
{
    "filePaths": {
        "excelSource": "path/to/excel/file.xlsx",
        "csvFallback": "path/to/csv/file.csv",
        "benchmarksLookup": "data\\database\\benchmarks_fixed.csv",
        "outputDirectory": "data\\reports",
        "logDirectory": "data\\logs"
    }
}
```

### Excel Settings
```json
{
    "excelSettings": {
        "worksheetName": "Checklist Details",
        "statusFilter": "Open"
    }
}
```

### Output Settings
```json
{
    "outputSettings": {
        "includeTimestamp": true,
        "outputFormats": ["CSV", "JSON"],
        "maxTopVulnerabilities": 10
    }
}
```

### Logging Settings
```json
{
    "logging": {
        "logLevel": "INFO",
        "logToFile": true,
        "logToConsole": true,
        "maxLogFileSizeMB": 10,
        "maxLogFiles": 5
    }
}
```

### Performance Settings
```json
{
    "performance": {
        "chunkSize": 5000,
        "enableMemoryOptimization": true,
        "enableProgressReporting": false
    }
}
```

### Data Generation Settings
```json
{
    "dataGeneration": {
        "targetUniqueVulnerabilities": 300,
        "targetTotalRecords": 50000,
        "enableRealisticDistribution": true,
        "severityDistribution": {
            "high": 0.08,
            "medium": 0.75,
            "low": 0.17
        }
    }
}
```

## Output Files

### Reports Directory (`data/reports/`)
- **CSV Report**: `Vulnerability_Summary_YYYYMMDD_HHMMSS.csv`
- **JSON Report**: `Vulnerability_Summary_YYYYMMDD_HHMMSS.json`

### Logs Directory (`data/logs/`)
- **Daily Log**: `VulnerabilitySummary_YYYYMMDD.log`
- **Rotated Logs**: `VulnerabilitySummary_YYYYMMDD_HHMMSS.log`

### Database Directory (`data/database/`)
- **Benchmarks**: `benchmarks_fixed.csv` - Vulnerability lookup data

### Config Directory (`data/config/`)
- **Configuration**: `config.json` - Main configuration file

### Tools Directory (`tools/`)
- **Data Generator**: `Generate-ProductionSCCData.ps1` - Creates synthetic test data
- **Configuration**: Uses settings from `data/config/config.json`

## Performance Metrics

The script provides detailed performance metrics:
- **Execution time**: Total script runtime
- **Records processed per second**: Processing throughput
- **Memory usage**: Optimized for large datasets
- **File metrics**: Output file sizes and record counts

## Error Handling

The script includes comprehensive error handling:
- **File access errors**: Graceful fallback to alternative sources
- **Excel COM errors**: Automatic cleanup and recovery
- **Configuration errors**: Clear error messages and suggestions
- **Memory errors**: Automatic garbage collection and optimization

## Log Levels

- **DEBUG**: Detailed debugging information
- **INFO**: General information about script execution
- **WARN**: Warning messages for non-critical issues
- **ERROR**: Error messages for critical failures

## Examples

### Filter for Different Status
```powershell
.\Create-Summary.ps1 -StatusFilter "Not_Reviewed"
```

### Generate JSON Only
```powershell
.\Create-Summary.ps1 -OutputFormat "JSON"
```

### Use Custom Configuration
```powershell
.\Create-Summary.ps1 -ConfigPath "data\config\production-config.json"
```

### Silent Mode (No Console Output)
```powershell
.\Create-Summary.ps1 -NoLog
```

## Troubleshooting

### Common Issues

1. **Configuration file not found**
   - Ensure `config.json` exists in the script directory
   - Check file permissions

2. **Excel file access issues**
   - Ensure Excel file is not open in another application
   - Check file path in configuration

3. **Memory issues with large datasets**
   - Reduce `chunkSize` in performance settings
   - Enable memory optimization

4. **Log file access issues**
   - Check log directory permissions
   - Ensure sufficient disk space

### Log Analysis

Check the log file for detailed execution information:
```powershell
Get-Content "data\logs\VulnerabilitySummary_$(Get-Date -Format 'yyyyMMdd').log"
```

## Version History

- **v2.0.0**: Enhanced version with configuration, logging, and optimization
- **v1.x**: Original streamlined version 