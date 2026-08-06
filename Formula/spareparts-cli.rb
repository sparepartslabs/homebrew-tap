class SparepartsCli < Formula
  include Language::Python::Virtualenv

  desc "sp, the Spare Parts command line: ask what a diff does before you push it"
  homepage "https://github.com/sparepartslabs/spareparts-cli"
  # url + sha256 are updated automatically on each release by the spareparts-cli
  # repo's .github/workflows/homebrew.yml. Until the first release lands on PyPI
  # this formula cannot install; the placeholders below are what it replaces.
  url "https://files.pythonhosted.org/packages/source/s/spareparts-cli/spareparts_cli-0.0.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  # All three vendor SDKs are vendored as resource blocks below, refreshed by
  # that same workflow. A pip install brings none of them, because none of the
  # three is the assumed vendor, and brew has no extras syntax to offer here, so
  # the formula carries all three and `sp` uses whichever key you have set.
  depends_on "python@3.12"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "sp <module>", shell_output("#{bin}/sp --help")
  end
end
