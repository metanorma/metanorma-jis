require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.default_cassette_options = {
    clean_outdated_http_interactions: true,
    re_record_interval: 1512000,
    record: :once,
  }
end

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "bundler/setup"
require "asciidoctor"
require "metanorma-jis"
require "rspec/matchers"
require "equivalent-xml"
require "metanorma"
require "metanorma/jis"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def metadata(xml)
  xml.sort.to_h.delete_if do |_k, v|
    v.nil? || (v.respond_to?(:empty?) && v.empty?)
  end
end

def strip_guid(xml)
  xml.gsub(%r{ id="_[^"]+"}, ' id="_"')
    .gsub(%r{ target="_[^"]+"}, ' target="_"')
    .gsub(%r( href="#_?[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"), ' href="#_"')
    .gsub(%r( id="[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{13}"), ' id="_"')
    .gsub(%r( id="ftn[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{13}"), ' id="ftn_"')
    .gsub(%r( id="fn:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{13}"), ' id="fn:_"')
    .gsub(%r[ src="([^/]+)/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.], ' src="\\1/_.')
end

def xmlpp(xml)
  c = HTMLEntities.new
  xml &&= xml.split(/(&\S+?;)/).map do |n|
    if /^&\S+?;$/.match?(n)
      c.encode(c.decode(n), :hexadecimal)
    else n
    end
  end.join
  xsl = <<~XSL
    <!--
        <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
          <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
          <xsl:strip-space elements="*"/>
          <xsl:template match="/">
            <xsl:copy-of select="."/>
          </xsl:template>
        </xsl:stylesheet>
    -->
      <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" encoding="ISO-8859-1"/>
      <xsl:param name="indent-increment" select="'  '"/>

      <xsl:template name="newline">
        <xsl:text disable-output-escaping="yes">
    </xsl:text>
      </xsl:template>

      <xsl:template match="comment() | processing-instruction()">
        <xsl:param name="indent" select="''"/>
        <xsl:call-template name="newline"/>
        <xsl:value-of select="$indent"/>
        <xsl:copy />
      </xsl:template>

      <xsl:template match="text()">
        <xsl:param name="indent" select="''"/>
        <xsl:call-template name="newline"/>
        <xsl:value-of select="$indent"/>
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:template>

      <xsl:template match="text()[normalize-space(.)='']"/>

      <xsl:template match="*">
        <xsl:param name="indent" select="''"/>
        <xsl:call-template name="newline"/>
        <xsl:value-of select="$indent"/>
          <xsl:choose>
           <xsl:when test="count(child::*) > 0">
            <xsl:copy>
             <xsl:copy-of select="@*"/>
             <xsl:apply-templates select="*|text()">
               <xsl:with-param name="indent" select="concat ($indent, $indent-increment)"/>
             </xsl:apply-templates>
             <xsl:call-template name="newline"/>
             <xsl:value-of select="$indent"/>
            </xsl:copy>
           </xsl:when>
           <xsl:otherwise>
            <xsl:copy-of select="."/>
           </xsl:otherwise>
         </xsl:choose>
      </xsl:template>
    </xsl:stylesheet>
  XSL
  Nokogiri::XSLT(xsl).transform(Nokogiri::XML(xml, &:noblanks))
    .to_xml(indent: 2, encoding: "UTF-8")
    .gsub(%r{<fetched>[^<]+</fetched>}, "<fetched/>")
    .gsub(%r{ schema-version="[^"]+"}, "")
end

ASCIIDOC_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :no-isobib:
  :docnumber: 0

HDR

ISOBIB_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :no-isobib-cache:
  :docnumber: 0

HDR

FLUSH_CACHE_ISOBIB_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :flush-caches:
  :docnumber: 0

HDR

CACHED_ISOBIB_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :docnumber: 0

HDR

LOCAL_CACHED_ISOBIB_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :local-cache:
  :docnumber: 0

HDR

VALIDATING_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :docnumber: 0

HDR

def middle_title(word, number = "", year = "")
<<~HDR
  <p class="JapaneseIndustrialStandard">
    日本工業規格#{word ? '<span style="mso-tab-count:7">  </span>' : " "}<span class="JIS">JIS</span>
  </p>
  <p class="StandardNumber">
    #{word ? '<span style="mso-tab-count:1">  </span>' : " "} #{number}:
    <span class="EffectiveYear">#{year}</span>
  </p>
  <p class="IDT"/>
               <p class="zzSTDTitle1"/>
      <p class="zzSTDTitle2"/>
HDR
end

TERMS_BOILERPLATE = "".freeze

def boilerplate(xmldoc)
  file = File.read(
    File.join(File.dirname(__FILE__), "..", "lib",
              "metanorma", "jsi", "jsi_intro_jp.xml"), encoding: "utf-8"
  )
  conv = Metanorma::JIS::Converter
    .new(nil, backend: :jis, header_footer: true)
  conv.init(Asciidoctor::Document.new([]))
  ret = Nokogiri::XML(
    conv.boilerplate_isodoc(xmldoc).populate_template(file, nil)
    .gsub(/<p>/, "<p id='_'>")
    .gsub(/<p align="left">/, "<p align='left' id='_'>")
    .gsub(/<ol>/, "<ol id='_' type='alphabet'>")
    .gsub(/<ul>/, "<ul id='_'>"),
  )
  conv.smartquotes_cleanup(ret)
  HTMLEntities.new.decode(ret.to_xml)
end

BLANK_HDR = <<~"HDR".freeze
  <?xml version="1.0" encoding="UTF-8"?>
  <jis-standard xmlns="https://www.metanorma.org/ns/jis" type="semantic" version="#{Metanorma::JIS::VERSION}">
  <bibdata type="standard">
      <docidentifier type="JIS">0:2023</docidentifier>
    <docnumber>0</docnumber>
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
    <language>ja</language>
    <script>Jpan</script>
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
      <doctype>japanese-industrial-standard</doctype>
    <editorialgroup>
      <agency>JIS</agency>
    </editorialgroup>
          <approvalgroup>
        <agency>ISO</agency>
      </approvalgroup>
           <structuredidentifier>
       <project-number>0</project-number>
     </structuredidentifier>
    </ext>
  </bibdata>
  <metanorma-extension>
      <presentation-metadata>
      <name>TOC Heading Levels</name>
      <value>3</value>
    </presentation-metadata>
    <presentation-metadata>
      <name>HTML TOC Heading Levels</name>
      <value>2</value>
    </presentation-metadata>
    <presentation-metadata>
      <name>DOC TOC Heading Levels</name>
      <value>3</value>
    </presentation-metadata>
  </metanorma-extension>
HDR

def blank_hdr_gen
  <<~"HDR"
    #{BLANK_HDR}
    #{boilerplate(Nokogiri::XML("#{BLANK_HDR}</bsi-standard>"))}
  HDR
end

HTML_HDR = <<~HDR.freeze
  <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
    <head/>
    <body lang="en">
      <div class="title-section">
        <p>&#160;</p>
      </div>
      <br/>
      <div class="prefatory-section">
        <p>&#160;</p>
      </div>
      <br/>
      <div class="main-section">
HDR

OPTIONS = [backend: :jis, header_footer: true].freeze

def presxml_options
  { semanticxmlinsert: "false" }
end

def mock_pdf
  allow(Mn2pdf).to receive(:convert) do |url, output, _c, _d|
    FileUtils.cp(url.gsub(/"/, ""), output.gsub(/"/, ""))
  end
end

private

def get_xml(search, code, opts)
  c = code.gsub(%r{[/\s:-]}, "_").sub(%r{_+$}, "").downcase
  o = opts.keys.join "_"
  file = "spec/examples/#{[c, o].join '_'}.xml"
  if File.exist? file
    File.read file
  else
    result = search.call(code)
    hit = result&.first&.first
    xml = hit.to_xml nil, opts
    File.write file, xml
    xml
  end
end
