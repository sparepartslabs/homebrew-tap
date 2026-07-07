# Spare Parts Labs Homebrew tap

Homebrew formulae for Spare Parts Labs command-line tools.

## Install

```sh
brew install sparepartslabs/tap/blitz-cli
```

or tap once and install by name:

```sh
brew tap sparepartslabs/tap
brew install blitz-cli
```

## Formulae

| Formula | Description |
|---------|-------------|
| `blitz-cli` | Developer CLI for Blitz: onboard a repo, scan LLM calls, scaffold a QLoRA trainer. |

## Maintenance

Formulae are updated automatically. Each tool's release workflow (e.g.
`sparepartslabs/blitz-cli` `.github/workflows/homebrew.yml`) points its formula
at the new PyPI sdist (`url` + `sha256`) on every `v*` tag. To add a tool, drop a
`Formula/<name>.rb` here and wire the same bump step into that tool's release.
