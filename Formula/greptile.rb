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

  def post_install
    # Set up and start the health server LaunchAgent automatically
    plist_dir = Pathname.new("#{Dir.home}/Library/LaunchAgents")
    plist_dir.mkpath

    node_bin = Formula["node"].opt_bin/"node"
    plist_dest = plist_dir/"com.greptile.health.plist"

    # Generate plist with correct paths
    plist_content = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>com.greptile.health</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{node_bin}</string>
          <string>health-server.js</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{opt_libexec}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>StandardOutPath</key>
        <string>/tmp/greptile-health.log</string>
        <key>StandardErrorPath</key>
        <string>/tmp/greptile-health.log</string>
      </dict>
      </plist>
    XML

    # Unload if already running, write new plist, load it
    system "launchctl", "unload", plist_dest.to_s if plist_dest.exist?
    # Write via shell to avoid Homebrew sandbox restrictions on ~/Library
    tmpfile = "#{Dir.tmpdir}/com.greptile.health.plist"
    File.write(tmpfile, plist_content)
    system "cp", tmpfile, plist_dest.to_s
    File.delete(tmpfile) if File.exist?(tmpfile)
    system "launchctl", "load", plist_dest.to_s
  end

  def caveats
    <<~EOS
      The health server has been started automatically on port 4747.

      Repo path mappings are stored in ~/.greptile/repos.json.
      The first time you click "Fix in Claude Code" for a repo,
      you'll be asked to select the local folder for that repo.
    EOS
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/greptile-fix 2>&1", 1)
  end
end
