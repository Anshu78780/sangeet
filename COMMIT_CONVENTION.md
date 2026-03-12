# Commit Convention

This project uses the [Conventional Commits](https://www.conventionalcommits.org/) specification for commit messages. This leads to more readable messages that are easy to follow when looking through the project history.

## Commit Message Format

Each commit message consists of a **header**, an optional **body**, and an optional **footer**.

```
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

### 1. Type
Must be one of the following:
* **feat**: A new feature
* **fix**: A bug fix
* **docs**: Documentation only changes
* **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
* **refactor**: A code change that neither fixes a bug nor adds a feature
* **perf**: A code change that improves performance
* **test**: Adding missing tests or correcting existing tests
* **chore**: Changes to the build process or auxiliary tools and libraries such as documentation generation
* **build**: Changes that affect the build system or external dependencies
* **ci**: Changes to CI configuration files and scripts
* **revert**: Reverts a previous commit

### 2. Scope (Optional)
The scope should be the name of the npm package, module, or component affected (e.g., `api`, `auth`, `ui`).

### 3. Subject
The subject contains a succinct description of the change:
* use the imperative, present tense: "change" not "changed" nor "changes"
* don't capitalize the first letter
* no dot (.) at the end

### Examples

**Feature with scope:**
```
feat(auth): add email verification
```

**Bug fix:**
```
fix: resolve crash on app startup
```

**Breaking change (indicated by `!` or in footer):**
```
feat(api)!: overhaul the video extraction endpoints

BREAKING CHANGE: The `y2mate` extractor now requires an authentication token.
```
