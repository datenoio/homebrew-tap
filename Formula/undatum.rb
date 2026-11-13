# Homebrew formula for the datenoio tap (https://github.com/datenoio/homebrew-tap),
# rendered on release from packaging/homebrew/undatum.rb.in in datenoio/undatum by
# scripts/render_homebrew_formula.py, which fills in the sdist URL and checksum; Homebrew
# reads the version from the URL.
#
# undatum depends on DuckDB and Apache Arrow, which are impractical to build from
# source, so the formula installs the released source distribution and the wheels of its
# dependencies into a private virtualenv instead of listing every dependency as a
# resource (fine for a tap, not for homebrew-core).
class Undatum < Formula
  include Language::Python::Virtualenv

  desc "Convert, inspect, validate and transform data files"
  homepage "https://github.com/datenoio/undatum"
  url "https://files.pythonhosted.org/packages/6a/6e/53cec6eaa8948ea411971ac9ad852c20cb889b72ed0f16b9e8a4a9f8091e/undatum-2.0.1.tar.gz"
  sha256 "b693dbfe95802dac5de29ecfbc78dbb208a7f984cca5a48d0c976899643e3ca8"
  license "MIT"

  depends_on "python@3.13"

  # The dependencies are prebuilt wheels: an absolute install name does not fit in the
  # Mach-O header of some of them (orjson), so their @rpath names stay as they are.
  preserve_rpath

  def install
    python3 = formula_opt_bin("python@3.13")/"python3.13"
    # Without system site-packages: packages installed into Homebrew's Python must not leak in.
    virtualenv_create(libexec, python3, system_site_packages: false)
    system python3, "-m", "pip", "--python=#{libexec}/bin/python", "install", "--no-cache-dir", buildpath
    bin.install_symlink libexec/"bin/undatum"
    generate_completions_from_executable(bin/"undatum", shell_parameter_format: :typer,
                                                        shells:                 [:bash, :zsh, :fish])
  end

  test do
    assert_match "undatum #{version}", shell_output("#{bin}/undatum --version")
    (testpath/"data.csv").write "id,city\n1,Berlin\n2,Paris\n"
    assert_equal "2", shell_output("#{bin}/undatum count #{testpath}/data.csv").strip
  end
end
