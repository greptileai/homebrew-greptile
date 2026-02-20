class Greptile < Formula
  desc "Bridge for Greptile code review 'Fix in Claude Code' and 'Fix in Codex' links"
  homepage "https://greptile.com"
  url "https://github.com/greptileai/homebrew-greptile/releases/download/v2.2.5/greptile-cli-v2.2.5.tar.gz"
  sha256 "810336617477b26bfac39a62c39cff1d591e32a8cd2bf5e23f0b2d9eb87ab79a"
  license "MIT"

  depends_on :macos
  depends_on "node"

  def install
    # Install the CLI script
    bin.install "greptile-fix"

    # Install health server + package.json marker (used by self-check)
    libexec.install "health-server.js", "package.json"

    # Install plist template for LaunchAgent setup
    libexec.install "com.greptile.health.plist"

    # Build the .app bundle for greptile:// URL scheme
    system "bash", "build-app.sh", prefix
  end

  service do
    run [Formula["node"].opt_bin/"node", opt_libexec/"health-server.js"]
    working_dir opt_libexec
    keep_alive true
    log_path var/"log/greptile-health.log"
    error_log_path var/"log/greptile-health.log"
  end

  def post_install
    # Automatically start the health server service
    system "brew", "services", "start", name
  end

  def caveats
    <<~EOS
      The health server runs on port 4747 via `brew services`.

      To manage it:
        brew services start greptile   # start
        brew services stop greptile    # stop
        brew services restart greptile # restart

      Repo path mappings are stored in ~/.greptile/repos.json.
      The first time you click "Fix in Claude Code" for a repo,
      you'll be asked to select the local folder for that repo.
    EOS
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/greptile-fix 2>&1", 1)
  end
end
