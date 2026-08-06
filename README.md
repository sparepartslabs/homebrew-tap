# Spare Parts Labs Homebrew tap

Homebrew formulae for Spare Parts Labs command-line tools.

## Install

```sh
brew install sparepartslabs/tap/spareparts-cli
```

or tap once and install by name:

```sh
brew tap sparepartslabs/tap
brew install spareparts-cli
```

## Formulae

| Formula | Description |
|---------|-------------|
| `spareparts-cli` | `sp`, the Spare Parts command line. `sp lgtm` asks two or three questions about the change you are about to push, generated from the diff, and can install itself as a git hook. Ships all three model vendors; it uses whichever key you have set. |

## Maintenance

Formulae are updated automatically. Each tool's release workflow (e.g.
`sparepartslabs/spareparts-cli` `.github/workflows/homebrew.yml`) points its
formula at the new PyPI sdist (`url` + `sha256`) on every `v*` tag, and
regenerates the vendored `resource` blocks from that release's dependency tree.
To add a tool, drop a `Formula/<name>.rb` here and wire the same bump step into
that tool's release.
