require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc do
  it "processes IsoXML footnotes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword displayorder="1"><title>Foreword</title>
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
    html = <<~OUTPUT
      #{HTML_HDR}
             <br/>
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <p>
                 A.
                 <a class="FootnoteRef" href="#fn:2">
                   <sup>2</sup>
                 </a>
               </p>
               <p>
                 B.
                 <a class="FootnoteRef" href="#fn:2">
                   <sup>2</sup>
                 </a>
               </p>
               <p>
                 C.
                 <a class="FootnoteRef" href="#fn:1">
                   <sup>1</sup>
                 </a>
               </p>
             </div>
             <aside id="fn:2" class="footnote">
               <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
             </aside>
             <aside id="fn:1" class="footnote">
               <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
             </aside>
           </div>
         </body>
       </html>
    OUTPUT
    word = <<~OUTPUT
      <html xmlns:epub='http://www.idpf.org/2007/ops' lang='en'>
        <head>
          <style> </style>
          <style> </style>
        </head>
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
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <p class="ForewordText">
                 A.
                 <span style="mso-bookmark:_Ref">
                   <a class="FootnoteRef" href="#ftn2" epub:type="footnote">
                     <sup>2</sup>
                   </a>
                 </span>
               </p>
               <p class="ForewordText">
                 B.
                 <span style="mso-element:field-begin"/>
                 NOTEREF _Ref \\f \\h
                 <span style="mso-element:field-separator"/>
                 <span class="MsoFootnoteReference">2</span>
                 <span style="mso-element:field-end"/>
               </p>
               <p class="ForewordText">
                 C.
                 <span style="mso-bookmark:_Ref">
                   <a class="FootnoteRef" href="#ftn1" epub:type="footnote">
                     <sup>1</sup>
                   </a>
                 </span>
               </p>
             </div>
             <p> </p>
           </div>
           <p class="section-break">
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection3">
             <aside id="ftn2">
               <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
             </aside>
             <aside id="ftn1">
               <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
             </aside>
           </div>
           <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
           <div class="colophon"/>
         </body>
       </html>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::Jis::HtmlConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(IsoDoc::Jis::WordConvert.new({})
      .convert("test", input, true)
      .gsub(/_Ref\d+/, "_Ref")))
      .to be_equivalent_to Xml::C14n.format(word)
  end
end
