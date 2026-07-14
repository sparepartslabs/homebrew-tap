class BlitzCli < Formula
  include Language::Python::Virtualenv

  desc "Developer CLI for Blitz: onboard a repo, scan LLM calls, scaffold a QLoRA trainer"
  homepage "https://github.com/sparepartslabs/blitz-cli"
  # url + sha256 are updated automatically on each release by the blitz-cli repo's
  # .github/workflows/homebrew.yml. The placeholder sha256 below is replaced with
  # the real PyPI sdist digest on the first release; until then this formula will
  # not install.
  url "https://files.pythonhosted.org/packages/78/ce/053855f0123f9c69ca4b4adc3dc2eee70ba1a88f2425cc30b3ec5ec36da6/blitz_cli-0.7.0.tar.gz"
  sha256 "a7c756228e7fd48873e9255f0fdfd5e4e8a13c7dedf23945a244af26f6fa1920"
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
