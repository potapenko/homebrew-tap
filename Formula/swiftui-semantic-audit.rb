class SwiftuiSemanticAudit < Formula
  desc "Inspect SwiftUI state ownership and data flow"
  homepage "https://github.com/potapenko/swiftui-semantic-audit"
  url "file:///private/tmp/swiftui-semantic-audit-0.4.0.tar.gz"
  sha256 "c15ce1ba9bb33495c3a8664b2835e7b1be29cfcba01780061cd778c724bcaa53"
  license "MIT"

  depends_on xcode: ["26.6", :build]

  on_macos do
    depends_on macos: :ventura
  end

  def install
    system "swift", "build", "--product", "swiftui-audit",
           "--disable-automatic-resolution", *std_swift_args
    bin.install ".build/release/swiftui-audit"
  end

  test do
    (testpath/"Sample.swift").write <<~SWIFT
      import SwiftUI

      struct Sample: View {
        @State private var enabled = false

        var body: some View {
          Toggle("Enabled", isOn: $enabled)
        }
      }
    SWIFT

    report = JSON.parse(shell_output("#{bin}/swiftui-audit audit #{testpath} --syntax-only --format json"))
    assert_equal version.to_s, report.fetch("toolVersion")
    assert_equal 2, report.fetch("schemaVersion")
    assert_equal "syntax-only", report.fetch("resolution")
  end
end
