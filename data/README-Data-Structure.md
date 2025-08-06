# Data Directory Structure

This directory contains all data files organized in a logical structure for the Vulnerability Summary Script.

## Directory Layout

```
data/
├── config/          # Configuration files
│   └── config.json  # Main configuration file
├── database/        # Database and lookup files
│   └── benchmarks_fixed.csv  # Vulnerability benchmarks lookup
├── imports/         # Input data files
│   ├── eMASSterOutput.xlsx   # Excel source data
│   └── SCC_Output_Data_Production.csv  # CSV fallback data
├── logs/           # Log files
│   └── VulnerabilitySummary_YYYYMMDD.log
└── reports/        # Output reports
    ├── Vulnerability_Summary_YYYYMMDD_HHMMSS.csv
    └── Vulnerability_Summary_YYYYMMDD_HHMMSS.json
```

**Note**: Development tools are located in the `tools/` directory at the project root.

## File Descriptions

### config/
- **config.json**: Main configuration file containing all script settings
  - File paths for inputs and outputs
  - Excel settings (worksheet name, status filter)
  - Output settings (formats, timestamps)
  - Logging configuration
  - Performance settings

### database/
- **benchmarks_fixed.csv**: Vulnerability benchmarks lookup table
  - Contains V-ID mappings to severity, rule titles, and operating systems
  - Used as the authoritative source for vulnerability information

### imports/
- **eMASSterOutput.xlsx**: Primary Excel source data
  - Contains the "Checklist Details" worksheet with vulnerability data
  - Used as the main input for vulnerability analysis
- **SCC_Output_Data_Production.csv**: Fallback CSV data source
  - Used when Excel file is unavailable or fails to load
  - Provides alternative data source for script reliability

### logs/
- **VulnerabilitySummary_YYYYMMDD.log**: Daily log files
  - Contains detailed execution logs with timestamps
  - Automatic rotation when file size exceeds 10MB
  - Keeps up to 5 log files

### reports/
- **Vulnerability_Summary_YYYYMMDD_HHMMSS.csv**: CSV format vulnerability summary
- **Vulnerability_Summary_YYYYMMDD_HHMMSS.json**: JSON format vulnerability summary
  - Both files contain the same data in different formats
  - Timestamped to prevent overwriting previous reports

## Usage

The script automatically uses this structure when run from the parent directory:

```powershell
# From the parent directory (emasster/)
.\Create-Summary.ps1
```

The script will:
1. Load configuration from `data/config/config.json`
2. Read benchmarks from `data/database/benchmarks_fixed.csv`
3. Write logs to `data/logs/`
4. Generate reports in `data/reports/`

## Customization

To use a different configuration file:

```powershell
.\Create-Summary.ps1 -ConfigPath "path/to/custom-config.json"
```

## Backup and Maintenance

- **Backup**: Copy the entire `data/` directory to preserve all configuration and historical data
- **Cleanup**: Old log files are automatically rotated, but you may want to periodically clean old reports
- **Updates**: When updating the script, the `data/` structure will be preserved 