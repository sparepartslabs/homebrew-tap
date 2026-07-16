class BlitzCli < Formula
  include Language::Python::Virtualenv

  desc "Developer CLI for the Blitz locker-room: playbooks, codebase ontology node, session replay"
  homepage "https://github.com/sparepartslabs/blitz-cli"
  # url + sha256 are updated automatically on each release by the blitz-cli repo's
  # .github/workflows/homebrew.yml. The placeholder sha256 below is replaced with
  # the real PyPI sdist digest on the first release; until then this formula will
  # not install.
  url "https://files.pythonhosted.org/packages/2f/61/91a7291378e6541f1dbc0489d2d9f48ce350b392b3087c419104c4a863db/blitz_cli-0.16.1.tar.gz"
  sha256 "a2dc8c8b5e4a30672d078119c1a31d13d45ee4c06719fc37351e215a1bb37a9b"
  license "MIT"

  # blitz-cli depends on rich (with its own deps), vendored as resource
  # blocks below; it installs into its own virtualenv on Homebrew's Python.
  depends_on "python@3.12"

  resource "markdown-it-py" do
    url "https://files.pythonhosted.org/packages/06/ff/7841249c247aa650a76b9ee4bbaeae59370dc8bfd2f6c01f3630c35eb134/markdown_it_py-4.2.0.tar.gz"
    sha256 "04a21681d6fbb623de53f6f364d352309d4094dd4194040a10fd51833e418d49"
  end

  resource "mdurl" do
    url "https://files.pythonhosted.org/packages/d6/54/cfe61301667036ec958cb99bd3efefba235e65cdeb9c84d24a8293ba1d90/mdurl-0.1.2.tar.gz"
    sha256 "bb413d29f5eea38f31dd4754dd7377d4465116fb207585f97bf925588687c1ba"
  end

  resource "Pygments" do
    url "https://files.pythonhosted.org/packages/c3/b2/bc9c9196916376152d655522fdcebac55e66de6603a76a02bca1b6414f6c/pygments-2.20.0.tar.gz"
    sha256 "6757cd03768053ff99f3039c1a36d6c0aa0b263438fcab17520b30a303a82b5f"
  end

  resource "rich" do
    url "https://files.pythonhosted.org/packages/c0/8f/0722ca900cc807c13a6a0c696dacf35430f72e0ec571c4275d2371fca3e9/rich-15.0.0.tar.gz"
    sha256 "edd07a4824c6b40189fb7ac9bc4c52536e9780fbbfbddf6f1e2502c31b068c36"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "usage: blitz", shell_output("#{bin}/blitz --help")
  end
end
