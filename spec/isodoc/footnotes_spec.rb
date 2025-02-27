require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc do
  it "processes IsoXML footnotes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword displayorder="1"><fmt-title>Foreword</fmt-title>
          <p>A.<fn reference="2">
        <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
      </fn></p>
          <p>B.<fn reference="2">
        <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
      </fn></p>
          <p>C.<fn reference="1">
        <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
      </fn></p>
          </foreword>
          </preface>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <foreword displayorder="1" id="_">
                <title id="_">Foreword</title>
                <fmt-title depth="1">Foreword</fmt-title>
                <p>
                   A.
                   <fn reference="1" original-reference="2" id="_" target="_">
                      <p original-id="_">Formerly denoted as 15 % (m/m).</p>
                      <fmt-fn-label>
                         <sup>
                            <semx element="autonum" source="_">1</semx>
                         </sup>
                      </fmt-fn-label>
                   </fn>
                </p>
                <p>
                   B.
                   <fn reference="1" original-reference="2" id="_" target="_">
                      <p id="_">Formerly denoted as 15 % (m/m).</p>
                      <fmt-fn-label>
                         <sup>
                            <semx element="autonum" source="_">1</semx>
                         </sup>
                      </fmt-fn-label>
                   </fn>
                </p>
                <p>
                   C.
                   <fn reference="2" original-reference="1" id="_" target="_">
                      <p original-id="_">Hello! denoted as 15 % (m/m).</p>
                      <fmt-fn-label>
                         <sup>
                            <semx element="autonum" source="_">2</semx>
                         </sup>
                      </fmt-fn-label>
                   </fn>
                </p>
             </foreword>
             <clause type="toc" id="_" displayorder="2">
                <fmt-title depth="1">Contents</fmt-title>
             </clause>
          </preface>
          <fmt-footnote-container>
             <fmt-fn-body id="_" target="_" reference="1">
                <semx element="fn" source="_">
                   <p id="_">
                      <fmt-fn-label>
                         <sup>
                            <semx element="autonum" source="_">1</semx>
                         </sup>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                      </fmt-fn-label>
                      Formerly denoted as 15 % (m/m).
                   </p>
                </semx>
             </fmt-fn-body>
             <fmt-fn-body id="_" target="_" reference="2">
                <semx element="fn" source="_">
                   <p id="_">
                      <fmt-fn-label>
                         <sup>
                            <semx element="autonum" source="_">2</semx>
                         </sup>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                      </fmt-fn-label>
                      Hello! denoted as 15 % (m/m).
                   </p>
                </semx>
             </fmt-fn-body>
          </fmt-footnote-container>
       </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
             <br/>
                <div id="_">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <p>
                      A.
                      <a class="FootnoteRef" href="#fn:1">
                         <sup>1</sup>
                      </a>
                   </p>
                   <p>
                      B.
                      <a class="FootnoteRef" href="#fn:1">
                         <sup>1</sup>
                      </a>
                   </p>
                   <p>
                      C.
                      <a class="FootnoteRef" href="#fn:2">
                         <sup>2</sup>
                      </a>
                   </p>
                </div>
                <br/>
                <div id="_" class="TOC">
                   <h1 class="IntroTitle">Contents</h1>
                </div>
                <aside id="fn:1" class="footnote">
                   <p id="_">Formerly denoted as 15 % (m/m).</p>
                </aside>
                <aside id="fn:2" class="footnote">
                   <p id="_">Hello! denoted as 15 % (m/m).</p>
                </aside>
             </div>
          </body>
       </html>
    OUTPUT
    word = <<~OUTPUT
       <body lang="EN-US" link="blue" vlink="#954F72">
          <div class="WordSection1">
             <p> </p>
          </div>
          <p class="section-break">
             <br clear="all" class="section"/>
          </p>
          <div class="WordSection2">
             <p class="page-break">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <div id="_">
                <h1 class="ForewordTitle">Foreword</h1>
                <p class="ForewordText">
                   A.
                   <span style="mso-bookmark:_Ref">
                      <a class="FootnoteRef" href="#ftn1" epub:type="footnote">
                         <sup>1</sup>
                      </a>
                   </span>
                </p>
                <p class="ForewordText">
                   B.
                   <span style="mso-element:field-begin"/>
                   NOTEREF _Ref \\f \\h
                   <span style="mso-element:field-separator"/>
                   <span class="MsoFootnoteReference">1</span>
                   <span style="mso-element:field-end"/>
                </p>
                <p class="ForewordText">
                   C.
                   <span style="mso-bookmark:_Ref">
                      <a class="FootnoteRef" href="#ftn2" epub:type="footnote">
                         <sup>2</sup>
                      </a>
                   </span>
                </p>
             </div>
             <p class="page-break">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <div id="_" type="toc" class="TOC">
                <p class="zzContents">Contents</p>
             </div>
             <p> </p>
          </div>
          <p class="section-break">
             <br clear="all" class="section"/>
          </p>
          <div class="WordSection3">
             <aside id="ftn1">
                <p id="_">Formerly denoted as 15 % (m/m).</p>
             </aside>
             <aside id="ftn2">
                <p id="_">Hello! denoted as 15 % (m/m).</p>
             </aside>
          </div>
          <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
          <div class="colophon"/>
       </body>
    OUTPUT
        pres_output = IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
       .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Jis::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Jis::WordConvert.new({})
      .convert("test", pres_output, true))
      .at("//body").to_xml)
      .gsub(/_Ref\d+/, "_Ref")))
      .to be_equivalent_to Xml::C14n.format(word)
  end
end
