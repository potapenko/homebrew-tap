class SwiftuiSemanticAudit < Formula
  desc "Inspect SwiftUI state ownership and data flow"
  homepage "https://github.com/potapenko/swiftui-semantic-audit"
  url "https://github.com/potapenko/swiftui-semantic-audit/releases/download/0.4.0/swiftui-semantic-audit-0.4.0.tar.gz"
  sha256 "e314379b9cf67f1d5d6ccf3e8b9dce9b10d4a619c6af9eff4d39af0f4a8f08d3"
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
