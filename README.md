# Homebrew tap for Veritas AI

[Veritas AI](https://github.com/frimpsjoek/veritas-ai) is an open-source research assistant you can check: it reads
your papers, notes and Zotero library, answers with citations you can open, and brings you a daily reading radar.

```sh
brew install frimpsjoek/veritas/veritas
brew services start veritas     # start now and at login
veritas open                    # http://localhost:27182/app/
```

Your data and the search model live in `$(brew --prefix)/var/veritas`. Remove with `brew services stop veritas`
and `brew uninstall veritas`.
