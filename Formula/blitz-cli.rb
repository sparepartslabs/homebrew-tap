class BlitzCli < Formula
  include Language::Python::Virtualenv

  desc "Developer CLI for Blitz: onboard a repo, scan LLM calls, scaffold a QLoRA trainer"
  homepage "https://github.com/sparepartslabs/blitz-cli"
  # url + sha256 are updated automatically on each release by the blitz-cli repo's
  # .github/workflows/homebrew.yml. The placeholder sha256 below is replaced with
  # the real PyPI sdist digest on the first release; until then this formula will
  # not install.
  url "https://files.pythonhosted.org/packages/83/23/ba9aa4c06b20b537c06cada7b5e7a873950657efd37fbe1212bbbda10d48/blitz_cli-0.4.0.tar.gz"
  sha256 "17ac9f837554509757025bab11415783de4b562bd98d4b0412073b6813ed1ba5"
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
