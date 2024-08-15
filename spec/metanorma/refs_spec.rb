require "spec_helper"
RSpec.describe Metanorma::JIS do
  before do
    # Force to download Relaton index file
    allow_any_instance_of(Relaton::Index::Type).to receive(:actual?)
      .and_return(false)
    allow_any_instance_of(Relaton::Index::FileIO).to receive(:check_file)
      .and_return(nil)
  end

  it "has boilerplate for empty normative references" do
    input = <<~INPUT
      #{ISOBIB_BLANK_HDR}

      [bibliography]
      == Normative references
    INPUT
    xml = Nokogiri::XML(Asciidoctor.convert(input, *OPTIONS))
    expect(Xml::C14n.format(strip_guid(xml.at(
      "//xmlns:references/xmlns:p",
    ).to_xml))).to be_equivalent_to <<~OUTPUT
      <p id="_">この規格には，引用規格はない。</p>
    OUTPUT
  end

  it "has boilerplate for undated normative references" do
    VCR.use_cassette "isobib_123_undated" do
      input = <<~INPUT
        #{ISOBIB_BLANK_HDR}

        [bibliography]
        == Normative references

         * [[[iso123, ISO 123]]] _Standard_
         * [[[iso124, ISO 124]]] _Standard_
         * [[[iso125, ISO 125]]] _Standard_
      INPUT
      xml = Nokogiri::XML(Asciidoctor.convert(input, *OPTIONS))
      expect(Xml::C14n.format(strip_guid(xml.at(
        "//xmlns:references/xmlns:p",
      ).to_xml))).to be_equivalent_to <<~OUTPUT
        <p id="_">次に掲げる引用規格は，この規格に引用されることによって，その一部又は全部がこの規格の要求事項 を構成している。これらの引用規格は，その最新版(追補を含む。)を適用する。</p>
      OUTPUT
    end
  end

  it "has boilerplate for dated normative references" do
    VCR.use_cassette "isobib_123_dated" do
      input = <<~INPUT
        #{ISOBIB_BLANK_HDR}

        [bibliography]
        == Normative references

         * [[[iso123, ISO 123:1985]]] _Standard_
         * [[[iso124, ISO 124:2014]]] _Standard_
         * [[[iso125, ISO 125:2011]]] _Standard_
      INPUT
      xml = Nokogiri::XML(Asciidoctor.convert(input, *OPTIONS))
      expect(Xml::C14n.format(strip_guid(xml.at(
        "//xmlns:references/xmlns:p",
      ).to_xml))).to be_equivalent_to <<~OUTPUT
        <p id="_">次に掲げる引用規格は，この規格に引用されることによって，その一部又は全部がこの規格の要 求事項を構成している。これらの引用規格は，記載の年の版を適用し，その後の改正版(追補を含む。) は適用しない。</p>
      OUTPUT
    end
  end

  it "has boilerplate for mixed dated and undated normative references" do
    VCR.use_cassette "isobib_123_mix_dated" do
      input = <<~INPUT
        #{ISOBIB_BLANK_HDR}

        [bibliography]
        == Normative references

         * [[[iso123, ISO 123:1985]]] _Standard_
         * [[[iso124, ISO 124]]] _Standard_
         * [[[iso125, ISO 125:2011]]] _Standard_
      INPUT
      xml = Nokogiri::XML(Asciidoctor.convert(input, *OPTIONS))
      expect(Xml::C14n.format(strip_guid(xml.at(
        "//xmlns:references/xmlns:p",
      ).to_xml))).to be_equivalent_to <<~OUTPUT
        <p id="_">次に掲げる引用規格は，この規格に引用されることによって，その一部又は全部がこの規格の要 求事項を構成している。これらの引用規格のうち，西暦年を付記してあるものは，記載の年の版を適 用し，その後の改正版(追補を含む。)は適用しない。西暦年の付記がない引用規格は，その最新版(追 補を含む。)を適用する。</p>
      OUTPUT
    end
  end

  it "sorts referenes" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      [bibliography]
      == Normative references

      * [[[ref1,JIS/ISO/IEC 1]]]  span:publisher[Japanese Industrial Standards] span:publisher[International Electrotechnical Commission] span:publisher[International Organization for Standardization]
      * [[[ref2,JIS/IEC 1]]] span:publisher[Japanese Industrial Standards] span:publisher[International Electrotechnical Commission]
      * [[[ref3,JIS/ISO 1]]] span:publisher[Japanese Industrial Standards] span:publisher[International Organization for Standardization]
      * [[[ref4,ISO/IEC 1]]] span:publisher[International Electrotechnical Commission]
      * [[[ref5,ISO 1]]] span:publisher[International Organization for Standardization]
      * [[[ref6,IEC 1]]] span:publisher[International Electrotechnical Commission]
      * [[[ref7,IEC 10]]] span:publisher[International Electrotechnical Commission]
      * [[[ref8,IEC 2]]] span:publisher[International Electrotechnical Commission]
      * [[[ref10,NIST 1]]] span:publisher[National Institute for Science and Technology]
      * [[[ref9,IETF 1]]] span:publisher[Internet Task Force]
      * [[[ref11,JIS 1]]] span:publisher[Japanese Industrial Standards]
    INPUT

    out = Nokogiri::XML(Asciidoctor.convert(input, *OPTIONS))
    expect(out.xpath("//xmlns:references/xmlns:bibitem/@id")
      .map(&:value))
      .to be_equivalent_to ["ref11", "ref2", "ref1", "ref3", "ref5", "ref4",
                            "ref6", "ref8", "ref7", "ref9", "ref10"]
  end
end
