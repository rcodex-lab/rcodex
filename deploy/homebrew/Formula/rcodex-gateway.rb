class RcodexGateway < Formula
  desc "rCodex Gateway for local macOS development machines"
  homepage "https://github.com/rcodexlab/homebrew-rcodex"
  version "1.2.58"

  # 发布时将 URL 和 SHA256 替换为 GitHub Release 中的真实原生包。
  url "https://github.com/rcodexlab/rcodex-releases/releases/download/v1.2.58/rcodex-gateway-1.2.58-darwin-arm64.tar.gz"
  sha256 "REPLACE_WITH_RELEASE_SHA256"

  depends_on "node@22"

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/rcodex-gateway"

    (etc/"rcodex-gateway").mkpath
    unless (etc/"rcodex-gateway/gateway.env").exist?
      (etc/"rcodex-gateway/gateway.env").write((libexec/"etc/rcodex-gateway.env.example").read)
    end

    (var/"rcodex-gateway").mkpath
    (var/"log").mkpath
  end

  service do
    run [opt_bin/"rcodex-gateway", "start"]
    keep_alive true
    working_dir var/"rcodex-gateway"
    log_path var/"log/rcodex-gateway.log"
    error_log_path var/"log/rcodex-gateway.log"
  end

  test do
    assert_match "rCodex Gateway", shell_output("#{bin}/rcodex-gateway --version")
  end
end

