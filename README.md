# DevSecOps CI/CD Pipeline

> A comprehensive DevSecOps CI/CD pipeline built with GitHub Actions that enforces security checks automatically and blocks releases when security rules are violated.

## 📋 Overview

This project implements a **six-stage security pipeline** for [OWASP Juice Shop](https://github.com/juice-shop/juice-shop), an intentionally vulnerable web application. The pipeline demonstrates real-world DevSecOps practices by integrating security scanning directly into the CI/CD workflow.

### Pipeline Architecture
```
┌─────────────────┐     ┌──────────────────┐     ┌──────────────┐
│  Push to main   │────▶│  Build & Test     │────▶│  Secrets      │
│  or Pull Request│     │  (Node.js 18)     │     │  Scan         │
└─────────────────┘     └──────────────────┘     │  (Gitleaks)   │
                                                  └──────┬───────┘
                                                         │
                              ┌───────────────────────────┼───────────────────┐
                              ▼                           ▼                   ▼
                     ┌────────────────┐      ┌────────────────┐    ┌──────────────────┐
                     │  SAST Scan     │      │  SCA / Dep     │    │  (parallel)      │
                     │  (Semgrep)     │      │  Scan (Trivy)  │    │                  │
                     └────────┬───────┘      └────────┬───────┘    └──────────────────┘
                              │                       │
                              ▼                       ▼
                     ┌─────────────────────────────────────────┐
                     │        Container Security (Trivy)        │
                     │        Build image → Scan → Gate         │
                     └────────────────┬────────────────────────┘
                                      │
                                      ▼
                     ┌─────────────────────────────────────────┐
                     │     Security Report & Metrics            │
                     │     Summary + Artifacts + Dashboard      │
                     └─────────────────────────────────────────┘
```

## 🛠️ Security Tools

| Stage | Tool | Purpose |
|-------|------|---------|
| Secrets Scanning | [Gitleaks](https://github.com/gitleaks/gitleaks) | Detect hardcoded credentials, API keys, tokens |
| SAST | [Semgrep](https://semgrep.dev/) | Static code analysis for security vulnerabilities |
| SCA | [Trivy](https://trivy.dev/) | Dependency vulnerability scanning (CVEs) |
| Container Security | [Trivy](https://trivy.dev/) | Docker image vulnerability scanning |

## 🚀 Getting Started

### Prerequisites

- Git
- Docker
- A GitHub account
- Node.js 18 (for local development)

### Clone and Setup
```bash
git clone git@github.com:Kentunji/devsecops-cicd-pipeline.git
cd devsecops-cicd-pipeline
git push origin main
```

### Local Build Reproduction
```bash
chmod +x scripts/local-build.sh
./scripts/local-build.sh
```

## 📁 Project Structure
```
devsecops-cicd-pipeline/
├── .github/
│   └── workflows/
│       └── devsecops-pipeline.yml   # Main CI/CD pipeline (all 6 stages)
├── scripts/
│   ├── demo-secrets-scan.sh         # Task 2: Secrets scanning demo
│   └── local-build.sh              # Local build reproduction script
├── .gitleaks.toml                   # Gitleaks configuration
├── .semgrepignore                   # Semgrep exclusions
├── Dockerfile                       # (from Juice Shop)
├── package.json                     # (from Juice Shop)
└── README.md                        # This file
```

## 🔒 Security Quality Gates

Each security stage acts as a **quality gate** that can block the pipeline:

| Gate | Condition to Fail | Action |
|------|-------------------|--------|
| Secrets | Any hardcoded credential detected | ❌ Pipeline fails immediately |
| SAST | Critical/High severity code issues | ❌ Pipeline fails |
| SCA | Critical/High CVEs in dependencies | ⚠️ Warning (configurable to fail) |
| Container | Critical/High CVEs in Docker image | ⚠️ Warning (configurable to fail) |

> **Note:** For OWASP Juice Shop (intentionally vulnerable), SCA and Container gates are set to warn rather than fail. In production, all gates should be set to fail.

## 📊 Security Metrics (Task 6)

The pipeline tracks three key metrics:

1. **Vulnerability Severity Distribution** — Count of Critical/High/Medium findings per scan type, enabling trend analysis over time.

2. **Pipeline Security Gate Pass Rate** — Percentage of security stages that pass their quality gates per run, indicating overall security posture.

3. **Security Scan Coverage** — Number of security tools applied per pipeline run (target: 4/4 = 100%), ensuring no security checks are skipped.

## 📝 Task Demonstrations

### Task 2: Proving the Secrets Gate
```bash
chmod +x scripts/demo-secrets-scan.sh
./scripts/demo-secrets-scan.sh
```

### Task 3: SAST Findings

After pipeline runs, download the `sast-report` artifact from GitHub Actions to view Semgrep findings. To fix a finding:
1. Review the finding in `semgrep-results.json`
2. Apply the suggested fix
3. Push and verify the finding is resolved

### Task 4: Dependency Remediation

To remediate a vulnerable dependency:
1. Download `sca-report` artifact
2. Identify the vulnerable package and CVE
3. Run `npm audit` to see advisories
4. Run `npm audit fix` or manually update `package.json`
5. Push and verify the vulnerability is resolved

## 🔧 Configuration

### Pipeline Credentials

All sensitive values are stored in **GitHub Secrets** (Settings → Secrets and variables → Actions):
- `GITHUB_TOKEN` — Automatically provided by GitHub Actions
- `GITLEAKS_LICENSE` — Optional, for Gitleaks commercial features

### Customizing Quality Gates

Edit `.github/workflows/devsecops-pipeline.yml`:
- Change `TRIVY_SEVERITY` env var to adjust Trivy thresholds
- Modify Semgrep `--severity` flags for SAST sensitivity
- Uncomment `exit 1` lines in SCA/Container stages to enforce hard failures

## 📄 License

This project is for educational purposes as part of the DevSecOps CI/CD Lab.

---

*Built by Kehinde Adetunji as part of the Security and Network Engineering Master's program at Innopolis University.*
