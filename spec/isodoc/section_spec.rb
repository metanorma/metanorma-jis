require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc::JIS do
  it "processes normative reference subclauses" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
       <bibliography>
       <clause id="R" normative="true" obligation="informative">
         <title>Normative References</title>
          <references id="R" normative="true" obligation="informative">
         <title>Normative References 1</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    INPUT
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
           <p class="zzSTDTitle1"/>
           <p class="zzSTDTitle2"/>
           <div class="normref_div">
             <h1>Normative References</h1>
             <div>
               <h2 class="BiblioTitle">Normative References 1</h2>
             </div>
           </div>
         </div>
         <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
         <div class="colophon"/>
       </body>
    OUTPUT
    expect(xmlpp(IsoDoc::JIS::WordConvert.new({})
          .convert("test", input, true)
          .sub(/^.*<body /m, "<body ").sub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to xmlpp(word)
  end
end
