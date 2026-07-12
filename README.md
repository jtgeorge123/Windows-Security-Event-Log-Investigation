# Windows Security Event Log Investigation

![Status](https://img.shields.io/badge/Status-Complete-brightgreen)
![Windows](https://img.shields.io/badge/Platform-Windows%2011-blue)
![PowerShell](https://img.shields.io/badge/Tool-PowerShell-blue)

## Overview

Comprehensive investigation of Windows Event Viewer security logs to identify and analyze authentication events, system activities, and potential security concerns. This project demonstrates the methodologies and tools used by SOC analysts and IT security professionals during incident investigation and routine security monitoring.

## Quick Start

- **Documentation**: See [METHODOLOGY.md](docs/METHODOLOGY.md) for investigation approach
- **Analysis Results**: See [FINDINGS.md](docs/FINDINGS.md) for detailed findings
- **Event Reference**: See [EVENT-IDS.md](docs/EVENT-IDS.md) for complete event documentation
- **Setup**: See [SETUP.md](docs/SETUP.md) for reproducibility

### Quick Run

Run these PowerShell commands on a Windows machine (open PowerShell as Administrator). Adjust paths as needed.

Prerequisites:

- Run PowerShell as Administrator
- PowerShell 5.0 or newer
- (Optional) Allow scripts for this session:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Export events (from the repository `scripts` folder):

```powershell
cd C:\Path\To\Repository\scripts
.\export-logs.ps1 -Hours 24 -OutputPath "C:\SecurityAnalysis\Results" -IncludeDetails -Verbose
```

Analyze exported CSVs and generate an HTML report:

```powershell
.\analyze-logs.ps1 -CsvFolder "C:\SecurityAnalysis\Results" -OutputReport "C:\SecurityAnalysis\Results\Analysis.html" -IncludeCharts -Verbose
```

One-step wrapper (export + analysis):

```powershell
cd C:\Path\To\Repository\scripts
.\run-analysis.ps1 -Hours 24 -AnalysisRoot "C:\SecurityAnalysis" -IncludeDetails -IncludeCharts -Verbose
```

Open the generated report:

```powershell
Invoke-Item "C:\SecurityAnalysis\Results\Analysis.html"
```

Notes: scripts require PowerShell 5.0+ and Administrator privileges. See `docs/SETUP.md` for full setup and troubleshooting.

## Project Structure

```text
├── README.md                          # This file
├── PORTFOLIO.md                       # Portfolio summary for hiring
├── docs/
│   ├── METHODOLOGY.md                 # Investigation methodology
│   ├── FINDINGS.md                    # Detailed analysis findings
│   ├── EVENT-IDS.md                   # Event ID reference guide
│   └── SETUP.md                       # Environment setup instructions
├── scripts/
│   ├── export-logs.ps1                # Export Security logs using PowerShell
│   └── analyze-logs.ps1               # Analyze and filter logs
└── screenshots/                       # Event Viewer evidence
    ├── event-4624-successful-login.png
    ├── event-4625-failed-login.png
    ├── event-4634-logoff.png
    └── event-4672-privileges.png

```

## Investigation Summary

**Scope**: Windows Security Event Log Analysis (Event IDs 4624, 4625, 4634, 4672)

**Objectives**:

- ✅ Identify authentication events (successful and failed logins)
- ✅ Track privileged account activity
- ✅ Document logoff events
- ✅ Export and analyze 100+ security events
- ✅ Create reusable analysis tools

**Key Findings**:

- Identified successful login attempts with user context
- Identified failed login attempts with failure reasons
- Tracked privilege escalation events
- Documented logoff patterns

See [FINDINGS.md](docs/FINDINGS.md) for detailed analysis.

## Events Investigated

| Event ID | Description | Purpose | Frequency |
| --- | --- | --- | --- |
| 4624 | Successful Account Logon | Track successful authentication | High |
| 4625 | Failed Account Logon | Identify failed login attempts & potential intrusions | Medium |
| 4634 | An Account Was Logged Off | Monitor session endings & user activity | High |
| 4672 | Special Privileges Assigned | Track privilege escalation & admin activities | Low-Medium |

For detailed event information, see [EVENT-IDS.md](docs/EVENT-IDS.md).

## Methodology

This project follows a structured security investigation approach:

1. **Collection** - Gather security logs from Event Viewer
2. **Filtering** - Apply Event ID filters to focus analysis
3. **Examination** - Review event details and context
4. **Export** - Use PowerShell to export filtered logs (CSV format)
5. **Analysis** - Identify patterns and anomalies
6. **Documentation** - Record findings and create reusable tools

See [METHODOLOGY.md](docs/METHODOLOGY.md) for detailed process documentation.

## Tools & Technologies

- **Windows 11** - Operating System
- **Event Viewer** - Log collection and viewing
- **PowerShell** - Log export and analysis automation
- **Excel/CSV** - Data analysis and reporting

## Skills Demonstrated

- ✅ **Event Log Analysis** - Interpret security events in context
- ✅ **Windows Administration** - Navigate Event Viewer and system logs
- ✅ **Security Monitoring** - Identify suspicious activity patterns
- ✅ **Incident Investigation** - Systematic log analysis methodology
- ✅ **Automation** - PowerShell scripting for log export
- ✅ **Documentation** - Professional security reporting
- ✅ **Technical Communication** - Clear explanation of findings

## Evidence & Screenshots

### Event ID 4624 - Successful Logon

<img width="1377" height="887" alt="Event ID 4624 showing successful login details" src="https://github.com/user-attachments/assets/4fa47bd8-315a-4a62-9d4b-930282d1fcd4" />

**Analysis**: Shows successful authentication with user account, logon type, source IP, and timestamp.

### Event ID 4625 - Failed Logon

<img width="1507" height="872" alt="Event ID 4625 showing failed login attempt" src="https://github.com/user-attachments/assets/b0a6ff98-e7e9-4e25-be32-38a69784cec1" />

**Analysis**: Demonstrates failed authentication with failure reason (invalid password, account disabled, etc.).

### Event ID 4634 - Logoff

<img width="1502" height="852" alt="Event ID 4634 showing logoff event" src="https://github.com/user-attachments/assets/760b765e-b070-4c5c-8607-4125956327c5" />

**Analysis**: Tracks user session termination and logoff events.

### Event ID 4672 - Privilege Assignment

<img width="1517" height="878" alt="Event ID 4672 showing privilege escalation" src="https://github.com/user-attachments/assets/9d1436af-ef47-4c9f-8055-71998525736c" />

**Analysis**: Records when special privileges are assigned to user accounts (admin rights, etc.).

### PowerShell Export

<img width="892" height="176" alt="PowerShell export command" src="https://github.com/user-attachments/assets/010bdae9-1228-4b4d-9429-ec57b704754c" />

**Command Used**: Export-WinEvent with Get-WinEvent for filtered log extraction

### Exported CSV Analysis

<img width="1246" height="677" alt="Exported CSV data showing 100 security events" src="https://github.com/user-attachments/assets/248fdd81-0788-4f32-ac0a-2fe82d6282c1" />

**Results**: Successfully exported 100+ security events to CSV format for further analysis.

## How This Applies to SOC/IT Support Roles

This investigation demonstrates core competencies required in security operations:

- **Log Correlation**: Understanding how events relate to user activity
- **Threat Detection**: Identifying suspicious patterns (failed login attempts, privilege escalation)
- **Evidence Collection**: Properly extracting and preserving log data
- **Technical Documentation**: Clear reporting of findings
- **Automation**: Using tools to streamline analysis processes

## Reproducibility

This project is fully reproducible. See [SETUP.md](docs/SETUP.md) for instructions on:
- Setting up the investigation environment
- Running the provided PowerShell scripts
- Filtering and exporting your own security logs
- Interpreting event details

## Further Reading

- [Microsoft Event ID Documentation](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/advanced-security-audit-policy-settings)
- [MITRE ATT&CK Framework](https://attack.mitre.org/) - Connect events to adversary tactics
- [Event Log Analysis Best Practices](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/auditing-events)

---

**Project Status**: ✅ Complete | **Last Updated**: 2026-07-09 | **Developed for**: Security Portfolio Demonstration
