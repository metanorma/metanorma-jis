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
          <title language="en" type="title-part-prefix">Part 1</title>
          <title language="ja" type="title-part-prefix">その 1</title>
          <docidentifier type="JIS">1000-1.3:2000</docidentifier>
          <docnumber>1000</docnumber>
          <date type="created">1900-01-02</date>
          <date type="published">Doomsday</date>
          <contributor>
            <role type="author"/>
            <organization>
              <name>Japanese Industrial Standards</name>
              <abbreviation>JIS</abbreviation>
            </organization>
          </contributor>
                    <contributor>
             <role type="author">
                <description>committee</description>
             </role>
             <organization>
                <name>International Electrotechnical Commission</name>
                <subdivision type="Technical committee" subtype="TC">
                   <name>Electrical equipment in medical practice</name>
                   <identifier>TC 62</identifier>
                   <identifier type="full">IEC TC 62</identifier>
                </subdivision>
                <abbreviation>IEC</abbreviation>
             </organization>
          </contributor>
          <contributor>
             <role type="author">
                <description>committee</description>
             </role>
             <organization>
                <name>International Organization for Standardization</name>
                <subdivision type="Technical committee" subtype="TC">
                   <name>Quality management and corresponding general aspects for medical devices</name>
                   <identifier>TC 210</identifier>
                   <identifier type="full">TC 210/SC 62A/WG 62A1</identifier>
                </subdivision>
                <subdivision type="Subcommittee" subtype="SC">
                   <name>Common aspects of electrical equipment used in medical practice</name>
                   <identifier>SC 62A</identifier>
                </subdivision>
                <subdivision type="Workgroup" subtype="WG">
                   <name>Working group on defibulators</name>
                   <identifier>WG 62A1</identifier>
                </subdivision>
                <abbreviation>ISO</abbreviation>
             </organization>
          </contributor>
          <contributor>
             <role type="author">
                <description>committee</description>
             </role>
             <organization>
                <name>Institute of Electrical and Electronic Engineers</name>
                <subdivision type="Technical committee" subtype="TC">
                   <name>The committee</name>
                </subdivision>
                <abbreviation>IEEE</abbreviation>
             </organization>
          </contributor>
             <contributor>
      <role type="author">
         <description>secretariat</description>
      </role>
      <organization>
         <name>International Organization for Standardization</name>
         <subdivision type="Secretariat">
            <name>GB</name>
         </subdivision>
         <abbreviation>ISO</abbreviation>
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
        <metanorma-extension>
        <semantic-metadata>
        <stage-published>false</stage-published>
        </semantic-metadata>
        </metanorma-extension>
        <sections> </sections>
      </jis-standard>
    INPUT
    output =
      { agency: "JIS",
        authorizer: ["Japanese Industrial Standards Committee"],
        createddate: "1900-01-02",
        docnumber: "1000-1.3:2000",
        docnumber_undated: "1000-1.3",
        docnumeric: "1000",
        docsubtitle: "Introduction Française&#xa0;&#x2014; Titre Principal&#xa0;&#x2014; その 1： Part du Titre",
        docsubtitleintro: "Introduction Fran&#xe7;aise",
        docsubtitlemain: "Titre Principal",
        docsubtitlepart: "Part du Titre",
        docsubtitlepartlabel: "その&#xa0;1",
        doctitle: "Introduction&#xa0;&#x2014; Main Title — Title&#xa0;&#x2014; Part 1: Title Part",
        doctitleintro: "Introduction",
        doctitlemain: "Main Title&#x2009;&#x2014;&#x2009;Title",
        doctitlepart: "Title Part",
        doctitlepartlabel: "Part&#xa0;1",
        doctype: "Standard",
        doctype_display: "Standard",
        docyear: "2000",
        draft: "0.3.4",
        draftinfo: " (draft 0.3.4, 2000-01-01)",
        edition: "2",
        editorialgroup: "IEC TC 62 and TC 210/SC 62A/WG 62A1",
        horizontal: "true",
        "investigative-committee": "Committee 123",
        "investigative-committee-representative-name": "KUROSAWA Akira",
        "investigative-committee-representative-role": "chairperson",
        "investigative-organization": "Japanese Industrial Standards Committee",
        lang: "en",
        publisheddate: "Doomsday",
        publisher: "Japanese Industrial Standards",
        revdate: "2000-01-01",
        revdate_monthyear: "January 2000",
        sc: "SC 62A",
        script: "Latn",
        secretariat: "GB",
        stage: "20",
        stage_int: 20,
        stageabbr: "WD",
        statusabbr: "PreWD3",
        substage_int: "20",
        tc: "TC 62",
        unpublished: true,
        wg: "WG 62A1" }
    expect(metadata(c.info(Nokogiri::XML(input),
                           nil))).to be_equivalent_to output
    c = IsoDoc::Jis::HtmlConvert.new({})
    _ = c.convert_init(<<~"INPUT", "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
       <bibdata>
          <language>ja</language>
        </bibdata>
      </iso-standard>
    INPUT
    output =
      { agency: "JIS",
        authorizer: ["日本産業標準調査会"],
        createddate: "明治三十三年1月2日",
        docnumber: "1000-1.3:2000",
        docnumber_undated: "1000-1.3",
        docnumeric: "1000",
        docsubtitle: "Introduction&#xa0;&#x2014; Main Title — Title&#xa0;&#x2014; Part 1: Title Part",
        docsubtitleintro: "Introduction",
        docsubtitlemain: "Main Title&#x2009;&#x2014;&#x2009;Title",
        docsubtitlepart: "Title Part",
        docsubtitlepartlabel: "Part&#xa0;1",
        doctitle: "Introduction Française&#xa0;&#x2014; Titre Principal&#xa0;&#x2014; その 1： Part du Titre",
        doctitleintro: "Introduction Fran&#xE7;aise",
        doctitlemain: "Titre Principal",
        doctitlepart: "Part du Titre",
        doctitlepartlabel: "その&#xa0;1",
        doctype: "Standard",
        doctype_display: "Standard",
        docyear: "2000",
        draft: "0.3.4",
        draftinfo: " （案 0.3.4、平成十二年1月1日）",
        edition: "2",
        editorialgroup: "IEC TC 62 及び TC 210/SC 62A/WG 62A1",
        horizontal: "true",
        "investigative-committee": "Committee 123",
        "investigative-committee-representative-name": "KUROSAWA Akira",
        "investigative-committee-representative-role": "&#x59d4;&#x54e1;&#x4f1a;&#x9577;",
        "investigative-organization": "&#x65e5;&#x672c;&#x7523;&#x696d;&#x6a19;&#x6e96;&#x8abf;&#x67fb;&#x4f1a;",
        lang: "ja",
        publisheddate: "Doomsday",
        publisher: "Japanese Industrial Standards",
        revdate: "平成十二年1月1日",
        revdate_monthyear: "1月 2000",
        sc: "SC 62A",
        script: "Jpan",
        secretariat: "GB",
        stage: "20",
        stage_int: 20,
        stageabbr: "WD",
        statusabbr: "PreWD3",
        substage_int: "20",
        tc: "TC 62",
        unpublished: true,
        wg: "WG 62A1" }
    expect(metadata(c.info(Nokogiri::XML(input),
                           nil))).to be_equivalent_to output
  end
end
