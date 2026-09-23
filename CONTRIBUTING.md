# TACHYS Contribution Guide

Thank you for your interest in contributing to **TACHYS**.

TACHYS is a scripting project designed to support basic computer inspection and diagnosis, especially for technician and internship activities. Contributions from anyone are welcome as long as they follow the guidelines below.

---

## 1. Types of Contributions

You can contribute in various ways, such as:

* Fixing bugs or errors in scripts.
* Adding new features.
* Improving compatibility with specific operating systems.
* Improving documentation.
* Improving code structure or quality.
* Adding new system checks or information.
* Reporting bugs or issues found.
* Providing suggestions for TACHYS development.

---

## 2. Reporting Issues

If you find a bug or issue, you can create an **Issue** in the TACHYS GitHub repository.

Please include enough information so the problem can be understood and reproduced, such as:

* Operating system used.
* Operating system version.
* TACHYS version used.
* Steps to reproduce the problem.
* Error message shown.
* Screenshots or terminal output if necessary.

The more complete the information provided, the easier the issue will be to review.

---

## 3. Making Changes

Before making changes, it is recommended to use a separate branch.

Examples:

```bash
git checkout -b feature-feature-name
```

or:

```bash
git checkout -b fix-issue-name
```

Avoid making direct changes to the main branch (`main`).

---

## 4. Commit

Use clear commit messages that describe the changes made.

Examples:

```text
Add system information check
```

```text
Fix Linux hardware detection
```

```text
Update installation instructions
```

Avoid overly generic commit messages such as:

```text
update
```

or:

```text
fix
```

---

## 5. Pull Request

Once the changes are complete, please create a **Pull Request (PR)** to the TACHYS repository.

Pull Requests are allowed for:

* New features.
* Bug fixes.
* Documentation improvements.
* Compatibility fixes.
* Structural or code changes.

### Required change explanation

Each Pull Request **must explain the changes made**.

At minimum, include:

* What was changed?
* Why is this change needed?
* Which parts or files were affected?
* How was the change tested?
* Are there any changes that could affect other features?

Example:

```text
## Changes

Added CPU information checks on Linux.

## Reason

CPU information was not available in the TACHYS output for Linux.

## Files Changed

- Tachys.sh

## Testing

Tested on Ubuntu and the CPU information was successfully displayed.

## Notes

This change only affects the CPU check section.
```

---

## 6. Review and Approval Process

Pull Requests created by contributors **will not be merged directly into the main branch**.

Each Pull Request will first be reviewed by a TACHYS maintainer.

The process is as follows:

```text
Contributor
    │
    ▼
Makes changes
    │
    ▼
Creates Pull Request
    │
    ▼
Explains changes
    │
    ▼
Maintainer review
    │
    ├── Needs changes ──► Contributor revises
    │                        │
    │                        └────► Review again
    │
    └── Approved
            │
            ▼
      Pull Request merged
```

**A Pull Request will only be merged after the change has been reviewed and approved by the maintainer.**

Therefore, creating a Pull Request **does not mean the change will automatically be accepted or merged**.

---

## 7. Maintainer Rights

Maintainers have the right to:

* Request changes to a Pull Request.
* Ask for additional explanation about the change.
* Reject changes that do not align with TACHYS goals.
* Ask contributors to fix code or documentation.
* Merge a Pull Request after the change is deemed suitable.

Merge decisions are made by considering stability, security, compatibility, and development goals of TACHYS.

---

## 8. Code Style

Please keep changes aligned with the structure and style already used in the project.

Avoid:

* Changing code unrelated to the contribution.
* Removing features without a clear reason.
* Adding unnecessary dependencies.
* Including personal information or credentials in the repository.
* Changing important configuration without explaining why.

---

## 9. Testing

Before creating a Pull Request, test the changes you have made.

If possible, explain:

* Operating system used.
* Command executed.
* Expected result.
* Result obtained.

If the change can only be tested on a specific system, explain the limitation in the Pull Request.

---

## 10. Security

Do not include sensitive information in the repository, including:

* Passwords.
* API keys.
* Tokens.
* Private keys.
* Credentials.
* User or customer personal information.

If you discover a security issue, do not directly publish sensitive information through an Issue or Pull Request.

---

## 11. License and Ownership of Contributions

By submitting a Pull Request, you state that the changes you contribute can be used in the TACHYS project in accordance with the license applied to the repository.

Make sure the code, documentation, or assets you contribute do not violate copyright or licensing rights of others.

---

## 12. Acknowledgment

Every contribution, whether code, documentation, bug reports, or suggestions, greatly helps the development of TACHYS.

Thank you to SMK PGRI 1 Martapura, Bandung Computer Banjarbaru, and all fellow internship colleagues for the support, guidance, and inspiration that continue to motivate the growth of this project.

Thank you for helping develop TACHYS.
