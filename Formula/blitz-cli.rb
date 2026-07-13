class BlitzCli < Formula
  include Language::Python::Virtualenv

  desc "Developer CLI for Blitz: onboard a repo, scan LLM calls, scaffold a QLoRA trainer"
  homepage "https://github.com/sparepartslabs/blitz-cli"
  # url + sha256 are updated automatically on each release by the blitz-cli repo's
  # .github/workflows/homebrew.yml. The placeholder sha256 below is replaced with
  # the real PyPI sdist digest on the first release; until then this formula will
  # not install.
  url "https://files.pythonhosted.org/packages/42/81/1c38e28b968380205bd5b3d013abcad1ceb8e48fa05118743727c8fc4497/blitz_cli-0.6.0.tar.gz"
  sha256 "23e2ca2eabc8b26d9f891b37567a0001fdcb9bd0d647ebaa60d047a464735e2f"
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
