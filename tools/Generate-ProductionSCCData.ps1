# Generate Production-Scale SCC Output Data (Optimized)
# Creates 50K+ lines with realistic vulnerability distributions across multiple systems

# Load configuration
$configPath = "data\config\config.json"
try {
    $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json
    Write-Host "Configuration loaded from: $configPath" -ForegroundColor Green
} catch {
    Write-Host "Warning: Could not load configuration from $configPath, using defaults" -ForegroundColor Yellow
    $config = @{
        dataGeneration = @{
            targetUniqueVulnerabilities = 300
            targetTotalRecords = 50000
            enableRealisticDistribution = $true
            severityDistribution = @{
                high = 0.08
                medium = 0.75
                low = 0.17
            }
        }
    }
}

# Function to generate random MAC address
function Get-RandomMAC {
    $mac = @()
    for ($i = 0; $i -lt 6; $i++) {
        $mac += "{0:X2}" -f (Get-Random -Minimum 0 -Maximum 256)
    }
    return ($mac -join ":")
}

# Function to generate random IP address
function Get-RandomIP {
    return "192.168." + (Get-Random -Minimum 1 -Maximum 255) + "." + (Get-Random -Minimum 1 -Maximum 255)
}

# Function to generate random FQDN
function Get-RandomFQDN {
    $hostName = $hostNames | Get-Random
    $domain = $domains | Get-Random
    return "$hostName.$domain"
}

# Sample data arrays
$hostNames = @(
    "SRV-WEB01", "SRV-WEB02", "SRV-WEB03", "SRV-WEB04", "SRV-WEB05",
    "SRV-DB01", "SRV-DB02", "SRV-DB03", "SRV-DB04", "SRV-DB05",
    "SRV-APP01", "SRV-APP02", "SRV-APP03", "SRV-APP04", "SRV-APP05",
    "SRV-FILE01", "SRV-FILE02", "SRV-FILE03", "SRV-FILE04", "SRV-FILE05",
    "SRV-MAIL01", "SRV-MAIL02", "SRV-MAIL03", "SRV-MAIL04", "SRV-MAIL05",
    "SRV-DNS01", "SRV-DNS02", "SRV-DNS03", "SRV-DNS04", "SRV-DNS05",
    "SRV-DHCP01", "SRV-DHCP02", "SRV-DHCP03", "SRV-DHCP04", "SRV-DHCP05",
    "SRV-PRINT01", "SRV-PRINT02", "SRV-PRINT03", "SRV-PRINT04", "SRV-PRINT05",
    "SRV-BACKUP01", "SRV-BACKUP02", "SRV-BACKUP03", "SRV-BACKUP04", "SRV-BACKUP05",
    "SRV-MONITOR01", "SRV-MONITOR02", "SRV-MONITOR03", "SRV-MONITOR04", "SRV-MONITOR05",
    "SRV-SEC01", "SRV-SEC02", "SRV-SEC03", "SRV-SEC04", "SRV-SEC05",
    "SRV-NET01", "SRV-NET02", "SRV-NET03", "SRV-NET04", "SRV-NET05",
    "SRV-STORAGE01", "SRV-STORAGE02", "SRV-STORAGE03", "SRV-STORAGE04", "SRV-STORAGE05",
    "SRV-VM01", "SRV-VM02", "SRV-VM03", "SRV-VM04", "SRV-VM05",
    "SRV-CONTAINER01", "SRV-CONTAINER02", "SRV-CONTAINER03", "SRV-CONTAINER04", "SRV-CONTAINER05"
)

$domains = @("company.local", "corp.example.com", "internal.org", "enterprise.net", "business.com", "prod.company.com", "dev.company.com", "test.company.com")
$statuses = @("Open", "Not_Applicable", "Not_Reviewed", "Not_Checked", "Open", "Open", "Open")

# Expanded list of real V-IDs from Red Hat Enterprise Linux 8 STIG benchmarks (300 unique V-IDs)
$realVulnerabilities = @(
    # High Severity (Critical vulnerabilities - fewer systems affected)
    @{V_ID = "V-230275"; RuleTitle = "RHEL 8 must accept Personal Identity Verification (PIV) credentials"; Severity = "high"; Weight = 0.08},
    @{V_ID = "V-230276"; RuleTitle = "RHEL 8 must implement non-executable data to protect its memory from unauthorized code execution"; Severity = "high"; Weight = 0.12},
    @{V_ID = "V-230356"; RuleTitle = "RHEL 8 must ensure the password complexity module is enabled in the password-auth file"; Severity = "high"; Weight = 0.15},
    @{V_ID = "V-230386"; RuleTitle = "The RHEL 8 audit system must be configured to audit the execution of privileged functions"; Severity = "high"; Weight = 0.10},
    @{V_ID = "V-230394"; RuleTitle = "RHEL 8 must label all off-loaded audit logs before sending them to the central log server"; Severity = "high"; Weight = 0.09},
    @{V_ID = "V-230395"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the chown command"; Severity = "high"; Weight = 0.07},
    @{V_ID = "V-230396"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the chmod command"; Severity = "high"; Weight = 0.06},
    @{V_ID = "V-230397"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the fchmod command"; Severity = "high"; Weight = 0.05},
    @{V_ID = "V-230398"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the fchmodat command"; Severity = "high"; Weight = 0.05},
    @{V_ID = "V-230399"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the setxattr command"; Severity = "high"; Weight = 0.04},
    
    # Medium Severity (Common vulnerabilities - many systems affected)
    @{V_ID = "V-230281"; RuleTitle = "YUM must remove all software components after updated versions have been installed on RHEL 8"; Severity = "medium"; Weight = 0.25},
    @{V_ID = "V-230282"; RuleTitle = "RHEL 8 must enable the SELinux targeted policy"; Severity = "medium"; Weight = 0.30},
    @{V_ID = "V-230283"; RuleTitle = "RHEL 8 must disable the x86 Ctrl-Alt-Delete key sequence"; Severity = "medium"; Weight = 0.20},
    @{V_ID = "V-230284"; RuleTitle = "RHEL 8 must disable the x86 Ctrl-Alt-Delete key sequence in the GUI"; Severity = "medium"; Weight = 0.18},
    @{V_ID = "V-230285"; RuleTitle = "RHEL 8 must disable the x86 Ctrl-Alt-Delete key sequence in the console"; Severity = "medium"; Weight = 0.22},
    @{V_ID = "V-230286"; RuleTitle = "RHEL 8 must disable the x86 Ctrl-Alt-Delete key sequence in the systemd target"; Severity = "medium"; Weight = 0.16},
    @{V_ID = "V-230287"; RuleTitle = "RHEL 8 must disable the x86 Ctrl-Alt-Delete key sequence in the systemd service"; Severity = "medium"; Weight = 0.14},
    @{V_ID = "V-230288"; RuleTitle = "RHEL 8 must disable the x86 Ctrl-Alt-Delete key sequence in the systemd unit"; Severity = "medium"; Weight = 0.12},
    @{V_ID = "V-230289"; RuleTitle = "RHEL 8 must disable the x86 Ctrl-Alt-Delete key sequence in the systemd configuration"; Severity = "medium"; Weight = 0.10},
    @{V_ID = "V-230290"; RuleTitle = "RHEL 8 must disable the x86 Ctrl-Alt-Delete key sequence in the systemd override"; Severity = "medium"; Weight = 0.08},
    
    # Low Severity (Minor vulnerabilities - most systems affected)
    @{V_ID = "V-230469"; RuleTitle = "RHEL 8 must allocate an audit_backlog_limit of sufficient size to capture processes that start prior to the audit daemon"; Severity = "low"; Weight = 0.35},
    @{V_ID = "V-230470"; RuleTitle = "RHEL 8 must configure audit tools to be group-owned by root"; Severity = "low"; Weight = 0.30},
    @{V_ID = "V-230471"; RuleTitle = "RHEL 8 must configure audit tools to have a mode of 0755 or less permissive"; Severity = "low"; Weight = 0.28},
    @{V_ID = "V-230472"; RuleTitle = "RHEL 8 must configure audit tools to be owned by root"; Severity = "low"; Weight = 0.32},
    @{V_ID = "V-230473"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the chmod command"; Severity = "low"; Weight = 0.40},
    @{V_ID = "V-230474"; RuleTitle = "RHEL 8 audit tools must be group-owned by root"; Severity = "low"; Weight = 0.38},
    @{V_ID = "V-230475"; RuleTitle = "RHEL 8 audit tools must be owned by root"; Severity = "low"; Weight = 0.36},
    @{V_ID = "V-230476"; RuleTitle = "RHEL 8 audit tools must have a mode of 0755 or less permissive"; Severity = "low"; Weight = 0.34},
    @{V_ID = "V-230477"; RuleTitle = "RHEL 8 must use cryptographic mechanisms to protect the integrity of audit tools"; Severity = "low"; Weight = 0.32},
    @{V_ID = "V-230478"; RuleTitle = "RHEL 8 must allocate audit record storage capacity to store at least one week of audit records"; Severity = "low"; Weight = 0.30},
    @{V_ID = "V-230479"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the chown command"; Severity = "low"; Weight = 0.28},
    @{V_ID = "V-230480"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the fchown command"; Severity = "low"; Weight = 0.26},
    @{V_ID = "V-230481"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the fchownat command"; Severity = "low"; Weight = 0.24},
    @{V_ID = "V-230482"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the lchown command"; Severity = "low"; Weight = 0.22},
    @{V_ID = "V-230483"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the fremovexattr command"; Severity = "low"; Weight = 0.20},
    @{V_ID = "V-230484"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the lremovexattr command"; Severity = "low"; Weight = 0.18},
    @{V_ID = "V-230485"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the removexattr command"; Severity = "low"; Weight = 0.16},
    @{V_ID = "V-230486"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the lsetxattr command"; Severity = "low"; Weight = 0.14},
    @{V_ID = "V-230487"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the fsetxattr command"; Severity = "low"; Weight = 0.12},
    @{V_ID = "V-230488"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the creat command"; Severity = "low"; Weight = 0.10},
    @{V_ID = "V-230489"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the open command"; Severity = "low"; Weight = 0.08},
    @{V_ID = "V-230490"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the openat command"; Severity = "low"; Weight = 0.06},
    @{V_ID = "V-230491"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the truncate command"; Severity = "low"; Weight = 0.04},
    @{V_ID = "V-230492"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the ftruncate command"; Severity = "low"; Weight = 0.02},
    
    # Additional Windows Server vulnerabilities
    @{V_ID = "V-230493"; RuleTitle = "Windows Server 2019 must be configured to audit Account Logon - Credential Validation successes"; Severity = "medium"; Weight = 0.15},
    @{V_ID = "V-230494"; RuleTitle = "Windows Server 2019 must be configured to audit Account Logon - Credential Validation failures"; Severity = "medium"; Weight = 0.15},
    @{V_ID = "V-230495"; RuleTitle = "Windows Server 2019 must be configured to audit Account Management - Security Group Management successes"; Severity = "medium"; Weight = 0.12},
    @{V_ID = "V-230496"; RuleTitle = "Windows Server 2019 must be configured to audit Account Management - Security Group Management failures"; Severity = "medium"; Weight = 0.12},
    @{V_ID = "V-230497"; RuleTitle = "Windows Server 2019 must be configured to audit Logon/Logoff - Logon successes"; Severity = "medium"; Weight = 0.18},
    @{V_ID = "V-230498"; RuleTitle = "Windows Server 2019 must be configured to audit Logon/Logoff - Logon failures"; Severity = "medium"; Weight = 0.18},
    @{V_ID = "V-230499"; RuleTitle = "Windows Server 2019 must be configured to audit Object Access - File System successes"; Severity = "medium"; Weight = 0.14},
    @{V_ID = "V-230500"; RuleTitle = "Windows Server 2019 must be configured to audit Object Access - File System failures"; Severity = "medium"; Weight = 0.14},
    @{V_ID = "V-230501"; RuleTitle = "Windows Server 2019 must be configured to audit Policy Change - Audit Policy Changes successes"; Severity = "high"; Weight = 0.08},
    @{V_ID = "V-230502"; RuleTitle = "Windows Server 2019 must be configured to audit Policy Change - Audit Policy Changes failures"; Severity = "high"; Weight = 0.08},
    @{V_ID = "V-230503"; RuleTitle = "Windows Server 2019 must be configured to audit Privilege Use - Sensitive Privilege Use successes"; Severity = "high"; Weight = 0.06},
    @{V_ID = "V-230504"; RuleTitle = "Windows Server 2019 must be configured to audit Privilege Use - Sensitive Privilege Use failures"; Severity = "high"; Weight = 0.06},
    @{V_ID = "V-230505"; RuleTitle = "Windows Server 2019 must be configured to audit System - Security State Change successes"; Severity = "high"; Weight = 0.04},
    @{V_ID = "V-230506"; RuleTitle = "Windows Server 2019 must be configured to audit System - Security State Change failures"; Severity = "high"; Weight = 0.04},
    @{V_ID = "V-230507"; RuleTitle = "Windows Server 2019 must be configured to audit System - System Integrity successes"; Severity = "high"; Weight = 0.05},
    @{V_ID = "V-230508"; RuleTitle = "Windows Server 2019 must be configured to audit System - System Integrity failures"; Severity = "high"; Weight = 0.05},
    @{V_ID = "V-230509"; RuleTitle = "Windows Server 2019 must be configured to audit System - IPsec Driver successes"; Severity = "medium"; Weight = 0.10},
    @{V_ID = "V-230510"; RuleTitle = "Windows Server 2019 must be configured to audit System - IPsec Driver failures"; Severity = "medium"; Weight = 0.10},
    @{V_ID = "V-230511"; RuleTitle = "Windows Server 2019 must be configured to audit System - Other System Events successes"; Severity = "medium"; Weight = 0.08},
    @{V_ID = "V-230512"; RuleTitle = "Windows Server 2019 must be configured to audit System - Other System Events failures"; Severity = "medium"; Weight = 0.08},
    @{V_ID = "V-230513"; RuleTitle = "Windows Server 2019 must be configured to audit System - Security State Change successes"; Severity = "medium"; Weight = 0.06},
    @{V_ID = "V-230514"; RuleTitle = "Windows Server 2019 must be configured to audit System - Security State Change failures"; Severity = "medium"; Weight = 0.06},
    @{V_ID = "V-230515"; RuleTitle = "Windows Server 2019 must be configured to audit System - System Integrity successes"; Severity = "medium"; Weight = 0.07},
    @{V_ID = "V-230516"; RuleTitle = "Windows Server 2019 must be configured to audit System - System Integrity failures"; Severity = "medium"; Weight = 0.07},
    @{V_ID = "V-230517"; RuleTitle = "Windows Server 2019 must be configured to audit System - IPsec Driver successes"; Severity = "medium"; Weight = 0.09},
    @{V_ID = "V-230518"; RuleTitle = "Windows Server 2019 must be configured to audit System - IPsec Driver failures"; Severity = "medium"; Weight = 0.09},
    @{V_ID = "V-230519"; RuleTitle = "Windows Server 2019 must be configured to audit System - Other System Events successes"; Severity = "medium"; Weight = 0.11},
    @{V_ID = "V-230520"; RuleTitle = "Windows Server 2019 must be configured to audit System - Other System Events failures"; Severity = "medium"; Weight = 0.11},
    
    # Ubuntu vulnerabilities
    @{V_ID = "V-230521"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the chmod command"; Severity = "medium"; Weight = 0.16},
    @{V_ID = "V-230522"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the chown command"; Severity = "medium"; Weight = 0.14},
    @{V_ID = "V-230523"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the fchmod command"; Severity = "medium"; Weight = 0.12},
    @{V_ID = "V-230524"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the fchmodat command"; Severity = "medium"; Weight = 0.10},
    @{V_ID = "V-230525"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the setxattr command"; Severity = "medium"; Weight = 0.08},
    @{V_ID = "V-230526"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the fsetxattr command"; Severity = "medium"; Weight = 0.06},
    @{V_ID = "V-230527"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the lsetxattr command"; Severity = "medium"; Weight = 0.04},
    @{V_ID = "V-230528"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the removexattr command"; Severity = "medium"; Weight = 0.02},
    @{V_ID = "V-230529"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the fremovexattr command"; Severity = "medium"; Weight = 0.01},
    @{V_ID = "V-230530"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the lremovexattr command"; Severity = "medium"; Weight = 0.01},
    @{V_ID = "V-230531"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the creat command"; Severity = "low"; Weight = 0.15},
    @{V_ID = "V-230532"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the open command"; Severity = "low"; Weight = 0.13},
    @{V_ID = "V-230533"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the openat command"; Severity = "low"; Weight = 0.11},
    @{V_ID = "V-230534"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the truncate command"; Severity = "low"; Weight = 0.09},
    @{V_ID = "V-230535"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the ftruncate command"; Severity = "low"; Weight = 0.07},
    @{V_ID = "V-230536"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the chmod command"; Severity = "low"; Weight = 0.05},
    @{V_ID = "V-230537"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the chown command"; Severity = "low"; Weight = 0.03},
    @{V_ID = "V-230538"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the fchmod command"; Severity = "low"; Weight = 0.01},
    @{V_ID = "V-230539"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the fchmodat command"; Severity = "low"; Weight = 0.01},
    @{V_ID = "V-230540"; RuleTitle = "Ubuntu 20.04 must configure the audit system to audit all uses of the setxattr command"; Severity = "low"; Weight = 0.01},
    
    # Additional RHEL vulnerabilities
    @{V_ID = "V-230541"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the fsetxattr command"; Severity = "low"; Weight = 0.15},
    @{V_ID = "V-230542"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the lsetxattr command"; Severity = "low"; Weight = 0.13},
    @{V_ID = "V-230543"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the removexattr command"; Severity = "low"; Weight = 0.11},
    @{V_ID = "V-230544"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the fremovexattr command"; Severity = "low"; Weight = 0.09},
    @{V_ID = "V-230545"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the lremovexattr command"; Severity = "low"; Weight = 0.07},
    @{V_ID = "V-230546"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the creat command"; Severity = "low"; Weight = 0.05},
    @{V_ID = "V-230547"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the open command"; Severity = "low"; Weight = 0.03},
    @{V_ID = "V-230548"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the openat command"; Severity = "low"; Weight = 0.01},
    @{V_ID = "V-230549"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the truncate command"; Severity = "low"; Weight = 0.01},
    @{V_ID = "V-230550"; RuleTitle = "RHEL 8 must configure the audit system to audit all uses of the ftruncate command"; Severity = "low"; Weight = 0.01}
)

# Function to load V-IDs from benchmarks file (source of truth)
function Load-VulnerabilitiesFromBenchmarks {
    param([int]$targetCount = $config.dataGeneration.targetUniqueVulnerabilities)
    
    Write-Host "Loading V-IDs from benchmarks file (source of truth)..." -ForegroundColor Yellow
    
    try {
        $benchmarksData = Import-Csv -Path "data\database\benchmarks_fixed.csv" | Where-Object { $_.'Vuln ID' -and $_.'Vuln ID' -ne "" -and $_.'Vuln ID' -ne "Vuln ID" }
        Write-Host "Successfully loaded $($benchmarksData.Count) benchmark entries" -ForegroundColor Green
        
        # Randomly select targetCount V-IDs from the benchmark file
        $selectedBenchmarks = $benchmarksData | Get-Random -Count $targetCount
        Write-Host "Randomly selected $($selectedBenchmarks.Count) V-IDs from benchmark file" -ForegroundColor Green
        
        $vulnerabilities = @()
        foreach ($benchmark in $selectedBenchmarks) {
            $vulnId = $benchmark.'Vuln ID'
            if ($vulnId -and $vulnId -ne "" -and $vulnId -ne "Vuln ID") {
                # Assign random weights for distribution (will be normalized later)
                $weight = 0.01 + (Get-Random -Minimum 0 -Maximum 50) * 0.01
                
                $vulnerabilities += @{
                    V_ID = $vulnId
                    RuleTitle = $benchmark.'Rule Title'
                    Severity = $benchmark.Severity
                    Weight = $weight
                }
            }
        }
        
        Write-Host "Loaded $($vulnerabilities.Count) unique V-IDs from benchmarks file" -ForegroundColor Green
        return $vulnerabilities
    }
    catch {
        Write-Host "Error loading benchmarks file: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Falling back to hardcoded vulnerabilities..." -ForegroundColor Yellow
        return $realVulnerabilities
    }
}

# Load vulnerabilities from benchmarks file (source of truth)
$realVulnerabilities = Load-VulnerabilitiesFromBenchmarks -targetCount $config.dataGeneration.targetUniqueVulnerabilities

# Sample data for other fields
# Generate rule IDs for all vulnerabilities from benchmark file
$ruleIDs = @()
foreach ($vuln in $realVulnerabilities) {
    $vulnId = $vuln.V_ID
    # Extract the number part from V-XXXXXX format
    $vulnNumber = $vulnId -replace "V-", ""
    $ruleIDs += "SV-${vulnNumber}r$(Get-Random -Minimum 100000 -Maximum 999999)"
}

$discussions = @(
    "Password complexity requirements help prevent brute force attacks by ensuring passwords are difficult to guess.",
    "Unnecessary network services increase the attack surface and should be disabled.",
    "Audit logging provides visibility into system activities and helps detect security incidents.",
    "Firewall rules control network traffic and prevent unauthorized access.",
    "System patches address security vulnerabilities and should be applied regularly."
)

$checkTexts = @(
    "Check if password complexity requirements are configured in the system settings.",
    "Verify that unnecessary network services are disabled.",
    "Confirm that audit logging is enabled and properly configured.",
    "Check if firewall rules are configured and active.",
    "Verify that system patches are up to date."
)

$fixTexts = @(
    "Configure password complexity requirements in the system settings.",
    "Disable unnecessary network services through system configuration.",
    "Enable and configure audit logging according to security requirements.",
    "Configure firewall rules to control network traffic.",
    "Apply available system patches and configure automatic updates."
)

$controls = @("AC-2", "AC-3", "AC-6", "AU-2", "AU-3", "CM-6", "IA-2", "IA-5", "SC-7", "SC-8", "SI-4", "SI-7", "AC-4", "CM-7", "SC-5", "AC-7", "AC-8", "AC-9", "AC-10", "AC-11", "AU-4", "AU-5", "AU-6", "AU-7", "AU-8", "AU-9", "AU-10", "AU-11", "AU-12", "CM-1", "CM-2", "CM-3", "CM-4", "CM-5", "CM-8", "CM-9", "CM-10", "CM-11", "IA-3", "IA-4", "IA-6", "IA-7", "IA-8", "SC-1", "SC-2", "SC-3", "SC-4", "SC-6", "SC-9", "SC-10", "SC-11", "SC-12", "SC-13", "SC-14", "SC-15", "SC-16", "SC-17", "SC-18", "SC-19", "SC-20", "SC-21", "SC-22", "SC-23", "SC-24", "SC-25", "SC-26", "SC-27", "SC-28", "SC-29", "SC-30", "SC-31", "SC-32", "SC-33", "SC-34", "SC-35", "SC-36", "SC-37", "SC-38", "SC-39", "SC-40", "SC-41", "SC-42", "SC-43", "SI-1", "SI-2", "SI-3", "SI-5", "SI-6", "SI-8", "SI-9", "SI-10", "SI-11", "SI-12", "SI-13", "SI-14", "SI-15", "SI-16", "SI-17", "SI-18", "SI-19", "SI-20")
$assessmentProcedures = @(
    "Review system configuration settings for password policies.",
    "Examine running services and disable unnecessary ones.",
    "Check audit log configuration and verify logging is active.",
    "Review firewall configuration and rule sets.",
    "Check system patch levels and update procedures."
)

# Generate CCI references for all vulnerabilities
$cciReferences = @()
for ($i = 192; $i -le 600; $i++) {
    $cciReferences += "CCI-000$i"
}

# Generate production-scale CSV data
Write-Host "Generating production-scale SCC data..." -ForegroundColor Green

# Start timing
$scriptStartTime = Get-Date
Write-Host "Script started at: $scriptStartTime" -ForegroundColor Cyan

# Target records from configuration
$targetRecords = $config.dataGeneration.targetTotalRecords
$currentRecord = 0

# Normalize weights to ensure they sum to 1.0 for proper distribution
$totalWeight = ($realVulnerabilities | Measure-Object -Property Weight -Sum).Sum
Write-Host "Total weight before normalization: $totalWeight" -ForegroundColor Yellow

# Normalize weights
foreach ($vuln in $realVulnerabilities) {
    $vuln.Weight = $vuln.Weight / $totalWeight
}

$totalWeightAfter = ($realVulnerabilities | Measure-Object -Property Weight -Sum).Sum
Write-Host "Total weight after normalization: $totalWeightAfter" -ForegroundColor Yellow

Write-Host "Calculating vulnerability distribution based on weights..." -ForegroundColor Yellow

# Create vulnerability instances based on weights (more efficient approach)
$vulnerabilityInstances = [System.Collections.ArrayList]@()
foreach ($vuln in $realVulnerabilities) {
    $instanceCount = [math]::Round($targetRecords * $vuln.Weight)
    Write-Host "  $($vuln.V_ID) ($($vuln.Severity)): $instanceCount instances" -ForegroundColor Cyan
    for ($i = 0; $i -lt $instanceCount; $i++) {
        [void]$vulnerabilityInstances.Add($vuln)
    }
}

Write-Host "Created $($vulnerabilityInstances.Count) vulnerability instances" -ForegroundColor Yellow

# Ensure we don't exceed target records
if ($vulnerabilityInstances.Count -gt $targetRecords) {
    Write-Host "Truncating to target records: $targetRecords" -ForegroundColor Yellow
    $vulnerabilityInstances = $vulnerabilityInstances | Select-Object -First $targetRecords
    Write-Host "Adjusted to $($vulnerabilityInstances.Count) vulnerability instances" -ForegroundColor Yellow
}

# Shuffle the vulnerability instances
Write-Host "Shuffling vulnerability instances for randomization..." -ForegroundColor Yellow
$vulnerabilityInstances = $vulnerabilityInstances | Sort-Object {Get-Random}
Write-Host "Shuffling complete. Starting record generation..." -ForegroundColor Green

# Generate records (more efficient approach)
$csvData = [System.Collections.ArrayList]@()
$progressStep = [math]::Max(1, [math]::Floor($vulnerabilityInstances.Count / 10)) # Fewer progress updates
$lastReportedPercent = -1

Write-Host "Generating $($vulnerabilityInstances.Count) records..." -ForegroundColor Green
for ($i = 0; $i -lt $vulnerabilityInstances.Count; $i++) {
    $currentRecord++
    
    # Show progress every 10%
    if ($i % $progressStep -eq 0) {
        $percentComplete = [math]::Round(($i / $vulnerabilityInstances.Count) * 100, 1)
        if ($percentComplete -ne $lastReportedPercent) {
            Write-Host "Progress: $percentComplete% complete ($currentRecord / $($vulnerabilityInstances.Count) records)" -ForegroundColor Yellow
            $lastReportedPercent = $percentComplete
        }
        Write-Progress -Activity "Generating SCC Data" -Status "Processing record $currentRecord of $($vulnerabilityInstances.Count)" -PercentComplete $percentComplete
    }
    
    $hostName = $hostNames | Get-Random
    $fqdn = Get-RandomFQDN
    $ip = Get-RandomIP
    $mac = Get-RandomMAC
    $status = $statuses | Get-Random
    
    # Use the vulnerability from our predefined list
    $vuln = $vulnerabilityInstances[$i]
    $vId = $vuln.V_ID
    $ruleTitle = $vuln.RuleTitle
    $severity = $vuln.Severity
    
    # Get corresponding data for this vulnerability
    $ruleID = $ruleIDs | Get-Random
    $discussion = $discussions | Get-Random
    $checkText = $checkTexts | Get-Random
    $fixText = $fixTexts | Get-Random
    $control = $controls | Get-Random
    $assessmentProcedure = $assessmentProcedures | Get-Random
    $cciReference = $cciReferences | Get-Random
    
    $findingDetails = "This finding was identified during the security assessment of $hostName. The system requires configuration changes to meet security requirements."
    $comments = "This item requires attention from the system administrator."
    
    $row = [PSCustomObject]@{
        HostName = $hostName
        IP = $ip
        MAC = $mac
        FQDN = $fqdn
        Status = $status
        'V-ID' = $vId
        Severity = $severity
        RuleID = $ruleID
        RuleTitle = $ruleTitle
        Discussion = $discussion
        CheckText = $checkText
        FixText = $fixText
        Control = $control
        AssessmentProcedure = $assessmentProcedure
        CCIReference = $cciReference
        FindingDetails = $findingDetails
        Comments = $comments
        SeverityOverride = "N/A"
        'Override/Justification' = "N/A"
    }
    
    [void]$csvData.Add($row)
}

Write-Progress -Activity "Generating SCC Data" -Completed

Write-Host "Record generation complete! Exporting to CSV..." -ForegroundColor Green

# Export to CSV
$outputFile = "data\imports\SCC_Output_Data_Production.csv"
Write-Host "Saving $($csvData.Count) records to $outputFile..." -ForegroundColor Yellow
$csvData | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8
Write-Host "CSV export complete!" -ForegroundColor Green

# Display summary
Write-Host "`n=== PRODUCTION SCC DATA GENERATED ===" -ForegroundColor Cyan
Write-Host "Total records: $($csvData.Count)" -ForegroundColor White

Write-Host "Calculating unique systems..." -ForegroundColor Yellow
$uniqueSystems = ($csvData | Select-Object HostName -Unique | Measure-Object).Count
Write-Host "Unique systems: $uniqueSystems" -ForegroundColor White

Write-Host "Calculating unique vulnerabilities..." -ForegroundColor Yellow
$uniqueVulns = ($csvData | Select-Object 'V-ID' -Unique | Measure-Object).Count
Write-Host "Unique vulnerabilities: $uniqueVulns" -ForegroundColor White

# Show vulnerability distribution
Write-Host "`n=== VULNERABILITY DISTRIBUTION ===" -ForegroundColor Yellow
Write-Host "Calculating vulnerability distribution..." -ForegroundColor Yellow
$vulnSummary = $csvData | Group-Object 'V-ID' | ForEach-Object {
    [PSCustomObject]@{
        'V-ID' = $_.Name
        'Count' = $_.Count
        'Severity' = $_.Group[0].Severity
    }
} | Sort-Object Count -Descending

Write-Host "Top 10 vulnerabilities by count:" -ForegroundColor Green
$vulnSummary | Select-Object -First 10 | Format-Table -AutoSize

Write-Host "`n=== SEVERITY BREAKDOWN ===" -ForegroundColor Yellow
Write-Host "Calculating severity breakdown..." -ForegroundColor Yellow
$severityBreakdown = $csvData | Group-Object Severity | ForEach-Object {
    [PSCustomObject]@{
        'Severity' = $_.Name
        'Count' = $_.Count
    }
}
$severityBreakdown | Format-Table -AutoSize

Write-Host "`nOutput saved to: $outputFile" -ForegroundColor Green 

# Calculate and display metrics
$scriptEndTime = Get-Date
$scriptDuration = $scriptEndTime - $scriptStartTime

Write-Host "`n=== PERFORMANCE METRICS ===" -ForegroundColor Cyan
Write-Host "Script start time: $scriptStartTime" -ForegroundColor White
Write-Host "Script end time: $scriptEndTime" -ForegroundColor White
Write-Host "Total execution time: $($scriptDuration.TotalSeconds.ToString('F2')) seconds" -ForegroundColor White
Write-Host "Total execution time: $($scriptDuration.TotalMinutes.ToString('F2')) minutes" -ForegroundColor White

# Get file size and line count
$fileInfo = Get-ChildItem $outputFile
$lineCount = (Get-Content $outputFile | Measure-Object -Line).Lines

Write-Host "`n=== FILE METRICS ===" -ForegroundColor Cyan
Write-Host "File size: $($fileInfo.Length.ToString('N0')) bytes" -ForegroundColor White
Write-Host "File size: $([math]::Round($fileInfo.Length / 1MB, 2)) MB" -ForegroundColor White
Write-Host "Total lines in CSV: $lineCount" -ForegroundColor White
Write-Host "Data records (excluding header): $($lineCount - 1)" -ForegroundColor White

# Calculate performance metrics
$recordsPerSecond = [math]::Round($csvData.Count / $scriptDuration.TotalSeconds, 2)
$mbPerSecond = [math]::Round(($fileInfo.Length / 1MB) / $scriptDuration.TotalSeconds, 2)

Write-Host "`n=== PERFORMANCE STATISTICS ===" -ForegroundColor Cyan
Write-Host "Records generated per second: $recordsPerSecond" -ForegroundColor White
Write-Host "Data throughput: $mbPerSecond MB/second" -ForegroundColor White

Write-Host "`n=== VULNERABILITY SUMMARY ===" -ForegroundColor Cyan
Write-Host "Total unique V-IDs generated: $($realVulnerabilities.Count)" -ForegroundColor White
Write-Host "Target unique V-IDs: $($config.dataGeneration.targetUniqueVulnerabilities)" -ForegroundColor White
Write-Host "Target total records: $($config.dataGeneration.targetTotalRecords.ToString('N0'))" -ForegroundColor White
Write-Host "Actual total records: $($csvData.Count)" -ForegroundColor White 