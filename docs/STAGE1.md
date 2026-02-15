# Stage 1: Pipeline Foundation and Build

## Overview
Automated build and test validation for OWASP Juice Shop application.

## Workflow Steps
1. Checkout code
2. Setup Node.js v20
3. Install dependencies with `npm ci`
4. Build application
5. Run test suite (fails pipeline if tests fail)
6. Archive build artifacts

## Local Reproduction
```bash
npm ci
npm test
```

## Success Criteria
- ✅ All dependencies install successfully
- ✅ Application builds without errors
- ✅ All tests pass
- ❌ Pipeline fails if any test fails
