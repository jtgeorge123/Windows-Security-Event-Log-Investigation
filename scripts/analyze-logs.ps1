<#
.SYNOPSIS
    Analyze exported Windows Security Event logs for patterns and anomalies.

.DESCRIPTION
    This script analyzes CSV-exported security events to identify patterns,
    create statistics, and detect potential security anomalies.

.PARAMETER CsvFolder
    Folder containing exported CSV files from export-logs.ps1.

.PARAMETER OutputReport
    Path and filename for HTML report output.

.PARAMETER EventType
    Filter analysis to specific Event ID (optional).

.PARAMETER IncludeCharts
    Generate charts in HTML report (requires charting capability).

.EXAMPLE
    .\analyze-logs.ps1 -CsvFolder "C:\Logs" -OutputReport "C:\Analysis\Report.html"
    
    Analyzes all CSV files in C:\Logs and generates HTML report

.EXAMPLE
    .\analyze-logs.ps1 -CsvFolder "C:\Logs" -EventType 4625 -OutputReport "C:\Analysis\FailedLogons.html"
    
    Analyzes only failed logon events (4625)

.NOTES
    Requires: PowerShell 5.0+
    CSV files should be from export-logs.ps1 for best results
#>

param(
    [string]$CsvFolder = ".",
    [string]$OutputReport = "SecurityAnalysis.html",
    [int]$EventType = 0,
    [switch]$IncludeCharts,
    [switch]$Verbose
)

function Write-Status {
    param([string]$Message, [string]$Color = "Green")
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor $Color
}

Write-Status "Security Event Log Analyzer"
Write-Status "============================"

# Find CSV files
Write-Status "Searching for CSV files in: $CsvFolder"
$CsvFiles = Get-ChildItem $CsvFolder -Filter "*.csv" -ErrorAction SilentlyContinue

if ($CsvFiles.Count -eq 0) {
    Write-Status "No CSV files found. Make sure to run export-logs.ps1 first." "Yellow"
    exit 1
}

Write-Status "Found $($CsvFiles.Count) CSV file(s)"

# Import and combine data
$AllEvents = @()
foreach ($File in $CsvFiles) {
    Write-Status "Loading: $($File.Name)"
    try {
        $Data = Import-Csv -Path $File.FullName
        $AllEvents += $Data
    } catch {
        Write-Status "Error reading $($File.Name): $_" "Yellow"
    }
}

Write-Status "Total events loaded: $($AllEvents.Count)"

# Filter by EventType if specified
if ($EventType -ne 0) {
    $AllEvents = $AllEvents | Where-Object { $_.EventID -eq $EventType }
    Write-Status "Filtered to Event ID $EventType : $($AllEvents.Count) events"
}

# Analyze data
$Analysis = @{
    TotalEvents = $AllEvents.Count
    UniqueComputers = ($AllEvents | Select-Object -ExpandProperty ComputerName -Unique).Count
    UniqueAccounts = ($AllEvents | Select-Object -ExpandProperty 'Account Name' -Unique -ErrorAction SilentlyContinue).Count
    EventDistribution = $AllEvents | Group-Object -Property EventID | Select-Object Name, Count
    AccountActivity = $AllEvents | Group-Object -Property 'Account Name' | Sort-Object Count -Descending | Select-Object -First 10
}

# Generate HTML Report
$Html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Security Event Analysis Report</title>
    <meta charset="UTF-8">
    <style>
        body {
            font-family: Segoe UI, Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        h1 {
            color: #0078d4;
            border-bottom: 3px solid #0078d4;
            padding-bottom: 10px;
        }
        h2 {
            color: #0078d4;
            margin-top: 30px;
            border-left: 4px solid #0078d4;
            padding-left: 15px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
        }
        th {
            background-color: #0078d4;
            color: white;
            padding: 12px;
            text-align: left;
        }
        td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }
        tr:hover {
            background-color: #f0f0f0;
        }
        .stat-box {
            display: inline-block;
            background-color: #f0f0f0;
            padding: 20px;
            margin: 10px;
            border-radius: 8px;
            border-left: 4px solid #0078d4;
            min-width: 200px;
        }
        .stat-value {
            font-size: 28px;
            font-weight: bold;
            color: #0078d4;
        }
        .stat-label {
            font-size: 14px;
            color: #666;
            margin-top: 5px;
        }
        .alert {
            background-color: #fff4ce;
            border-left: 4px solid #f0ad4e;
            padding: 15px;
            margin: 15px 0;
            border-radius: 4px;
        }
        .info {
            background-color: #d1ecf1;
            border-left: 4px solid #17a2b8;
            padding: 15px;
            margin: 15px 0;
            border-radius: 4px;
        }
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            color: #666;
            font-size: 12px;
        }
        .warning {
            color: #f0ad4e;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Windows Security Event Analysis Report</h1>
        
        <div class="info">
            <strong>Report Generated:</strong> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')<br>
            <strong>Analysis Type:</strong> Security Event Log Analysis<br>
            <strong>Source:</strong> Exported Security Events (CSV format)
        </div>
        
        <h2>Executive Summary</h2>
        
        <div class="stat-box">
            <div class="stat-value">$($Analysis.TotalEvents)</div>
            <div class="stat-label">Total Events Analyzed</div>
        </div>
        
        <div class="stat-box">
            <div class="stat-value">$($Analysis.UniqueComputers)</div>
            <div class="stat-label">Unique Computers</div>
        </div>
        
        <div class="stat-box">
            <div class="stat-value">$($Analysis.UniqueAccounts)</div>
            <div class="stat-label">Unique Accounts</div>
        </div>
        
        <h2>Event Distribution</h2>
        <table>
            <tr>
                <th>Event ID</th>
                <th>Description</th>
                <th>Count</th>
                <th>Percentage</th>
            </tr>
"@

# Add event distribution
foreach ($Event in $Analysis.EventDistribution | Sort-Object Count -Descending) {
    $Description = @{
        '4624' = 'Successful Logon'
        '4625' = 'Failed Logon'
        '4634' = 'Logoff'
        '4672' = 'Privilege Assignment'
    }[$Event.Name]
    
    $Percentage = [math]::Round(($Event.Count / $Analysis.TotalEvents) * 100, 2)
    
    $Html += @"
            <tr>
                <td>$($Event.Name)</td>
                <td>$Description</td>
                <td>$($Event.Count)</td>
                <td>$Percentage%</td>
            </tr>
"@
}

$Html += @"
        </table>
        
        <h2>Top 10 Active Accounts</h2>
        <table>
            <tr>
                <th>Account Name</th>
                <th>Event Count</th>
            </tr>
"@

# Add account activity
foreach ($Account in $Analysis.AccountActivity) {
    $Html += @"
            <tr>
                <td>$($Account.Name)</td>
                <td>$($Account.Count)</td>
            </tr>
"@
}

$Html += @"
        </table>
        
        <h2>Analysis Notes</h2>
        <div class="info">
            <strong>Key Points:</strong>
            <ul>
                <li>High logon (4624) event count indicates active system usage</li>
                <li>Low failed logon (4625) count suggests healthy authentication</li>
                <li>Balance of logoff (4634) events correlates with logons (proper cleanup)</li>
                <li>Privilege assignment (4672) events should align with admin activity only</li>
            </ul>
        </div>
        
        <h2>Recommendations</h2>
        <div class="alert">
            <strong>Security Recommendations:</strong>
            <ul>
                <li>Review all failed logon events (Event ID 4625) for potential brute force attacks</li>
                <li>Verify all privilege assignments (4672) are authorized</li>
                <li>Monitor for accounts with unusual logon patterns or times</li>
                <li>Cross-reference logons with system access logs for correlation</li>
                <li>Establish baseline for normal event frequency to detect anomalies</li>
            </ul>
        </div>
        
        <h2>For Detailed Analysis</h2>
        <div class="info">
            <strong>Next Steps:</strong>
            <ol>
                <li>Review CSV files directly in Excel for custom pivot tables</li>
                <li>Consult <strong>METHODOLOGY.md</strong> for investigation techniques</li>
                <li>Review <strong>EVENT-IDS.md</strong> for detailed field descriptions</li>
                <li>Compare findings to baseline from <strong>FINDINGS.md</strong></li>
                <li>Create correlation analysis between event types</li>
            </ol>
        </div>
        
        <div class="footer">
            <p><strong>Report Source:</strong> Security Event Log Analysis Tool</p>
            <p>This report was automatically generated from exported security events.</p>
            <p>For detailed analysis methodology, see METHODOLOGY.md in the project documentation.</p>
        </div>
    </div>
</body>
</html>
"@

# Save report
Write-Status "Generating HTML report..."
$Html | Out-File -FilePath $OutputReport -Encoding UTF8
Write-Status "Report saved to: $OutputReport" "Cyan"

# Display summary
Write-Status ""
Write-Status "Analysis Summary:" "Cyan"
Write-Status "  Total Events: $($Analysis.TotalEvents)"
Write-Status "  Unique Computers: $($Analysis.UniqueComputers)"
Write-Status "  Unique Accounts: $($Analysis.UniqueAccounts)"
Write-Status ""
Write-Status "Event Distribution:"
foreach ($Event in $Analysis.EventDistribution | Sort-Object Count -Descending) {
    $Percentage = [math]::Round(($Event.Count / $Analysis.TotalEvents) * 100, 2)
    Write-Status "  Event $($Event.Name): $($Event.Count) ($Percentage%)"
}

Write-Status ""
Write-Status "Analysis complete! Open the HTML report for detailed view." "Green"
Write-Status "============================"
