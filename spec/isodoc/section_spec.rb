require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc::Jis do
  it "processes normative reference subclauses" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
       <bibliography>
       <clause id="R" normative="true" obligation="informative" displayorder="1">
         <title>Normative References</title>
          <references id="R" normative="true" obligation="informative">
         <title>Normative References 1</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    INPUT
    word = <<~OUTPUT
      <body lang="EN-US" link="blue" vlink="#954F72">
        <div class="WordSection1">
          <p> </p>
        </div>
        <p class="section-break">
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection2">
          <p> </p>
        </div>
        <p class="section-break">
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection3">
           <div class="normref_div">
             <h1>Normative References</h1>
             <div>
               <h2 class="BiblioTitle">Normative References 1</h2>
             </div>
           </div>
         </div>
         <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
         <div class="colophon"/>
       </body>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::Jis::WordConvert.new({})
          .convert("test", input, true)
          .sub(/^.*<body /m, "<body ").sub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "renders commentaries" do
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
          <docidentifier type="JIS">Z 1000-1.3:2000</docidentifier>
          <docnumber>1000</docnumber>
          <contributor>
            <role type="author"/>
            <organization>
              <name>Japanese Industrial Standards</name>
              <abbreviation>JIS</abbreviation>
            </organization>
          </contributor>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>Japanese Industrial Standards</name>
              <abbreviation>JIS</abbreviation>
            </organization>
          </contributor>
          <edition>2</edition>
          <version>
            <revision-date>2000-01-01</revision-date>
            <draft>0.3.4</draft>
          </version>
          <language>en</language>
          <script>Latn</script>
          <copyright>
            <from>2000</from>
            <owner>
              <organization>
                <name>Japanese Industrial Standards</name>
                <abbreviation>JIS</abbreviation>
              </organization>
            </owner>
          </copyright>
          </bibdata>
      <annex id="A"  inline-header="false" obligation="normative">
      <title>First Annex</title>
      </annex>
      <annex id="C"  inline-header="false" obligation="informative" commentary="true">
      <title>Commentary</title>
      <clause id="C1"><title>First clause</title>
      <clause id="C2"><title>First subclause</title>
      </clause>
      </clause>
      </annex>
      <annex id="B"  inline-header="false" obligation="informative">
      <title>Second Annex</title>
      </annex>
      <annex id="D"  inline-header="false" obligation="informative" commentary="true">
      <title>Another Commentary</title>
      </annex>
       <bibliography>
       <clause id="R" normative="true" obligation="informative">
         <title>Normative References</title>
          <references id="R1" normative="true" obligation="informative">
         <title>Normative References 1</title>
       </references>
       </clause>
       <references id="S" normative="false" obligation="informative">
         <title>Bibliography</title>
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
           <docidentifier type="JIS">Z 1000-1.3:2000</docidentifier>
           <docnumber>1000</docnumber>
           <contributor>
             <role type="author"/>
             <organization>
               <name>Japanese Industrial Standards</name>
               <abbreviation>JIS</abbreviation>
             </organization>
           </contributor>
           <contributor>
             <role type="publisher"/>
             <organization>
               <name>Japanese Industrial Standards</name>
               <abbreviation>JIS</abbreviation>
             </organization>
           </contributor>
           <edition language="">2</edition>
           <edition language="en">second edition</edition>
           <version>
             <revision-date>2000-01-01</revision-date>
             <draft>0.3.4</draft>
           </version>
           <language current="true">en</language>
           <script current="true">Latn</script>
           <copyright>
             <from>2000</from>
             <owner>
               <organization>
                 <name>Japanese Industrial Standards</name>
                 <abbreviation>JIS</abbreviation>
               </organization>
             </owner>
           </copyright>
         </bibdata>
           <preface>
            <clause type="toc" id="_" displayorder="1">
            <title depth="1">Contents</title>
          </clause>
        </preface>
                 <sections>
           <p class="JapaneseIndustrialStandard" displayorder="2">
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
           <p class="StandardNumber" displayorder="3">
             <tab/>
             Z 1000-1.3:
             <span class="EffectiveYear">2000</span>
           </p>
           <p class="IDT" displayorder="4"/>
           <p class="zzSTDTitle1" displayorder="5">Introduction — Main Title — Title — </p>
           <p class="zzSTDTitle1" displayorder="6">
             Part :
             <br/>
             <strong>Title Part</strong>
           </p>
           <p class="zzSTDTitle2" displayorder="7">Introduction Française — Titre Principal — </p>
           <p class="zzSTDTitle2" displayorder="8">
             その :
             <br/>
             <strong>Part du Titre</strong>
           </p>
           <clause id="R" normative="true" obligation="informative" displayorder="9">
             <title depth="1">
               1
               <tab/>
               Normative References
             </title>
             <references id="R1" normative="true" obligation="informative">
               <title depth="2">
                 1.1
                 <tab/>
                 Normative References 1
               </title>
             </references>
           </clause>
         </sections>
         <annex id="A" inline-header="false" obligation="normative" displayorder="10">
           <title>
             Annex A
             <br/>
             (normative)
             <br/>
             <strong>First Annex</strong>
           </title>
         </annex>
         <annex id="B" inline-header="false" obligation="informative" displayorder="11">
           <title>
             Annex B
             <br/>
             (informative)
             <br/>
             <strong>Second Annex</strong>
           </title>
         </annex>
         <bibliography>
           <references id="S" normative="false" obligation="informative" displayorder="12">
             <title depth="1">Bibliography</title>
           </references>
         </bibliography>
         <annex id="C" inline-header="false" obligation="informative" commentary="true" displayorder="13">
           <p class="CommentaryStandardNumber">
             JIS Z 1000-1.3 :
             <span class="CommentaryEffectiveYear">2000</span>
           </p>
           <p class="CommentaryStandardName">Introduction — Main Title — Title — </p>
           <p class="zzSTDTitle1">
             Part :
             <br/>
             <strong>Title Part</strong>
           </p>
           <title>Commentary</title>
               <clause id="C1">
                <title depth="2">
                  1
                  <tab/>
                  First clause
                </title>
                <clause id="C2">
                  <title depth="3">
                    1.1
                    <tab/>
                    First subclause
                  </title>
                </clause>
              </clause>
         </annex>
         <annex id="D" inline-header="false" obligation="informative" commentary="true" displayorder="14">
           <p class="CommentaryStandardNumber">
             JIS Z 1000-1.3 :
             <span class="CommentaryEffectiveYear">2000</span>
           </p>
           <p class="CommentaryStandardName">Introduction — Main Title — Title — </p>
           <p class="zzSTDTitle1">
             Part :
             <br/>
             <strong>Title Part</strong>
           </p>
           <title>Another Commentary</title>
         </annex>
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
      <div id="_" class="TOC">
        <h1 class="IntroTitle">Contents</h1>
      </div>
                       <p class="JapaneseIndustrialStandard">
               日本工業規格              
               <span class="JIS">JIS</span>
             </p>
             <p class="StandardNumber">
                 Z 1000-1.3:
               <span class="EffectiveYear">2000</span>
             </p>
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
            <div id="R">
              <h1>
              1
               
              Normative References
            </h1>
              <div>
                <h2 class="Section3">
                1.1
                 
                Normative References 1
              </h2>
              </div>
            </div>
            <br/>
            <div id="A" class="Section3">
              <h1 class="Annex">
                Annex A
                <br/>
                (normative)
                <br/>
                <b>First Annex</b>
              </h1>
            </div>
            <br/>
            <div id="B" class="Section3">
              <h1 class="Annex">
                Annex B
                <br/>
                (informative)
                <br/>
                <b>Second Annex</b>
              </h1>
            </div>
            <br/>
            <div>
              <h1 class="Section3">Bibliography</h1>
            </div>
            <br/>
            <div id="C" class="Section3">
                           <p class="CommentaryStandardNumber">
                 JIS Z 1000-1.3 :
                 <span class="CommentaryEffectiveYear">2000</span>
               </p>
               <p class="CommentaryStandardName">Introduction — Main Title — Title — </p>
               <p class="zzSTDTitle1">
                 Part :
                 <br/>
                 <b>Title Part</b>
               </p>
              <h1 class="Annex">Commentary</h1>
                      <div id="C1">
          <h2>
            1
             
            First clause
          </h2>
          <div id="C2">
            <h3>
              1.1
               
              First subclause
            </h3>
          </div>
        </div>
            </div>
            <br/>
            <div id="D" class="Section3">
                           <p class="CommentaryStandardNumber">
                 JIS Z 1000-1.3 :
                 <span class="CommentaryEffectiveYear">2000</span>
               </p>
               <p class="CommentaryStandardName">Introduction — Main Title — Title — </p>
               <p class="zzSTDTitle1">
                 Part :
                 <br/>
                 <b>Title Part</b>
               </p>
              <h1 class="Annex">Another Commentary</h1>
            </div>
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
          <div id="_" type="toc" class="TOC">
            <p class="zzContents">Contents</p>
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
            Z 1000-1.3:
            <span class="EffectiveYear">2000</span>
          </p>
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
          <div id="R">
            <h1>
              1
              <span style="mso-tab-count:1">  </span>
              Normative References
            </h1>
            <div>
              <h2 class="BiblioTitle">
                1.1
                <span style="mso-tab-count:1">  </span>
                Normative References 1
              </h2>
            </div>
          </div>
          <p class="page-break">
            <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
          </p>
          <div id="A" class="Section3">
            <h1 class="Annex">
              Annex A
              <br/>
              (normative)
              <br/>
              <b>First Annex</b>
            </h1>
          </div>
          <p class="page-break">
            <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
          </p>
          <div id="B" class="Section3">
            <h1 class="Annex">
              Annex B
              <br/>
              (informative)
              <br/>
              <b>Second Annex</b>
            </h1>
          </div>
          <p class="page-break">
            <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
          </p>
          <div class="bibliography">
            <h1 class="Section3">Bibliography</h1>
          </div>
          <span style="mso-bookmark:PRECOMMENTARYPAGEREF"/>
          <p class="section-break">
            <br clear="all" class="section"/>
          </p>
          <div class="WordSectionCommentary">
            <div id="C" class="Section3">
              <p class="CommentaryStandardNumber">
                JIS Z 1000-1.3 :
                <span class="CommentaryEffectiveYear">2000</span>
              </p>
              <p class="CommentaryStandardName">Introduction — Main Title — Title — </p>
              <p class="zzSTDTitle1">
                Part :
                <br/>
                <b>Title Part</b>
              </p>
              <h1 class="Annex">Commentary</h1>
              <div id="C1">
                <h2>
                  1
                  <span style="mso-tab-count:1">  </span>
                  First clause
                </h2>
                <div id="C2">
                  <h3>
                    1.1
                    <span style="mso-tab-count:1">  </span>
                    First subclause
                  </h3>
                </div>
              </div>
            </div>
          </div>
          <span style="mso-bookmark:PRECOMMENTARYPAGEREF"/>
          <p class="section-break">
            <br clear="all" class="section"/>
          </p>
          <div class="WordSectionCommentary">
            <div id="D" class="Section3">
              <p class="CommentaryStandardNumber">
                JIS Z 1000-1.3 :
                <span class="CommentaryEffectiveYear">2000</span>
              </p>
              <p class="CommentaryStandardName">Introduction — Main Title — Title — </p>
              <p class="zzSTDTitle1">
                Part :
                <br/>
                <b>Title Part</b>
              </p>
              <h1 class="Annex">Another Commentary</h1>
            </div>
          </div>
        </div>
        <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
        <div class="colophon"/>
      </body>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
        .convert("test", input, true))
        .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::Jis::HtmlConvert.new({})
        .convert("test", presxml, true)))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(IsoDoc::Jis::WordConvert.new({})
        .convert("test", presxml, true))
            .sub(/^.*<body /m, "<body ").sub(%r{</body>.*$}m, "</body>"))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes contributor table" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata type="standard">
              <language>en</language>
              <contributor><role type="publisher"/><organization>
                <name>国土交通省都市局</name>
              </organization></contributor><contributor><role type="authorizer"><description>Investigative organization</description></role><organization>
              <name> language="ja">日本産業標準調査会</name><name language="en">Japanese Industrial Standards Committee</name>
              </organization></contributor><contributor><role type="authorizer"><description>Investigative committee</description></role><organization>
              <name>日本産業標準調査会 標準第一部会</name>
              </organization></contributor>
      </bibdata>
      <sections>
      <clause id="_blank" type="participants" inline-header="false" obligation="normative">
      <sourcecode id="_17ee9ae0-dbd4-156e-202e-981056a3d532" lang="yaml">
      - name:
          surname: 酒井
          givenname: 信介
        affiliation:  横浜国立大学
        role: 部会長
      - name:
          surname: 伊藤
          givenname: 弘
        affiliation: 国立研究開発法人建築研究所
        role: 委員
      - name:
          surname: 宇治
          givenname: 公隆
        affiliation: 国立研究開発法人建築研究所</sourcecode>

      </clause>

      <clause id="_clause" inline-header="false" obligation="normative">
      <title>Clause</title>
      </clause>
      </sections>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <preface>
          <clause id="_8f8a39d0-9603-4429-b5bb-3b4eeef89dbb" displayorder="1">
             <title depth="1">日本産業標準調査会 標準第一部会 Membership Table</title>
             <table unnumbered="true">
                <thead>
                   <tr>
                      <th/>
                      <th>Full Name</th>
                      <th>Affiliation</th>
                   </tr>
                </thead>
                <tbody>
                   <tr>
                      <td>(部会長)</td>
                      <td>信介 酒井</td>
                      <td>横浜国立大学</td>
                   </tr>
                   <tr>
                      <td>(委員)</td>
                      <td>弘 伊藤</td>
                      <td>国立研究開発法人建築研究所</td>
                   </tr>
                   <tr>
                      <td/>
                      <td>公隆 宇治</td>
                      <td>国立研究開発法人建築研究所</td>
                   </tr>
                </tbody>
             </table>
          </clause>
          <clause type="toc" id="_049d0d9c-36cd-4fd5-8a82-16cc86a95e23" displayorder="2">
             <title depth="1">Contents</title>
          </clause>
       </preface>
    OUTPUT
    output = Nokogiri::XML(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
    output = output.at("//xmlns:preface")
    expect(Xml::C14n.format(strip_guid(output.to_xml)))
      .to be_equivalent_to Xml::C14n.format(strip_guid(presxml))

    presxml = <<~OUTPUT
      <preface>
          <clause id="_" displayorder="1">
             <title depth="1">日本産業標準調査会 標準第一部会 構成表</title>
             <table unnumbered="true">
                <thead>
                   <tr>
                      <th/>
                      <th>氏名</th>
                      <th>所属</th>
                   </tr>
                </thead>
                <tbody>
                   <tr>
                      <td>(部会長)</td>
                      <td>酒井 信介</td>
                      <td>横浜国立大学</td>
                   </tr>
                   <tr>
                      <td>(委員)</td>
                      <td>伊藤 弘</td>
                      <td>国立研究開発法人建築研究所</td>
                   </tr>
                   <tr>
                      <td/>
                      <td>宇治 公隆</td>
                      <td>国立研究開発法人建築研究所</td>
                   </tr>
                </tbody>
             </table>
          </clause>
          <clause type="toc" id="_" displayorder="2">
             <title depth="1">目　次</title>
          </clause>
       </preface>
    OUTPUT
    output = Nokogiri::XML(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input.sub("<language>en</language>",
                                 "<language>ja</language>"), true))
    output = output.at("//xmlns:preface")
    expect(Xml::C14n.format(strip_guid(output.to_xml)))
      .to be_equivalent_to Xml::C14n.format(strip_guid(presxml))
  end

    it "processes section names" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <boilerplate>
        <copyright-statement>
        <clause>
          <title>Copyright</title>
        </clause>
        </copyright-statement>
        <license-statement>
        <clause>
          <title>License</title>
        </clause>
        </license-statement>
        <legal-statement>
        <clause>
          <title>Legal</title>
        </clause>
        </legal-statement>
        <feedback-statement>
        <clause>
          <title>Feedback</title>
        </clause>
        </feedback-statement>
      </boilerplate>
      <preface>
      <abstract obligation="informative">
         <title>Abstract</title>
      </abstract>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       </introduction>
       <clause id="B1"><title>Dedication</title></clause>
       <clause id="B2"><title>Note to reader</title></clause>
       <acknowledgements obligation="informative">
         <title>Acknowledgements</title>
       </acknowledgements>
        </preface><sections>
        <note id="NN1"><p>Initial note</p></note>
        <admonition id="NN2" type="warning">
        <name>WARNING</name>
        <p>Initial admonition</p></admonition>
       <clause id="D" obligation="normative" type="scope">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>
       <clause id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title><terms id="I" obligation="normative">
         <title>Normal Terms</title>
         <term id="J">
         <preferred><expression><name>Term2</name></expression></preferred>
       </term>
       </terms>
       <definitions id="K">
         <title>Definitions</title>
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       </clause>
       <definitions id="L">
       <title>Symbols and abbreviated terms</title>
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </clause>
       <clause id="O1" inline-header="false" obligation="normative">
       </clause>
        </clause>
       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </clause>
         <references id="Q2" normative="false">
        <title>Annex Bibliography</title>
        </references>
       </clause>
       </annex>
       <annex id="P1" inline-header="false" obligation="normative">
       </annex>
        <bibliography><references id="R" obligation="informative" normative="true">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       <indexsect id="INDX">
       <title>Index</title>
       </indexsect>
       <colophon>
      <clause id="U1" obligation="informative">
         <title>Postface 1</title>
      </clause>
      <clause id="U2" obligation="informative">
         <title>Postface 2</title>
      </clause>
      </colophon>
       </iso-standard>
    INPUT
    presxml = <<~PRESXML
           <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <boilerplate>
             <copyright-statement>
                <clause>
                   <title depth="1">Copyright</title>
                </clause>
             </copyright-statement>
             <license-statement>
                <clause>
                   <title depth="1">License</title>
                </clause>
             </license-statement>
             <legal-statement>
                <clause>
                   <title depth="1">Legal</title>
                </clause>
             </legal-statement>
             <feedback-statement>
                <clause>
                   <title depth="1">Feedback</title>
                </clause>
             </feedback-statement>
          </boilerplate>
          <preface>
             <abstract obligation="informative" displayorder="1">
                <title>Abstract</title>
             </abstract>
             <foreword obligation="informative" displayorder="2">
                <title>Foreword</title>
                <p id="A">This is a preamble</p>
             </foreword>
             <clause id="B1" displayorder="3">
                <title depth="1">Dedication</title>
             </clause>
             <clause id="B2" displayorder="4">
                <title depth="1">Note to reader</title>
             </clause>
             <acknowledgements obligation="informative" displayorder="5">
                <title>Acknowledgements</title>
             </acknowledgements>
             <clause type="toc" id="_" displayorder="6">
                <title depth="1">Contents</title>
             </clause>
          </preface>
          <sections>
             <p class="JapaneseIndustrialStandard" displayorder="7">
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
             <p class="StandardNumber" displayorder="8">
                <tab/>
             </p>
             <p class="IDT" displayorder="9"/>
             <introduction id="B" obligation="informative" unnumbered="true" displayorder="10">
                <title>Introduction</title>
                <clause id="C" inline-header="false" obligation="informative">
                   <title depth="2">Introduction Subsection</title>
                </clause>
             </introduction>
             <note id="NN1" displayorder="11">
                <name>NOTE</name>
                <p>Initial note</p>
             </note>
             <admonition id="NN2" type="warning" displayorder="12">
                <p>
                   <strong>WARNING — </strong>
                   <strong>Initial admonition</strong>
                </p>
             </admonition>
             <clause id="D" obligation="normative" type="scope" displayorder="13">
                <title depth="1">
                   1
                   <tab/>
                   Scope
                </title>
                <p id="E">Text</p>
             </clause>
             <clause id="H" obligation="normative" displayorder="15">
                <title depth="1">
                   3
                   <tab/>
                   Terms, Definitions, Symbols and Abbreviated Terms
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
                <definitions id="K">
                   <title depth="2">
                      3.2
                      <tab/>
                      Definitions
                   </title>
                   <dl>
                      <dt>Symbol</dt>
                      <dd>Definition</dd>
                   </dl>
                </definitions>
             </clause>
             <definitions id="L" displayorder="16">
                <title depth="1">
                   4
                   <tab/>
                   Symbols and abbreviated terms
                </title>
                <dl>
                   <dt>Symbol</dt>
                   <dd>Definition</dd>
                </dl>
             </definitions>
             <clause id="M" inline-header="false" obligation="normative" displayorder="17">
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
                <clause id="O1" inline-header="true" obligation="normative">
                   <title>5.3</title>
                </clause>
             </clause>
             <references id="R" obligation="informative" normative="true" displayorder="14">
                <title depth="1">
                   2
                   <tab/>
                   Normative References
                </title>
             </references>
          </sections>
          <annex id="P" inline-header="false" obligation="normative" displayorder="18">
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
                <references id="Q2" normative="false">
                   <title depth="3">
                      A.1.2
                      <tab/>
                      Annex Bibliography
                   </title>
                </references>
             </clause>
          </annex>
          <annex id="P1" inline-header="false" obligation="normative" displayorder="19">
             <title>
                Annex B
                <br/>
                (normative)
             </title>
          </annex>
          <bibliography>
             <clause id="S" obligation="informative" displayorder="20">
                <title depth="1">Bibliography</title>
                <references id="T" obligation="informative" normative="false">
                   <title depth="2">Bibliography Subsection</title>
                </references>
             </clause>
          </bibliography>
          <colophon>
             <clause id="U1" obligation="informative" displayorder="21">
                <title depth="1">Postface 1</title>
             </clause>
             <clause id="U2" obligation="informative" displayorder="22">
                <title depth="1">Postface 2</title>
             </clause>
          </colophon>
       </iso-standard>
    PRESXML
     output = Nokogiri::XML(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
    expect(Xml::C14n.format(strip_guid(output.to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    presxml = <<~PRESXML
    PRESXML
    input.sub!("</bibdata>", <<~SUB
      </bibdata><metanorma-extension>
      <presentation-metadata><name>autonumber-style</name><value>japanese</value></presentation-metadata>
      </metanorma-extension>
      SUB
    )
     output = Nokogiri::XML(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
    expect(Xml::C14n.format(strip_guid(output.to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    end
end
