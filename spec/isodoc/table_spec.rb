require "spec_helper"

RSpec.describe IsoDoc do
  it "processes IsoXML tables" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <table alt="tool tip" id="tableD-1" summary="long desc">
              <name>Repeatability and reproducibility of
                <em>husked</em>
                rice yield<fn reference="1">
                      <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Name footnote.</p></fn></name>
              <thead>
                <tr>
                  <td align="left" rowspan="2">Description</td>
                  <td align="center" colspan="4">Rice sample</td>
                </tr>
                <tr>
                  <td align="left">Arborio</td>
                  <td align="center">Drago
                    <fn reference="a">
                      <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p></fn>
                  </td>
                  <td align="center">Balilla
                    <fn reference="a">
                      <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p></fn>
                  </td>
                  <td align="center">Thaibonnet</td>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <th align="left">Number of laboratories retained after eliminating outliers</th>
                  <td align="center">13</td>
                  <td align="center">11</td>
                  <td align="center">13</td>
                  <td align="center">13</td>
                </tr>
                <tr>
                  <td align="left">Mean value, g/100 g</td>
                  <td align="center">81,2</td>
                  <td align="center">82,0</td>
                  <td align="center">81,8</td>
                  <td align="center">77,7</td>
                </tr>
              </tbody>
              <tfoot>
                <tr>
                  <td align="left">Reproducibility limit,
                    <stem type="AsciiMath">R</stem>
                    (= 2,83
                    <stem type="AsciiMath">s_R</stem>
                    )</td>
                  <td align="center">2,89</td>
                  <td align="center">0,57</td>
                  <td align="center">2,26</td>
                  <td align="center">6,06</td>
                </tr>
              </tfoot>
              <dl>
                <dt>Drago</dt>
                <dd>A type of rice</dd>
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
          <source status="generalisation">
        <origin bibitemid="ISO713" type="inline" citeas="">
          <localityStack>
            <locality type="section">
              <referenceFrom>3</referenceFrom>
            </locality>
          </localityStack>
        </origin>
        <modification>
          <p id="_">with alterations</p>
        </modification>
      </source>
              <note>
                <p>This is a table about rice</p>
              </note>
            </table>
          </foreword>
        </preface>
        <sections>
        <clause/>
        </sections>
        <annex id="Annex"><title>Annex</title>
        <table id="AnnexTable">
        <name>Another table</name>
        <tbody><tr><td>?</td></tr></tbody>
        </table>
        </annex>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
           <foreword displayorder="1">
             <table alt="tool tip" id="tableD-1" summary="long desc">
               <name>
                Table 1 — Repeatability and reproducibility of
                <em>husked</em>
                rice yield
                <fn reference="1">
                  <p id="_">Name footnote.</p>
                </fn>
              </name>
               <thead>
                 <tr>
                   <td align="left" rowspan="2">Description</td>
                   <td align="center" colspan="4">Rice sample</td>
                 </tr>
                 <tr>
                   <td align="left">Arborio</td>
                   <td align="center">
                     Drago
                     <fn reference="a">
                       <p id="_">Parboiled rice.</p>
                     </fn>
                   </td>
                   <td align="center">
                     Balilla
                     <fn reference="a">
                       <p id="_">Parboiled rice.</p>
                     </fn>
                   </td>
                   <td align="center">Thaibonnet</td>
                 </tr>
               </thead>
               <tbody>
                 <tr>
                   <th align="left">Number of laboratories retained after eliminating outliers</th>
                   <td align="center">13</td>
                   <td align="center">11</td>
                   <td align="center">13</td>
                   <td align="center">13</td>
                 </tr>
                 <tr>
                   <td align="left">Mean value, g/100 g</td>
                   <td align="center">81,2</td>
                   <td align="center">82,0</td>
                   <td align="center">81,8</td>
                   <td align="center">77,7</td>
                 </tr>
               </tbody>
               <tfoot>
                 <tr>
                   <td align="left">
                     Reproducibility limit,
                     <stem type="AsciiMath">R</stem>
                     (= 2,83
                     <stem type="AsciiMath">s_R</stem>
                     )
                   </td>
                   <td align="center">2,89</td>
                   <td align="center">0,57</td>
                   <td align="center">2,26</td>
                   <td align="center">6,06</td>
                 </tr>
               </tfoot>
               <p class="ListTitle">Key</p>
               <p class="dl">Drago: A type of rice</p>
               <source status="generalisation">SOURCE:
                 <origin bibitemid="ISO712" type="inline" citeas="">
                   <localityStack>
                     <locality type="section">
                       <referenceFrom>1</referenceFrom>
                     </locality>
                   </localityStack>
                   , Section 1
                 </origin>
                   &#x2014; with adjustments ;
               <origin bibitemid="ISO713" type="inline" citeas="">
            <localityStack>
              <locality type="section">
                <referenceFrom>3</referenceFrom>
              </locality>
            </localityStack>
            , Section 3
          </origin>
          &#x2014; with alterations
               </source>
               <note>
                 <name>NOTE 1</name>
                 <p>This is a table about rice</p>
               </note>
             </table>
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
            <clause displayorder="6"/>
            </sections>
         <annex id="Annex" displayorder="7">
           <title>
             Annex A
             <br/>
             (informative)
             <br/>
             <strong>Annex</strong>
           </title>
           <table id="AnnexTable">
               <name>Table A.1 — Another table</name>
               <thead> </thead>
             <tbody>
               <tr>
                 <td>?</td>
               </tr>
             </tbody>
           </table>
         </annex>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      <main class="main-section">
         <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
         <br/>
         <div>
           <h1 class="ForewordTitle" id="_">Foreword</h1>
           <table id="tableD-1" class="MsoISOTable" style="border-width:1px;border-spacing:0;" title="tool tip">
             <caption>
               <span style="display:none">long desc</span>
             </caption>
             <thead>
               <tr>
                 <td colspan="5" style=";text-align:center;vertical-align:middle;" scope="colgroup">
                   <p class="TableTitle"  style="text-align:center;;">
                     Table 1 — Repeatability and reproducibility of
                     <i>husked</i>
                     rice yield<a href="#tableD-11" class="TableFootnoteRef">1</a>
                   </p>
                 </td>
               </tr>
               <tr>
                 <td rowspan="2" style="text-align:left;border-top:none;border-bottom:solid windowtext 1.5pt;;text-align:center;vertical-align:middle;" scope="col">Description</td>
                 <td colspan="4" style="text-align:center;border-top:none;border-bottom:solid windowtext 1.0pt;;text-align:center;vertical-align:middle;" scope="colgroup">Rice sample</td>
               </tr>
               <tr>
                 <td style="text-align:left;border-top:none;border-bottom:solid windowtext 1.5pt;;text-align:center;vertical-align:middle;" scope="col">Arborio</td>
                 <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;;text-align:center;vertical-align:middle;" scope="col">
                   Drago
                   <a href="#tableD-1a" class="TableFootnoteRef">a</a>
                 </td>
                 <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;;text-align:center;vertical-align:middle;" scope="col">
                   Balilla
                   <a href="#tableD-1a" class="TableFootnoteRef">a</a>
                 </td>
                 <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;;text-align:center;vertical-align:middle;" scope="col">Thaibonnet</td>
               </tr>
             </thead>
             <tbody>
               <tr>
                 <th style="font-weight:bold;text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;" scope="row">Number of laboratories retained after eliminating outliers</th>
                 <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
                 <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">11</td>
                 <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
                 <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
               </tr>
               <tr>
                 <td style="text-align:left;border-top:none;border-bottom:solid windowtext 1.5pt;">Mean value, g/100 g</td>
                 <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">81,2</td>
                 <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">82,0</td>
                 <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">81,8</td>
                 <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">77,7</td>
               </tr>
             </tbody>
             <tfoot>
               <tr>
                 <td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:0pt;">
                   Reproducibility limit,
                   <span class="stem">(#(R)#)</span>
                   (= 2,83
                   <span class="stem">(#(s_R)#)</span>
                   )
                 </td>
                 <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:0pt;">2,89</td>
                 <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:0pt;">0,57</td>
                 <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:0pt;">2,26</td>
                 <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:0pt;">6,06</td>
               </tr>
               <tr>
                 <td colspan="5" style="border-top:0pt;border-bottom:solid windowtext 1.5pt;">
                 <p class="ListTitle">Key</p>
                <p class="dl">Drago: A type of rice</p>
                   <div class="BlockSource">
                     <p>SOURCE:


                    , Section 1

                  &#x2014; with adjustments ;      , Section 3
                 &#x2014; with alterations
                </p>
                   </div>
                   <div class="Note">
                     <p>
                       <span class="note_label">NOTE 1</span>
                         This is a table about rice
                     </p>
                   </div>
                   <div class="TableFootnote">
              <div id="fn:tableD-11">
                <p id="_" class="TableFootnote">
                  <span>
                    Footnote
                    <span id="tableD-11" class="TableFootnoteRef">1)</span>
                     
                  </span>
                  Name footnote.
                </p>
              </div>
            </div>
                   <div class="TableFootnote">
                     <div id="fn:tableD-1a">
                       <p id="_" class="TableFootnote">
                         <span>
                           Footnote
                           <span id="tableD-1a" class="TableFootnoteRef">a)</span>
                            
                         </span>
                         Parboiled rice.
                       </p>
                     </div>
                   </div>
                 </td>
               </tr>
             </tfoot>
           </table>
         </div>
         <br/>
                     #{middle_title(false)}
                     <div><h1/></div>
         <br/>
         <div id="Annex" class="Section3">
           <h1 class="Annex" id="_">
          <a class="anchor" href="#Annex"/>
          <a class="header" href="#Annex">
             Annex A
             <br/>
             (informative)
             <br/>
             <b>Annex</b>
             </a>
           </h1>
           <table id="AnnexTable" class="MsoISOTable" style="border-width:1px;border-spacing:0;">
             <thead>
               <tr>
                 <td colspan="1" style=";text-align:center;vertical-align:middle;" scope="colgroup">
                   <p class="TableTitle"  style="text-align:center;;"> Table A.1 — Another table</p>
                 </td>
               </tr>
             </thead>
             <tbody>
               <tr>
                 <td style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">?</td>
               </tr>
             </tbody>
           </table>
         </div>
       </main>
    OUTPUT

    doc = <<~OUTPUT
      <div>
         <table xmlns:m="m" title="tool tip" summary="long desc" width="" class="MsoTableGrid" style="border-collapse:collapse;mso-table-anchor-horizontal:column;mso-table-overlap:never;border:none;mso-padding-alt: 0cm 5.4pt 0cm 5.4pt;mso-border-insideh:none;mso-border-insidev:none;" border="0" cellspacing="0" cellpadding="0">
           <a name="tableD-1" id="tableD-1"/>
           <thead>
             <tr>
               <td colspan="5" style="page-break-after:avoid;" align="center" valign="middle">
               <p class="ForewordText" style="text-align:center;;text-align: center;page-break-after:avoid">
                   Table 1 — Repeatability and reproducibility of
                   <i>husked</i>
                   rice yield
                   <a href="#tableD-11" class="TableFootnoteRef">1</a>
                 </p>
               </td>
             </tr>
             <tr>
               <td rowspan="2" align="center" style="border-top:none;mso-border-top-alt:none;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;" valign="middle">Description</td>
               <td colspan="4" align="center" style="border-top:none;mso-border-top-alt:none;border-left:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;" valign="middle">Rice sample</td>
             </tr>
             <tr>
               <td align="center" style="border-top:none;mso-border-top-alt:none;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;" valign="middle">Arborio</td>
               <td align="center" style="border-top:none;mso-border-top-alt:none;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;" valign="middle">
                 Drago
                 <a href="#tableD-1a" class="TableFootnoteRef">a</a>
               </td>
               <td align="center" style="border-top:none;mso-border-top-alt:none;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;" valign="middle">
                 Balilla
                 <a href="#tableD-1a" class="TableFootnoteRef">a</a>
               </td>
               <td align="center" style="border-top:none;mso-border-top-alt:none;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;" valign="middle">Thaibonnet</td>
             </tr>
           </thead>
           <tbody>
             <tr>
               <th align="left" style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-left:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">Number of laboratories retained after eliminating outliers</th>
               <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-left:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">13</td>
               <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-left:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">11</td>
               <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-left:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">13</td>
               <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-left:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">13</td>
             </tr>
             <tr>
               <td align="left" style="border-top:none;mso-border-top-alt:none;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">Mean value, g/100 g</td>
               <td align="center" style="border-top:none;mso-border-top-alt:none;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">81,2</td>
               <td align="center" style="border-top:none;mso-border-top-alt:none;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">82,0</td>
               <td align="center" style="border-top:none;mso-border-top-alt:none;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">81,8</td>
               <td align="center" style="border-top:none;mso-border-top-alt:none;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">77,7</td>
             </tr>
           </tbody>
           <tfoot>
             <tr>
               <td align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:0pt;mso-border-bottom-alt:0pt;page-break-after:auto;">
                 Reproducibility limit,
                 <span class="stem">(#(R)#)</span>
                 (= 2,83
                 <span class="stem">(#(s_R)#)</span>
                 )
               </td>
               <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:0pt;mso-border-bottom-alt:0pt;page-break-after:auto;">2,89</td>
               <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:0pt;mso-border-bottom-alt:0pt;page-break-after:auto;">0,57</td>
               <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:0pt;mso-border-bottom-alt:0pt;page-break-after:auto;">2,26</td>
               <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:0pt;mso-border-bottom-alt:0pt;page-break-after:auto;">6,06</td>
             </tr>
             <tr>
               <td colspan="5" style="border-top:0pt;mso-border-top-alt:0pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;border-left:solid windowtext 1.5pt;mso-border-left-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-right-alt:solid windowtext 1.5pt;">
                 <div class="BlockSource">
                   <p class="MsoNormal">SOURCE:


                    , Section 1

                    &#x2014; with adjustments ;


             , Section 3

           &#x2014; with alterations
                </p>
                 </div>
                 <div>
                   <p class="Note">
                     <span class="note_label">NOTE 1</span>
                     <span style="mso-tab-count:1">  </span>
                     This is a table about rice
                   </p>
                 </div>
                 <div class="TableFootnote">
                   <div>
                     <a name="ftntableD-11" id="ftntableD-11"/>
                     <p class="TableFootnote">
                       <a name="_" id="_"/>
                       <span>
                         Footnote
                         <span class="TableFootnoteRef">
                           <a name="tableD-11" id="tableD-11"/>
                           1)
                         </span>
                         <span style="mso-tab-count:1">  </span>
                       </span>
                       Name footnote.
                     </p>
                   </div>
                 </div>
                 <div class="TableFootnote">
                   <div>
                     <a name="ftntableD-1a" id="ftntableD-1a"/>
                     <p class="TableFootnote">
                       <a name="_" id="_"/>
                       <span>
                         Footnote
                         <span class="TableFootnoteRef">
                           <a name="tableD-1a" id="tableD-1a"/>
                           a)
                         </span>
                         <span style="mso-tab-count:1">  </span>
                       </span>
                       Parboiled rice.
                     </p>
                   </div>
                 </div>
               </td>
             </tr>
           </tfoot>
          <p class="ForewordText">Key</p>
          <p class="ForewordText">Drago: A type of rice</p>
         </table>
       </div>
    OUTPUT
    doc2 = <<~OUTPUT
      <div class="Section3">
         <a name="Annex" id="Annex"/>
         <p class="Annex">
           Annex A
           <br/>
           (informative)
           <br/>
           <span class="Strong">Annex</span>
         </p>
         <div align="center" class="table_container">
           <table title="" summary="" width="" class="MsoTableGrid" style="border-collapse:collapse;mso-table-anchor-horizontal:column;mso-table-overlap:never;border:none;mso-padding-alt: 0cm 5.4pt 0cm 5.4pt;mso-border-insideh:none;mso-border-insidev:none;" border="0" cellspacing="0" cellpadding="0">
             <a name="AnnexTable" id="AnnexTable"/>
             <thead>
               <tr>
                 <td colspan="1" style="page-break-after:avoid;" align="center" valign="middle">
                 <p class="TableTitle" style="text-align:center;;text-align: center;page-break-after:avoid"> Table A.1 — Another table</p>
                 </td>
               </tr>
             </thead>
             <tbody>
               <tr>
                 <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">?</td>
               </tr>
             </tbody>
           </table>
         </div>
       </div>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::JIS::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)))).to be_equivalent_to xmlpp(presxml)
    IsoDoc::JIS::HtmlConvert.new({}).convert("test", presxml, false)
    expect(File.exist?("test.html")).to be true
    out = File.read("test.html")
      .sub(/^.*<main /m, "<main ")
      .sub(%r{</main>.*$}m, "</main>")
    expect(xmlpp(strip_guid(out))).to be_equivalent_to xmlpp(html)
    IsoDoc::JIS::WordConvert.new({}).convert("test", presxml, false)
    expect(File.exist?("test.doc")).to be true
    out = File.read("test.doc")
      .sub(/^.+?<table /m, '<table xmlns:m="m" ')
      .sub(%r{</div>\s*<p class="MsoNormal">.*$}m, "")
    expect(xmlpp("<div>#{out}")).to be_equivalent_to xmlpp(doc)
    out = File.read("test.doc")
      .sub(/^.+?<div class="Section3"/m, '<div class="Section3"')
      .sub(%r{</div>\s*<br[^>]+>\s*<div class="colophon".*$}m, "")
    expect(xmlpp(out)).to be_equivalent_to xmlpp(doc2)
  end

  it "processes units statements in tables" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <table id="tableD-1">
              <name>Repeatability and reproducibility of
                <em>husked</em>
                rice yield</name>
              <thead>
                <tr>
                  <td>Description</td>
                  <td>Rice sample</td>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <th align="left">Number of laboratories retained after eliminating outliers</th>
                  <td align="center">13</td>
                </tr>
                <tr>
                  <td align="left">Mean value, g/100 g</td>
                  <td align="center">81,2</td>
                </tr>
              </tbody>
              <dl>
                <dt>Drago</dt>
                <dd>A type of rice</dd>
              </dl>
              <note id="A">Note 1</note>
              <note id="B" type="units">Units in mm</note>
              <note id="C">Note 2</note>
              <note id="D" type="units">Other units in sec</note>
            </table>
          </foreword>
        </preface>
         <sections>
         <clause/>
         </sections>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
           <foreword displayorder="1">
             <table id="tableD-1">
               <name>
                  Table 1 — Repeatability and reproducibility of
                  <em>husked</em>
                  rice yield
                </name>
               <thead>
                 <tr>
                   <td border="0" colspan="2">
                     <note id="B" type="units">Units in mm</note>
                   </td>
                 </tr>
                 <tr>
                   <td>Description</td>
                   <td>Rice sample</td>
                 </tr>
               </thead>
               <tbody>
                 <tr>
                   <th align="left">Number of laboratories retained after eliminating outliers</th>
                   <td align="center">13</td>
                 </tr>
                 <tr>
                   <td align="left">Mean value, g/100 g</td>
                   <td align="center">81,2</td>
                 </tr>
               </tbody>
               <p class="ListTitle">Key</p>
               <p class="dl">Drago: A type of rice</p>
               <note id="A">
                 <name>NOTE  1</name>
                 Note 1
               </note>
               <note id="C">
                 <name>NOTE  2</name>
                 Note 2
               </note>
               <note id="D" type="units">Other units in sec</note>
             </table>
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
          <clause displayorder="6"/>
        </sections>
       </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
            <br/>
            <div>
                           <h1 class="ForewordTitle">Foreword</h1>
               <div align="right">
                 <b>Other units in sec</b>
               </div>
               <table id="tableD-1" class="MsoISOTable" style="border-width:1px;border-spacing:0;">
                 <thead>
                   <tr>
                     <td colspan="2" style="" scope="colgroup">
                       <p class="TableTitle" style="text-align:center;;">
                         Table 1 — Repeatability and reproducibility of
                         <i>husked</i>
                         rice yield
                       </p>
                     </td>
                   </tr>
                   <tr>
                     <td colspan="2" style="" scope="colgroup">
                       <div id="B" class="Note">Units in mm</div>
                     </td>
                   </tr>
                   <tr>
                     <td style="border-top:none;border-bottom:solid windowtext 1.5pt;" scope="col">Description</td>
                     <td style="border-top:none;border-bottom:solid windowtext 1.5pt;" scope="col">Rice sample</td>
                   </tr>
                 </thead>
                 <tbody>
                   <tr>
                     <th style="font-weight:bold;text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;" scope="row">Number of laboratories retained after eliminating outliers</th>
                     <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
                   </tr>
                   <tr>
                     <td style="text-align:left;border-top:none;border-bottom:solid windowtext 1.5pt;">Mean value, g/100 g</td>
                     <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">81,2</td>
                   </tr>
                 </tbody>
                 <p class="ListTitle">Key</p>
                 <p class="dl">Drago: A type of rice</p>
                 <div id="A" class="Note">
                   <p>
                     <span class="note_label">NOTE  1</span>
                      
                   </p>
                   Note 1
                 </div>
                 <div id="C" class="Note">
                   <p>
                     <span class="note_label">NOTE  2</span>
                      
                   </p>
                   Note 2
                 </div>
                 <div id="D" class="Note">Other units in sec</div>
               </table>
             </div>
                   <br/>
              <div id="_" class="TOC">
                <h1 class="IntroTitle">Contents</h1>
              </div>
                         #{middle_title(false)}
                              <div>
                <h1/>
              </div>
           </div>
         </body>
       </html>
    OUTPUT
    doc = <<~OUTPUT
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
               <div align="right">
                 <b>Other units in sec</b>
               </div>
               <div align="center" class="table_container">
                 <table id="tableD-1" title="" summary="" width="" class="MsoTableGrid" style="border-collapse:collapse;mso-table-anchor-horizontal:column;mso-table-overlap:never;border:none;mso-padding-alt: 0cm 5.4pt 0cm 5.4pt;mso-border-insideh:none;mso-border-insidev:none;" border="0" cellspacing="0" cellpadding="0">
                   <thead>
                     <tr>
                       <td colspan="2" style="page-break-after:avoid;">
                         <p class="ForewordText" style="text-align:center;;">
                           Table 1 — Repeatability and reproducibility of
                           <i>husked</i>
                           rice yield
                         </p>
                       </td>
                     </tr>
                     <tr>
                       <td colspan="2" style="page-break-after:avoid;">
                         <div id="B" class="Note">
                           <p class="Note">
                             <span class="note_label"/>
                             <span style="mso-tab-count:1">  </span>
                           </p>
                           Units in mm
                         </div>
                       </td>
                     </tr>
                     <tr>
                       <td style="border-top:none;mso-border-top-alt:none;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">Description</td>
                       <td style="border-top:none;mso-border-top-alt:none;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">Rice sample</td>
                     </tr>
                   </thead>
                   <tbody>
                     <tr>
                       <th align="left" style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-left:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">Number of laboratories retained after eliminating outliers</th>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-left:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">13</td>
                     </tr>
                     <tr>
                       <td align="left" style="border-top:none;mso-border-top-alt:none;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">Mean value, g/100 g</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-left:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-right:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">81,2</td>
                     </tr>
                   </tbody>
                   <p class="ForewordText">Key</p>
                  <p class="ForewordText">Drago: A type of rice</p>
                   <div id="A" class="Note">
                     <p class="Note">
                       <span class="note_label">NOTE  1</span>
                       <span style="mso-tab-count:1">  </span>
                     </p>
                     Note 1
                   </div>
                   <div id="C" class="Note">
                     <p class="Note">
                       <span class="note_label">NOTE  2</span>
                       <span style="mso-tab-count:1">  </span>
                     </p>
                     Note 2
                   </div>
                   <div id="D" class="Note">
            <p class="Note">
              <span class="note_label"/>
              <span style="mso-tab-count:1">  </span>
            </p>
            Other units in sec
          </div>
                 </table>
               </div>
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
                           <div>
            <h1/>
          </div>
           </div>
           <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
           <div class="colophon"/>
         </body>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::JIS::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true)))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::JIS::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(Nokogiri::XML(IsoDoc::JIS::WordConvert.new({})
      .convert("test", presxml, true))
      .at("//body").to_xml)).to be_equivalent_to xmlpp(doc)
  end
end
