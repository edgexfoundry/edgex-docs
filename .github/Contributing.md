## <a name="commit"></a> Commit Message Guidelines

We have very precise rules over how our git commit messages can be formatted.  This leads to **more readable messages** that are easy to follow when looking through the **project history**. For full contribution guidelines visit
the [Contributors Guide](https://wiki.edgexfoundry.org/display/FA/Committing+Code+Guidelines#CommittingCodeGuidelines-Commits) on the EdgeX Wiki

### Commit Message Format
Each commit message consists of a **header**, a **body** and a **footer**.  The header has a special format that includes a **type**, a **scope** and a **subject**:

```
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

The **header** with **type** is mandatory.  The **scope** of the header is optional as far as the automated PR checks are concerned, but be advised that PR reviewers **may request** you provide an applicable scope.

Any line of the commit message cannot be longer 100 characters! This allows the message to be easier to read on GitHub as well as in various git tools.

The footer should contain a [closing reference to an issue](https://help.github.com/articles/closing-issues-via-commit-messages/) if any.

Example 1:
```
feat: add new app service description
```

Example 2:
```
fix(ref): correct default database port configuration 

Previously configuration page references the wrong default database port. This commit fixes the default database port for Redis references in the configuration page.

Closes: #123
```

### Revert
If the commit reverts a previous commit, it should begin with `revert: `, followed by the header of the reverted commit. In the body it should say: `This reverts commit <hash>.`, where the hash is the SHA of the commit being reverted.

### Type
Must be one of the following:

* **feat**: A new feature
* **fix**: A bug fix
* **style**: Changes that do not affect the meaning of the code (white-space, formatting, etc)
* **build**: Changes that affect the CI/CD pipeline or build system or external dependencies (example scopes: travis, jenkins, makefile)
* **ci**: Changes provided by DevOps for CI purposes.
* **revert**: Reverts a previous commit.

### Scope
Should be one of the following:
Modules:
* **api**: A change or addition to API documentation
* **adr**: A change or addition to architectural design decisions
* **legacy**: A change or addition to legacy design documentation
* **examples**: A change or addition to examples
* **microservices**: A change or addition to the micro services documentation
* **security**: A change or addition to the security documentation
* **ref** A change or addition to the reference documentation
* **walkthru**: A change or addition to the walk through documentation
* *no scope*:  If no scope is provided, it is assumed the PR does not apply to the above scopes or applies to all scopes

### Subject
The subject contains a succinct description of the change:

* use the imperative, present tense: "change" not "changed" nor "changes"
* don't capitalize the first letter
* no dot (.) at the end

### Body
Just as in the **subject**, use the imperative, present tense: "change" not "changed" nor "changes".
The body should include the motivation for the change and contrast this with previous behavior.

### Footer
The footer should contain any information about **Breaking Changes** and is also the place to
reference GitHub issues that this commit **Closes**.

**Breaking Changes** should start with the word `BREAKING CHANGE:` with a space or two newlines. The rest of the commit message is then used for this.

