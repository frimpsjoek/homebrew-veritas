# Homebrew formula for Veritas AI (veritas-ai spec 024 G1).
# Source: https://github.com/frimpsjoek/veritas-ai/blob/main/packaging/homebrew/veritas.rb
class Veritas < Formula
  desc "Open-source research assistant you can check: your papers, notes and new literature, with citations"
  homepage "https://github.com/frimpsjoek/veritas-ai"
  url "https://github.com/frimpsjoek/veritas-ai/archive/refs/tags/v0.54.0.tar.gz"
  sha256 "b4d5518eadf14df52c3a06cf3f6f98ec1e9a73f6f8c37b1e109dcfeffac30ebe"
  license "MIT"

  depends_on "node@22" => :build
  depends_on "uv" => :build
  depends_on "node@22"
  depends_on "python@3.12"

  def install
    libexec.install Dir["*"]
    cd libexec/"server" do
      system "uv", "venv", "--python", Formula["python@3.12"].opt_bin/"python3.12", ".venv"
      system "uv", "pip", "install", "--python", ".venv/bin/python", "-r", "requirements.txt"
    end
    ENV.prepend_path "PATH", Formula["node@22"].opt_bin
    cd(libexec/"agent") { system "npm", "ci"; system "npm", "run", "build" }
    cd(libexec/"web") { system "npm", "ci"; system "npm", "run", "build" }
    (bin/"veritas").write_env_script libexec/"bin/veritas",
      VERITAS_DATA:      var/"veritas",
      VERITAS_PYTHON:    libexec/"server/.venv/bin/python",
      SECOND_BRAIN_NODE: Formula["node@22"].opt_bin/"node",
      PATH:              "#{Formula["node@22"].opt_bin}:$PATH"
  end

  def post_install
    (var/"veritas").mkpath
    # the web app goes into the data folder, so an upgrade does not wipe it either
    system "env", "VERITAS_DATA=#{var}/veritas", "PATH=#{Formula["node@22"].opt_bin}:#{ENV["PATH"]}",
           "sh", libexec/"web/install.sh"
  end

  service do
    run [opt_bin/"veritas", "serve"]
    keep_alive true
    log_path var/"log/veritas.log"
    error_log_path var/"log/veritas.log"
  end

  def caveats
    <<~EOS
      Start Veritas now and at login:  brew services start veritas
      Open it:                         veritas open   (http://localhost:27182/app/)
      Your data and the search model live in #{var}/veritas.
    EOS
  end

  test do
    assert_match "veritas serve", shell_output("#{bin}/veritas 2>&1", 2)
  end
end
