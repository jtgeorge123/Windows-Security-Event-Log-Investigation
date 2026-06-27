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
| 4672 | Privileges Assigned |

## Analysis Process

1. Open Event Viewer
2. Navigate to Windows Logs → Security
3. Filter by Event ID
4. Review event details
5. Export Security Event logs using PowerShell
6. Document findings
7. Capture screenshots

## Findings

via Event Viewer:

- Identified successful login attempts
- Identified failed login attempts
- Identified privilages assigned
- Exported 100 Security Event logs using PowerShell

## Skills Demonstrated

- Event Log Analysis
- Windows Administration
- Security Monitoring
- Incident Investigation
- Documentation

## Screenshots

### Event ID 4624

<img width="1377" height="887" alt="Screenshot 2026-06-11 185303" src="https://github.com/user-attachments/assets/4fa47bd8-315a-4a62-9d4b-930282d1fcd4" />

### Event ID 4625

<img width="1507" height="872" alt="Screenshot 2026-06-11 185552" src="https://github.com/user-attachments/assets/b0a6ff98-e7e9-4e25-be32-38a69784cec1" />

### Event ID 4634

<img width="1502" height="852" alt="Screenshot 2026-06-11 190008" src="https://github.com/user-attachments/assets/760b765e-b070-4c5c-8607-4125956327c5" />

### Event ID 4672

<img width="1517" height="878" alt="Screenshot 2026-06-11 190124" src="https://github.com/user-attachments/assets/9d1436af-ef47-4c9f-8055-71998525736c" />

### Powershell command/Exported csv output

<img width="892" height="176" alt="Screenshot 2026-06-11 191220" src="https://github.com/user-attachments/assets/010bdae9-1228-4b4d-9429-ec57b704754c" />
<img width="1246" height="677" alt="Screenshot 2026-06-11 191412" src="https://github.com/user-attachments/assets/248fdd81-0788-4f32-ac0a-2fe82d6282c1" />


## Key Takeaways

This project demonstrates the ability to investigate Windows logs, identify authentication events, and document findings similar to tasks performed in entry-level SOC analyst and IT support roles.
