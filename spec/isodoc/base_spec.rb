require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc::JIS do
  it "processes isodoc as JIS: HTML output" do
    IsoDoc::JIS::HtmlConvert.new({}).convert("test", <<~"INPUT", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
        <language>ja</language>
        </bibdata>
        <preface>
          <foreword>
            <note>
              <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
            </note>
          </foreword>
        </preface>
      </iso-standard>
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html)
      .to match(%r[\bpre[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html)
      .to match(%r[blockquote[^{]+\{[^{]+font-family: "MS Mincho", serif;]m)
    expect(html)
      .to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "MS Gothic", sans-serif;]m)
  end
end
