class Greptile < Formula
  desc "Bridge for Greptile code review 'Fix in Claude Code' and 'Fix in Codex' links"
  homepage "https://greptile.com"
  url "https://github.com/greptileai/homebrew-greptile/releases/download/v0.3.0/greptile-cli-v0.3.0.tar.gz"
  sha256 "49405f87f833ffdbf497399333397ba5a622f85af61dd762ab328f38e559875c"
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
