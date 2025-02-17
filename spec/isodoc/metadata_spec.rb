require "spec_helper"
require "nokogiri"

RSpec.describe IsoDoc::Jis::Metadata do
  it "processes IsoXML metadata" do
    c = IsoDoc::Jis::HtmlConvert.new({})
    _ = c.convert_init(<<~"INPUT", "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
    input = <<~INPUT
         <jis-standard type="semantic" version="#{Metanorma::Jis::VERSION}" xmlns="https://www.metanorma.org/ns/jis">
              <bibdata type="standard">
          <title language="en" format="text/plain" type="main">Introduction — Main Title — Title — Title Part</title>
          <title language="en" format="text/plain" type="title-intro">Introduction</title>
          <title language="en" format="text/plain" type="title-main">Main Title — Title</title>
          <title language="en" format="text/plain" type="title-part">Title Part</title>
          <title language="ja" format="text/plain" type="main">Introduction Française — Titre Principal — Part du Titre</title>
          <title language="ja" format="text/plain" type="title-intro">Introduction Française</title>
          <title language="ja" format="text/plain" type="title-main">Titre Principal</title>
          <title language="ja" format="text/plain" type="title-part">Part du Titre</title>
          <docidentifier type="JIS">1000-1.3:2000</docidentifier>
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
          <contributor>
             <role type="authorizer">
               <description>Investigative organization</description>
             </role>
             <organization>
                 <name language="ja">日本産業標準調査会</name>
                 <name language="en">Japanese Industrial Standards Committee</name>
             </organization>
           </contributor>
                      <contributor>
             <role type="authorizer">
               <description>Investigative committee</description>
             </role>
             <person>
               <name>
                 <completename>KUROSAWA Akira</completename>
               </name>
               <affiliation>
                 <organization>
                   <name>Committee 123</name>
                 </organization>
               </affiliation>
             </person>
           </contributor>
           <contributor>
             <role type="authorizer">
               <description>Investigative committee</description>
             </role>
             <person>
               <name>
                 <completename>MIFUNE Toshiro</completename>
               </name>
               <affiliation>
                 <name>委員会長</name>
                 <name>lead actor</name>
                 <organization>
                   <name>Committee 123</name>
                 </organization>
               </affiliation>
             </person>
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
    output = #<<~OUTPUT
      {:agency=>"JIS",
      :docnumber=>"1000-1.3:2000",
      :docnumber_undated=>"1000-1.3",
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
      :"investigative-committee"=>"Committee 123",
      :"investigative-committee-representative-name"=>"KUROSAWA Akira",
      :"investigative-committee-representative-role"=>"chairperson",
      :"investigative-organization"=>"Japanese Industrial Standards Committee",
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
    #OUTPUT
    expect(metadata(c.info(Nokogiri::XML(input),
                           nil))).to be_equivalent_to output
  end
end
