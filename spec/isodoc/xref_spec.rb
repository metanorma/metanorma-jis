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
    expect(Xml::C14n.format(Nokogiri.XML(IsoDoc::JIS::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to Xml::C14n.format(output)
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
          <xref target="Q">Clause 1, List  1 a) 1)</xref>
          <xref target="R">Clause 1, List  1 a) 1.1)</xref>
          <xref target="S">Clause 1, List  1 a) 1.1.1)</xref>
          <xref target="P1">Clause 1, List  2 a)</xref>
        </p>
      </foreword>
    OUTPUT
    expect(Xml::C14n.format(Nokogiri.XML(IsoDoc::JIS::PresentationXMLConvert
       .new(presxml_options)
       .convert("test", input, true))
       .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to Xml::C14n.format(output)

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
           <xref target="Q">箇条 1のリスト  1のa)の1)</xref>
           <xref target="R">箇条 1のリスト  1のa)の1.1)</xref>
           <xref target="S">箇条 1のリスト  1のa)の1.1.1)</xref>
           <xref target="P1">箇条 1のリスト  2のa)</xref>
         </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(Nokogiri.XML(IsoDoc::JIS::PresentationXMLConvert
       .new(presxml_options)
       .convert("test", input, true))
       .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to Xml::C14n.format(output)
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
      <foreword obligation="informative" displayorder="1">
         <title>Foreword</title>
         <p id="A">
           This is a preamble
            <xref target="P">Annex A, Note</xref>
            <xref target="Q">A.1, Note</xref>
            <xref target="R">Commentary, Note</xref>
            <xref target="S">Commentary, Clause 1, Note</xref>
               <xref target="T">
            <span class="citetbl">Commentary, Table 1</span>
          </xref>
          <xref target="U">
            <span class="citetbl">Commentary, Clause 1, Table 2</span>
          </xref>
         </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(Nokogiri.XML(IsoDoc::JIS::PresentationXMLConvert
       .new(presxml_options)
       .convert("test", input, true))
       .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to Xml::C14n.format(output)
    output = <<~OUTPUT
      <foreword obligation="informative" displayorder="1">
         <title>Foreword</title>
         <p id="A">
           This is a preamble
           <xref target="P">附属書 Aの注記</xref>
           <xref target="Q">A.1の注記</xref>
           <xref target="R">Commentaryの注記</xref>
           <xref target="S">Commentaryの箇条 1の注記</xref>
           <xref target="T">
            <span class="citetbl">Commentaryの表 1</span>
          </xref>
          <xref target="U">
            <span class="citetbl">Commentaryの箇条 1の表 2</span>
          </xref>
         </p>
       </foreword>
    OUTPUT
    input.sub!("<preface>",
               "<bibdata><language>ja</language></bibdata><preface>")
    expect(Xml::C14n.format(Nokogiri.XML(IsoDoc::JIS::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
       .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to Xml::C14n.format(output)
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
         <p>
           <xref target="N">
             <span class="citefig">Figure 1</span>
           </xref>
           <xref target="note1">
             <span class="citefig">Figure 1 a)</span>
           </xref>
           <xref target="note2">
             <span class="citefig">Figure 1 b)</span>
           </xref>
           <xref target="AN">
             <span class="citefig">Figure A.1</span>
           </xref>
           <xref target="Anote1">
             <span class="citefig">Figure A.1 a)</span>
           </xref>
           <xref target="Anote2">
             <span class="citefig">Figure A.1 b)</span>
           </xref>
           <xref target="AN1">
             <span class="citefig">Bibliographical Section, Figure 1</span>
           </xref>
           <xref target="Anote11">
             <span class="citefig">Bibliographical Section, Figure 1 a)</span>
           </xref>
           <xref target="Anote21">
             <span class="citefig">Bibliographical Section, Figure 1 b)</span>
           </xref>
         </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(Nokogiri.XML(IsoDoc::JIS::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to Xml::C14n.format(output)
    output = <<~OUTPUT
       <foreword id="fwd" displayorder="1">
         <p>
           <xref target="N">
             <span class="citefig">図 1</span>
           </xref>
           <xref target="note1">
             <span class="citefig">図 1のa)</span>
           </xref>
           <xref target="note2">
             <span class="citefig">図 1のb)</span>
           </xref>
           <xref target="AN">
             <span class="citefig">図 A.1</span>
           </xref>
           <xref target="Anote1">
             <span class="citefig">図 A.1のa)</span>
           </xref>
           <xref target="Anote2">
             <span class="citefig">図 A.1のb)</span>
           </xref>
           <xref target="AN1">
             <span class="citefig">Bibliographical Sectionの図 1</span>
           </xref>
           <xref target="Anote11">
             <span class="citefig">Bibliographical Sectionの図 1のa)</span>
           </xref>
           <xref target="Anote21">
             <span class="citefig">Bibliographical Sectionの図 1のb)</span>
           </xref>
         </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(Nokogiri.XML(IsoDoc::JIS::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input.sub(">en<", ">ja<"), true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to Xml::C14n.format(output)
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
                <foreword displayorder='1'>
                  <p>
                     <xref target='N1'>Clause 1, Permission 1</xref>
      <xref target='N2'>Clause 1, Permission 1-1</xref>
      <xref target='N'>Clause 1, Permission 1-1-1</xref>
      <xref target='Q1'>Clause 1, Requirement 1-1</xref>
      <xref target='R1'>Clause 1, Recommendation 1-1</xref>
      <xref target='AN1'>Permission A.1</xref>
      <xref target='AN2'>Permission A.1-1</xref>
      <xref target='AN'>Permission A.1-1-1</xref>
      <xref target='AQ1'>Requirement A.1-1</xref>
      <xref target='AR1'>Recommendation A.1-1</xref>
      <xref target="BN1">Bibliographical Section, Permission 1</xref>
      <xref target="BN2">Bibliographical Section, Permission 1-1</xref>
      <xref target="BN">Bibliographical Section, Permission 1-1-1</xref>
      <xref target="BQ1">Bibliographical Section, Requirement 1-1</xref>
      <xref target="BR1">Bibliographical Section, Recommendation 1-1</xref>
                  </p>
                </foreword>
    OUTPUT
    expect(Xml::C14n.format(Nokogiri.XML(IsoDoc::JIS::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to Xml::C14n.format(output)
    output = <<~OUTPUT
      <foreword displayorder="1">
         <p>
           <xref target="N1">箇条 1のPermission 1</xref>
           <xref target="N2">箇条 1のPermission 1の1</xref>
           <xref target="N">箇条 1のPermission 1の1の1</xref>
           <xref target="Q1">箇条 1のRequirement 1の1</xref>
           <xref target="R1">箇条 1のRecommendation 1の1</xref>
           <xref target="AN1">Permission A.1</xref>
           <xref target="AN2">Permission A.1の1</xref>
           <xref target="AN">Permission A.1の1の1</xref>
           <xref target="AQ1">Requirement A.1の1</xref>
           <xref target="AR1">Recommendation A.1の1</xref>
           <xref target="BN1">Bibliographical SectionのPermission 1</xref>
           <xref target="BN2">Bibliographical SectionのPermission 1の1</xref>
           <xref target="BN">Bibliographical SectionのPermission 1の1の1</xref>
           <xref target="BQ1">Bibliographical SectionのRequirement 1の1</xref>
           <xref target="BR1">Bibliographical SectionのRecommendation 1の1</xref>
         </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(Nokogiri.XML(IsoDoc::JIS::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input.sub(">en<", ">ja<"), true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
