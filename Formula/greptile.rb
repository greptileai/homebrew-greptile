class Greptile < Formula
  desc "Bridge for Greptile code review 'Fix in Claude Code' and 'Fix in Codex' links"
  homepage "https://greptile.com"
  url "https://github.com/greptileai/homebrew-greptile/releases/download/v0.1.0/greptile-cli-v0.1.0.tar.gz"
  sha256 "6b63d2a4c9795fdb5e4746f1950e661b353054ad70e22de68d178db7f2d8275e"
  license "MIT"

  depends_on :macos

  def install
    # Install the CLI script
    bin.install "greptile-fix"

    # Build the .app bundle
    system "bash", "build-app.sh", prefix
  end

  def caveats
    <<~EOS
      Repo path mappings are stored in ~/.greptile/repos.json.
      The first time you click "Fix in Claude Code" for a repo,
      you'll be asked to select the local folder for that repo.
    EOS
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/greptile-fix 2>&1", 1)
  end
end
