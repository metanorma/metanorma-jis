require "spec_helper"

RSpec.describe IsoDoc::Jis do
  it "cross-references sections" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble
         <xref target="P"/>
         <xref target="Q"/>
         <xref target="Q1"/>
         <xref target="U"/>
         <xref target="V"/>
         <xref target="V1"/>
         <xref target="V2"/>
         <xref target="R"/>
         <xref target="S"/>
         </p>
       </foreword>
       </preface>
       <sections/>
       <annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </clause>
       </clause>
       </annex>
       <annex id="U" inline-header="false" obligation="normative">
         <title>Another Annex</title>
       </annex>
       <annex id="V" inline-header="false" obligation="normative" commentary="true">
         <title>Commentary</title>
         <clause id="V1">
         <clause id="V2"/>
         </clause>
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
       </iso-standard>
    INPUT
    output = <<~OUTPUT
        <foreword obligation="informative" id="_" displayorder="1">
           <title id="_">Foreword</title>
           <fmt-title id="_" depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p id="A">
              This is a preamble
              <xref target="P" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="P">
                    <span class="citeapp">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="P">A</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="Q" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Q">
                    <span class="citeapp">
                       <semx element="autonum" source="P">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="Q">1</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="Q1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Q1">
                    <span class="citeapp">
                       <semx element="autonum" source="P">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="Q">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="Q1">1</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="U" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="U">
                    <span class="citeapp">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="U">B</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="V" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="V">
                    <span class="citesec">
                       <semx element="annex" source="V">Commentary</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="V1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="V1">
                    <span class="citesec">
                       <span class="fmt-xref-container">
                          <semx element="annex" source="V">Commentary</semx>
                       </span>
                       <span class="fmt-comma">,</span>
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="V1">1</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="V2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="V2">
                    <span class="citesec">
                       <span class="fmt-xref-container">
                          <semx element="annex" source="V">Commentary</semx>
                       </span>
                       <span class="fmt-comma">,</span>
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="V1">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="V2">1</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="R" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="R">
                    <span class="citesec">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="R">1</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="S" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="S">
                    <span class="citesec">
                       <semx element="clause" source="S">Bibliography</semx>
                    </span>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Nokogiri.XML(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "cross-references list items" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble
         <xref target="P"/>
         <xref target="Q"/>
         <xref target="R"/>
         <xref target="S"/>
         <xref target="P1"/>
         </p>
       </foreword>
       </preface>
       <sections>
       <clause id="A"><title>Clause</title>
       <ol id="L">
       <li id="P">
       <ol id="L11">
       <li id="Q">
       <ol id="L12">
       <li id="R">
       <ol id="L13">
       <li id="S">
       </li>
       </ol>
       </li>
       </ol>
       </li>
       </ol>
       </li>
       </ol>
       <ol id="L1">
       <li id="P1">A</li>
       </ol>
       </clause>
       </sections>
       </iso-standard>
    INPUT
    output = <<~OUTPUT
        <foreword obligation="informative" id="_" displayorder="1">
           <title id="_">Foreword</title>
           <fmt-title id="_" depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p id="A">
              This is a preamble
              <xref target="P" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="P">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="A">1</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                    <semx element="autonum" source="L">1</semx>
                    <semx element="autonum" source="P">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="Q" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Q">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="A">1</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                    <semx element="autonum" source="L">1</semx>
                    <semx element="autonum" source="P">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="Q">1</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="R" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="R">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="A">1</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                    <semx element="autonum" source="L">1</semx>
                    <semx element="autonum" source="P">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="Q">1</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="R">1</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="S" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="S">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="A">1</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                    <semx element="autonum" source="L">1</semx>
                    <semx element="autonum" source="P">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="Q">1</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="R">1</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="S">1</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="P1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="P1">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="A">1</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                    <semx element="autonum" source="L1">2</semx>
                    <semx element="autonum" source="P1">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Nokogiri.XML(IsoDoc::Jis::PresentationXMLConvert
       .new(presxml_options)
       .convert("test", input, true))
       .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)

    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata><language>ja</language></bibdata>
      <preface>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble
         <xref target="P"/>
         <xref target="Q"/>
         <xref target="R"/>
         <xref target="S"/>
         <xref target="P1"/>
         </p>
       </foreword>
       </preface>
       <sections>
       <clause id="A"><title>Clause</title>
       <ol id="L">
       <li id="P">
       <ol id="L11">
       <li id="Q">
       <ol id="L12">
       <li id="R">
       <ol id="L13">
       <li id="S">
       </li>
       </ol>
       </li>
       </ol>
       </li>
       </ol>
       </li>
       </ol>
       <ol id="L1">
       <li id="P1">A</li>
       </ol>
       </clause>
       </sections>
       </iso-standard>
    INPUT
    output = <<~OUTPUT
        <foreword obligation="informative" id="_" displayorder="1">
           <title id="_">Foreword</title>
           <fmt-title id="_" depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p id="A">
              This is a preamble
              <xref target="P" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="P">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">箇条</span>
                       <semx element="autonum" source="A">1</semx>
                    </span>
                    <span class="fmt-conn">の</span>
                    <span class="fmt-element-name">リスト</span>
                    <semx element="autonum" source="L">1</semx>
                    <span class="fmt-conn">の</span>
                    <semx element="autonum" source="P">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="Q" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Q">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">箇条</span>
                       <semx element="autonum" source="A">1</semx>
                    </span>
                    <span class="fmt-conn">の</span>
                    <span class="fmt-element-name">リスト</span>
                    <semx element="autonum" source="L">1</semx>
                    <span class="fmt-conn">の</span>
                    <semx element="autonum" source="P">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <span class="fmt-conn">の</span>
                    <semx element="autonum" source="Q">1</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="R" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="R">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">箇条</span>
                       <semx element="autonum" source="A">1</semx>
                    </span>
                    <span class="fmt-conn">の</span>
                    <span class="fmt-element-name">リスト</span>
                    <semx element="autonum" source="L">1</semx>
                    <span class="fmt-conn">の</span>
                    <semx element="autonum" source="P">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <span class="fmt-conn">の</span>
                    <semx element="autonum" source="Q">1</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="R">1</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="S" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="S">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">箇条</span>
                       <semx element="autonum" source="A">1</semx>
                    </span>
                    <span class="fmt-conn">の</span>
                    <span class="fmt-element-name">リスト</span>
                    <semx element="autonum" source="L">1</semx>
                    <span class="fmt-conn">の</span>
                    <semx element="autonum" source="P">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <span class="fmt-conn">の</span>
                    <semx element="autonum" source="Q">1</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="R">1</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="S">1</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="P1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="P1">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">箇条</span>
                       <semx element="autonum" source="A">1</semx>
                    </span>
                    <span class="fmt-conn">の</span>
                    <span class="fmt-element-name">リスト</span>
                    <semx element="autonum" source="L1">2</semx>
                    <span class="fmt-conn">の</span>
                    <semx element="autonum" source="P1">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Nokogiri.XML(IsoDoc::Jis::PresentationXMLConvert
       .new(presxml_options)
       .convert("test", input, true))
       .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "cross-references assets in commentaries" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble
         <xref target="P"/>
         <xref target="Q"/>
         <xref target="R"/>
         <xref target="S"/>
         <xref target="T"/>
         <xref target="U"/>
         </p>
       </foreword>
       </preface>
       <annex id="A1" inline-header="false" obligation="normative">
         <title>Annex</title>
         <note id="P"/>
         <clause id="A2" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         <note id="Q"/>
         </clause>
       </annex>
       <annex id="A3" inline-header="false" obligation="normative" commentary="true">
         <title>Commentary</title>
         <note id="R"/>
         <table id="T"><tbody><tr><td/></tr></tbody></table>
         <clause id="A4">
         <note id="S"/>
         <table id="U">><tbody><tr><td/></tr></tbody></table>
         </clause>
       </annex>
       </iso-standard>
    INPUT
    output = <<~OUTPUT
        <foreword obligation="informative" id="_" displayorder="1">
           <title id="_">Foreword</title>
           <fmt-title id="_" depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p id="A">
              This is a preamble
              <xref target="P" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="P">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="A1">A</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Note</span>
                 </fmt-xref>
              </semx>
              <xref target="Q" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Q">
                    <span class="fmt-xref-container">
                       <semx element="autonum" source="A1">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="A2">1</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Note</span>
                 </fmt-xref>
              </semx>
              <xref target="R" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="R">
                    <span class="fmt-xref-container">
                       <semx element="annex" source="A3">Commentary</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Note</span>
                 </fmt-xref>
              </semx>
              <xref target="S" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="S">
                    <span class="fmt-xref-container">
                       <span class="fmt-xref-container">
                          <semx element="annex" source="A3">Commentary</semx>
                       </span>
                       <span class="fmt-comma">,</span>
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="A4">1</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Note</span>
                 </fmt-xref>
              </semx>
              <xref target="T" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="T">
                    <span class="citetbl">
                       <span class="fmt-xref-container">
                          <semx element="annex" source="A3">Commentary</semx>
                       </span>
                       <span class="fmt-comma">,</span>
                       <span class="fmt-element-name">Table</span>
                       <semx element="autonum" source="T">1</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="U" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="U">
                    <span class="citetbl">
                       <span class="fmt-xref-container">
                          <span class="fmt-xref-container">
                             <semx element="annex" source="A3">Commentary</semx>
                          </span>
                          <span class="fmt-comma">,</span>
                          <span class="fmt-element-name">Clause</span>
                          <semx element="autonum" source="A4">1</semx>
                       </span>
                       <span class="fmt-comma">,</span>
                       <span class="fmt-element-name">Table</span>
                       <semx element="autonum" source="U">2</semx>
                    </span>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Nokogiri.XML(IsoDoc::Jis::PresentationXMLConvert
       .new(presxml_options)
       .convert("test", input, true))
       .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
    output = <<~OUTPUT
       <foreword obligation="informative" id="_" displayorder="1">
           <title id="_">Foreword</title>
           <fmt-title id="_" depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p id="A">
              This is a preamble
              <xref target="P" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="P">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">附属書</span>
                       <semx element="autonum" source="A1">A</semx>
                    </span>
                    <span class="fmt-conn">の</span>
                    <span class="fmt-element-name">注記</span>
                 </fmt-xref>
              </semx>
              <xref target="Q" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Q">
                    <span class="fmt-xref-container">
                       <semx element="autonum" source="A1">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="A2">1</semx>
                    </span>
                    <span class="fmt-conn">の</span>
                    <span class="fmt-element-name">注記</span>
                 </fmt-xref>
              </semx>
              <xref target="R" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="R">
                    <span class="fmt-xref-container">
                       <semx element="annex" source="A3">Commentary</semx>
                    </span>
                    <span class="fmt-conn">の</span>
                    <span class="fmt-element-name">注記</span>
                 </fmt-xref>
              </semx>
              <xref target="S" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="S">
                    <span class="fmt-xref-container">
                       <span class="fmt-xref-container">
                          <semx element="annex" source="A3">Commentary</semx>
                       </span>
                       <span class="fmt-conn">の</span>
                       <span class="fmt-element-name">箇条</span>
                       <semx element="autonum" source="A4">1</semx>
                    </span>
                    <span class="fmt-conn">の</span>
                    <span class="fmt-element-name">注記</span>
                 </fmt-xref>
              </semx>
              <xref target="T" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="T">
                    <span class="citetbl">
                       <span class="fmt-xref-container">
                          <semx element="annex" source="A3">Commentary</semx>
                       </span>
                       <span class="fmt-conn">の</span>
                       <span class="fmt-element-name">表</span>
                       <semx element="autonum" source="T">1</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="U" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="U">
                    <span class="citetbl">
                       <span class="fmt-xref-container">
                          <span class="fmt-xref-container">
                             <semx element="annex" source="A3">Commentary</semx>
                          </span>
                          <span class="fmt-conn">の</span>
                          <span class="fmt-element-name">箇条</span>
                          <semx element="autonum" source="A4">1</semx>
                       </span>
                       <span class="fmt-conn">の</span>
                       <span class="fmt-element-name">表</span>
                       <semx element="autonum" source="U">2</semx>
                    </span>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    input.sub!("<preface>",
               "<bibdata><language>ja</language></bibdata><preface>")
    expect(Canon.format_xml(strip_guid(Nokogiri.XML(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
       .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "cross-references subfigures" do
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <bibdata><language>en</language></bibdata>
            <preface>
        <foreword id="fwd">
        <p>
        <xref target="N"/>
        <xref target="note1"/>
        <xref target="note2"/>
        <xref target="AN"/>
        <xref target="Anote1"/>
        <xref target="Anote2"/>
        <xref target="AN1"/>
        <xref target="Anote11"/>
        <xref target="Anote21"/>
        </p>
        </foreword>
        </preface>
        <sections>
        <clause id="scope" type="scope"><title>Scope</title>
        </clause>
        <terms id="terms"/>
        <clause id="widgets"><title>Widgets</title>
        <clause id="widgets1">
        <figure id="N">
            <figure id="note1">
      <name>Split-it-right sample divider</name>
      <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
      </figure>
        <figure id="note2">
      <name>Split-it-right sample divider</name>
      <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
      </figure>
      </figure>
      <p>    <xref target="note1"/> <xref target="note2"/> </p>
        </clause>
        </clause>
        </sections>
        <annex id="annex1">
        <clause id="annex1a">
        </clause>
        <clause id="annex1b">
        <figure id="AN">
            <figure id="Anote1">
      <name>Split-it-right sample divider</name>
      <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
      </figure>
        <figure id="Anote2">
      <name>Split-it-right sample divider</name>
      <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
      </figure>
      </figure>
        </clause>
        </annex>
                  <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
                  <figure id="AN1">
            <figure id="Anote11">
      <name>Split-it-right sample divider</name>
      <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
      </figure>
        <figure id="Anote21">
      <name>Split-it-right sample divider</name>
      <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
      </figure>
      </figure>
          </references></bibliography>
        </iso-standard>
    INPUT
    output = <<~OUTPUT
        <foreword id="fwd" displayorder="1">
           <title id="_">Foreword</title>
           <fmt-title id="_" depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N">
                    <span class="citefig">
                       <span class="fmt-element-name">Figure</span>
                       <semx element="autonum" source="N">1</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="note1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note1">
                    <span class="citefig">
                       <span class="fmt-element-name">Figure</span>
                       <semx element="autonum" source="N">1</semx>
                       <span class="fmt-autonum-delim"> </span>
                       <semx element="autonum" source="note1">a</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="note2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note2">
                    <span class="citefig">
                       <span class="fmt-element-name">Figure</span>
                       <semx element="autonum" source="N">1</semx>
                       <span class="fmt-autonum-delim"> </span>
                       <semx element="autonum" source="note2">b</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="AN" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN">
                    <span class="citefig">
                       <span class="fmt-element-name">Figure</span>
                       <semx element="autonum" source="annex1">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="AN">1</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="Anote1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote1">
                    <span class="citefig">
                       <span class="fmt-element-name">Figure</span>
                       <semx element="autonum" source="annex1">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="AN">1</semx>
                       <span class="fmt-autonum-delim"> </span>
                       <semx element="autonum" source="Anote1">a</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="Anote2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote2">
                    <span class="citefig">
                       <span class="fmt-element-name">Figure</span>
                       <semx element="autonum" source="annex1">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="AN">1</semx>
                       <span class="fmt-autonum-delim"> </span>
                       <semx element="autonum" source="Anote2">b</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="AN1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN1">
                    <span class="citefig">
                       <span class="fmt-xref-container">
                          <semx element="references" source="biblio">Bibliographical Section</semx>
                       </span>
                       <span class="fmt-comma">,</span>
                       <span class="fmt-element-name">Figure</span>
                       <semx element="autonum" source="AN1">1</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="Anote11" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote11">
                    <span class="citefig">
                       <span class="fmt-xref-container">
                          <semx element="references" source="biblio">Bibliographical Section</semx>
                       </span>
                       <span class="fmt-comma">,</span>
                       <span class="fmt-element-name">Figure</span>
                       <semx element="autonum" source="AN1">1</semx>
                       <span class="fmt-autonum-delim"> </span>
                       <semx element="autonum" source="Anote11">a</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="Anote21" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote21">
                    <span class="citefig">
                       <span class="fmt-xref-container">
                          <semx element="references" source="biblio">Bibliographical Section</semx>
                       </span>
                       <span class="fmt-comma">,</span>
                       <span class="fmt-element-name">Figure</span>
                       <semx element="autonum" source="AN1">1</semx>
                       <span class="fmt-autonum-delim"> </span>
                       <semx element="autonum" source="Anote21">b</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </span>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Nokogiri.XML(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
    output = <<~OUTPUT
        <foreword id="fwd" displayorder="1">
           <title id="_">まえがき</title>
           <fmt-title id="_" depth="1">
              <semx element="title" source="_">まえがき</semx>
           </fmt-title>
           <p>
              <xref target="N" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N">
                    <span class="citefig">
                       <span class="fmt-element-name">図</span>
                       <semx element="autonum" source="N">1</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="note1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note1">
                    <span class="citefig">
                       <span class="fmt-element-name">図</span>
                       <semx element="autonum" source="N">1</semx>
                       <span class="fmt-autonum-delim">の</span>
                       <semx element="autonum" source="note1">a</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="note2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note2">
                    <span class="citefig">
                       <span class="fmt-element-name">図</span>
                       <semx element="autonum" source="N">1</semx>
                       <span class="fmt-autonum-delim">の</span>
                       <semx element="autonum" source="note2">b</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="AN" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN">
                    <span class="citefig">
                       <span class="fmt-element-name">図</span>
                       <semx element="autonum" source="annex1">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="AN">1</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="Anote1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote1">
                    <span class="citefig">
                       <span class="fmt-element-name">図</span>
                       <semx element="autonum" source="annex1">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="AN">1</semx>
                       <span class="fmt-autonum-delim">の</span>
                       <semx element="autonum" source="Anote1">a</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="Anote2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote2">
                    <span class="citefig">
                       <span class="fmt-element-name">図</span>
                       <semx element="autonum" source="annex1">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="AN">1</semx>
                       <span class="fmt-autonum-delim">の</span>
                       <semx element="autonum" source="Anote2">b</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="AN1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN1">
                    <span class="citefig">
                       <span class="fmt-xref-container">
                          <semx element="references" source="biblio">Bibliographical Section</semx>
                       </span>
                       <span class="fmt-conn">の</span>
                       <span class="fmt-element-name">図</span>
                       <semx element="autonum" source="AN1">1</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="Anote11" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote11">
                    <span class="citefig">
                       <span class="fmt-xref-container">
                          <semx element="references" source="biblio">Bibliographical Section</semx>
                       </span>
                       <span class="fmt-conn">の</span>
                       <span class="fmt-element-name">図</span>
                       <semx element="autonum" source="AN1">1</semx>
                       <span class="fmt-autonum-delim">の</span>
                       <semx element="autonum" source="Anote11">a</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="Anote21" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote21">
                    <span class="citefig">
                       <span class="fmt-xref-container">
                          <semx element="references" source="biblio">Bibliographical Section</semx>
                       </span>
                       <span class="fmt-conn">の</span>
                       <span class="fmt-element-name">図</span>
                       <semx element="autonum" source="AN1">1</semx>
                       <span class="fmt-autonum-delim">の</span>
                       <semx element="autonum" source="Anote21">b</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </span>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Nokogiri.XML(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input.sub(">en<", ">ja<"), true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end

      it "cross-references tabular subfigures" do
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface>
        <foreword id="fwd">
        <p>
        <xref target="N"/>
        <xref target="note1"/>
        <xref target="AN"/>
        <xref target="Anote1"/>
        </p>
        </foreword>
        </preface>
        <sections>
        <clause id="scope" type="scope"><title>Scope</title>
                     <figure id="N">
                <name id="_">Stages of gelatinization</name>
                <table id="T1" plain="true">
                   <colgroup>
                      <col width="25%"/>
                      <col width="75%"/>
                   </colgroup>
                   <tbody>
                      <tr id="_">
                         <td id="_" valign="bottom" align="center">
                            <figure id="note1">
                               <name id="_">Initial stages: No grains are fully gelatinized (ungelatinized starch granules are visible inside the kernels)</name>
                               <image id="_" src="spec/examples/rice_images/rice_image3_1.png" mimetype="image/png" height="auto" width="auto" filename="spec/examples/rice_images/rice_image3_1.png"/>
                            </figure>
                         </td>
                         <td id="_" valign="bottom" align="center">
                            <figure id="AN">
                               <name id="_">Intermediate stages: Some fully gelatinized kernels are visible</name>
                               <image id="_" src="spec/examples/rice_images/rice_image3_2.png" mimetype="image/png" height="auto" width="auto" filename="spec/examples/rice_images/rice_image3_2.png"/>
                            </figure>
                         </td>
                      </tr>
                      <tr id="_">
                         <td id="_" colspan="2" valign="bottom" align="center">
                            <figure id="Anote1">
                               <name id="_">Final stages: All kernels are fully gelatinized</name>
                               <image id="_" src="spec/examples/rice_images/rice_image3_3.png" mimetype="image/png" height="auto" width="auto" filename="spec/examples/rice_images/rice_image3_3.png"/>
                            </figure>
                         </td>
                      </tr>
                   </tbody>
                </table>
             </figure>
      </clause>
      </sections>
        </iso-standard>
    INPUT
presxml = <<~OUTPUT
      <foreword id="fwd" displayorder="1">
          <title id="_">Foreword</title>
          <fmt-title depth="1" id="_">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N">
                   <span class="citefig">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="N">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">
                   <span class="citefig">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="N">1</semx>
                      <span class="fmt-autonum-delim"> </span>
                      <semx element="autonum" source="note1">a</semx>
                      <span class="fmt-autonum-delim">)</span>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="AN" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="AN">
                   <span class="citefig">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="N">1</semx>
                      <span class="fmt-autonum-delim"> </span>
                      <semx element="autonum" source="AN">b</semx>
                      <span class="fmt-autonum-delim">)</span>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="Anote1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote1">
                   <span class="citefig">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="N">1</semx>
                      <span class="fmt-autonum-delim"> </span>
                      <semx element="autonum" source="Anote1">c</semx>
                      <span class="fmt-autonum-delim">)</span>
                   </span>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
OUTPUT
   pres_output = IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
    end


  it "labels and cross-references nested requirements" do
    input = <<~INPUT
              <iso-standard xmlns="http://riboseinc.com/isoxml">
            <bibdata><language>en</language></bibdata>
              <preface>
      <foreword>
      <p>
      <xref target="N1"/>
      <xref target="N2"/>
      <xref target="N"/>
      <xref target="Q1"/>
      <xref target="R1"/>
      <xref target="AN1"/>
      <xref target="AN2"/>
      <xref target="AN"/>
      <xref target="AQ1"/>
      <xref target="AR1"/>
      <xref target="BN1"/>
      <xref target="BN2"/>
      <xref target="BN"/>
      <xref target="BQ1"/>
      <xref target="BR1"/>
      </p>
      </foreword>
      </preface>
      <sections>
      <clause id="xyz"><title>Preparatory</title>
      <permission id="N1" model="default">
      <permission id="N2" model="default">
      <permission id="N" model="default">
      </permission>
      </permission>
      <requirement id="Q1" model="default">
      </requirement>
      <recommendation id="R1" model="default">
      </recommendation>
      </permission>
      </clause>
      </sections>
      <annex id="Axyz"><title>Preparatory</title>
      <permission id="AN1" model="default">
      <permission id="AN2" model="default">
      <permission id="AN" model="default">
      </permission>
      </permission>
      <requirement id="AQ1" model="default">
      </requirement>
      <recommendation id="AR1" model="default">
      </recommendation>
      </permission>
      </annex>
                <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
                <permission id="BN1" model="default">
      <permission id="BN2" model="default">
      <permission id="BN" model="default">
      </permission>
      </permission>
      <requirement id="BQ1" model="default">
      </requirement>
      <recommendation id="BR1" model="default">
      </recommendation>
      </permission>
          </references></bibliography>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
        <foreword id="_" displayorder="1">
           <title id="_">Foreword</title>
           <fmt-title id="_" depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N1">
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="N1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="N2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N2">
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-autonum-delim">-</span>
                    <semx element="autonum" source="N2">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="N" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N">
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-autonum-delim">-</span>
                    <semx element="autonum" source="N2">1</semx>
                    <span class="fmt-autonum-delim">-</span>
                    <semx element="autonum" source="N">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="Q1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Q1">
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-autonum-delim">-</span>
                    <semx element="autonum" source="Q1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="R1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="R1">
                    <span class="fmt-element-name">Recommendation</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-autonum-delim">-</span>
                    <semx element="autonum" source="R1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="AN1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN1">
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="Axyz">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="AN2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN2">
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="Axyz">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN1">1</semx>
                    <span class="fmt-autonum-delim">-</span>
                    <semx element="autonum" source="AN2">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="AN" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN">
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="Axyz">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN1">1</semx>
                    <span class="fmt-autonum-delim">-</span>
                    <semx element="autonum" source="AN2">1</semx>
                    <span class="fmt-autonum-delim">-</span>
                    <semx element="autonum" source="AN">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="AQ1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AQ1">
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="Axyz">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN1">1</semx>
                    <span class="fmt-autonum-delim">-</span>
                    <semx element="autonum" source="AQ1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="AR1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AR1">
                    <span class="fmt-element-name">Recommendation</span>
                    <semx element="autonum" source="Axyz">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN1">1</semx>
                    <span class="fmt-autonum-delim">-</span>
                    <semx element="autonum" source="AR1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="BN1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="BN1">
                    <span class="fmt-xref-container">
                       <semx element="references" source="biblio">Bibliographical Section</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="BN1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="BN2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="BN2">
                    <span class="fmt-xref-container">
                       <semx element="references" source="biblio">Bibliographical Section</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="BN1">1</semx>
                    <span class="fmt-autonum-delim">-</span>
                    <semx element="autonum" source="BN2">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="BN" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="BN">
                    <span class="fmt-xref-container">
                       <semx element="references" source="biblio">Bibliographical Section</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="BN1">1</semx>
                    <span class="fmt-autonum-delim">-</span>
                    <semx element="autonum" source="BN2">1</semx>
                    <span class="fmt-autonum-delim">-</span>
                    <semx element="autonum" source="BN">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="BQ1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="BQ1">
                    <span class="fmt-xref-container">
                       <semx element="references" source="biblio">Bibliographical Section</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="BN1">1</semx>
                    <span class="fmt-autonum-delim">-</span>
                    <semx element="autonum" source="BQ1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="BR1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="BR1">
                    <span class="fmt-xref-container">
                       <semx element="references" source="biblio">Bibliographical Section</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Recommendation</span>
                    <semx element="autonum" source="BN1">1</semx>
                    <span class="fmt-autonum-delim">-</span>
                    <semx element="autonum" source="BR1">1</semx>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Nokogiri.XML(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
    output = <<~OUTPUT
        <foreword id="_" displayorder="1">
           <title id="_">まえがき</title>
           <fmt-title id="_" depth="1">
              <semx element="title" source="_">まえがき</semx>
           </fmt-title>
           <p>
              <xref target="N1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N1">
                    <span class="fmt-element-name">許可</span>
                    <semx element="autonum" source="N1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="N2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N2">
                    <span class="fmt-element-name">許可</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-autonum-delim">の</span>
                    <semx element="autonum" source="N2">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="N" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N">
                    <span class="fmt-element-name">許可</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-autonum-delim">の</span>
                    <semx element="autonum" source="N2">1</semx>
                    <span class="fmt-autonum-delim">の</span>
                    <semx element="autonum" source="N">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="Q1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Q1">
                    <span class="fmt-element-name">要求</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-autonum-delim">の</span>
                    <semx element="autonum" source="Q1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="R1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="R1">
                    <span class="fmt-element-name">推奨</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-autonum-delim">の</span>
                    <semx element="autonum" source="R1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="AN1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN1">
                    <span class="fmt-element-name">許可</span>
                    <semx element="autonum" source="Axyz">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="AN2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN2">
                    <span class="fmt-element-name">許可</span>
                    <semx element="autonum" source="Axyz">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN1">1</semx>
                    <span class="fmt-autonum-delim">の</span>
                    <semx element="autonum" source="AN2">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="AN" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN">
                    <span class="fmt-element-name">許可</span>
                    <semx element="autonum" source="Axyz">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN1">1</semx>
                    <span class="fmt-autonum-delim">の</span>
                    <semx element="autonum" source="AN2">1</semx>
                    <span class="fmt-autonum-delim">の</span>
                    <semx element="autonum" source="AN">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="AQ1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AQ1">
                    <span class="fmt-element-name">要求</span>
                    <semx element="autonum" source="Axyz">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN1">1</semx>
                    <span class="fmt-autonum-delim">の</span>
                    <semx element="autonum" source="AQ1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="AR1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AR1">
                    <span class="fmt-element-name">推奨</span>
                    <semx element="autonum" source="Axyz">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN1">1</semx>
                    <span class="fmt-autonum-delim">の</span>
                    <semx element="autonum" source="AR1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="BN1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="BN1">
                    <span class="fmt-xref-container">
                       <semx element="references" source="biblio">Bibliographical Section</semx>
                    </span>
                    <span class="fmt-conn">の</span>
                    <span class="fmt-element-name">許可</span>
                    <semx element="autonum" source="BN1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="BN2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="BN2">
                    <span class="fmt-xref-container">
                       <semx element="references" source="biblio">Bibliographical Section</semx>
                    </span>
                    <span class="fmt-conn">の</span>
                    <span class="fmt-element-name">許可</span>
                    <semx element="autonum" source="BN1">1</semx>
                    <span class="fmt-autonum-delim">の</span>
                    <semx element="autonum" source="BN2">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="BN" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="BN">
                    <span class="fmt-xref-container">
                       <semx element="references" source="biblio">Bibliographical Section</semx>
                    </span>
                    <span class="fmt-conn">の</span>
                    <span class="fmt-element-name">許可</span>
                    <semx element="autonum" source="BN1">1</semx>
                    <span class="fmt-autonum-delim">の</span>
                    <semx element="autonum" source="BN2">1</semx>
                    <span class="fmt-autonum-delim">の</span>
                    <semx element="autonum" source="BN">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="BQ1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="BQ1">
                    <span class="fmt-xref-container">
                       <semx element="references" source="biblio">Bibliographical Section</semx>
                    </span>
                    <span class="fmt-conn">の</span>
                    <span class="fmt-element-name">要求</span>
                    <semx element="autonum" source="BN1">1</semx>
                    <span class="fmt-autonum-delim">の</span>
                    <semx element="autonum" source="BQ1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="BR1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="BR1">
                    <span class="fmt-xref-container">
                       <semx element="references" source="biblio">Bibliographical Section</semx>
                    </span>
                    <span class="fmt-conn">の</span>
                    <span class="fmt-element-name">推奨</span>
                    <semx element="autonum" source="BN1">1</semx>
                    <span class="fmt-autonum-delim">の</span>
                    <semx element="autonum" source="BR1">1</semx>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Nokogiri.XML(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input.sub(">en<", ">ja<"), true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
