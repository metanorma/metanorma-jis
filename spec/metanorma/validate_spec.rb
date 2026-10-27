require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Jis do
  it "validates document against Metanorma XML schema" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = A
      X
      :docfile: test.adoc
      :no-pdf:

      [align=mid-air]
      Para
    INPUT
    # leptris (unlike Jing) drops the attribute diagnostic when the element
    # is also position-invalid: leptris#1704
    expect(File.read("test.err.html"))
      .to include('element "p" not allowed anywhere')
  end
end
