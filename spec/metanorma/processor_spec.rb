require "spec_helper"
require "metanorma"
require "fileutils"

RSpec.describe Metanorma::JIS::Processor do
  registry = Metanorma::Registry.instance
  registry.register(Metanorma::JIS::Processor)
  processor = registry.find_processor(:jis)

  inputxml = <<~INPUT
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <bibdata type="standard">
    <title language="en" format="text/plain" type="main">English</title>
    <title language="en" format="text/plain" type="title-main">English</title>
    <title language="fr" format="text/plain" type="main">French</title>
    <title language="fr" format="text/plain" type="title-main">French</title>
    <docidentifier type="JIS">Z 100</docidentifier>
    <docnumber>1</docnumber>
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
    <language>fr</language>
    <script>Latn</script>
    <status>
    <stage>60</stage>
    <substage>60</substage>
    </status>
    <copyright>
    <from>#{Time.new.year}</from>
    <owner>
    <organization>
    <name>Japanese Industrial Standards</name>
    <abbreviation>JIS</abbreviation>
    </organization>
    </owner>
    </copyright>
    <ext>
    <doctype>directive</doctype>
    <subdoctype>vocabulary</subdoctype>
    <editorialgroup>
    <technical-committee/>
    <subcommittee/>
    <workgroup/>
    </editorialgroup>
    <structuredidentifier>
    <project-number>ISO 1</project-number>
    </structuredidentifier>
    <stagename>International standard</stagename>
    </ext>
    </bibdata>
    <boilerplate>
      <copyright-statement>
        <clause>
          <title>DOCUMENT PROT&#201;G&#201; PAR COPYRIGHT</title>
        <p id="boilerplate-year">&#169; ISO 2021</p>

      <p id="boilerplate-message">
    Droits de reproduction r&#233;serv&#233;s. Sauf indication contraire, aucune partie de cette publication ne
    peut &#234;tre reproduite ni utilis&#233;e sous quelque forme que ce soit et par aucun proc&#233;d&#233;, &#233;lectronique
    ou m&#233;canique, y compris la photocopie, l&#8217;affichage sur l&#8217;internet ou sur un Intranet, sans
    autorisation &#233;crite pr&#233;alable. Les demandes d&#8217;autorisation peuvent &#234;tre adress&#233;es &#224; l&#8217;ISO &#224;
    l&#8217;adresse ci-apr&#232;s ou au comit&#233; membre de l&#8217;ISO dans le pays du demandeur.
      </p>

      <p id="boilerplate-address" align="left">
        ISO copyright office<br/>
        Ch. de Blandonnet 8 &#8226; CP 401<br/>
        CH-1214 Vernier, Geneva, Switzerland<br/>
        Phone: +41 22 749 01 11<br/>
        Email: copyright@iso.org<br/>
        Website: www.iso.org
      </p>
        <p id="boilerplate-place">
        Publi&#233; en Suisse
      </p>
    </clause>
      </copyright-statement>


    </boilerplate>
          <sections>
            <terms id="H" obligation="normative"><title>1&#xA0; Terms, Definitions, Symbols and Abbreviated Terms</title>
              <term id="J">
                <name>1.1</name>
                <preferred>Term2</preferred>
              </term>
            </terms>
          </sections>
    </iso-standard>
  INPUT

  it "registers against metanorma" do
    expect(processor).not_to be nil
  end

  it "registers output formats against metanorma" do
    expect(processor.output_formats.sort.to_s).to be_equivalent_to <<~OUTPUT
      [[:doc, "doc"], [:html, "html"], [:pdf, "pdf"], [:presentation, "presentation.xml"], [:rxl, "rxl"], [:xml, "xml"]]
    OUTPUT
  end

  it "registers version against metanorma" do
    expect(processor.version.to_s).to match(%r{^Metanorma::JIS })
  end

  it "generates IsoDoc XML from a blank document" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
    INPUT
    output = <<~OUTPUT
        #{BLANK_HDR}
        <sections/>
      </jis-standard>
    OUTPUT
    expect(xmlpp(processor.input_to_isodoc(input, nil)))
      .to be_equivalent_to xmlpp(output)
  end

  it "converts a blank document" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :docnumber: 0

      == Clause
    INPUT

    output = xmlpp(<<~"OUTPUT")
      #{BLANK_HDR}
      <sections>
          <clause id="_" inline-header="false" obligation="normative">
            <title>Clause</title>
          </clause>
        </sections>
      </ogc-standard>
    OUTPUT

    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.pdf"
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to output
    expect(File.exist?("test.html")).to be true
    expect(File.exist?("test.doc")).to be true
    expect(File.exist?("test.pdf")).to be true
  end

  it "generates HTML from Metanorma XML" do
    FileUtils.rm_f "test.xml"
    FileUtils.rm_f "test.html"
    processor.output(inputxml, "test.xml", "test.html", :html)
    expect(xmlpp(strip_guid(File.read("test.html", encoding: "utf-8")
      .gsub(%r{^.*<main}m, "<main")
      .gsub(%r{</main>.*}m, "</main>"))))
      .to be_equivalent_to xmlpp(<<~OUTPUT)
         <main class="main-section">
           <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
           <div class='authority'> </div>
           #{middle_title(false, "Z 100", Date.today.year)}
          <div id="H">
            <h1 id="_">1  Terms, Definitions, Symbols and Abbreviated Terms</h1>
            <h2 class="TermNum" id="J">1.1</h2>
            <p class="Terms" style="text-align:left;">Term2</p>
          </div>
        </main>
      OUTPUT
  end
end
