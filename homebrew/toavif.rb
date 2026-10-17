# Homebrew formula template for toavif.
# Copy this file to Formula/toavif.rb in the mnich/homebrew-tools tap
# and update `url` and `sha256` for every new release.
class Toavif < Formula
  desc "Multi-threaded CLI for batch conversion of JPG/PNG images to AVIF"
  homepage "https://github.com/mnich/toavif"
  url "https://github.com/mnich/toavif/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "REPLACE_WITH_SHA256_OF_RELEASE_TARBALL"
  license "MIT"

  # Official libavif package, provides avifenc
  depends_on "libavif"

  def install
    bin.install "toavif"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/toavif --version")
    system bin/"toavif", "--help"
  end
end
