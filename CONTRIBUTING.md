# Contributing

Thank you for helping improve this project.

1. Fork the repository and create a focused branch.
2. Keep identifiers, credentials, state, plans, and generated authentication files out of commits.
3. Make a documented change and update examples when behavior changes.
4. Run:

   ```bash
   terraform fmt -recursive
   terraform fmt -check -recursive
   terraform init -backend=false
   terraform validate
   ```

5. Review `git diff` and scan it for sensitive or environment-specific data.
6. Open a pull request describing motivation, validation, and security/cost implications.

Follow standard Terraform formatting, prefer reusable inputs to hard-coded values, keep defaults safe, and avoid unnecessary dependencies. By contributing, you license your contribution under Apache License 2.0.
