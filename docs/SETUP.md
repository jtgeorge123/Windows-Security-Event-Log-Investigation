# Setup & Reproducibility Guide

## Overview

This guide enables you to reproduce the Windows Security Event log analysis shown in this project. You can run the provided scripts and tools to analyze your own systems or recreate the investigation methodology.

## Prerequisites

### System Requirements
- **Operating System**: Windows 10 or later (Windows 11 recommended)
- **Privileges**: Administrator rights (required to access Security logs)
- **PowerShell**: Version 5.0 or later
- **Storage**: 100 MB free space for log exports

### Verification

#### Check Windows Version
```powershell
# Open PowerShell as Administrator and run:
$PSVersionTable
```

Expected output: PSVersion 5.0 or higher

#### Check Administrator Status
```powershell
# Run this in PowerShell:
[Security.Principal.WindowsIdentity]::GetCurrent() | 
  Select-Object -ExpandProperty Groups | 
  Where-Object {$_ -match 'S-1-5-32-544'} | 
  Measure-Object | 
  Select-Object Count
```

If Count = 1: You have admin rights ✅

## Environment Setup

### Step 1: Prepare Working Directory

```powershell
# Create analysis directory
$AnalysisFolder = "C:\SecurityAnalysis"
New-Item -ItemType Directory -Path $AnalysisFolder -Force

# Create subdirectories for organized output
New-Item -ItemType Directory -Path "$AnalysisFolder\Logs" -Force
New-Item -ItemType Directory -Path "$AnalysisFolder\Results" -Force

cd $AnalysisFolder
```

### Step 2: Verify Event Log Access

```powershell
# Check if Security log is accessible
$LogTest = Get-WinEvent -LogName Security -MaxEvents 1 -ErrorAction SilentlyContinue

if ($LogTest) {
    Write-Host "✅ Security log accessible" -ForegroundColor Green
} else {
    Write-Host "❌ Cannot access Security log - run as Administrator" -ForegroundColor Red
}
```

### Step 3: Copy Analysis Scripts

Copy the PowerShell scripts from the `scripts/` directory to your analysis folder:

```powershell
# If files are in repository
Copy-Item "..\..\scripts\*.ps1" "$AnalysisFolder\"

# Verify scripts copied
Get-ChildItem "$AnalysisFolder\*.ps1"
```

## Running Analysis Scripts

### Script 1: Export Security Logs

**Purpose**: Extract security events from Event Viewer into CSV files for analysis

**Location**: `scripts/export-logs.ps1`

#### Basic Usage

```powershell
# Export all security events from last 24 hours
.\export-logs.ps1 -Hours 24 -OutputPath ".\Results"
```

#### Advanced Options

```powershell
# Export from specific time range
.\export-logs.ps1 -Hours 72 -OutputPath ".\Results" -Verbose

# Export specific Event IDs
.\export-logs.ps1 -EventIDs @(4624, 4625) -Hours 24 -OutputPath ".\Results"

# Export with comprehensive details
.\export-logs.ps1 `
  -Hours 48 `
  -OutputPath ".\Results" `
  -IncludeDetails `
  -Verbose
```

#### Output Files

The script creates CSV files:
- `SecurityEvents_4624_*.csv` - Successful logons
- `SecurityEvents_4625_*.csv` - Failed logons
- `SecurityEvents_4634_*.csv` - Logoff events
- `SecurityEvents_4672_*.csv` - Privilege assignments

#### Example Command

```powershell
# Export last 24 hours to detailed CSV
$ExportPath = "C:\SecurityAnalysis\Results"
.\export-logs.ps1 -Hours 24 -OutputPath $ExportPath -IncludeDetails -Verbose

# View results
Get-ChildItem "$ExportPath\*.csv" | Format-Table Name, Length
```

### Script 2: Analyze Logs

**Purpose**: Process exported logs to identify patterns and anomalies

**Location**: `scripts/analyze-logs.ps1`

#### Basic Usage

```powershell
# Analyze exported CSV files
.\analyze-logs.ps1 -CsvFolder ".\Results" -OutputReport ".\Results\Analysis.html"
```

#### Advanced Usage

```powershell
# Detailed analysis with statistics
.\analyze-logs.ps1 `
  -CsvFolder ".\Results" `
  -OutputReport ".\Results\Analysis.html" `
  -IncludeCharts `
  -Verbose

# Analyze specific event type
.\analyze-logs.ps1 `
  -CsvFolder ".\Results" `
  -EventType 4625 `
  -OutputReport ".\Results\FailedLogons.html"
```

#### Output

Generates HTML report with:
- Event statistics
- Time-based distribution charts
- Account activity analysis
- Anomaly detection
- Recommendations

#### View Results

```powershell
# Open generated report in browser
Invoke-Item ".\Results\Analysis.html"
```

## Manual Analysis Using Event Viewer

If you prefer GUI-based analysis, follow these steps:

### Step 1: Open Event Viewer

```powershell
# Method 1: PowerShell command
eventvwr.msc

# Method 2: Search in Start Menu
# Search for "Event Viewer" and launch
```

### Step 2: Navigate to Security Logs

1. Click on **Windows Logs** in left panel
2. Select **Security** (requires admin privileges)
3. You'll see list of security events

### Step 3: Apply Filters

1. Right-click on **Security** → **Filter Current Log**
2. In filter dialog:
   - **Event ID**: Enter event ID (e.g., 4624)
   - **Time Range**: Select date/time range
   - **Level**: Ensure Information is checked

3. Click **OK**

### Step 4: Review Event Details

1. Click on any event to view full details
2. In **Details** tab, see all fields with values
3. Compare against field descriptions in [EVENT-IDS.md](EVENT-IDS.md)

### Step 5: Export Filtered Events

1. Right-click on filtered results
2. Click **Save All Events As...**
3. Choose format:
   - **CSV Table** - Easy to analyze in Excel
   - **XML** - Preserves all details
4. Specify save location

## Analysis Workflow

### Complete Analysis Process

```
1. SETUP
   └─ Prepare directory and scripts
   
2. COLLECTION
   ├─ Run export-logs.ps1
   └─ Verify CSV files created
   
3. ANALYSIS
   ├─ Run analyze-logs.ps1
   ├─ Review generated report
   └─ Or: Manual analysis in Event Viewer
   
4. INTERPRETATION
   ├─ Compare findings to baseline
   ├─ Identify anomalies
   └─ Document results
   
5. REPORTING
   ├─ Create findings summary
   ├─ Document recommendations
   └─ Generate report for stakeholders
```

### Example: Complete Analysis Session

```powershell
# 1. Create analysis directory
$AnalysisRoot = "C:\SecurityAnalysis"
New-Item -ItemType Directory -Path $AnalysisRoot -Force

# 2. Navigate to scripts
cd $AnalysisRoot

# 3. Export logs from last 48 hours
Write-Host "Step 1: Exporting security logs..."
.\export-logs.ps1 -Hours 48 -OutputPath ".\Results" -Verbose

# 4. Wait for export to complete
Start-Sleep -Seconds 10

# 5. Analyze exported logs
Write-Host "Step 2: Analyzing logs..."
.\analyze-logs.ps1 -CsvFolder ".\Results" -OutputReport ".\Results\Analysis.html" -Verbose

# 6. Open results
Write-Host "Step 3: Opening analysis report..."
Invoke-Item ".\Results\Analysis.html"

Write-Host "✅ Analysis complete!" -ForegroundColor Green
```

## Data Analysis in Excel

### Import CSV Files

1. **Open Excel**
2. **File → Open** → Select CSV file
3. **Data → From Text** wizard:
   - Delimiter: Comma
   - Click **Next**
   - Verify column headers
   - Click **Finish**

### Create Pivot Tables

```
1. Select data range
2. Insert → Pivot Table
3. Choose:
   - Rows: Event ID or Account Name
   - Values: Count of records
   - Filters: Time range or other criteria
4. Click OK
```

### Create Charts

```
1. Select data
2. Insert → Chart
3. Choose chart type:
   - Column chart for event distribution
   - Timeline chart for time-based analysis
   - Pie chart for account breakdown
4. Customize as needed
```

### Analysis Queries

#### Find Failed Logins by Account

```excel
Filter Column: Event ID = 4625
Pivot by: Account Name
Count: Number of failures
Sort by: Count (descending)
```

#### Identify Logon Times

```excel
Filter: Event ID = 4624
Column: Time extracted from EventTime
Pivot: Hour of day
Analyze: Peak logon times
```

#### Track Session Duration

```excel
Create column: =TIMEDIFF(Logon_Time, Logoff_Time)
Analyze: Average session duration
Identify: Outliers (unusually long/short)
```

## Security Baseline Establishment

### Create Your Baseline

Use initial analysis to establish normal patterns:

#### Event Frequency Baseline
```
Document:
- Average events per hour (each ID)
- Peak activity times
- Off-hours activity level
- Expected event rate

Set Alerts When:
- 2x normal event rate for 1 hour
- Any events outside business hours
- Specific event count thresholds
```

#### Account Activity Baseline
```
Document per account:
- Normal logon times
- Expected logon sources
- Typical session duration
- Expected privilege assignments

Alert on:
- Logon from unexpected IP
- Logon at unusual time
- Unexpected privilege elevation
- Rapid logon/logoff cycles
```

#### Storage Considerations

```powershell
# Calculate log growth rate
$LogSize = (Get-ChildItem "C:\Windows\System32\winevt\Logs\Security.evtx").Length / 1MB
Write-Host "Current Security log: $([math]::Round($LogSize, 2)) MB"

# Estimate retention
$DaysRetention = 90  # Policy: 90 days
$DailyGrowth = 50    # MB per day (estimate)
$StorageNeeded = $DailyGrowth * $DaysRetention
Write-Host "Storage for $DaysRetention days: $StorageNeeded MB"
```

## Troubleshooting

### Issue: "Access Denied" when accessing Security logs

```powershell
# Solution 1: Run PowerShell as Administrator
# - Right-click PowerShell → Run as Administrator

# Solution 2: Verify permissions
whoami /groups | findstr /C:"S-1-5-32-544"
# Should show BUILTIN\Administrators

# Solution 3: Check Event Log service
Get-Service EventLog | Format-List Status
# Should show: Running
```

### Issue: No events found or too few events

```powershell
# Verify events exist
Get-WinEvent -LogName Security | Measure-Object
# Shows total event count

# Check security log is enabled
Get-WinEvent -ListLog Security

# Verify filter syntax
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624} -MaxEvents 5
```

### Issue: Scripts won't execute

```powershell
# Check execution policy
Get-ExecutionPolicy

# Temporarily allow script execution (admin only)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or run specific script
PowerShell.exe -ExecutionPolicy Bypass -File ".\export-logs.ps1"
```

### Issue: Export file too large

```powershell
# Reduce time range
.\export-logs.ps1 -Hours 12  # Instead of 24+

# Export single event ID at a time
.\export-logs.ps1 -EventIDs @(4624) -Hours 24

# Filter by time window
Get-WinEvent -FilterHashtable @{
    LogName='Security'
    StartTime=(Get-Date).AddDays(-1)
    EndTime=(Get-Date)
} | Export-Csv "output.csv"
```

## Integration with SIEM Systems

### Export for Splunk

```powershell
# Export with additional metadata
Get-WinEvent -LogName Security -MaxEvents 10000 |
  Select-Object TimeCreated, Id, Message, ProviderName |
  Export-Csv "splunk-import.csv"

# Upload to Splunk via HTTP Event Collector
# See Splunk documentation for HEC integration
```

### Export for ELK Stack

```powershell
# Export in JSON format
Get-WinEvent -LogName Security | ConvertTo-Json |
  Out-File "events.json"

# Or use Winlogbeat for real-time streaming
# https://www.elastic.co/guide/en/beats/winlogbeat/
```

## Next Steps

1. **Review METHODOLOGY.md** - Understand investigation approach
2. **Review EVENT-IDS.md** - Deep dive into event interpretation
3. **Review FINDINGS.md** - See example analysis results
4. **Run export scripts** - Collect your own logs
5. **Analyze patterns** - Compare to baseline
6. **Document findings** - Create security report

## Additional Resources

- [Microsoft Windows Security Event Logging](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/)
- [Event ID Reference](https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/)
- [PowerShell Get-WinEvent](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.diagnostics/get-winevent/)
- [NIST Incident Response Guide](https://nvlpubs.nist.gov/nistpubs/specialpublications/NIST.SP.800-61r3.pdf)
- [SANS Incident Handling](https://www.sans.org/cyber-aces/resources/tutorials/)

---

**Note**: Always ensure you have permission to analyze system logs before running these tools. Archive sensitive log data securely and follow your organization's data retention and handling policies.
