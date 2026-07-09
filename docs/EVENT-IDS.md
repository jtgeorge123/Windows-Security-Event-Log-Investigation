# Windows Security Event ID Reference Guide

## Complete Event Documentation

### Overview

This guide provides detailed documentation of the key Windows Security Event IDs analyzed in this investigation. Each event is explained with field descriptions, security significance, and interpretation guidance.

---

## Event ID 4624: Account Logon (Successful)

### Summary
- **Event Name**: An account was successfully logged on
- **Security Category**: Authentication & Logons
- **Importance**: High (baseline for user activity)
- **Frequency**: Very Common
- **Threat Level**: Informational (unless anomalies present)

### Description

Event 4624 is logged whenever a user successfully authenticates to a computer. This includes both local logons and network-based authentication. It's one of the most frequently logged security events and provides critical information about who is accessing systems and how.

### Event Fields

#### Core Authentication Fields

| Field | Description | Example | Analysis Value |
|-------|-------------|---------|-----------------|
| **Event Time** | When logon occurred | 2026-06-11 09:45:32 | Track time patterns |
| **Event ID** | Event classification | 4624 | Filter/identify event type |
| **Logon ID** | Unique session ID | 0x45E3A | Correlate with logoff (4634) |

#### Subject Fields (System Initiating Logon)

| Field | Description | Example | Analysis Value |
|-------|-------------|---------|-----------------|
| **Subject Account Name** | Account requesting logon | ADMIN | Track which account initiated |
| **Subject Account Domain** | Domain of initiating account | WORKGROUP | Corporate vs. local |
| **Subject Logon ID** | Session ID of initiator | 0x3E7 | Correlate related events |

#### Target Logon Fields (Account Logging In)

| Field | Description | Example | Analysis Value |
|-------|-------------|---------|-----------------|
| **Account Name** | User account logging in | JohnDoe | **Identify who accessed system** |
| **Account Domain** | Domain of user account | DESKTOP-ABC123 | Local vs. AD domain |
| **Fully Qualified Account Name** | Complete account identifier | DESKTOP-ABC123\\JohnDoe | Unique identification |

#### Logon Type

| Code | Logon Type | Description | Risk Level |
|------|-----------|-------------|-----------|
| **2** | **Interactive** | Local login (keyboard, console) | Normal |
| **3** | **Network** | Remote login (UNC path, SMB share) | Medium |
| **4** | **Batch** | Scheduled task, batch process | Medium |
| **5** | **Service** | Service started by system | Normal (if authorized) |
| **7** | **Unlock** | Unlocking locked workstation | Normal |
| **8** | **NetworkCleartext** | Network logon, credentials in cleartext | **High** |
| **9** | **NewCredentials** | Logon with new credentials | Medium |
| **10** | **RemoteInteractive** | Remote Desktop (RDP) | Medium |
| **11** | **CachedInteractive** | Cached credential logon | Medium |

**Interpretation**: 
- Types 2, 5, 7: Expected in normal operations
- Types 3, 10: Verify authorized remote access
- Type 8: Investigate (should use encrypted credentials)
- Unexpected types: Flag for investigation

#### Source/Network Information

| Field | Description | Example | Analysis Value |
|-------|-------------|---------|-----------------|
| **Source Network Address** | IP address of origin | 192.168.1.100 | Identify logon source |
| **Source Port** | Port number of origin | 52341 | Track network patterns |
| **Workstation Name** | Computer name of source | LAPTOP-USER | Identify source system |

**Interpretation**:
- Blank workstation name: Local console logon
- IP address 127.0.0.1: Local system logon
- Remote IP: Network access from that source

#### Process Information

| Field | Description | Example | Analysis Value |
|-------|-------------|---------|-----------------|
| **Process ID** | PID of logon process | 0x284 | Correlate with process logs |
| **Process Name** | Executable initiating logon | C:\\Windows\\System32\\svchost.exe | Identify logon mechanism |

#### Authentication Information

| Field | Description | Example | Analysis Value |
|-------|-------------|---------|-----------------|
| **Authentication Package** | Method used | NTLM | Verify secure auth method |
| **Transited Services** | Intermediate systems | -network- | Track authentication chain |
| **LM Package** | Legacy auth protocol | NTLM V2 | Should not be LM (legacy) |

### Security Interpretation

#### Normal Patterns (Low Risk)
```
✅ Interactive logon (Type 2) during business hours
✅ From expected workstation name/IP
✅ Using NTLM v2 or Kerberos authentication
✅ Within expected logon frequency
✅ Service account logons (Type 5) at predictable times
```

#### Suspicious Patterns (High Risk)
```
⚠️ Interactive logon at 3 AM from unknown IP
⚠️ Type 8 (cleartext credentials) - immediate concern
⚠️ Rapid logon/logoff cycles (potential reconnaissance)
⚠️ Service account interactive logon (Type 2)
⚠️ User account logon from multiple IPs simultaneously
⚠️ Logon to system not assigned to user
```

### Real-World Examples

#### Example 1: Normal User Logon
```
Event ID: 4624
Time: 2026-06-11 08:45:23
Account Name: JohnDoe
Domain: DESKTOP-USER
Logon Type: 2 (Interactive)
Source: LAPTOP-USER (127.0.0.1 - local)
Authentication: NTLM V2
Process: C:\Windows\System32\winlogon.exe

Interpretation: ✅ Routine morning logon, local interactive
Risk: LOW
```

#### Example 2: Network Logon (Normal)
```
Event ID: 4624
Time: 2026-06-11 14:30:15
Account Name: Support
Domain: CORP.DOMAIN
Logon Type: 3 (Network)
Source: File Server (192.168.1.50)
Authentication: Kerberos
Process: C:\Windows\System32\lsass.exe

Interpretation: ✅ Network share access, expected
Risk: LOW
```

#### Example 3: Suspicious RDP Logon
```
Event ID: 4624
Time: 2026-06-11 03:22:45
Account Name: Administrator
Domain: DESKTOP-ABC
Logon Type: 10 (RemoteInteractive - RDP)
Source: 203.45.67.89 (External IP)
Authentication: NTLM
Process: C:\Windows\System32\svchost.exe

Interpretation: ⚠️ Admin RDP at odd hour from external IP
Risk: HIGH - Requires investigation
```

### MITRE ATT&CK Correlation

| ATT&CK Technique | Event Indicator |
|---|---|
| T1078 - Valid Accounts | 4624 with compromised account |
| T1110 - Brute Force | Multiple 4625s followed by 4624 |
| T1046 - Network Service Scanning | 4624 attempts on many systems |
| T1550 - Use Alternate Authentication | 4624 with unusual auth package |

---

## Event ID 4625: Account Logon Failed

### Summary
- **Event Name**: An account failed to log on
- **Security Category**: Authentication & Logons
- **Importance**: High (security indicator)
- **Frequency**: Common (but should be low)
- **Threat Level**: Warning (especially if multiple occurrences)

### Description

Event 4625 is logged when an authentication attempt fails. This event is critical for detecting brute force attacks, credential spray attacks, and account compromise attempts. Unlike 4624, this event doesn't result in system access.

### Event Fields

#### Failure Identification

| Field | Description | Example |
|-------|-------------|---------|
| **Event ID** | Event classification | 4625 |
| **Event Time** | When failure occurred | 2026-06-11 09:47:12 |
| **Failure Reason** | Why authentication failed | User Account Does Not Exist |

#### Failure Codes (Common)

| Code | Meaning | Cause | Investigation |
|------|---------|-------|---|
| **C0000064** | User account does not exist | Invalid username | Reconnaissance/enumeration |
| **C000006A** | User has not been granted login rights | User disabled/locked | Check account status |
| **C000006D** | Invalid username or password | Wrong password | User error or attack |
| **C000006E** | Invalid workstation for user logon | Cross-machine attempt | Verify authorization |
| **C000006F** | User account locked | Lockout policy triggered | Check for brute force |
| **C0000070** | Invalid logon type for user | Wrong logon type attempted | Verify authentication method |
| **C00000DC** | Account disabled | Account inactive | Verify account status |

#### Subject/Target Account Information

| Field | Description | Example | Use |
|-------|-------------|---------|-----|
| **Account Name** | Account attempted to be used | admin | What account was targeted |
| **Account Domain** | Domain of account | WORKGROUP | Local vs. networked |
| **Failure Sub-status** | Additional failure code | N/A | Deep dive into cause |

#### Source Information

| Field | Description | Example | Analysis |
|-------|-------------|---------|----------|
| **Source Network Address** | IP address of attacker | 192.168.1.50 | Where did attempt come from |
| **Source Port** | Port number | 52431 | Track connections |
| **Workstation Name** | Computer attempting logon | UNKNOWN | May be blank for remote |

### Security Interpretation

#### Red Flags (Potential Attack)

```
🚨 CRITICAL:
- Multiple failures (5+) in short time period
- Failures from multiple IPs targeting same account
- Failures for non-existent accounts (reconnaissance)
- Type 8 (cleartext) failures - credential in transit

⚠️ WARNING:
- 3-5 failures per account per hour
- Failures from unfamiliar IP
- Unusual time for login attempts
- Service account failed logon
```

#### Normal Patterns (Low Risk)

```
✅ 1-2 failures followed by successful logon (user error)
✅ Occasional failures, spread over time
✅ Failures from expected source IP
✅ Failures during business hours
```

### Attack Pattern Detection

#### Brute Force Attack
```
Signature:
- Same account targeted
- 10+ failures in 5 minutes
- Same source IP
- Multiple failure codes

Event Log:
4625 - admin - fail - 192.168.1.50 - 10:00:00
4625 - admin - fail - 192.168.1.50 - 10:00:15
4625 - admin - fail - 192.168.1.50 - 10:00:30
... [10+ times]

Response: BLOCK source IP, check admin account
```

#### Credential Spray Attack
```
Signature:
- Multiple accounts targeted
- 1-2 failures per account
- Many source IPs or rotating
- Spread over time (stealth)

Event Log:
4625 - user1 - fail - 192.168.1.50 - 10:00:00
4625 - admin - fail - 192.168.1.51 - 10:00:30
4625 - guest - fail - 192.168.1.52 - 10:01:00
... [many accounts]

Response: Investigate source IPs, check used passwords
```

#### Account Enumeration
```
Signature:
- Attempts for non-existent accounts
- Failure code: C0000064
- Multiple attempts
- May indicate reconnaissance

Event Log:
4625 - testadmin - fail - User Does Not Exist - 10:00:00
4625 - administrator - fail - Invalid Password - 10:00:15
4625 - admin1 - fail - User Does Not Exist - 10:00:30

Response: Check for follow-up brute force, harden auth
```

### Real-World Examples

#### Example 1: User Forgot Password
```
Event ID: 4625
Time: 2026-06-11 09:47:23
Account Name: JohnDoe
Failure Reason: Invalid username or password
Source: LAPTOP-USER (127.0.0.1 - local)
Failure Count: 1 (then successful logon 30 seconds later)

Interpretation: ✅ User mistyped password once
Risk: LOW
Action: No action needed
```

#### Example 2: Multiple Failed Attempts
```
Event ID: 4625
Time: 2026-06-11 14:15:00 - 14:15:45
Account Name: admin
Failure Reason: Invalid password
Source: 192.168.1.100 (remote)
Failure Count: 5

Interpretation: ⚠️ Possible brute force attack or account lock
Risk: MEDIUM
Action: Check account lockout status, verify source IP
```

#### Example 3: Reconnaissance Activity
```
Event ID: 4625
Time: 2026-06-11 23:30:00 - 23:35:00
Accounts Targeted: administrator, admin, root, test, guest
Failure Reason: User does not exist / Invalid password
Source: 203.45.67.89 (external)
Pattern: Multiple accounts, multiple failures

Interpretation: 🚨 Likely reconnaissance/enumeration scan
Risk: HIGH
Action: Block source IP, alert security team, investigate
```

### MITRE ATT&CK Correlation

| ATT&CK Technique | Event Indicator |
|---|---|
| T1110 - Brute Force | Multiple 4625s, same account/source |
| T1110.003 - Password Spray | Multiple 4625s, multiple accounts |
| T1589 - Account Enumeration | 4625 with "user does not exist" |
| T1078 - Account Takeover | 4625s then successful 4624 |

---

## Event ID 4634: Account Logoff

### Summary
- **Event Name**: An account was logged off
- **Security Category**: Session Management
- **Importance**: Medium (correlate with logons)
- **Frequency**: Common (should match 4624)
- **Threat Level**: Informational

### Description

Event 4634 is logged when a user session terminates (logoff). By correlating 4634 with 4624 (logon), analysts can determine session duration and identify orphaned or abandoned sessions.

### Event Fields

#### Session Information

| Field | Description | Example |
|-------|-------------|---------|
| **Event ID** | Event classification | 4634 |
| **Event Time** | When logoff occurred | 2026-06-11 17:30:45 |
| **Logon ID** | Session ID being closed | 0x45E3A |

#### Account Information

| Field | Description | Example | Analysis |
|-------|-------------|---------|----------|
| **Account Name** | Account logging off | JohnDoe | Who is ending session |
| **Account Domain** | Domain of account | DESKTOP-USER | Local vs. network |

#### Logon Information

| Field | Description | Example | Analysis |
|-------|-------------|---------|----------|
| **Logon Type** | Type of session ended | 2 (Interactive) | See 4624 logon types |
| **Logon ID** | Unique session identifier | 0x45E3A | Correlate with 4624 |

### Security Interpretation

#### Normal Patterns
```
✅ Logoff matches prior logon (same Logon ID)
✅ Session duration 4-8 hours (normal work day)
✅ Logoff during business hours
✅ All opened sessions properly closed
```

#### Suspicious Patterns
```
⚠️ Logoff without corresponding logon
⚠️ Session duration >24 hours (possible idle)
⚠️ No logoff after logon (abandoned session/crash)
⚠️ Rapid logon/logoff cycle (reconnaissance)
🚨 Session duration 0 seconds (possible error)
```

### Session Duration Analysis

#### Duration Calculation
```
Logon Time:   08:00:00
Logoff Time:  17:00:00
Duration:     9 hours

Assessment: ✅ Normal full work day
```

#### Examples

| Logon Time | Logoff Time | Duration | Assessment |
|-----------|-----------|----------|-----------|
| 08:00 | 17:00 | 9 hours | ✅ Normal work day |
| 14:00 | 14:05 | 5 minutes | ⚠️ Investigation needed |
| 22:00 | 06:00 (next day) | 8 hours | ✅ Night shift normal |
| 08:00 | (no logoff) | Open | ⚠️ Session abandoned or crash |

### Real-World Examples

#### Example 1: Normal Workday Session
```
Event ID: 4624 (Logon)
Time: 2026-06-11 08:00:00
Account: JohnDoe
Logon ID: 0x45E3A

Event ID: 4634 (Logoff)
Time: 2026-06-11 17:30:00
Account: JohnDoe
Logon ID: 0x45E3A

Analysis: ✅ Normal 9.5-hour session
Duration: Complete and clean
Risk: LOW
```

#### Example 2: Abandoned Session
```
Event ID: 4624 (Logon)
Time: 2026-06-11 08:00:00
Account: JohnDoe
Logon ID: 0x45E3A

Event ID: 4634 (Logoff) - NOT FOUND
Expected time: 2026-06-11 17:30:00

Analysis: ⚠️ No logoff event - session abandoned
Duration: Unknown (>8 hours at least)
Cause: System crash, ungraceful termination, or idle
Risk: MEDIUM - Session accessible if attacker gains credentials
```

#### Example 3: Brief Session
```
Event ID: 4624 (Logon)
Time: 2026-06-11 14:00:00
Account: admin
Logon ID: 0x45E3B

Event ID: 4634 (Logoff)
Time: 2026-06-11 14:02:00
Account: admin
Logon ID: 0x45E3B

Analysis: ⚠️ Very brief 2-minute session
Reason: Testing, quick task, or failed activity
Risk: MEDIUM - Investigate reason for brief logon
```

### MITRE ATT&CK Correlation

| ATT&CK Technique | Event Indicator |
|---|---|
| T1078 - Valid Accounts | Logoff after extended activity |
| T1021 - Remote Services | Logoff for RDP/network session |
| T1531 - Account Access Removal | Forced logoff indicating response |

---

## Event ID 4672: Special Privileges Assigned

### Summary
- **Event Name**: Special Privileges (Administrator-Equivalent) Assigned to New Logon
- **Security Category**: Privilege Escalation
- **Importance**: High (privilege escalation indicator)
- **Frequency**: Low-Medium (depends on admin use)
- **Threat Level**: Warning (if unexpected)

### Description

Event 4672 is logged when an account is assigned special privileges (administrator-equivalent rights). This event is crucial for detecting privilege escalation and monitoring administrative activity.

### Event Fields

#### Logon Session Information

| Field | Description | Example |
|-------|-------------|---------|
| **Subject Account Name** | Account receiving privileges | ADMIN |
| **Subject Domain** | Domain of account | CORP.LOCAL |
| **Subject Logon ID** | Session receiving privileges | 0x45E3A |
| **Logon Type** | Session type | 2 (Interactive) |

#### Privileges Assigned

| Privilege | Security Identifier | Description | Risk |
|-----------|-------------------|-------------|------|
| **SeChangeNotifyPrivilege** | SE_CHANGE_NOTIFY_NAME | Bypass directory traversal checks | Low |
| **SeDebugPrivilege** | SE_DEBUG_NAME | Debug processes (code execution) | **High** |
| **SeImpersonatePrivilege** | SE_IMPERSONATE_NAME | Impersonate other users | **High** |
| **SeLoadDriverPrivilege** | SE_LOAD_DRIVER_NAME | Load device drivers | **Critical** |
| **SeRestorePrivilege** | SE_RESTORE_NAME | Bypass file permission checks | **High** |
| **SeTcbPrivilege** | SE_TCB_NAME | Act as OS (Trusted Computing Base) | **Critical** |
| **SeSystemtimePrivilege** | SE_SYSTEMTIME_NAME | Change system time | Medium |
| **SeBackupPrivilege** | SE_BACKUP_NAME | Bypass file backup restrictions | **High** |

#### Privilege Levels
- **Low Risk**: SeChangeNotifyPrivilege, SeSystemtimePrivilege
- **Medium Risk**: SeShutdownPrivilege, SeRemoteShutdownPrivilege
- **High Risk**: SeDebugPrivilege, SeImpersonatePrivilege, SeBackupPrivilege, SeRestorePrivilege
- **Critical**: SeTcbPrivilege, SeLoadDriverPrivilege (system-level)

### Security Interpretation

#### Expected Privilege Assignments
```
✅ Administrator account receiving privileges - normal
✅ Service account with SeImpersonatePrivilege - expected
✅ SYSTEM account with any privileges - normal
✅ Privileged assignment at logon time - expected
```

#### Unexpected/Suspicious
```
⚠️ Regular user receiving SeDebugPrivilege
⚠️ Service account with SeTcbPrivilege
🚨 Non-admin account receiving SeLoadDriverPrivilege
🚨 Repeated privilege escalations for single user
⚠️ Privilege assignment outside work hours
```

### Real-World Examples

#### Example 1: Expected Admin Privileges
```
Event ID: 4672
Time: 2026-06-11 08:00:00
Account: Administrator
Domain: CORP
Logon Type: 2 (Interactive)
Privileges:
  - SeChangeNotifyPrivilege
  - SeDebugPrivilege
  - SeImpersonatePrivilege
  - SeRestorePrivilege
  - SeTcbPrivilege

Interpretation: ✅ Administrator logon with expected privileges
Risk: LOW (expected behavior)
```

#### Example 2: Service Account Configuration
```
Event ID: 4672
Time: 2026-06-11 08:00:15
Account: SQLService
Domain: CORP
Logon Type: 5 (Service)
Privileges:
  - SeChangeNotifyPrivilege
  - SeImpersonatePrivilege

Interpretation: ✅ Service account with necessary impersonation
Risk: LOW (expected for service accounts)
```

#### Example 3: Suspicious User Privilege Escalation
```
Event ID: 4672
Time: 2026-06-11 23:45:00
Account: JohnDoe
Domain: CORP
Logon Type: 2 (Interactive)
Privileges:
  - SeDebugPrivilege
  - SeLoadDriverPrivilege
  - SeTcbPrivilege

Prior Events:
  - 4625 failed login attempts (reconnaissance)
  - Multiple privilege escalation attempts

Interpretation: 🚨 Unauthorized privilege escalation
Risk: CRITICAL
Action: Immediate investigation, disable account, initiate IR
```

### Privilege Escalation Attack Pattern

#### How Attackers Use Privilege Events
```
1. Gain initial access (4624 with limited privileges)
2. Exploit vulnerability to escalate privileges
3. Event 4672 logged with unauthorized privileges
4. Attacker now has admin-level capabilities
5. Lateral movement (T1021), data exfiltration (T1020)
```

#### Detection Strategy
```
✓ Alert on any 4672 for non-expected accounts
✓ Alert on SeTcbPrivilege or SeLoadDriverPrivilege for users
✓ Correlate with 4625 failures (failed attempt to escalate)
✓ Alert on 4672 for deactivated/should-not-exist accounts
✓ Track privilege assignment frequency per user
```

### MITRE ATT&CK Correlation

| ATT&CK Technique | Event Indicator |
|---|---|
| T1134 - Access Token Manipulation | 4672 with unusual privileges |
| T1548 - Abuse Elevation Control | 4672 for unauthorized escalation |
| T1134.003 - Token Impersonation/Theft | 4672 with SeImpersonatePrivilege |
| T1053 - Scheduled Task Manipulation | 4672 + scheduled task creation |

---

## Event Correlation Guide

### How to Correlate Events

#### Method 1: Using Logon ID
```
Same Logon ID ties together events from one session:

4624 (Logon) → Logon ID: 0x45E3A
4672 (Privileges) → Logon ID: 0x45E3A (same session)
[User Activity in logs] → Logon ID: 0x45E3A
4634 (Logoff) → Logon ID: 0x45E3A

Result: Complete session audit trail
```

#### Method 2: Timeline Analysis
```
Timeline:
08:00 - Event 4624: JohnDoe logs in (Logon ID 0x45E3A)
08:05 - Event 4672: SeDebugPrivilege assigned (Logon ID 0x45E3A)
08:10 - Event 4688: Process created (Debugger.exe)
17:00 - Event 4634: JohnDoe logs off (Logon ID 0x45E3A)

Analysis: Shows complete user session with privilege use
```

#### Method 3: Cross-Event Analysis
```
Brute Force Attack Detection:
Multiple 4625s (failed logins) → Followed by 4624 (success)
Indicates: Attacker gained credentials, now has access

Privilege Escalation Detection:
Normal 4624 (limited user) → Followed by 4672 (admin privs)
Indicates: User escalated privileges (exploit or misuse)
```

### Common Investigation Patterns

| Pattern | Events | Interpretation | Risk |
|---------|--------|-----------------|------|
| Logon + Privilege + Activity + Logoff | 4624→4672→4688→4634 | Complete session audit | Normal |
| Failed logons then success | 4625(5x)→4624 | Brute force then compromise | **High** |
| Privilege without logon | 4672 (no matching 4624) | Orphaned session or data error | Medium |
| Logon without logoff | 4624 (no matching 4634) | Session abandoned or crash | Low-Medium |
| Rapid logon/logoff | 4624→4634 (seconds) | Reconnaissance or error | Medium |

---

## Investigation Checklist

Use this checklist when analyzing security events:

### For 4624 (Successful Logon)
- [ ] Is logon type expected for account?
- [ ] Is source IP/workstation expected?
- [ ] Is logon time within business hours?
- [ ] Is authentication method secure (NTLM v2+, Kerberos)?
- [ ] Does frequency match baseline?
- [ ] Is account active and authorized?

### For 4625 (Failed Logon)
- [ ] How many failures for this account?
- [ ] Time period (clustering indicates attack)?
- [ ] Failure reason (password vs. account issue)?
- [ ] Source IP address(es)?
- [ ] Is this pattern known/expected?
- [ ] Is account targeted or random?

### For 4634 (Logoff)
- [ ] Is matching logon event present?
- [ ] What is session duration?
- [ ] Is duration reasonable for activity?
- [ ] Is logoff during expected time?
- [ ] Any data loss or crash indicators?

### For 4672 (Privilege Assignment)
- [ ] Is account expected to receive these privileges?
- [ ] Is privilege type authorized?
- [ ] Is timing expected (logon vs. later)?
- [ ] Is privilege set minimal (principle of least privilege)?
- [ ] Any prior failed escalation attempts?

---

## Quick Reference Summary

| Event ID | When Logged | Key Risk | Primary Use | Red Flag |
|----------|-----------|----------|-------------|----------|
| **4624** | Successful logon | Access control | Who accessed system | Logon at odd time/IP |
| **4625** | Failed logon | Attack detection | Brute force/spray | Multiple failures/account |
| **4634** | Session end | Session tracking | Activity duration | Missing logoff entries |
| **4672** | Privilege grant | Escalation detect | Admin activity | Unexpected privilege assign |

---

## References

- [Microsoft Event 4624 Documentation](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4624)
- [Microsoft Event 4625 Documentation](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4625)
- [Microsoft Event 4634 Documentation](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4634)
- [Microsoft Event 4672 Documentation](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4672)
- [MITRE ATT&CK Framework](https://attack.mitre.org/)
- [Windows Security Auditing](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/advanced-security-audit-policy-settings)
