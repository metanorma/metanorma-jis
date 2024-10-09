require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Jis do
  context "when xref_error.adoc compilation" do
    it "generates error file" do
      FileUtils.rm_f "xref_error.err.html"
      File.write("xref_error.adoc", <<~CONTENT)
        = X
        A

        == Clause

        <<a,b>>
      CONTENT

      expect do
        mock_pdf
        Metanorma::Compile
          .new
          .compile("xref_error.adoc", type: "jis", install_fonts: false)
      end.to(change { File.exist?("xref_error.err.html") }
              .from(false).to(true))
    end
  end
end
