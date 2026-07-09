# Investigation Methodology

## Overview

This document outlines the systematic approach used to investigate Windows Security Event logs. The methodology follows industry-standard incident investigation practices adapted for security event analysis.

## Investigation Framework

### Phase 1: Preparation
**Objective**: Establish analysis environment and define scope

**Steps**:
1. **Environment Setup**
   - Launch Event Viewer on Windows 11
   - Verify access to Security logs
   - Confirm administrative privileges
   - Document baseline system information

2. **Define Scope**
   - Target Event IDs: 4624, 4625, 4634, 4672
   - Time window: Last 24-72 hours (or specified period)
   - Affected systems: Local machine or network range
   - Hypothesis: What are we investigating?

3. **Tool Preparation**
   - Verify PowerShell version (v5.0+)
   - Prepare export templates
   - Organize output directories

### Phase 2: Collection
**Objective**: Gather relevant security events

**Steps**:
1. **Event Filtering**
   - Open Event Viewer
   - Navigate to Windows Logs → Security
   - Apply Event ID filters one at a time
   - Document filter criteria used

2. **Initial Observation**
   - Note total event count for each Event ID
   - Identify time ranges with high activity
   - Look for obvious anomalies (repeated failures, unusual times)
   - Take screenshots of summary view

3. **Export Preparation**
   - Filter logs by Event ID
   - Select appropriate time range
   - Ensure export format (CSV/XML)
   - Verify export destination

### Phase 3: Analysis - Event ID 4624 (Successful Logon)
**Objective**: Understand successful authentication patterns

**Key Fields to Review**:
- **Logon Type**: 
  - 2 = Interactive (local login)
  - 3 = Network (remote access)
  - 10 = RemoteInteractive (RDP)
  - 5 = Service
- **Account Name**: User account used
- **Source Network Address**: IP or hostname
- **Workstation Name**: Source computer
- **Logon Time**: When authentication occurred

**Analysis Questions**:
- ✓ Which accounts are logging in?
- ✓ From which IP addresses/systems?
- ✓ What logon types are being used?
- ✓ Are logons during expected times?
- ✓ Are there unexpected locations or logon types?

**Findings to Document**:
- List of authenticated users
- Common logon sources
- Logon time patterns
- Any suspicious successful logons

### Phase 4: Analysis - Event ID 4625 (Failed Logon)
**Objective**: Identify authentication failures and potential attacks

**Key Fields to Review**:
- **Failure Reason**: Why authentication failed
  - C0000064 = User name does not exist
  - C000006A = Password incorrect
  - C0000070 = User logon with misspelled or bad password
  - C00000DC = Account disabled
- **Account Name**: Target account
- **Source Network Address**: Attacker's IP (potential)
- **Failure Count**: Patterns of repeated attempts

**Analysis Questions**:
- ✓ Which accounts have failed login attempts?
- ✓ How many failed attempts per account?
- ✓ Are attempts from single or multiple sources?
- ✓ Is there a pattern (brute force)?
- ✓ Are attempts targeted or random?

**Findings to Document**:
- Failed logon statistics per account
- Failed attempt sources
- Brute force patterns (>5 failures in short time)
- Targeted vs. spray attacks

### Phase 5: Analysis - Event ID 4634 (Logoff)
**Objective**: Track user session management and activity patterns

**Key Fields to Review**:
- **Account Name**: User logging off
- **Logon Type**: Type of session being closed
- **Logon ID**: Correlate with logon event
- **Logoff Time**: Session duration calculation

**Analysis Questions**:
- ✓ How long are sessions typically active?
- ✓ Are there sessions without corresponding logons?
- ✓ Are there abandoned sessions (no logoff)?
- ✓ Do logoff patterns correlate with work hours?

**Findings to Document**:
- Average session duration
- Orphaned sessions
- Session continuity
- After-hours activity

### Phase 6: Analysis - Event ID 4672 (Privilege Assignment)
**Objective**: Monitor privilege escalation and administrative activity

**Key Fields to Review**:
- **Subject Account**: User receiving privileges
- **Privileges**: Which privileges assigned
  - SeChangeNotifyPrivilege
  - SeImpersonatePrivilege
  - SeTcbPrivilege (Trusted Computing Base)
  - SeDebugPrivilege

**Analysis Questions**:
- ✓ Which accounts are receiving privileges?
- ✓ When are privileges assigned?
- ✓ Are assignments expected/authorized?
- ✓ Are there unexpected privilege escalations?

**Findings to Document**:
- Privilege assignment frequency
- Authorized vs. unexpected escalations
- Correlation with user roles
- Suspicious privilege patterns

### Phase 7: Export & Correlation
**Objective**: Extract events for detailed analysis

**Steps**:
1. **Filter Each Event ID**
   - Apply single Event ID filter
   - Note event count
   - Observe time distribution

2. **Export Process**
   - Use PowerShell Get-WinEvent
   - Filter by Event ID and time range
   - Export to CSV format
   - Validate exported data

3. **Data Correlation**
   - Match logon (4624) with logoff (4634) events
   - Cross-reference with failed attempts (4625)
   - Note privilege escalations (4672) around other activities

### Phase 8: Reporting & Documentation
**Objective**: Document findings for stakeholders

**Report Structure**:
1. Executive Summary
   - Total events analyzed
   - Time period covered
   - Key findings overview

2. Detailed Findings
   - For each Event ID: patterns, anomalies, statistics
   - Visual charts of event distribution
   - Timeline of significant events

3. Recommendations
   - Actions required
   - Security improvements
   - Monitoring enhancements

4. Appendices
   - Screenshots
   - Raw exported data
   - Complete event listings

## Data Analysis Techniques

### Pattern Recognition
- Look for repeated events (failed attempts, privilege assignments)
- Identify time-based patterns (business hours vs. off-hours)
- Note clustering of events (sudden spike in activity)

### Anomaly Detection
- Compare against baseline (expected activity)
- Identify outliers (unusual IPs, accounts, times)
- Find deviations from normal patterns

### Timeline Analysis
- Create chronological event sequences
- Correlate events (logon → activity → logoff)
- Identify gaps or missing events

### Statistical Analysis
- Event counts by category
- Frequency distributions
- Success/failure ratios

## Security Investigation Principles

### 1. **Preservation of Evidence**
- Export logs to prevent data loss
- Document findings with timestamps
- Maintain audit trail of analysis

### 2. **Objectivity**
- Base conclusions on data, not assumptions
- Document ambiguities
- Avoid confirmation bias

### 3. **Completeness**
- Analyze all relevant events
- Don't ignore outliers
- Check for related events

### 4. **Chain of Custody**
- Document what was analyzed
- Record time and method
- Maintain export integrity

## Common Findings & Interpretations

### Successful Logon Event (4624)
| Finding | Interpretation | Action |
|---------|-----------------|--------|
| Many interactive logons from same IP | Normal user activity | Document |
| Logon from unusual IP/time | Potential compromise | Investigate |
| Network logon spikes | Possible credential misuse | Review failed attempts |
| Service account interactive logon | Misconfiguration | Escalate |

### Failed Logon Event (4625)
| Finding | Interpretation | Action |
|---------|-----------------|--------|
| 1-2 failures | Normal user error | Monitor |
| 5+ failures in short time | Possible brute force | Alert |
| Failures for non-existent account | Reconnaissance scan | Document |
| Failures with correct password | Account locked | Verify account status |

### Logoff Event (4634)
| Finding | Interpretation | Action |
|---------|-----------------|--------|
| Logoff shortly after logon | Normal session | Document |
| No logoff event after logon | Session abandoned | Investigate |
| Sudden batch logoffs | System reboot or termination | Verify |

### Privilege Assignment (4672)
| Finding | Interpretation | Action |
|---------|-----------------|--------|
| Regular admin privilege assignment | Expected admin activity | Document |
| Unexpected account receiving privileges | Potential privilege escalation | Investigate |
| Service account with admin privileges | Misconfiguration | Remediate |

## Tools & Commands Reference

### PowerShell Event Log Query
```powershell
# Get specific event ID
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624} -MaxEvents 100

# Export to CSV
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624} | 
  Export-Csv -Path "C:\Logs\SecurityEvents.csv" -NoTypeInformation

# Time-based filter
Get-WinEvent -FilterHashtable @{
    LogName='Security'
    ID=4625
    StartTime=(Get-Date).AddHours(-24)
}
```

### Event Viewer GUI
- **Open**: eventvwr.msc
- **Navigate**: Windows Logs → Security
- **Filter**: Right-click → Filter Current Log
- **Export**: Action menu → Save All Events As

## Conclusion

This methodology provides a structured approach to Windows Security log analysis. By systematically examining each event type and correlating findings, security professionals can:

- Identify authentication patterns and anomalies
- Detect potential security breaches or misuse
- Build audit trails for compliance
- Develop baseline behavior for future monitoring

The same techniques apply to broader incident response, threat hunting, and continuous security monitoring.

---

**Related Documentation**: See [EVENT-IDS.md](EVENT-IDS.md) for detailed event field descriptions
