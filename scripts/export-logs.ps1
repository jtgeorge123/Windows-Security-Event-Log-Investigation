<#
.SYNOPSIS
    Export Windows Security Event logs to CSV format for analysis.

.DESCRIPTION
    This script exports security events from the Windows Event Log to CSV files,
    organized by Event ID. Useful for collecting logs for analysis, compliance
    reporting, or forensic investigation.

.PARAMETER Hours
    Number of hours to look back (default: 24). Use -1 for all events.

.PARAMETER EventIDs
    Array of Event IDs to export (default: 4624, 4625, 4634, 4672).
    Example: @(4624, 4625)

.PARAMETER OutputPath
    Directory where CSV files will be saved (default: current directory).

.PARAMETER IncludeDetails
    Include detailed event information (Message, etc.).

.EXAMPLE
    .\export-logs.ps1 -Hours 24 -OutputPath "C:\Logs"
    
    Exports last 24 hours of security events to C:\Logs

.EXAMPLE
    .\export-logs.ps1 -Hours 48 -EventIDs @(4624) -OutputPath "C:\Analysis" -IncludeDetails
    
    Exports successful logons from last 48 hours with full details

.NOTES
    Requires: Administrator privileges
    Platform: Windows PowerShell 5.0+
#>

param(
    [int]$Hours = 24,
    [array]$EventIDs = @(4624, 4625, 4634, 4672),
    [string]$OutputPath = ".",
    [switch]$IncludeDetails,
    [switch]$Verbose
)

# Color output functions
function Write-Status {
    param([string]$Message, [string]$Color = "Green")
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor $Color
}

function Write-Error-Status {
    param([string]$Message)
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] ❌ ERROR: $Message" -ForegroundColor Red
}

# Verify administrator privileges
$isAdmin = [Security.Principal.WindowsIdentity]::GetCurrent() | 
    ForEach-Object { [Security.Principal.WindowsPrincipal]$_ } | 
    ForEach-Object { $_.IsInRole('Administrators') }

if (-not $isAdmin) {
    Write-Error-Status "This script requires Administrator privileges. Please run as Administrator."
    exit 1
}

Write-Status "Security Event Log Export Tool"
Write-Status "================================"

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputPath)) {
    Write-Status "Creating output directory: $OutputPath"
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

# Calculate time range
if ($Hours -eq -1) {
    Write-Status "Exporting all available security events"
    $StartTime = [datetime]::MinValue
} else {
    $StartTime = (Get-Date).AddHours(-$Hours)
    Write-Status "Time range: $StartTime to $(Get-Date)"
}

# Build filter
$Filter = @{
    LogName = 'Security'
}

if ($Hours -ne -1) {
    $Filter['StartTime'] = $StartTime
}

# Export each Event ID
foreach ($EventID in $EventIDs) {
    Write-Status "Processing Event ID: $EventID"
    
    try {
        # Add Event ID to filter
        $CurrentFilter = $Filter.Clone()
        $CurrentFilter['ID'] = $EventID
        
        # Get events
        $Events = Get-WinEvent -FilterHashtable $CurrentFilter -ErrorAction SilentlyContinue
        
        if ($null -eq $Events) {
            Write-Status "No events found for Event ID $EventID" "Yellow"
            continue
        }
        
        $EventCount = if ($Events -is [array]) { $Events.Count } else { 1 }
        Write-Status "Found $EventCount events for Event ID $EventID"
        
        # Parse event details
        $ParsedEvents = @()
        foreach ($Event in $Events) {
            try {
                # Parse XML for detailed fields
                $EventXml = [xml]$Event.ToXml()
                $EventData = @{}
                
                # Extract common fields
                $EventData['TimeCreated'] = $Event.TimeCreated
                $EventData['EventID'] = $Event.Id
                $EventData['ComputerName'] = $Event.MachineName
                
                # Extract Event-specific fields from XML
                $EventData['Provider'] = $Event.ProviderName
                $EventData['Level'] = $Event.LevelDisplayName
                
                # Parse EventData fields
                foreach ($DataField in $EventXml.Event.EventData.Data) {
                    $FieldName = $DataField.Name
                    $FieldValue = $DataField.'#text'
                    $EventData[$FieldName] = $FieldValue
                }
                
                # Add message if requested
                if ($IncludeDetails) {
                    $EventData['Message'] = $Event.Message
                }
                
                $ParsedEvents += [PSCustomObject]$EventData
            } catch {
                Write-Status "Error parsing event: $_" "Yellow"
                continue
            }
        }
        
        # Export to CSV
        if ($ParsedEvents.Count -gt 0) {
            $FileName = "SecurityEvents_{0}_{1:yyyyMMdd_HHmmss}.csv" -f $EventID, (Get-Date)
            $FilePath = Join-Path $OutputPath $FileName
            
            $ParsedEvents | Export-Csv -Path $FilePath -NoTypeInformation -Encoding UTF8
            Write-Status "Exported to: $FileName" "Cyan"
        }
    } catch {
        Write-Error-Status "Error processing Event ID $EventID : $_"
    }
}

Write-Status "Export complete!" "Green"
Write-Status "Results saved to: $((Get-Item $OutputPath).FullName)"
Write-Status "================================"
