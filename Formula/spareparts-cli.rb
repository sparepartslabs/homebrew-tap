class SparepartsCli < Formula
  include Language::Python::Virtualenv

  desc "sp, the Spare Parts command line: ask what a diff does before you push it"
  homepage "https://github.com/sparepartslabs/spareparts-cli"
  # url + sha256 are updated automatically on each release by the spareparts-cli
  # repo's .github/workflows/homebrew.yml. Until the first release lands on PyPI
  # this formula cannot install; the placeholders below are what it replaces.
  url "https://files.pythonhosted.org/packages/16/7f/9bdc2ffc5373aa47c041b00caf20f23513a1237332bf348f93c3bf1d1641/spareparts_cli-0.5.2.tar.gz"
  sha256 "d29e997fc94ab766c71b4ca96c6cf3d55f48614e7415f5f383a1cb9880414d1a"

  # Homebrew builds Python resources from source. Keep the formula on the
  # CLI's stable base dependency set; optional LLM SDKs pull Rust-backed
  # packages such as cryptography and pydantic-core that are not reliable
  # source builds inside brew's isolated virtualenv. Provider-enabled installs
  # remain available through pipx extras.
  depends_on "python@3.12"

  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/05/8e/961c0007c59b8dd7729d542c61a4d537767a59645b82a0b521206e1e25c2/pyyaml-6.0.3.tar.gz"
    sha256 "d76623373421df22fb4cf8817020cbb7ef15c725b9d5e45f17e189bfc384190f"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "sp <module>", shell_output("#{bin}/sp --help")
  end
end
