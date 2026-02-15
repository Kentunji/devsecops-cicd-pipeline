# Stage 3: SAST (Static Application Security Testing)

## Overview
Static code analysis using Semgrep to detect security vulnerabilities in source code before runtime.

## Tool
- **Semgrep**: Fast, customizable static analysis tool
- **Rulesets Applied**:
  - `p/default` - General best practices
  - `p/javascript` - JavaScript-specific rules
  - `p/typescript` - TypeScript-specific rules
  - `p/nodejs` - Node.js security patterns
  - `p/owasp-top-ten` - OWASP Top 10 vulnerabilities
  - `p/security-audit` - Comprehensive security audit

## Workflow Steps
1. Checkout source code
2. Run Semgrep with multiple security rulesets
3. Generate SARIF report
4. Check for critical/high severity findings
5. Fail pipeline if critical issues found (quality gate)
6. Upload report as artifact

## Quality Gate Policy
- **FAIL** if: Critical or High severity findings detected
- **PASS** if: Only Medium/Low/Info findings (or none)

## Common Findings in OWASP Juice Shop

Semgrep will likely detect issues like:
- SQL Injection vulnerabilities
- Cross-Site Scripting (XSS) risks
- Insecure deserialization
- Path traversal vulnerabilities
- Weak cryptography usage
- Hardcoded secrets (overlap with Gitleaks)

**Note**: These are intentional vulnerabilities in Juice Shop for training purposes.

## Viewing Results

### GitHub Actions UI
1. Go to Actions → Select workflow run
2. Click "Stage 3: SAST"
3. View findings in the logs
4. Download `semgrep-report` artifact

### SARIF Report
Download `semgrep.sarif` and view in:
- VS Code with SARIF Viewer extension
- GitHub Security tab (if enabled)
- Any SARIF-compatible viewer

## Remediation Process

For each finding:
1. **Review the issue** - Understand the vulnerability
2. **Assess severity** - Check if it's a real risk
3. **Fix or suppress**:
   - Fix: Update code to remove vulnerability
   - Suppress: Add `# nosemgrep` comment if false positive

Example fix:
```javascript
// Before (vulnerable)
eval(userInput);

// After (secure)
JSON.parse(userInput);
```

## Optional: Fix One Finding

To demonstrate remediation in your lab:

1. Download semgrep report
2. Choose one LOW severity finding
3. Fix the issue in code
4. Commit and push
5. Show the finding disappears in next run

## Success Criteria
- ✅ Semgrep scans complete without errors
- ✅ SARIF report generated
- ⚠️ Findings detected (expected for Juice Shop)
- ✅ Quality gate evaluated correctly

## For Lab Report

### Evidence to Include
1. Screenshot of SAST stage running
2. Screenshot showing findings count
3. Sample of SARIF report
4. (Optional) Before/after of fixing one issue

### Key Points to Document
- Tool used: Semgrep
- Rulesets applied: OWASP Top 10, Node.js security, etc.
- Quality gate policy: Fail on critical/high
- Number and types of findings
- Remediation approach (if you fix any)
