class BlitzCli < Formula
  include Language::Python::Virtualenv

  desc "Developer CLI for Blitz: onboard a repo, scan LLM calls, scaffold a QLoRA trainer"
  homepage "https://github.com/sparepartslabs/blitz-cli"
  # url + sha256 are updated automatically on each release by the blitz-cli repo's
  # .github/workflows/homebrew.yml. The placeholder sha256 below is replaced with
  # the real PyPI sdist digest on the first release; until then this formula will
  # not install.
  url "https://files.pythonhosted.org/packages/c2/9b/3c4abc91034387f74e518387698f6589dd1f2978ebcfa6e6639805284720/blitz_cli-0.8.0.tar.gz"
  sha256 "f6e6871f751ba5703b6f17fe646ab0bf6f6377bde79f995d2db8b0fd214e5aa2"
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
