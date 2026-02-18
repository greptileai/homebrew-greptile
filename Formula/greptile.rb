class Greptile < Formula
  desc "Bridge for Greptile code review 'Fix in Claude Code' and 'Fix in Codex' links"
  homepage "https://greptile.com"
  url "https://github.com/greptileai/homebrew-greptile/releases/download/v0.2.0/greptile-cli-v0.2.0.tar.gz"
  sha256 "c70e5c54186c187f3406695b7954293c8ea041b39323e423d79a7a6b2bfa73b8"
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
