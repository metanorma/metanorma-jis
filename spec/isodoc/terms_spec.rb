require "spec_helper"

RSpec.describe IsoDoc::Jis do
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

              <source status="modified">
                <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
                  <modification>
                  <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" (and similar terms) is shown as deprecated, and Note 1 to entry is not included here</p>
                </modification>
              </source>
              <source status="modified">
                <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
              </source>
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
              <source status="identical">
                <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
              </source>
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
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1" id="_">Contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <p class="JapaneseIndustrialStandard" displayorder="2">
                日本工業規格
                <tab/>
                <tab/>
                <tab/>
                <tab/>
                <tab/>
                <tab/>
                <tab/>
                <span class="JIS">JIS</span>
             </p>
             <p class="StandardNumber" displayorder="3">
                <tab/>
             </p>
             <p class="IDT" displayorder="4"/>
             <terms id="_" obligation="normative" displayorder="5">
                <title id="_">Terms and Definitions</title>
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="_">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Terms and Definitions</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="_">1</semx>
                </fmt-xref-label>
                <term id="paddy1">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="_">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="paddy1">1</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <semx element="autonum" source="_">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="paddy1">1</semx>
                   </fmt-xref-label>
                   <preferred id="_">
                      <expression>
                         <name>paddy</name>
                      </expression>
                   </preferred>
                   <fmt-preferred>
                      <p>
                         <semx element="preferred" source="_">
                            <strong>paddy</strong>
                         </semx>
                      </p>
                   </fmt-preferred>
                   <domain id="_">rice</domain>
                   <definition id="_">
                      <verbal-definition>
                         <p original-id="_">rice retaining its husk after threshing</p>
                      </verbal-definition>
                   </definition>
                   <fmt-definition id="_">
                      <semx element="definition" source="_">
                         <p id="_">
                            &lt;
                            <semx element="domain" source="_">rice</semx>
                            &gt; rice retaining its husk after threshing
                         </p>
                      </semx>
                   </fmt-definition>
                   <termexample id="_" autonum="1">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">EXAMPLE</span>
                            <semx element="autonum" source="_">1</semx>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Example</span>
                         <semx element="autonum" source="_">1</semx>
                      </fmt-xref-label>
                      <fmt-xref-label container="paddy1">
                         <span class="fmt-xref-container">
                            <semx element="autonum" source="_">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="paddy1">1</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Example</span>
                         <semx element="autonum" source="_">1</semx>
                      </fmt-xref-label>
                      <p id="_">Foreign seeds, husks, bran, sand, dust.</p>
                      <ul>
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">－</semx>
                            </fmt-name>
                            A
                         </li>
                      </ul>
                   </termexample>
                   <termexample id="_" autonum="2">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">EXAMPLE</span>
                            <semx element="autonum" source="_">2</semx>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Example</span>
                         <semx element="autonum" source="_">2</semx>
                      </fmt-xref-label>
                      <fmt-xref-label container="paddy1">
                         <span class="fmt-xref-container">
                            <semx element="autonum" source="_">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="paddy1">1</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Example</span>
                         <semx element="autonum" source="_">2</semx>
                      </fmt-xref-label>
                      <ul>
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">－</semx>
                            </fmt-name>
                            A
                         </li>
                      </ul>
                   </termexample>
                   <source status="modified" id="_">
                      <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                         <locality type="clause">
                            <referenceFrom>3.1</referenceFrom>
                         </locality>
                      </origin>
                      <modification id="_">
                         <p id="_">The term "cargo rice" (and similar terms) is shown as deprecated, and Note 1 to entry is not included here</p>
                      </modification>
                   </source>
                   <source status="modified" id="_">
                      <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                         <locality type="clause">
                            <referenceFrom>3.1</referenceFrom>
                         </locality>
                      </origin>
                   </source>
                   <fmt-termsource status="modified">
                      [SOURCE:
                      <semx element="source" source="_">
                         <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011" id="_">
                            <locality type="clause">
                               <referenceFrom>3.1</referenceFrom>
                            </locality>
                         </origin>
                         <semx element="origin" source="_">
                            <fmt-origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                               <locality type="clause">
                                  <referenceFrom>3.1</referenceFrom>
                               </locality>
                               ISO 7301:2011,
                               <span class="citesec">3.1</span>
                            </fmt-origin>
                         </semx>
                         , modified,
                         <semx element="modification" source="_">The term "cargo rice" (and similar terms) is shown as deprecated, and Note 1 to entry is not included here</semx>
                      </semx>
                      ;
                      <semx element="source" source="_">
                         <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011" id="_">
                            <locality type="clause">
                               <referenceFrom>3.1</referenceFrom>
                            </locality>
                         </origin>
                         <semx element="origin" source="_">
                            <fmt-origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                               <locality type="clause">
                                  <referenceFrom>3.1</referenceFrom>
                               </locality>
                               ISO 7301:2011,
                               <span class="citesec">3.1</span>
                            </fmt-origin>
                         </semx>
                         , modified
                      </semx>
                      ]
                   </fmt-termsource>
                </term>
                <term id="paddy">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="_">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="paddy">2</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <semx element="autonum" source="_">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="paddy">2</semx>
                   </fmt-xref-label>
                   <preferred id="_">
                      <expression>
                         <name>paddy</name>
                      </expression>
                   </preferred>
                   <fmt-preferred>
                      <p>
                         <semx element="preferred" source="_">
                            <strong>paddy</strong>
                         </semx>
                      </p>
                   </fmt-preferred>
                   <admitted id="_">
                      <expression>
                         <name>paddy rice</name>
                      </expression>
                   </admitted>
                   <admitted id="_">
                      <expression>
                         <name>rough rice</name>
                      </expression>
                   </admitted>
                   <fmt-admitted>
                      <p>
                         ADMITTED:
                         <semx element="admitted" source="_">paddy rice</semx>
                      </p>
                      <p>
                         ADMITTED:
                         <semx element="admitted" source="_">rough rice</semx>
                      </p>
                   </fmt-admitted>
                   <deprecates id="_">
                      <expression>
                         <name>cargo rice</name>
                      </expression>
                   </deprecates>
                   <fmt-deprecates>
                      <p>
                         DEPRECATED:
                         <semx element="deprecates" source="_">cargo rice</semx>
                      </p>
                   </fmt-deprecates>
                   <definition id="_">
                      <verbal-definition>
                         <p original-id="_">rice retaining its husk after threshing</p>
                      </verbal-definition>
                   </definition>
                   <fmt-definition id="_">
                      <semx element="definition" source="_">
                         <p id="_">rice retaining its husk after threshing</p>
                      </semx>
                   </fmt-definition>
                   <termexample id="_" autonum="">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">EXAMPLE</span>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Example</span>
                      </fmt-xref-label>
                      <fmt-xref-label container="paddy">
                         <span class="fmt-xref-container">
                            <semx element="autonum" source="_">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="paddy">2</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Example</span>
                      </fmt-xref-label>
                      <ul>
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">－</semx>
                            </fmt-name>
                            A
                         </li>
                      </ul>
                   </termexample>
                   <termnote id="_" autonum="1">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            Note
                            <semx element="autonum" source="_">1</semx>
                            to entry
                         </span>
                         <span class="fmt-label-delim">: </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Note</span>
                         <semx element="autonum" source="_">1</semx>
                      </fmt-xref-label>
                      <fmt-xref-label container="paddy">
                         <span class="fmt-xref-container">
                            <semx element="autonum" source="_">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="paddy">2</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Note</span>
                         <semx element="autonum" source="_">1</semx>
                      </fmt-xref-label>
                      <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                   </termnote>
                   <termnote id="_" autonum="2">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            Note
                            <semx element="autonum" source="_">2</semx>
                            to entry
                         </span>
                         <span class="fmt-label-delim">: </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Note</span>
                         <semx element="autonum" source="_">2</semx>
                      </fmt-xref-label>
                      <fmt-xref-label container="paddy">
                         <span class="fmt-xref-container">
                            <semx element="autonum" source="_">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="paddy">2</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Note</span>
                         <semx element="autonum" source="_">2</semx>
                      </fmt-xref-label>
                      <ul>
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">－</semx>
                            </fmt-name>
                            A
                         </li>
                      </ul>
                      <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                   </termnote>
                   <source status="identical" id="_">
                      <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                         <locality type="clause">
                            <referenceFrom>3.1</referenceFrom>
                         </locality>
                      </origin>
                   </source>
                   <fmt-termsource status="identical">
                      (SOURCE:
                      <semx element="source" source="_">
                         <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011" id="_">
                            <locality type="clause">
                               <referenceFrom>3.1</referenceFrom>
                            </locality>
                         </origin>
                         <semx element="origin" source="_">
                            <fmt-origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                               <locality type="clause">
                                  <referenceFrom>3.1</referenceFrom>
                               </locality>
                               ISO 7301:2011,
                               <span class="citesec">3.1</span>
                            </fmt-origin>
                         </semx>
                      </semx>
                      )
                   </fmt-termsource>
                </term>
                <term id="A">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="_">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="A">3</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <semx element="autonum" source="_">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="A">3</semx>
                   </fmt-xref-label>
                   <preferred id="_">
                      <expression>
                         <name>term1</name>
                      </expression>
                   </preferred>
                   <fmt-preferred>
                      <p>
                         <semx element="preferred" source="_">
                            <strong>term1</strong>
                         </semx>
                      </p>
                   </fmt-preferred>
                   <definition id="_">
                      <verbal-definition>term1 definition</verbal-definition>
                   </definition>
                   <fmt-definition id="_">
                      <semx element="definition" source="_">term1 definition</semx>
                   </fmt-definition>
                   <term id="B">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="_">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="A">3</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="B">1</semx>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <semx element="autonum" source="_">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="A">3</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="B">1</semx>
                      </fmt-xref-label>
                      <preferred id="_">
                         <expression>
                            <name>term2</name>
                         </expression>
                      </preferred>
                      <fmt-preferred>
                         <p>
                            <semx element="preferred" source="_">
                               <strong>term2</strong>
                            </semx>
                         </p>
                      </fmt-preferred>
                      <definition id="_">
                         <verbal-definition>term2 definition</verbal-definition>
                      </definition>
                      <fmt-definition id="_">
                         <semx element="definition" source="_">term2 definition</semx>
                      </fmt-definition>
                   </term>
                </term>
             </terms>
          </sections>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
            <br/>
      <div id="_" class="TOC">
        <h1 class="IntroTitle">Contents</h1>
      </div>
                  #{middle_title(false)}
               <div id="_">
                   <h1>1  Terms and Definitions</h1>
                   <p class="TermNum" id="paddy1">1.1</p>
                   <p class="Terms" style="text-align:left;">
                      <b>paddy</b>
                   </p>
                   <p id="_">&lt;rice&gt;  rice retaining its husk after threshing</p>
                   <div id="_" class="example">
                      <p>
                         <span class="example_label">EXAMPLE 1</span>
                           Foreign seeds, husks, bran, sand, dust.
                      </p>
                      <div class="ul_wrap">
                         <ul>
                            <li id="_">A</li>
                         </ul>
                      </div>
                   </div>
                   <div id="_" class="example">
                      <p>
                         <span class="example_label">EXAMPLE 2</span>
                          
                      </p>
                      <div class="ul_wrap">
                         <ul>
                            <li id="_">A</li>
                         </ul>
                      </div>
                   </div>
                   <p>
                      [SOURCE: ISO 7301:2011,
                      <span class="citesec">3.1</span>
                      , modified, The term "cargo rice" (and similar terms) is shown as deprecated, and Note 1 to entry is not included here; ISO 7301:2011,
                      <span class="citesec">3.1</span>
                      , modified]
                   </p>
                   <p class="TermNum" id="paddy">1.2</p>
                   <p class="Terms" style="text-align:left;">
                      <b>paddy</b>
                   </p>
                   <p class="AltTerms" style="text-align:left;">ADMITTED: paddy rice</p>
                   <p class="AltTerms" style="text-align:left;">ADMITTED: rough rice</p>
                   <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
                   <p id="_">rice retaining its husk after threshing</p>
                   <div id="_" class="example">
                      <p>
                         <span class="example_label">EXAMPLE</span>
                          
                      </p>
                      <div class="ul_wrap">
                         <ul>
                            <li id="_">A</li>
                         </ul>
                      </div>
                   </div>
                   <div id="_" class="Note">
                      <p>
                         <span class="termnote_label">Note 1 to entry: </span>
                         The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.
                      </p>
                   </div>
                   <div id="_" class="Note">
                      <p>
                         <span class="termnote_label">Note 2 to entry: </span>
                      </p>
                      <div class="ul_wrap">
                         <ul>
                            <li id="_">A</li>
                         </ul>
                      </div>
                      <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                   </div>
                   <p>
                      (SOURCE: ISO 7301:2011,
                      <span class="citesec">3.1</span>
                      )
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
       <p class="section-break">
         <br clear="all" class="section"/>
       </p>
       <div class="WordSection2">
       <p class="page-break">
         <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
       </p>
       <div id="_" type="toc" class="TOC">
         <p class="zzContents">Contents</p>
       </div>
         <p> </p>
       </div>
       <p class="section-break">
         <br clear="all" class="section"/>
       </p>
       <div class="WordSection3">
                   #{middle_title(true)}
             <div id="_">
                <h1>
                   1
                   <span style="mso-tab-count:1">  </span>
                   Terms and Definitions
                </h1>
                <p class="TermNum" id="paddy1">1.1</p>
                <p class="Terms" style="text-align:left;">
                   <b>paddy</b>
                </p>
                <p class="Definition" id="_">&lt;rice&gt;  rice retaining its husk after threshing</p>
                <div id="_" class="example">
                   <p>
                      <span class="example_label">EXAMPLE 1</span>
                      <span style="mso-tab-count:1">  </span>
                      Foreign seeds, husks, bran, sand, dust.
                   </p>
                   <div class="ul_wrap">
                      <ul>
                         <li id="_">A</li>
                      </ul>
                   </div>
                </div>
                <div id="_" class="example">
                   <p>
                      <span class="example_label">EXAMPLE 2</span>
                      <span style="mso-tab-count:1">  </span>
                   </p>
                   <div class="ul_wrap">
                      <ul>
                         <li id="_">A</li>
                      </ul>
                   </div>
                </div>
                <p class="Source">
                   [SOURCE: ISO 7301:2011,
                   <span class="citesec">3.1</span>
                   , modified, The term "cargo rice" (and similar terms) is shown as deprecated, and Note 1 to entry is not included here; ISO 7301:2011,
                   <span class="citesec">3.1</span>
                   , modified]
                </p>
                <p class="TermNum" id="paddy">1.2</p>
                <p class="Terms" style="text-align:left;">
                   <b>paddy</b>
                </p>
                <p class="AltTerms" style="text-align:left;">ADMITTED: paddy rice</p>
                <p class="AltTerms" style="text-align:left;">ADMITTED: rough rice</p>
                <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
                <p class="Definition" id="_">rice retaining its husk after threshing</p>
                <div id="_" class="example">
                   <p>
                      <span class="example_label">EXAMPLE</span>
                      <span style="mso-tab-count:1">  </span>
                   </p>
                   <div class="ul_wrap">
                      <ul>
                         <li id="_">A</li>
                      </ul>
                   </div>
                </div>
                <div id="_" class="Note">
                   <p class="Note">
                      <span class="termnote_label">Note 1 to entry: </span>
                      The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.
                   </p>
                </div>
                <div id="_" class="Note">
                   <p class="Note">
                      <span class="termnote_label">Note 2 to entry: </span>
                   </p>
                   <div class="ul_wrap">
                      <ul>
                         <li id="_">A</li>
                      </ul>
                   </div>
                   <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                </div>
                <p class="Source">
                   (SOURCE: ISO 7301:2011,
                   <span class="citesec">3.1</span>
                   )
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
    pres_output = IsoDoc::Jis::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(IsoDoc::Jis::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
    expect(Canon.format_xml(strip_guid(IsoDoc::Jis::WordConvert.new({})
      .convert("test", pres_output, true)
      .sub(/^.*<body/m, "<body")
      .sub(%r{</body>.*$}m, "</body>"))))
      .to be_equivalent_to Canon.format_xml(word)
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

              <source status="modified">
                <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
                  <modification>
                  <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" （および類似の用語） is shown as deprecated, and Note 1 to entry is not included here</p>
                </modification>
              </source>
              <source status="modified">
                <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
              </source>
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
              <source status="identical">
                <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
              </source>
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
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1" id="_">目　次</fmt-title>
             </clause>
          </preface>
          <sections>
             <p class="JapaneseIndustrialStandard" displayorder="2">
                日本工業規格
                <tab/>
                <tab/>
                <tab/>
                <tab/>
                <tab/>
                <tab/>
                <tab/>
                <span class="JIS">JIS</span>
             </p>
             <p class="StandardNumber" displayorder="3">
                <tab/>
             </p>
             <p class="IDT" displayorder="4"/>
             <terms id="_" obligation="normative" displayorder="5">
                <title id="_">Terms and Definitions</title>
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="_">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Terms and Definitions</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">箇条</span>
                    
                   <semx element="autonum" source="_">1</semx>
                </fmt-xref-label>
                <term id="paddy1">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="_">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="paddy1">1</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <semx element="autonum" source="_">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="paddy1">1</semx>
                   </fmt-xref-label>
                   <preferred id="_">
                      <expression>
                         <name>paddy</name>
                      </expression>
                   </preferred>
                   <fmt-preferred>
                      <p>
                         <semx element="preferred" source="_">
                            <strong>paddy</strong>
                         </semx>
                      </p>
                   </fmt-preferred>
                   <domain id="_">rice</domain>
                   <definition id="_">
                      <verbal-definition>
                         <p original-id="_">rice retaining its husk after threshing</p>
                      </verbal-definition>
                   </definition>
                   <fmt-definition id="_">
                      <semx element="definition" source="_">
                         <p id="_">
                            &lt;
                            <semx element="domain" source="_">rice</semx>
                            &gt; rice retaining its husk after threshing
                         </p>
                      </semx>
                   </fmt-definition>
                   <termexample id="_" autonum="1">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">例</span>
                             
                            <semx element="autonum" source="_">1</semx>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">例</span>
                          
                         <semx element="autonum" source="_">1</semx>
                      </fmt-xref-label>
                      <fmt-xref-label container="paddy1">
                         <span class="fmt-xref-container">
                            <semx element="autonum" source="_">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="paddy1">1</semx>
                         </span>
                         <span class="fmt-conn">の</span>
                         <span class="fmt-element-name">例</span>
                          
                         <semx element="autonum" source="_">1</semx>
                      </fmt-xref-label>
                      <p id="_">Foreign seeds, husks, bran, sand, dust.</p>
                      <ul>
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">－</semx>
                            </fmt-name>
                            A
                         </li>
                      </ul>
                   </termexample>
                   <termexample id="_" autonum="2">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">例</span>
                             
                            <semx element="autonum" source="_">2</semx>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">例</span>
                          
                         <semx element="autonum" source="_">2</semx>
                      </fmt-xref-label>
                      <fmt-xref-label container="paddy1">
                         <span class="fmt-xref-container">
                            <semx element="autonum" source="_">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="paddy1">1</semx>
                         </span>
                         <span class="fmt-conn">の</span>
                         <span class="fmt-element-name">例</span>
                          
                         <semx element="autonum" source="_">2</semx>
                      </fmt-xref-label>
                      <ul>
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">－</semx>
                            </fmt-name>
                            A
                         </li>
                      </ul>
                   </termexample>
                   <source status="modified" id="_">
                      <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                         <locality type="clause">
                            <referenceFrom>3.1</referenceFrom>
                         </locality>
                      </origin>
                      <modification id="_">
                         <p id="_">The term "cargo rice" （および類似の用語） is shown as deprecated, and Note 1 to entry is not included here</p>
                      </modification>
                   </source>
                   <source status="modified" id="_">
                      <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                         <locality type="clause">
                            <referenceFrom>3.1</referenceFrom>
                         </locality>
                      </origin>
                   </source>
                   <fmt-termsource status="modified">
                      ［出典： 
                      <semx element="source" source="_">
                         <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011" id="_">
                            <locality type="clause">
                               <referenceFrom>3.1</referenceFrom>
                            </locality>
                         </origin>
                         <semx element="origin" source="_">
                            <fmt-origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                               <locality type="clause">
                                  <referenceFrom>3.1</referenceFrom>
                               </locality>
                               ISO 7301:2011、
                               <span class="citesec">第3.1</span>
                            </fmt-origin>
                         </semx>
                         、を一部変更し，
                         <semx element="modification" source="_">The term "cargo rice" （および類似の用語） is shown as deprecated、 and Note 1 to entry is not included here</semx>
                      </semx>
                      、
                      <semx element="source" source="_">
                         <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011" id="_">
                            <locality type="clause">
                               <referenceFrom>3.1</referenceFrom>
                            </locality>
                         </origin>
                         <semx element="origin" source="_">
                            <fmt-origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                               <locality type="clause">
                                  <referenceFrom>3.1</referenceFrom>
                               </locality>
                               ISO 7301:2011、
                               <span class="citesec">第3.1</span>
                            </fmt-origin>
                         </semx>
                         、を変更
                      </semx>
                      ］
                   </fmt-termsource>
                </term>
                <term id="paddy">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="_">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="paddy">2</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <semx element="autonum" source="_">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="paddy">2</semx>
                   </fmt-xref-label>
                   <preferred id="_">
                      <expression>
                         <name>paddy</name>
                      </expression>
                   </preferred>
                   <fmt-preferred>
                      <p>
                         <semx element="preferred" source="_">
                            <strong>paddy</strong>
                         </semx>
                      </p>
                   </fmt-preferred>
                   <admitted id="_">
                      <expression>
                         <name>paddy rice</name>
                      </expression>
                   </admitted>
                   <admitted id="_">
                      <expression>
                         <name>rough rice</name>
                      </expression>
                   </admitted>
                   <fmt-admitted>
                      <p>
                         代替用語：
                         <semx element="admitted" source="_">paddy rice</semx>
                      </p>
                      <p>
                         代替用語：
                         <semx element="admitted" source="_">rough rice</semx>
                      </p>
                   </fmt-admitted>
                   <deprecates id="_">
                      <expression>
                         <name>cargo rice</name>
                      </expression>
                   </deprecates>
                   <fmt-deprecates>
                      <p>
                         推奨しない用語：
                         <semx element="deprecates" source="_">cargo rice</semx>
                      </p>
                   </fmt-deprecates>
                   <definition id="_">
                      <verbal-definition>
                         <p original-id="_">rice retaining its husk after threshing</p>
                      </verbal-definition>
                   </definition>
                   <fmt-definition id="_">
                      <semx element="definition" source="_">
                         <p id="_">rice retaining its husk after threshing</p>
                      </semx>
                   </fmt-definition>
                   <termexample id="_" autonum="">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">例</span>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">例</span>
                      </fmt-xref-label>
                      <fmt-xref-label container="paddy">
                         <span class="fmt-xref-container">
                            <semx element="autonum" source="_">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="paddy">2</semx>
                         </span>
                         <span class="fmt-conn">の</span>
                         <span class="fmt-element-name">例</span>
                      </fmt-xref-label>
                      <ul>
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">－</semx>
                            </fmt-name>
                            A
                         </li>
                      </ul>
                   </termexample>
                   <termnote id="_" autonum="1">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            注釈
                            <semx element="autonum" source="_">1</semx>
                         </span>
                         <span class="fmt-label-delim">: </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">注記</span>
                          
                         <semx element="autonum" source="_">1</semx>
                      </fmt-xref-label>
                      <fmt-xref-label container="paddy">
                         <span class="fmt-xref-container">
                            <semx element="autonum" source="_">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="paddy">2</semx>
                         </span>
                         <span class="fmt-conn">の</span>
                         <span class="fmt-element-name">注記</span>
                          
                         <semx element="autonum" source="_">1</semx>
                      </fmt-xref-label>
                      <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                   </termnote>
                   <termnote id="_" autonum="2">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            注釈
                            <semx element="autonum" source="_">2</semx>
                         </span>
                         <span class="fmt-label-delim">: </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">注記</span>
                          
                         <semx element="autonum" source="_">2</semx>
                      </fmt-xref-label>
                      <fmt-xref-label container="paddy">
                         <span class="fmt-xref-container">
                            <semx element="autonum" source="_">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="paddy">2</semx>
                         </span>
                         <span class="fmt-conn">の</span>
                         <span class="fmt-element-name">注記</span>
                          
                         <semx element="autonum" source="_">2</semx>
                      </fmt-xref-label>
                      <ul>
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">－</semx>
                            </fmt-name>
                            A
                         </li>
                      </ul>
                      <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                   </termnote>
                   <source status="identical" id="_">
                      <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                         <locality type="clause">
                            <referenceFrom>3.1</referenceFrom>
                         </locality>
                      </origin>
                   </source>
                   <fmt-termsource status="identical">
                      （出典： 
                      <semx element="source" source="_">
                         <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011" id="_">
                            <locality type="clause">
                               <referenceFrom>3.1</referenceFrom>
                            </locality>
                         </origin>
                         <semx element="origin" source="_">
                            <fmt-origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                               <locality type="clause">
                                  <referenceFrom>3.1</referenceFrom>
                               </locality>
                               ISO 7301:2011、
                               <span class="citesec">第3.1</span>
                            </fmt-origin>
                         </semx>
                      </semx>
                      ）
                   </fmt-termsource>
                </term>
                <term id="A">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="_">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="A">3</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <semx element="autonum" source="_">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="A">3</semx>
                   </fmt-xref-label>
                   <preferred id="_">
                      <expression>
                         <name>term1</name>
                      </expression>
                   </preferred>
                   <fmt-preferred>
                      <p>
                         <semx element="preferred" source="_">
                            <strong>term1</strong>
                         </semx>
                      </p>
                   </fmt-preferred>
                   <definition id="_">
                      <verbal-definition>term1 definition</verbal-definition>
                   </definition>
                   <fmt-definition id="_">
                      <semx element="definition" source="_">term1 definition</semx>
                   </fmt-definition>
                   <term id="B">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="_">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="A">3</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="B">1</semx>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <semx element="autonum" source="_">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="A">3</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="B">1</semx>
                      </fmt-xref-label>
                      <preferred id="_">
                         <expression>
                            <name>term2</name>
                         </expression>
                      </preferred>
                      <fmt-preferred>
                         <p>
                            <semx element="preferred" source="_">
                               <strong>term2</strong>
                            </semx>
                         </p>
                      </fmt-preferred>
                      <definition id="_">
                         <verbal-definition>term2 definition</verbal-definition>
                      </definition>
                      <fmt-definition id="_">
                         <semx element="definition" source="_">term2 definition</semx>
                      </fmt-definition>
                   </term>
                </term>
             </terms>
          </sections>
       </iso-standard>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Jis::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
    xml.at("//xmlns:localized-strings").remove
    expect(Canon.format_xml(strip_guid(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
  end

  it "gives full citations for term sources" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
          <terms id="_terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
            <term id="paddy1">
              <preferred><expression><name>paddy</name></expression></preferred>
              <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing, <eref bibitem="ISO712" citeas="ISO 712"/></p></verbal-definition></definition>
              <source status="modified">
                <origin bibitemid="ISO712" type="inline" citeas="ISO 712"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
                  <modification>
                  <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
                </modification>
              </source>
            </term>

            <term id="paddy">
              <preferred><expression><name>paddy</name></expression></preferred>
              <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing  <eref bibitem="ISO713" citeas="ISO 713"/></p></verbal-definition></definition>
              <source status="identical">
                <origin bibitemid="ISO713" type="inline" citeas="ISO 713"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
              </source>
            </term>

            <term id="paddy2">
              <preferred><expression><name>paddy</name></expression></preferred>
              <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing  <eref bibitem="ISO713" citeas="ISO 713"/></p></verbal-definition></definition>
              <source status="identical">
                <origin bibitemid="ISO713" type="inline" style="reference_tag" citeas="ISO 713"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
              </source>
            </term>

          </terms>
        </sections>
        <bibliography>
                  <references id="_bibliography" obligation="informative" normative="false"><title>Bibliography</title>
        <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ISO713" type="standard">
              <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
              <uri type="src">https://www.iso.org/standard/4766.html</uri>
              <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
              <docidentifier type="ISBN">9781108877831</docidentifier>
              <date type="published"><on>2022</on></date>
              <contributor>
                <role type="editor"/>
                <person>
                  <name><surname>Aluffi</surname><forename>Paolo</forename></name>
                </person>
              </contributor>
                      <contributor>
                <role type="editor"/>
                <person>
                  <name><surname>Anderson</surname><forename>David</forename></name>
                </person>
              </contributor>
              <contributor>
                <role type="editor"/>
                <person>
                  <name><surname>Hering</surname><forename>Milena</forename></name>
                </person>
              </contributor>
              <contributor>
                <role type="editor"/>
                <person>
                  <name><surname>Mustaţă</surname><forename>Mircea</forename></name>
                </person>
              </contributor>
              <contributor>
                <role type="editor"/>
                <person>
                  <name><surname>Payne</surname><forename>Sam</forename></name>
                </person>
              </contributor>
              <edition>1</edition>
              <series>
              <title>London Mathematical Society Lecture Note Series</title>
              <number>472</number>
              </series>
                  <contributor>
                    <role type="publisher"/>
                    <organization>
                      <name>Cambridge University Press</name>
                    </organization>
                  </contributor>
                  <place>Cambridge, UK</place>
                <size><value type="volume">1</value></size>
      </bibitem>
      </references>
      </bibliography>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1" id="_">Contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <p class="JapaneseIndustrialStandard" displayorder="2">
                日本工業規格
                <tab/>
                <tab/>
                <tab/>
                <tab/>
                <tab/>
                <tab/>
                <tab/>
                <span class="JIS">JIS</span>
             </p>
             <p class="StandardNumber" displayorder="3">
                <tab/>
             </p>
             <p class="IDT" displayorder="4"/>
             <terms id="_" obligation="normative" displayorder="5">
                <title id="_">Terms and Definitions</title>
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="_">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Terms and Definitions</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="_">1</semx>
                </fmt-xref-label>
                <term id="paddy1">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="_">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="paddy1">1</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <semx element="autonum" source="_">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="paddy1">1</semx>
                   </fmt-xref-label>
                   <preferred id="_">
                      <expression>
                         <name>paddy</name>
                      </expression>
                   </preferred>
                   <fmt-preferred>
                      <p>
                         <semx element="preferred" source="_">
                            <strong>paddy</strong>
                         </semx>
                      </p>
                   </fmt-preferred>
                   <definition id="_">
                      <verbal-definition>
                         <p original-id="_">
                            rice retaining its husk after threshing,
                            <eref bibitem="ISO712" citeas="ISO 712"/>
                         </p>
                      </verbal-definition>
                   </definition>
                   <fmt-definition id="_">
                      <semx element="definition" source="_">
                         <p id="_">
                            rice retaining its husk after threshing,
                            <eref bibitem="ISO712" citeas="ISO 712" id="_"/>
                            <semx element="eref" source="_">
                               <fmt-eref bibitem="ISO712" citeas="ISO 712">ISO 712</fmt-eref>
                            </semx>
                         </p>
                      </semx>
                   </fmt-definition>
                   <source status="modified" id="_">
                      <origin bibitemid="ISO712" type="inline" citeas="ISO 712">
                         <locality type="clause">
                            <referenceFrom>3.1</referenceFrom>
                         </locality>
                      </origin>
                      <modification id="_">
                         <p id="_">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
                      </modification>
                   </source>
                   <fmt-termsource status="modified">
                      (SOURCE:
                      <semx element="source" source="_">
                         <origin bibitemid="ISO712" type="inline" citeas="ISO 712" id="_">
                            <locality type="clause">
                               <referenceFrom>3.1</referenceFrom>
                            </locality>
                         </origin>
                         <semx element="origin" source="_">
                            <fmt-xref type="inline" target="ISO712">
                               ISO 712,
                               <span class="citesec">3.1</span>
                            </fmt-xref>
                         </semx>
                         , modified,
                         <semx element="modification" source="_">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</semx>
                      </semx>
                      )
                   </fmt-termsource>
                </term>
                <term id="paddy">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="_">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="paddy">2</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <semx element="autonum" source="_">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="paddy">2</semx>
                   </fmt-xref-label>
                   <preferred id="_">
                      <expression>
                         <name>paddy</name>
                      </expression>
                   </preferred>
                   <fmt-preferred>
                      <p>
                         <semx element="preferred" source="_">
                            <strong>paddy</strong>
                         </semx>
                      </p>
                   </fmt-preferred>
                   <definition id="_">
                      <verbal-definition>
                         <p original-id="_">
                            rice retaining its husk after threshing
                            <eref bibitem="ISO713" citeas="ISO 713"/>
                         </p>
                      </verbal-definition>
                   </definition>
                   <fmt-definition id="_">
                      <semx element="definition" source="_">
                         <p id="_">
                            rice retaining its husk after threshing
                            <eref bibitem="ISO713" citeas="ISO 713" id="_"/>
                            <semx element="eref" source="_">
                               <fmt-eref bibitem="ISO713" citeas="ISO 713">ISO 713</fmt-eref>
                            </semx>
                         </p>
                      </semx>
                   </fmt-definition>
                   <source status="identical" id="_">
                      <origin bibitemid="ISO713" type="inline" citeas="ISO 713">
                         <locality type="clause">
                            <referenceFrom>3.1</referenceFrom>
                         </locality>
                      </origin>
                   </source>
                   <fmt-termsource status="identical">
                      (SOURCE:
                      <semx element="source" source="_">
                         <origin bibitemid="ISO713" type="inline" citeas="ISO 713" id="_">
                            <locality type="clause">
                               <referenceFrom>3.1</referenceFrom>
                            </locality>
                         </origin>
                         <semx element="origin" source="_">
                            <fmt-xref type="inline" style="short" target="ISO713">
                               Aluffi P., Anderson D., Hering M., Mustaţă M. &amp; Payne S.
                               <span class="stddocTitle">Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</span>
                               . Version 1. Cambridge University Press,
                               <span class="citesec">3.1</span>
                            </fmt-xref>
                         </semx>
                      </semx>
                      )
                   </fmt-termsource>
                </term>
                <term id="paddy2">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="_">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="paddy2">3</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <semx element="autonum" source="_">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="paddy2">3</semx>
                   </fmt-xref-label>
                   <preferred id="_">
                      <expression>
                         <name>paddy</name>
                      </expression>
                   </preferred>
                   <fmt-preferred>
                      <p>
                         <semx element="preferred" source="_">
                            <strong>paddy</strong>
                         </semx>
                      </p>
                   </fmt-preferred>
                   <definition id="_">
                      <verbal-definition>
                         <p original-id="_">
                            rice retaining its husk after threshing
                            <eref bibitem="ISO713" citeas="ISO 713"/>
                         </p>
                      </verbal-definition>
                   </definition>
                   <fmt-definition id="_">
                      <semx element="definition" source="_">
                         <p id="_">
                            rice retaining its husk after threshing
                            <eref bibitem="ISO713" citeas="ISO 713" id="_"/>
                            <semx element="eref" source="_">
                               <fmt-eref bibitem="ISO713" citeas="ISO 713">ISO 713</fmt-eref>
                            </semx>
                         </p>
                      </semx>
                   </fmt-definition>
                   <source status="identical" id="_">
                      <origin bibitemid="ISO713" type="inline" style="reference_tag" citeas="ISO 713">
                         <locality type="clause">
                            <referenceFrom>3.1</referenceFrom>
                         </locality>
                      </origin>
                   </source>
                   <fmt-termsource status="identical">
                      (SOURCE:
                      <semx element="source" source="_">
                         <origin bibitemid="ISO713" type="inline" style="reference_tag" citeas="ISO 713" id="_">
                            <locality type="clause">
                               <referenceFrom>3.1</referenceFrom>
                            </locality>
                         </origin>
                         <semx element="origin" source="_">
                            <fmt-xref type="inline" style="reference_tag" target="ISO713">
                               [2],
                               <span class="citesec">3.1</span>
                            </fmt-xref>
                         </semx>
                      </semx>
                      )
                   </fmt-termsource>
                </term>
             </terms>
          </sections>
          <bibliography>
             <references id="_" obligation="informative" normative="false" displayorder="6">
                <title id="_">Bibliography</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Bibliography</semx>
                </fmt-title>
                <bibitem id="ISO712" type="standard">
                   <biblio-tag>
                      [1]
                      <tab/>
                      ISO 712,
                   </biblio-tag>
                   <formattedref>
                      <span class="stddocTitle">Cereals and cereal products</span>
                   </formattedref>
                   <title format="text/plain">Cereals or cereal products</title>
                   <title type="main" format="text/plain">Cereals and cereal products</title>
                   <docidentifier type="metanorma-ordinal">[1]</docidentifier>
                   <docidentifier type="ISO">ISO 712</docidentifier>
                   <docidentifier scope="biblio-tag">ISO 712</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Organization for Standardization</name>
                      </organization>
                   </contributor>
                </bibitem>
                <bibitem id="ISO713" type="standard">
                   <biblio-tag>
                      [2]
                      <tab/>
                   </biblio-tag>
                   <formattedref>
                      Aluffi P., Anderson D., Hering M., Mustaţă M. &amp; Payne S.
                      <span class="stddocTitle">Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</span>
                      . Version 1. Cambridge University Press. Available from:
                      <span class="biburl">
                      <fmt-link target="https://www.iso.org/standard/4766.html">https://www.iso.org/standard/4766.html</fmt-link>
                      </span>
                   </formattedref>
                   <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
                   <uri type="src">https://www.iso.org/standard/4766.html</uri>
                   <docidentifier type="metanorma-ordinal">[2]</docidentifier>
                   <docidentifier type="DOI">DOI https://doi.org/10.1017/9781108877831</docidentifier>
                   <docidentifier type="ISBN">ISBN 9781108877831</docidentifier>
                   <date type="published">
                      <on>2022</on>
                   </date>
                   <contributor>
                      <role type="editor"/>
                      <person>
                         <name>
                            <surname>Aluffi</surname>
                            <forename>Paolo</forename>
                         </name>
                      </person>
                   </contributor>
                   <contributor>
                      <role type="editor"/>
                      <person>
                         <name>
                            <surname>Anderson</surname>
                            <forename>David</forename>
                         </name>
                      </person>
                   </contributor>
                   <contributor>
                      <role type="editor"/>
                      <person>
                         <name>
                            <surname>Hering</surname>
                            <forename>Milena</forename>
                         </name>
                      </person>
                   </contributor>
                   <contributor>
                      <role type="editor"/>
                      <person>
                         <name>
                            <surname>Mustaţă</surname>
                            <forename>Mircea</forename>
                         </name>
                      </person>
                   </contributor>
                   <contributor>
                      <role type="editor"/>
                      <person>
                         <name>
                            <surname>Payne</surname>
                            <forename>Sam</forename>
                         </name>
                      </person>
                   </contributor>
                   <edition>1</edition>
                   <series>
                      <title>London Mathematical Society Lecture Note Series</title>
                      <number>472</number>
                   </series>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>Cambridge University Press</name>
                      </organization>
                   </contributor>
                   <place>Cambridge, UK</place>
                   <size>
                      <value type="volume">1</value>
                   </size>
                </bibitem>
             </references>
          </bibliography>
       </iso-standard>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Jis::PresentationXMLConvert.new(presxml_options)
         .convert("test", input, true))
    # xml.at("//xmlns:localized-strings").remove
    expect(Canon.format_xml(strip_guid(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
