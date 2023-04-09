require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::JIS do
  context "when xref_error.adoc compilation" do
    it "generates error file" do
      FileUtils.rm_f "xref_error.err"
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
          .compile("xref_error.adoc", type: "iso", no_install_fonts: true)
      end.to(change { File.exist?("xref_error.err") }
              .from(false).to(true))
    end
  end

  it "Warns of illegal script" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :script: pizza
      :docnumber: 1000

      text
    INPUT
    expect(File.read("test.err")).to include "pizza is not a recognised script"

    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :script: Jpan
      :docnumber: 1000

      text
    INPUT
    expect(File.read("test.err")).not_to include "Jpan is not a recognised script"
  end
end
