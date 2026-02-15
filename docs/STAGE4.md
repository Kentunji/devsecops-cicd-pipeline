# Stage 4: SCA (Software Composition Analysis) / Dependency Scanning

## Overview
Scan npm dependencies for known vulnerabilities (CVEs) using Trivy. Fails pipeline if critical or high severity vulnerabilities are detected.

## Tool
- **Trivy**: Comprehensive vulnerability scanner
- **Scan Type**: Filesystem scan (`fs`)
- **Targets**: `package.json`, `package-lock.json`

## Quality Gate Policy

| Severity | Action |
|----------|--------|
| **CRITICAL** | ❌ **FAIL pipeline** - Block deployment |
| **HIGH** | ❌ **FAIL pipeline** - Block deployment |
| **MEDIUM** | ⚠️ **Warn only** - Allow deployment |
| **LOW** | ℹ️ **Info only** - Allow deployment |

## Workflow Steps

1. **Checkout code**
2. **Run Trivy filesystem scan** (JSON format)
3. **Run Trivy filesystem scan** (Table format - human readable)
4. **Quality Gate Check**:
   - Parse JSON results
   - Count CRITICAL and HIGH vulnerabilities
   - If count > 0 → **EXIT 1** (fail pipeline)
5. **Upload artifacts** (always runs)

## Expected Behavior

### OWASP Juice Shop Dependencies
Juice Shop has many dependencies (500+). It's likely Trivy will find vulnerabilities because:
- Some dependencies may be outdated
- Known CVEs in popular packages
- Transitive dependencies with issues

### First Run
- ❌ **Pipeline will likely FAIL**
- Trivy will detect vulnerable dependencies
- Report shows CVE IDs, severity, affected packages

### Remediation Options

**Option 1: Upgrade Dependencies**
```bash
# Update package.json versions
npm update

# Or manually upgrade specific packages
npm install package-name@latest

# Regenerate lock file
npm install

# Commit changes
git add package.json package-lock.json
git commit -m "Update dependencies to fix CVEs"
```

**Option 2: Accept Risk (Suppress)**
For vulnerabilities that can't be fixed:
```bash
# Create .trivyignore file
cat > .trivyignore << 'IGNORE'
# CVE-2024-XXXXX - No fix available, low risk in our context
CVE-2024-XXXXX

# CVE-2024-YYYYY - Fixed in future version, not yet compatible
CVE-2024-YYYYY
IGNORE
```

**Option 3: Adjust Quality Gate**
Change policy to warn instead of fail:
```yaml
exit-code: '0'  # Don't fail, just report
```

## Common Vulnerabilities in Juice Shop

Typical findings:
- **Prototype Pollution** in older packages
- **ReDoS** (Regular Expression Denial of Service)
- **Path Traversal** in file handling packages
- **XSS** in template engines
- **SQL Injection** in ORM packages

## Viewing Results

### GitHub Actions UI
1. Actions → Failed run
2. Click "Stage 4: SCA / Dependency Scan"
3. View vulnerability counts in Quality Gate step

### Download Report
1. Scroll to Artifacts
2. Download `sca-trivy-report`
3. Open `trivy-sca-results.txt`

Example output:
```
┌─────────────────────┬────────────────┬──────────┬───────────────────┬───────────────┬─────────────────────────────────────┐
│      Library        │ Vulnerability  │ Severity │ Installed Version │ Fixed Version │             Title                   │
├─────────────────────┼────────────────┼──────────┼───────────────────┼───────────────┼─────────────────────────────────────┤
│ express             │ CVE-2024-43796 │ HIGH     │ 4.17.3            │ 4.19.2        │ express: path disclosure on...      │
│ jsonwebtoken        │ CVE-2022-23529 │ CRITICAL │ 8.5.1             │ 9.0.0         │ jsonwebtoken: lacks algorithm...    │
└─────────────────────┴────────────────┴──────────┴───────────────────┴───────────────┴─────────────────────────────────────┘
```

## Remediation Documentation

For each finding:
1. **Identify**: Note CVE ID, package, current version
2. **Research**: Check if fix available
3. **Upgrade**: Update to fixed version
4. **Test**: Run tests to ensure compatibility
5. **Verify**: Re-run scan to confirm fix

Example remediation:
```bash
# Finding: jsonwebtoken 8.5.1 has CVE-2022-23529 (CRITICAL)
# Fixed in: 9.0.0

# Upgrade
npm install jsonwebtoken@9.0.0

# Verify
npm list jsonwebtoken

# Test
npm test

# Commit if tests pass
git add package.json package-lock.json
git commit -m "Upgrade jsonwebtoken to 9.0.0 (fixes CVE-2022-23529)"
git push
```

## Success Criteria

✅ **Stage 4 passes when**:
- Trivy scan completes successfully
- No CRITICAL or HIGH vulnerabilities in dependencies
- Reports generated and uploaded

❌ **Stage 4 fails when**:
- Any CRITICAL severity dependency found
- Any HIGH severity dependency found
- Scan cannot complete

## For Lab Report

### Evidence to Include

1. **Failed Run** (before remediation):
   - Screenshot showing vulnerability count
   - Sample from trivy-sca-results.txt
   - List of critical/high CVEs

2. **Remediation Process**:
   - Document 1-2 dependency upgrades
   - Show before/after package.json versions
   - Git commit message

3. **Passing Run** (after remediation):
   - Screenshot showing 0 critical/high
   - Clean quality gate

### Key Documentation Points
```
Initial SCA Scan:
- Found X CRITICAL and Y HIGH severity vulnerabilities
- Total vulnerable dependencies: Z
- Primary issues: outdated packages with known CVEs

Remediation Strategy:
1. Identified dependencies with fixes available
2. Upgraded packages maintaining compatibility
3. Ran test suite to verify functionality
4. Re-scanned to confirm vulnerability resolution

Quality Gate Policy:
- Fail on: CRITICAL or HIGH severity in dependencies
- Warn on: MEDIUM severity
- Locked versions: package-lock.json for deterministic builds

Results:
- Before: X critical/high vulnerabilities
- After: 0 critical/high vulnerabilities
- Pipeline: PASSED
```

## Next Steps

After Stage 4 passes:
- **Stage 5**: Container Security (Docker image scanning)
- **Stage 6**: Reporting and Metrics
