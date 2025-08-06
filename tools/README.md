# Tools Directory

This directory contains development utilities and tools for the Vulnerability Summary Script project.

## Scripts

### Generate-ProductionSCCData.ps1
**Purpose**: Generates synthetic SCC (Security Content Automation Protocol) data for testing and development purposes.

**Features**:
- Creates configurable number of realistic vulnerability records
- Generates configurable number of unique V-IDs with proper severity distribution
- Simulates multiple systems across different operating systems
- Outputs data in the correct format for the main script
- Uses configuration file for customizable settings

**Usage**:
```powershell
# From the project root directory
.\tools\Generate-ProductionSCCData.ps1
```

**Output**:
- Generates `data/imports/SCC_Output_Data_Production.csv`
- Creates realistic vulnerability data for testing the main script
- Provides performance metrics and data statistics

**When to Use**:
- Setting up a new development environment
- Testing the main script with different data scenarios
- Creating sample data for demonstrations
- Performance testing with large datasets
- Customizing data generation parameters via config file

## Development Workflow

1. **Generate Test Data**: Run `Generate-ProductionSCCData.ps1` to create sample data
2. **Test Main Script**: Use the generated data with `Create-Summary.ps1`
3. **Iterate**: Modify data generation parameters as needed

## File Organization

- **Input**: Script uses `data/database/benchmarks_fixed.csv` for V-ID lookup
- **Configuration**: Script reads settings from `data/config/config.json`
- **Output**: Generated data goes to `data/imports/SCC_Output_Data_Production.csv`
- **Integration**: Generated data can be used directly by the main script

## Configuration Options

The script reads the following settings from `data/config/config.json`:

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

- **targetUniqueVulnerabilities**: Number of unique V-IDs to generate
- **targetTotalRecords**: Total number of records to create
- **enableRealisticDistribution**: Whether to use realistic severity distribution
- **severityDistribution**: Percentage breakdown of high/medium/low severity vulnerabilities

## Notes

- This script is for development/testing purposes only
- Generated data is synthetic and should not be used in production
- The script creates realistic but fictional vulnerability data
- Performance metrics help optimize the main script's processing 