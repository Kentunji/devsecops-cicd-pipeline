# Stage 5: Container Security

## Overview
Build Docker container image, tag with traceable identifier (commit SHA), scan for vulnerabilities, and fail pipeline on critical or high findings.

## Tool
**Trivy** - Comprehensive container vulnerability scanner

## Core Requirements

### ✅ 1. Build Container Image
```bash
docker build -t juice-shop:${{ github.sha }} .
```

### ✅ 2. Tag with Traceable Identifier
- **Tag**: Commit SHA (`${{ github.sha }}`)
- **Purpose**: Immutable, cryptographic identifier
- **Traceability**: Links image directly to source code commit

### ✅ 3. Scan for Vulnerabilities
```bash
trivy image juice-shop:${{ github.sha }}
```

Trivy scans:
- OS packages in base image
- Application dependencies
- Known CVEs in all layers

### ✅ 4. Fail on Critical/High Findings
**Quality Gate Policy**:
- ❌ **FAIL** if CRITICAL severity found
- ❌ **FAIL** if HIGH severity found
- ⚠️ **WARN** on MEDIUM severity
- ℹ️ **INFO** on LOW severity

## Workflow Steps

1. **Checkout code**
2. **Build Docker image**
   - Use Dockerfile from repository
   - Tag with `${{ github.sha }}` (traceable identifier)
   - Also tag as `latest` for convenience
3. **Scan image (JSON format)**
   - Full vulnerability data for automation
4. **Scan image (Table format)**
   - Human-readable report
5. **Quality Gate Check**
   - Parse JSON results
   - Count CRITICAL and HIGH vulnerabilities
   - If count > 0 → **EXIT 1** (fail pipeline)
   - If .trivyignore exists → Accept risk, pass with warning
6. **Upload artifacts**
   - Always runs (even on failure)
   - Stores scan results for evidence

## Expected Behavior

### First Run (No .trivyignore)
```
Container Security Gate Results
==========================================
Critical/High vulnerabilities: 145
==========================================
❌ Container Security Gate FAILED!
Found 145 critical/high severity vulnerabilities
Review trivy-container-results.txt for remediation steps
```

### With .trivyignore (Training App)
```
Container Security - Risk Acceptance Mode
==========================================
⚠️ .trivyignore file detected
Total Critical/High container vulnerabilities: 145
Status: Accepted with documented justification
✅ Container Security Gate PASSED (Risk Accepted)
```

## Traceable Identifier

**Tag Format**: `juice-shop:<commit-sha>`

**Example**: `juice-shop:a1b2c3d4e5f6789...`

**Benefits**:
- ✅ Immutable (cannot be changed)
- ✅ Cryptographic (SHA-1 hash)
- ✅ Links image to exact source code
- ✅ Enables audit trail
- ✅ Supports rollback to specific commits

**Verification**:
```bash
# Find which commit an image was built from
docker inspect juice-shop:a1b2c3d4 | jq '.[0].Config.Labels'

# View source code for that commit
git show a1b2c3d4
```

## Difference from Stage 4 (SCA)

| Aspect | Stage 4: SCA | Stage 5: Container |
|--------|--------------|---------------------|
| **Scan Target** | package-lock.json | Docker image |
| **Scope** | npm dependencies only | Base image + dependencies |
| **Finds** | Application CVEs | OS packages + application CVEs |
| **Example** | crypto-js vulnerability | Ubuntu base image + crypto-js |
| **Layer** | Application layer | All container layers |

**Stage 5 finds MORE vulnerabilities** because it includes the base image (Node.js, OS packages, system libraries).

## Quality Gate Implementation
```python
# Count CRITICAL and HIGH vulnerabilities
critical_high = 0
for result in scan_results:
    for vulnerability in result.get('Vulnerabilities', []):
        if vulnerability['Severity'] in ['CRITICAL', 'HIGH']:
            critical_high += 1

# Apply policy
if critical_high > 0:
    print(f"❌ FAILED: {critical_high} critical/high vulnerabilities")
    exit(1)  # Fail pipeline
else:
    print("✅ PASSED: No critical/high vulnerabilities")
    exit(0)  # Pass pipeline
```

## Artifacts Generated

| File | Format | Purpose |
|------|--------|---------|
| `trivy-container-results.json` | JSON | Machine-readable, automation |
| `trivy-container-results.txt` | Table | Human-readable report |

## Optional Enhancements (Not Implemented)

### Cosign Image Signing
```bash
# Sign image
cosign sign juice-shop:${{ github.sha }}

# Verify signature
cosign verify juice-shop:${{ github.sha }}
```

### in-toto Provenance
```bash
# Generate build provenance
in-toto-run --step-name build --products juice-shop:latest -- docker build .
```

## For Lab Report

### Evidence Required

1. **Build Logs** - Showing image built with SHA tag
2. **Scan Results** - Vulnerability count (before/after .trivyignore)
3. **Quality Gate** - Failed run screenshot
4. **Quality Gate** - Passed run screenshot (with .trivyignore)
5. **Artifacts** - Downloaded trivy-container-results.txt

### Documentation Template
```
Stage 5: Container Security

Tool: Trivy
Image: juice-shop
Traceable Tag: juice-shop:a1b2c3d4e5f6789 (commit SHA)

Build Process:
- Dockerfile: Uses official Node.js base image
- Build command: docker build -t juice-shop:$SHA .
- Traceable identifier: Commit SHA ensures exact source linkage

Scan Results:
- Base image vulnerabilities: 95 (Node.js, Ubuntu packages)
- Application layer vulnerabilities: 50 (npm dependencies)
- Total CRITICAL/HIGH: 145

Quality Gate Policy:
- FAIL on: CRITICAL or HIGH severity
- Initial result: FAILED (145 critical/high found)
- Resolution: Risk accepted via .trivyignore (training app)
- Final result: PASSED (with documented justification)

Traceability:
- Image tag links to commit: a1b2c3d4e5f6789
- Can reproduce build from exact source code
- Audit trail maintained in git history
```

## Success Criteria

✅ **Stage 5 succeeds when**:
- Docker image builds successfully
- Image tagged with commit SHA
- Trivy scan completes
- No CRITICAL/HIGH vulnerabilities found
  - OR .trivyignore exists with proper justification
- Scan reports uploaded as artifacts

## Common Issues

### Issue: Image build fails
**Solution**: Check Dockerfile syntax, ensure base image is available

### Issue: Scan finds too many vulnerabilities
**Solution**: 
- Use newer base image (`node:20-alpine` vs `node:20`)
- Accept risk with `.trivyignore` (for training only)
- Upgrade dependencies (see Stage 4)

### Issue: Quality gate too strict
**Solution**: Document and accept risk for training environment

## Next Steps

After Stage 5 passes:
- Optionally implement image signing (Cosign)
- Optionally generate SBOM
- Move to Stage 6: Reporting & Metrics
