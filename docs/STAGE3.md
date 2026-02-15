# Stage 3: SAST (Static Application Security Testing)

## Overview
Static code analysis using Semgrep to detect security vulnerabilities. Pipeline FAILS if critical or high severity issues are found.

## Tool Configuration
- **Tool**: Semgrep
- **Container**: `semgrep/semgrep` (official image)
- **Rulesets**:
  - `auto` - Automatic detection
  - `p/javascript` - JavaScript security rules
  - `p/typescript` - TypeScript security rules
  - `p/nodejs` - Node.js security patterns
  - `p/owasp-top-ten` - OWASP Top 10 vulnerabilities
  - `p/security-audit` - Comprehensive security audit

## Quality Gate Policy

**CRITICAL REQUIREMENT**: Pipeline MUST fail when critical/high issues found

| Severity | Action |
|----------|--------|
| **ERROR** (Critical/High) | ❌ **FAIL pipeline** - Block deployment |
| **WARNING** (Medium) | ⚠️ **Warn only** - Allow deployment |
| **INFO** (Low) | ℹ️ **Log only** - Allow deployment |

## Workflow Steps

1. **Checkout code**
2. **Run Semgrep** (3 output formats):
   - JSON format → `semgrep-results.json` (for parsing)
   - Text format → `semgrep-results.txt` (human-readable)
   - SARIF format → `semgrep-results.sarif` (compliance)
3. **Quality Gate Check**:
   - Parse JSON results
   - Count ERROR severity findings
   - If ERROR > 0 → **EXIT 1** (fail pipeline)
   - If ERROR = 0 → Continue
4. **Upload artifacts** (always runs, even on failure)

## Expected Behavior for OWASP Juice Shop

Since Juice Shop is **intentionally vulnerable**:

### First Run (Before Fixes)
- ❌ **Pipeline will FAIL**
- Semgrep will detect critical issues like:
  - SQL Injection
  - Command Injection
  - Path Traversal
  - XSS vulnerabilities
  - Insecure cryptography

### After Fixing One Finding
- ✅ **Pipeline MAY pass** (if you fix all ERROR severity issues)
- OR still fail if critical issues remain

## Fixing a Finding (Required for Lab)

### Step 1: Download and Review Report
```bash
# After pipeline fails, download the artifact
# Go to GitHub Actions → Failed run → Artifacts → sast-semgrep-report

# Extract and view
unzip sast-semgrep-report.zip
cat semgrep-results.txt | head -50
```

### Step 2: Choose a Finding to Fix

Look for ERROR severity issues. Example finding:
```
server.ts:245: ERROR - SQL Injection
  Dangerous use of eval() with user input
  Rule: javascript.lang.security.audit.eval-detected
```

### Step 3: Fix the Issue

**Before (Vulnerable)**:
```javascript
// Example from Juice Shop
eval(req.query.code)  // ❌ Dangerous!
```

**After (Fixed)**:
```javascript
// Safe alternative
try {
  const result = JSON.parse(req.query.code)
  // Process safely
} catch (e) {
  // Handle error
}
```

### Step 4: Verify Fix
```bash
cd ~/devsecops-cicd-pipeline

# Make the fix in the code file
nano server.ts  # or vim, code, etc.

# Commit the fix
git add server.ts
git commit -m "Fix: Remove eval() usage to address SAST finding

- Replace eval() with JSON.parse()
- Resolves Semgrep ERROR severity issue
- Improves code security posture"

git push origin main
```

### Step 5: Verify Pipeline Passes

- Go to GitHub Actions
- Watch new workflow run
- **If all ERROR findings fixed** → ✅ Pipeline PASSES
- **If ERROR findings remain** → ❌ Pipeline still FAILS

## Artifacts Generated

After each run (pass or fail):

| File | Format | Purpose |
|------|--------|---------|
| `semgrep-results.json` | JSON | Machine-readable, for automation |
| `semgrep-results.txt` | Text | Human-readable report |
| `semgrep-results.sarif` | SARIF | Security industry standard format |

**All three files uploaded as artifact**: `sast-semgrep-report`

## Viewing Results

### In GitHub Actions Logs
```
==========================================
SAST Quality Gate Results
==========================================
Critical/High (ERROR): 15
Medium (WARNING): 23
==========================================
❌ SAST Quality Gate FAILED!
Found 15 critical/high severity issues
Review semgrep-results.txt for details
```

### In Downloaded Artifact
Open `semgrep-results.txt`:
```
┌──────────────┬─────────────────────────────────┐
│ Severity     │ Count                           │
├──────────────┼─────────────────────────────────┤
│ ERROR        │ 15                              │
│ WARNING      │ 23                              │
│ INFO         │ 8                               │
└──────────────┴─────────────────────────────────┘

Finding 1:
  File: routes/search.js:42
  Severity: ERROR
  Rule: javascript.express.security.audit.express-sql-injection
  Message: Potential SQL injection vulnerability
  Code:
    db.query("SELECT * FROM products WHERE name = '" + req.query.q + "'")
```

## For Lab Report

### Evidence Required

1. **Screenshot: Failed Pipeline** (before fix)
   - Stage 3 with red X
   - Error count in logs
   
2. **Artifact: semgrep-results.txt** (before fix)
   - Download and include in report
   - Highlight one ERROR finding

3. **Code Change: Fix Implementation**
   - Show before/after code
   - Explain the security improvement

4. **Screenshot: Passing Pipeline** (after fix)
   - Stage 3 with green checkmark
   - Quality gate passed message

### Documentation Points
```
Quality Gate Policy:
- Fail pipeline when: ERROR (Critical/High) severity > 0
- Implementation: exit 1 in quality gate step
- Results: Pipeline blocked deployment with 15 critical findings
- Remediation: Fixed eval() injection vulnerability in server.ts
- Outcome: After fix, ERROR count reduced to 0, pipeline passed
```

## Troubleshooting

### Issue: No artifacts uploaded
**Cause**: `if: always()` missing on upload step
**Solution**: Already fixed in workflow (always uploads)

### Issue: Pipeline doesn't fail despite findings
**Cause**: `exit 1` not executed in quality gate
**Solution**: Already fixed - explicit `exit 1` on ERROR findings

### Issue: Can't parse JSON results
**Cause**: Semgrep didn't generate JSON
**Solution**: Using container image with proper Semgrep installation

## Success Criteria

For this stage to be complete:

- ✅ Semgrep scans execute successfully
- ✅ Three report formats generated (JSON, TXT, SARIF)
- ✅ Artifacts uploaded (visible in GitHub Actions)
- ✅ **Quality gate FAILS pipeline** when ERROR findings exist
- ✅ At least one finding fixed (documented)
- ✅ **Quality gate PASSES pipeline** after fix

## Next Steps

After Stage 3 is verified:
- Download sast-semgrep-report artifact
- Review findings
- Fix at least one ERROR severity issue
- Verify pipeline passes
- Move to **Stage 4: SCA/Dependency Scanning**
