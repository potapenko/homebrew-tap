class SwiftuiSemanticAudit < Formula
  desc "Inspect SwiftUI state ownership and data flow"
  homepage "https://github.com/potapenko/swiftui-semantic-audit"
  url "https://github.com/potapenko/swiftui-semantic-audit/releases/download/0.5.0/swiftui-semantic-audit-0.5.0.tar.gz"
  sha256 "c8d2ea55ea7719de61d55fca13a0d7b2b4053c056c85e15d65d3a1a7eeadcb6b"
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
