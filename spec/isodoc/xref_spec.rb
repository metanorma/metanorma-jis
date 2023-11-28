require "spec_helper"

RSpec.describe IsoDoc::JIS do
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
      <foreword obligation="informative" displayorder="1">
         <title>Foreword</title>
         <p id="A">
           This is a preamble
           <xref target="P">
             <span class="citeapp">Annex A</span>
           </xref>
           <xref target="Q">
             <span class="citeapp">A.1</span>
           </xref>
           <xref target="Q1">
             <span class="citeapp">A.1.1</span>
           </xref>
           <xref target="U">
             <span class="citeapp">Annex B</span>
           </xref>
           <xref target="V">
             <span class="citesec">Commentary</span>
           </xref>
           <xref target="V1">
              <span class="citesec">Commentary, Clause 1</span>
            </xref>
            <xref target="V2">
              <span class="citesec">Commentary, Clause 1.1</span>
            </xref>
           <xref target="R">
             <span class="citesec">Clause 1</span>
           </xref>
           <xref target="S">
             <span class="citesec">Bibliography</span>
           </xref>
         </p>
       </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::JIS::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
      <foreword obligation="informative" displayorder="1">
        <title>Foreword</title>
        <p id="A">
          This is a preamble
          <xref target="P">Clause 1, List  1 a)</xref>
          <xref target="Q">1 List  1 a) 1)</xref>
          <xref target="R">1 List  1 a) 1.1)</xref>
          <xref target="S">1 List  1 a) 1.1.1)</xref>
          <xref target="P1">Clause 1, List  2 a)</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::JIS::PresentationXMLConvert
       .new(presxml_options)
       .convert("test", input, true))
       .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)

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
      <foreword obligation="informative" displayorder="1">
         <title>Foreword</title>
         <p id="A">
           This is a preamble
           <xref target="P">箇条 1のリスト  1のa)</xref>
           <xref target="Q">1 リスト  1のa)の1)</xref>
           <xref target="R">1 リスト  1のa)の1.1)</xref>
           <xref target="S">1 リスト  1のa)の1.1.1)</xref>
           <xref target="P1">箇条 1のリスト  2のa)</xref>
         </p>
       </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::JIS::PresentationXMLConvert
       .new(presxml_options)
       .convert("test", input, true))
       .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
         <clause id="A4">
         <note id="S"/>
         </clause>
       </annex>
       </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword obligation="informative" displayorder="1">
         <title>Foreword</title>
         <p id="A">
           This is a preamble
            <xref target="P">Annex A, Note</xref>
            <xref target="Q">A.1, Note</xref>
            <xref target="R">Commentary, Note</xref>
            <xref target="S">Commentary, Clause 1, Note</xref>
         </p>
       </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::JIS::PresentationXMLConvert
       .new(presxml_options)
       .convert("test", input, true))
       .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
    output = <<~OUTPUT
      <foreword obligation="informative" displayorder="1">
         <title>Foreword</title>
         <p id="A">
           This is a preamble
           <xref target="P">附属書 Aの注記</xref>
           <xref target="Q">A.1の注記</xref>
           <xref target="R">Commentaryの注記</xref>
           <xref target="S">Commentaryの箇条 1の注記</xref>
         </p>
       </foreword>
    OUTPUT
    input.sub!("<preface>",
               "<bibdata><language>ja</language></bibdata><preface>")
    expect(xmlpp(Nokogiri.XML(IsoDoc::JIS::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
       .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end
end
