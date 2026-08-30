# Security Policy

## Reporting a vulnerability

Do not open a public issue for a suspected vulnerability. Use GitHub private vulnerability reporting if enabled, or a private channel published by the maintainers. Include affected files, impact, reproduction steps, and mitigation ideas. Never include live credentials, personal data, or exploit data from systems you do not own.

This reference project supports only the latest revision on the default branch. No response-time or remediation guarantee is implied.

## Deployment guidance

- Keep state in a private, versioned GCS bucket with least-privilege IAM, encryption, and suitable retention controls.
- Use WIF short-lived credentials; never commit keys or generated authentication files.
- Restrict WIF to the exact repository and trusted refs or environments.
- Protect the default branch and require review for deployment environments.
- Replace HTTP with HTTPS before serving sensitive or production traffic.
- Review IAM and use custom roles where practical.
- Prefer tested, patched images to installing unpinned packages at boot.
- Enable audit logging, budget alerts, vulnerability monitoring, and applicable organization policies.
- Treat Terraform state and plans as sensitive even when configuration is public.
