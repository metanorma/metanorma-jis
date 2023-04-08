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
end
