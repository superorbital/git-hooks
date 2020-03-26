# git-hooks

> *An opinionated use of the `core.hooksPath` feature released in Git 2.9.*

## ABOUT

This repository is meant to be used as the directory that the Git
`core.hooksPath` config value is pointed at.

It exists because using the `core.hooksPath` feature is used in place of any
local, repository-specific hooks in `.git/hooks`. This isn't necessarily
what you want, as you may have repository-specific hooks that you want to
run in addition to some hooks that should be global.

If you use this repository as your `core.hooksPath`, you will be able to:

* Retain any repository-specific hooks in `.git/hooks`
* Add hooks that will apply to all repositories in their respective `HOOK.d` folder
* Use multiple files for hooks rather than a single file, as Git expects

And now that the hooks dir is outside of your repository, you can commit the
global hooks. Hooray!

## INSTALLATION

### Installing git-hooks

Clone this repo to your directory of choice, e.g. $HOME/workspace/git-hooks.
Point `core.hooksPath` at the installation directory.

```
REPO=somewhere/git-hooks
git clone https://github.com/superorbital/git-hooks "$REPO"
git config --global --add core.hooksPath "$REPO"
```

### (Optional) Adding global hooks

Add any global hooks you'd like to their respective `HOOK.d` folder:

```
chmod +x my-commit-msg-hook
cp my-commit-msg-hook "$REPO/commit-msg.d"
```

## VERIFY IT ALL WORKS

We use bats for testing.  Install that, and then:

```
./tests/test.bats
```

## LINKS

* [githooks](https://git-scm.com/docs/githooks)
