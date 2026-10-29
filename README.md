# GitOps-Driven CDN Edge & Security Pipeline

A production-ready Infrastructure-as-Code (IaC) pipeline that automates edge network delivery, content optimization, and Web Application Firewall (WAF) security policies.

This repository demonstrates how to manage an enterprise-grade secure edge layer using a GitOps framework. By treating delivery rules and security policies as version-controlled code, engineering teams can eliminate manual dashboard errors, guarantee compliance, and accelerate release velocities.

##  Project Architecture & File Mapping

The workspace is modularized into dedicated structural layers within the `terraform/` directory:
*   **`providers.tf`**: Initializes infrastructure providers and handles environment locking.
*   **`variables.tf`**: Abstracts account metadata to ensure deployment portability between environments.
*   **`edge_delivery.tf`**: The routing and content optimization engine. Configures reverse-proxy mappings to an upstream cloud origin (e.g., AWS Application Load Balancer) and sets conditional edge caching thresholds.
*   **`edge_security.tf`**: The automated perimeter firewall. Implements live signature and regex scanning to mitigate OWASP Top 10 vulnerabilities directly at the internet's edge.

---

##  Enterprise Portfolio Mapping: Translating to Akamai, Jira, and Confluence

To facilitate rapid technical testing without enterprise contract constraints, this repository utilizes an open-source provider sandbox. However, the architectural design, abstraction patterns, and operational logic directly translate to an **Akamai-centric enterprise ecosystem**:

### 1. Akamai Property Manager Integration (`edge_delivery.tf`)
The conditional routing, compression settings, and file-extension matching logic built into `edge_delivery.tf` map directly to **Akamai Property Manager JSON rules** managed via the Property Manager API (PAPI).
*   **Origin Routing**: The global origin routing block corresponds directly to an Akamai origin behavior utilizing `verificationMode: PLATFORM_SETTINGS`, `originSni: true`, and `forwardHostHeader: REQUEST_HOST_HEADER`.
*   **Static Offloading**: The `Static Asset Optimization` rule translates directly to an Akamai **Caching Behavior** set to `MAX_AGE` (30 days), which would include enabling `tieredDistribution` (Origin Shielding) to protect the AWS backend.
*   **Dynamic Exceptions**: The `Dynamic Compliance` rule matches the behavior of an Akamai caching override rule set to `BYPASS_CACHE`, forcing real-time traffic through Akamai's **SureRoute** performance optimization pathways.

### 2. Akamai AppSec & Web Application Protector Integration (`edge_security.tf`)
The security layer mirrors the configuration lifecycle of **Akamai Web Application Protector (WAP)** and App & API Protector.
*   **Attack Group Controls**: The regex rules for blocking malicious payloads match shifting the native Akamai WAP **SQLi and XSS Attack Groups** into active `Deny/Block` mode.
*   **Bot Management Profiles**: The challenge rule block maps directly to executing an Akamai **Bot Manager** client-side challenge to drop unauthorized directory scanning traffic before it incurs origin compute bills.
*   **Enterprise Scaling**: In a live Akamai production setup, these manual filters would be entirely abstracted using Akamai's **Adaptive Security Engine (`attack_protection_rule_set = "ASE_AUTO"`)** to offload signature maintenance to Akamaiâ€™s global threat intelligence teams.

### 3. Change Management & Jira Support
In an enterprise workflow, the GitHub Actions deployment engine integrates directly with **Jira Change Management via CI/CD webhooks**:
*   **Automated Ticket Advancement**: When an engineer opens a Pull Request to adjust a caching rule or security policy, a pipeline script extracts the Jira issue key (e.g., `SEC-104`) from the commit message.
*   **Plan Logging**: The pipeline automatically prints the output of `terraform plan` as a formal comment inside the corresponding Jira ticket, providing a transparent audit trail for security and operations reviewers.
*   **State Alignment**: Upon merging to `main`, successful execution of `terraform apply` triggers a webhook that advances the Jira issue status from "In Review" to "Completed."

### 4. Technical Runbooks & Confluence Support
To eliminate documentation rot, the output schemas of this pipeline sync with **Confluence Space API Engines**:
*   The configuration versions, active edge caching rules, and asset path lists are extracted as clean JSON arrays during deployment.
*   An automated post-deployment routine formats these outputs into human-readable tables and updates internal engineering runbooks in Confluence via its REST API. This ensures that security matrices and caching exceptions are updated dynamically without manual documentation overhead.

---

## ð Automated CI/CD Pipeline Lifecycle

The continuous deployment architecture is governed by GitHub Actions inside `.github/workflows/deploy-edge.yml`:


