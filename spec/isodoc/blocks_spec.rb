require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc::Jis do
  it "processes figures" do
    input = <<~INPUT
                <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><foreword>
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
            <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
            <foreword displayorder="1">
              <figure id="figureA-1" keep-with-next="true" keep-lines-together="true">
                <name>
                  Figure 1 — Split-it-right
                  <em>sample</em>
                  divider
                  <fn reference="1">
                    <p>X</p>
                  </fn>
                </name>
                <image src="rice_images/rice_image1.png" height="20" width="30" id="_" mimetype="image/png" alt="alttext" title="titletxt"/>
                <image src="rice_images/rice_image1.png" height="20" width="auto" id="_" mimetype="image/png"/>
                <image src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto" id="_" mimetype="image/png"/>
                <image src="data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==" height="20" width="auto" id="_" mimetype="application/xml"/>
                <fn reference="a">
                  <p id="_">
                    The time
                    <stem type="AsciiMath">t_90</stem>
                    was estimated to be 18,2 min for this example.
                  </p>
                </fn>
                <p class="ListTitle">Key
            <bookmark id="DL1"/>
          </p>
                <p class="dl">A: B</p>
                <source status="generalisation">[SOURCE:
                         <xref type="inline" target="ISO712">ISO 712, Section 1</xref>
                   &#x2014; with adjustments]</source>
                   <note id="note1">
            <name>NOTE</name>
            This is a note
          </note>
          <note id="note2" type="units">Units in mm</note>
              </figure>
              <figure id="figure-B">
                <name>Figure 2</name>
                <pre alt="A B">A &lt;
          B</pre>
              </figure>
              <figure id="figure-C" unnumbered="true">
                <pre>A &lt;
          B</pre>
              </figure>
            </foreword>
                <clause type="toc" id="_" displayorder="2">
        <title depth="1">Contents</title>
      </clause>
          </preface>
          <sections>
           <p class="JapaneseIndustrialStandard" displayorder="3">
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
           <p class="StandardNumber" displayorder="4">
             <tab/>
           </p>
           <p class="IDT" displayorder="5"/>
            <references id="_" obligation="informative" normative="true" displayorder="6">
              <title depth="1">
                1
                <tab/>
                Normative References
              </title>
              <bibitem id="ISO712" type="standard">
                <formattedref>
                    <span class="stddocTitle">Cereals and cereal products</span>
                </formattedref>
                <docidentifier type="ISO">ISO 712</docidentifier>
                <docidentifier scope="biblio-tag">ISO 712</docidentifier>
                <biblio-tag>ISO 712, </biblio-tag>
              </bibitem>
            </references>
          </sections>
          <bibliography/>
        </iso-standard>
    OUTPUT
    html = <<~OUTPUT
           <html lang="en">
         <head/>
         <body lang="en">
           <div class="title-section">
             <p> </p>
           </div>
           <br/>
           <div class="prefatory-section">
             <p> </p>
           </div>
           <br/>
           <div class="main-section">
             <br/>
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <div align="right">
           <b>Units in mm</b>
         </div>
               <div id="figureA-1" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                 <img src="rice_images/rice_image1.png" height="20" width="30" title="titletxt" alt="alttext"/>
                 <img src="rice_images/rice_image1.png" height="20" width="auto"/>
                 <img src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto"/>
                 <img src="data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==" height="20" width="auto"/>
                 <a href="#_" class="TableFootnoteRef">a</a>
                 <aside class="footnote">
                   <div id="fn:_">
                     <span>
                       Footnote
                       <span id="_" class="TableFootnoteRef">a)</span>
                        
                     </span>
                     <p id="_">
                       The time
                       <span class="stem">(#(t_90)#)</span>
                       was estimated to be 18,2 min for this example.
                     </p>
                   </div>
                 </aside>
                 <p class="ListTitle">
             Key
             <a id="DL1"/>
           </p>
                 <p class="dl">A: B</p>
                 <div class="BlockSource">
                    <p>
                      [SOURCE:
                      <a href="#ISO712">
                     ISO 712, Section 1
                   </a>
                      &#x2014; with adjustments]
                    </p>
                  </div>
                 <div id="note1" class="Note">
             <p>
               <span class="note_label">NOTE</span>
                
             </p>
             This is a note
           </div>
                 <p class="FigureTitle" style="text-align:center;">
                   Figure 1 — Split-it-right
                   <i>sample</i>
                   divider
                   <a class="FootnoteRef" href="#fn:1">
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
                  <br/>
      <div id="_" class="TOC">
        <h1 class="IntroTitle">Contents</h1>
      </div>
      #{middle_title(false)}
             <div>
               <h1>
               1
                
               Normative References
             </h1>
               <p id="ISO712" class="NormRef">
                 ISO 712,
                   <span class="stddocTitle">Cereals and cereal products</span>
               </p>
             </div>
             <aside id="fn:1" class="footnote">
               <p>X</p>
             </aside>
           </div>
         </body>
       </html>
    OUTPUT
    word = <<~OUTPUT
      <html lang="en">
       <head><style></style><style></style></head>
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
            <div>
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
                      <p class="ForewordText">Key <a id="DL1"/></p>
                     <p class="ForewordText">A: B</p>
                  </td>
                </tr>
                <tr>
            <td valign="top" style="padding:0cm 5.4pt 0cm 5.4pt">
              <div id="note1" class="Note">
                <p class="Note">
                  <span class="note_label">NOTE</span>
                  <span style="mso-tab-count:1">  </span>
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
                         <a href="#ISO712">
                    ISO 712, Section 1
                  </a>
                         &#x2014; with adjustments]
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
                      <a href="#_" class="TableFootnoteRef">1</a>
                      <aside>
                        <div id="ftn_">
                          <span>
                            Footnote
                            <span id="_" class="TableFootnoteRef">1)</span>
                            <span style="mso-tab-count:1">  </span>
                          </span>
                          <p>X</p>
                        </div>
                      </aside>
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
            <div class="normref_div">
              <h1>
                1
                <span style="mso-tab-count:1">  </span>
                Normative References
              </h1>
              <p id="ISO712" class="NormRef">
                ISO 712,
                  <span class="stddocTitle">Cereals and cereal products</span>
              </p>
            </div>
          </div>
          <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
          <div class="colophon"/>
        </body>
      </html>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true).gsub("&lt;", "&#x3c;"))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Jis::HtmlConvert.new({})
      .convert("test", presxml, true)))).to be_equivalent_to Xml::C14n.format(html)
    FileUtils.rm_rf "spec/assets/odf1.emf"
    expect(Xml::C14n.format(strip_guid(IsoDoc::Jis::WordConvert.new({})
      .convert("test", presxml, true)
      .gsub(/['"][^'".]+\.(gif|xml)['"]/, "'_.\\1'")
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref"))))
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
        <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
            <foreword displayorder="1">
              <figure id="figureA-1" keep-with-next="true" keep-lines-together="true">
                <name>Figure 1 — Overall title</name>
                <figure id="note1">
                  <name>a)  Subfigure 1</name>
                  <image src="rice_images/rice_image1.png" height="20" width="30" id="_" mimetype="image/png" alt="alttext" title="titletxt"/>
                </figure>
                <figure id="note2">
                  <name>b)  Subfigure 2</name>
                  <image src="rice_images/rice_image1.png" height="20" width="auto" id="_" mimetype="image/png"/>
                </figure>
              </figure>
            </foreword>
                <clause type="toc" id="_" displayorder="2">
        <title depth="1">Contents</title>
      </clause>
          </preface>
        </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
             <br/>
             <div>
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
            <div>
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
    expect(Xml::C14n.format(strip_guid(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true).gsub("&lt;", "&#x3c;"))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Jis::HtmlConvert.new({})
      .convert("test", presxml, true)))).to be_equivalent_to Xml::C14n.format(html)
    FileUtils.rm_rf "spec/assets/odf1.emf"
    expect(Xml::C14n.format(strip_guid(IsoDoc::Jis::WordConvert.new({})
      .convert("test", presxml, true)
      .gsub(/['"][^'".]+\.(gif|xml)['"]/, "'_.\\1'")
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref"))))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes admonitions with titles" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="caution">
          <name>Title</name>
          <ul>
          <li>List</li>
          </ul>
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml" type='presentation'>
            <preface><foreword displayorder="1">
            <admonition id="_" type="caution">
            <name>Title</name>
            <ul>
            <li>List</li>
            </ul>
          <p id="_">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
        </admonition>
            </foreword>
                <clause type="toc" id="_" displayorder="2">
        <title depth="1">Contents</title>
      </clause>
            </preface>
            </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                    <br/>
             <div>
             <h1 class="ForewordTitle">Foreword</h1>
                      <div id="_" class="Admonition">
                 <p>
                   <span class="note_label">Title — </span>
                 </p>
                 <div class="ul_wrap">
                 <ul>
                   <li>List</li>
                 </ul>
                 </div>
                 <p id="_">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
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
    expect(Xml::C14n.format(strip_guid(IsoDoc::Jis::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::Jis::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to Xml::C14n.format(output)
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
          <foreword displayorder="1">
            <ol id="A" type="alphabet">
              <li id="A1" label="a">
                <ol id="B" type="arabic">
                  <li id="B1" label="1">
                    <ol id="C" type="arabic">
                      <li id="C1" label="1.1">
                        <ol id="D" type="arabic">
                          <li id="D1" label="1.1.1">
                            <ol id="E" type="arabic">
                              <li id="E1" label="1.1.1.1">
      </li>
                              <li id="E2" label="1.1.1.2">
      </li>
                            </ol>
                          </li>
                          <li id="D2" label="1.1.2">
      </li>
                        </ol>
                      </li>
                      <li id="C2" label="1.2">
      </li>
                    </ol>
                  </li>
                  <li id="B2" label="2">
                    <ol id="CC" type="arabic">
                      <li id="CC1" label="2.1"/>
                    </ol>
                  </li>
                </ol>
              </li>
              <li id="A2" label="b">
                <ol id="BB" type="arabic">
                  <li id="BB1" label="1"/>
                </ol>
              </li>
            </ol>
          </foreword>
          <clause type="toc" id="_" displayorder="2">
            <title depth="1">Contents</title>
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
