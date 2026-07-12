class BlitzCli < Formula
  include Language::Python::Virtualenv

  desc "Developer CLI for Blitz: onboard a repo, scan LLM calls, scaffold a QLoRA trainer"
  homepage "https://github.com/sparepartslabs/blitz-cli"
  # url + sha256 are updated automatically on each release by the blitz-cli repo's
  # .github/workflows/homebrew.yml. The placeholder sha256 below is replaced with
  # the real PyPI sdist digest on the first release; until then this formula will
  # not install.
  url "https://files.pythonhosted.org/packages/42/a9/6e25131d61a6327ec8052f7709407c541e9f9adb802729189c6375c8301a/blitz_cli-0.5.0.tar.gz"
  sha256 "c7b2c61ac6796055be7548d0d45e9b493cce9db11f4e242f88b1ba87a291340a"
  license "MIT"

  # blitz-cli is stdlib-only (no PyPI dependencies), so there are no resource
  # blocks to vendor — it installs into its own virtualenv on Homebrew's Python.
  depends_on "python@3.12"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "usage: blitz", shell_output("#{bin}/blitz --help")
  end
end
