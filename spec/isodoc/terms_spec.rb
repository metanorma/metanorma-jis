require "spec_helper"

RSpec.describe IsoDoc::JIS do
  it "processes IsoXML terms" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
          <terms id="_terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
            <term id="paddy1">
              <preferred><expression><name>paddy</name></expression></preferred>
              <domain>rice</domain>
              <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
              <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f892">
                <p id="_65c9a509-9a89-4b54-a890-274126aeb55c">Foreign seeds, husks, bran, sand, dust.</p>
                <ul>
                <li>A</li>
                </ul>
              </termexample>
              <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f894">
                <ul>
                <li>A</li>
                </ul>
              </termexample>

              <termsource status="modified">
                <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
                  <modification>
                  <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
                </modification>
              </termsource>
            </term>

            <term id="paddy">
              <preferred><expression><name>paddy</name></expression></preferred>
              <admitted><expression><name>paddy rice</name></expression></admitted>
              <admitted><expression><name>rough rice</name></expression></admitted>
              <deprecates><expression><name>cargo rice</name></expression></deprecates>
              <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
              <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74e">
                <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
              </termnote>
              <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f893">
                <ul>
                <li>A</li>
                </ul>
              </termexample>
              <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74f">
              <ul><li>A</li></ul>
                <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
              </termnote>
              <termsource status="identical">
                <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
              </termsource>
            </term>
            <term id="A">
              <preferred><expression><name>term1</name></expression></preferred>
              <definition><verbal-definition>term1 definition</verbal-definition></definition>
              <term id="B">
              <preferred><expression><name>term2</name></expression></preferred>
              <definition><verbal-definition>term2 definition</verbal-definition></definition>
              </term>
            </term>
          </terms>
        </sections>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <sections>
          <terms id="_terms_and_definitions" obligation="normative" displayorder="1">
            <title depth="1">
              1
              <tab/>
              Terms and Definitions
            </title>
            <term id="paddy1">
              <name>1.1</name>
              <preferred>
                <strong>paddy</strong>
              </preferred>
              <definition>
                <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">&lt;rice&gt; rice retaining its husk after threshing</p>
              </definition>
              <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f892">
                <name>EXAMPLE  1</name>
                <p id="_65c9a509-9a89-4b54-a890-274126aeb55c">Foreign seeds, husks, bran, sand, dust.</p>
                <ul>
                  <li>A</li>
                </ul>
              </termexample>
              <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f894">
                <name>EXAMPLE  2</name>
                <ul>
                  <li>A</li>
                </ul>
              </termexample>
              <termsource status="modified">
                [SOURCE:
                <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                  <locality type="clause">
                    <referenceFrom>3.1</referenceFrom>
                  </locality>
                  ISO 7301:2011,
                  <span class="citesec">3.1</span>
                </origin>
                , modified – The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]
              </termsource>
            </term>
            <term id="paddy">
              <name>1.2</name>
              <preferred>
                <strong>paddy</strong>
              </preferred>
              <admitted>ADMITTED: paddy rice</admitted>
              <admitted>ADMITTED: rough rice</admitted>
              <deprecates>DEPRECATED: cargo rice</deprecates>
              <definition>
                <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p>
              </definition>
              <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f893">
                <name>EXAMPLE</name>
                <ul>
                  <li>A</li>
                </ul>
              </termexample>
              <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74e">
                <name>Note 1 to entry</name>
                <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
              </termnote>
              <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74f">
                <name>Note 2 to entry</name>
                <ul>
                  <li>A</li>
                </ul>
                <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
              </termnote>
              <termsource status="identical">
                [SOURCE:
                <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                  <locality type="clause">
                    <referenceFrom>3.1</referenceFrom>
                  </locality>
                  ISO 7301:2011,
                  <span class="citesec">3.1</span>
                </origin>
                ]
              </termsource>
            </term>
            <term id="A">
              <name>1.3</name>
              <preferred>
                <strong>term1</strong>
              </preferred>
              <definition>term1 definition</definition>
              <term id="B">
                <name>1.3.1</name>
                <preferred>
                  <strong>term2</strong>
                </preferred>
                <definition>term2 definition</definition>
              </term>
            </term>
          </terms>
        </sections>
      </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
                  #{middle_title(false)}
             <div id="_terms_and_definitions">
               <h1>
               1
                
               Terms and Definitions
             </h1>
               <p class="TermNum" id="paddy1">1.1</p>
               <p class="Terms" style="text-align:left;">
                 <b>paddy</b>
               </p>
               <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">&lt;rice&gt; rice retaining its husk after threshing</p>
               <div id="_bd57bbf1-f948-4bae-b0ce-73c00431f892" class="example">
                 <p>
                   <span class="example_label">EXAMPLE  1</span>
                     Foreign seeds, husks, bran, sand, dust.
                 </p>
                 <ul>
                   <li>A</li>
                 </ul>
               </div>
               <div id="_bd57bbf1-f948-4bae-b0ce-73c00431f894" class="example">
                 <p>
                   <span class="example_label">EXAMPLE  2</span>
                    
                 </p>
                 <ul>
                   <li>A</li>
                 </ul>
               </div>
               <p>
                 [SOURCE: ISO 7301:2011,
                 <span class="citesec">3.1</span>
                 , modified – The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]
               </p>
               <p class="TermNum" id="paddy">1.2</p>
               <p class="Terms" style="text-align:left;">
                 <b>paddy</b>
               </p>
               <p class="AltTerms" style="text-align:left;">ADMITTED: paddy rice</p>
               <p class="AltTerms" style="text-align:left;">ADMITTED: rough rice</p>
               <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
               <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p>
               <div id="_bd57bbf1-f948-4bae-b0ce-73c00431f893" class="example">
                 <p>
                   <span class="example_label">EXAMPLE</span>
                    
                 </p>
                 <ul>
                   <li>A</li>
                 </ul>
               </div>
               <div id="_671a1994-4783-40d0-bc81-987d06ffb74e" class="Note">
                 <p>
                   <span class="note_label">Note 1 to entry</span>
                   : The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.
                 </p>
               </div>
               <div id="_671a1994-4783-40d0-bc81-987d06ffb74f" class="Note">
                 <p>
                   <span class="note_label">Note 2 to entry</span>
                   :
                   <ul>
                     <li>A</li>
                   </ul>
                   <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                 </p>
               </div>
               <p>
                 [SOURCE: ISO 7301:2011,
                 <span class="citesec">3.1</span>
                 ]
               </p>
               <p class="TermNum" id="A">1.3</p>
               <p class="Terms" style="text-align:left;">
                 <b>term1</b>
               </p>
               term1 definition
               <p class="TermNum" id="B">1.3.1</p>
               <p class="Terms" style="text-align:left;">
                 <b>term2</b>
               </p>
               term2 definition
             </div>
           </div>
         </body>
       </html>


    OUTPUT

    word = <<~OUTPUT
          <body lang="EN-US" link="blue" vlink="#954F72">
        <div class="WordSection1">
          <p> </p>
        </div>
        <p>
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection2">
          <p> </p>
        </div>
        <p>
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection3">
                    #{middle_title(true)}
          <div id="_terms_and_definitions">
            <h1>
              1
              <span style="mso-tab-count:1">  </span>
              Terms and Definitions
            </h1>
            <p class="TermNum" id="paddy1">1.1</p>
            <p class="Terms" style="text-align:left;">
              <b>paddy</b>
            </p>
            <p class="Definition" id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">&lt;rice&gt; rice retaining its husk after threshing</p>
            <div id="_bd57bbf1-f948-4bae-b0ce-73c00431f892" class="example">
              <p>
                <span class="example_label">EXAMPLE  1</span>
                <span style="mso-tab-count:1">  </span>
                Foreign seeds, husks, bran, sand, dust.
              </p>
              <ul>
                <li>A</li>
              </ul>
            </div>
            <div id="_bd57bbf1-f948-4bae-b0ce-73c00431f894" class="example">
              <p>
                <span class="example_label">EXAMPLE  2</span>
                <span style="mso-tab-count:1">  </span>
              </p>
              <ul>
                <li>A</li>
              </ul>
            </div>
            <p class="Source">
              [SOURCE: ISO 7301:2011,
              <span class="citesec">3.1</span>
              , modified – The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]
            </p>
            <p class="TermNum" id="paddy">1.2</p>
            <p class="Terms" style="text-align:left;">
              <b>paddy</b>
            </p>
            <p class="AltTerms" style="text-align:left;">ADMITTED: paddy rice</p>
            <p class="AltTerms" style="text-align:left;">ADMITTED: rough rice</p>
            <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
            <p class="Definition" id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p>
            <div id="_bd57bbf1-f948-4bae-b0ce-73c00431f893" class="example">
              <p>
                <span class="example_label">EXAMPLE</span>
                <span style="mso-tab-count:1">  </span>
              </p>
              <ul>
                <li>A</li>
              </ul>
            </div>
            <div id="_671a1994-4783-40d0-bc81-987d06ffb74e" class="Note">
              <p>
                <span class="note_label">Note 1 to entry</span>
                : The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.
              </p>
            </div>
            <div id="_671a1994-4783-40d0-bc81-987d06ffb74f" class="Note">
              <p>
                <span class="note_label">Note 2 to entry</span>
                :
                <ul>
                  <li>A</li>
                </ul>
                <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
              </p>
            </div>
            <p class="Source">
              [SOURCE: ISO 7301:2011,
              <span class="citesec">3.1</span>
              ]
            </p>
            <p class="TermNum" id="A">1.3</p>
            <p class="Terms" style="text-align:left;">
              <b>term1</b>
            </p>
            term1 definition
            <p class="TermNum" id="B">1.3.1</p>
            <p class="Terms" style="text-align:left;">
              <b>term2</b>
            </p>
            term2 definition
          </div>
        </div>
        <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
        <div class="colophon"/>
      </body>
    OUTPUT
    expect(xmlpp(IsoDoc::JIS::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::JIS::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::JIS::WordConvert.new({})
      .convert("test", presxml, true)
      .sub(/^.*<body/m, "<body")
      .sub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to xmlpp(word)
  end

  it "processes IsoXML terms in Japanese" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata><language>ja</language></bibdata>
        <sections>
          <terms id="_terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
            <term id="paddy1">
              <preferred><expression><name>paddy</name></expression></preferred>
              <domain>rice</domain>
              <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
              <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f892">
                <p id="_65c9a509-9a89-4b54-a890-274126aeb55c">Foreign seeds, husks, bran, sand, dust.</p>
                <ul>
                <li>A</li>
                </ul>
              </termexample>
              <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f894">
                <ul>
                <li>A</li>
                </ul>
              </termexample>

              <termsource status="modified">
                <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
                  <modification>
                  <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
                </modification>
              </termsource>
            </term>

            <term id="paddy">
              <preferred><expression><name>paddy</name></expression></preferred>
              <admitted><expression><name>paddy rice</name></expression></admitted>
              <admitted><expression><name>rough rice</name></expression></admitted>
              <deprecates><expression><name>cargo rice</name></expression></deprecates>
              <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
              <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74e">
                <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
              </termnote>
              <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f893">
                <ul>
                <li>A</li>
                </ul>
              </termexample>
              <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74f">
              <ul><li>A</li></ul>
                <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
              </termnote>
              <termsource status="identical">
                <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
              </termsource>
            </term>
            <term id="A">
              <preferred><expression><name>term1</name></expression></preferred>
              <definition><verbal-definition>term1 definition</verbal-definition></definition>
              <term id="B">
              <preferred><expression><name>term2</name></expression></preferred>
              <definition><verbal-definition>term2 definition</verbal-definition></definition>
              </term>
            </term>
          </terms>
        </sections>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
           <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
           <language current="true">ja</language>
         </bibdata>
         <sections>
           <terms id="_terms_and_definitions" obligation="normative" displayorder="1">
             <title depth="1">
               1
               <tab/>
               Terms and Definitions
             </title>
             <term id="paddy1">
               <name>1.1</name>
               <preferred>
                 <strong>paddy</strong>
               </preferred>
               <definition>
                 <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">&lt;rice&gt; rice retaining its husk after threshing</p>
               </definition>
               <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f892">
                 <name>例  1</name>
                 <p id="_65c9a509-9a89-4b54-a890-274126aeb55c">Foreign seeds, husks, bran, sand, dust.</p>
                 <ul>
                   <li>A</li>
                 </ul>
               </termexample>
               <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f894">
                 <name>例  2</name>
                 <ul>
                   <li>A</li>
                 </ul>
               </termexample>
               <termsource status="modified">
                 [出典:
                 <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                   <locality type="clause">
                     <referenceFrom>3.1</referenceFrom>
                   </locality>
                   ISO 7301:2011,
                   <span class="citesec">3.1</span>
                 </origin>
                 , modified – The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]
               </termsource>
             </term>
             <term id="paddy">
               <name>1.2</name>
               <preferred>
                 <strong>paddy</strong>
               </preferred>
               <admitted>代替用語: paddy rice</admitted>
               <admitted>代替用語: rough rice</admitted>
               <deprecates>推奨しない用語: cargo rice</deprecates>
               <definition>
                 <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p>
               </definition>
               <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f893">
                 <name>例</name>
                 <ul>
                   <li>A</li>
                 </ul>
               </termexample>
               <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74e">
                 <name>注釈1</name>
                 <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
               </termnote>
               <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74f">
                 <name>注釈2</name>
                 <ul>
                   <li>A</li>
                 </ul>
                 <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
               </termnote>
               <termsource status="identical">
                 [出典:
                 <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                   <locality type="clause">
                     <referenceFrom>3.1</referenceFrom>
                   </locality>
                   ISO 7301:2011,
                   <span class="citesec">3.1</span>
                 </origin>
                 ]
               </termsource>
             </term>
             <term id="A">
               <name>1.3</name>
               <preferred>
                 <strong>term1</strong>
               </preferred>
               <definition>term1 definition</definition>
               <term id="B">
                 <name>1.3.1</name>
                 <preferred>
                   <strong>term2</strong>
                 </preferred>
                 <definition>term2 definition</definition>
               </term>
             </term>
           </terms>
         </sections>
       </iso-standard>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::JIS::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
    xml.at("//xmlns:localized-strings").remove
    expect(xmlpp(xml.to_xml))
      .to be_equivalent_to xmlpp(presxml)
  end
end
