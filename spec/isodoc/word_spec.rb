require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc::Jis do
  it "processes Word styles" do
    input = <<~INPUT
      <jis-standard xmlns="https://www.metanorma.org/ns/jis" type="presentation" version="0.0.1">
      <bibdata type="standard">
      <contributor><role type="author"/><organization>
      <name>Japanese Industrial Standards</name>
      <abbreviation>JIS</abbreviation></organization></contributor><contributor><role type="publisher"/><organization>
      <name>Japanese Industrial Standards</name>
      <abbreviation>JIS</abbreviation></organization></contributor><language current="true">ja</language><script current="true">Jpan</script><status><stage>60</stage><substage>60</substage></status>
      </bibdata>
      <preface>
      <foreword id="_foreword" obligation="informative" displayorder="1">
      <fmt-title>まえがき</fmt-title>
      <p id="_553c5ce1-fd17-941b-b935-59caca87f267">This is a foreword</p>
      </foreword>
      <clause type="toc"><fmt-title>目次</fmt-title></clause>
      </preface><sections>
      <clause id="_clause" inline-header="false" obligation="normative" displayorder="3">
      <fmt-title depth="1">2<tab/>Clause</fmt-title>
      <note id="_339b7abc-c95c-638c-54a9-750cef9ea065"><fmt-name>注記<tab/></fmt-name><p id="_977f50de-4e2f-4dfc-c48b-c35a3ff271cc">Para1</p>

      <p id="_6d6fb0cf-1924-fadf-4eed-18a5915a75d8">para2</p>
      </note>

      <p id="_3cf332d1-0d92-ce94-f50d-8a0ba6150316"><strong>strong</strong></p>
      </clause>
      <references id="_normative_references" normative="true" obligation="informative" displayorder="2" displayorder="5">
      <fmt-title depth="1">1<tab/>引用規格</fmt-title><p id="_375d89b0-e764-77b0-b84e-611678e3e3a8">次に掲げる引用規格は，この規格に引用されることによ>って
      ，その一部又は全部がこの規格の要 求事項を構成している。これらの引用規格のうち，西暦年を付記してあるものは，記載の年の版を適 用し，その後>の改
      正版(追補を含む。)は適用しない。西暦年の付記がない引用規格は，その最新版(追 補を含む。)を適用する。</p>


      <bibitem id="A"><formattedref format="application/x-isodoc+xml"/><docidentifier>B</docidentifier><biblio-tag>B, </biblio-tag></bibitem>
      </references>
      </sections>
      <annex id="A" displayorder="4"><fmt-title>Annex</fmt-title>
      <clause id="B"><fmt-title>Annex Clause</fmt-title>
      <clause id="C"><fmt-title>Annex Clause Clause</fmt-title>
      </clause></clause></annex>
      <bibliography>
      <references id="_bibliography" normative="false" obligation="informative" displayorder="6">
      <fmt-title depth="1">参考文献</fmt-title>
      <p id="_1dcfd70f-f687-ba32-9a43-3088add497fc">This is some boilerplate</p><bibitem id="C">
        <formattedref format="application/x-isodoc+xml"/><docidentifier type="metanorma-ordinal">[1]</docidentifier>
        <docidentifier>D</docidentifier>

      <biblio-tag>[1]<tab/>D, </biblio-tag></bibitem>


      </references></bibliography>
      </jis-standard>
    INPUT
    word1 = <<~OUTPUT
      <div class="WordSection2">
        <div>
          <a name="_foreword" id="_foreword"/>
          <p class="ForewordTitle">まえがき</p>
          <p class="ForewordText">
            <a name="_553c5ce1-fd17-941b-b935-59caca87f267" id="_553c5ce1-fd17-941b-b935-59caca87f267"/>
            This is a foreword
          </p>
        </div>
        <p class="MsoNormal"> </p>
                 <div style="mso-element:para-border-div;border:solid windowtext 1.0pt; border-bottom-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt: solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:1.0pt 4.0pt 0cm 4.0pt; margin-left:5.1pt;margin-right:5.1pt">
         </div>
       </div>
    OUTPUT
    word2 = <<~OUTPUT
          <div class="WordSection3">
             <div class="normref_div">
               <h1>
                 1
                 <span style="mso-tab-count:1">  </span>
                 引用規格
               </h1>
               <p class="NormRefText">
                 <a name="_375d89b0-e764-77b0-b84e-611678e3e3a8" id="_375d89b0-e764-77b0-b84e-611678e3e3a8"/>
                 次に掲げる引用規格は，この規格に引用されることによって ，その一部又は全部がこの規格の要 求事項を構成している。これらの引用規格のうち，西暦年を付記してあるものは，記載の年の版を適 用し，その後の改 正版(追補を含む。)は適用しない。西暦年の付記がない引用規格は，その最新版(追 補を含む。)を適用する。
               </p>
               <p class="NormRef">
                 <a name="A" id="A"/>
                 B,
               </p>
             </div>
             <div>
               <a name="_clause" id="_clause"/>
               <h1>
                 2
                 <span style="mso-tab-count:1">  </span>
                 Clause
               </h1>
               <div>
                 <a name="_339b7abc-c95c-638c-54a9-750cef9ea065" id="_339b7abc-c95c-638c-54a9-750cef9ea065"/>
                 <p class="Note">
                   <span class="note_label">
               注記
               <span style="mso-tab-count:1">  </span>
            </span>
                   Para1
                 </p>
                 <p class="NoteCont">
                   <a name="_6d6fb0cf-1924-fadf-4eed-18a5915a75d8" id="_6d6fb0cf-1924-fadf-4eed-18a5915a75d8"/>
                   para2
                 </p>
               </div>
               <p class="MsoNormal">
                 <a name="_3cf332d1-0d92-ce94-f50d-8a0ba6150316" id="_3cf332d1-0d92-ce94-f50d-8a0ba6150316"/>
                 <span class="Strong">strong</span>
               </p>
             </div>
             <p class="MsoNormal">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
               <div class="Section3">
        <a name="A" id="A"/>
        <p class="Annex">Annex</p>
        <div>
          <a name="B" id="B"/>
          <p class="h2Annex">Annex Clause</p>
          <div>
            <a name="C" id="C"/>
            <p class="h3Annex">Annex Clause Clause</p>
          </div>
        </div>
      </div>
      <p class="MsoNormal">
        <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
      </p>
             <div class="bibliography">
               <h1 class="Section3">参考文献</h1>
               <p class="MsoNormal">
                 <a name="_1dcfd70f-f687-ba32-9a43-3088add497fc" id="_1dcfd70f-f687-ba32-9a43-3088add497fc"/>
                 This is some boilerplate
               </p>
               <p class="Biblio">
                 <a name="C" id="C"/>
                 [1]
                 <span style="mso-tab-count:1">  </span>
                 D,
               </p>
             </div>
           </div>
    OUTPUT
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test_cover.doc"
    IsoDoc::Jis::WordConvert.new({}).convert("test", input, false)
    expect(File.exist?("test.doc")).to be true
    expect(File.exist?("test_cover.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    doc = Nokogiri::XML(output)
    doc.xpath("//xmlns:p[@class = 'MsoToc1']").each(&:remove)
    doc1 = doc.at("//xmlns:div[@class = 'WordSection2']")
    expect(Xml::C14n.format(strip_guid(doc1.to_xml)))
      .to be_equivalent_to Xml::C14n.format(strip_guid(word1))
    doc1 = doc.at("//xmlns:div[@class = 'WordSection3']")
    expect(Xml::C14n.format(doc1.to_xml))
      .to be_equivalent_to Xml::C14n.format(word2)
  end

  it "moves content to inner cover" do
    input = <<~INPUT
      <jis-standard xmlns="https://www.metanorma.org/ns/jis" type="presentation" version="0.0.1">
      <bibdata type="standard">
      <contributor><role type="author"/><organization>
      <name>Japanese Industrial Standards</name>
      <abbreviation>JIS</abbreviation></organization></contributor><contributor><role type="publisher"/><organization>
      <name>Japanese Industrial Standards</name>
      <abbreviation>JIS</abbreviation></organization></contributor><language current="true">ja</language><script current="true">Jpan</script><status><stage>60</stage><substage>60</substage></status>
      </bibdata>
      <preface>
      <foreword displayorder="1"><fmt-title>Antauparolo</fmt-title></foreword>
      <clause type="participants" displayorder="3"><fmt-title>Contributors</fmt-title><p>Contributors</p></clause>
      </preface>
      </jis-standard>
    INPUT
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test_cover.doc"
    IsoDoc::Jis::WordConvert.new({}).convert("test", input, false)
    expect(File.exist?("test.doc")).to be true
    expect(File.exist?("test_cover.doc")).to be true
    word = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    doc = Nokogiri::XML(word)
    doc.xpath("//xmlns:p[@class = 'MsoToc1']").each(&:remove)
    expect(doc.to_xml).to include("Antauparolo")
    expect(doc.to_xml).not_to include("Contributors")
    word = File.read("test_cover.doc", encoding: "UTF-8")
    expect(word).not_to include("Antauparolo")
    expect(word).to include("Contributors")
  end

  it "deals with lists" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
        <clause id="A"><p>
        <ol id="B">
        <li><p>A</p></li>
        <li><p>B</p></li>
        <li><ol>
        <li>C</li>
        <li>D</li>
        <li><ol>
        <li>E</li>
        <li>F</li>
        <li><ol>
        <li>G</li>
        <li>H</li>
        <li><ol>
        <li>I</li>
        <li>J</li>
        <li><ol>
        <li>K</li>
        <li>L</li>
        <li>M</li>
        </ol></li>
        <li>N</li>
        </ol></li>
        <li>O</li>
        </ol></li>
        <li>P</li>
        </ol></li>
        <li>Q</li>
        </ol></li>
        <li>R</li>
        </ol>
        <ul id="C">
        <li><p>A</p></li>
        <li><p>B</p></li>
        <li><p>B1</p><ul>
        <li>C</li>
        <li>D</li>
        <li><ul>
        <li>E</li>
        <li>F</li>
        <li><ul>
        <li>G</li>
        <li>H</li>
        <li><ul>
        <li>I</li>
        <li>J</li>
        <li><ul>
        <li>K</li>
        <li>L</li>
        <li>M</li>
        </ul></li>
        <li>N</li>
        </ul></li>
        <li>O</li>
        </ul></li>
        <li>P</li>
        </ul></li>
        <li>Q</li>
        </ul></li>
        <li>R</li>
        </ul>
        </p></clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
      <div class="WordSection3">
                  #{middle_title(true)}
         <div>
           <a name="A" id="A"/>
           <h1>1</h1>
                      <p class="MsoNormal">
             <div class="ol_wrap">
               <p class="MsoList" style="margin-left: 36.0pt;text-indent:-18.0pt;;mso-list:l8 level1 lfo2;">
                 <a name="_" id="_"/>
                 A
               </p>
               <p class="MsoList" style="margin-left: 36.0pt;text-indent:-18.0pt;;mso-list:l8 level1 lfo2;">
                 <a name="_" id="_"/>
                 B
               </p>
               <p style="mso-list:l8 level1 lfo2;" class="margin-left: 36.0pt;text-indent:-18.0pt;">
                 <a name="_" id="_"/>
                 <div class="ol_wrap">
                   <p style="mso-list:l8 level2 lfo2;" class="margin-left: 54.0pt;text-indent:-18.0pt;">
                     <a name="_" id="_"/>
                     C
                   </p>
                   <p style="mso-list:l8 level2 lfo2;" class="margin-left: 54.0pt;text-indent:-18.0pt;">
                     <a name="_" id="_"/>
                     D
                   </p>
                   <p style="mso-list:l8 level2 lfo2;" class="margin-left: 54.0pt;text-indent:-18.0pt;">
                     <a name="_" id="_"/>
                     <div class="ol_wrap">
                       <p style="mso-list:l8 level3 lfo2;" class="margin-left: 72.0pt;text-indent:-18.0pt;">
                         <a name="_" id="_"/>
                         E
                       </p>
                       <p style="mso-list:l8 level3 lfo2;" class="margin-left: 72.0pt;text-indent:-18.0pt;">
                         <a name="_" id="_"/>
                         F
                       </p>
                       <p style="mso-list:l8 level3 lfo2;" class="margin-left: 72.0pt;text-indent:-18.0pt;">
                         <a name="_" id="_"/>
                         <div class="ol_wrap">
                           <p style="mso-list:l8 level4 lfo2;" class="margin-left: 90.0pt;text-indent:-18.0pt;">
                             <a name="_" id="_"/>
                             G
                           </p>
                           <p style="mso-list:l8 level4 lfo2;" class="margin-left: 90.0pt;text-indent:-18.0pt;">
                             <a name="_" id="_"/>
                             H
                           </p>
                           <p style="mso-list:l8 level4 lfo2;" class="margin-left: 90.0pt;text-indent:-18.0pt;">
                             <a name="_" id="_"/>
                             <div class="ol_wrap">
                               <p style="mso-list:l8 level5 lfo2;" class="margin-left: 108.0pt;text-indent:-18.0pt;">
                                 <a name="_" id="_"/>
                                 I
                               </p>
                               <p style="mso-list:l8 level5 lfo2;" class="margin-left: 108.0pt;text-indent:-18.0pt;">
                                 <a name="_" id="_"/>
                                 J
                               </p>
                               <p style="mso-list:l8 level5 lfo2;" class="margin-left: 108.0pt;text-indent:-18.0pt;">
                                 <a name="_" id="_"/>
                                 <div class="ol_wrap">
                                   <p style="mso-list:l8 level6 lfo2;" class="margin-left: 126.0pt;text-indent:-18.0pt;">
                                     <a name="_" id="_"/>
                                     K
                                   </p>
                                   <p style="mso-list:l8 level6 lfo2;" class="margin-left: 126.0pt;text-indent:-18.0pt;">
                                     <a name="_" id="_"/>
                                     L
                                   </p>
                                   <p style="mso-list:l8 level6 lfo2;" class="margin-left: 126.0pt;text-indent:-18.0pt;">
                                     <a name="_" id="_"/>
                                     M
                                   </p>
                                 </div>
                               </p>
                               <p style="mso-list:l8 level5 lfo2;" class="margin-left: 108.0pt;text-indent:-18.0pt;">
                                 <a name="_" id="_"/>
                                 N
                               </p>
                             </div>
                           </p>
                           <p style="mso-list:l8 level4 lfo2;" class="margin-left: 90.0pt;text-indent:-18.0pt;">
                             <a name="_" id="_"/>
                             O
                           </p>
                         </div>
                       </p>
                       <p style="mso-list:l8 level3 lfo2;" class="margin-left: 72.0pt;text-indent:-18.0pt;">
                         <a name="_" id="_"/>
                         P
                       </p>
                     </div>
                   </p>
                   <p style="mso-list:l8 level2 lfo2;" class="margin-left: 54.0pt;text-indent:-18.0pt;">
                     <a name="_" id="_"/>
                     Q
                   </p>
                 </div>
               </p>
               <p style="mso-list:l8 level1 lfo2;" class="margin-left: 36.0pt;text-indent:-18.0pt;">
                 <a name="_" id="_"/>
                 R
               </p>
             </div>
             <div class="ul_wrap">
               <p class="MsoListBullet" style="margin-left: 36.0pt;text-indent:-18.0pt;;mso-list:l9 level1 lfo1;" id="">A</p>
               <p class="MsoListBullet" style="margin-left: 36.0pt;text-indent:-18.0pt;;mso-list:l9 level1 lfo1;" id="">B</p>
               <p class="MsoListBullet" style="margin-left: 36.0pt;text-indent:-18.0pt;;mso-list:l9 level1 lfo1;" id="">B1</p>
               <div class="ListContLevel1">
                 <div class="ul_wrap">
                   <p style="mso-list:l9 level2 lfo1;" class="margin-left: 45.95pt;text-indent:-18.0pt;">C</p>
                   <p style="mso-list:l9 level2 lfo1;" class="margin-left: 45.95pt;text-indent:-18.0pt;">D</p>
                   <p style="mso-list:l9 level2 lfo1;" class="margin-left: 45.95pt;text-indent:-18.0pt;">
                     <div class="ul_wrap">
                       <p style="mso-list:l9 level3 lfo1;" class="margin-left: 72.0pt;text-indent:-18.0pt;">E</p>
                       <p style="mso-list:l9 level3 lfo1;" class="margin-left: 72.0pt;text-indent:-18.0pt;">F</p>
                       <p style="mso-list:l9 level3 lfo1;" class="margin-left: 72.0pt;text-indent:-18.0pt;">
                         <div class="ul_wrap">
                           <p style="mso-list:l9 level4 lfo1;" class="margin-left: 90.0pt;text-indent:-18.0pt;">G</p>
                           <p style="mso-list:l9 level4 lfo1;" class="margin-left: 90.0pt;text-indent:-18.0pt;">H</p>
                           <p style="mso-list:l9 level4 lfo1;" class="margin-left: 90.0pt;text-indent:-18.0pt;">
                             <div class="ul_wrap">
                               <p style="mso-list:l9 level5 lfo1;" class="margin-left: 108.0pt;text-indent:-18.0pt;">I</p>
                               <p style="mso-list:l9 level5 lfo1;" class="margin-left: 108.0pt;text-indent:-18.0pt;">J</p>
                               <p style="mso-list:l9 level5 lfo1;" class="margin-left: 108.0pt;text-indent:-18.0pt;">
                                 <div class="ul_wrap">
                                   <p style="mso-list:l9 level6 lfo1;" class="margin-left: 126.0pt;text-indent:-18.0pt;">K</p>
                                   <p style="mso-list:l9 level6 lfo1;" class="margin-left: 126.0pt;text-indent:-18.0pt;">L</p>
                                   <p style="mso-list:l9 level6 lfo1;" class="margin-left: 126.0pt;text-indent:-18.0pt;">M</p>
                                 </div>
                               </p>
                               <p style="mso-list:l9 level5 lfo1;" class="margin-left: 108.0pt;text-indent:-18.0pt;">N</p>
                             </div>
                           </p>
                           <p style="mso-list:l9 level4 lfo1;" class="margin-left: 90.0pt;text-indent:-18.0pt;">O</p>
                         </div>
                       </p>
                       <p style="mso-list:l9 level3 lfo1;" class="margin-left: 72.0pt;text-indent:-18.0pt;">P</p>
                     </div>
                   </p>
                   <p style="mso-list:l9 level2 lfo1;" class="margin-left: 45.95pt;text-indent:-18.0pt;">Q</p>
                 </div>
               </div>
               <p style="mso-list:l9 level1 lfo1;" class="margin-left: 36.0pt;text-indent:-18.0pt;">R</p>
             </div>
           </p>
         </div>
       </div>
    OUTPUT
    FileUtils.rm_f "test.doc"
    presxml = IsoDoc::Jis::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    IsoDoc::Jis::WordConvert.new({}).convert("test", presxml, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "deals with lists and paragraphs" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
      <clause id="A">
      <p id="_eb2fd8cd-5cbe-1f1f-7bdb-282868a25828">ISO and IEC maintain terminological databases for use in
      standardization at the following addresses:</p>

      <ul id="_6f8dbb84-61d9-f774-264e-b7e249cf44d1">
      <li> <p id="_9f56356a-3a58-64c4-e59e-a23ca3da7e88">ISO Online browsing platform: available at
        <link target="https://www.iso.org/obp"/></p></li>
      <li> <p id="_5dc6886f-a99c-e420-a29d-2aa6ca9f376e">IEC Electropedia: available at
      <link target="https://www.electropedia.org"/>
      </p> </li> </ul>
      </clause>
      </sections>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
      <div class="WordSection3">
                  #{middle_title(true)}
         <div>
           <a name="A" id="A"/>
           <h1>1</h1>
           <p class="MsoNormal">
             <a name="_eb2fd8cd-5cbe-1f1f-7bdb-282868a25828" id="_eb2fd8cd-5cbe-1f1f-7bdb-282868a25828"/>
             ISO and IEC maintain terminological databases for use in standardization at the following addresses:
           </p>
           <div class="ul_wrap">
           <p id="" class="MsoListBullet" style="margin-left: 36.0pt;text-indent:-18.0pt;;mso-list:l9 level1 lfo1;">
             ISO Online browsing platform: available at
             <a href="https://www.iso.org/obp">https://www.iso.org/obp</a>
           </p>
           <p id="" class="MsoListBullet" style="margin-left: 36.0pt;text-indent:-18.0pt;;mso-list:l9 level1 lfo1;">
             IEC Electropedia: available at
             <a href="https://www.electropedia.org">https://www.electropedia.org</a>
           </p>
         </div>
         </div>
       </div>
    OUTPUT
    FileUtils.rm_f "test.doc"
    presxml = IsoDoc::Jis::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    IsoDoc::Jis::WordConvert.new({}).convert("test", presxml, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    expect(Xml::C14n.format(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml))
      .to be_equivalent_to Xml::C14n.format(word)
  end
end
