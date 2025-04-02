require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc::Jis do
  it "processes figures" do
    input = <<~INPUT
                <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><foreword id="A">
            <figure id="figureA-1" keep-with-next="true" keep-lines-together="true">
          <name>Split-it-right <em>sample</em> divider<fn reference="1"><p>X</p></fn></name>
          <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
          <image src="rice_images/rice_image1.png" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f1" mimetype="image/png"/>
          <image src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f2" mimetype="image/png"/>
          <image src="data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f2" mimetype="application/xml"/>
          <fn reference="a">
          <p id="_ef2c85b8-5a5a-4ecd-a1e6-92acefaaa852">The time <stem type="AsciiMath">t_90</stem> was estimated to be 18,2 min for this example.</p>
        </fn>
          <dl id="DL1">
          <name>Key</name>
          <dt>A</dt>
          <dd><p>B</p></dd>
          </dl>
                <source status="generalisation">
          <origin bibitemid="ISO712" type="inline" citeas="">
            <localityStack>
              <locality type="section">
                <referenceFrom>1</referenceFrom>
              </locality>
            </localityStack>
          </origin>
          <modification>
            <p id="_">with adjustments</p>
          </modification>
        </source>
        <note id="note1">This is a note</note>
        <note id="note2" type="units">Units in mm</note>
        </figure>
        <figure id="figure-B">
        <pre alt="A B">A &#x3c;
        B</pre>
        </figure>
        <figure id="figure-C" unnumbered="true">
        <pre>A &#x3c;
        B</pre>
        </figure>
            </foreword></preface>
                  <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
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
      </bibliography>
            </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <foreword id="A" displayorder="1">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <figure id="figureA-1" keep-with-next="true" keep-lines-together="true" autonum="1">
             <name id="_">
                Split-it-right
                <em>sample</em>
                divider
                <fn reference="1" original-reference="1" target="_" original-id="_">
                   <p>X</p>
                   <fmt-fn-label>
                      <sup>
                         <semx element="autonum" source="_">1</semx>
                      </sup>
                   </fmt-fn-label>
                </fn>
             </name>
             <fmt-name>
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Figure</span>
                   <semx element="autonum" source="figureA-1">1</semx>
                </span>
                <span class="fmt-caption-delim"> — </span>
                <semx element="name" source="_">
                   Split-it-right
                   <em>sample</em>
                   divider
                   <fn reference="1" original-reference="1" id="_" target="_">
                      <p>X</p>
                      <fmt-fn-label>
                         <sup>
                            <semx element="autonum" source="_">1</semx>
                         </sup>
                      </fmt-fn-label>
                   </fn>
                </semx>
             </fmt-name>
             <fmt-xref-label>
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="figureA-1">1</semx>
             </fmt-xref-label>
             <image src="rice_images/rice_image1.png" height="20" width="30" id="_" mimetype="image/png" alt="alttext" title="titletxt"/>
             <image src="rice_images/rice_image1.png" height="20" width="auto" id="_" mimetype="image/png"/>
             <image src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto" id="_" mimetype="image/png"/>
             <image src="data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==" height="20" width="auto" id="_" mimetype="application/xml"/>
             <fn reference="a" id="_" target="_">
                <p original-id="_">
                   The time
                   <stem type="AsciiMath" id="_">t_90</stem>
                   <fmt-stem type="AsciiMath">
                      <semx element="stem" source="_">t_90</semx>
                   </fmt-stem>
                   was estimated to be 18,2 min for this example.
                </p>
                <fmt-fn-label>
                   <sup>
                      <semx element="autonum" source="_">a</semx>
                      <span class="fmt-label-delim">)</span>
                   </sup>
                </fmt-fn-label>
             </fn>
             <p class="ListTitle">
                <semx element="name" source="_">Key</semx>
                <bookmark id="DL1"/>
             </p>
             <p class="dl">A: B</p>
             <source status="generalisation">
                [SOURCE:
                <origin bibitemid="ISO712" type="inline" citeas="" id="_">
                   <localityStack>
                      <locality type="section">
                         <referenceFrom>1</referenceFrom>
                      </locality>
                   </localityStack>
                </origin>
                <semx element="origin" source="_">
                   <fmt-xref type="inline" target="ISO712">ISO 712, Section 1</fmt-xref>
                </semx>
                —
                <semx element="modification" source="_">with adjustments</semx>
                ]
             </source>
             <note id="note1" autonum="">
                <fmt-name>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">NOTE</span>
                   </span>
                   <span class="fmt-label-delim">
                      <tab/>
                   </span>
                </fmt-name>
                <fmt-xref-label>
                   <span class="fmt-element-name">Note</span>
                </fmt-xref-label>
                <fmt-xref-label container="A">
                   <span class="fmt-xref-container">
                      <semx element="foreword" source="A">Foreword</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                </fmt-xref-label>
                This is a note
             </note>
             <note id="note2" type="units">Units in mm</note>
             <fmt-footnote-container>
                <fmt-fn-body id="_" target="_" reference="a">
                   <semx element="fn" source="_">
                      <p id="_">
                         <fmt-fn-label>
                            Footnote
                            <sup>
                               <semx element="autonum" source="_">a</semx>
                               <span class="fmt-label-delim">)</span>
                            </sup>
                            <span class="fmt-caption-delim">
                               <tab/>
                            </span>
                         </fmt-fn-label>
                         The time
                         <stem type="AsciiMath" id="_">t_90</stem>
                         <fmt-stem type="AsciiMath">
                            <semx element="stem" source="_">t_90</semx>
                         </fmt-stem>
                         was estimated to be 18,2 min for this example.
                      </p>
                   </semx>
                </fmt-fn-body>
             </fmt-footnote-container>
          </figure>
          <figure id="figure-B" autonum="2">
             <fmt-name>
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Figure</span>
                   <semx element="autonum" source="figure-B">2</semx>
                </span>
             </fmt-name>
             <fmt-xref-label>
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="figure-B">2</semx>
             </fmt-xref-label>
             <pre alt="A B">A &lt;
         B</pre>
          </figure>
          <figure id="figure-C" unnumbered="true">
             <pre>A &lt;
         B</pre>
          </figure>
       </foreword>
    OUTPUT
    html = <<~OUTPUT
      <div id="A">
         <h1 class="ForewordTitle">Foreword</h1>
         <div align="right">
            <b>Units in mm</b>
         </div>
         <div id="figureA-1" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
            <img src="rice_images/rice_image1.png" height="20" width="30" title="titletxt" alt="alttext"/>
            <img src="rice_images/rice_image1.png" height="20" width="auto"/>
            <img src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto"/>
            <img src="data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==" height="20" width="auto"/>
            <a href="#figureA-1a" class="TableFootnoteRef">a)</a>
            <p class="ListTitle">
               Key
               <a id="DL1"/>
            </p>
            <p class="dl">A: B</p>
            <div class="BlockSource">
               <p>
                  [SOURCE:
                  <a href="#ISO712">ISO 712, Section 1</a>
                  — with adjustments]
               </p>
            </div>
            <div id="note1" class="Note">
               <p>
                  <span class="note_label">NOTE  </span>
               </p>
               This is a note
            </div>
            <aside id="fn:figureA-1a" class="footnote">
               <p id="_">
                  <span class="TableFootnoteRef">Footnote a)</span>
                    The time
                  <span class="stem">(#(t_90)#)</span>
                  was estimated to be 18,2 min for this example.
               </p>
            </aside>
            <p class="FigureTitle" style="text-align:center;">
               Figure 1 — Split-it-right
               <i>sample</i>
               divider
               <a class="FootnoteRef" href="#fn:_">
                  <sup>1</sup>
               </a>
            </p>
         </div>
         <div id="figure-B" class="figure">
            <pre>A &lt;
        B</pre>
            <p class="FigureTitle" style="text-align:center;">Figure 2</p>
         </div>
         <div id="figure-C" class="figure">
            <pre>A &lt;
        B</pre>
         </div>
      </div>
    OUTPUT
    word = <<~OUTPUT
      <div id="A">
         <h1 class="ForewordTitle">Foreword</h1>
         <table id="figureA-1" class="MsoTableGrid" style="border-collapse:collapse;border:none;mso-padding-alt: 0cm 5.4pt 0cm 5.4pt;mso-border-insideh:none;mso-border-insidev:none;page-break-after: avoid;page-break-inside: avoid;" border="0" cellspacing="0" cellpadding="0">
            <tr>
               <td valign="top" style="padding:0cm 5.4pt 0cm 5.4pt">
                  <p class="UnitStatement">Units in mm</p>
               </td>
            </tr>
            <tr>
               <td valign="top" style="padding:0cm 5.4pt 0cm 5.4pt">
                  <p class="Figure">
                     <img src="rice_images/rice_image1.png" height="20" alt="alttext" title="titletxt" width="30"/>
                  </p>
               </td>
            </tr>
            <tr>
               <td valign="top" style="padding:0cm 5.4pt 0cm 5.4pt">
                  <p class="ForewordText">
                     Key
                     <a id="DL1"/>
                  </p>
                  <p class="ForewordText">A: B</p>
               </td>
            </tr>
            <tr>
               <td valign="top" style="padding:0cm 5.4pt 0cm 5.4pt">
                  <div id="note1" class="Note">
                     <p class="Note">
                        <span class="note_label">
                           NOTE
                           <span style="mso-tab-count:1">  </span>
                        </span>
                     </p>
                     This is a note
                  </div>
               </td>
            </tr>
            <tr>
               <td valign="top" style="padding:0cm 5.4pt 0cm 5.4pt">
                  <div class="BlockSource">
                     <p>
                        [SOURCE:
                        <a href="#ISO712">ISO 712, Section 1</a>
                        — with adjustments]
                     </p>
                  </div>
               </td>
            </tr>
            <tr>
               <td valign="top" style="padding:0cm 5.4pt 0cm 5.4pt">
                  <p class="Tabletitle" style="text-align:center;">
                     Figure 1 — Split-it-right
                     <i>sample</i>
                     divider
                     <span style="mso-bookmark:_Ref" class="MsoFootnoteReference">
                        <a class="FootnoteRef" epub:type="footnote" href="#fn:_">1</a>
                     </span>
                  </p>
               </td>
            </tr>
         </table>
         <table id="figure-B" class="MsoTableGrid" style="border-collapse:collapse;border:none;mso-padding-alt: 0cm 5.4pt 0cm 5.4pt;mso-border-insideh:none;mso-border-insidev:none;" border="0" cellspacing="0" cellpadding="0">
            <tr>
               <td valign="top" style="padding:0cm 5.4pt 0cm 5.4pt">
                  <p class="Tabletitle" style="text-align:center;">Figure 2</p>
               </td>
            </tr>
         </table>
         <table id="figure-C" class="MsoTableGrid" style="border-collapse:collapse;border:none;mso-padding-alt: 0cm 5.4pt 0cm 5.4pt;mso-border-insideh:none;mso-border-insidev:none;" border="0" cellspacing="0" cellpadding="0"/>
      </div>
    OUTPUT
    pres_output = IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Jis::HtmlConvert
      .new({})
      .convert("test", pres_output, true))
      .at("//div[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(html)
    FileUtils.rm_rf "spec/assets/odf1.emf"
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Jis::WordConvert
      .new({})
      .convert("test", pres_output, true))
      .at("//div[@id = 'A']").to_xml)
      .gsub(/['"][^'".]+\.(gif|xml)['"]/, "'_.\\1'")
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes subfigures" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
           <preface><foreword>
           <figure id="figureA-1" keep-with-next="true" keep-lines-together="true">
         <name>Overall title</name>
         <figure id="note1">
       <name>Subfigure 1</name>
         <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
         </figure>
         <figure id="note2">
       <name>Subfigure 2</name>
         <image src="rice_images/rice_image1.png" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f1" mimetype="image/png"/>
         </figure>
       </figure>
           </foreword></preface>
           </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <foreword displayorder="1" id="_">
         <title id="_">Foreword</title>
         <fmt-title depth="1">
            <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <figure id="figureA-1" keep-with-next="true" keep-lines-together="true" autonum="1">
            <name id="_">Overall title</name>
            <fmt-name>
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="figureA-1">1</semx>
               </span>
               <span class="fmt-caption-delim"> — </span>
               <semx element="name" source="_">Overall title</semx>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Figure</span>
               <semx element="autonum" source="figureA-1">1</semx>
            </fmt-xref-label>
            <figure id="note1" autonum="1 a">
               <name id="_">Subfigure 1</name>
               <fmt-name>
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="note1">a</semx>
                     <span class="fmt-label-delim">)</span>
                  </span>
                  <span class="fmt-caption-delim">  </span>
                  <semx element="name" source="_">Subfigure 1</semx>
               </fmt-name>
               <fmt-xref-label>
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="figureA-1">1</semx>
                  <span class="fmt-autonum-delim"> </span>
                  <semx element="autonum" source="note1">a</semx>
                  <span class="fmt-autonum-delim">)</span>
               </fmt-xref-label>
               <image src="rice_images/rice_image1.png" height="20" width="30" id="_" mimetype="image/png" alt="alttext" title="titletxt"/>
            </figure>
            <figure id="note2" autonum="1 b">
               <name id="_">Subfigure 2</name>
               <fmt-name>
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="note2">b</semx>
                     <span class="fmt-label-delim">)</span>
                  </span>
                  <span class="fmt-caption-delim">  </span>
                  <semx element="name" source="_">Subfigure 2</semx>
               </fmt-name>
               <fmt-xref-label>
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="figureA-1">1</semx>
                  <span class="fmt-autonum-delim"> </span>
                  <semx element="autonum" source="note2">b</semx>
                  <span class="fmt-autonum-delim">)</span>
               </fmt-xref-label>
               <image src="rice_images/rice_image1.png" height="20" width="auto" id="_" mimetype="image/png"/>
            </figure>
         </figure>
      </foreword>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
             <br/>
             <div id="_">
                            <h1 class="ForewordTitle">Foreword</h1>
               <div id="figureA-1" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                 <div id="note1" class="figure">
                   <img src="rice_images/rice_image1.png" height="20" width="30" title="titletxt" alt="alttext"/>
                   <p class="FigureTitle" style="text-align:center;">a)  Subfigure 1</p>
                 </div>
                 <div id="note2" class="figure">
                   <img src="rice_images/rice_image1.png" height="20" width="auto"/>
                   <p class="FigureTitle" style="text-align:center;">b)  Subfigure 2</p>
                 </div>
                 <p class="FigureTitle" style="text-align:center;">Figure 1 — Overall title</p>
               </div>
             </div>
                   <br/>
      <div id="_" class="TOC">
        <h1 class="IntroTitle">Contents</h1>
      </div>
           </div>
         </body>
       </html>
    OUTPUT
    word = <<~OUTPUT
         <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
       <head>
         <style> </style>
         <style> </style>
       </head>
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
            <div id="_">
              <h1 class="ForewordTitle">Foreword</h1>
              <table id="figureA-1" class="MsoTableGrid" style="border-collapse:collapse;border:none;mso-padding-alt: 0cm 5.4pt 0cm 5.4pt;mso-border-insideh:none;mso-border-insidev:none;page-break-after: avoid;page-break-inside: avoid;" border="0" cellspacing="0" cellpadding="0">
                <tr>
                  <td valign="top" style="padding:0cm 5.4pt 0cm 5.4pt">
                    <p class="Figure">
                      <img src="rice_images/rice_image1.png" height="20" alt="alttext" title="titletxt" width="30"/>
                    </p>
                  </td>
                </tr>
                <tr>
                  <td valign="top" style="padding:0cm 5.4pt 0cm 5.4pt">
                    <p class="SubfigureCaption">a)  Subfigure 1</p>
                  </td>
                </tr>
                <tr>
                  <td valign="top" style="padding:0cm 5.4pt 0cm 5.4pt">
                    <p class="Figure">
                      <img src="rice_images/rice_image1.png" height="20" width="auto"/>
                    </p>
                  </td>
                </tr>
                <tr>
                  <td valign="top" style="padding:0cm 5.4pt 0cm 5.4pt">
                    <p class="SubfigureCaption">b)  Subfigure 2</p>
                  </td>
                </tr>
                <tr>
                  <td valign="top" style="padding:0cm 5.4pt 0cm 5.4pt">
                    <p class="Tabletitle" style="text-align:center;">Figure 1 — Overall title</p>
                  </td>
                </tr>
              </table>
            </div>
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
          </div>
          <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
          <div class="colophon"/>
        </body>
      </html>
    OUTPUT
    pres_output = IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Jis::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    FileUtils.rm_rf "spec/assets/odf1.emf"
    expect(Xml::C14n.format(strip_guid(IsoDoc::Jis::WordConvert.new({})
      .convert("test", pres_output, true)
      .gsub(/['"][^'".]+\.(gif|xml)['"]/, "'_.\\1'")
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref"))))
      .to be_equivalent_to Xml::C14n.format(word)
  end

    it "processes unordered lists" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <clause type="toc" id="_" displayorder="1"> <fmt-title depth="1">Table of contents</fmt-title> </clause>
          <foreword displayorder="2" id="fwd"><fmt-title>Foreword</fmt-title>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddb"  keep-with-next="true" keep-lines-together="true">
          <name>Caption</name>
        <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a2">Level 1</p>
        </li>
        <li>
          <p id="_60eb765c-1f6c-418a-8016-29efa06bf4f9">deletion of 4.3.</p>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddc"  keep-with-next="true" keep-lines-together="true">
          <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a3">Level 2</p>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddc"  keep-with-next="true" keep-lines-together="true">
          <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a3">Level 3</p>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddc"  keep-with-next="true" keep-lines-together="true">
          <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a3">Level 4</p>
        </li>
        </ul>
        </li>
        </ul>
        </li>
          </ul>
        </li>
      </ul>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
            <foreword displayorder="1" id="fwd">
               <title id="_">Foreword</title>
               <fmt-title depth="1">Foreword</fmt-title>
               <ul id="_" keep-with-next="true" keep-lines-together="true">
                  <name id="_">Caption</name>
                  <fmt-name>
                     <semx element="name" source="_">Caption</semx>
                  </fmt-name>
                  <li>
                     <fmt-name>
                        <semx element="autonum" source="">－</semx>
                     </fmt-name>
                     <p id="_">Level 1</p>
                  </li>
                  <li>
                     <fmt-name>
                        <semx element="autonum" source="">－</semx>
                     </fmt-name>
                     <p id="_">deletion of 4.3.</p>
                     <ul id="_" keep-with-next="true" keep-lines-together="true">
                        <li>
                           <fmt-name>
                              <semx element="autonum" source="">・</semx>
                           </fmt-name>
                           <p id="_">Level 2</p>
                           <ul id="_" keep-with-next="true" keep-lines-together="true">
                              <li>
                                 <fmt-name>
                                    <semx element="autonum" source="">－</semx>
                                 </fmt-name>
                                 <p id="_">Level 3</p>
                                 <ul id="_" keep-with-next="true" keep-lines-together="true">
                                    <li>
                                       <fmt-name>
                                          <semx element="autonum" source="">・</semx>
                                       </fmt-name>
                                       <p id="_">Level 4</p>
                                    </li>
                                 </ul>
                              </li>
                           </ul>
                        </li>
                     </ul>
                  </li>
               </ul>
            </foreword>
            <clause type="toc" id="_" displayorder="2">
               <fmt-title depth="1">Table of contents</fmt-title>
            </clause>
         </preface>
      </iso-standard>
    INPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Jis::PresentationXMLConvert
          .new(presxml_options)
         .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes ordered lists" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <ol id="A">
      <li id="A1">
      <ol id="B">
      <li id="B1">
      <ol id="C">
      <li id="C1">
      <ol id="D">
      <li id="D1">
      <ol id="E">
      <li id="E1">
      </li>
      <li id="E2">
      </li>
      </ol>
      </li>
      <li id="D2">
      </li>
      </ol>
      </li>
      <li id="C2">
      </li>
      </ol>
      </li>
      <li id="B2">
      <ol id="CC">
      <li id="CC1"></li>
      </ol>
      </li>
      </ol>
      </li>
      <li id="A2">
      <ol id="BB">
      <li id="BB1"></li>
      </ol>
      </li>
      </ol>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <foreword id="_" displayorder="1">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <ol id="A" type="alphabet">
                   <li id="A1">
                      <fmt-name>
                         <semx element="autonum" source="A1">a</semx>
                         <span class="fmt-label-delim">)</span>
                      </fmt-name>
                      <ol id="B" type="arabic">
                         <li id="B1">
                            <fmt-name>
                               <semx element="autonum" source="B1">1</semx>
                               <span class="fmt-label-delim">)</span>
                            </fmt-name>
                            <ol id="C" type="arabic">
                               <li id="C1">
                                  <fmt-name>
                                     <semx element="autonum" source="C1">1.1</semx>
                                     <span class="fmt-label-delim">)</span>
                                  </fmt-name>
                                  <ol id="D" type="arabic">
                                     <li id="D1">
                                        <fmt-name>
                                           <semx element="autonum" source="D1">1.1.1</semx>
                                           <span class="fmt-label-delim">)</span>
                                        </fmt-name>
                                        <ol id="E" type="arabic">
                                           <li id="E1">
                                              <fmt-name>
                                                 <semx element="autonum" source="E1">1.1.1.1</semx>
                                                 <span class="fmt-label-delim">)</span>
                                              </fmt-name>
                                           </li>
                                           <li id="E2">
                                              <fmt-name>
                                                 <semx element="autonum" source="E2">1.1.1.2</semx>
                                                 <span class="fmt-label-delim">)</span>
                                              </fmt-name>
                                           </li>
                                        </ol>
                                     </li>
                                     <li id="D2">
                                        <fmt-name>
                                           <semx element="autonum" source="D2">1.1.2</semx>
                                           <span class="fmt-label-delim">)</span>
                                        </fmt-name>
                                     </li>
                                  </ol>
                               </li>
                               <li id="C2">
                                  <fmt-name>
                                     <semx element="autonum" source="C2">1.2</semx>
                                     <span class="fmt-label-delim">)</span>
                                  </fmt-name>
                               </li>
                            </ol>
                         </li>
                         <li id="B2">
                            <fmt-name>
                               <semx element="autonum" source="B2">2</semx>
                               <span class="fmt-label-delim">)</span>
                            </fmt-name>
                            <ol id="CC" type="arabic">
                               <li id="CC1">
                                  <fmt-name>
                                     <semx element="autonum" source="CC1">2.1</semx>
                                     <span class="fmt-label-delim">)</span>
                                  </fmt-name>
                               </li>
                            </ol>
                         </li>
                      </ol>
                   </li>
                   <li id="A2">
                      <fmt-name>
                         <semx element="autonum" source="A2">b</semx>
                         <span class="fmt-label-delim">)</span>
                      </fmt-name>
                      <ol id="BB" type="arabic">
                         <li id="BB1">
                            <fmt-name>
                               <semx element="autonum" source="BB1">1</semx>
                               <span class="fmt-label-delim">)</span>
                            </fmt-name>
                         </li>
                      </ol>
                   </li>
                </ol>
             </foreword>
             <clause type="toc" id="_" displayorder="2">
                <fmt-title depth="1">Contents</fmt-title>
             </clause>
          </preface>
       </iso-standard>
    INPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
     .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)

    input.sub!("<preface>", <<~SUB
      <metanorma-extension>
      <presentation-metadata><autonumbering-style>japanese</autonumbering-style></presentation-metadata>
      </metanorma-extension><preface>
    SUB
    )
    presxml = <<~INPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <metanorma-extension>
             <presentation-metadata>
                <autonumbering-style>japanese</autonumbering-style>
             </presentation-metadata>
          </metanorma-extension>
          <preface>
             <foreword id="_" displayorder="1">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <ol id="A" type="alphabet">
                   <li id="A1">
                      <fmt-name>
                         <semx element="autonum" source="A1">a</semx>
                         <span class="fmt-label-delim">)</span>
                      </fmt-name>
                      <ol id="B" type="arabic">
                         <li id="B1">
                            <fmt-name>
                               <semx element="autonum" source="B1">一</semx>
                               <span class="fmt-label-delim">)</span>
                            </fmt-name>
                            <ol id="C" type="arabic">
                               <li id="C1">
                                  <fmt-name>
                                     <semx element="autonum" source="C1">一・一</semx>
                                     <span class="fmt-label-delim">)</span>
                                  </fmt-name>
                                  <ol id="D" type="arabic">
                                     <li id="D1">
                                        <fmt-name>
                                           <semx element="autonum" source="D1">一・一・一</semx>
                                           <span class="fmt-label-delim">)</span>
                                        </fmt-name>
                                        <ol id="E" type="arabic">
                                           <li id="E1">
                                              <fmt-name>
                                                 <semx element="autonum" source="E1">一・一・一・一</semx>
                                                 <span class="fmt-label-delim">)</span>
                                              </fmt-name>
                                           </li>
                                           <li id="E2">
                                              <fmt-name>
                                                 <semx element="autonum" source="E2">一・一・一・二</semx>
                                                 <span class="fmt-label-delim">)</span>
                                              </fmt-name>
                                           </li>
                                        </ol>
                                     </li>
                                     <li id="D2">
                                        <fmt-name>
                                           <semx element="autonum" source="D2">一・一・二</semx>
                                           <span class="fmt-label-delim">)</span>
                                        </fmt-name>
                                     </li>
                                  </ol>
                               </li>
                               <li id="C2">
                                  <fmt-name>
                                     <semx element="autonum" source="C2">一・二</semx>
                                     <span class="fmt-label-delim">)</span>
                                  </fmt-name>
                               </li>
                            </ol>
                         </li>
                         <li id="B2">
                            <fmt-name>
                               <semx element="autonum" source="B2">二</semx>
                               <span class="fmt-label-delim">)</span>
                            </fmt-name>
                            <ol id="CC" type="arabic">
                               <li id="CC1">
                                  <fmt-name>
                                     <semx element="autonum" source="CC1">二・一</semx>
                                     <span class="fmt-label-delim">)</span>
                                  </fmt-name>
                               </li>
                            </ol>
                         </li>
                      </ol>
                   </li>
                   <li id="A2">
                      <fmt-name>
                         <semx element="autonum" source="A2">b</semx>
                         <span class="fmt-label-delim">)</span>
                      </fmt-name>
                      <ol id="BB" type="arabic">
                         <li id="BB1">
                            <fmt-name>
                               <semx element="autonum" source="BB1">一</semx>
                               <span class="fmt-label-delim">)</span>
                            </fmt-name>
                         </li>
                      </ol>
                   </li>
                </ol>
             </foreword>
             <clause type="toc" id="_" displayorder="2">
                <fmt-title depth="1">Contents</fmt-title>
             </clause>
          </preface>
       </iso-standard>
    INPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
     .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end
end
