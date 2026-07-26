# Dependency Conventions

This file defines expectations for adding, updating, and removing third-party dependencies. Every dependency is code you now maintain but didn't write.

---

## A Dependency Must Earn Its Place

Adding a package is an architectural decision, not a convenience. Before installing, answer:

- **Could we write it ourselves in under ~100 lines?** If yes, write it. A left-pad-sized dependency is pure risk with no payoff.
- **Is it maintained?** Recent releases, responsive issues, more than one contributor.
- **Is it widely used?** Download counts and dependents are a proxy for battle-testing.
- **What does it drag in?** Check the transitive dependency tree. A "small" package with 40 dependencies is not small.
- **Is the license compatible?** MIT/Apache/BSD are fine; copyleft needs a deliberate decision.

Prefer, in order: the platform (browser/Node built-ins) → the framework you already have → a well-established library → writing it yourself → a niche package.

## Verify Before You Install

- **Confirm the package is the real one.** Typosquats and AI-hallucinated package names are an active supply-chain attack vector. Check the npm page, repo link, and download count before `npm install` — especially for a package name suggested by an AI tool.
- Never install a package solely because generated code imported it.

## Lockfile Discipline

- Lockfiles (`package-lock.json`, etc.) are always committed.
- CI and fresh setups install from the lockfile (`npm ci`), never a bare `npm install`.
- Version ranges: caret ranges are fine *because* the lockfile pins the actual version. Pin exact versions only for packages where a silent minor bump has burned you.

## Updating

- Updates are deliberate, not ambient. Don't bump versions as a side effect of another task.
- Major version bumps get their own commit, with the changelog read and the test suite run.
- Batch routine minor/patch updates periodically; verify with the full test suite before committing.
- A security advisory on a dependency you actually use is a now-task, not a someday-task. (`npm audit` noise on dev-only transitive deps can be triaged with judgment.)

## Removing

- When a dependency stops being used, remove it in the same change. Unused dependencies are attack surface plus install time for zero value.
- Periodically check for dependencies that a platform feature has since made redundant (e.g. `node-fetch` after native `fetch`).
