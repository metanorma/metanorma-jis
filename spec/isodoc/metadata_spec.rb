require "spec_helper"
require "nokogiri"

RSpec.describe IsoDoc::JIS::Metadata do
  it "processes IsoXML metadata" do
    c = IsoDoc::JIS::HtmlConvert.new({})
    _ = c.convert_init(<<~"INPUT", "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
    input = <<~INPUT
         <jis-standard type="semantic" version="#{Metanorma::JIS::VERSION}" xmlns="https://www.metanorma.org/ns/jis">
              <bibdata type="standard">
          <title language="en" format="text/plain" type="main">Introduction — Main Title — Title — Title Part</title>
          <title language="en" format="text/plain" type="title-intro">Introduction</title>
          <title language="en" format="text/plain" type="title-main">Main Title — Title</title>
          <title language="en" format="text/plain" type="title-part">Title Part</title>
          <title language="ja" format="text/plain" type="main">Introduction Française — Titre Principal — Part du Titre</title>
          <title language="ja" format="text/plain" type="title-intro">Introduction Française</title>
          <title language="ja" format="text/plain" type="title-main">Titre Principal</title>
          <title language="ja" format="text/plain" type="title-part">Part du Titre</title>
          <docidentifier type="ISO">ISO/WD 1000-1.3</docidentifier>
          <docidentifier type="iso-reference">ISO/WD 1000-1.3:2000()</docidentifier>
          <docidentifier type="URN">urn:iso:std:iso:1000:-1:stage-20.20.v3:ja</docidentifier>
          <docidentifier type="iso-undated">ISO/WD 1000-1.3</docidentifier>
          <docidentifier type="iso-with-lang">ISO/WD 1000-1.3(ja)</docidentifier>
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
          <language>ja</language>
          <script>Jpan</script>
          <status>
            <stage abbreviation="WD">20</stage>
            <substage>20</substage>
            <iteration>3</iteration>
          </status>
          <copyright>
            <from>2000</from>
            <owner>
              <organization>
                <name>Japanese Industrial Standards</name>
                <abbreviation>JIS</abbreviation>
              </organization>
            </owner>
          </copyright>
          <ext>
            <doctype>standard</doctype>
            <horizontal>true</horizontal>
            <editorialgroup>
              <agency>JIS</agency>
              <technical-committee number="1" type="A">TC</technical-committee>
              <technical-committee number="11" type="A1">TC1</technical-committee>
              <subcommittee number="2" type="B">SC</subcommittee>
              <subcommittee number="21" type="B1">SC1</subcommittee>
              <workgroup number="3" type="C">WG</workgroup>
              <workgroup number="31" type="C1">WG1</workgroup>
              <secretariat>SECRETARIAT</secretariat>
            </editorialgroup>
            <approvalgroup>
              <agency>ISO</agency>
              <agency>IEC</agency>
              <technical-committee number="1a" type="Aa">TCa</technical-committee>
              <technical-committee number="11a" type="A1a">TC1a</technical-committee>
              <subcommittee number="2a" type="Ba">SCa</subcommittee>
              <subcommittee number="21a" type="B1a">SC1a</subcommittee>
              <workgroup number="3a" type="Ca">WGa</workgroup>
              <workgroup number="31a" type="C1a">WG1a</workgroup>
            </approvalgroup>
            <structuredidentifier>
              <project-number part="1">JIS 1000</project-number>
            </structuredidentifier>
            <stagename abbreviation="WD">Working Draft International Standard</stagename>
          </ext>
        </bibdata>
        <sections> </sections>
      </jis-standard>
    INPUT
    output = <<~OUTPUT
      {:agency=>"JIS",
      :docnumber=>"ISO/WD 1000-1.3",
      :docnumber_lang=>"ISO/WD 1000-1.3(ja)",
      :docnumber_reference=>"ISO/WD 1000-1.3:2000()",
      :docnumber_undated=>"ISO/WD 1000-1.3",
      :docnumeric=>"1000",
      :docsubtitle=>"Introduction Fran&#xe7;aise&#xa0;&#x2014; Titre Principal&#xa0;&#x2014; &#xa0;1: Part du Titre",
      :docsubtitleintro=>"Introduction Fran&#xe7;aise",
      :docsubtitlemain=>"Titre Principal",
      :docsubtitlepart=>"Part du Titre",
      :docsubtitlepartlabel=>"その&#xa0;1",
      :doctitle=>"Introduction&#xa0;&#x2014; Main Title&#x2009;&#x2014;&#x2009;Title&#xa0;&#x2014; Part&#xa0;1: Title Part",
      :doctitleintro=>"Introduction",
      :doctitlemain=>"Main Title&#x2009;&#x2014;&#x2009;Title",
      :doctitlepart=>"Title Part",
      :doctitlepartlabel=>"Part&#xa0;1",
      :doctype=>"Standard",
      :doctype_display=>"Standard",
      :docyear=>"2000",
      :draft=>"0.3.4",
      :draftinfo=>" (draft 0.3.4, 2000-01-01)",
      :edition=>"2",
      :horizontal=>"true",
      :lang=>"en",
      :publisher=>"Japanese Industrial Standards",
      :revdate=>"2000-01-01",
      :revdate_monthyear=>"January 2000",
      :sc=>"B 2",
      :script=>"Latn",
      :secretariat=>"SECRETARIAT",
      :stage=>"20",
      :stage_int=>20,
      :stageabbr=>"WD",
      :statusabbr=>"PreWD3",
      :substage_int=>"20",
      :tc=>"A 1",
      :unpublished=>true,
      :wg=>"C 3"}
    OUTPUT
    expect(metadata(c.info(Nokogiri::XML(input),
                           nil))).to be_equivalent_to output
  end
end
