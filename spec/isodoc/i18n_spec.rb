require "spec_helper"

RSpec.describe IsoDoc::Jis do
  it "processes Japanese" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
                  <title language="en" format="text/plain" type="main">Introduction — Main Title — Title — Title Part</title>
          <title language="en" format="text/plain" type="title-intro">Introduction</title>
          <title language="en" format="text/plain" type="title-main">Main Title — Title</title>
          <title language="en" format="text/plain" type="title-part">Title Part</title>
          <title language="ja" format="text/plain" type="main">Introduction Française — Titre Principal — Part du Titre</title>
          <title language="ja" format="text/plain" type="title-intro">Introduction Française</title>
          <title language="ja" format="text/plain" type="title-main">Titre Principal</title>
          <title language="ja" format="text/plain" type="title-part">Part du Titre</title>
          <edition>2</edition>
          <status>
            <stage abbreviation='IS' language=''>60</stage>
          </status>
          <language>ja</language>
          <ext>
            <doctype language=''>international-standard</doctype>
          </ext>
        </bibdata>
        <preface>
          <foreword obligation="informative">
            <title>Foreword</title>
            <p id="A">This is a preamble</p>
          </foreword>
          <introduction id="B" obligation="informative">
            <title>Introduction</title>
            <clause id="C" inline-header="false" obligation="informative">
              <title>Introduction Subsection</title>
            </clause>
            <p>This is patent boilerplate</p>
          </introduction>
        </preface>
        <sections>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
          <clause id="H" obligation="normative">
            <title>Terms, definitions, symbols and abbreviated terms</title>
            <terms id="I" obligation="normative">
              <title>Normal Terms</title>
              <term id="J">
                <preferred><expression><name>Term2</name></expression></preferred>
              </term>
            </terms>
            <definitions id="K">
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
          </clause>
          <definitions id="L">
            <dl>
              <dt>Symbol</dt>
              <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id="M" inline-header="false" obligation="normative">
            <title>Clause 4</title>
            <clause id="N" inline-header="false" obligation="normative">
              <title>Introduction</title>
            </clause>
            <clause id="O" inline-header="false" obligation="normative">
              <title>Clause 4.2</title>
            </clause>
          </clause>
        </sections>
        <annex id="P" inline-header="false" obligation="normative">
          <title>Annex</title>
          <clause id="Q" inline-header="false" obligation="normative">
            <title>Annex A.1</title>
            <clause id="Q1" inline-header="false" obligation="normative">
              <title>Annex A.1a</title>
            </clause>
          </clause>
          <appendix id="Q2" inline-header="false" obligation="normative">
            <title>An Appendix</title>
          </appendix>
        </annex>
        <bibliography>
          <references id="R" normative="true" obligation="informative">
            <title>Normative References</title>
          </references>
          <clause id="S" obligation="informative">
            <title>Bibliography</title>
            <references id="T" normative="false" obligation="informative">
              <title>Bibliography Subsection</title>
            </references>
          </clause>
        </bibliography>
      </iso-standard>
    INPUT

    presxml = <<~OUTPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <bibdata>
                  <title language="en" format="text/plain" type="main">Introduction — Main Title — Title — Title Part</title>
          <title language="en" format="text/plain" type="title-intro">Introduction</title>
          <title language="en" format="text/plain" type="title-main">Main Title — Title</title>
          <title language="en" format="text/plain" type="title-part">Title Part</title>
          <title language="ja" format="text/plain" type="main">Introduction Française — Titre Principal — Part du Titre</title>
          <title language="ja" format="text/plain" type="title-intro">Introduction Française</title>
          <title language="ja" format="text/plain" type="title-main">Titre Principal</title>
          <title language="ja" format="text/plain" type="title-part">Part du Titre</title>
          <edition language="">2</edition>
          <edition language="ja">第2版</edition>
          <status>
            <stage abbreviation="IS" language="">60</stage>
            <stage abbreviation="IS" language="ja">International Standard</stage>
          </status>
          <language current="true">ja</language>
          <ext>
            <doctype language="">international-standard</doctype>
            <doctype language="ja">日本産業規格</doctype>
          </ext>
        </bibdata>

        <preface>
          <foreword obligation="informative" displayorder="1">
            <title>Foreword</title>
            <p id="A">This is a preamble</p>
          </foreword>
              <clause type="toc" id="_" displayorder="2">
          <title depth="1">目　次</title>
        </clause>
        </preface>
        <sections>
                   <p class="JapaneseIndustrialStandard" displayorder="3">
             日本工業規格
             <tab/>
             <tab/>
             <tab/>
             <tab/>
             <tab/>
             <tab/>
             <tab/>
             <span class="JIS">JIS</span>
           </p>
           <p class="StandardNumber" displayorder="4">
             <tab/>
           </p>
           <p class="IDT" displayorder="5"/>
                     <p class="zzSTDTitle1" displayorder="6">Introduction Française — Titre Principal — </p>
           <p class="zzSTDTitle1" displayorder="7">
             その :
             <br/>
             <strong>Part du Titre</strong>
           </p>
           <p class="zzSTDTitle2" displayorder="8">Introduction — Main Title — Title — </p>
           <p class="zzSTDTitle2" displayorder="9">
             Part :
             <br/>
             <strong>Title Part</strong>
           </p>
          <introduction id="B" obligation="informative" unnumbered="true" displayorder="10">
            <title>Introduction</title>
            <clause id="C" inline-header="false" obligation="informative">
              <title depth="2">
                Introduction Subsection
              </title>
            </clause>
            <p>This is patent boilerplate</p>
          </introduction>
          <clause id="D" obligation="normative" type="scope" displayorder="11">
            <title depth="1">
              1
              <tab/>
              Scope
            </title>
            <p id="E">Text</p>
          </clause>
          <clause id="H" obligation="normative" displayorder="13">
            <title depth="1">
              3
              <tab/>
              Terms, definitions, symbols and abbreviated terms
            </title>
            <terms id="I" obligation="normative">
              <title depth="2">
                3.1
                <tab/>
                Normal Terms
              </title>
              <term id="J">
                <name>3.1.1</name>
                <preferred>
                  <strong>Term2</strong>
                </preferred>
              </term>
            </terms>
            <definitions id="K" inline-header="true">
              <title>3.2</title>
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
          </clause>
          <definitions id="L" displayorder="14">
            <title>4</title>
            <dl>
              <dt>Symbol</dt>
              <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id="M" inline-header="false" obligation="normative" displayorder="15">
            <title depth="1">
              5
              <tab/>
              Clause 4
            </title>
            <clause id="N" inline-header="false" obligation="normative">
              <title depth="2">
                5.1
                <tab/>
                Introduction
              </title>
            </clause>
            <clause id="O" inline-header="false" obligation="normative">
              <title depth="2">
                5.2
                <tab/>
                Clause 4.2
              </title>
            </clause>
          </clause>
                    <references id="R" normative="true" obligation="informative" displayorder="12">
            <title depth="1">
              2
              <tab/>
              Normative References
            </title>
          </references>
        </sections>
        <annex id="P" inline-header="false" obligation="normative" displayorder="16">
          <title>
            附属書A
            <br/>
            （規定）
            <br/>
            <strong>Annex</strong>
          </title>
          <clause id="Q" inline-header="false" obligation="normative">
            <title depth="2">
              A.1
              <tab/>
              Annex A.1
            </title>
            <clause id="Q1" inline-header="false" obligation="normative">
              <title depth="3">
                A.1.1
                <tab/>
                Annex A.1a
              </title>
            </clause>
          </clause>
          <appendix id="Q2" inline-header="false" obligation="normative">
            <title depth="2">
              Appendix 1
              <tab/>
              An Appendix
            </title>
          </appendix>
        </annex>
        <bibliography>
          <clause id="S" obligation="informative" displayorder="17">
            <title depth="1">Bibliography</title>
            <references id="T" normative="false" obligation="informative">
              <title depth="2">Bibliography Subsection</title>
            </references>
          </clause>
        </bibliography>
      </iso-standard>
    OUTPUT

    html = <<~OUTPUT
         <html lang="ja">
        <head/>
        <body lang="ja">
          <div class="title-section">
            <p> </p>
          </div>
          <br/>
          <div class="prefatory-section">
            <p> </p>
          </div>
          <br/>
          <div class="main-section">
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p id="A">This is a preamble</p>
            </div>
            <br/>
      <div id="_" class="TOC">
        <h1 class="IntroTitle">目　次</h1>
      </div>
                  <p class="JapaneseIndustrialStandard">
        日本工業規格              
        <span class="JIS">JIS</span>
      </p>
      <p class="StandardNumber">  </p>
      <p class="IDT"/>
            <p class="zzSTDTitle1">Introduction Française — Titre Principal — </p>
             <p class="zzSTDTitle1">
               その :
               <br/>
               <b>Part du Titre</b>
             </p>
             <p class="zzSTDTitle2">Introduction — Main Title — Title — </p>
             <p class="zzSTDTitle2">
               Part :
               <br/>
               <b>Title Part</b>
             </p>
             <div class="Section3" id="B">
              <h1 class="IntroTitle">Introduction</h1>
              <div id="C">
                <h2>
                Introduction Subsection
              </h2>
              </div>
              <p>This is patent boilerplate</p>
            </div>
                  <br/>
            <div id="D">
              <h1>
              1
               
              Scope
            </h1>
              <p id="E">Text</p>
            </div>
            <div>
              <h1>
              2
               
              Normative References
            </h1>
            </div>
            <div id="H">
              <h1>
              3
               
              Terms, definitions, symbols and abbreviated terms
            </h1>
              <div id="I">
                <h2>
                3.1
                 
                Normal Terms
              </h2>
                <p class="TermNum" id="J">3.1.1</p>
                <p class="Terms" style="text-align:left;">
                  <b>Term2</b>
                </p>
              </div>
              <div id="K">
                <span class="zzMoveToFollowing inline-header">
                  <b>3.2  </b>
                </span>
                <div class="figdl">
                <dl>
                  <dt>
                    <p>Symbol</p>
                  </dt>
                  <dd>Definition</dd>
                </dl>
              </div>
              </div>
            </div>
            <div id="L" class="Symbols">
              <h1>4</h1>
              <div class="figdl">
              <dl>
                <dt>
                  <p>Symbol</p>
                </dt>
                <dd>Definition</dd>
              </dl>
            </div>
            </div>
            <div id="M">
              <h1>
              5
               
              Clause 4
            </h1>
              <div id="N">
                <h2>
                5.1
                 
                Introduction
              </h2>
              </div>
              <div id="O">
                <h2>
                5.2
                 
                Clause 4.2
              </h2>
              </div>
            </div>
            <br/>
            <div id="P" class="Section3">
              <h1 class="Annex">
                附属書A
                <br/>
                （規定）
                <br/>
                <b>Annex</b>
              </h1>
              <div id="Q">
                <h2>
              A.1
               
              Annex A.1
            </h2>
                <div id="Q1">
                  <h3>
                A.1.1
                 
                Annex A.1a
              </h3>
                </div>
              </div>
              <div id="Q2">
                <h2>
              Appendix 1
               
              An Appendix
            </h2>
              </div>
            </div>
            <br/>
            <div>
              <h1 class="Section3">Bibliography</h1>
              <div>
                <h2 class="Section3">Bibliography Subsection</h2>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    word = <<~WORD
       <html xmlns:epub='http://www.idpf.org/2007/ops' lang='ja'>
          <head>
            <style></style>
            <style></style>
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
                <p class="ForewordText" id="A">This is a preamble</p>
              </div>
                  <p class="page-break">
         <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
       </p>
       <div id="_" type="toc" class="TOC">
         <p class="zzContents">目　次</p>
       </div>
       <p> </p>
            </div>
            <p class="section-break">
              <br clear="all" class="section"/>
            </p>
            <div class="WordSection3">
                 <p class="JapaneseIndustrialStandard">
        日本工業規格
        <span style="mso-tab-count:1">  </span>
        <span style="mso-tab-count:1">  </span>
        <span style="mso-tab-count:1">  </span>
        <span style="mso-tab-count:1">  </span>
        <span style="mso-tab-count:1">  </span>
        <span style="mso-tab-count:1">  </span>
        <span style="mso-tab-count:1">  </span>
        <span class="JIS">JIS</span>
      </p>
      <p class="StandardNumber">
      <span style="mso-tab-count:1">  </span>
      </p>
      <p class="IDT"/>
              <p class="zzSTDTitle1">Introduction Française — Titre Principal — </p>
              <p class="zzSTDTitle1">
                その :
                <br/>
                <b>Part du Titre</b>
              </p>
              <p class="zzSTDTitle2">Introduction — Main Title — Title — </p>
              <p class="zzSTDTitle2">
                Part :
                <br/>
                <b>Title Part</b>
              </p>
              <div class="Section3" id="B">
                <h1 class="IntroTitle">Introduction</h1>
                <div id="C">
                  <h2>
                    Introduction Subsection
                  </h2>
                </div>
                <p>This is patent boilerplate</p>
              </div>
              <div id="D">
                <h1>
                  1
                  <span style="mso-tab-count:1">  </span>
                  Scope
                </h1>
                <p id="E">Text</p>
              </div>
              <div class="normref_div">
                <h1>
                  2
                  <span style="mso-tab-count:1">  </span>
                  Normative References
                </h1>
              </div>
              <div id="H">
                <h1>
                  3
                  <span style="mso-tab-count:1">  </span>
                  Terms, definitions, symbols and abbreviated terms
                </h1>
                <div id="I">
                  <h2>
                    3.1
                    <span style="mso-tab-count:1">  </span>
                    Normal Terms
                  </h2>
                  <p class="TermNum" id="J">3.1.1</p>
                  <p class="Terms" style="text-align:left;">
                    <b>Term2</b>
                  </p>
                </div>
                <div id="K">
                  <span class="zzMoveToFollowing inline-header">
                    <b>
                      3.2
                      <span style="mso-tab-count:1">  </span>
                    </b>
                  </span>
                  <table class="dl">
                    <tr>
                      <td valign="top" align="left">
                        <p align="left" style="margin-left:0pt;text-align:left;">Symbol</p>
                      </td>
                      <td valign="top">Definition</td>
                    </tr>
                  </table>
                </div>
              </div>
              <div id="L" class="Symbols">
                <h1>4</h1>
                <table class="dl">
                  <tr>
                    <td valign="top" align="left">
                      <p align="left" style="margin-left:0pt;text-align:left;">Symbol</p>
                    </td>
                    <td valign="top">Definition</td>
                  </tr>
                </table>
              </div>
              <div id="M">
                <h1>
                  5
                  <span style="mso-tab-count:1">  </span>
                  Clause 4
                </h1>
                <div id="N">
                  <h2>
                    5.1
                    <span style="mso-tab-count:1">  </span>
                    Introduction
                  </h2>
                </div>
                <div id="O">
                  <h2>
                    5.2
                    <span style="mso-tab-count:1">  </span>
                    Clause 4.2
                  </h2>
                </div>
              </div>
              <p class="page-break">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
              </p>
              <div id="P" class="Section3">
                <h1 class="Annex">
                  附属書A
                  <br/>
                  （規定）
                  <br/>
                  <b>Annex</b>
                </h1>
                <div id="Q">
                  <h2>
                    A.1
                    <span style="mso-tab-count:1">  </span>
                    Annex A.1
                  </h2>
                  <div id="Q1">
                    <h3>
                      A.1.1
                      <span style="mso-tab-count:1">  </span>
                      Annex A.1a
                    </h3>
                  </div>
                </div>
                <div id="Q2">
                  <h2>
                    Appendix 1
                    <span style="mso-tab-count:1">  </span>
                    An Appendix
                  </h2>
                </div>
              </div>
              <p class="page-break">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
              </p>
              <div class="bibliography">
                <h1 class="Section3">Bibliography</h1>
                <div>
                  <h2 class="BiblioTitle">Bibliography Subsection</h2>
                </div>
              </div>
            </div>
            <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
            <div class="colophon"/>
          </body>
        </html>
    WORD
    out = IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(out).to include <<~STR
      <localized-string key="971" language="ja">&#x4E5D;&#x767E;&#x4E03;&#x5341;&#x4E00;</localized-string>
    STR
    expect(Xml::C14n.format(strip_guid(out))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::Jis::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(IsoDoc::Jis::WordConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to Xml::C14n.format(word)

    input.sub!("</bibdata>", <<~SUB
      </bibdata><metanorma-extension>
      <presentation-metadata><name>autonumbering-style</name><value>japanese</value></presentation-metadata>
      </metanorma-extension>
    SUB
    )
    presxml = <<~PRESXML
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
             <title language="en" format="text/plain" type="main">Introduction — Main Title — Title — Title Part</title>
             <title language="en" format="text/plain" type="title-intro">Introduction</title>
             <title language="en" format="text/plain" type="title-main">Main Title — Title</title>
             <title language="en" format="text/plain" type="title-part">Title Part</title>
             <title language="ja" format="text/plain" type="main">Introduction Française — Titre Principal — Part du Titre</title>
             <title language="ja" format="text/plain" type="title-intro">Introduction Française</title>
             <title language="ja" format="text/plain" type="title-main">Titre Principal</title>
             <title language="ja" format="text/plain" type="title-part">Part du Titre</title>
             <edition language="">2</edition>
             <edition language="ja">第二版</edition>
             <status>
                <stage abbreviation="IS" language="">60</stage>
                <stage abbreviation="IS" language="ja">International Standard</stage>
             </status>
             <language current="true">ja</language>
             <ext>
                <doctype language="">international-standard</doctype>
                <doctype language="ja">日本産業規格</doctype>
             </ext>
          </bibdata>


          <preface>
             <foreword obligation="informative" displayorder="1">
                <title>Foreword</title>
                <p id="A">This is a preamble</p>
             </foreword>
             <clause type="toc" id="_" displayorder="2">
                <title depth="1">目　次</title>
             </clause>
          </preface>
          <sections>
             <p class="JapaneseIndustrialStandard" displayorder="3">
                日本工業規格
                <tab/>
                <tab/>
                <tab/>
                <tab/>
                <tab/>
                <tab/>
                <tab/>
                <span class="JIS">JIS</span>
             </p>
             <p class="StandardNumber" displayorder="4">
                <tab/>
             </p>
             <p class="IDT" displayorder="5"/>
             <p class="zzSTDTitle1" displayorder="6">Introduction Française — Titre Principal — </p>
             <p class="zzSTDTitle1" displayorder="7">
                その :
                <br/>
                <strong>Part du Titre</strong>
             </p>
             <p class="zzSTDTitle2" displayorder="8">Introduction — Main Title — Title — </p>
             <p class="zzSTDTitle2" displayorder="9">
                Part :
                <br/>
                <strong>Title Part</strong>
             </p>
             <introduction id="B" obligation="informative" unnumbered="true" displayorder="10">
                <title>Introduction</title>
                <clause id="C" inline-header="false" obligation="informative">
                   <title depth="2">Introduction Subsection</title>
                </clause>
                <p>This is patent boilerplate</p>
             </introduction>
             <clause id="D" obligation="normative" type="scope" displayorder="11">
                <title depth="1">
                   一
                   <tab/>
                   Scope
                </title>
                <p id="E">Text</p>
             </clause>
             <clause id="H" obligation="normative" displayorder="13">
                <title depth="1">
                   三
                   <tab/>
                   Terms, definitions, symbols and abbreviated terms
                </title>
                <terms id="I" obligation="normative">
                   <title depth="2">
                      三．一
                      <tab/>
                      Normal Terms
                   </title>
                   <term id="J">
                      <name>三．一．一</name>
                      <preferred>
                         <strong>Term2</strong>
                      </preferred>
                   </term>
                </terms>
                <definitions id="K" inline-header="true">
                <title>三　．　二</title>
                   <dl>
                      <dt>Symbol</dt>
                      <dd>Definition</dd>
                   </dl>
                </definitions>
             </clause>
             <definitions id="L" displayorder="14">
                <title>四</title>
                <dl>
                   <dt>Symbol</dt>
                   <dd>Definition</dd>
                </dl>
             </definitions>
             <clause id="M" inline-header="false" obligation="normative" displayorder="15">
                <title depth="1">
                   五
                   <tab/>
                   Clause 4
                </title>
                <clause id="N" inline-header="false" obligation="normative">
                   <title depth="2">
                      五．一
                      <tab/>
                      Introduction
                   </title>
                </clause>
                <clause id="O" inline-header="false" obligation="normative">
                   <title depth="2">
                      五．二
                      <tab/>
                      Clause 4.2
                   </title>
                </clause>
             </clause>
             <references id="R" normative="true" obligation="informative" displayorder="12">
                <title depth="1">
                   二
                   <tab/>
                   Normative References
                </title>
             </references>
          </sections>
          <annex id="P" inline-header="false" obligation="normative" displayorder="16">
             <title>
                附属書A
                <br/>
                （規定）
                <br/>
                <strong>Annex</strong>
             </title>
             <clause id="Q" inline-header="false" obligation="normative">
                <title depth="2">
                   A.一
                   <tab/>
                   Annex A.1
                </title>
                <clause id="Q1" inline-header="false" obligation="normative">
                   <title depth="3">
                      A.一．一
                      <tab/>
                      Annex A.1a
                   </title>
                </clause>
             </clause>
             <appendix id="Q2" inline-header="false" obligation="normative">
                <title depth="2">
                   Appendix 1
                   <tab/>
                   An Appendix
                </title>
             </appendix>
          </annex>
          <bibliography>
             <clause id="S" obligation="informative" displayorder="17">
                <title depth="1">Bibliography</title>
                <references id="T" normative="false" obligation="informative">
                   <title depth="2">Bibliography Subsection</title>
                </references>
             </clause>
          </bibliography>
       </iso-standard>
    PRESXML
    expect(Xml::C14n.format(strip_guid(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
      .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, ""))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "defaults to Japanese" do
    output = IsoDoc::Jis::PresentationXMLConvert.new(presxml_options)
      .convert("test", <<~INPUT, true)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
              <status>
              <stage abbreviation='IS' language=''>60</stage>
            </status>
            <language>tlh</language>
            <ext>
              <doctype language=''>international-standard</doctype>
            </ext>
          </bibdata>
          <preface>
            <foreword obligation="informative">
              <title>Foreword</title>
              <p id="A">This is a preamble</p>
            </foreword>
            <introduction id="B" obligation="informative">
              <title>Introduction</title>
              <clause id="C" inline-header="false" obligation="informative">
                <title>Introduction Subsection</title>
              </clause>
              <p>This is patent boilerplate</p>
            </introduction>
          </preface>
          <sections>
            <clause id="D" obligation="normative" type="scope">
              <title>Scope</title>
              <p id="E">Text</p>
            </clause>
            <clause id="H" obligation="normative">
              <title>Terms, definitions, symbols and abbreviated terms</title>
              <terms id="I" obligation="normative">
                <title>Normal Terms</title>
                <term id="J">
                  <preferred><expression><name>Term2</name></expression></preferred>
                </term>
              </terms>
              <definitions id="K">
                <dl>
                  <dt>Symbol</dt>
                  <dd>Definition</dd>
                </dl>
              </definitions>
            </clause>
            <definitions id="L">
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
            <clause id="M" inline-header="false" obligation="normative">
              <title>Clause 4</title>
              <clause id="N" inline-header="false" obligation="normative">
                <title>Introduction</title>
              </clause>
              <clause id="O" inline-header="false" obligation="normative">
                <title>Clause 4.2</title>
              </clause>
            </clause>
          </sections>
          <annex id="P" inline-header="false" obligation="normative">
            <title>Annex</title>
            <clause id="Q" inline-header="false" obligation="normative">
              <title>Annex A.1</title>
              <clause id="Q1" inline-header="false" obligation="normative">
                <title>Annex A.1a</title>
              </clause>
            </clause>
            <appendix id="Q2" inline-header="false" obligation="normative">
              <title>An Appendix</title>
            </appendix>
          </annex>
          <bibliography>
            <references id="R" normative="true" obligation="informative">
              <title>Normative References</title>
            </references>
            <clause id="S" obligation="informative">
              <title>Bibliography</title>
              <references id="T" normative="false" obligation="informative">
                <title>Bibliography Subsection</title>
              </references>
            </clause>
          </bibliography>
        </iso-standard>
      INPUT
    expect(Xml::C14n.format(strip_guid(output))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
        <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
             <bibdata>
               <status>
                 <stage abbreviation="IS" language="">60</stage>
                 <stage abbreviation="IS" language="tlh">International Standard</stage>
               </status>
               <language current="true">tlh</language>
               <ext>
                 <doctype language="">international-standard</doctype>
                 <doctype language="tlh">International Standard</doctype>
               </ext>
             </bibdata>

             <preface>
               <foreword obligation="informative" displayorder="1">
                 <title>Foreword</title>
                 <p id="A">This is a preamble</p>
               </foreword>
                <clause type="toc" id="_" displayorder="2">
                  <title depth="1">Table of contents</title>
                </clause>
             </preface>
             <sections>
                        <p class="JapaneseIndustrialStandard" displayorder="3">
             日本工業規格
             <tab/>
             <tab/>
             <tab/>
             <tab/>
             <tab/>
             <tab/>
             <tab/>
             <span class="JIS">JIS</span>
           </p>
           <p class="StandardNumber" displayorder="4">
             <tab/>
           </p>
           <p class="IDT" displayorder="5"/>
                <introduction id="B" obligation="informative" unnumbered="true" displayorder="6">
                 <title>Introduction</title>
                 <clause id="C" inline-header="false" obligation="informative">
                   <title depth="2">
                     Introduction Subsection
                   </title>
                 </clause>
                 <p>This is patent boilerplate</p>
               </introduction>
               <clause id="D" obligation="normative" type="scope" displayorder="7">
                 <title depth="1">
                   1
                   <tab/>
                   Scope
                 </title>
                 <p id="E">Text</p>
               </clause>
               <clause id="H" obligation="normative" displayorder="9">
                 <title depth="1">
                   3
                   <tab/>
                   Terms, definitions, symbols and abbreviated terms
                 </title>
                 <terms id="I" obligation="normative">
                   <title depth="2">
                     3.1
                     <tab/>
                     Normal Terms
                   </title>
                   <term id="J">
                     <name>3.1.1</name>
                     <preferred>
                       <strong>Term2</strong>
                     </preferred>
                   </term>
                 </terms>
                 <definitions id="K" inline-header="true">
                   <title>3.2</title>
                   <dl>
                     <dt>Symbol</dt>
                     <dd>Definition</dd>
                   </dl>
                 </definitions>
               </clause>
               <definitions id="L" displayorder="10">
                 <title>4</title>
                 <dl>
                   <dt>Symbol</dt>
                   <dd>Definition</dd>
                 </dl>
               </definitions>
               <clause id="M" inline-header="false" obligation="normative" displayorder="11">
                 <title depth="1">
                   5
                   <tab/>
                   Clause 4
                 </title>
                 <clause id="N" inline-header="false" obligation="normative">
                   <title depth="2">
                     5.1
                     <tab/>
                     Introduction
                   </title>
                 </clause>
                 <clause id="O" inline-header="false" obligation="normative">
                   <title depth="2">
                     5.2
                     <tab/>
                     Clause 4.2
                   </title>
                 </clause>
               </clause>
               <references id="R" normative="true" obligation="informative" displayorder="8">
                 <title depth="1">
                   2
                   <tab/>
                   Normative References
                 </title>
               </references>
             </sections>
             <annex id="P" inline-header="false" obligation="normative" displayorder="12">
               <title>
                 Annex A
                 <br/>
                 (normative)
                 <br/>
                 <strong>Annex</strong>
               </title>
               <clause id="Q" inline-header="false" obligation="normative">
                 <title depth="2">
                   A.1
                   <tab/>
                   Annex A.1
                 </title>
                 <clause id="Q1" inline-header="false" obligation="normative">
                   <title depth="3">
                     A.1.1
                     <tab/>
                     Annex A.1a
                   </title>
                 </clause>
               </clause>
               <appendix id="Q2" inline-header="false" obligation="normative">
                 <title depth="2">
                   Appendix 1
                   <tab/>
                   An Appendix
                 </title>
               </appendix>
             </annex>
             <bibliography>
               <clause id="S" obligation="informative" displayorder="13">
                 <title depth="1">Bibliography</title>
                 <references id="T" normative="false" obligation="informative">
                   <title depth="2">Bibliography Subsection</title>
                 </references>
               </clause>
             </bibliography>
           </iso-standard>
      OUTPUT
  end

  it "processes English" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
                  <title language="en" format="text/plain" type="main">Introduction — Main Title — Title — Title Part</title>
          <title language="en" format="text/plain" type="title-intro">Introduction</title>
          <title language="en" format="text/plain" type="title-main">Main Title — Title</title>
          <title language="en" format="text/plain" type="title-part">Title Part</title>
          <title language="ja" format="text/plain" type="main">Introduction Française — Titre Principal — Part du Titre</title>
          <title language="ja" format="text/plain" type="title-intro">Introduction Française</title>
          <title language="ja" format="text/plain" type="title-main">Titre Principal</title>
          <title language="ja" format="text/plain" type="title-part">Part du Titre</title>
          <status>
            <stage abbreviation='IS' language=''>60</stage>
          </status>
          <language>en</language>
          <ext>
            <doctype language=''>international-standard</doctype>
          </ext>
        </bibdata>
        <preface>
          <foreword obligation="informative">
            <title>Foreword</title>
            <p id="A">This is a preamble</p>
          </foreword>
          <introduction id="B" obligation="informative">
            <title>Introduction</title>
            <clause id="C" inline-header="false" obligation="informative">
              <title>Introduction Subsection</title>
            </clause>
            <p>This is patent boilerplate</p>
          </introduction>
        </preface>
        <sections>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
          <clause id="H" obligation="normative">
            <title>Terms, definitions, symbols and abbreviated terms</title>
            <terms id="I" obligation="normative">
              <title>Normal Terms</title>
              <term id="J">
                <preferred><expression><name>Term2</name></expression></preferred>
              </term>
            </terms>
            <definitions id="K">
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
          </clause>
          <definitions id="L">
            <dl>
              <dt>Symbol</dt>
              <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id="M" inline-header="false" obligation="normative">
            <title>Clause 4</title>
            <clause id="N" inline-header="false" obligation="normative">
              <title>Introduction</title>
            </clause>
            <clause id="O" inline-header="false" obligation="normative">
              <title>Clause 4.2</title>
            </clause>
          </clause>
        </sections>
        <annex id="P" inline-header="false" obligation="normative">
          <title>Annex</title>
          <clause id="Q" inline-header="false" obligation="normative">
            <title>Annex A.1</title>
            <clause id="Q1" inline-header="false" obligation="normative">
              <title>Annex A.1a</title>
            </clause>
          </clause>
          <appendix id="Q2" inline-header="false" obligation="normative">
            <title>An Appendix</title>
          </appendix>
        </annex>
        <bibliography>
          <references id="R" normative="true" obligation="informative">
            <title>Normative References</title>
          </references>
          <clause id="S" obligation="informative">
            <title>Bibliography</title>
            <references id="T" normative="false" obligation="informative">
              <title>Bibliography Subsection</title>
            </references>
          </clause>
        </bibliography>
      </iso-standard>
    INPUT

    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <bibdata>
                  <title language="en" format="text/plain" type="main">Introduction — Main Title — Title — Title Part</title>
          <title language="en" format="text/plain" type="title-intro">Introduction</title>
          <title language="en" format="text/plain" type="title-main">Main Title — Title</title>
          <title language="en" format="text/plain" type="title-part">Title Part</title>
          <title language="ja" format="text/plain" type="main">Introduction Française — Titre Principal — Part du Titre</title>
          <title language="ja" format="text/plain" type="title-intro">Introduction Française</title>
          <title language="ja" format="text/plain" type="title-main">Titre Principal</title>
          <title language="ja" format="text/plain" type="title-part">Part du Titre</title>
          <status>
            <stage abbreviation="IS" language="">60</stage>
            <stage abbreviation="IS" language="en">International Standard</stage>
          </status>
          <language current="true">en</language>
          <ext>
            <doctype language="">international-standard</doctype>
            <doctype language="en">International standard</doctype>
          </ext>
        </bibdata>

        <preface>
          <foreword obligation="informative" displayorder="1">
            <title>Foreword</title>
            <p id="A">This is a preamble</p>
          </foreword>
            <clause type="toc" id="_" displayorder="2">
        <title depth="1">Contents</title>
      </clause>
        </preface>
        <sections>
                   <p class="JapaneseIndustrialStandard" displayorder="3">
             日本工業規格
             <tab/>
             <tab/>
             <tab/>
             <tab/>
             <tab/>
             <tab/>
             <tab/>
             <span class="JIS">JIS</span>
           </p>
           <p class="StandardNumber" displayorder="4">
             <tab/>
           </p>
           <p class="IDT" displayorder="5"/>
           <p class="zzSTDTitle1" displayorder="6">Introduction — Main Title — Title — </p>
           <p class="zzSTDTitle1" displayorder="7">
             Part :
             <br/>
             <strong>Title Part</strong>
           </p>
           <p class="zzSTDTitle2" displayorder="8">Introduction Française — Titre Principal — </p>
           <p class="zzSTDTitle2" displayorder="9">
             その :
             <br/>
             <strong>Part du Titre</strong>
           </p>
                  <introduction id="B" unnumbered="true" obligation="informative" displayorder="10">
            <title>Introduction</title>
            <clause id="C" inline-header="false" obligation="informative">
              <title depth="2">
                Introduction Subsection
              </title>
            </clause>
            <p>This is patent boilerplate</p>
          </introduction>
          <clause id="D" obligation="normative" type="scope" displayorder="11">
            <title depth="1">
              1
              <tab/>
              Scope
            </title>
            <p id="E">Text</p>
          </clause>
          <clause id="H" obligation="normative" displayorder="13">
            <title depth="1">
              3
              <tab/>
              Terms, definitions, symbols and abbreviated terms
            </title>
            <terms id="I" obligation="normative">
              <title depth="2">
                3.1
                <tab/>
                Normal Terms
              </title>
              <term id="J">
                <name>3.1.1</name>
                <preferred>
                  <strong>Term2</strong>
                </preferred>
              </term>
            </terms>
            <definitions id="K" inline-header="true">
              <title>3.2</title>
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
          </clause>
          <definitions id="L" displayorder="14">
            <title>4</title>
            <dl>
              <dt>Symbol</dt>
              <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id="M" inline-header="false" obligation="normative" displayorder="15">
            <title depth="1">
              5
              <tab/>
              Clause 4
            </title>
            <clause id="N" inline-header="false" obligation="normative">
              <title depth="2">
                5.1
                <tab/>
                Introduction
              </title>
            </clause>
            <clause id="O" inline-header="false" obligation="normative">
              <title depth="2">
                5.2
                <tab/>
                Clause 4.2
              </title>
            </clause>
          </clause>
          <references id="R" normative="true" obligation="informative" displayorder="12">
            <title depth="1">
              2
              <tab/>
              Normative References
            </title>
          </references>
        </sections>
        <annex id="P" inline-header="false" obligation="normative" displayorder="16">
          <title>
            Annex A
            <br/>
            (normative)
            <br/>
            <strong>Annex</strong>
          </title>
          <clause id="Q" inline-header="false" obligation="normative">
            <title depth="2">
              A.1
              <tab/>
              Annex A.1
            </title>
            <clause id="Q1" inline-header="false" obligation="normative">
              <title depth="3">
                A.1.1
                <tab/>
                Annex A.1a
              </title>
            </clause>
          </clause>
          <appendix id="Q2" inline-header="false" obligation="normative">
            <title depth="2">
              Appendix 1
              <tab/>
              An Appendix
            </title>
          </appendix>
        </annex>
        <bibliography>
          <clause id="S" obligation="informative" displayorder="17">
            <title depth="1">Bibliography</title>
            <references id="T" normative="false" obligation="informative">
              <title depth="2">Bibliography Subsection</title>
            </references>
          </clause>
        </bibliography>
      </iso-standard>
    OUTPUT

    html = <<~OUTPUT
          <html lang="en">
        <head/>
        <body lang="en">
          <div class="title-section">
            <p> </p>
          </div>
          <br/>
          <div class="prefatory-section">
            <p> </p>
          </div>
          <br/>
          <div class="main-section">
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p id="A">This is a preamble</p>
            </div>
            <br/>
      <div id="_" class="TOC">
        <h1 class="IntroTitle">Contents</h1>
      </div>
            <p class="JapaneseIndustrialStandard">
        日本工業規格              
        <span class="JIS">JIS</span>
      </p>
      <p class="StandardNumber">  </p>
      <p class="IDT"/>
                  <p class="zzSTDTitle1">Introduction — Main Title — Title — </p>
      <p class="zzSTDTitle1">
        Part :
        <br/>
        <b>Title Part</b>
      </p>
            <p class="zzSTDTitle2">Introduction Française — Titre Principal — </p>
      <p class="zzSTDTitle2">
        その :
        <br/>
        <b>Part du Titre</b>
      </p>
      <br/>
      <div class="Section3" id="B">
              <h1 class="IntroTitle">Introduction</h1>
              <div id="C">
                <h2>
                Introduction Subsection
              </h2>
              </div>
              <p>This is patent boilerplate</p>
            </div>
            <div id="D">
              <h1>
              1
               
              Scope
            </h1>
              <p id="E">Text</p>
            </div>
            <div>
              <h1>
              2
               
              Normative References
            </h1>
            </div>
            <div id="H">
              <h1>
              3
               
              Terms, definitions, symbols and abbreviated terms
            </h1>
              <div id="I">
                <h2>
                3.1
                 
                Normal Terms
              </h2>
                <p class="TermNum" id="J">3.1.1</p>
                <p class="Terms" style="text-align:left;">
                  <b>Term2</b>
                </p>
              </div>
              <div id="K">
                <span class="zzMoveToFollowing inline-header">
                  <b>3.2  </b>
                </span>
                <div class="figdl">
                <dl>
                  <dt>
                    <p>Symbol</p>
                  </dt>
                  <dd>Definition</dd>
                </dl>
              </div>
              </div>
            </div>
            <div id="L" class="Symbols">
              <h1>4</h1>
              <div class="figdl">
              <dl>
                <dt>
                  <p>Symbol</p>
                </dt>
                <dd>Definition</dd>
              </dl>
            </div>
            </div>
            <div id="M">
              <h1>
              5
               
              Clause 4
            </h1>
              <div id="N">
                <h2>
                5.1
                 
                Introduction
              </h2>
              </div>
              <div id="O">
                <h2>
                5.2
                 
                Clause 4.2
              </h2>
              </div>
            </div>
            <br/>
            <div id="P" class="Section3">
              <h1 class="Annex">
                Annex A
                <br/>
                (normative)
                <br/>
                <b>Annex</b>
              </h1>
              <div id="Q">
                <h2>
              A.1
               
              Annex A.1
            </h2>
                <div id="Q1">
                  <h3>
                A.1.1
                 
                Annex A.1a
              </h3>
                </div>
              </div>
              <div id="Q2">
                <h2>
              Appendix 1
               
              An Appendix
            </h2>
              </div>
            </div>
            <br/>
            <div>
              <h1 class="Section3">Bibliography</h1>
              <div>
                <h2 class="Section3">Bibliography Subsection</h2>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::Jis::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "internationalises dates in bibdata" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
        <language>en</language>
          <date type="created">2020-10-11</date>
          <date type="issued">2020-10</date>
          <date type="published">2020</date>
        </bibdata>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <bibdata>
          <language current="true">en</language>
          <date type="created">2020-10-11</date>
          <date type="issued">2020-10</date>
          <date type="published">2020</date>
        </bibdata>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(output)
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <bibdata>
          <language current="true">ja</language>
          <date type="created">令和二年10月11日</date>
          <date type="issued">令和二年10月</date>
          <date type="published">令和二年</date>
        </bibdata>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input.sub("<language>en</language>",
                                 "<language>ja</language"), true)))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
