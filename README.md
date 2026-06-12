# Windows Security Log Analysis Project

## Overview

This project demonstrates the analysis of Windows Event Viewer security logs to identify security events most commonly reviewed by IT Support and SOC analysts.

## Objective

Review and export Windows logs and document findings related to authentication activity, system events, and potential security concerns. 

## Environment

- Windows 11
- Event Viewer
- Security Logs
- PowerShell

## Event IDs Investigated

### Security Events

| Event ID | Description |
|-----------|-------------|
| 4624 | Successful Login |
| 4625 | Failed Login |
| 4634 | Logoff |

## Analysis Process

1. Open Event Viewer
2. Navigate to Windows Logs → Security
3. Filter by Event ID
4. Review event details
5. Export Security Event logs using PowerShell
6. Document findings
7. Capture screenshots

## Findings

### Successful Logins (4624)

Observed multiple successful logins from local user accounts.

### Failed Logins (4625)

Identified failed login attempts and reviewed source information.

### Special Privileges Assigned (4672)

Identified special privileges assigned from running programs as an administrator.

## Skills Demonstrated

- Event Log Analysis
- Windows Administration
- Security Monitoring
- Incident Investigation
- Documentation

## Screenshots

### Event ID 4624

![4624](screenshots/event-4624.png)

### Event ID 4625

![4625](screenshots/event-4625.png)

### Event ID 4672

![4672](screenshots/event-4672.png)

## Key Takeaways

This project demonstrates the ability to investigate Windows logs, identify authentication events, and document findings similar to tasks performed in entry-level SOC analyst and IT support roles.
