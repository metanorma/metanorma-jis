require "spec_helper"
require "nokogiri"

RSpec.describe IsoDoc::JIS::Metadata do
  it "processes IsoXML metadata" do
    c = IsoDoc::Iso::HtmlConvert.new({})
    _ = c.convert_init(<<~"INPUT", "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata type="standard">
          <title format="text/plain" language="en" type="title-intro">Cereals and pulses</title>
          <title format="text/plain" language="en" type="title-main">Specifications and test methods</title>
          <title format="text/plain" language="en" type="title-part">Rice</title>
          <title format="text/plain" language="fr" type="title-intro">Céréales et légumineuses</title>
          <title format="text/plain" language="fr" type="title-main">Spécification et méthodes d'essai</title>
          <title format="text/plain" language="fr" type="title-part">Riz</title>
          <docidentifier type="ISO">ISO/PreCD3 17301-1</docidentifier>
          <docidentifier type="iso-with-lang">ISO/PreCD3 17301-1 (E)</docidentifier>
          <docidentifier type="iso-reference">ISO/PreCD3 17301-1:2000 (E)</docidentifier>
          <docidentifier type="iso-tc">17301</docidentifier>
          <docidentifier type="iso-tc">17302</docidentifier>
          <docnumber>1730</docnumber>
          <date type="published">
            <on>2011</on>
          </date>
          <date type="accessed">
            <on>2012</on>
          </date>
          <date type="created">
            <from>2010</from>
            <to>2011</to>
          </date>
          <date type="activated">
            <on>2013</on>
          </date>
          <date type="obsoleted">
            <on>2014</on>
          </date>
          <edition>2</edition>
          <version>
            <revision-date>2016-05-01</revision-date>
            <draft>0.4</draft>
          </version>
          <contributor>
            <role type="author"/>
            <organization>
              <abbreviation>ISO</abbreviation>
            </organization>
          </contributor>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </contributor>
          <language>en</language>
          <script>Latn</script>
          <status>
            <stage abbreviation="CD">30</stage>
            <substage>92</substage>
            <iteration>3</iteration>
          </status>
          <copyright>
            <from>2016</from>
            <owner>
              <organization>
                <abbreviation>ISO</abbreviation>
              </organization>
            </owner>
          </copyright>
          <keyword>kw2</keyword>
          <keyword>kw1</keyword>
          <ext>
            <doctype>international-standard</doctype>
            <horizontal>true</horizontal>
            <editorialgroup identifier="DEF">
              <technical-committee number="34">Food products</technical-committee>
              <subcommittee number="4">Cereals and pulses</subcommittee>
              <workgroup number="3">Rice Group</workgroup>
              <secretariat>GB</secretariat>
            </editorialgroup>
            <approvalgroup identifier="ABC">
              <technical-committee number="34a">Food products A</technical-committee>
              <subcommittee number="4a">Cereals and pulses A</subcommittee>
              <workgroup number="3a">Rice Group A</workgroup>
            </approvalgroup>
            <structuredidentifier>
              <project-number part="1">ISO/PreCD3 17301</project-number>
            </structuredidentifier>
            <stagename>Committee draft</stagename>
          </ext>
        </bibdata>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      {:accesseddate=>"2012",
      :activateddate=>"2013",
      :agency=>"ISO",
      :approvalgroup=>"ABC",
      :createddate=>"2010&#x2013;2011",
      :docnumber=>"ISO/PreCD3 17301-1",
      :docnumber_lang=>"ISO/PreCD3 17301-1 (E)",
      :docnumber_reference=>"ISO/PreCD3 17301-1:2000 (E)",
      :docnumeric=>"1730",
      :docsubtitle=>"C&#xe9;r&#xe9;ales et l&#xe9;gumineuses&#xa0;&#x2014; Sp&#xe9;cification et m&#xe9;thodes d&#x27;essai&#xa0;&#x2014; Partie&#xa0;1: Riz",
      :docsubtitleintro=>"C&#xe9;r&#xe9;ales et l&#xe9;gumineuses",
      :docsubtitlemain=>"Sp&#xe9;cification et m&#xe9;thodes d&#x27;essai",
      :docsubtitlepart=>"Riz",
      :docsubtitlepartlabel=>"Partie&#xa0;1",
      :doctitle=>"Cereals and pulses&#xa0;&#x2014; Specifications and test methods&#xa0;&#x2014; Part&#xa0;1: Rice",
      :doctitleintro=>"Cereals and pulses",
      :doctitlemain=>"Specifications and test methods",
      :doctitlepart=>"Rice",
      :doctitlepartlabel=>"Part&#xa0;1",
      :doctype=>"International Standard",
      :doctype_display=>"International Standard",
      :docyear=>"2016",
      :draft=>"0.4",
      :draftinfo=>" (draft 0.4, 2016-05-01)",
      :edition=>"2",
      :editorialgroup=>"DEF",
      :horizontal=>"true",
      :keywords=>["kw2", "kw1"],
      :lang=>"en",
      :obsoleteddate=>"2014",
      :publisheddate=>"2011",
      :publisher=>"International Organization for Standardization",
      :revdate=>"2016-05-01",
      :revdate_monthyear=>"May 2016",
      :sc=>"SC 4",
      :script=>"Latn",
      :secretariat=>"GB",
      :stage=>"30",
      :stage_int=>30,
      :stageabbr=>"CD",
      :statusabbr=>"PreCD3",
      :substage_int=>"92",
      :tc=>"TC 34",
      :tc_docnumber=>["17301", "17302"],
      :unpublished=>true,
      :wg=>"WG 3"}
    OUTPUT
    expect(metadata(c.info(Nokogiri::XML(input),
                           nil))).to be_equivalent_to output
  end
end
