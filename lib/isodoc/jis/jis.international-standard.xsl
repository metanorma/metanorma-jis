<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:jis="https://www.metanorma.org/ns/standoc" xmlns:mathml="http://www.w3.org/1998/Math/MathML" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fox="http://xmlgraphics.apache.org/fop/extensions" xmlns:pdf="http://xmlgraphics.apache.org/fop/extensions/pdf" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:java="http://xml.apache.org/xalan/java" xmlns:jeuclid="http://jeuclid.sf.net/ns/ext" xmlns:barcode="http://barcode4j.krysalis.org/ns" xmlns:redirect="http://xml.apache.org/xalan/redirect" exclude-result-prefixes="java" extension-element-prefixes="redirect" version="1.0">

	<xsl:output method="xml" encoding="UTF-8" indent="no"/>

	<xsl:key name="kfn" match="*[local-name() = 'fn'][not(ancestor::*[(local-name() = 'table' or local-name() = 'figure' or local-name() = 'localized-strings')] and not(ancestor::*[local-name() = 'name']))]" use="@reference"/>

	<xsl:variable name="debug">false</xsl:variable>

	<!-- <xsl:variable name="isIgnoreComplexScripts">true</xsl:variable> -->

	<xsl:variable name="vertical_layout" select="normalize-space(/*/jis:metanorma-extension/jis:presentation-metadata/jis:vertical-layout)"/>
	<xsl:variable name="vertical_layout_rotate_clause_numbers" select="normalize-space(/*/jis:metanorma-extension/jis:presentation-metadata/jis:vertical-layout-rotate-clause-numbers)"/>

	<xsl:variable name="autonumbering_style" select="normalize-space(/*/jis:metanorma-extension/jis:presentation-metadata/jis:autonumbering-style)"/>

	<xsl:variable name="numbers_japanese_">
		<xsl:copy-of select="/*/jis:localized-strings/jis:localized-string[starts-with(@key,'0') or starts-with(@key,'1') or starts-with(@key,'2') or starts-with(@key,'3') or     starts-with(@key,'4') or starts-with(@key,'5') or starts-with(@key,'6') or starts-with(@key,'7') or starts-with(@key,'8') or starts-with(@key,'9')]"/>
	</xsl:variable>
	<xsl:variable name="numbers_japanese" select="xalan:nodeset($numbers_japanese_)"/>

	<xsl:variable name="contents_">
		<xsl:variable name="bundle" select="count(//jis:metanorma) &gt; 1"/>

		<xsl:if test="normalize-space($bundle) = 'true'">
			<collection firstpage_id="firstpage_id_0"/>
		</xsl:if>

		<xsl:for-each select="//jis:metanorma">
			<xsl:variable name="num"><xsl:number level="any" count="jis:metanorma"/></xsl:variable>
			<xsl:variable name="docnumber"><xsl:value-of select="jis:bibdata/jis:docidentifier[@type = 'JIS']"/></xsl:variable>
			<xsl:variable name="current_document">
				<xsl:copy-of select="."/>
			</xsl:variable>

			<xsl:for-each select="xalan:nodeset($current_document)"> <!-- . -->
				<doc num="{$num}" firstpage_id="firstpage_id_{$num}" title-part="{$docnumber}" bundle="{$bundle}"> <!-- 'bundle' means several different documents (not language versions) in one xml -->
					<contents>
						<!-- <xsl:call-template name="processPrefaceSectionsDefault_Contents"/> -->

						<xsl:call-template name="processMainSectionsDefault_Contents"/>

						<xsl:apply-templates select="//jis:indexsect" mode="contents"/>

					</contents>
				</doc>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="contents" select="xalan:nodeset($contents_)"/>

	<xsl:variable name="updated_contents_xml_step0">
		<xsl:if test="$vertical_layout = 'true'">
			<xsl:apply-templates select="$contents" mode="update_xml_step0"/>
		</xsl:if>
	</xsl:variable>
	<xsl:variable name="updated_contents_xml_">
		<xsl:choose>
			<xsl:when test="$vertical_layout = 'true'">
				<xsl:apply-templates select="xalan:nodeset($updated_contents_xml_step0)" mode="update_xml_step1"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$contents"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="updated_contents_xml" select="xalan:nodeset($updated_contents_xml_)"/>

	<xsl:variable name="ids">
		<xsl:for-each select="//*[@id]">
			<id><xsl:value-of select="@id"/></id>
		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="pageWidthA5">148</xsl:variable>
	<xsl:variable name="pageHeightA5">210</xsl:variable>

	<xsl:template match="/">

		<fo:root xml:lang="{$lang}">
			<xsl:variable name="root-style">
				<root-style xsl:use-attribute-sets="root-style">
					<xsl:if test="$vertical_layout = 'true'">
						<xsl:attribute name="font-family">Noto Serif JP, STIX Two Math, <xsl:value-of select="$font_noto_serif"/></xsl:attribute>
						<xsl:attribute name="font-family-generic">Serif</xsl:attribute>
						<xsl:attribute name="font-size">11pt</xsl:attribute>
						<xsl:attribute name="font-weight">200</xsl:attribute>
						<xsl:attribute name="color">rgb(34,31,31)</xsl:attribute>
					</xsl:if>

					<xsl:if test="$lang = 'en'">
						<xsl:attribute name="font-family">Times New Roman, STIX Two Math, <xsl:value-of select="$font_noto_serif"/></xsl:attribute>
						<xsl:attribute name="font-family-generic">Serif</xsl:attribute>
						<xsl:attribute name="font-size">11pt</xsl:attribute>
					</xsl:if>
				</root-style>
			</xsl:variable>
			<xsl:call-template name="insertRootStyle">
				<xsl:with-param name="root-style" select="$root-style"/>
			</xsl:call-template>

			<fo:layout-master-set>

				<!-- Cover page -->
				<fo:simple-page-master master-name="cover-page" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="28.5mm" margin-bottom="25mm" margin-left="22mm" margin-right="22mm"/>
					<fo:region-before region-name="header" extent="28.5mm"/>
					<fo:region-after region-name="footer" extent="25mm"/>
					<fo:region-start region-name="left-region" extent="22mm"/>
					<fo:region-end region-name="right-region" extent="22mm"/>
				</fo:simple-page-master>

				<fo:simple-page-master master-name="cover-page_2024" page-width="{$pageWidthA5}mm" page-height="{$pageHeightA5}mm">
					<!-- Note (for writing-mode="tb-rl", may be due the update for support 'tb-rl' mode):
					 fo:region-body/@margin-top = left margin
					 fo:region-body/@margin-bottom = right margin
					 fo:region-body/margin-left = bottom margin
					 fo:region-body/margin-right = top margin
					-->
					<fo:region-body margin-top="6mm" margin-bottom="6mm" margin-left="12.8mm" margin-right="58mm" writing-mode="tb-rl"/>
					<fo:region-before region-name="header" extent="58mm" precedence="true"/>
					<fo:region-after region-name="footer" extent="12.8mm"/>
					<fo:region-start region-name="left-region" extent="20mm"/> <!-- 6 20mm -->
					<fo:region-end region-name="right-region" extent="6.8mm"/> <!-- 17mm -->
				</fo:simple-page-master>

				<fo:simple-page-master master-name="cover-page-JSA" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="165mm" margin-bottom="44.5mm" margin-left="37mm" margin-right="37mm"/>
					<fo:region-before region-name="header" extent="165mm"/>
					<fo:region-after region-name="footer" extent="44.5mm"/>
					<fo:region-start region-name="left-region" extent="37mm"/>
					<fo:region-end region-name="right-region" extent="37mm"/>
				</fo:simple-page-master>

				<fo:simple-page-master master-name="first_page" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<xsl:if test="$vertical_layout = 'true' and $isGenerateTableIF = 'false'">
						<xsl:attribute name="page-width"><xsl:value-of select="$pageHeight"/>mm</xsl:attribute>
						<xsl:attribute name="page-height"><xsl:value-of select="$pageWidth"/>mm</xsl:attribute>
					</xsl:if>
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2}mm">
						<xsl:if test="$vertical_layout = 'true' and $isGenerateTableIF = 'false'">
							<xsl:attribute name="writing-mode">tb-rl</xsl:attribute>
						</xsl:if>
					</fo:region-body>
					<fo:region-before region-name="header" extent="{$marginTop}mm"/>
					<fo:region-after region-name="footer" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="{$marginLeftRight1}mm"/>
					<fo:region-end region-name="right-region" extent="{$marginLeftRight2}mm"/>
				</fo:simple-page-master>
				<fo:simple-page-master master-name="odd" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<xsl:if test="$vertical_layout = 'true' and $isGenerateTableIF = 'false'">
						<xsl:attribute name="page-width"><xsl:value-of select="$pageHeight"/>mm</xsl:attribute>
						<xsl:attribute name="page-height"><xsl:value-of select="$pageWidth"/>mm</xsl:attribute>
					</xsl:if>
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2}mm">
						<xsl:if test="$vertical_layout = 'true' and $isGenerateTableIF = 'false'">
							<xsl:attribute name="writing-mode">tb-rl</xsl:attribute>
						</xsl:if>
					</fo:region-body>
					<fo:region-before region-name="header-odd" extent="{$marginTop}mm"/>
					<fo:region-after region-name="footer" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="{$marginLeftRight1}mm"/>
					<fo:region-end region-name="right-region" extent="{$marginLeftRight2}mm"/>
				</fo:simple-page-master>
				<fo:simple-page-master master-name="even" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<xsl:if test="$vertical_layout = 'true' and $isGenerateTableIF = 'false'">
						<xsl:attribute name="page-width"><xsl:value-of select="$pageHeight"/>mm</xsl:attribute>
						<xsl:attribute name="page-height"><xsl:value-of select="$pageWidth"/>mm</xsl:attribute>
					</xsl:if>
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2}mm">
						<xsl:if test="$vertical_layout = 'true' and $isGenerateTableIF = 'false'">
							<xsl:attribute name="writing-mode">tb-rl</xsl:attribute>
						</xsl:if>
					</fo:region-body>
					<fo:region-before region-name="header-even" extent="{$marginTop}mm"/>
					<fo:region-after region-name="footer" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="{$marginLeftRight1}mm"/>
					<fo:region-end region-name="right-region" extent="{$marginLeftRight2}mm"/>
				</fo:simple-page-master>

				<fo:simple-page-master master-name="first_page_toc" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<xsl:if test="$vertical_layout = 'true'">
						<xsl:attribute name="page-width"><xsl:value-of select="$pageHeight"/>mm</xsl:attribute>
						<xsl:attribute name="page-height"><xsl:value-of select="$pageWidth"/>mm</xsl:attribute>
					</xsl:if>
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2}mm">
						<xsl:if test="$vertical_layout = 'true' and $isGenerateTableIF = 'false'">
							<xsl:attribute name="writing-mode">tb-rl</xsl:attribute>
						</xsl:if>
					</fo:region-body>
					<fo:region-before region-name="header-odd-first" extent="{$marginTop}mm"/>
					<fo:region-after region-name="footer" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="{$marginLeftRight1}mm"/>
					<fo:region-end region-name="right-region" extent="{$marginLeftRight2}mm"/>
				</fo:simple-page-master>

				<fo:page-sequence-master master-name="document_toc">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference page-position="first" master-reference="first_page_toc"/>
						<fo:conditional-page-master-reference odd-or-even="even" master-reference="even"/>
						<fo:conditional-page-master-reference odd-or-even="odd" master-reference="odd"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>

				<xsl:if test="1 = 3">
				<fo:simple-page-master master-name="document_toc_2024" page-width="{$pageHeight}mm" page-height="{$pageWidth}mm">
					<!-- Note (for writing-mode="tb-rl", may be due the update for support 'tb-rl' mode):
					 fo:region-body/@margin-top = left margin
					 fo:region-body/@margin-bottom = right margin
					 fo:region-body/margin-left = bottom margin
					 fo:region-body/margin-right = top margin
					-->
					<!-- <fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2 + 40}mm" writing-mode="tb-rl" background-color="rgb(240,240,240)"/> -->
					<fo:region-body margin-top="{$marginLeftRight1}mm" margin-bottom="{$marginLeftRight2}mm" margin-left="30mm" margin-right="30mm" writing-mode="tb-rl"/> <!--  background-color="rgb(240,240,240)" -->
					<fo:region-before region-name="header" extent="30mm"/> <!--  background-color="yellow" -->
					<fo:region-after region-name="footer" extent="210mm" writing-mode="tb-rl" background-color="green"/> <!-- 30  background-color="green" -->
					<fo:region-start region-name="left-region" extent="{$marginLeftRight1}mm" writing-mode="tb-rl" background-color="blue"/> <!--  background-color="blue" -->
					<fo:region-end region-name="right-region" extent="{$marginLeftRight2}mm"/> <!--  background-color="red" -->
				</fo:simple-page-master>
				</xsl:if>

				<fo:simple-page-master master-name="document_toc_2024" page-width="{$pageHeight}mm" page-height="{$pageWidth}mm">
					<!-- Note (for writing-mode="tb-rl", may be due the update for support 'tb-rl' mode):
					 fo:region-body/@margin-top = left margin
					 fo:region-body/@margin-bottom = right margin
					 fo:region-body/margin-left = bottom margin
					 fo:region-body/margin-right = top margin
					-->
					<!-- <fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2 + 40}mm" writing-mode="tb-rl" background-color="rgb(240,240,240)"/> -->
					<fo:region-body margin-top="{$marginLeftRight1}mm" margin-bottom="38mm" margin-left="30mm" margin-right="30mm" writing-mode="tb-rl"/> <!--  background-color="rgb(240,240,240)" -->
					<fo:region-before region-name="header" extent="30mm"/> <!--  background-color="yellow" -->
					<fo:region-after region-name="footer" extent="30mm"/> <!--  background-color="green" -->
					<fo:region-start region-name="left-region" extent="{$marginLeftRight1}mm"/> <!--  background-color="blue" -->
					<fo:region-end region-name="right-region" extent="{$marginLeftRight2}mm"/> <!--  background-color="red" -->
				</fo:simple-page-master>

				<fo:page-sequence-master master-name="document_preface">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference odd-or-even="even" master-reference="even"/>
						<fo:conditional-page-master-reference odd-or-even="odd" master-reference="odd"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>

				<fo:page-sequence-master master-name="document_first_section">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference page-position="first" master-reference="first_page"/>
						<fo:conditional-page-master-reference odd-or-even="even" master-reference="even"/>
						<fo:conditional-page-master-reference odd-or-even="odd" master-reference="odd"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>

				<fo:page-sequence-master master-name="document">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference odd-or-even="even" master-reference="even"/>
						<fo:conditional-page-master-reference odd-or-even="odd" master-reference="odd"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>

				<fo:simple-page-master master-name="document_2024" page-width="{$pageHeight}mm" page-height="{$pageWidth}mm">
					<xsl:if test="$isGenerateTableIF = 'true'">
						<xsl:attribute name="page-width"><xsl:value-of select="$pageWidth"/>mm</xsl:attribute>
						<xsl:attribute name="page-height"><xsl:value-of select="$pageHeight"/>mm</xsl:attribute>
					</xsl:if>
					<!-- Note (for writing-mode="tb-rl", may be due the update for support 'tb-rl' mode):
					 fo:region-body/@margin-top = left margin
					 fo:region-body/@margin-bottom = right margin
					 fo:region-body/margin-left = bottom margin
					 fo:region-body/margin-right = top margin
					-->
					<!-- <fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2 + 40}mm" writing-mode="tb-rl" background-color="rgb(240,240,240)"/> -->
					<fo:region-body margin-top="{$marginLeftRight1}mm" margin-bottom="{$marginLeftRight2}mm" margin-left="{$marginBottom}mm" margin-right="{$marginTop}mm">	 <!--  background-color="rgb(240,240,240)" -->
						<xsl:if test="$isGenerateTableIF = 'false'">
							<xsl:attribute name="writing-mode">tb-rl</xsl:attribute>
						</xsl:if>
					</fo:region-body>
					<fo:region-before region-name="header" extent="{$marginTop}mm"/> <!--  background-color="yellow" -->
					<fo:region-after region-name="footer" extent="{$marginBottom}mm"/> <!--  background-color="green" -->
					<fo:region-start region-name="left-region" extent="{$marginLeftRight1}mm"/> <!--  background-color="blue" -->
					<fo:region-end region-name="right-region" extent="{$marginLeftRight2}mm"/> <!--  background-color="red" -->
				</fo:simple-page-master>

				<fo:simple-page-master master-name="document_2024_page" page-width="{$pageHeight}mm" page-height="{$pageWidth}mm">
					<xsl:if test="$isGenerateTableIF = 'true'">
						<xsl:attribute name="page-width"><xsl:value-of select="$pageWidth"/>mm</xsl:attribute>
						<xsl:attribute name="page-height"><xsl:value-of select="$pageHeight"/>mm</xsl:attribute>
					</xsl:if>
					<!-- Note (for writing-mode="tb-rl", may be due the update for support 'tb-rl' mode):
					 fo:region-body/@margin-top = left margin
					 fo:region-body/@margin-bottom = right margin
					 fo:region-body/margin-left = bottom margin
					 fo:region-body/margin-right = top margin
					-->
					<!-- <fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2 + 40}mm" writing-mode="tb-rl" background-color="rgb(240,240,240)"/> -->
					<fo:region-body margin-top="{$marginLeftRight1}mm" margin-bottom="{$marginLeftRight2}mm" margin-left="{$marginBottom}mm" margin-right="{$marginTop}mm">  <!--  background-color="rgb(240,240,240)" -->
						<xsl:if test="$isGenerateTableIF = 'false'">
							<xsl:attribute name="writing-mode">tb-rl</xsl:attribute>
						</xsl:if>
					</fo:region-body>
					<fo:region-before region-name="header" extent="{$marginTop}mm"/> <!--  background-color="yellow" -->
					<fo:region-after region-name="footer" extent="{$marginBottom}mm"/> <!--  background-color="green" -->
					<fo:region-start region-name="left-region" extent="{$marginLeftRight1}mm"/> <!--  background-color="blue" -->
					<fo:region-end region-name="right-region" extent="{$marginLeftRight2}mm"/> <!--  background-color="red" -->
				</fo:simple-page-master>
				<fo:simple-page-master master-name="document_2024_last" page-width="{$pageHeight}mm" page-height="{$pageWidth}mm">
					<xsl:if test="$isGenerateTableIF = 'true'">
						<xsl:attribute name="page-width"><xsl:value-of select="$pageWidth"/>mm</xsl:attribute>
						<xsl:attribute name="page-height"><xsl:value-of select="$pageHeight"/>mm</xsl:attribute>
					</xsl:if>
					<!-- Note (for writing-mode="tb-rl", may be due the update for support 'tb-rl' mode):
					 fo:region-body/@margin-top = left margin
					 fo:region-body/@margin-bottom = right margin
					 fo:region-body/margin-left = bottom margin
					 fo:region-body/margin-right = top margin
					-->
					<!-- <fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2 + 40}mm" writing-mode="tb-rl" background-color="rgb(240,240,240)"/> -->
					<fo:region-body margin-top="194mm" margin-bottom="{$marginLeftRight2}mm" margin-left="{$marginBottom}mm" margin-right="{$marginTop}mm">  <!--  background-color="rgb(240,240,240)" -->
						<xsl:if test="$isGenerateTableIF = 'false'">
							<xsl:attribute name="writing-mode">tb-rl</xsl:attribute>
						</xsl:if>
					</fo:region-body>
					<fo:region-before region-name="header-last" extent="{$marginTop}mm">  <!--  background-color="yellow" -->
						<xsl:if test="$isGenerateTableIF = 'false'">
							<xsl:attribute name="writing-mode">tb-rl</xsl:attribute>
						</xsl:if>
					</fo:region-before>
					<fo:region-after region-name="footer" extent="{$marginBottom}mm"/> <!--  background-color="green" -->
					<!-- for boilerplate:
						reserve paper space in left-region, but text will render in the header 
					-->
					<fo:region-start region-name="left-region" extent="194mm"/> <!--  background-color="blue"  background-color="rgb(230,230,230)" -->
					<fo:region-end region-name="right-region" extent="{$marginLeftRight2}mm"/> <!--  background-color="red" -->
				</fo:simple-page-master>

				<fo:page-sequence-master master-name="document_2024_with_last">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference page-position="last" master-reference="document_2024_last"/>
						<fo:conditional-page-master-reference page-position="any" master-reference="document_2024_page"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>

				<fo:simple-page-master master-name="commentary_first_page_even" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<xsl:if test="$vertical_layout = 'true' and $isGenerateTableIF = 'false'">
						<xsl:attribute name="page-width"><xsl:value-of select="$pageHeight"/>mm</xsl:attribute>
						<xsl:attribute name="page-height"><xsl:value-of select="$pageWidth"/>mm</xsl:attribute>
					</xsl:if>
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2}mm">
						<xsl:if test="$vertical_layout = 'true' and $isGenerateTableIF = 'false'">
							<xsl:attribute name="writing-mode">tb-rl</xsl:attribute>
						</xsl:if>
					</fo:region-body>
					<fo:region-before region-name="header-commentary-even-first" extent="{$marginTop}mm"/>
					<fo:region-after region-name="footer" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="{$marginLeftRight1}mm"/>
					<fo:region-end region-name="right-region" extent="{$marginLeftRight2}mm"/>
				</fo:simple-page-master>

				<fo:simple-page-master master-name="commentary_first_page_odd" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<xsl:if test="$vertical_layout = 'true' and $isGenerateTableIF = 'false'">
						<xsl:attribute name="page-width"><xsl:value-of select="$pageHeight"/>mm</xsl:attribute>
						<xsl:attribute name="page-height"><xsl:value-of select="$pageWidth"/>mm</xsl:attribute>
					</xsl:if>
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2}mm">
						<xsl:if test="$vertical_layout = 'true' and $isGenerateTableIF = 'false'">
							<xsl:attribute name="writing-mode">tb-rl</xsl:attribute>
						</xsl:if>
					</fo:region-body>
					<fo:region-before region-name="header-commentary-odd-first" extent="{$marginTop}mm"/>
					<fo:region-after region-name="footer" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="{$marginLeftRight1}mm"/>
					<fo:region-end region-name="right-region" extent="{$marginLeftRight2}mm"/>
				</fo:simple-page-master>

				<fo:page-sequence-master master-name="document_commentary_section">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference page-position="first" odd-or-even="even" master-reference="commentary_first_page_even"/>
						<fo:conditional-page-master-reference page-position="first" odd-or-even="odd" master-reference="commentary_first_page_odd"/>
						<fo:conditional-page-master-reference odd-or-even="even" master-reference="even"/>
						<fo:conditional-page-master-reference odd-or-even="odd" master-reference="odd"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>

				<!-- landscape -->
				<fo:simple-page-master master-name="odd-landscape" page-width="{$pageHeight}mm" page-height="{$pageWidth}mm">
					<fo:region-body margin-top="{$marginLeftRight1}mm" margin-bottom="{$marginLeftRight2}mm" margin-left="{$marginBottom}mm" margin-right="{$marginTop}mm"/>
					<fo:region-before region-name="header-odd" extent="{$marginLeftRight1}mm" precedence="true"/>
					<fo:region-after region-name="footer" extent="{$marginLeftRight2}mm" precedence="true"/>
					<fo:region-start region-name="left-region-landscape" extent="{$marginBottom}mm"/>
					<fo:region-end region-name="right-region-landscape" extent="{$marginTop}mm"/>
				</fo:simple-page-master>
				<fo:simple-page-master master-name="even-landscape" page-width="{$pageHeight}mm" page-height="{$pageWidth}mm">
					<fo:region-body margin-top="{$marginLeftRight2}mm" margin-bottom="{$marginLeftRight1}mm" margin-left="{$marginBottom}mm" margin-right="{$marginTop}mm"/>
					<fo:region-before region-name="header-even" extent="{$marginLeftRight2}mm" precedence="true"/>
					<fo:region-after region-name="footer" extent="{$marginLeftRight1}mm" precedence="true"/>
					<fo:region-start region-name="left-region-landscape" extent="{$marginBottom}mm"/>
					<fo:region-end region-name="right-region-landspace" extent="{$marginTop}mm"/>
				</fo:simple-page-master>
				<fo:page-sequence-master master-name="document-landscape">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference odd-or-even="even" master-reference="even-landscape"/>
						<fo:conditional-page-master-reference odd-or-even="odd" master-reference="odd-landscape"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>

				<fo:simple-page-master master-name="back-page_2024" page-width="{$pageWidthA5}mm" page-height="{$pageHeightA5}mm">
					<!-- Note (for writing-mode="tb-rl", may be due the update for support 'tb-rl' mode):
					 fo:region-body/@margin-top = left margin
					 fo:region-body/@margin-bottom = right margin
					 fo:region-body/margin-left = bottom margin
					 fo:region-body/margin-right = top margin
					-->
					<fo:region-body margin-top="5mm" margin-bottom="122mm" margin-left="6.5mm" margin-right="70mm" writing-mode="tb-rl"/>
					<fo:region-before region-name="header" extent="70mm"/>
					<fo:region-after region-name="footer" extent="6.5mm"/>
					<fo:region-start region-name="left-region" extent="5mm"/>
					<fo:region-end region-name="right-region" extent="122mm"/>
				</fo:simple-page-master>
			</fo:layout-master-set>

			<fo:declarations>
				<xsl:call-template name="addPDFUAmeta"/>
			</fo:declarations>

			<xsl:call-template name="addBookmarks">
				<xsl:with-param name="contents" select="$contents"/>
			</xsl:call-template>

			<xsl:if test="$debug = 'true'">
				<redirect:write file="contents_.xml">
					<xsl:copy-of select="$contents"/>
				</redirect:write>
			</xsl:if>
			<xsl:if test="$debug = 'true'">
				<redirect:write file="contents_updated_.xml">
					<xsl:copy-of select="$updated_contents_xml"/>
				</redirect:write>
			</xsl:if>

			<xsl:variable name="updated_xml_step0">
				<!-- <xsl:if test="$vertical_layout = 'true'"> -->
				<xsl:apply-templates mode="update_xml_step0"/>
				<!-- </xsl:if> -->
			</xsl:variable>
			<xsl:if test="$debug = 'true'">
				<redirect:write file="update_xml_step0.xml">
					<xsl:copy-of select="$updated_xml_step0"/>
				</redirect:write>
			</xsl:if>

			<xsl:variable name="updated_xml_step1">
				<!-- <xsl:choose>
					<xsl:when test="$vertical_layout = 'true'">
						<xsl:apply-templates select="xalan:nodeset($updated_xml_step0)" mode="update_xml_step1"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates mode="update_xml_step1"/>
					</xsl:otherwise>
				</xsl:choose> -->
				<xsl:apply-templates select="xalan:nodeset($updated_xml_step0)" mode="update_xml_step1"/>
			</xsl:variable>
			<!-- DEBUG: updated_xml_step1=<xsl:copy-of select="$updated_xml_step1"/> -->
			<xsl:if test="$debug = 'true'">
				<xsl:message>start redirect</xsl:message>
				<redirect:write file="update_xml_step1.xml">
					<xsl:copy-of select="$updated_xml_step1"/>
				</redirect:write>
				<xsl:message>end redirect</xsl:message>
			</xsl:if>

			<xsl:variable name="updated_xml_step2_">
				<xsl:apply-templates select="xalan:nodeset($updated_xml_step1)" mode="update_xml_step2"/>
			</xsl:variable>
			<xsl:variable name="updated_xml_step2" select="xalan:nodeset($updated_xml_step2_)"/>
			<!-- DEBUG: updated_xml_step2=<xsl:copy-of select="$updated_xml_step2"/> -->

			<xsl:for-each select="$updated_xml_step2//jis:metanorma">
				<xsl:variable name="num"><xsl:number level="any" count="jis:metanorma"/></xsl:variable>

				<xsl:variable name="current_document">
					<xsl:copy-of select="."/>
				</xsl:variable>

				<xsl:for-each select="xalan:nodeset($current_document)">

					<xsl:variable name="docnumber" select="/*/jis:bibdata/jis:docnumber"/>

					<xsl:variable name="year_published" select="substring(/*/jis:bibdata/jis:date[@type = 'published']/jis:on, 1, 4)"/>

					<xsl:variable name="element_name_colon_gothic">colon_gothic</xsl:variable>
					<xsl:variable name="tag_colon_gothic_open">###<xsl:value-of select="$element_name_colon_gothic"/>###</xsl:variable>
					<xsl:variable name="tag_colon_gothic_close">###/<xsl:value-of select="$element_name_colon_gothic"/>###</xsl:variable>

					<xsl:variable name="docidentifier_" select="java:replaceAll(java:java.lang.String.new(/*/jis:bibdata/jis:docidentifier), '(:)', concat($tag_colon_gothic_open,'$1',$tag_colon_gothic_close))"/>

					<xsl:variable name="docidentifier__"><text><xsl:call-template name="replace_text_tags">
						<xsl:with-param name="tag_open" select="$tag_colon_gothic_open"/>
						<xsl:with-param name="tag_close" select="$tag_colon_gothic_close"/>
						<xsl:with-param name="text" select="$docidentifier_"/>
					</xsl:call-template></text></xsl:variable>

					<xsl:variable name="docidentifier">
						<xsl:apply-templates select="xalan:nodeset($docidentifier__)/node()"/>
					</xsl:variable>

					<xsl:variable name="copyrightText_">
						<xsl:variable name="backpage_boilerplate_text" select="normalize-space(/*/jis:metanorma-extension/jis:presentation-metadata/jis:backpage-boilerplate-text)"/>
						<xsl:value-of select="$backpage_boilerplate_text"/>
						<xsl:if test="$backpage_boilerplate_text = ''">
							<xsl:call-template name="getLocalizedString">
								<xsl:with-param name="key">permission_footer</xsl:with-param>
								<xsl:with-param name="formatted" select="$vertical_layout"/> <!-- $vertical_layout = 'true' -->
								<xsl:with-param name="bibdata_updated" select="/*/jis:bibdata"/> <!-- $vertical_layout = 'true' -->
							</xsl:call-template>
						</xsl:if>
					</xsl:variable>
					<xsl:variable name="copyrightText" select="normalize-space($copyrightText_)"/>

					<xsl:variable name="doctype" select="/*/jis:bibdata/jis:ext/jis:doctype"/>

					<xsl:variable name="title_ja" select="/*/jis:bibdata/jis:title[@language = 'ja' and @type = 'main']"/>
					<xsl:variable name="title_en" select="/*/jis:bibdata/jis:title[@language = 'en' and @type = 'main']"/>

					<xsl:variable name="cover_header_footer_background_value" select="normalize-space(/*/jis:metanorma-extension/jis:presentation-metadata/jis:color-header-footer-background)"/>
					<xsl:variable name="cover_header_footer_background_">
						<xsl:value-of select="$cover_header_footer_background_value"/>
						<xsl:if test="$cover_header_footer_background_value = ''">#0B0968</xsl:if>
					</xsl:variable>
					<xsl:variable name="cover_header_footer_background" select="normalize-space($cover_header_footer_background_)"/>

					<xsl:variable name="docidentifier_JIS_" select="/*/jis:bibdata/jis:docidentifier[@type = 'JIS']"/>
					<xsl:variable name="docidentifier_JIS">
						<xsl:choose>
							<xsl:when test="contains($docidentifier_JIS_, ':')"><xsl:value-of select="substring-before($docidentifier_JIS_, ':')"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="$docidentifier_JIS_"/></xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="edition" select="/jis:metanorma/jis:bibdata/jis:edition[@language = 'ja' and @numberonly = 'true']"/>

					<xsl:variable name="doclang">
						<xsl:call-template name="getLang"/>
					</xsl:variable>

					<xsl:if test="$isGenerateTableIF = 'false'">
					<xsl:choose>
						<xsl:when test="$vertical_layout = 'true'">
							<xsl:call-template name="insertCoverPage2024">
								<xsl:with-param name="num" select="$num"/>
								<xsl:with-param name="docidentifier_jis" select="$docidentifier_JIS_"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="$doctype = 'technical-specification'">
							<xsl:call-template name="insertCoverPageJSA">
								<xsl:with-param name="num" select="$num"/>
								<xsl:with-param name="doclang" select="$doclang"/>
								<xsl:with-param name="docidentifier_jis" select="$docidentifier_JIS_"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="insertCoverPage">
								<xsl:with-param name="num" select="$num"/>
								<xsl:with-param name="copyrightText" select="$copyrightText"/>
								<xsl:with-param name="docidentifier_jis" select="$docidentifier_JIS_"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:if test="not($vertical_layout = 'true')">
					<xsl:call-template name="insertInnerCoverPage">
						<xsl:with-param name="docidentifier" select="$docidentifier"/>
						<xsl:with-param name="copyrightText" select="$copyrightText"/>
					</xsl:call-template>
					</xsl:if>
					</xsl:if>

					<!-- ========================== -->
					<!-- Contents and preface pages -->
					<!-- ========================== -->

					<xsl:variable name="bibdata">
						<xsl:copy-of select="/jis:metanorma/jis:bibdata"/>
					</xsl:variable>

					<xsl:for-each select="/*/*[local-name()='preface']/*[not(local-name() = 'clause' and @type = 'contributors')]">
						<xsl:sort select="@displayorder" data-type="number"/>

						<xsl:choose>
							<xsl:when test="local-name() = 'clause' and @type = 'toc'">
								<fo:page-sequence master-reference="document_toc" force-page-count="no-force">

									<xsl:if test="$vertical_layout = 'true'">
										<xsl:attribute name="master-reference">document_toc_2024</xsl:attribute>
										<xsl:attribute name="format">一</xsl:attribute>
									</xsl:if>

									<xsl:if test="position() = 1">
										<xsl:attribute name="initial-page-number">1</xsl:attribute>
									</xsl:if>

									<xsl:choose>
										<xsl:when test="$vertical_layout = 'true'">
											<xsl:call-template name="insertLeftRightRegions">
												<xsl:with-param name="cover_header_footer_background" select="$cover_header_footer_background"/>
												<xsl:with-param name="title_ja" select="$title_ja"/>
												<xsl:with-param name="i18n_JIS" select="$i18n_JIS"/>
												<xsl:with-param name="docidentifier" select="concat('JIS ', $docidentifier_JIS)"/>
												<xsl:with-param name="docidentifier_jis" select="$docidentifier_JIS_"/>
												<xsl:with-param name="edition" select="$edition"/>
												<xsl:with-param name="copyrightText">
													<xsl:copy-of select="$copyrightText"/>
												</xsl:with-param>
											</xsl:call-template>
										</xsl:when>
										<xsl:otherwise>
											<xsl:call-template name="insertHeaderFooter">
												<xsl:with-param name="docidentifier" select="$docidentifier"/>
												<xsl:with-param name="copyrightText" select="$copyrightText"/>
												<xsl:with-param name="section">preface</xsl:with-param>
												<xsl:with-param name="section_title">
													<fo:inline font-family="IPAexGothic">
														<xsl:text> </xsl:text>
														<xsl:call-template name="getLocalizedString">
															<xsl:with-param name="key">table_of_contents</xsl:with-param>
														</xsl:call-template>
													</fo:inline>
												</xsl:with-param>
											</xsl:call-template>
										</xsl:otherwise>
									</xsl:choose>

									<fo:flow flow-name="xsl-region-body">

										<xsl:apply-templates select=".">
											<xsl:with-param name="num" select="$num"/>
										</xsl:apply-templates>

										<!-- <xsl:if test="not(/*/*[local-name()='preface']/*[local-name() = 'clause'][@type = 'toc'])">
											<fo:block> --><!-- prevent fop error for empty document --><!-- </fo:block>
										</xsl:if> -->

									</fo:flow>

								</fo:page-sequence>
							</xsl:when><!-- end ToC -->
							<xsl:otherwise>
								<xsl:variable name="structured_xml_preface">
									<xsl:apply-templates select="." mode="linear_xml"/>
								</xsl:variable>

								<xsl:variable name="paged_xml_preface_">
									<xsl:call-template name="makePagedXML">
										<xsl:with-param name="structured_xml" select="$structured_xml_preface"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:variable name="paged_xml_preface" select="xalan:nodeset($paged_xml_preface_)"/>

								<xsl:if test="$paged_xml_preface/*[local-name()='page'] and count($paged_xml_preface/*[local-name()='page']/*) != 0">
									<!-- Preface pages -->
									<fo:page-sequence master-reference="document_preface" force-page-count="no-force">

										<xsl:if test="$vertical_layout = 'true'">
											<xsl:attribute name="master-reference">document_2024</xsl:attribute>
											<xsl:attribute name="format">一</xsl:attribute>
										</xsl:if>

										<xsl:if test="position() = 1">
											<xsl:attribute name="initial-page-number">1</xsl:attribute>
										</xsl:if>

										<fo:static-content flow-name="xsl-footnote-separator">
											<fo:block text-align="center" margin-bottom="6pt">
												<fo:leader leader-pattern="rule" leader-length="80mm"/>
											</fo:block>
										</fo:static-content>

										<xsl:choose>
											<xsl:when test="$vertical_layout = 'true'">
												<xsl:call-template name="insertLeftRightRegions">
													<xsl:with-param name="cover_header_footer_background" select="$cover_header_footer_background"/>
													<xsl:with-param name="title_ja" select="$title_ja"/>
													<xsl:with-param name="i18n_JIS" select="$i18n_JIS"/>
													<xsl:with-param name="docidentifier" select="concat('JIS ', $docidentifier_JIS)"/>
													<xsl:with-param name="docidentifier_jis" select="$docidentifier_JIS_"/>
													<xsl:with-param name="edition" select="$edition"/>
													<xsl:with-param name="copyrightText">
														<xsl:copy-of select="$copyrightText"/>
													</xsl:with-param>
													<!-- <xsl:with-param name="insertLast">true</xsl:with-param> -->
													<xsl:with-param name="bibdata" select="$bibdata"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<xsl:call-template name="insertHeaderFooter">
													<xsl:with-param name="docidentifier" select="$docidentifier"/>
													<xsl:with-param name="copyrightText" select="$copyrightText"/>
													<xsl:with-param name="section">preface</xsl:with-param>
												</xsl:call-template>
											</xsl:otherwise>
										</xsl:choose>

										<fo:flow flow-name="xsl-region-body">

											<fo:block>
												<xsl:for-each select="$paged_xml_preface/*[local-name()='page']">
													<xsl:if test="position() != 1">
														<fo:block break-after="page"/>
													</xsl:if>
													<xsl:apply-templates select="*" mode="page"/>
												</xsl:for-each>
											</fo:block>
										</fo:flow>
									</fo:page-sequence> <!-- END Preface pages -->
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>

					<xsl:if test="not($vertical_layout = 'true') and not($doctype = 'technical-specification')">

					<!-- Document type rendering -->
					<fo:page-sequence master-reference="document_preface" force-page-count="no-force">
						<xsl:call-template name="insertHeaderFooter">
							<xsl:with-param name="docidentifier" select="$docidentifier"/>
							<xsl:with-param name="copyrightText" select="$copyrightText"/>
							<xsl:with-param name="section">preface</xsl:with-param>
						</xsl:call-template>

						<fo:flow flow-name="xsl-region-body">
							<fo:block-container margin-left="70mm">
								<fo:block-container margin-left="0mm" margin-top="30mm" width="26.5mm" height="8.5mm" text-align="center" display-align="center" border="1pt solid black">
									<fo:block>
										<xsl:call-template name="getLocalizedString">
											<xsl:with-param name="key">white-paper</xsl:with-param>
										</xsl:call-template>
									</fo:block>
								</fo:block-container>
							</fo:block-container>
						</fo:flow>
					</fo:page-sequence>
					</xsl:if>

					<!-- ========================== -->
					<!-- END Contents and preface pages -->
					<!-- ========================== -->

					<!-- item - page sequence -->
					<xsl:variable name="structured_xml_">

						<xsl:if test="not(/*/*[local-name()='preface']/*[local-name() = 'p' and @type = 'section-title'][following-sibling::*[1][local-name() = 'introduction']])">
							<item><xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name() = 'introduction']" mode="linear_xml"/></item>
						</xsl:if>

						<item>
							<xsl:choose>
								<xsl:when test="/*/*[local-name()='preface']/*[local-name() = 'p' and @type = 'section-title'][following-sibling::*[1][local-name() = 'introduction']]">
									<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name() = 'p' and @type = 'section-title'][following-sibling::*[1][local-name() = 'introduction']]" mode="linear_xml"/>
									<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name() = 'introduction']" mode="linear_xml"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name() = 'p' and @type = 'section-title'][not(following-sibling::*) or following-sibling::*[1][local-name() = 'clause' and @type = 'corrigenda']]" mode="linear_xml"/>
								</xsl:otherwise>
							</xsl:choose>

							<xsl:apply-templates select="/*/*[local-name()='sections']/*" mode="linear_xml"/>
						</item>

						<!-- Annexes -->
						<!-- <xsl:for-each select="/*/*[local-name()='annex']">
							<item>
								<xsl:apply-templates select="." mode="linear_xml"/>
							</item>
						</xsl:for-each> -->

						<!-- Annexes and Bibliography -->
						<xsl:for-each select="/*/*[local-name()='annex'] | /*/*[local-name()='bibliography']/*[count(.//*[local-name() = 'bibitem'][not(@hidden) = 'true']) &gt; 0 and not(@hidden = 'true')]">
							<xsl:sort select="@displayorder" data-type="number"/>
							<item><xsl:apply-templates select="." mode="linear_xml"/></item>
						</xsl:for-each>

						<item>
							<xsl:copy-of select="//jis:indexsect"/>
						</item>

					</xsl:variable>

					<!-- <xsl:if test="$debug = 'true'">
						<redirect:write file="structured_xml_.xml">
							<xsl:copy-of select="$structured_xml_"/>
						</redirect:write>
					</xsl:if> -->

					<!-- page break before each section -->
					<xsl:variable name="structured_xml">
						<xsl:for-each select="xalan:nodeset($structured_xml_)/item[*]">
							<xsl:element name="pagebreak" namespace="{$namespace_full}"/>
							<xsl:copy-of select="./*"/>
						</xsl:for-each>
					</xsl:variable>

					<!-- <xsl:if test="$debug = 'true'">
						<redirect:write file="structured_xml_.xml">
							<xsl:copy-of select="$structured_xml"/>
						</redirect:write>
					</xsl:if> -->

					<xsl:variable name="paged_xml">
						<xsl:call-template name="makePagedXML">
							<xsl:with-param name="structured_xml" select="$structured_xml"/>
						</xsl:call-template>
					</xsl:variable>
					<!-- paged_xml=<xsl:copy-of select="$paged_xml"/> -->

					<xsl:for-each select="xalan:nodeset($paged_xml)/*[local-name()='page'][*]">

						<xsl:variable name="isCommentary" select="normalize-space(.//jis:annex[@commentary = 'true'] and 1 = 1)"/> <!-- true or false -->
						<!-- DEBUG: <xsl:copy-of select="."/> -->
						<fo:page-sequence master-reference="document" force-page-count="no-force">

							<xsl:choose>
								<xsl:when test="$vertical_layout = 'true'">
									<xsl:attribute name="master-reference">document_2024</xsl:attribute>
									<xsl:if test="position() = last()">
										<xsl:attribute name="master-reference">document_2024_with_last</xsl:attribute>
									</xsl:if>

									<xsl:attribute name="format">一</xsl:attribute>
									<!-- <xsl:attribute name="fox:number-conversion-features">&#x30A2;</xsl:attribute> -->
								</xsl:when>
								<xsl:otherwise>
									<xsl:if test="position() = 1">
										<xsl:attribute name="master-reference">document_first_section</xsl:attribute>
									</xsl:if>
									<xsl:if test="@orientation = 'landscape'">
										<xsl:attribute name="master-reference">document-<xsl:value-of select="@orientation"/></xsl:attribute>
									</xsl:if>
									<xsl:if test="$isCommentary = 'true'">
										<xsl:attribute name="master-reference">document_commentary_section</xsl:attribute>
									</xsl:if>
									<xsl:if test="position() = 1">
										<xsl:attribute name="initial-page-number">1</xsl:attribute>
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>

							<fo:static-content flow-name="xsl-footnote-separator">
								<fo:block>
									<fo:leader leader-pattern="rule" leader-length="15%"/>
								</fo:block>
							</fo:static-content>

							<xsl:variable name="section_title">
								<xsl:if test="$isCommentary = 'true'">
									<fo:inline padding-left="2mm">
										<xsl:if test="not($vertical_layout = 'true')">
											<xsl:attribute name="font-family">IPAexGothic</xsl:attribute>
										</xsl:if>
										<xsl:text> </xsl:text>
										<xsl:call-template name="getLocalizedString">
											<xsl:with-param name="key">commentary</xsl:with-param>
										</xsl:call-template>
									</fo:inline>
								</xsl:if>
							</xsl:variable>

							<xsl:variable name="section">
								<xsl:choose>
									<xsl:when test="$isCommentary = 'true'">commentary</xsl:when>
									<xsl:otherwise>main</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>

							<xsl:choose>
								<xsl:when test="$vertical_layout = 'true'">
									<xsl:call-template name="insertLeftRightRegions">
										<xsl:with-param name="cover_header_footer_background" select="$cover_header_footer_background"/>
										<xsl:with-param name="title_ja" select="$title_ja"/>
										<xsl:with-param name="i18n_JIS" select="$i18n_JIS"/>
										<xsl:with-param name="docidentifier" select="concat('JIS ', $docidentifier_JIS)"/>
										<xsl:with-param name="docidentifier_jis" select="$docidentifier_JIS_"/>
										<xsl:with-param name="edition" select="$edition"/>
										<xsl:with-param name="copyrightText">
											<xsl:copy-of select="$copyrightText"/>
										</xsl:with-param>
										<xsl:with-param name="insertLast" select="normalize-space(position() = last())"/>
										<xsl:with-param name="bibdata" select="$bibdata"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="insertHeaderFooter">
										<xsl:with-param name="docidentifier" select="$docidentifier"/>
										<xsl:with-param name="copyrightText" select="$copyrightText"/>
										<xsl:with-param name="section" select="$section"/>
										<xsl:with-param name="section_title">
											<xsl:copy-of select="$section_title"/>
										</xsl:with-param>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>

							<fo:flow flow-name="xsl-region-body">

								<!-- <xsl:if test="position() = 1">
									<fo:table table-layout="fixed" width="100%">
										<fo:table-column column-width="proportional-column-width(35)"/>
										<fo:table-column column-width="proportional-column-width(97)"/>
										<fo:table-column column-width="proportional-column-width(23)"/>
										<fo:table-column column-width="proportional-column-width(12)"/>
										<fo:table-body>
											<fo:table-row>
												<fo:table-cell><fo:block></fo:block></fo:table-cell>
												<fo:table-cell font-family="IPAexGothic" font-size="14pt" text-align="center">
													<fo:block>
														<xsl:call-template name="getLocalizedString">
															<xsl:with-param name="key">doctype_dict.<xsl:value-of select="$doctype"/></xsl:with-param>
														</xsl:call-template>
													</fo:block>
												</fo:table-cell>
												<fo:table-cell text-align="right">
													<fo:block font-family="Arial" font-size="16pt">
														<xsl:value-of select="java:replaceAll(java:java.lang.String.new($docnumber), '^(JIS)(.*)', '$1')"/>
														<fo:block/>
														<xsl:value-of select="java:replaceAll(java:java.lang.String.new($docnumber), '^(JIS)?(.*)', '$2')"/>
													</fo:block>
												</fo:table-cell>
												<fo:table-cell display-align="after">
													<fo:block font-size="10pt">
														<fo:inline baseline-shift="40%">
															<fo:inline font-family="IPAexMincho">：</fo:inline><fo:inline font-family="Times New Roman"><xsl:value-of select="$year_published"/></fo:inline>
														</fo:inline>
													</fo:block>
												</fo:table-cell>
												
											</fo:table-row>
										</fo:table-body>
									</fo:table>
									
									<fo:block font-family="IPAexGothic" font-size="19pt" text-align="center" margin-top="12mm" margin-bottom="4mm"><xsl:value-of select="$title_ja"/></fo:block>
									<fo:block font-family="Arial" font-size="13pt" text-align="center" margin-bottom="10mm"><xsl:value-of select="$title_en"/></fo:block>
									
								</xsl:if> -->

								<!-- Annex Commentary first page -->
								<!-- <xsl:if test="$isCommentary = 'true'"> -->

									<!-- Example: JIS Z 8301：2019  -->
									<!-- <fo:block font-family="IPAexGothic" font-size="15pt" text-align="center">
										<fo:inline font-family="Arial">JIS <xsl:value-of select="$docidentifier_number"/></fo:inline>
										<fo:inline baseline-shift="10%"><fo:inline font-size="10pt">：</fo:inline>
										<fo:inline font-family="Times New Roman" font-size="10pt"><xsl:value-of select="$docidentifier_year"/></fo:inline></fo:inline>
									</fo:block> -->

									<!-- title -->
									<!-- <fo:block role="H1" font-family="IPAexGothic" font-size="16pt" text-align="center" margin-top="6mm"><xsl:value-of select="$title_ja"/></fo:block> -->
								<!-- </xsl:if> -->

								<xsl:if test="$vertical_layout = 'true' and position() = 1">
									<fo:block font-weight="bold" font-size="12pt" margin-top="5mm" letter-spacing="4mm" margin-left="-6mm">
										<xsl:value-of select="$i18n_JIS"/>
									</fo:block>
								</xsl:if>

								<xsl:apply-templates select="*" mode="page"/>

								<xsl:if test="not(*)">
									<fo:block><!-- prevent fop error for empty document --></fo:block>
								</xsl:if>

							</fo:flow>
						</fo:page-sequence>
					</xsl:for-each>

					<xsl:if test="$isGenerateTableIF = 'false'">
					<!-- insert Last Cover Page on English for Japanese document -->
					<xsl:if test="$doctype = 'technical-specification' and $doclang != 'en'">
						<xsl:call-template name="insertCoverPageJSA">
							<xsl:with-param name="num" select="$num"/>
							<xsl:with-param name="doclang" select="'en'"/>
							<xsl:with-param name="first">false</xsl:with-param>
							<xsl:with-param name="docidentifier_jis" select="$docidentifier_JIS_"/>
						</xsl:call-template>
					</xsl:if>

					<xsl:if test="$vertical_layout = 'true'">
						<xsl:call-template name="insertBackPage2024">
							<xsl:with-param name="num" select="$num"/>
							<xsl:with-param name="copyrightText">
								<xsl:copy-of select="$copyrightText"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
					</xsl:if>

				</xsl:for-each>

			</xsl:for-each>

			<xsl:if test="not(//jis:metanorma)">
				<fo:page-sequence master-reference="document" force-page-count="no-force">
					<fo:flow flow-name="xsl-region-body">
						<fo:block><!-- prevent fop error for empty document --></fo:block>
					</fo:flow>
				</fo:page-sequence>
			</xsl:if>

		</fo:root>
	</xsl:template>

	<xsl:template match="*[local-name() = 'references'][not(@hidden = 'true')]" mode="linear_xml" priority="2">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="linear_xml"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'colon_gothic']">
		<!-- replace : to ： (Fullwidth colon) and render it in the font IPAexGothic -->
		<fo:inline><xsl:if test="not($vertical_layout = 'true')"><xsl:attribute name="font-family">IPAexGothic</xsl:attribute></xsl:if>：</fo:inline>
	</xsl:template>

	<xsl:template match="*[local-name()='preface']/*[local-name() = 'clause'][@type = 'toc']" priority="4">
		<xsl:param name="num"/>
		<xsl:apply-templates/>
		<xsl:if test="count(*) = 1 and *[local-name() = 'title']"> <!-- if there isn't user ToC -->
			<!-- fill ToC -->
			<fo:block role="TOC">
				<xsl:if test="not($vertical_layout = 'true') and not($lang = 'en')">
					<xsl:attribute name="font-family">IPAexGothic</xsl:attribute>
				</xsl:if>
				<xsl:if test="$vertical_layout = 'true'">
					<xsl:attribute name="font-size">10.5pt</xsl:attribute>
				</xsl:if>

				<xsl:if test="$updated_contents_xml/doc[@num = $num]//item[@display = 'true']">
					<xsl:for-each select="$updated_contents_xml/doc[@num = $num]//item[@display = 'true'][@level &lt;= $toc_level or @type='figure' or @type = 'table']">
						<fo:block role="TOCI">
							<xsl:choose>
								<xsl:when test="@type = 'annex' or @type = 'bibliography'">
									<fo:block space-after="5pt" role="SKIP">
										<xsl:if test="$vertical_layout = 'true'">
											<xsl:attribute name="space-after">8pt</xsl:attribute>
										</xsl:if>
										<xsl:call-template name="insertTocItem"/>
									</fo:block>
								</xsl:when>
								<xsl:otherwise>
									<fo:list-block space-after="5pt" role="SKIP">
										<xsl:if test="$vertical_layout = 'true'">
											<xsl:attribute name="space-after">8pt</xsl:attribute>
										</xsl:if>
										<xsl:choose>
											<xsl:when test="$vertical_layout = 'true'">
												<xsl:attribute name="provisional-distance-between-starts">15mm</xsl:attribute> <!-- 10 isn't enought for 3 chars numbers -->
											</xsl:when>
											<xsl:otherwise>
												<xsl:variable name="provisional-distance-between-starts">
													<xsl:choose>
														<xsl:when test="string-length(@section) = 1">5</xsl:when>
														<xsl:when test="string-length(@section) &gt;= 2"><xsl:value-of select="5 + (string-length(@section) - 1) * 2"/></xsl:when>
														<xsl:when test="@type = 'annex'">16</xsl:when>
														<xsl:otherwise>5</xsl:otherwise>
													</xsl:choose>
												</xsl:variable>
												<xsl:attribute name="provisional-distance-between-starts">
													<xsl:choose>
														<xsl:when test="$vertical_layout_rotate_clause_numbers = 'true'">
															<xsl:value-of select="concat($provisional-distance-between-starts * 1.5, 'mm')"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of select="concat($provisional-distance-between-starts, 'mm')"/>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:attribute>
												</xsl:otherwise>
											</xsl:choose>
										<fo:list-item role="SKIP">
											<fo:list-item-label end-indent="label-end()" role="SKIP">
												<fo:block role="SKIP">
													<xsl:if test="not($vertical_layout = 'true') and @section != '' and @type != 'annex'">
														<xsl:attribute name="font-family">Times New Roman</xsl:attribute>
														<xsl:attribute name="font-weight">bold</xsl:attribute>
													</xsl:if>
													<xsl:value-of select="@section"/>
												</fo:block>
											</fo:list-item-label>
											<fo:list-item-body start-indent="body-start()" role="SKIP">
												<xsl:call-template name="insertTocItem"/>
											</fo:list-item-body>
										</fo:list-item>
									</fo:list-block>
								</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</xsl:for-each>
				</xsl:if>
			</fo:block>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'clause'][@type = 'toc']/*[local-name() = 'title']" priority="3">
		<fo:block text-align="center" font-size="14pt" margin-top="8.5mm">
			<xsl:if test="not($vertical_layout = 'true')">
				<xsl:attribute name="font-family">IPAexGothic</xsl:attribute>
			</xsl:if>
			<xsl:if test="$vertical_layout = 'true'">
				<xsl:attribute name="text-align">left</xsl:attribute>
				<xsl:attribute name="font-weight">bold</xsl:attribute>
				<!-- <xsl:attribute name="margin-top">26mm</xsl:attribute> -->
				<!-- Contents -->
				<!-- <xsl:call-template name="getLocalizedString">
					<xsl:with-param name="key">table_of_contents</xsl:with-param>
				</xsl:call-template> -->
				<fo:marker marker-class-name="section_title">
					<xsl:variable name="section_title_"><xsl:apply-templates/></xsl:variable>
					<xsl:variable name="section_title" select="translate($section_title_, '　', '')"/>
					<xsl:call-template name="insertVerticalChar">
						<xsl:with-param name="str" select="$section_title"/>
					</xsl:call-template>
				</fo:marker>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
		<fo:block text-align="right" margin-top="10mm">
			<xsl:if test="not($vertical_layout = 'true')">
				<xsl:attribute name="font-family">IPAexMincho</xsl:attribute>
				<xsl:attribute name="font-size">8pt</xsl:attribute>
			</xsl:if>
			<xsl:if test="$vertical_layout = 'true'">
				<xsl:attribute name="font-size">10.5pt</xsl:attribute>
				<xsl:attribute name="margin-top">1mm</xsl:attribute>
				<xsl:attribute name="margin-bottom">6mm</xsl:attribute>
			</xsl:if>
			<!-- Page -->
			<xsl:call-template name="getLocalizedString">
				<xsl:with-param name="key">locality.page</xsl:with-param>
			</xsl:call-template>
		</fo:block>
	</xsl:template>

	<xsl:template name="insertTocItem">
		<fo:block text-align-last="justify" role="SKIP">
			<fo:basic-link internal-destination="{@id}" fox:alt-text="{normalize-space(title)}">
				<fo:inline>
					<xsl:if test="$vertical_layout = 'true'">
						<xsl:attribute name="padding-right">7.5mm</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates select="title"/>
				</fo:inline>
				<fo:inline keep-together.within-line="always">
					<fo:leader leader-pattern="dots">
						<xsl:if test="$vertical_layout = 'true'">
							<xsl:attribute name="leader-pattern">rule</xsl:attribute>
							<xsl:attribute name="rule-thickness">0.5pt</xsl:attribute>
							<xsl:attribute name="baseline-shift">60%</xsl:attribute>
						</xsl:if>
					</fo:leader>
					<fo:inline>
						<xsl:if test="not($vertical_layout = 'true')">
							<xsl:attribute name="font-size">8pt</xsl:attribute>
							<xsl:attribute name="font-family">Times New Roman</xsl:attribute>
						</xsl:if>
						<xsl:if test="$vertical_layout = 'true'">
							<xsl:attribute name="padding-left">6mm</xsl:attribute>
						</xsl:if>
						<fo:page-number-citation ref-id="{@id}"/>
					</fo:inline>
				</fo:inline>
			</fo:basic-link>
		</fo:block>
	</xsl:template>

	<xsl:template name="insertCoverPage">
		<xsl:param name="num"/>
		<xsl:param name="copyrightText"/>
		<xsl:param name="docidentifier_jis"/>

		<!-- docidentifier, 3 part: number, colon and year-->
		<xsl:variable name="docidentifier_number" select="java:replaceAll(java:java.lang.String.new($docidentifier_jis), '^(.*)(:)(.*)$', '$1')"/>
		<xsl:variable name="docidentifier_year" select="java:replaceAll(java:java.lang.String.new($docidentifier_jis), '^(.*)(:)(.*)$', '$3')"/>

		<fo:page-sequence master-reference="cover-page" force-page-count="no-force">
			<xsl:call-template name="insertFooter">
				<xsl:with-param name="copyrightText" select="$copyrightText"/>
			</xsl:call-template>

			<fo:flow flow-name="xsl-region-body">
				<!-- JIS -->
				<fo:block>
					<xsl:if test="$num = 1">
						<xsl:attribute name="id">firstpage_id_0</xsl:attribute>
					</xsl:if>
					<fo:block id="firstpage_id_{$num}">
						<fo:instream-foreign-object content-width="81mm" fox:alt-text="JIS Logo">
							<xsl:copy-of select="$JIS-Logo"/>
						</fo:instream-foreign-object>
					</fo:block>
				</fo:block>

				<fo:block-container text-align="center">
					<!-- title -->
					<fo:block role="H1" font-family="IPAexGothic" font-size="22pt" margin-top="27mm"><xsl:apply-templates select="/*/jis:bibdata/jis:title[@language = 'ja' and @type = 'main']/node()"/></fo:block>

					<fo:block font-family="IPAexGothic" font-size="20pt" margin-top="15mm">
						<fo:inline font-family="Arial">JIS <xsl:value-of select="$docidentifier_number"/></fo:inline>
						<fo:inline baseline-shift="20%"><fo:inline font-size="10pt">：</fo:inline>
						<fo:inline font-family="Times New Roman" font-size="10pt"><xsl:value-of select="$docidentifier_year"/></fo:inline></fo:inline>
					</fo:block>
					<fo:block font-family="Arial" font-size="14pt" margin-top="12mm">
						<fo:inline font-family="IPAexMincho">（</fo:inline>
						<!-- JSA -->
						<xsl:value-of select="/*/jis:bibdata/jis:copyright/jis:owner/jis:organization/jis:abbreviation"/>
						<fo:inline font-family="IPAexMincho">）</fo:inline></fo:block>
				</fo:block-container>

				<fo:block-container absolute-position="fixed" left="0mm" top="200mm" height="69mm" text-align="center" display-align="after" font-family="IPAexMincho">
					<!-- Revised on July 22, 2019 -->
					<!-- <fo:block font-size="9pt">令和元年<fo:inline font-family="Times New Roman"> 7 </fo:inline>月<fo:inline font-family="Times New Roman"> 22 </fo:inline>日 改正</fo:block> -->
					<fo:block font-size="9pt"><xsl:apply-templates select="/*/jis:bibdata/jis:date[@type = 'published']/text()"/> 改正</fo:block>
					<!-- Japan Industrial Standards Survey Council deliberations -->
					<!-- 日本産業標準調査会 -->
					<fo:block font-size="14pt" margin-top="7mm"><xsl:value-of select="/*/jis:bibdata/jis:contributor[jis:role/@type = 'authorizer']/jis:organization/jis:name/jis:variant[@language = 'ja']"/> 審議</fo:block>
					<!-- (Issued by the Japan Standards Association) -->
					<!-- 日本規格協会 -->
					<fo:block font-size="9pt" margin-top="6.5mm">（<xsl:value-of select="/*/jis:bibdata/jis:contributor[jis:role/@type = 'publisher']/jis:organization/jis:name/jis:variant[@language = 'ja']"/> 発行）</fo:block>
				</fo:block-container>
			</fo:flow>
		</fo:page-sequence>
	</xsl:template> <!-- insertCoverPage -->

	<xsl:template name="insertCoverPageJSA">
		<xsl:param name="num"/>
		<xsl:param name="doclang"/>
		<xsl:param name="first">true</xsl:param>
		<xsl:param name="docidentifier_jis"/>

		<fo:page-sequence master-reference="cover-page-JSA" force-page-count="no-force">
			<fo:static-content flow-name="footer" font-family="IPAexGothic" font-size="10pt" line-height="1.7">
				<fo:block text-align="center">
					<fo:block>
						<xsl:if test="$doclang = 'en'">Published </xsl:if>
						<xsl:apply-templates select="/*/jis:bibdata/jis:date[@type = 'published']//text()"/>
						<xsl:if test="$doclang = 'ja'">
							<xsl:text> 発行</xsl:text>
						</xsl:if>
					</fo:block>
					<fo:block>
					<xsl:text>ICS </xsl:text>
						<xsl:for-each select="/*/jis:bibdata/jis:ext/jis:ics/jis:code">
							<xsl:text> </xsl:text>
							<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.), '(\.)', concat($thin_space,'$1',$thin_space))"/>
						</xsl:for-each>
					</fo:block>
				</fo:block>
			</fo:static-content>

			<fo:flow flow-name="xsl-region-body">
				<!-- JSA cover, background image -->
				<fo:block-container absolute-position="fixed" left="0mm" top="0mm" font-size="0" id="__internal_layout__coverpage_{$doclang}_{$num}_{generate-id()}">
					<fo:block>
						<xsl:if test="$first = 'true'">
							<xsl:attribute name="id">firstpage_id_<xsl:value-of select="$num"/></xsl:attribute>
						</xsl:if>
						<fo:external-graphic fox:alt-text="Image Cover">
							<xsl:attribute name="src">
								<xsl:text>data:application/pdf;base64,</xsl:text>
								<xsl:choose>
									<xsl:when test="$doclang = 'ja'"><xsl:value-of select="$JSA-Cover-ja"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="$JSA-Cover-en"/></xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
						</fo:external-graphic>
					</fo:block>
				</fo:block-container>

				<fo:block-container text-align="center">
					<fo:block font-family="IPAexGothic" font-size="15pt">
						<xsl:value-of select="$docidentifier_jis"/>
					</fo:block>
					<!-- title -->
					<fo:block role="H1" font-family="IPAexGothic" font-size="32pt" line-height="1.3">
						<xsl:if test="$doclang = 'en'">
							<xsl:attribute name="font-size">25pt</xsl:attribute>
							<xsl:attribute name="margin-top">2mm</xsl:attribute>
						</xsl:if>
						<xsl:apply-templates select="/*/jis:bibdata/jis:title[@language = $doclang and @type = 'main']/node()"/>
					</fo:block>

				</fo:block-container>

			</fo:flow>
		</fo:page-sequence>
	</xsl:template> <!-- insertCoverPageJSA -->

	<xsl:variable name="i18n_JIS_">
		<xsl:variable name="coverpage_header" select="normalize-space(/*/jis:metanorma-extension/jis:presentation-metadata/jis:coverpage-header)"/>
		<xsl:value-of select="$coverpage_header"/>
		<xsl:if test="$coverpage_header = ''">
			<xsl:call-template name="getLocalizedString"><xsl:with-param name="key">JIS</xsl:with-param></xsl:call-template>
		</xsl:if>
	</xsl:variable>
	<xsl:variable name="i18n_JIS" select="normalize-space($i18n_JIS_)"/>

	<xsl:template name="insertCoverPage2024">
		<xsl:param name="num"/>
		<xsl:param name="docidentifier_jis"/>

		<!-- docidentifier, 3 part: number, colon and year-->
		<xsl:variable name="docidentifier_number" select="java:replaceAll(java:java.lang.String.new($docidentifier_jis), '^(.*)(:)(.*)$', '$1')"/>
		<xsl:variable name="docidentifier_year" select="java:replaceAll(java:java.lang.String.new($docidentifier_jis), '^(.*)(:)(.*)$', '$3')"/>

		<fo:page-sequence master-reference="cover-page_2024" force-page-count="no-force">

			<!-- <xsl:variable name="cover_page_background_1_value" select="normalize-space(//jis:metanorma/jis:metanorma-extension/jis:presentation-metadata/jis:color-cover-page-background-1)"/>
			<xsl:variable name="cover_page_background_1_">
				<xsl:value-of select="$cover_page_background_1_value"/>
				<xsl:if test="$cover_page_background_1_value = ''">#00063F</xsl:if>
			</xsl:variable>
			<xsl:variable name="cover_page_background_1" select="normalize-space($cover_page_background_1_)"/>
			
			<xsl:variable name="cover_page_background_2_value" select="normalize-space(//jis:metanorma/jis:metanorma-extension/jis:presentation-metadata/jis:color-cover-page-background-2)"/>
			<xsl:variable name="cover_page_background_2_">
				<xsl:value-of select="$cover_page_background_2_value"/>
				<xsl:if test="$cover_page_background_2_value = ''">#DBD6BD</xsl:if>
			</xsl:variable>
			<xsl:variable name="cover_page_background_2" select="normalize-space($cover_page_background_2_)"/> -->

			<fo:static-content flow-name="header">
				<xsl:call-template name="insertBackgroundPageImage"/>

				<!-- vertical bar -->
				<!-- <xsl:call-template name="insertBackgroundColor">
					<xsl:with-param name="opacity">0.58</xsl:with-param>
					<xsl:with-param name="color_background" select="$cover_page_background_1"/>
					<xsl:with-param name="width">20mm</xsl:with-param>
					<xsl:with-param name="absolute_position">true</xsl:with-param>
				</xsl:call-template> -->

				<!-- vertical bar -->
				<!-- <xsl:call-template name="insertBackgroundColor">
					<xsl:with-param name="opacity">0.75</xsl:with-param>
					<xsl:with-param name="color_background" select="$cover_page_background_2"/>
					<xsl:with-param name="width">46.5mm</xsl:with-param>
					<xsl:with-param name="absolute_position">true</xsl:with-param>
					<xsl:with-param name="left">20mm</xsl:with-param>
				</xsl:call-template> -->

				<!-- vertical bar -->
				<!-- <xsl:call-template name="insertBackgroundColor">
					<xsl:with-param name="opacity">0.75</xsl:with-param>
					<xsl:with-param name="color_background" select="$cover_page_background_2"/>
					<xsl:with-param name="width">10.7mm</xsl:with-param>
					<xsl:with-param name="absolute_position">true</xsl:with-param>
					<xsl:with-param name="left">133.8mm</xsl:with-param>
				</xsl:call-template> -->

				<!-- vertical bar -->
				<!-- <xsl:call-template name="insertBackgroundColor">
					<xsl:with-param name="opacity">0.58</xsl:with-param>
					<xsl:with-param name="color_background" select="$cover_page_background_1"/>
					<xsl:with-param name="width">17mm</xsl:with-param>
					<xsl:with-param name="absolute_position">true</xsl:with-param>
					<xsl:with-param name="left">131mm</xsl:with-param>
				</xsl:call-template> -->

			</fo:static-content>

			<fo:static-content flow-name="left-region">
				<fo:table table-layout="fixed" width="9mm" font-size="10pt" font-weight="bold" color="white" margin-left="2.7mm" margin-top="-1mm" line-height="1.5">
					<fo:table-column column-width="proportional-column-width(3)"/>
					<fo:table-column column-width="proportional-column-width(2.2)"/>
					<fo:table-column column-width="proportional-column-width(3)"/>
					<xsl:variable name="publisher" select="/*/jis:bibdata/jis:contributor[jis:role/@type = 'publisher']/jis:organization/jis:name/jis:variant[@language = 'ja']"/>
					<xsl:variable name="authorizer" select="/*/jis:bibdata/jis:contributor[jis:role/@type = 'authorizer']//jis:organization/jis:name"/>
					<fo:table-body>
						<fo:table-row height="50mm">
							<fo:table-cell>
								<fo:block id="__internal_layout__coverpage_footer_block1_{$num}_{generate-id()}"><xsl:value-of select="$publisher"/></fo:block>
							</fo:table-cell>
							<fo:table-cell><fo:block id="__internal_layout__coverpage_footer_block2_{$num}_{generate-id()}"> </fo:block></fo:table-cell>
							<fo:table-cell>
								<fo:block id="__internal_layout__coverpage_footer_block3_{$num}_{generate-id()}"><xsl:value-of select="$authorizer"/></fo:block>
							</fo:table-cell>
						</fo:table-row>
						<fo:table-row>
							<fo:table-cell>
								<fo:block id="__internal_layout__coverpage_footer_block4_{$num}_{generate-id()}"><xsl:if test="normalize-space($publisher) != ''">発行</xsl:if></fo:block>
							</fo:table-cell>
							<fo:table-cell><fo:block id="__internal_layout__coverpage_footer_block5_{$num}_{generate-id()}"> </fo:block></fo:table-cell>
							<fo:table-cell>
								<fo:block id="__internal_layout__coverpage_footer_block6_{$num}_{generate-id()}"><xsl:if test="normalize-space($authorizer) != ''">審議</xsl:if></fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</fo:static-content>

			<!-- <fo:static-content flow-name="left-region"> -->

				<!-- JIS, JSA_logos -->
				<!-- <fo:block-container absolute-position="fixed" left="2.4mm" top="171mm" font-size="0">
					<fo:block id="firstpage_id_{$num}" margin-left="2mm">
						<fo:instream-foreign-object content-width="12.1mm" fox:alt-text="JIS Logo">
							<xsl:copy-of select="$JIS-Logo_2024"/>
						</fo:instream-foreign-object>
					</fo:block>
					<fo:block margin-top="3mm">
						<fo:instream-foreign-object content-width="15.2mm" fox:alt-text="JSA Logo">
							<xsl:copy-of select="$JSA-Logo_2024"/>
						</fo:instream-foreign-object>
					</fo:block>
				</fo:block-container>
			</fo:static-content> -->

			<fo:flow flow-name="xsl-region-body" font-family="Noto Serif JP">

				<fo:block font-weight="900" font-size="14pt" color="white" letter-spacing="2.5mm">
					<xsl:value-of select="$i18n_JIS"/>
				</fo:block>

				<fo:block margin-top="75mm" font-size="14pt" font-weight="500">

					<fo:inline-container writing-mode="lr-tb" text-align="center" alignment-baseline="central" reference-orientation="90" width="1em" margin="0" padding="0" text-indent="0mm" last-line-end-indent="0mm" start-indent="0mm" end-indent="0mm">

							<xsl:variable name="blocks">
								<xsl:call-template name="insertEachCharInBlock">
									<xsl:with-param name="str">JIS <xsl:value-of select="java:replaceAll(java:java.lang.String.new($docidentifier_number), ' ', '  ')"/></xsl:with-param>
									<xsl:with-param name="spaceIndent">0.5em</xsl:with-param>
									<xsl:with-param name="lineHeight">1.1em</xsl:with-param>
								</xsl:call-template>
								<fo:block line-height="1em" margin-top="0.2em"/>
							</xsl:variable>
							<xsl:variable name="blocksWidth">
								<xsl:for-each select="xalan:nodeset($blocks)//@line-height[normalize-space(..) != '']">
									<width><xsl:value-of select="substring-before(.,'em')"/></width>
								</xsl:for-each>
								<xsl:for-each select="xalan:nodeset($blocks)//@margin-top">
									<width><xsl:value-of select="substring-before(.,'em')"/></width>
								</xsl:for-each>
							</xsl:variable>
							<xsl:attribute name="width"><xsl:value-of select="sum(xalan:nodeset($blocksWidth)//width)"/>em</xsl:attribute>
							<fo:block-container width="1em" id="__internal_layout__coverpage_block1_{$num}_{generate-id()}">
								<xsl:copy-of select="$blocks"/>
							</fo:block-container>
					</fo:inline-container>

					<fo:inline font-size="8.16pt" baseline-shift="20%">:</fo:inline>

					<fo:inline-container writing-mode="lr-tb" text-align="center" alignment-baseline="central" reference-orientation="90" width="1em" margin="0" padding="0" text-indent="0mm" last-line-end-indent="0mm" start-indent="0mm" end-indent="0mm">
							<fo:block-container width="1em" id="__internal_layout__coverpage_block2_{$num}_{generate-id()}">
								<fo:block line-height="1em" margin-top="0.2em"/>
								<fo:block font-size="8.16pt" baseline-shift="20%">
									<xsl:call-template name="insertEachCharInBlock">
										<xsl:with-param name="str"><xsl:value-of select="$docidentifier_year"/></xsl:with-param>
										<xsl:with-param name="lineHeight">1em</xsl:with-param>
									</xsl:call-template>
								</fo:block>
							</fo:block-container>
					</fo:inline-container>
				</fo:block>

				<fo:block margin-top="2mm" letter-spacing="2mm" font-weight="bold">
					<xsl:variable name="title_len" select="string-length(/*/jis:bibdata/jis:title[@language = 'ja' and @type = 'main']/node())"/>
					<xsl:attribute name="font-size">
						<xsl:choose>
							<xsl:when test="$title_len &gt; 20">16pt</xsl:when>
							<xsl:when test="$title_len &gt; 16">18pt</xsl:when>
							<xsl:when test="$title_len &gt; 13">20pt</xsl:when>
							<xsl:otherwise>24pt</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:apply-templates select="/*/jis:bibdata/jis:title[@language = 'ja' and @type = 'main']/node()"/>
				</fo:block>

				<fo:block margin-top="3mm" font-size="11pt" font-weight="500">
					<xsl:apply-templates select="/*/jis:bibdata/jis:title[@language = 'en' and @type = 'main']/node()"/>
				</fo:block>

				<fo:block margin-top="6.5mm" font-size="8pt" font-weight="500">
					<xsl:variable name="revised_date"><xsl:apply-templates select="/*/jis:bibdata/jis:date[@type = 'revised']/text()"/></xsl:variable>
					<xsl:if test="normalize-space($revised_date) != ''"><fo:inline padding-right="5mm"><xsl:copy-of select="$revised_date"/></fo:inline>改正</xsl:if>
				</fo:block>

			</fo:flow>
		</fo:page-sequence>
	</xsl:template> <!-- insertCoverPage2024 -->

	<xsl:template name="insertBackPage2024">
		<xsl:param name="num"/>
		<xsl:param name="copyrightText"/>

		<fo:page-sequence master-reference="back-page_2024" force-page-count="no-force" font-family="Noto Serif JP" font-weight="500">

			<fo:static-content flow-name="header">
				<xsl:variable name="presentation_metadata_image_name">
					<xsl:choose>
						<xsl:when test="/*[local-name() = 'metanorma']/*[local-name() = 'metanorma-extension']/*[local-name() = 'presentation-metadata'][*[local-name() = 'name'] = 'backpage-image']/*[local-name() = 'value']/*[local-name() = 'image']">backpage-image</xsl:when>
						<xsl:otherwise>coverpage-image</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:call-template name="insertBackgroundPageImage">
					<xsl:with-param name="name" select="$presentation_metadata_image_name"/>
					<xsl:with-param name="suffix">back</xsl:with-param>
				</xsl:call-template>
			</fo:static-content>

			<fo:flow flow-name="xsl-region-body">
				<!-- publication date -->
				<fo:block font-size="8pt" margin-left="90mm" text-align-last="justify" letter-spacing="0.5mm">
					<xsl:variable name="date_published"><xsl:apply-templates select="/*/jis:bibdata/jis:date[@type = 'published']/text()"/></xsl:variable>
					<xsl:copy-of select="$date_published"/>
					<xsl:choose>
						<xsl:when test="normalize-space($date_published) != ''">
							<fo:inline keep-together.within-line="always">
								<fo:leader leader-pattern="space"/>
								<xsl:text>発行</xsl:text>
							</fo:inline>
						</xsl:when>
						<xsl:otherwise> </xsl:otherwise>
					</xsl:choose>
				</fo:block>
				<!-- revision date -->
				<fo:block font-size="8pt" margin-left="90mm" text-align-last="justify" letter-spacing="0.5mm">
					<xsl:variable name="date_revised"><xsl:apply-templates select="/*/jis:bibdata/jis:date[@type = 'revised']/text()"/></xsl:variable>
					<xsl:copy-of select="$date_revised"/>
					<xsl:choose>
						<xsl:when test="normalize-space($date_revised) != ''">
							<fo:inline keep-together.within-line="always">
								<fo:leader leader-pattern="space"/>
								<xsl:text>改正</xsl:text>
							</fo:inline>
						</xsl:when>
						<xsl:otherwise> </xsl:otherwise>
					</xsl:choose>
				</fo:block>
				<fo:block font-size="12pt" margin-top="7mm" text-align="right">
					<!-- <xsl:value-of select="$copyrightText"/> -->
					<xsl:copy-of select="$copyrightText"/>
				</fo:block>
			</fo:flow>
		</fo:page-sequence>
	</xsl:template> <!-- insertBackPage2024 -->

	<xsl:template name="insertBackgroundColor">
		<xsl:param name="opacity">1</xsl:param>
		<xsl:param name="color_background">#ffffff</xsl:param>
		<xsl:param name="width">20mm</xsl:param>
		<xsl:param name="absolute_position">false</xsl:param>
		<xsl:param name="left"/>

		<!-- background color -->
		<fo:block-container font-size="0"> <!-- absolute-position="fixed" left="0" top="0"  -->
			<xsl:if test="$absolute_position = 'true'">
				<xsl:attribute name="absolute-position">fixed</xsl:attribute>
				<xsl:attribute name="top">0</xsl:attribute>
			</xsl:if>
			<xsl:if test="normalize-space($left) != ''">
				<xsl:attribute name="left"><xsl:value-of select="$left"/></xsl:attribute>
			</xsl:if>
			<fo:block>
				<fo:instream-foreign-object content-height="{$pageHeight}mm" fox:alt-text="Background color">
					<svg xmlns="http://www.w3.org/2000/svg" version="1.0" width="{$width}" height="{$pageHeight}mm">
						<rect width="{$pageWidth}mm" height="{$pageHeight}mm" style="fill:{$color_background};stroke-width:0;fill-opacity:{$opacity}"/>
					</svg>
				</fo:instream-foreign-object>
			</fo:block>
		</fo:block-container>
	</xsl:template>

	<xsl:template name="insertInnerCoverPage">
		<xsl:param name="docidentifier"/>
		<xsl:param name="copyrightText"/>
		<fo:page-sequence master-reference="document" force-page-count="no-force">

			<fo:static-content flow-name="xsl-footnote-separator">
				<fo:block text-align="center" margin-bottom="6pt">
					<fo:leader leader-pattern="rule" leader-length="80mm" rule-style="solid" rule-thickness="0.3pt"/>
				</fo:block>
			</fo:static-content>

			<xsl:call-template name="insertHeaderFooter">
				<xsl:with-param name="docidentifier" select="$docidentifier"/>
				<xsl:with-param name="copyrightText" select="$copyrightText"/>
			</xsl:call-template>

			<fo:flow flow-name="xsl-region-body">
				<fo:block-container font-size="9pt" margin-top="5mm">

					<xsl:apply-templates select="/*/*[local-name() = 'preface']/*[local-name() = 'clause'][@type = 'contributors']"/>

					<fo:block>
						<fo:footnote>
							<fo:inline/>
							<fo:footnote-body>
								<fo:block font-size="8.5pt">
									<!-- <xsl:apply-templates select="/*/*[local-name() = 'preface']/*[local-name() = 'clause'][@type = 'inner-cover-note']" /> -->
									<xsl:apply-templates select="/*/*[local-name() = 'boilerplate']"/>
								</fo:block>
							</fo:footnote-body>
						</fo:footnote>
					</fo:block>
				</fo:block-container>
			</fo:flow>
		</fo:page-sequence>
	</xsl:template> <!-- insertInnerCoverPage -->

	<xsl:template match="jis:p[@class = 'JapaneseIndustrialStandard']" priority="4">
		<xsl:if test="not($vertical_layout = 'true')">
		<fo:table table-layout="fixed" width="100%">
			<fo:table-column column-width="proportional-column-width(36)"/>
			<fo:table-column column-width="proportional-column-width(92)"/>
			<fo:table-column column-width="proportional-column-width(36)"/>
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell>
						<fo:block> </fo:block>
					</fo:table-cell>
					<fo:table-cell font-family="IPAexGothic" font-size="14pt" text-align="center">
						<fo:block><xsl:apply-templates/></fo:block>
					</fo:table-cell>
					<fo:table-cell padding-left="5mm">
						<fo:block font-family="Arial" font-size="16pt">
							<xsl:apply-templates select="jis:span[@class = 'JIS']">
								<xsl:with-param name="process">true</xsl:with-param>
							</xsl:apply-templates>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
		</xsl:if>
	</xsl:template>

	<xsl:template match="jis:p[@class = 'StandardNumber']" priority="4">
		<xsl:if test="not($vertical_layout = 'true')">
		<fo:table table-layout="fixed" width="100%">
			<fo:table-column column-width="proportional-column-width(60)"/>
			<fo:table-column column-width="proportional-column-width(44)"/>
			<fo:table-column column-width="proportional-column-width(60)"/>
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell>
						<fo:block> </fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block> </fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block>
							<xsl:apply-templates/>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
		</xsl:if>
	</xsl:template>

	<xsl:template match="jis:p[@class = 'StandardNumber']//text()[not(ancestor::jis:span)]" priority="4">
		<fo:inline font-family="Arial" font-size="16pt">
			<xsl:choose>
				<xsl:when test="contains(., ':')">
					<xsl:value-of select="substring-before(., ':')"/>
					<fo:inline baseline-shift="10%" font-size="10pt" font-family="IPAexMincho">：</fo:inline>
					<xsl:value-of select="substring-after(., ':')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>
	</xsl:template>

	<xsl:template match="jis:p[@class = 'StandardNumber']/jis:span[@class = 'EffectiveYear']" priority="4">
		<fo:inline font-size="10pt" baseline-shift="10%">
			<fo:inline font-family="Times New Roman"><xsl:apply-templates/></fo:inline>
		</fo:inline>
	</xsl:template>

	<xsl:template match="jis:p[@class = 'JapaneseIndustrialStandard']/jis:tab" priority="4"/>
		<!-- <fo:inline role="SKIP" padding-right="0mm">&#x200B;</fo:inline>
	</xsl:template> -->
	<xsl:template match="jis:p[@class = 'JapaneseIndustrialStandard']/jis:span[@class = 'JIS']" priority="4">
		<xsl:param name="process">false</xsl:param>
		<xsl:if test="$process = 'true'">
			<fo:inline font-size="16pt" font-family="Arial"><xsl:apply-templates/></fo:inline>
		</xsl:if>
	</xsl:template>

	<xsl:template match="jis:p[@class = 'zzSTDTitle1']" priority="4">
		<fo:block font-size="19pt" text-align="center" margin-top="12mm" margin-bottom="4mm">
			<xsl:if test="not($vertical_layout = 'true')">
				<xsl:attribute name="font-family">IPAexGothic</xsl:attribute>
			</xsl:if>
			<xsl:if test="$vertical_layout = 'true'">
				<xsl:attribute name="font-size">16pt</xsl:attribute>
				<xsl:attribute name="font-weight">bold</xsl:attribute>
				<xsl:attribute name="text-align">left</xsl:attribute>
				<xsl:attribute name="margin-top">6mm</xsl:attribute>
				<xsl:attribute name="margin-bottom">2.5mm</xsl:attribute>
				<xsl:attribute name="letter-spacing">3mm</xsl:attribute>
				<xsl:attribute name="margin-left">-6mm</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="jis:p[@class = 'zzSTDTitle2']" priority="4">
		<fo:block font-size="13pt" text-align="center" margin-bottom="10mm">
			<xsl:if test="not($vertical_layout = 'true')">
				<xsl:attribute name="font-family">Arial</xsl:attribute>
			</xsl:if>
			<xsl:if test="$vertical_layout = 'true'">
				<xsl:attribute name="font-size">11pt</xsl:attribute>
				<xsl:attribute name="text-align">left</xsl:attribute>
				<xsl:attribute name="margin-bottom">3mm</xsl:attribute>
				<xsl:attribute name="margin-left">-6mm</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<!-- for commentary annex -->
	<xsl:template match="jis:p[@class = 'CommentaryStandardNumber']" priority="4">
		<fo:block font-family="IPAexGothic" font-size="15pt" text-align="center">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="jis:p[@class = 'CommentaryStandardNumber']//text()[not(ancestor::jis:span)]" priority="4">
		<fo:inline font-family="Arial">
			<xsl:choose>
				<xsl:when test="contains(., ':')">
					<xsl:value-of select="substring-before(., ':')"/>
					<fo:inline baseline-shift="10%" font-size="10pt" font-family="IPAexMincho">：</fo:inline>
					<xsl:value-of select="substring-after(., ':')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>
	</xsl:template>

	<xsl:template match="jis:p[@class = 'CommentaryStandardNumber']/jis:span[@class = 'CommentaryEffectiveYear']" priority="4">
		<fo:inline baseline-shift="10%" font-family="Times New Roman" font-size="10pt"><xsl:apply-templates/></fo:inline>
	</xsl:template>

	<xsl:template match="jis:p[@class = 'CommentaryStandardName']" priority="4">
		<fo:block role="H1" font-family="IPAexGothic" font-size="16pt" text-align="center" margin-top="6mm">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<!-- ============================= -->
	<!-- CONTENTS                      -->
	<!-- ============================= -->

	<!-- element with title -->
	<xsl:template match="*[jis:title or jis:fmt-title]" mode="contents">

		<xsl:variable name="level">
			<xsl:call-template name="getLevel">
				<xsl:with-param name="depth" select="jis:fmt-title/@depth | jis:title/@depth"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- if previous clause contains section-title as latest element (section-title may contain  note's, admonition's, etc.),
		and if @depth of current clause equals to section-title @depth,
		then put section-title before current clause -->
		<xsl:if test="local-name() = 'clause'">
			<xsl:apply-templates select="preceding-sibling::*[1][local-name() = 'clause']//*[local-name() = 'p' and @type = 'section-title'     and @depth = $level      and not(following-sibling::*[local-name()='clause'])]" mode="contents_in_clause"/>
		</xsl:if>

		<xsl:variable name="section">
			<xsl:call-template name="getSection"/>
		</xsl:variable>

		<xsl:variable name="type">
			<xsl:choose>
				<xsl:when test="local-name() = 'indexsect'">index</xsl:when>
				<xsl:when test="(ancestor-or-self::jis:bibliography and local-name() = 'clause' and not(.//*[local-name() = 'references' and @normative='true'])) or self::jis:references[not(@normative) or @normative='false']">bibliography</xsl:when>
				<xsl:otherwise><xsl:value-of select="local-name()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="display">
			<xsl:choose>
				<xsl:when test="normalize-space(@id) = ''">false</xsl:when>
				<xsl:when test="ancestor-or-self::jis:annex and $level &gt;= 2">false</xsl:when>
				<xsl:when test="$type = 'bibliography' and $level &gt;= 2">false</xsl:when>
				<xsl:when test="$type = 'bibliography'">true</xsl:when>
				<xsl:when test="$type = 'references' and $level &gt;= 2">false</xsl:when>
				<xsl:when test="ancestor-or-self::jis:colophon">true</xsl:when>
				<xsl:when test="$section = '' and $type = 'clause' and $level = 1 and ancestor::jis:preface">true</xsl:when>
				<xsl:when test="$section = '' and $type = 'clause'">false</xsl:when>
				<xsl:when test="$level &lt;= $toc_level">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="skip">
			<xsl:choose>
				<xsl:when test="ancestor-or-self::jis:bibitem">true</xsl:when>
				<xsl:when test="ancestor-or-self::jis:term">true</xsl:when>
				<xsl:when test="@type = 'corrigenda'">true</xsl:when>
				<xsl:when test="@type = 'policy'">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="$skip = 'false'">

			<xsl:variable name="title">
				<xsl:call-template name="getName"/>
			</xsl:variable>

			<xsl:variable name="root">
				<xsl:if test="ancestor-or-self::jis:preface">preface</xsl:if>
				<xsl:if test="ancestor-or-self::jis:annex">annex</xsl:if>
			</xsl:variable>

			<item id="{@id}" level="{$level}" section="{$section}" type="{$type}" root="{$root}" display="{$display}">
				<xsl:if test="$type = 'index'">
					<xsl:attribute name="level">1</xsl:attribute>
				</xsl:if>
				<title>
					<xsl:apply-templates select="xalan:nodeset($title)" mode="contents_item">
						<xsl:with-param name="mode">contents</xsl:with-param>
					</xsl:apply-templates>
				</title>
				<xsl:if test="$type != 'index'">
					<xsl:apply-templates mode="contents"/>
				</xsl:if>
			</item>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'preface']/*[local-name() = 'clause']" priority="3">
		<fo:block>
			<xsl:call-template name="setId"/>
			<xsl:call-template name="addReviewHelper"/>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*" priority="3" mode="page">
		<xsl:call-template name="elementProcessing"/>
	</xsl:template>

	<xsl:template name="elementProcessing">
		<xsl:choose>
			<xsl:when test="local-name() = 'p' and count(node()) = count(processing-instruction())"><!-- skip --></xsl:when> <!-- empty paragraph with processing-instruction -->
			<xsl:when test="@hidden = 'true'"><!-- skip --></xsl:when>
			<xsl:when test="local-name() = 'title' or local-name() = 'term'">
				<xsl:apply-templates select="."/>
			</xsl:when>
			<xsl:when test="@mainsection = 'true'">
				<!-- page break before section's title -->
				<xsl:if test="local-name() = 'p' and @type='section-title'">
					<fo:block break-after="page"/>
				</xsl:if>
				<fo:block-container>
					<xsl:attribute name="keep-with-next">always</xsl:attribute>
					<fo:block><xsl:apply-templates select="."/></fo:block>
				</fo:block-container>
			</xsl:when>
			<xsl:when test="local-name() = 'indexsect'">
				<xsl:apply-templates select="." mode="index"/>
			</xsl:when>
			<xsl:otherwise>
				<fo:block>
					<xsl:if test="not(node())">
						<xsl:attribute name="keep-with-next">always</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates select="."/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="jis:title" priority="2" name="title">

		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>

		<xsl:variable name="font-family">
			<xsl:choose>
				<xsl:when test="$vertical_layout = 'true'">Noto Sans JP</xsl:when>
				<xsl:otherwise>IPAexGothic</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="font-size">
			<xsl:choose>
				<xsl:when test="$vertical_layout = 'true'">12pt</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="@type = 'section-title'">18pt</xsl:when>
						<xsl:when test="@ancestor = 'foreword' and $level = '1'">14pt</xsl:when>
						<xsl:when test="@ancestor = 'annex' and $level = '1' and preceding-sibling::*[local-name() = 'annex'][1][@commentary = 'true']">16pt</xsl:when>
						<xsl:when test="@ancestor = 'annex' and $level = '1'">14pt</xsl:when>
						<xsl:otherwise>10pt</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="font-weight">
			<xsl:choose>
				<xsl:when test="$vertical_layout = 'true'">500</xsl:when> <!-- bold, or 500 (medium) ? -->
				<xsl:otherwise>normal</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="text-align">
			<xsl:choose>
				<xsl:when test="@ancestor = 'foreword' and $level = 1">center</xsl:when>
				<xsl:when test="@ancestor = 'annex' and $level = 1">center</xsl:when>
				<xsl:otherwise>left</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="margin-top">
			<xsl:choose>
				<xsl:when test="@ancestor = 'foreword' and $level = 1">9mm</xsl:when>
				<xsl:when test="@ancestor = 'annex' and $level = '1' and preceding-sibling::*[local-name() = 'annex'][1][@commentary = 'true']">1mm</xsl:when>
				<xsl:when test="$level = 1">6.5mm</xsl:when>
				<xsl:when test="@ancestor = 'foreword' and $level = 2">0mm</xsl:when>
				<xsl:when test="@ancestor = 'annex' and $level = 2">4.5mm</xsl:when>
				<xsl:when test="@ancestor = 'bibliography' and $level = 2">0mm</xsl:when>
				<xsl:when test="$level = 2">2mm</xsl:when>
				<xsl:when test="$level &gt;= 3">2mm</xsl:when>
				<xsl:otherwise>0mm</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="element-name">
			<xsl:choose>
				<xsl:when test="@inline-header = 'true'">fo:inline</xsl:when>
				<xsl:otherwise>fo:block</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="margin-bottom">
			<xsl:choose>
				<xsl:when test="@ancestor = 'foreword' and $level = 1">9mm</xsl:when>
				<xsl:when test="@ancestor = 'annex' and $level = '1' and preceding-sibling::*[local-name() = 'annex'][1][@commentary = 'true']">7mm</xsl:when>
				<xsl:when test="$level = 1 and following-sibling::jis:clause">8pt</xsl:when>
				<xsl:when test="$level = 1">12pt</xsl:when>
				<xsl:when test="$level = 2 and following-sibling::jis:clause">8pt</xsl:when>
				<xsl:when test="$level &gt;= 2">12pt</xsl:when>
				<xsl:when test="@type = 'section-title'">6mm</xsl:when>
				<xsl:when test="@inline-header = 'true'">0pt</xsl:when>
				<xsl:when test="@ancestor = 'annex' and $level = 1">6mm</xsl:when>
				<xsl:otherwise>0mm</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- to space-before Foreword -->
		<xsl:if test="@ancestor = 'foreword' and $level = '1'"><fo:block/></xsl:if>

		<xsl:choose>
			<xsl:when test="@inline-header = 'true' and following-sibling::*[1][self::jis:p]">
				<fo:block role="H{$level}">
					<xsl:for-each select="following-sibling::*[1][self::jis:p]">
						<xsl:call-template name="paragraph">
							<xsl:with-param name="inline-header">true</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="{$element-name}">
					<xsl:attribute name="font-family"><xsl:value-of select="$font-family"/></xsl:attribute>
					<xsl:attribute name="font-size"><xsl:value-of select="$font-size"/></xsl:attribute>
					<xsl:attribute name="font-weight"><xsl:value-of select="$font-weight"/></xsl:attribute>
					<xsl:attribute name="text-align"><xsl:value-of select="$text-align"/></xsl:attribute>
					<xsl:attribute name="space-before"><xsl:value-of select="$margin-top"/></xsl:attribute>
					<xsl:attribute name="margin-bottom"><xsl:value-of select="$margin-bottom"/></xsl:attribute>
					<xsl:attribute name="keep-with-next">always</xsl:attribute>
					<xsl:attribute name="role">H<xsl:value-of select="$level"/></xsl:attribute>

					<xsl:if test="@type = 'floating-title' or @type = 'section-title'">
						<xsl:copy-of select="@id"/>
					</xsl:if>

					<xsl:if test="$vertical_layout = 'true'">
						<!-- <xsl:attribute name="letter-spacing">1mm</xsl:attribute> -->
						<xsl:if test="not($text-align = 'center')">
							<xsl:attribute name="margin-left">-6mm</xsl:attribute>
						</xsl:if>
					</xsl:if>

					<!-- if first and last childs are `add` ace-tag, then move start ace-tag before title -->
					<xsl:if test="*[local-name() = 'tab'][1]/following-sibling::node()[last()][local-name() = 'add'][starts-with(text(), $ace_tag)]">
						<xsl:apply-templates select="*[local-name() = 'tab'][1]/following-sibling::node()[1][local-name() = 'add'][starts-with(text(), $ace_tag)]">
							<xsl:with-param name="skip">false</xsl:with-param>
						</xsl:apply-templates>
					</xsl:if>

					<xsl:variable name="section">
						<xsl:call-template name="extractSection"/>
					</xsl:variable>

					<xsl:if test="$level = 1 and $vertical_layout = 'true'">
						<fo:marker marker-class-name="section_title">
							<xsl:choose>
								<xsl:when test="@ancestor = 'annex' and *[local-name() = 'br']">
									<xsl:variable name="stitle">
										<xsl:for-each select="jis:br[1]/preceding-sibling::node()">
											<xsl:value-of select="."/>
										</xsl:for-each>
									</xsl:variable>
									<!-- <xsl:value-of select="$stitle"/> -->
									<xsl:call-template name="insertVerticalChar">
										<xsl:with-param name="str" select="$stitle"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="stitle"><xsl:call-template name="extractTitle"/></xsl:variable>
									<xsl:variable name="section_title_"><xsl:value-of select="normalize-space(concat($section, ' ', $stitle))"/></xsl:variable>
									<xsl:variable name="section_title" select="translate($section_title_, ' ', '　')"/>
									<xsl:call-template name="insertVerticalChar">
										<xsl:with-param name="str" select="$section_title"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</fo:marker>
					</xsl:if>

					<xsl:if test="normalize-space($section) != ''">

						<xsl:choose>
							<!-- DISABLED rotation due writing-mode="tb-rl" -->
							<xsl:when test="$vertical_layout_rotate_clause_numbers = 'true123'">
								<fo:inline font-family="Times New Roman" font-weight="bold">
									<xsl:call-template name="insertVerticalChar">
										<xsl:with-param name="str" select="$section"/>
									</xsl:call-template>
								</fo:inline>
								<fo:inline padding-right="4mm"> </fo:inline>
							</xsl:when>
							<xsl:otherwise>
								<fo:inline>
									<xsl:if test="not($vertical_layout = 'true')">
										<xsl:attribute name="font-family">Times New Roman</xsl:attribute>
										<xsl:attribute name="font-weight">bold</xsl:attribute>
									</xsl:if>
									<!-- <xsl:value-of select="translate($section, '．', '・')"/> -->
									<xsl:choose>
										<xsl:when test="$vertical_layout = 'true'">
											<xsl:attribute name="letter-spacing">1mm</xsl:attribute>
											<!-- Example: <title depth="2"><font_en_vertical>G</font_en_vertical>・一<tab/>一般</title> -->
											<xsl:apply-templates select="*[local-name() = 'tab'][1]/preceding-sibling::node()"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$section"/>
										</xsl:otherwise>
									</xsl:choose>
									<fo:inline padding-right="4mm"> </fo:inline>
								</fo:inline>
							</xsl:otherwise>
						</xsl:choose>

					</xsl:if>

					<xsl:choose>
						<xsl:when test="$vertical_layout = 'true'">
							<!-- <xsl:call-template name="extractTitle"/> -->
							<xsl:variable name="title_fo">
								<title_fo>
									<xsl:call-template name="extractTitle"/>
								</title_fo>
							</xsl:variable>
							<!-- title_fo='<xsl:copy-of select="xalan:nodeset($title_fo)"/>' -->
							<xsl:apply-templates select="xalan:nodeset($title_fo)" mode="letter_spacing"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="extractTitle"/>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:apply-templates select="following-sibling::*[1][local-name() = 'variant-title'][@type = 'sub']" mode="subtitle"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ============================= -->
	<!-- add letter-spacing between characters letter_spacing -->
	<!-- ============================= -->
	<xsl:template match="@*|node()" mode="letter_spacing">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="letter_spacing"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="title_fo" mode="letter_spacing">
		<xsl:apply-templates mode="letter_spacing"/>
	</xsl:template>

	<xsl:template match="title_fo/text() | fo:inline[@font-family]/text()" mode="letter_spacing">
		<xsl:call-template name="add-letter-spacing">
			<xsl:with-param name="text" select="."/>
			<xsl:with-param name="letter-spacing">1</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<!-- ============================= -->
	<!-- END: letter_spacing -->
	<!-- ============================= -->

	<xsl:template match="*[local-name() = 'term']" priority="2">
		<fo:block id="{@id}" xsl:use-attribute-sets="term-style">

				<xsl:if test="$vertical_layout = 'true'">
					<xsl:attribute name="letter-spacing">1mm</xsl:attribute>
					<xsl:attribute name="margin-left">-6mm</xsl:attribute>
				</xsl:if>

		</fo:block>
		<fo:block>
			<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'introduction']">
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'annex']" priority="2">
		<fo:block id="{@id}">
		</fo:block>
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:variable name="text_indent">3</xsl:variable>

	<xsl:template match="jis:p" name="paragraph">
		<xsl:param name="inline-header">false</xsl:param>
		<xsl:param name="split_keep-within-line"/>

		<xsl:choose>

			<xsl:when test="preceding-sibling::*[1][self::jis:title]/@inline-header = 'true' and $inline-header = 'false'"/> <!-- paragraph displayed in title template -->

			<xsl:otherwise>

				<xsl:variable name="previous-element" select="local-name(preceding-sibling::*[1])"/>
				<xsl:variable name="element-name">fo:block</xsl:variable>

				<xsl:element name="{$element-name}">
					<xsl:call-template name="setBlockAttributes">
						<xsl:with-param name="text_align_default">justify</xsl:with-param>
					</xsl:call-template>
					<xsl:attribute name="margin-bottom">10pt</xsl:attribute>

					<xsl:if test="not(parent::jis:note or parent::jis:li or ancestor::jis:table)">
						<xsl:attribute name="text-indent"><xsl:value-of select="$text_indent"/>mm</xsl:attribute>
					</xsl:if>

					<xsl:copy-of select="@id"/>

					<xsl:attribute name="line-height">1.5</xsl:attribute>
					<!-- bookmarks only in paragraph -->

					<xsl:if test="count(jis:bookmark) != 0 and count(*) = count(jis:bookmark) and normalize-space() = ''">
						<xsl:attribute name="font-size">0</xsl:attribute>
						<xsl:attribute name="margin-bottom">0pt</xsl:attribute>
						<xsl:attribute name="line-height">0</xsl:attribute>
					</xsl:if>

					<xsl:if test="ancestor::*[@key = 'true']">
						<xsl:attribute name="margin-bottom">2pt</xsl:attribute>
					</xsl:if>

					<xsl:if test="parent::jis:definition">
						<xsl:attribute name="margin-bottom">2pt</xsl:attribute>
					</xsl:if>

					<xsl:if test="parent::jis:li or following-sibling::*[1][self::jis:ol or self::jis:ul or self::jis:note or self::jis:example] or parent::jis:quote">
						<xsl:attribute name="margin-bottom">4pt</xsl:attribute>
					</xsl:if>

					<xsl:if test="parent::jis:td or parent::jis:th or parent::jis:dd">
						<xsl:attribute name="margin-bottom">0pt</xsl:attribute>
					</xsl:if>

					<xsl:if test="parent::jis:clause[@type = 'inner-cover-note'] or ancestor::jis:boilerplate">
						<xsl:attribute name="margin-bottom">0pt</xsl:attribute>
					</xsl:if>

					<xsl:apply-templates>
						<xsl:with-param name="split_keep-within-line" select="$split_keep-within-line"/>
					</xsl:apply-templates>
				</xsl:element>
				<xsl:if test="$element-name = 'fo:inline' and not(local-name(..) = 'admonition')"> <!-- and not($inline = 'true')  -->
					<fo:block margin-bottom="12pt">
						 <xsl:if test="ancestor::jis:annex or following-sibling::jis:table">
							<xsl:attribute name="margin-bottom">0</xsl:attribute>
						 </xsl:if>
						<xsl:value-of select="$linebreak"/>
					</fo:block>
				</xsl:if>

			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="jis:termnote" priority="2">
		<fo:block id="{@id}" xsl:use-attribute-sets="termnote-style">
			<fo:list-block provisional-distance-between-starts="{18 + $text_indent}mm">
				<fo:list-item>
					<fo:list-item-label start-indent="{$text_indent}mm" end-indent="label-end()">
						<fo:block xsl:use-attribute-sets="note-name-style">
							<xsl:apply-templates select="*[local-name() = 'name']"/>
						</fo:block>
					</fo:list-item-label>
					<fo:list-item-body start-indent="body-start()">
						<fo:block>
							<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
						</fo:block>
					</fo:list-item-body>
				</fo:list-item>
			</fo:list-block>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name()='li']" priority="2">
		<fo:list-item xsl:use-attribute-sets="list-item-style">
			<xsl:copy-of select="@id"/>

			<xsl:call-template name="refine_list-item-style"/>

			<fo:list-item-label end-indent="label-end()">
				<fo:block xsl:use-attribute-sets="list-item-label-style">

					<xsl:call-template name="refine_list-item-label-style"/>

					<!-- if 'p' contains all text in 'add' first and last elements in first p are 'add' -->
					<xsl:if test="*[1][count(node()[normalize-space() != '']) = 1 and *[local-name() = 'add']]">
						<xsl:call-template name="append_add-style"/>
					</xsl:if>

					<xsl:variable name="list_item_label">
						<xsl:call-template name="getListItemFormat"/>
					</xsl:variable>

					<xsl:choose>
						<xsl:when test="$vertical_layout = 'true' and contains($list_item_label, ')') and ../@type = 'arabic'">
							<fo:inline font-weight="normal">(</fo:inline>
							<xsl:value-of select="substring-before($list_item_label,')')"/>
							<fo:inline font-weight="normal">)</fo:inline>
							<xsl:value-of select="substring-after($list_item_label,')')"/>
						</xsl:when>
						<xsl:when test="$vertical_layout = 'true' and ../@type = 'alphabet'">
							<xsl:call-template name="insertVerticalChar">
								<xsl:with-param name="str" select="substring-before($list_item_label,')')"/>
							</xsl:call-template>
							<fo:inline font-weight="normal">)</fo:inline>
						</xsl:when>
						<xsl:when test="contains($list_item_label, ')')">
							<xsl:value-of select="substring-before($list_item_label,')')"/>
							<fo:inline font-weight="normal">)</fo:inline>
							<xsl:value-of select="substring-after($list_item_label,')')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$list_item_label"/>
						</xsl:otherwise>
					</xsl:choose>

				</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()" xsl:use-attribute-sets="list-item-body-style">
				<fo:block>

					<xsl:call-template name="refine_list-item-body-style"/>

					<xsl:apply-templates mode="list_jis"/>

					<!-- <xsl:apply-templates select="node()[not(local-name() = 'note')]" />
					
					<xsl:for-each select="./bsi:note">
						<xsl:call-template name="note"/>
					</xsl:for-each> -->
				</fo:block>
			</fo:list-item-body>
		</fo:list-item>
	</xsl:template>

	<xsl:template match="node()" priority="2" mode="list_jis">
		<xsl:apply-templates select="."/>
	</xsl:template>

	<!-- display footnote after last element in li, except ol or ul -->
	<xsl:template match="*[local-name()='li']/*[not(local-name() = 'ul') and not(local-name() = 'ol')][last()]" priority="3" mode="list_jis">
		<xsl:apply-templates select="."/>

		<xsl:variable name="list_id" select="ancestor::*[local-name() = 'ul' or local-name() = 'ol'][1]/@id"/>
		<!-- render footnotes after current list-item, if there aren't footnotes anymore in the list -->
		<!-- i.e. i.e. if list-item is latest with footnote -->
		<xsl:if test="ancestor::*[local-name() = 'li'][1]//jis:fn[ancestor::*[local-name() = 'ul' or local-name() = 'ol'][1][@id = $list_id]] and   not(ancestor::*[local-name() = 'li'][1]/following-sibling::*[local-name() = 'li'][.//jis:fn[ancestor::*[local-name() = 'ul' or local-name() = 'ol'][1][@id = $list_id]]])">
			<xsl:apply-templates select="ancestor::*[local-name() = 'ul' or local-name() = 'ol'][1]//jis:fn[ancestor::*[local-name() = 'ul' or local-name() = 'ol'][1][@id = $list_id]][generate-id(.)=generate-id(key('kfn',@reference)[1])]" mode="fn_after_element">
				<xsl:with-param name="ancestor">li</xsl:with-param>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="jis:fn" mode="fn_after_element">
		<xsl:param name="ancestor">li</xsl:param>

		<xsl:variable name="ancestor_tree_">
			<xsl:for-each select="ancestor::*[local-name() != 'p' and local-name() != 'bibitem' and local-name() != 'biblio-tag']">
				<item><xsl:value-of select="local-name()"/></item>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="ancestor_tree" select="xalan:nodeset($ancestor_tree_)"/>
		<!-- <debug><xsl:copy-of select="$ancestor_tree"/></debug>
		<debug><ancestor><xsl:value-of select="$ancestor"/></ancestor></debug> -->

		<xsl:if test="$ancestor_tree//item[last()][. = $ancestor]">
			<xsl:call-template name="fn_jis"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="fn_jis">
		<xsl:variable name="ref_id" select="@target"/>
		<fo:block-container margin-left="11mm" margin-bottom="4pt" id="{$ref_id}">
			<xsl:if test="position() = last()">
				<xsl:attribute name="margin-bottom">10pt</xsl:attribute>
			</xsl:if>
			<fo:block-container margin-left="0mm">
				<fo:list-block provisional-distance-between-starts="10mm">
					<fo:list-item>
						<fo:list-item-label end-indent="label-end()">
							<xsl:variable name="current_fn_number" select="translate(normalize-space(jis:fmt-fn-label), ')', '')"/>
							<fo:block xsl:use-attribute-sets="note-name-style">注 <fo:inline xsl:use-attribute-sets="fn-num-style"><xsl:value-of select="$current_fn_number"/><fo:inline font-weight="normal">)</fo:inline></fo:inline></fo:block>
						</fo:list-item-label>
						<fo:list-item-body start-indent="body-start()">
							<fo:block>
								<!-- <xsl:apply-templates /> -->
								<xsl:apply-templates select="$footnotes/*[local-name() = 'fmt-fn-body'][@id = $ref_id]"/>
							</fo:block>
						</fo:list-item-body>
					</fo:list-item>
				</fo:list-block>
			</fo:block-container>
		</fo:block-container>
	</xsl:template>

	<!-- <fmt-fn-label>注<sup> -->
	<xsl:template match="*[local-name() = 'table']//*[local-name() = 'fmt-fn-body']//*[local-name() = 'fmt-fn-label']/node()[1][self::text()]" priority="5">
		<fo:inline font-size="9pt" padding-right="1mm">
			<xsl:if test="not($vertical_layout = 'true')">
				<xsl:attribute name="font-family">IPAexGothic</xsl:attribute>
			</xsl:if>
			<!-- <xsl:call-template name="getLocalizedString">
				<xsl:with-param name="key">table_footnote</xsl:with-param>
			</xsl:call-template> -->
			<xsl:value-of select="."/>
		</fo:inline>
		<!-- <xsl:text> </xsl:text> -->
	</xsl:template>

	<!-- =========================================================================== -->
	<!-- STEP 0: Replace characters with vertical form -->
	<!-- =========================================================================== -->
	<xsl:template match="@*|node()" mode="update_xml_step0">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="update_xml_step0"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'metanorma-extension']" mode="update_xml_step0">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="text()" mode="SKIP_update_xml_step0">
		<!-- from https://github.com/metanorma/docs/blob/main/109.adoc -->
		<!-- 
		U+0028 LEFT PARENTHESIS (()
		U+FF08 FULLWIDTH LEFT PARENTHESIS (（)
		to
		U+FE35 PRESENTATION FORM FOR VERTICAL LEFT PARENTHESIS (︵)
		
		U+0029 RIGHT PARENTHESIS ())
		U+FF09 FULLWIDTH RIGHT PARENTHESIS (）)
		to
		U+FE36 PRESENTATION FORM FOR VERTICAL RIGHT PARENTHESIS (︶)
		-->
		<xsl:variable name="text1" select="translate(.,'(（)）','︵︵︶︶')"/>
		<!--
		U+007B LEFT CURLY BRACKET ({)
		U+FF5B FULLWIDTH LEFT CURLY BRACKET (｛)
		to
		U+FE37 PRESENTATION FORM FOR VERTICAL LEFT CURLY BRACKET (︷)
		
		U+007D RIGHT CURLY BRACKET (})
		U+FF5D FULLWIDTH RIGHT CURLY BRACKET (｝)
		to
		U+FE38 PRESENTATION FORM FOR VERTICAL RIGHT CURLY BRACKET (︸)
		-->
		<xsl:variable name="text2" select="translate($text1,'{｛}｝','︷︷︸︸')"/>

		<!--
		U+3014 LEFT TORTOISE SHELL BRACKET (〔)
		to
		U+FE39 PRESENTATION FORM FOR VERTICAL LEFT TORTOISE SHELL BRACKET (︹)
		
		U+3015 RIGHT TORTOISE SHELL BRACKET (〕)
		to
		U+FE3A PRESENTATION FORM FOR VERTICAL RIGHT TORTOISE SHELL BRACKET (︺)
		-->
		<xsl:variable name="text3" select="translate($text2,'〔〕','︹︺')"/>

		<!--
		U+3010 LEFT BLACK LENTICULAR BRACKET (【)
		to
		U+FE3B PRESENTATION FORM FOR VERTICAL LEFT BLACK LENTICULAR BRACKET (︻)
		
		U+3011 RIGHT BLACK LENTICULAR BRACKET (】)
		to
		U+FE3C PRESENTATION FORM FOR VERTICAL RIGHT BLACK LENTICULAR BRACKET (︼)
		-->
		<xsl:variable name="text4" select="translate($text3,'【】','︻︼')"/>

		<!--
		U+300A LEFT DOUBLE ANGLE BRACKET (《)
		to
		U+FE3D PRESENTATION FORM FOR VERTICAL LEFT DOUBLE ANGLE BRACKET (︽)
		
		U+300B RIGHT DOUBLE ANGLE BRACKET (》)
		to
		U+FE3E PRESENTATION FORM FOR VERTICAL RIGHT DOUBLE ANGLE BRACKET (︾)
		-->
		<xsl:variable name="text5" select="translate($text4,'《》','︽︾')"/>

		<!--
		U+FF62 HALFWIDTH LEFT CORNER BRACKET (｢)
		U+300C LEFT CORNER BRACKET (「)
		to
		U+FE41 PRESENTATION FORM FOR VERTICAL LEFT CORNER BRACKET (﹁)
		
		U+FF63 HALFWIDTH RIGHT CORNER BRACKET (｣)
		U+300D RIGHT CORNER BRACKET (」)
		to
		U+FE42 PRESENTATION FORM FOR VERTICAL RIGHT CORNER BRACKET (﹂)
		-->
		<xsl:variable name="text6" select="translate($text5,'｢「｣」','﹁﹁﹂﹂')"/>

		<!--
		U+300E LEFT WHITE CORNER BRACKET (『)
		to
		U+FE43 PRESENTATION FORM FOR VERTICAL LEFT WHITE CORNER BRACKET (﹃)
		
		U+300F RIGHT WHITE CORNER BRACKET (』)
		to
		U+FE44 PRESENTATION FORM FOR VERTICAL RIGHT WHITE CORNER BRACKET (﹄)
		-->
		<xsl:variable name="text7" select="translate($text6,'『』','﹃﹄')"/>

		<!--
		U+005B LEFT SQUARE BRACKET ([)
		U+FF3B FULLWIDTH LEFT SQUARE BRACKET (［)
		to
		U+FE47 PRESENTATION FORM FOR VERTICAL LEFT SQUARE BRACKET (﹇)
		
		U+005D RIGHT SQUARE BRACKET (])
		U+FF3D FULLWIDTH RIGHT SQUARE BRACKET (］)
		to
		U+FE48 PRESENTATION FORM FOR VERTICAL RIGHT SQUARE BRACKET (﹈)
		-->
		<xsl:variable name="text8" select="translate($text7,'[［]］','﹇﹇﹈﹈')"/>

		<!--
		U+3008 LEFT ANGLE BRACKET (〈)
		to
		U+FE3F PRESENTATION FORM FOR VERTICAL LEFT ANGLE BRACKET (︿)
		
		U+3009 RIGHT ANGLE BRACKET (〉)
		to
		U+FE40 PRESENTATION FORM FOR VERTICAL RIGHT ANGLE BRACKET (﹀)
		-->
		<xsl:variable name="text9" select="translate($text8,'〈〉','︿﹀')"/>

		<!--
		U+3016 LEFT WHITE LENTICULAR BRACKET (〖)
		to
		U+FE17 PRESENTATION FORM FOR VERTICAL LEFT WHITE LENTICULAR BRACKET (︗)
		
		U+3017 RIGHT WHITE LENTICULAR BRACKET (〗)
		to
		U+FE18 PRESENTATION FORM FOR VERTICAL RIGHT WHITE LENTICULAR BRACKET (︘)
		-->
		<xsl:variable name="text10" select="translate($text9,'〖〗','︗︘')"/>

		<xsl:value-of select="$text10"/>
	</xsl:template>

	<!-- enclose surrogate pair characters into the tag 'spair' -->
	<xsl:variable name="element_name_spair">spair</xsl:variable>
	<xsl:variable name="tag_spair_open">###<xsl:value-of select="$element_name_spair"/>###</xsl:variable>
	<xsl:variable name="tag_spair_close">###/<xsl:value-of select="$element_name_spair"/>###</xsl:variable>

	<!-- replace horizontal to vertical oriented character -->
	<xsl:template match="text()" mode="update_xml_step0" name="replace_horizontal_to_vertical_form">
		<xsl:param name="text" select="."/>
		<xsl:variable name="text_replaced">
			<xsl:choose>
				<xsl:when test="$vertical_layout = 'true' and $isGenerateTableIF = 'false'">
					<!-- from https://github.com/metanorma/docs/blob/main/109.adoc -->
					<!-- 
					U+3001 IDEOGRAPHIC COMMA (、)
					to
					U+FE11 PRESENTATION FORM FOR VERTICAL IDEOGRAPHIC COMMA (︑) 
					
					U+FE50 SMALL COMMA (﹐)
					to
					U+FE10 PRESENTATION FORM FOR VERTICAL COMMA (︐)
					
					U+FE51 SMALL IDEOGRAPHIC COMMA (﹑)
					to
					U+FE11 PRESENTATION FORM FOR VERTICAL IDEOGRAPHIC COMMA (︑)
					
					U+FF0C FULLWIDTH COMMA (，)
					to
					U+FE10 PRESENTATION FORM FOR VERTICAL COMMA (︐)
					-->
					<xsl:variable name="text1" select="translate($text,'、﹐﹑，','︑︐︑︐')"/>

					<!-- 
					U+FF1A FULLWIDTH COLON (：)
					to
					U+FE13 PRESENTATION FORM FOR VERTICAL COLON (︓)
					
					U+FF1B FULLWIDTH SEMICOLON (；)
					to
					U+FE14 PRESENTATION FORM FOR VERTICAL SEMICOLON (︔)
					-->
					<xsl:variable name="text2" select="translate($text1,'：；','︓︔')"/>

					<!-- 
					U+FF01 FULLWIDTH EXCLAMATION MARK (！)
					to
					U+FE15 PRESENTATION FORM FOR VERTICAL EXCLAMATION MARK (︕)
					
					U+FF1F FULLWIDTH QUESTION MARK (？)
					to
					U+FE16 PRESENTATION FORM FOR VERTICAL QUESTION MARK (︖)
					-->
					<xsl:variable name="text3" select="translate($text2,'！？','︕︖')"/>
					<xsl:value-of select="$text3"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$text"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="text_spair_" select="java:replaceAll(java:java.lang.String.new($text_replaced), $regex_surrogate_pairs, concat($tag_spair_open,'$1',$tag_spair_close))"/>
		<xsl:variable name="text_spair">
			<xsl:element name="text" namespace="{$namespace_full}">
				<xsl:call-template name="replace_text_tags">
					<xsl:with-param name="tag_open" select="$tag_spair_open"/>
					<xsl:with-param name="tag_close" select="$tag_spair_close"/>
					<xsl:with-param name="text" select="$text_spair_"/>
				</xsl:call-template>
			</xsl:element>
		</xsl:variable>
		<xsl:copy-of select="xalan:nodeset($text_spair)/*[local-name() = 'text']/node()"/>

	</xsl:template>

	<!-- =========================================================================== -->
	<!-- END STEP 0: Replace characters with vertical form -->
	<!-- =========================================================================== -->

	<xsl:template match="*[local-name() = 'bibdata'][not(.//*[local-name() = 'passthrough'])] |        *[local-name() = 'localized-strings']" mode="update_xml_step1" priority="2">
		<xsl:choose>
			<xsl:when test="$vertical_layout = 'true'">
				<xsl:copy>
					<xsl:apply-templates select="@* | node()" mode="update_xml_step1"/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[local-name() = 'bibdata']/*[local-name() = 'title']" mode="update_xml_step1" priority="2">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'span'][@class = 'surname' or @class = 'givenname' or @class = 'JIS' or @class = 'EffectiveYear' or @class = 'CommentaryEffectiveYear']" mode="update_xml_step1" priority="2">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" mode="update_xml_step1"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="jis:clause[@type = 'contributors']//jis:table//jis:span[@class = 'surname']/text()[string-length() &lt; 3]" priority="2">
		<xsl:choose>
			<xsl:when test="string-length() = 1">
				<xsl:value-of select="concat(.,'　　')"/>
			</xsl:when>
			<xsl:when test="string-length() = 2">
				<xsl:value-of select="concat(substring(.,1,1), '　', substring(., 2))"/>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="../following-sibling::node()[1][self::jis:span and @class = 'surname']"> <!-- if no space between surname and given name -->
			<xsl:text>　</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="jis:clause[@type = 'contributors']//jis:table//jis:span[@class = 'givenname']/text()[string-length() &lt; 3]" priority="2">
		<xsl:choose>
			<xsl:when test="string-length() = 1">
				<xsl:value-of select="concat('　　', .)"/>
			</xsl:when>
			<xsl:when test="string-length() = 2">
				<xsl:value-of select="concat(substring(.,1,1), '　', substring(., 2))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- space between surname and givenname replace by 'ideographic space' -->
	<!-- and following-sibling::node()[1][self::jis:span and @class = 'givenname'] -->
	<xsl:template match="jis:clause[@type = 'contributors']//jis:table//node()[preceding-sibling::node()[1][self::jis:span and @class = 'surname']][. = ' ']" priority="2">
		<xsl:text>　</xsl:text>
	</xsl:template>

	<xsl:template name="makePagedXML">
		<xsl:param name="structured_xml"/>
		<xsl:choose>
			<xsl:when test="not(xalan:nodeset($structured_xml)/*[local-name()='pagebreak'])">
				<xsl:element name="page" namespace="{$namespace_full}">
					<xsl:copy-of select="xalan:nodeset($structured_xml)"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="xalan:nodeset($structured_xml)/*[local-name()='pagebreak']">

					<xsl:variable name="pagebreak_id" select="generate-id()"/>

					<!-- copy elements before pagebreak -->
					<xsl:element name="page" namespace="{$namespace_full}">
						<xsl:if test="not(preceding-sibling::jis:pagebreak)">
							<xsl:copy-of select="../@*"/>
						</xsl:if>
						<!-- copy previous pagebreak orientation -->
						<xsl:copy-of select="preceding-sibling::jis:pagebreak[1]/@orientation"/>

						<xsl:copy-of select="preceding-sibling::node()[following-sibling::jis:pagebreak[1][generate-id(.) = $pagebreak_id]][not(local-name() = 'pagebreak')]"/>
					</xsl:element>

					<!-- copy elements after last page break -->
					<xsl:if test="position() = last() and following-sibling::node()">
						<xsl:element name="page" namespace="{$namespace_full}">
							<xsl:copy-of select="@orientation"/>
							<xsl:copy-of select="following-sibling::node()"/>
						</xsl:element>
					</xsl:if>

				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ========================= -->
	<!-- Allocate non-Japanese text -->
	<!-- ========================= -->

	<xsl:template match="*[local-name() = 'span'][@class = 'horizontal']" mode="update_xml_step1" priority="3">
		<xsl:element name="{$element_name_font_en_horizontal}" namespace="{$namespace_full}">
			<xsl:apply-templates mode="update_xml_step1"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="*[local-name() = 'span'][@class = 'horizontal']//text()" mode="update_xml_step1" priority="3">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'span'][@class = 'norotate']" mode="update_xml_step1" priority="3">
		<xsl:copy-of select="."/>
	</xsl:template>

	<!-- https://github.com/metanorma/laozi/issues/8 -->
	<xsl:variable name="surrogate_pairs">\ud800\udc00-\udbff\udfff\ud800-\udfff</xsl:variable>
	<xsl:variable name="regex_surrogate_pairs">([<xsl:value-of select="$surrogate_pairs"/>])</xsl:variable>

	<!-- if vertical_layout = 'true', then font_en and font_en_bold are using for text rotation -->
	<xsl:variable name="regex_en_base">\u00A0\u2002-\u200B\u3000-\u9FFF\uF900-\uFFFF<xsl:value-of select="$surrogate_pairs"/></xsl:variable>
	<xsl:variable name="regex_en_">
		<xsl:choose>
			<!-- ( ) [ ] _ { } U+FF08 FULLWIDTH LEFT PARENTHESIS U+FF09 FULLWIDTH RIGHT PARENTHESIS-->
			<!-- <xsl:when test="$vertical_layout = 'true'">((<xsl:value-of select="$regex_ja_spec"/>)|([^\u0028\u0029\u005B\u005D\u005F\u007B\u007D<xsl:value-of select="$regex_en_base"/>]){1,})</xsl:when> -->
			<!-- regex for find characters to rotation -->
			<xsl:when test="$isGenerateTableIF = 'true' and $vertical_layout = 'true'">(([^\u005F<xsl:value-of select="$regex_ja_spec"/><xsl:value-of select="$regex_en_base"/>]){1,})</xsl:when> <!-- \u0028\u0029\u005B\u005D \u007B\u007D -->
			<xsl:when test="$vertical_layout = 'true'">((<xsl:value-of select="$regex_ja_spec"/>)|([^\u005F<xsl:value-of select="$regex_en_base"/>]){1,})</xsl:when> <!-- \u0028\u0029\u005B\u005D \u007B\u007D -->
			<xsl:otherwise>([^<xsl:value-of select="$regex_en_base"/>]{1,})</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="regex_en" select="normalize-space($regex_en_)"/>

	<xsl:variable name="regex_horizontal">(\d{1,3})</xsl:variable>

	<xsl:variable name="element_name_font_en">font_en</xsl:variable>
	<xsl:variable name="tag_font_en_open">###<xsl:value-of select="$element_name_font_en"/>###</xsl:variable>
	<xsl:variable name="tag_font_en_close">###/<xsl:value-of select="$element_name_font_en"/>###</xsl:variable>
	<xsl:variable name="element_name_font_en_bold">font_en_bold</xsl:variable>
	<xsl:variable name="tag_font_en_bold_open">###<xsl:value-of select="$element_name_font_en_bold"/>###</xsl:variable>
	<xsl:variable name="tag_font_en_bold_close">###/<xsl:value-of select="$element_name_font_en_bold"/>###</xsl:variable>
	<xsl:variable name="element_name_font_en_vertical">font_en_vertical</xsl:variable>
	<xsl:variable name="tag_font_en_vertical_open">###<xsl:value-of select="$element_name_font_en_vertical"/>###</xsl:variable>
	<xsl:variable name="tag_font_en_vertical_close">###/<xsl:value-of select="$element_name_font_en_vertical"/>###</xsl:variable>
	<xsl:variable name="element_name_font_en_horizontal">font_en_horizontal</xsl:variable>
	<xsl:variable name="tag_font_en_horizontal_open">###<xsl:value-of select="$element_name_font_en_horizontal"/>###</xsl:variable>
	<xsl:variable name="tag_font_en_horizontal_close">###/<xsl:value-of select="$element_name_font_en_horizontal"/>###</xsl:variable>

	<xsl:template match="text()[not(ancestor::*[local-name() = 'bibdata'] and ancestor::*[local-name() = 'title']) and not(ancestor::jis:p[@class = 'zzSTDTitle2'])][normalize-space() != '']" mode="update_xml_step1">
		<xsl:choose>
			<xsl:when test="$vertical_layout = 'true'">
				<xsl:call-template name="enclose_text_in_vertical_tag"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="jis:p//text()[not(ancestor::jis:strong) and not(ancestor::jis:p[@class = 'zzSTDTitle2'])][normalize-space() != ''] |       jis:dt/text()[normalize-space() != ''] |        jis:biblio-tag/text()[normalize-space() != ''] |       item/title/text()" mode="update_xml_step1">
		<xsl:choose>
			<xsl:when test="$vertical_layout = 'true'">
				<xsl:call-template name="enclose_text_in_vertical_tag"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="enclose_text_in_font_en_tag"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- <biblio-tag>[15]<tab/>JIS...</biblio-tag>
		to
		<biblio-tag><font_en_vertical>[</font_en_vertical><font_en_horizontal>15</font_en_horizontal><font_en_vertical>]</font_en_vertical><tab/>JIS...
	-->
	<xsl:template match="jis:references[@normative = 'false']//jis:biblio-tag/text()[not(preceding-sibling::node())][normalize-space() != '']" mode="update_xml_step1" priority="2">
		<xsl:choose>
			<xsl:when test="$vertical_layout = 'true'">
				<xsl:variable name="biblio_tag_text_nodes">
					<xsl:call-template name="enclose_text_in_vertical_tag">
						<xsl:with-param name="regex" select="concat('((', $regex_ja_spec, '){1,})')"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:for-each select="xalan:nodeset($biblio_tag_text_nodes)/node()">
					<xsl:choose>
						<xsl:when test="self::text()">
							<xsl:call-template name="enclose_text_in_horizontal_tag">
								<xsl:with-param name="regex" select="$regex_horizontal"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="enclose_text_in_font_en_tag"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="enclose_text_in_vertical_tag">
		<xsl:param name="text" select="."/>
		<xsl:param name="regex" select="$regex_en"/>

		<xsl:variable name="regex_two_digits">(^|[^\d])(\d{2,3})($|[^\d])</xsl:variable>

		<xsl:variable name="text_width_two_or_three_digits_" select="java:replaceAll(java:java.lang.String.new($text), $regex_two_digits, concat('$1',$tag_font_en_horizontal_open,'$2',$tag_font_en_horizontal_close,'$3'))"/>
		<xsl:variable name="text_width_two_or_three_digits">
			<xsl:element name="text" namespace="{$namespace_full}">
				<xsl:call-template name="replace_text_tags">
					<xsl:with-param name="tag_open" select="$tag_font_en_horizontal_open"/>
					<xsl:with-param name="tag_close" select="$tag_font_en_horizontal_close"/>
					<xsl:with-param name="text" select="$text_width_two_or_three_digits_"/>
				</xsl:call-template>
			</xsl:element>
		</xsl:variable>

		<!-- <xsl:copy-of select="$text_width_two_or_three_digits"/> -->

		<xsl:for-each select="xalan:nodeset($text_width_two_or_three_digits)/*[local-name() = 'text']/node()">

			<xsl:choose>
				<xsl:when test="self::text()">
					<xsl:variable name="text_vertical_" select="java:replaceAll(java:java.lang.String.new(.), $regex, concat($tag_font_en_vertical_open,'$1',$tag_font_en_vertical_close))"/>
					<xsl:variable name="text_vertical">
						<xsl:element name="text" namespace="{$namespace_full}">
							<xsl:call-template name="replace_text_tags">
								<xsl:with-param name="tag_open" select="$tag_font_en_vertical_open"/>
								<xsl:with-param name="tag_close" select="$tag_font_en_vertical_close"/>
								<xsl:with-param name="text" select="$text_vertical_"/>
							</xsl:call-template>
						</xsl:element>
					</xsl:variable>
					<xsl:copy-of select="xalan:nodeset($text_vertical)/*[local-name() = 'text']/node()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="enclose_text_in_horizontal_tag">
		<xsl:param name="text" select="."/>
		<xsl:param name="regex" select="$regex_horizontal"/>
		<xsl:variable name="text_horizontal_" select="java:replaceAll(java:java.lang.String.new($text), $regex, concat($tag_font_en_horizontal_open,'$1',$tag_font_en_horizontal_close))"/>
		<xsl:variable name="text_horizontal">
			<xsl:element name="text" namespace="{$namespace_full}">
				<xsl:call-template name="replace_text_tags">
					<xsl:with-param name="tag_open" select="$tag_font_en_horizontal_open"/>
					<xsl:with-param name="tag_close" select="$tag_font_en_horizontal_close"/>
					<xsl:with-param name="text" select="$text_horizontal_"/>
				</xsl:call-template>
			</xsl:element>
		</xsl:variable>
		<xsl:copy-of select="xalan:nodeset($text_horizontal)/*[local-name() = 'text']/node()"/>
	</xsl:template>

	<xsl:template name="enclose_text_in_font_en_tag">
		<xsl:param name="text" select="."/>
		<xsl:param name="regex" select="$regex_en"/>
		<xsl:variable name="text_en_" select="java:replaceAll(java:java.lang.String.new($text), $regex, concat($tag_font_en_open,'$1',$tag_font_en_close))"/>
		<xsl:variable name="text_en">
			<xsl:element name="text" namespace="{$namespace_full}">
				<xsl:call-template name="replace_text_tags">
					<xsl:with-param name="tag_open" select="$tag_font_en_open"/>
					<xsl:with-param name="tag_close" select="$tag_font_en_close"/>
					<xsl:with-param name="text" select="$text_en_"/>
				</xsl:call-template>
			</xsl:element>
		</xsl:variable>
		<xsl:copy-of select="xalan:nodeset($text_en)/*[local-name() = 'text']/node()"/>
	</xsl:template>

	<xsl:template name="enclose_text_in_font_en_bold_tag">
		<xsl:param name="text" select="."/>
		<xsl:param name="regex" select="$regex_en"/>
		<xsl:variable name="text_en_" select="java:replaceAll(java:java.lang.String.new($text), $regex, concat($tag_font_en_bold_open,'$1',$tag_font_en_bold_close))"/>
		<xsl:variable name="text_en">
			<xsl:element name="text" namespace="{$namespace_full}">
				<xsl:call-template name="replace_text_tags">
					<xsl:with-param name="tag_open" select="$tag_font_en_bold_open"/>
					<xsl:with-param name="tag_close" select="$tag_font_en_bold_close"/>
					<xsl:with-param name="text" select="$text_en_"/>
				</xsl:call-template>
			</xsl:element>
		</xsl:variable>
		<xsl:copy-of select="xalan:nodeset($text_en)/*[local-name() = 'text']/node()"/>
	</xsl:template>

	<!-- jis:term/jis:preferred2//text() | -->

	<!-- <name>注記  1</name> to <name>注記<font_en>  1</font_en></name> -->
	<xsl:template match="jis:title/text() | jis:fmt-title/text() |        jis:term/jis:name/text() | jis:term/jis:fmt-name/text() |        jis:note/jis:name/text() | jis:note/jis:fmt-name/text() |        jis:termnote/jis:name/text() |jis:termnote/jis:fmt-name/text() |       jis:table/jis:name/text() |jis:table/jis:fmt-name/text() |       jis:figure/jis:name/text() |jis:figure/jis:fmt-name/text() |       jis:termexample/jis:name/text() |jis:termexample/jis:fmtname/text() |       jis:xref//text() | jis:fmt-xref//text() |       jis:origin/text() | jis:fmt-origin/text()" mode="update_xml_step1">
		<xsl:choose>
			<xsl:when test="$vertical_layout = 'true'">
				<xsl:choose>
					<xsl:when test="ancestor::jis:xref and       (starts-with(., 'http:') or starts-with(., 'https') or starts-with(., 'www') or starts-with(., 'mailto') or starts-with(., 'ftp'))">
						<xsl:value-of select="."/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="enclose_text_in_vertical_tag"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="enclose_text_in_font_en_bold_tag"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- for $contents -->
	<xsl:template match="title/text()">
		<xsl:variable name="regex_en_contents">([^\u00A0\u2002-\u200B\u3000-\u9FFF\uF900-\uFFFF\(\)]{1,})</xsl:variable>
		<xsl:choose>
			<xsl:when test="$vertical_layout = 'true'">
				<xsl:call-template name="enclose_text_in_vertical_tag">
					<xsl:with-param name="regex" select="$regex_en_contents"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="text_markup">
					<xsl:call-template name="enclose_text_in_font_en_bold_tag">
						<xsl:with-param name="regex" select="$regex_en_contents"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:for-each select="xalan:nodeset($text_markup)/node()">
					<xsl:choose>
						<xsl:when test="self::text()"><xsl:value-of select="."/></xsl:when>
						<xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- move example title to the first paragraph -->
	<!-- Example:
		<example id="_7569d639-c245-acb6-2141-3b746374a9e1" autonum="1">
		<name id="_8eac959b-b129-4892-b8bb-fcca2914bd39">（可能性の例）</name>
		<fmt-name>
			<span class="fmt-caption-label">
				<span class="fmt-element-name">例</span>
				<semx element="autonum" source="_7569d639-c245-acb6-2141-3b746374a9e1">1</semx>
			</span>
			<span class="fmt-caption-delim"> — </span>
			<semx element="name" source="_8eac959b-b129-4892-b8bb-fcca2914bd39">（可能性の例）</semx>
		</fmt-name>
	-->
	<!-- <xsl:template match="jis:example[contains(normalize-space(jis:fmt-name), ' — ')]" mode="update_xml_step1"> -->
	<xsl:template match="jis:example[jis:fmt-name[contains(jis:span/text(), ' — ')]]" mode="update_xml_step1">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:element name="p" namespace="{$namespace_full}">
				<!-- <xsl:variable name="example_name">
					<xsl:apply-templates select="jis:fmt-name" mode="update_xml_step1"/>
				</xsl:variable>
				<xsl:value-of select="substring-after(xalan:nodeset($example_name)/jis:name/text()[1], ' — ')"/>
				<xsl:apply-templates select="xalan:nodeset($example_name)/jis:name/text()[1]/following-sibling::node()" mode="update_xml_step1"/> -->
				<xsl:apply-templates select="jis:fmt-name/jis:span[contains(., ' — ')][1]/following-sibling::node()" mode="update_xml_step1"/>
			</xsl:element>
			<xsl:apply-templates mode="update_xml_step1"/>
		</xsl:copy>
	</xsl:template>
	<!-- <xsl:template match="jis:example/jis:fmt-name[contains(normalize-space(), ' — ')]" mode="update_xml_step1"> -->
	<xsl:template match="jis:example/jis:fmt-name[contains(jis:span/text(), ' — ')]" mode="update_xml_step1" priority="2">
		<xsl:element name="name" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<!-- <xsl:variable name="example_name">
				<xsl:apply-templates select="." mode="update_xml_step1"/>
			</xsl:variable>
			<xsl:apply-templates select="xalan:nodeset($example_name)//text()[1]" mode="update_xml_step1"/>
			-->
			<xsl:apply-templates select="*[1]" mode="update_xml_step1"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="jis:example/jis:fmt-name//text()" mode="update_xml_step1">
		<xsl:variable name="example_name" select="."/>
			<!-- <xsl:choose>
				<xsl:when test="contains(., ' — ')"><xsl:value-of select="substring-before(., ' — ')"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable> -->
		<xsl:choose>
			<xsl:when test="$vertical_layout = 'true'">
				<xsl:call-template name="enclose_text_in_vertical_tag">
					<xsl:with-param name="text" select="$example_name"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="enclose_text_in_font_en_bold_tag">
					<xsl:with-param name="text" select="$example_name"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="jis:fmt-eref//text()" mode="update_xml_step1">
		<xsl:choose>
			<xsl:when test="$vertical_layout = 'true'">
				<xsl:call-template name="enclose_text_in_vertical_tag"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- Example: JIS Z 8301:2011 to <font_en_bold>JIS Z 8301</font_en_bold><font_en>:2011</font_en> -->
				<xsl:variable name="parts">
					<xsl:choose>
						<xsl:when test="contains(., ':')">
							<xsl:element name="{$element_name_font_en_bold}" namespace="{$namespace_full}"><xsl:value-of select="substring-before(., ':')"/></xsl:element>
							<xsl:element name="{$element_name_font_en}" namespace="{$namespace_full}">:<xsl:value-of select="substring-after(., ':')"/></xsl:element>
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="{$element_name_font_en_bold}" namespace="{$namespace_full}"><xsl:value-of select="."/></xsl:element>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:for-each select="xalan:nodeset($parts)/*">
					<xsl:variable name="tag_open">###<xsl:value-of select="local-name()"/>###</xsl:variable>
					<xsl:variable name="tag_close">###/<xsl:value-of select="local-name()"/>###</xsl:variable>
					<xsl:variable name="text_en_" select="java:replaceAll(java:java.lang.String.new(.), $regex_en, concat($tag_open,'$1',$tag_close))"/>
					<xsl:variable name="text_en">
						<xsl:element name="text" namespace="{$namespace_full}">
							<xsl:call-template name="replace_text_tags">
								<xsl:with-param name="tag_open" select="$tag_open"/>
								<xsl:with-param name="tag_close" select="$tag_close"/>
								<xsl:with-param name="text" select="$text_en_"/>
							</xsl:call-template>
						</xsl:element>
					</xsl:variable>
					<xsl:copy-of select="xalan:nodeset($text_en)/*[local-name() = 'text']/node()"/>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="jis:strong" priority="2" mode="update_xml_step1">
		<xsl:apply-templates mode="update_xml_step1"/>
	</xsl:template>
	<xsl:template match="jis:strong/text()" priority="2" mode="update_xml_step1">
		<xsl:choose>
			<xsl:when test="$vertical_layout = 'true'">
				<xsl:call-template name="enclose_text_in_vertical_tag"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="enclose_text_in_font_en_bold_tag"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- add @provisional-distance-between-starts for 'ol' -->
	<xsl:template match="jis:ol" priority="2" mode="update_xml_step1">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:if test="$vertical_layout = 'true'">
				<xsl:variable name="labels">
					<xsl:for-each select="*[local-name() = 'li']"><label_len><xsl:value-of select="string-length(@label)"/></label_len></xsl:for-each>
				</xsl:variable>
				<xsl:variable name="max_len_label_">
					<xsl:for-each select="xalan:nodeset($labels)//*">
						<xsl:sort select="." data-type="number" order="descending"/>
						<xsl:if test="position() = 1"><xsl:value-of select="."/></xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="max_len_label" select="number($max_len_label_)"/>

				<xsl:choose>
					<xsl:when test="@type = 'arabic'">
						<xsl:attribute name="provisional-distance-between-starts">
							<xsl:choose>
								<xsl:when test="$max_len_label = 1">8.5mm</xsl:when>
								<xsl:when test="$max_len_label = 2">12mm</xsl:when>
								<xsl:when test="$max_len_label = 3">20mm</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="3 + number($max_len_label) * 4"/>mm
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="ol_styles">
							<styles xsl:use-attribute-sets="list-style"/>
						</xsl:variable>
						<xsl:for-each select="xalan:nodeset($ol_styles)//styles">
							<xsl:copy-of select="@*"/>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:apply-templates mode="update_xml_step1"/>
		</xsl:copy>
	</xsl:template>

	<!-- bold English text in non-vertical layout -->
	<xsl:template match="*[local-name() = 'font_en_bold'][normalize-space() != '']">
		<xsl:if test="ancestor::*[local-name() = 'td' or local-name() = 'th']">
			<xsl:choose>
				<xsl:when test="$isGenerateTableIF = 'false'"><fo:inline font-size="0.1pt"><xsl:text> </xsl:text></fo:inline></xsl:when>
				<xsl:otherwise><fo:inline><xsl:value-of select="$zero_width_space"/></fo:inline></xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<fo:inline>
			<xsl:attribute name="font-family">Times New Roman</xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:if test="ancestor::*[local-name() = 'preferred']">
				<xsl:attribute name="font-weight">normal</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:inline>
		<xsl:if test="ancestor::*[local-name() = 'td' or local-name() = 'th']">
			<xsl:choose>
				<xsl:when test="$isGenerateTableIF = 'false'"><fo:inline font-size="0.1pt"><xsl:text> </xsl:text></fo:inline></xsl:when>
				<xsl:otherwise><fo:inline><xsl:value-of select="$zero_width_space"/></fo:inline></xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- English text in non-vertical layout -->
	<xsl:template match="*[local-name() = 'font_en'][normalize-space() != '']">
		<xsl:if test="ancestor::*[local-name() = 'td' or local-name() = 'th']">
			<xsl:choose>
				<xsl:when test="$isGenerateTableIF = 'false'"><fo:inline font-size="0.1pt"><xsl:text> </xsl:text></fo:inline></xsl:when>
				<xsl:otherwise><fo:inline><xsl:value-of select="$zero_width_space"/></fo:inline></xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<fo:inline>
			<xsl:if test="not(ancestor::jis:p[@class = 'zzSTDTitle2']) and not(ancestor::jis:span[@class = 'JIS'])">
				<xsl:attribute name="font-family">Times New Roman</xsl:attribute>
			</xsl:if>
			<xsl:if test="ancestor::*[local-name() = 'preferred']">
				<xsl:attribute name="font-weight">normal</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:inline>
		<xsl:if test="ancestor::*[local-name() = 'td' or local-name() = 'th']">
			<xsl:choose>
				<xsl:when test="$isGenerateTableIF = 'false'"><fo:inline font-size="0.1pt"><xsl:text> </xsl:text></fo:inline></xsl:when>
				<xsl:otherwise><fo:inline><xsl:value-of select="$zero_width_space"/></fo:inline></xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- English text in vertical layout -->
	<xsl:template match="*[local-name() = 'font_en_vertical'][normalize-space() != '']">
		<xsl:if test="ancestor::*[local-name() = 'td' or local-name() = 'th']"><xsl:value-of select="$zero_width_space"/></xsl:if>
		<fo:inline>
			<xsl:if test="not(ancestor::jis:p[@class = 'zzSTDTitle2']) and not(ancestor::jis:span[@class = 'JIS'])">
			</xsl:if>
			<xsl:if test="ancestor::*[local-name() = 'preferred']">
				<xsl:attribute name="font-weight">normal</xsl:attribute>
			</xsl:if>
			<xsl:for-each select="node()">
				<xsl:choose>
					<xsl:when test="self::text()">
						<!-- convert to vertical layout -->
						<xsl:variable name="text">
							<xsl:choose>
								<xsl:when test="(ancestor::*[local-name(../..) = 'note'] or ancestor::*[local-name(../..) = 'example'] ) and ancestor::*[local-name(..) = 'name']">
									<xsl:value-of select="concat(' ', normalize-space(.))"/>
								</xsl:when>
								<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:call-template name="insertVerticalChar">
							<xsl:with-param name="str" select="$text"/>
							<xsl:with-param name="reference-orientation">90</xsl:with-param>
							<xsl:with-param name="add_zero_width_space">true</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</fo:inline>
		<xsl:if test="ancestor::*[local-name() = 'td' or local-name() = 'th']"><xsl:value-of select="$zero_width_space"/></xsl:if>
	</xsl:template>

	<!-- English text in vertical layout, in horizontal mode -->
	<xsl:template match="*[local-name() = 'font_en_horizontal'][normalize-space() != '']">
		<xsl:if test="ancestor::*[local-name() = 'td' or local-name() = 'th']"><xsl:value-of select="$zero_width_space"/></xsl:if>
		<fo:inline>
			<xsl:for-each select="node()">
				<xsl:choose>
					<xsl:when test="self::text()">
						<xsl:call-template name="insertHorizontalChars">
							<xsl:with-param name="str" select="."/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</fo:inline>
		<xsl:if test="ancestor::*[local-name() = 'td' or local-name() = 'th']"><xsl:value-of select="$zero_width_space"/></xsl:if>
	</xsl:template>

	<!-- ========================= -->
	<!-- END: Allocate non-Japanese text -->
	<!-- ========================= -->

	<xsl:template match="*[local-name() = 'spair'][normalize-space() != '']">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template>

	<!-- patch for correct list-item-label rendering: enclose each char in inline-container -->
	<xsl:template match="*[local-name() = 'note' or local-name() = 'example']/*[local-name() = 'name']/text()" priority="3">
		<xsl:choose>
			<xsl:when test="not($vertical_layout = 'true')">
				<xsl:value-of select="."/>
			</xsl:when>
			<xsl:otherwise> <!-- $vertical_layout = 'true' -->
				<xsl:call-template name="insertVerticalChar">
					<xsl:with-param name="str" select="."/>
					<!-- <xsl:with-param name="writing-mode"/>
					<xsl:with-param name="reference-orientation"/> -->
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[local-name() = 'figure']/*[local-name() = 'name'] |         *[local-name() = 'image']/*[local-name() = 'name']" priority="3">
		<xsl:param name="process">false</xsl:param>

		<xsl:if test="normalize-space() != '' and (not($vertical_layout = 'true') or $process = 'true')">
			<fo:block xsl:use-attribute-sets="figure-name-style">

				<xsl:call-template name="refine_figure-name-style"/>

				<xsl:apply-templates/>
			</fo:block>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'figure']/*[local-name() = 'p'][@class = 'dl']" priority="3">
		<xsl:param name="process">false</xsl:param>
		<xsl:if test="normalize-space() != '' and (not($vertical_layout = 'true') or $process = 'true')">
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'span'][@class = 'norotate']//text()" name="norotate" priority="3">
		<xsl:param name="str" select="."/>
		<!-- <xsl:choose>
			<xsl:when test="$vertical_layout = 'true'">
				<xsl:if test="string-length($str) &gt; 0">
					<xsl:variable name="char" select="substring($str,1,1)"/>
					<fo:inline-container text-align="center"
								 alignment-baseline="central" width="1em" margin="0" padding="0"
								 text-indent="0mm" last-line-end-indent="0mm" start-indent="0mm" end-indent="0mm" reference-orientation="0">
						<fo:block-container width="1em">
							<fo:block line-height="1em">
								<xsl:value-of select="$char"/>
							</fo:block>
						</fo:block-container>
					</fo:inline-container>
					<xsl:call-template name="norotate">
						<xsl:with-param name="str" select="substring($str, 2)"/>
					</xsl:call-template>
			 </xsl:if>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
		</xsl:choose> -->
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'span'][@class = 'halffontsize']" priority="3">
		<fo:inline font-size="50%" baseline-shift="15%"><xsl:apply-templates/></fo:inline>
	</xsl:template>

	<xsl:template name="insertHeaderFooter">
		<xsl:param name="docidentifier"/>
		<xsl:param name="hidePageNumber">false</xsl:param>
		<xsl:param name="section"/>
		<xsl:param name="copyrightText"/>
		<xsl:param name="section_title"/>
		<fo:static-content flow-name="header-odd-first" role="artifact">
			<fo:block-container font-family="Arial" font-size="9pt" height="26mm" display-align="after" text-align="right">
				<xsl:if test="$vertical_layout = 'true'">
					<xsl:attribute name="display-align">center</xsl:attribute>
				</xsl:if>
				<xsl:if test="$section = 'main'"><fo:block><fo:page-number/></fo:block></xsl:if>
				<fo:block>
					<xsl:copy-of select="$docidentifier"/>
				</fo:block>
			</fo:block-container>
		</fo:static-content>
		<fo:static-content flow-name="header-odd" role="artifact">
			<fo:block-container font-family="Arial" font-size="9pt" height="26mm" display-align="after" text-align="right">
				<xsl:if test="$vertical_layout = 'true'">
					<xsl:attribute name="display-align">center</xsl:attribute>
				</xsl:if>
				<xsl:if test="$section = 'main' or $section = 'commentary'"><fo:block><fo:page-number/></fo:block></xsl:if>
				<fo:block>
					<xsl:copy-of select="$docidentifier"/>
					<xsl:copy-of select="$section_title"/>
				</fo:block>
			</fo:block-container>
		</fo:static-content>
		<fo:static-content flow-name="header-even" role="artifact">
			<fo:block-container font-family="Arial" font-size="9pt" height="26mm" display-align="after">
				<xsl:if test="$vertical_layout = 'true'">
					<xsl:attribute name="display-align">center</xsl:attribute>
				</xsl:if>
				<xsl:if test="$section = 'main' or $section = 'commentary'"><fo:block><fo:page-number/></fo:block></xsl:if>
				<fo:block>
					<xsl:copy-of select="$docidentifier"/>
					<xsl:copy-of select="$section_title"/>
				</fo:block>
			</fo:block-container>
		</fo:static-content>

		<fo:static-content flow-name="header-commentary-even-first" role="artifact">
			<fo:block-container font-family="Arial" font-size="9pt" height="26mm" display-align="after" text-align="left">
				<xsl:if test="$vertical_layout = 'true'">
					<xsl:attribute name="display-align">center</xsl:attribute>
				</xsl:if>
				<fo:block><fo:page-number/></fo:block>
				<fo:block> </fo:block>
			</fo:block-container>
		</fo:static-content>

		<fo:static-content flow-name="header-commentary-odd-first" role="artifact">
			<fo:block-container font-family="Arial" font-size="9pt" height="26mm" display-align="after" text-align="right">
				<xsl:if test="$vertical_layout = 'true'">
					<xsl:attribute name="display-align">center</xsl:attribute>
				</xsl:if>
				<fo:block><fo:page-number/></fo:block>
				<fo:block> </fo:block>
			</fo:block-container>
		</fo:static-content>

		<xsl:call-template name="insertFooter">
			<xsl:with-param name="section" select="$section"/>
			<xsl:with-param name="copyrightText" select="$copyrightText"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="insertFooter">
		<xsl:param name="section"/>
		<xsl:param name="copyrightText"/>
		<fo:static-content flow-name="footer">
			<fo:block-container height="24mm" display-align="after">
        <xsl:if test="$section = 'commentary'">
          <xsl:attribute name="height">24.5mm</xsl:attribute>
        </xsl:if>
				<xsl:if test="$section = 'preface'">
					<fo:block font-size="9pt" text-align="center" space-after="10pt">(<fo:inline font-family="Times New Roman"><fo:page-number/></fo:inline>)</fo:block>
				</xsl:if>
				<xsl:if test="$section = 'commentary'">
					<fo:block font-size="9pt" text-align="center" space-after="12pt">
						<fo:inline font-family="IPAexGothic" padding-right="3mm">
							<xsl:call-template name="getLocalizedString">
								<xsl:with-param name="key">commentary_page</xsl:with-param>
							</xsl:call-template>
						</fo:inline>
						<fo:inline font-weight="bold" font-family="Times New Roman" id="_independent_page_number_commentary"><fo:page-number/></fo:inline>
					</fo:block>
				</xsl:if>
				<!-- copyright restriction -->
				<fo:block font-size="7pt" text-align="center" font-family="IPAexMincho" margin-bottom="13mm">
					<xsl:if test="$vertical_layout = 'true'">
						<xsl:attribute name="margin-bottom">5mm</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="$copyrightText"/>
				</fo:block>
			</fo:block-container>
		</fo:static-content>
	</xsl:template>

	<xsl:template name="insertLeftRightRegions">
		<xsl:param name="cover_header_footer_background"/>
		<xsl:param name="i18n_JIS"/>
		<xsl:param name="docidentifier"/>
		<xsl:param name="docidentifier_jis"/>
		<xsl:param name="title_ja"/>
		<xsl:param name="edition"/>
		<xsl:param name="copyrightText"/>
		<xsl:param name="insertLast"/>
		<xsl:param name="bibdata"/>

		<!-- docidentifier, 3 part: number, colon and year-->
		<xsl:variable name="docidentifier_number" select="java:replaceAll(java:java.lang.String.new($docidentifier_jis), '^(.*)(:)(.*)$', '$1')"/>
		<xsl:variable name="docidentifier_year" select="java:replaceAll(java:java.lang.String.new($docidentifier_jis), '^(.*)(:)(.*)$', '$3')"/>

		<!-- header -->
		<fo:static-content flow-name="right-region" role="artifact">
			<fo:block-container font-size="9pt" height="{$pageHeightA5}mm" width="6mm" color="white" background-color="{$cover_header_footer_background}" text-align="center" margin-left="11mm">
				<fo:block-container margin-left="0mm" margin-top="14.5mm" line-height="1.1">
					 <!-- text-align-last="justify" -->
						<!-- example: 日本工業規格 JIS Z 8301 規格票の様式及び作成方法    一 -->
					<xsl:call-template name="insertEachCharInBlock">
						<xsl:with-param name="str" select="$i18n_JIS"/>
					</xsl:call-template>
					<fo:block margin-top="3mm">
						<xsl:call-template name="insertEachCharInBlock">
							<xsl:with-param name="str" select="$docidentifier"/>
							<xsl:with-param name="spaceIndent">1mm</xsl:with-param>
						</xsl:call-template>
					</fo:block>
					<fo:block margin-top="3mm">
						<xsl:call-template name="insertEachCharInBlock">
							<xsl:with-param name="str" select="$title_ja"/>
						</xsl:call-template>
					</fo:block>
					<fo:block margin-top="21mm">
						<xsl:value-of select="$edition"/>
					</fo:block>
				</fo:block-container>
			</fo:block-container>
		</fo:static-content>

		<xsl:if test="$insertLast = 'true'">
			<!-- header last render in header region -->
			<fo:static-content flow-name="header-last" role="artifact">
				<fo:block font-size="12pt" font-weight="bold" margin-left="10mm">
					<fo:inline-container writing-mode="lr-tb" text-align="center" alignment-baseline="central" reference-orientation="90" width="1em" margin="0" padding="0" text-indent="0mm" last-line-end-indent="0mm" start-indent="0mm" end-indent="0mm">
							<fo:block-container width="1em" id="__internal_layout__lastpage_{generate-id()}">
								<xsl:call-template name="insertEachCharInBlock">
									<xsl:with-param name="str">JIS <xsl:value-of select="$docidentifier_number"/></xsl:with-param>
									<xsl:with-param name="spaceIndent">0.5em</xsl:with-param>
									<xsl:with-param name="lineHeight">1.1em</xsl:with-param>
								</xsl:call-template>
							</fo:block-container>
					</fo:inline-container>
				</fo:block>
				<fo:block margin-top="2mm" font-size="12pt" font-weight="bold" margin-left="10mm" letter-spacing="2.5mm">
					<xsl:value-of select="$title_ja"/>
				</fo:block>
				<fo:block margin-top="6.5mm" font-size="10pt" font-weight="bold" margin-left="16.5mm">
					<fo:inline padding-right="7mm"><xsl:value-of select="xalan:nodeset($bibdata)//jis:bibdata/jis:date[@type = 'published']"/></fo:inline>
					<xsl:variable name="edition" select="xalan:nodeset($bibdata)//jis:edition[@language = 'ja'][1]"/>
					<!-- add spaced between characters -->
					<fo:inline padding-right="6mm"><xsl:value-of select="java:replaceAll(java:java.lang.String.new($edition), '(.)', '$1　')"/></fo:inline>
					発行
				</fo:block>

				<fo:block margin-top="13mm" font-size="10pt" font-weight="bold" margin-left="16.5mm">
				</fo:block>

			</fo:static-content>
		</xsl:if>

		<xsl:if test="1 = 3">
		<fo:static-content flow-name="left-region" role="artifact">
			<fo:block>l=<fo:page-number/> 三用語及び定義</fo:block>
		</fo:static-content>

		<fo:static-content flow-name="footer" role="artifact">

			<fo:block-container absolute-position="fixed" left="0mm" top="0" width="6mm" height="{$pageHeightA5}mm" background-color="{$cover_header_footer_background}">
				<fo:block color="white">f=<fo:page-number/> 三用語及び定義</fo:block>
			</fo:block-container>
			<fo:block text-align="left" margin-top="192.5mm" margin-left="100mm" color="white">

				<fo:inline-container writing-mode="lr-tb" text-align="center" alignment-baseline="central" reference-orientation="90" width="1em" margin="0" padding="0" text-indent="0mm" last-line-end-indent="0mm" start-indent="0mm" end-indent="0mm">
                <fo:block-container width="1em">
                    <fo:block line-height="1em"><fo:page-number/> </fo:block>
                </fo:block-container>
				</fo:inline-container>

			</fo:block> <!-- f= 三用語及び定義 -->
		</fo:static-content>
		</xsl:if>

		<!-- footer -->
		<xsl:if test="1 = 1">
		<fo:static-content flow-name="left-region"> <!--  role="artifact" commented, because there is <fo:retrieve-marker below, occurs java.lang.IndexOutOfBoundsException: Index: 1, Size: 1 -->
			<fo:block-container absolute-position="fixed" left="0mm" top="0" width="6mm" height="{$pageHeightA5}mm" background-color="{$cover_header_footer_background}">
				<fo:block-container font-size="9pt" color="white" text-align="center">
					<xsl:if test="$isGenerateTableIF = 'false'">
						<xsl:attribute name="writing-mode">tb-rl</xsl:attribute>
					</xsl:if>
					<fo:block margin-top="131mm" margin-right="1mm">
						<fo:page-number/>
					</fo:block> <!-- 二 -->
				</fo:block-container>
			</fo:block-container>

			<fo:block-container font-size="9pt" color="white" height="5.5mm" margin-left="56mm" line-height="1.1">
				<xsl:if test="$isGenerateTableIF = 'false'">
					<xsl:attribute name="writing-mode">tb-rl</xsl:attribute>
				</xsl:if>

				<fo:block text-align-last="justify" margin-top="56mm" margin-bottom="3mm">

					<fo:inline baseline-shift="-20%">
						<fo:inline>
							<fo:retrieve-marker retrieve-class-name="section_title" retrieve-position="last-ending-within-page" retrieve-boundary="page-sequence"/>
						</fo:inline><!-- <fo:inline padding-bottom="5mm">三</fo:inline>用語及び定義 -->
					</fo:inline>

					<fo:inline keep-together.within-line="always">
						<fo:leader leader-pattern="space"/>
						<fo:inline font-size="6pt" baseline-shift="-10%">
							<!-- <xsl:value-of select="$copyrightText"/> -->
							<xsl:for-each select="xalan:nodeset($copyrightText)/node()">
								<xsl:choose>
									<xsl:when test="self::text()">
										<xsl:call-template name="insertVerticalChar">
											<xsl:with-param name="str" select="."/>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:copy-of select="."/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</fo:inline>
					</fo:inline>

				<!-- <fo:table table-layout="fixed" width="100%">
					<fo:table-column column-width="proportional-column-width(56)"/>
					<fo:table-column column-width="proportional-column-width(70)"/>
					<fo:table-column column-width="proportional-column-width(24)"/>
					<fo:table-column column-width="proportional-column-width(59)"/>
					<fo:table-body>
						<fo:table-row>
							<fo:table-cell><fo:block>&#xa0;</fo:block></fo:table-cell>
							<fo:table-cell><fo:block>三用語及び定義</fo:block></fo:table-cell>
							<fo:table-cell><fo:block text-align="center">二</fo:block></fo:table-cell>
							<fo:table-cell display-align="center"><fo:block font-size="6pt"><xsl:value-of select="$copyrightText"/></fo:block></fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table> -->
				</fo:block>
			</fo:block-container>
		</fo:static-content>
		</xsl:if>
		<!-- <fo:static-content flow-name="left-region" role="artifact">
			<fo:block-container font-size="9pt" height="{$pageHeightA5}mm" width="6mm" color="white" background-color="{$cover_header_footer_background}" text-align="center">
				<fo:block-container margin-left="0mm" margin-top="55.5mm" line-height="1.1">
					
					<xsl:call-template name="insertEachCharInBlock">
						<xsl:with-param name="str" select="$i18n_JIS"/>
					</xsl:call-template>
					<fo:block margin-top="3mm">
						<xsl:call-template name="insertEachCharInBlock">
							<xsl:with-param name="str" select="$docidentifier"/>
							<xsl:with-param name="spaceIndent">1mm</xsl:with-param>
						</xsl:call-template>
					</fo:block>
					<fo:block margin-top="3mm">
						<xsl:call-template name="insertEachCharInBlock">
							<xsl:with-param name="str" select="$title_ja"/>
						</xsl:call-template>
					</fo:block>
					<fo:block margin-top="21mm">
						<xsl:value-of select="$edition"/>
					</fo:block>
				</fo:block-container>
			</fo:block-container>
		</fo:static-content> -->
	</xsl:template>

	<xsl:template name="insertEachCharInBlock">
		<xsl:param name="str"/>
		<xsl:param name="spaceIndent"/>
		<xsl:param name="lineHeight"/>
		<xsl:if test="string-length($str) &gt; 0">
			<xsl:variable name="char" select="substring($str, 1, 1)"/>
			<fo:block>
				<xsl:if test="$lineHeight != ''">
					<xsl:attribute name="line-height"><xsl:value-of select="$lineHeight"/></xsl:attribute>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="$char = ' ' and $spaceIndent != ''">
						<xsl:attribute name="margin-top"><xsl:value-of select="$spaceIndent"/></xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$char"/>
					</xsl:otherwise>
				</xsl:choose>
			</fo:block>
			<xsl:call-template name="insertEachCharInBlock">
				<xsl:with-param name="str" select="substring($str,2)"/>
				<xsl:with-param name="spaceIndent" select="$spaceIndent"/>
				<xsl:with-param name="lineHeight" select="$lineHeight"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:variable name="JIS-Logo">
		<svg xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg" width="80.94133mm" height="47.963669mm" viewBox="0 0 80.94133 47.963669" version="1.1" id="svg781">
		<defs id="defs778"/>
			<g id="layer1" transform="translate(-0.51630433,-0.32770559)">
				<path d="m 35.949294,46.979025 h 11.64167 V 1.4071956 h -11.64167 z" style="display:inline;fill:#231f20;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.352778" id="path94"/>
				<path d="m 76.419964,22.870205 c 3.175,2.37067 5.03767,6.35 5.03767,10.8585 0,7.6835 -6.096,13.7795 -13.75834,13.7795 -3.175,0 -6.096,-1.05833 -8.21266,-2.64583 l -7.13317,-5.03767 6.87917,-9.017 7.13316,5.03767 c 0.52917,0.254 1.05834,0.52916 1.5875,0.52916 1.5875,0 2.921,-1.05833 2.921,-2.64583 0,-1.05833 -0.52916,-1.86267 -1.3335,-2.39183 l -9.24983,-6.35 c -3.175,-2.667 -5.0165,-6.62517 -5.0165,-10.87967 0,-7.6834994 6.07483,-13.77949941 13.73717,-13.77949941 2.64583,0 5.82083,1.33350001 7.9375,2.92100001 l 2.921,2.39183 -6.87917,8.4666694 -2.64583,-2.11667 c -0.52917,-0.52916 -1.05834,-0.78316 -1.5875,-0.78316 -1.5875,0 -2.921,1.31233 -2.921,2.89983 0,0.80433 0.52916,1.60867 1.3335,2.13783 l 9.24983,6.62517" style="display:inline;fill:#231f20;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.352778" id="path244"/>
				<path d="m 28.816134,33.728705 c 0,9.271 -7.15433,14.56267 -14.2875,14.56267 -7.1331697,0 -10.5833297,-4.7625 -10.5833297,-4.7625 l -3.42899997,-3.45017 8.19149997,-8.21267 3.1749997,3.45017 0.80433,0.78317 c 0.508,0.52916 1.03717,1.05833 2.0955,1.05833 1.3335,0 2.64583,-1.31233 2.64583,-2.89983 0,0 0,0 0,-0.27517 V 1.4072066 h 11.38767 V 32.670375 c 0,0 0,-8.21267 0,1.05833" style="display:inline;fill:#231f20;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.352778" id="path364"/>
			</g>
		</svg>
	</xsl:variable>

	<xsl:variable name="JIS-Logo_2024">
		<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 34.29 34.29">
			<defs>
				<style>
					.cls-1 {
						fill: #fff;
						stroke-width: 0px;
					}
				</style>
			</defs>
			<path class="cls-1" d="m6.72,27.57c5.76,5.76,15.09,5.76,20.85,0,5.76-5.76,5.76-15.09,0-20.85C21.81.96,12.48.96,6.72,6.72c-3.28,3.28-4.82,7.91-4.17,12.5.26,1.84,1.97,3.13,3.81,2.86,1.66-.24,2.9-1.66,2.9-3.34v-9.32h3.09v9.32c0,3.38-2.74,6.11-6.11,6.11-3.03,0-5.61-2.22-6.05-5.23C-1.19,10.27,5.29,1.56,14.66.18c9.37-1.38,18.08,5.11,19.45,14.47,1.38,9.37-5.1,18.08-14.47,19.45-5.36.79-10.78-1.01-14.61-4.84m13.84-19.84v15.43h-3.43v-15.43m11.78,7.71c1.8,1.68,1.9,4.5.23,6.3-.84.91-2.03,1.42-3.26,1.42h-2.74v-2.74h2.23c1.04,0,1.89-.84,1.89-1.89,0-.52-.22-1.02-.6-1.38l-2.15-1.99c-1.73-1.61-1.83-4.32-.22-6.06.81-.87,1.95-1.37,3.14-1.37h2.06v2.74h-1.54c-.95,0-1.71.77-1.71,1.71,0,.48.2.93.55,1.26"/>
		</svg>
	</xsl:variable>

	<xsl:variable name="JSA-Logo_2024">
		<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 43.34 25.77">
			<defs>
				<style>
					.cls-1 {
						fill: #fff;
						stroke-width: 0px;
					}
				</style>
			</defs>
			<path class="cls-1" d="m2.01,24.08c-1.58-3.99,5.49-12.06,15.79-17.97C28.09.2,37.75-1.37,39.32,2.62c.67,1.72-.24,4.18-2.34,6.89,2.31-2.77,3.38-5.32,2.72-7.12-1.52-4.17-11.45-2.58-22.51,2.95-1.2.6-2.01,1.19-2.98,1.78-.62.37-1.29.7-1.88,1.09C4.14,13.57-1.09,19.87.19,23.39c.44,1.21,1.6,1.95,3.28,2.26-.67-.32-1.19-.88-1.47-1.56"/>
			<polygon class="cls-1" points="32.72 6.03 32.72 23.58 43.34 23.58 32.72 6.03"/>
			<path class="cls-1" d="m20.81,7.75c-2.34,2.17-2.48,5.83-.31,8.17.05.06.1.11.16.17l8.93-8.49c-2.54-2.2-6.33-2.14-8.78.15"/>
			<path class="cls-1" d="m18.94,21.67c.06.06.1.11.15.16,2.47,2.29,6.28,2.29,8.75,0,2.3-2.13,2.44-5.71.31-8.01-.1-.11-.2-.21-.31-.31-.05-.05-.11-.09-.16-.14l-8.74,8.31Z"/>
			<path class="cls-1" d="m7.09,25.77l-.32-1.1c3.44-.29,5.37-1.72,5.37-7.99v-8.32l3.81-2.3v10.62c0,6.8-5.17,9.09-8.85,9.09"/>
			<path class="cls-1" d="m15.98,1.92c0,1.06-.86,1.92-1.92,1.92-1.06,0-1.92-.86-1.92-1.92C12.15.86,13,0,14.06,0c1.06,0,1.92.85,1.92,1.9v.02"/>
		</svg>
	</xsl:variable>

	<xsl:variable name="JSA-Cover-ja_">
		<!-- cover in PDF -->
		<xsl:text>JVBERi0xLjcNJeLjz9MNCjU0IDAgb2JqDTw8L0ZpbHRlci9GbGF0ZURlY29kZS9GaXJzdCA1
			L0xlbmd0aCA0OS9OIDEvVHlwZS9PYmpTdG0+PnN0cmVhbQ0KaN4yMlcwULCx0Xfy1ffLL8pN
			zNEPqSxI1XetKHEPLkksSdVPTlQwtLMDCDAA4EUL4Q0KZW5kc3RyZWFtDWVuZG9iag01NSAw
			IG9iag08PC9GaWx0ZXIvRmxhdGVEZWNvZGUvRmlyc3QgNC9MZW5ndGggNDgvTiAxL1R5cGUv
			T2JqU3RtPj5zdHJlYW0NCmjeMlUwULCx0XfOL80rUTDU985MKY62BIoFxeqHVBak6gckpqcW
			29kBBBgA1ncLgA0KZW5kc3RyZWFtDWVuZG9iag01NiAwIG9iag08PC9GaWx0ZXIvRmxhdGVE
			ZWNvZGUvRmlyc3QgNC9MZW5ndGggMTQ5L04gMS9UeXBlL09ialN0bT4+c3RyZWFtDQpo3jJT
			MFCwsdF3LkpNLMnMz3NJLEnVcLEyMjAyMTQyNDA0MTIzNdI2MFY3MFDXhKjKL9IIcHHLyUxS
			cM7Pz04CYk193/wUTJ0WRhZwnQFF+SmlyakwrdoBLp4KlnpGegYFpgoxGgEeAeb6Ppl5pRW6
			FRZm8WYmMZqa+iGZJTmpIPUKLv7hfj7+ji6adnYAAQYAiA0wbQ0KZW5kc3RyZWFtDWVuZG9i
			ag01NyAwIG9iag08PC9GaWx0ZXIvRmxhdGVEZWNvZGUvRmlyc3QgNC9MZW5ndGggMTQwL04g
			MS9UeXBlL09ialN0bT4+c3RyZWFtDQpo3nTMwQrCMBAE0F/ZL+iG0IiFkoOV3sQQexBKDzEu
			omBTkhXq37t6d24zA68BBW2LXZqZZi5gtAweu5yWXVpHJc00pjIb2Na6UvWEB7rew5/PhSwK
			mJ/hqaRXjlTEdznFE/GIbt/jQCtPeD5eHhRZzv6pQH81byXoEwcmUDi8FxLyRtZ+BBgAMBUv
			9Q0KZW5kc3RyZWFtDWVuZG9iag0xIDAgb2JqDTw8L0xlbmd0aCAzMzMwL1N1YnR5cGUvWE1M
			L1R5cGUvTWV0YWRhdGE+PnN0cmVhbQ0KPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0w
			TXBDZWhpSHpyZVN6TlRjemtjOWQiPz4KPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczpt
			ZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS42LWMwMTcgOTEuMTY0NDY0LCAyMDIw
			LzA2LzE1LTEwOjIwOjA1ICAgICAgICAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6
			Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRl
			c2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczp4bXA9Imh0dHA6Ly9u
			cy5hZG9iZS5jb20veGFwLzEuMC8iCiAgICAgICAgICAgIHhtbG5zOmRjPSJodHRwOi8vcHVy
			bC5vcmcvZGMvZWxlbWVudHMvMS4xLyIKICAgICAgICAgICAgeG1sbnM6eG1wTU09Imh0dHA6
			Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iCiAgICAgICAgICAgIHhtbG5zOnBkZj0iaHR0
			cDovL25zLmFkb2JlLmNvbS9wZGYvMS4zLyI+CiAgICAgICAgIDx4bXA6TW9kaWZ5RGF0ZT4y
			MDI0LTEyLTEwVDE0OjI4OjI4KzAzOjAwPC94bXA6TW9kaWZ5RGF0ZT4KICAgICAgICAgPHht
			cDpDcmVhdGVEYXRlPjIwMjQtMTItMTBUMTQ6MjY6NTIrMDM6MDA8L3htcDpDcmVhdGVEYXRl
			PgogICAgICAgICA8eG1wOk1ldGFkYXRhRGF0ZT4yMDI0LTEyLTEwVDE0OjI4OjI4KzAzOjAw
			PC94bXA6TWV0YWRhdGFEYXRlPgogICAgICAgICA8eG1wOkNyZWF0b3JUb29sPlBERmxpYiBD
			b29rYm9vazwveG1wOkNyZWF0b3JUb29sPgogICAgICAgICA8ZGM6Zm9ybWF0PmFwcGxpY2F0
			aW9uL3BkZjwvZGM6Zm9ybWF0PgogICAgICAgICA8ZGM6dGl0bGU+CiAgICAgICAgICAgIDxy
			ZGY6QWx0PgogICAgICAgICAgICAgICA8cmRmOmxpIHhtbDpsYW5nPSJ4LWRlZmF1bHQiPlBE
			RiBET1dOTE9BRDwvcmRmOmxpPgogICAgICAgICAgICA8L3JkZjpBbHQ+CiAgICAgICAgIDwv
			ZGM6dGl0bGU+CiAgICAgICAgIDx4bXBNTTpEb2N1bWVudElEPnV1aWQ6OWM4OTdmNTUtZjZj
			Yy00MjRiLTkxMjEtNzU0NzNhZDk2MDM0PC94bXBNTTpEb2N1bWVudElEPgogICAgICAgICA8
			eG1wTU06SW5zdGFuY2VJRD51dWlkOjdiMzI2ODMwLWZiNmUtNDIyZC1hZjZkLTFjYjMwYTI0
			OTdiNzwveG1wTU06SW5zdGFuY2VJRD4KICAgICAgICAgPHBkZjpQcm9kdWNlcj5QREZsaWIr
			UERJIDkuMi4wcDUgKFBIUDcvTGludXgteDg2XzY0KTwvcGRmOlByb2R1Y2VyPgogICAgICA8
			L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
			ICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgIAo8P3hwYWNrZXQgZW5k
			PSJ3Ij8+DQplbmRzdHJlYW0NZW5kb2JqDTggMCBvYmoNPDwvTWV0YWRhdGEgMSAwIFIvUGFn
			ZXMgNSAwIFIvVHlwZS9DYXRhbG9nPj4NZW5kb2JqDTE5IDAgb2JqDTw8L0JpdHNQZXJDb21w
			b25lbnQgOC9Db2xvclNwYWNlL0RldmljZVJHQi9GaWx0ZXIvRmxhdGVEZWNvZGUvSGVpZ2h0
			IDE0NS9JbnRlcnBvbGF0ZSBmYWxzZS9MZW5ndGggMTE5NDMvU3VidHlwZS9JbWFnZS9UeXBl
			L1hPYmplY3QvV2lkdGggNTI2Pj5zdHJlYW0NCnic7Z0HeBTXufflXhPbseMkbrEdp17nJnbK
			vU7ixHlu8sU0YxtsmujdNItiuo3pEDDNIAQIRBNIdBASoope1LtQ7723lXZVvnf3aIejmdmZ
			c2ZmVwt5f8/76NkdnTZlz39Oe097O4IgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIg
			CIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIg
			CIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgiAxNl66ZjoVYUtK6
			uiD3MhHh4Waz2cAEy8vLk5OSyOezZ85oSyQ3Nxf+xsbEpKfdrXc/Pj4+JyeHfM7KykpISOja
			8tzz+GzeXF1dPWXSpK4uCOIiWiurKnr2L/T4Hm0VHw3u6nIx0dDQWFFRkZ2dk5qadvPmLUaD
			wOXlFc3Nza4v8IBPP62qqvpq/nz4IGtDPT2VU4BiQ7DFCxeSr9M+/3zm9OlC4mmpqbxFOnLo
			EMn0s7FjV61cyRu9C5kza5ZwHbymTPHbsYN89vH2njF1KmMi+/ftc3QviAlCzA5czw3r1vHG
			cgZQfj3RN27YsNPPTzbZkJAQ+AtP8k77ZeeiuamptrZWT9kQV9JmMok0grbW+oauLmAn2tra
			WlpacnPzpJX/rVvhERGRSUlJBQWFoAKy0eFfMTGx4eERdMTCwiJI1mWnQJRC+LpsyZIv582D
			dzOuXzS8Mw/s12/yxIkmk8lR/cae2shhw/bs3t0upxQsYuq/d6+sjRs9WkNhuDBKKSZ99pnw
			FUq7a+dO+iuLUrS2ttbbyc3JgViJCQnCEbgajIUxlsiICNHFh8JwpTBzxoyvv/pKehySraur
			g7/BQUHTvLxU05F9REOCg7kKg3QhhQ8+r6AUYF1dQCtQHyYkJERFRYvUIS8vD558bU0DiAUt
			ESEp+Gx4sUWcO3sWDH4gJ44dy87OhmoZbPDAgZ4DBpBKlRw5HRqqnI7FYoG/ZrM5MyOD/OIq
			bAQGBAifAcZSkURIh5hIKebNnj2of3+oA5VTAM1SeCEfP2bMFh8fxsLwYpRSjB4xgtwdcoOW
			LFxIf2VRitLSUuWGCe+pXQwLmztrFhh5KuBDREQEY1wSEWzC+PGQNfkM5xJ24QJ8hUYoezEg
			vOwDSc4oPi4OfkfQOlBNp6Iz8FyNGTmSvRhI11LeQ9zpJLWaOYu6pGz19Q1QnUZFRdHSkJyc
			UlZWbmw/f3FxMUk8MjLKwGSl0PXG8WPHrK+diYlzZ8+ePnVqeHg4qZHIv1jSCb91a/nSpZfC
			wvRUTaQjS8hRUApouM2aMQP+FRcbq+FMoeIF+YB7B59XLl+uefREAeVqmes6gFIMGTQIFIcY
			RJk4fjz9lav3KTYmBqLwvroT4HVowZdf0oUXijFpwgRSMJZ06MKPHTWKfIZHBf6Vkpw81NNz
			+JAhjEWCFOB9DH5xcJVog+PwF0oLxnWO0NQiWswVC+laCh/4vqpSuLhZAU1akANaHaKjY+BZ
			dXa+UGmT7FRfofVwOyUFfiaHDh5st/0GE+LjiVLcunULviYlJrIoBbB40SKhDhQ+BJ04wfvu
			Sqqj6KgOiSRKQeo6qEzoXjJ2Rg0fPnLYMPjQ2NgI6WRlZsLf0pISDUmp4j69TwTSGThi6FD4
			O2HcOGhoMEYkwKvRsMGDv1m1Sva/xUVFkKwfz6AAhC+Ru/KgjNCYtTC8cZEnCm4lXCLa4Dj5
			INs35YgzoaEQkVdckK6lpbCIRSZcoxQNDQ23boWLOpfgoCtHEHJzc0m+zstiupcXqZzLy8oc
			vQOzKEW77bX/8KFD7bbfMrTlwUgvEPkMppoChJEqBTmybPFibVc+JDgYogtqu37tWlAN0i2m
			ITVVDBzRFq4bfIYrSX9lV4oxI0eSCxiwfz/pUSTHobqGmln/DIoltmYCY+DJkyaJAguNLLhB
			cK9ZbrGj7DTc0JnTp4sedbi80DTmTQdxMe6gFPDSFRsbR6tDXFx8dXWN83JUJjY2FspApow6
			A/ID+Wr+/FMhIUFBQSuXL5caY1KkVocfO/wtLCgA89+zR/gMpprCNC8v0GKRUsybMwdeIDWf
			IOgCpEAfgfTJwIozMEQpampqyBUjjalFCxaQRsH58+fJ8SaGfnhg7KhRECuCqvrg6+e26nqA
			bUrbGbURKFXg3YCxijabzaB3Bw8coA9qGDExRCnKy8tJ1jOmTYuLjSVXFRpQ+/394aDvtm1c
			RUJcTKupqauUoq6uTjSpNSYmtri42PCMeIF3Lec1K2bPnLlwwYIB9rlPBwIDoVKVmmo627Zs
			sXZujB9fUV7ebvvNLl+6FGza558Ln8GuX7vGUipp75P2M7S1U8LOn9eTAheGKAVw9coVr8mT
			SVuAHNm3dy956b129SpLCkS4S2zPcFJi4pBBg0jdCEXKzTFssoTngAGMVfSeXbsgJLwJ0AeX
			Ll5siFLU1tayp3P06FFyJevr6qT/3eXn56T2JmIgRY+/qCoTRU++YlR28G6ZmZkl6mJKc7Ol
			XllZ1hLWyT3VOiFzTohSnDxxYoevr6zRneSyHD92LCoyUvh66tQpSHndN9+c6kxmRgZLqZSV
			oramhqsbCt5jtc2uh3fg2ykpvLFESkH3bDAqBelfghr423XrpH01G9auJX16qhN18vPzSdPp
			rK0rfu3q1e261zKIiImOhgRPBgWphmxpabG+MyxZ0m5rJvMO8dPIhg+zzaNgT4Tco3DbYBzY
			hXPnhH+RORWqKcDjIZTf3BXLoP7DMQWfUVUK0wm9TWagsrJKtIoBrEsWvrEAZUtJue2kxIlS
			hAQHgyIQW/Dll0M9PYWve/fsUU4B6gqRTZ0yZc2qVaKDN2/cYCyPglJs2rhx8MCB7Gc3fswY
			qHXZwwvMnzsXSpKdlcUVi1aKxsbGBgrGPjR4/6+uriafpUpBPqQkJ4MxFgliHbGNH0kT1ExO
			Tg7p2po3ezZL+L27d0Ngk8kE7XRrb+e8eXm5ufBokZp21PDhJcztd9KfKTo4Y9o03lMjY/1Q
			Bp/Nm+HDl/PmkeMzbVPsVKPPnTULnkNolaxZvXoiNf0AcRklv/gfBZko+cnbehJvbW3NlDQi
			MjIy3VYjCFDI2Ng4JyUu9D7duH6d/EaCTpyAeqDdNiOlkmEdxL9XrBAZRP9i2jTRwUB7R4pq
			eRSUYvSIEexDJwBZQjhy+HB4AWaPRVj09dcDONeY00qhk8jISEdKwYV1gMP+zpyZmam5PDu2
			b589c+Zk2+RYYozSD+RkZ0OF3G7vgxKOw92Er2SonQRQBULu3rWLPgIvIXBwr22pJjsgtRCL
			LMqGZjv5FUCTDT6cOX2apRjkA1m3wpU1YhRl7/aQlYmKnurzZxwBj0RkZJRII0pK+CYNdhWJ
			iUkxMVrWEbBAfiNkxqPv1q3tlFJAnWz9NdVwD+gvW7JEdb2eQnkEpQC5gboX3j8Fg/8GBgRw
			JVhRUTFh3DihfjsYGMgeF153IUo+86RoKC28316/ds2RMQ5Gw9MpPVNtNdK369eLens09PkA
			IPTTp06FO3vowAGWpW2yZNiWVa5ftw4uBZmBFnzyJBxnf1rgCgvzYENt7jusg/5ff81bEnhp
			JPMEaBvYr985qidKgeVLlkBbNT09fbqXl9eUKby5I0bRWltX/MKvCh/9UeF9z8Lfoqde1ZZO
			W1tbWVmZ1M+Gnuk0rscFSjF1ypQF8+e326ejTJ44kfwXXiM1rF01SinS09KEoVhr7/3AgUM9
			PTVPVD4VEnLs6FHeWMMGczgcg3psUP/+I4cNc2SVlZWqiZChCtKrT6Pn3RXqNDh32jQnpRNo
			4MA9JbZN32J5H2/v4UOG6JzJpvmCwA2CU+CaqIC4J6IVc2AREZF3l0YQQCnAnJR4Wloa/VvL
			zMiAIyaTSU+aBQUFQme7hvJoW1DsDuTm5hbk5+tMpKamRrbp4W5zLRDkrsZsNicnJ4s0Ii4u
			Xmft14XExsbBO2FXlwJBEOReoLHRJF1Y7byxYJcBZ1FVpfEVHUEQBBGQaoSznSa5DKc69EAQ
			BLnnaW5ujomJlYxHRDhjqVqXUFlZ5WynsgiCIPcqDQ0N0dEx0nYEy/SSu4jY2LiysrKuLgWC
			IMhdhsViiY+Pl2pEjnEObdyEtra2e77rqaahuazGJFiDycjNPhAE+c9kwPLTUo24fTtV8zT7
			qjrTN4djXhmy66k+22h7uq8vHFxzRNdChsRs1r3eZDGbzenpTO6SXMZbnwXQV0lzOvP8bjzd
			Z5vH+5tk7fl+O3ReeSmxmeWiW2xs+grAucCz9Hz/HSRf+Kz/0epyoPyvDt0l/HBe8tx5D5wU
			cg9wI6X4ge7eUI3QGhEZGaXNF0fApbQ/Tj7oqKaS2idLQkuquHfxhogayibghoPybwzfQ18W
			DSm8N+Mo+2X/xSj/iFRjltL/aoy/KPG/Tj9iSMqy5JXW/Y3hTOGRHvzvs9qyUE387QmBnywO
			DQk3sq09bPW5h3p4q2bdb6le/2wkHT1tTOH6swS+dbtE+Yye+3T7HyYfGLnmQmWdxiXqiLOB
			W/PrcfuFWybIBPvuzDTfHo9nr6lE9lSfrTEZHKMGEGXc+jANhWy3uZhz3oI7zehRisjUUm2X
			/bcTAhqbdC3FtbS0yqbc0mK8EGcW1fzX2H10Lt/5aOs7nx+Clw1iH34d/F9j9olK4uVzhTcj
			rmvoqVWPBL7wvSZKE85COCkw6Ul9tDCkqVnjjXM3paDthUF+STn31Hjo3U5rW9sX28TPp2bf
			4GkF1Zo1grafjdzbwvaqT8I3m1s0lNZ5Hjz0oFkp4rMr9Fxz31O6RPPg5QzZZP0vcDgAZGHd
			0Vgh8Yd6bl53VGU5z9+/OEKXp7iSo92qcAuq65qWBUS9NnT3o718tN0vmqr6pkd6bhYSeXf6
			YeXw/ZeF3tftTqZcL1cCXaUUjgLA9fy/Wcce/eDO9VwRGK25bIiB5JbWPfZBp+e8o+LV1N30
			j1nHDZEJYg/28I7NKFfNlAT+4YAdvKWtrq5x3lZ3etCsFLKXcfTaCzdTivPL6onB59HrLkiD
			PdDdm1GauXLXU3nK0m1ekJDsgUusy+prG80Dlp3WfElVg+WW1n6vry8JDB/Y0ydciM0XyvbW
			hMDaBqZfX1NzS8+vTgoR47PUfywi3E0pBBKod56Dl9F5QldiaWl9f+4Jo37abW1tUFcbKBOC
			+Z1R2SZACHkuhs8dkNsuLdemFHQVav+JKY3U55XV9Vt6p/IMuKjL5VF6Yae25NBVZ+mvt/Or
			9CQu8MmSUOHFoKWVe37FyZvZ93fbVFbN4ZeM6xb0WXyKhN94nOPRKqpsEC7UoSvckysuJxQK
			0SPT+Mab3FYp6OIZ+6aBcOETFKdcP3OlVtPQ7AyN8GBrKdDhzRbWt+KSklK39VKlTSlEbcND
			V1jfxJ7p6/t47y1aC9vB2PVhQtaP9LL6L6UL88/Zx3WmD+w+m0JS+wF/+1EzvD8HuJK8UUh4
			kLDyGu0PpHCpuRJxc6VoaraQ8Iv9IzSXENHM/d0c1szalOL+burzNDTY8/22s+RORxm6isn1
			fUtLi7aRetegQSnqTWY9d5BdYR1BZ/23GUfgyE90z+BylIXm2dqaM2UPv/9iGlcUoU/+cnyh
			pgJ2kF1cS9J5oLs3eyw3V4p2+2y6lz13qQdFjOPSzVgPB9Wy5nqGnjFloH2y+BRjAUQRCyvU
			/WknJCSyn6Dr0aAUpVWNdJRBK844u5A0Z6Jy6dyr661THJcHRtEHVx+O0ZOFUCOV8s+j1gPv
			z0HoYGcJfDuvkgT+eFGI1gLeYX9YKknNOyieMYr7K8WgldYOUtBTrQVE+Kitrb1589bJs1eM
			VYql+yKdIRPd56tvMS8givvaMJU9HAsLdb28uYC7Til+OmKvkPV3P94qHKeL9KMBfnqyIIl4
			rtQ7DVVbvuzhy2tM7FF4f26qwMWH1J78kLUv0f2VYtupJGMvEeIIaKonJCSQxRHGKkVjk8UZ
			MvGXaSrzA0VIUzh+PctRYIulhWzs687oVwoX/7LofFceuONr8b87tzcbtK7XeGGQX1dVF7z5
			srcpGuwdhiduZusoYCei08tImoyjFe6vFO94HYLwT7twsf9/JiZTp+0kjFWK79heYIy1Cd9e
			5D1HaSL3OV5eUVxczJu+6zFknGLbKRf1sG041ml2hIlaBRYWV0D/S8NMZgJZOPDRQgO6aHjh
			rdkW+0cwRhm26hwJqWESlwIkzed4xvjcWSleGbwLwv9ytL/WAiLq5OTkinw3GagUOaW1hsvE
			6kPRGk5TNqlfj9uvISk3Qdvcp+9+LHbx9Keph036ll2zIJpzJfqvqEgaylNa3UjiZhTVGFRk
			DnhrNhIe6jfVkE9+yD1LioVBy8942GZSsQR2c6UQ5j4tD4zUXEJEAYvFEhsr3lEC7NyVCKOU
			4rNvLxorE1/t1ujQ1VGCyXl3qysAbUqxdL/8zX1hoN+x61ll1U6ZEpxXWkfnJV2U0X9ZKB0g
			8CL3Kqor9vUCBhWZD66s354YSMLnlalv3UJC7jl/W18BxZyPyectg3sqRZO5hfcngHBRV1cn
			1Qiw0tLSwop6o5TCWJmYt/OG5vPVcxbuieY12m9QI8uy9uMhuzadiG/U6iZIylsTAuj0pYuL
			hRaB5psyYeMlN1cKS0trwMV04QQ/Xco0bY8E1uaFhiXl60nqHa1uqxT0GOheo8UUAZKSkmVl
			orHRui7VKKXIKKoxUCZuJOsaO1BIGWpFPSl3FXo8BP50xB7Gy/7f4/cn6HPY3t754jsadnyi
			d6fuqah0Pg9FT9h6ad51pk9aBUiZ/zD5oCN7cdBO+uzoAX2WlC1OcJ94VyvFhmNxZGyC2NFr
			mZrLhshisViioqKkGhEVFS2EMUopFu4NN0ombiaX6DxxPSfinuj0Or77XIqsLy9HdiVR47Th
			QOpFGuxqYpFsMC+fTqNjf595lCsXEuuDBcFcsQ5dSZ/rd0PBuHJnMdAylrU8hK0hSc57Pt1f
			KVjs8d5bLie4+4T2uw6TySTblLh9u5MbT6OUAn4UhsiEBp9mUpSzeM+2XvjuQv/+FEBoRO5L
			njsZb8TbEwM1ZPHiQD/GcnI9XbJxeZVi2Opzep5wUe7wwIvskV4dfl/XHInJLeXeUB6VwpE9
			09f3Ha9DSbl36yCjO1NTU6PQ40RjlFIYsi7bqB5a1YwyCqsNychlGKIUBGsX+qU0ltvx7KdM
			8ypp6Oh//0KppfCb8Z2GM6ZuucqbS9cqhfR4aGTHsvQTjhfvsKSMvU+Ia0hPT5eVCYtFZtTS
			KKXQLxMlVRz+PPUXxqi8XIOBSkGTVlB97HrWq0N2O7pKKwJZ+9iBfks7TWpSHmzac+42Hfix
			3hzOGYwd0Z7pe90QpQBeG7pbT8FQKRCXER8fL9WIiAiHc4/dQSke6uHd0KT9ydRWmFUHow3M
			0dk4SSlotoYkfldu4SR7CoLTVGLrj8UpmyijrGLWxRHB4TnuqRQVdscd3ead0FASEje9wOAG
			b6Z9tsndPksWMQSz2UwvvpYdv5bS5UrhDE9fjFmbmo2fjugkXKAUhA8WnBRdJb/TKruBEBpM
			BjhyYSykMM+WcX8fZQxUinaqYaVh3+cHbTtl/37SAd6Iygy3dbvdx+N4SsOmGAKoFO4MyIRs
			j1NaWpqyQ2ajlOLZT321VQ76vVtLYcz6z1P53El1IS5TCkDYqY1Yz/knWWKJGhTarLKWdTHg
			wz2tlarnCgPcAxqrFEKAJz/i3uBD2IOPN6IyD9u2WGUsDykA+0wwKagUbktlZaWsTOTm5qnG
			7doR7SbnvNWzFyAlr8oZBTAcVypFMbXhGtg/ZqlvOST1MaXN5u+6yVjIv04/bNSlMFwpDl/t
			2D18eyhTc0wgNqPDm19YXAFXRGVImtFsi1a+94n1PUGzPy4hu+HfMO0Lg0rhMgoKCmRlgnFf
			HqOUYuCKM1x1wjN9negKkqskziuGMmsOx+w5n6oezobgEcg1ZeZVCl+7I2j9xlvIZQF6/f8Y
			rhTtlLI3cnq1MvwW/6C/dYdiaFYwhu8274TOApDou86msARGpXANRUXFsjLB7kbbKKU4dj2T
			vTb41Zh9jMW7llS85nAsY2ABrqpp8T5Xb7NobmnlrRDoAjO6etMDr1KILmkN8/CB1E19ELPD
			7d9NOkCiVPOPCNA4QynyyzucX70/l2NfFeBSfIevXUNmXAhbmS/aG84YZcGeWyRKq6ZtBJvt
			rpmaLUzdBagULiAvL19WJpqaOH44rvf7xO4ueOy6Cx3PuT/rc85VEt7q2hB2nE6ms2aZJBOR
			WkpHmeJ9mTGvf845/u507rGYCRs7eXpU9dOYX9bJJeD3PvHlyk40wvWzkXsZIwoq8302f9qO
			cIZSAHDdSEjexTtkXNuQx1LDE97U3FHVrz3C/YYGvGnvhWYMj0rhbJKSkhjX1iljoFL8cvQ+
			1UR+PY61NTF7x3U6YmRaKftJ8SrF/35+kD1xnfxr7nFR7qqzIkXhGR0a1DU2k/CP9NqcXsg6
			AbWi1iTaVD0uU2XVfH/7OCyxOTuuM+ZFEF5iNVRr2+29Xr/5LIArUxonKYXZ0vpIL6sHlee0
			LmB8sLu3nsldz9hnJtzOr+KK+KOBO7TV3o1NHcNVfZg3MkalcCpxcTKLJsCam7mfKwOV4nJ8
			gXIKf2beum6m7zVpdPaJMbxK4eHaoW1p7udj5OcewGvzT4aL/ftpy+X1Ybsz1XZzSC2o1nDf
			NdfzjlL48GuOxde/GtPxfgIXSnmanyOcpBRAfFbHbne8vk+3BCcKVyOP3zFIVX2TsDVJ8K0c
			3ujCXt5ckwObLVpcgqNSOI/4+ARZmWht1TLd1EClaFesoqHyZyzSaHunk8ge6O7NmIIGpXiC
			eaNh/cjq4EM9N4en3nGNCL+7jxaGSIPtDxNv9yDL2eg82dN8sIe37I1YvC/ioR6bpeETc1Tm
			RWzrPJb9x8laWmd/8jqsWW5AHQTP6vd125TKr/h/mcY3jYor8G8/C9BWEwZcvONxhX2UAdhF
			LX7vvyyUN1/Co3Z/kq8OUdmDXgBaQCSKL8/WiqgUTiI7O0dWJkwmjbvSGKsUKblVsnFnb2ed
			nv17+zClrDFOO9SgFB7W/v9LjIXUj7YSPt9vB+O+maftPoj0GFTgqhm9OrSTJ5CdZ/jmhRKk
			0yEKGFYT0/z7YLQQ943he1iGxY9ey/rD5IMa5IkrcF1jR4cMV0OJAG8OQtnu77Zpw7E45fBH
			rmaSOa7EDl/Vvnqu3dqZ7E/SebrvtlTFDtIl+yNIPxvYmHVhXLmgUjiD/Hz5Iezycu17Chir
			FMAfJFX9+A2sG2H/c7a4D19k3/loK0s6muvGsmrDfE8pY2lplXWdoWC8rR7IQuiZ0WAsP3lT
			c4soltbrIXPLeFPIK617sbOn3Of7bx/xzXmoYMEOXc4gH/ouPvVcv+2ivODBq6jh69tkL9is
			7R29W8mavKH+eWqnBtejvXy6zw+CE9kemhR4KQ0+jFkf9sMBO+gwv5t0oK7RgNXrorYeyRfs
			cnwh+fAnr0N0gM83X+HNApXCcIqKimRlorpa11bChitFO9UOBdt3gXXJwDudnzpHdjZKfTmh
			5urx9WGsbW1D+HiRTP+SrMGru7YsckrqyIx6doN3SNVOJ8KkTZc7VVCaHJUTpF2O2nytpORW
			iqpNBXvq422TmSeSCWio2TT8iGjKa0xvsG1H9ZLnTm1ZOOJUeO4TH6qvvmfZJVwWVApjqa6u
			lpWJ9HTuPYhFOEMpotI6ZnWeishljPL9T8WveY7smb7qkzA1KwVYSAT3CKAe6hrN8CamUJ6X
			B+8qqmzQmUtVXZMwaVPB3poQyLWxgij6FQf7FrGQmi/ut5zNOYeKpqHJkl1c2+srsQ8rYnDB
			4b9V+lZhuJ4mc0teWd2INeflz6ik1hlOaAml1Y2yTym02o5czdTg4QpxBs3NzbIykZmZpT9x
			ZygFcDWxMOgma/GeY5YJYia1TZ/1KMVjTvBYyEhEWiltzU7wiNVuc9YhyiiCZwYygiDuiaxM
			xMUZsx+0k5SCnec5+0Y8rDNaVfp79SgF2IhvzjvpZBEEQQynra0tPFzGkTiYUVl0oVJAY/np
			PnyjusRUh8h1KgVYdb0BA4IIgiAuIDU1VVYmWloMc8HaVUpRXd+kuRp/orfKLCD9SgEtHWPP
			F0EQxBk48iVeXW3kllhdohTl9q3BNJty+vqVwoPHVR2CIEiXAK0GWZnIyNC1mkaK65WitqFZ
			fzWunIUhSmGsOCIIghhOdHSMrFJo82yjgIuVQn9rwpVK8b6m3ZARBEFcQFlZmaxMmM3at0F3
			RGRaKUud+Y7XIZfl5T5K4f7NiquJRT8f5Q/GGP52XhVXeBE7TidDXNHmQYeuZPxtxpG9DLsy
			QdxPl8h4IiJFauF3XPa7iQcg4oBlp3kjOuLNcfsgwVFrLmi+RK7k6T5WN4Dsu70g9xKtra2y
			MlFQYOSGiQKMtXefRaxuhB0hLMbUb6r7ERioFIaLBXu+UQzLHM5E5XEVMj6rXBReoQArDkSL
			on9zOAaOT91ylT74+jCr66edZ1JuppQIJuvp2sPq4F3mlYNkx6sUAyhv5z7BHF7pFHi4l9VN
			Yrd5QaJLGpVeBieVlNMxPZuco/NWurGwyD+c+DN/vPeW1Hwjxy6Ru4Lbt2XmO4WHO2tftnMx
			8k5HRcbyxqhAmpw7a82m6l7GWKUIjWRdac6CGyrF/d02PfuJL22P2CpMFqVw5LS2t5xDPFop
			1E9fcd9nwdUqNFLIh5BwpsX1LFdeqhQvDPKDI3+dcYROpLreKWuTBW97qkZ8vMCL00l+1+LI
			XU1TU5Nsg6K+vt5JOY5dH8byTMZlqWxno4D/+VRjq+7UgirlHI3Njr0eZoElwY8XnTJcKX48
			ZDfYCwP9SHjylZTnNYm3q2Grz7EohdnS+gDl44u2b4/LOD41Sim6z+/Y63na1qttbW2vDe3w
			ibRabUfRdcfi7iWlcMbzidwVxMfLbFEUH5/gvByf67w3peGPondQguH1tlnNzYXhOQ7591nN
			V0C2bMphpErxr7kntJVc2CDP0W31sHnoHb32Am0/G2nd8UFQiuTcSnIc6nkP68aF++FzTcOd
			FTHvfXGUhLwY17GbVYOpk8cVEt3D5jidfBb+NWjFGQ/rnrl3Ots9HCtFXlndS3aHsX2pjdX+
			OKXDf/gfJh9QuLBkO7/Xhu6OSC2Vms/JREd3x5VKse1Ukk9worKNtHt/uhCb74wyIO6MxWKR
			bVDAcedlyljhaEt8a0giY/rsxrJNs+GZglUw77jHUjblMFKlgKr1V2P2SU0o3lMfb5UNEEHt
			jtSudZzinFwX04uDrDX20322PWbb9eZsdF6VfTWll6R70NET5XcmhXyl9+OTVYpmS8sCysnh
			TF+x/8BRlOu8FYFR0o08QiM69uwIuCi/GxRpSXW5UrAgvIDVNxo/ywVxc6KioqUykZSkZWsY
			dlgqybl+rPsQ0fx5KpMXcV67kVxsyEnx2vf7bTdkirI2pZCloclCl5BlkyNZpWDvffqHfQOR
			1ta2kqqGRz/YDAehkqeL8aOBOxzl7mHvfWoyt+w9f2drtgkbL2YUVlfWmaDuFXze0hH7LwsV
			Ajvq7yJ2H/V58b47o3vN5o6tNO7v5nDnRBLgoR6bpf9yN6XoPj+InGxXFQDpKhwttdO25yk7
			LJVkLf+uKL0XyDt81mnfY3A5znhSGuy0EUPbBiqFqENbueOFoFMphLz+Oec4fXx7aJKHXU8V
			cheU4tCVdCGp8zHW/hNTs0V0tWXzDbyUdj25WOEe3c6rGv/tRfL5lcF3Nmt4uGfH3q9ZxQ73
			cyEB5u28Kf0Xi1IoRDecHwywul9+YaCfC/JC3IrCQpmNimJiYp2a6YkbWUZVzjT9loaqJqvN
			GDd8dFLuHppEU7ZsUJ8o2C9G+asqxSe2OT/P9N1GEiRdQI420Px6b7js6ShfK5FS7DqbQv+3
			x/wgcvwze81M7Jej/R1t7uZBjWgPWH7aO6jTANz/zTr+95nHei8IXiUZmD54Od3Lh2M/tXqT
			+f15J8jMB7OlRZAJUDRHUSLsW5FGy42PEKXYcTpZOBFHStFk34CJ99FiaSyL8mLfmx65Z3Cq
			w1hHDF55RvUB3nPuNnuCra1t731x1Em19MvM+3k5qQBgg1ac0XSltZRNQSmW7o8gYYS5T8I8
			5LA4mSHONUdiXxm8C+xH9rlP5CspzwPdvclXwcg2ZyKl+M5HHY5/p265CgoFb+8QQCjtxI0X
			Q6nNu18evOt6krjq85DMfZK9OPwXVYlGex/duqNK7109vzypkDv5F4tSNFucrhRj7PsDMoZH
			7iW6RCnuY3iAuRIUXt6cYewrs5xXBg+tuyGLyjbX76aC/dw29ciRUqw8EEUSScypoGfJgqaT
			z6GOtxqcsPGi6LZ6sPU+LbFp02u2RXagFHAR6Gsi7GTa0tJKH//OR528/hKlWLwvAowEIJ/B
			jl3Pkh4UIr434+iDPbx5zdfWgiBKwTiz+s9TDyv8NyK1lP5KK8XWUx2TN1rsy/GUb7HUcktr
			lUsoKswLjseDBELCcx/9wAfsrQl3Nq4duy6MHCRfoR0KnxOy7+yHezWx8NHO+3nBWwGJApZd
			3FHO34wPEA7SCcoC/z1wWbxB50uDdsLxDxaclA3/5a5O/XiTNl2m83pj+F7V07/3qK9vcNKW
			dsqo1oqL/TlW/DFu9avNuFahOlUpyMJYzYgqalkUxin+MatjTHnVwZh2yXoKYWPrKQ62hxbO
			Yqq9Mwc+P97bp9dXJ2l7efBOWinS7Q0Wej0F2abzqY+3ieKCCZOypLmTebZSG7rqnPSgEPHd
			aUc03Kltpxz2NYl4a0IAiSK77FoYQxFdRlopXh9mffhdMHDQyz4CeDlexWkDqB4Eg9tBFrPf
			362j/NHpZfd33zRnR8c0lbVHYuG/T364VYh4OaGQPtlXh1hfD17y3AnpkE5OcvwXo/zhJw8H
			BZMtxuRNl0iB91NTzmIzyshBYaE9HWW9bdmL2dxpbwU4HWjVCnnBO4/y6d+TlJaWSpWiro5j
			R2MNsHQ9saf2s5H+zquc95zn6AFrd7JSeDgeDmAvm3IYWaWgd5pesCecHJSuvBvy77PkCFTX
			9SbxFErpzVU4TUEpjlzNgK/LAyJFK+++8L3O9fB42JTi5K1sMBJG+BCTUSY96Oj6CF1t9MGm
			5pYNcsv9VBHaYt0dOIRMzK4QZefRWSkEKVm4N1xDAdjZd6FjEetPR6i/UUOw9dSDSrc0ocF1
			9Fom+UyUAuyjhSHkCK0UBy9b5x7sOpsixE21+2kBpVDdUyy7pPaB7t7Xk4o8OisFfT3Lahrh
			sz/1G4ev/2/OMVFSv5904LefBaie9b2NrAcPp+bY1tamWh8Ki7ZYgB/vQ87pevK/wO1IxBnF
			EJlmnz/KdSBBqhSfUpMEoDkAbQdivb8OJgeFI2Ce1DsA1LpCIov8rePaz/Td9scpBzyo18gM
			+zRXheI98aG1H0lWKXp9FQw1Em3KSiG6DnRg1WLQwQYsv/MSm1tSJz1fFuLsk8Gg8lTOjq6c
			RUohXG2urHmh559U1KpP0PWwbchVWt0o/ZdUKVYfst7Z0iprYFopFM6LRSnowoiU4nNqisIz
			fX17ftnRB7X6UDTJER65fkvv3GJQin/NOeF3OjkstqC8xpjFTXcdrlcK8mAo2H3duB/7xibx
			REf9lqbWvSyLC5RCWJWsrWzKYaRKcS46n0Qsqmw4cjVTuWwQfn9Yh1skWtHIkbyy2gaTmXye
			sc1a55O6/eej9tLFOxeT/5LnzjpTp7leskohci2rcI4enZXizbH723Uohahjv+/iU7zV9UJq
			SliK4+EnEkAYzm7vrBR/mXaYfJ2jadkRI30WhQhFhRd1lii+p5JI+Mc+8Hl7YiD9L6lStNtO
			6uGe1rUkIqWY4sDNGpmhJxi9yl6KR2elIP2T5LOpyQIlFJQC3mT+9/OD7RKlEK2jidfhX+ju
			xcVKUddoVq5qHlfbftQRLa2tQu+HTnM0tsiC4boga7duc0xrFJVNOYxs79O+sI62VWVdk+CA
			YuOJeJIg7ZWCBMspqRV8n7ZbPXtbR8mfta9wH7j8zAPdvKvqm+A1kqQQbosoFG+vzVvX2PVh
			dBmMUor351mdk5B6QAi8Jdg6KNx/WajyVRq1Vn7mT1R6R9c38ZunTERqyY+H7BJuZaTjaWY9
			bGvcRNkJsX49bj/5TCaSOYPAS+nEuzixK4kcLX0g+Fa2p81fyn3vb6q0+xmQVQqT7U1v6f5I
			dqUAdRaeOnpMXIpIKSpqTaLpNGTKdLTtJhaUW93ciZSi3TZeRj78bOTeZxl8Ndx7yI5TOC+7
			d+1vQY5MmN6gjcKK+jftvyANBi8VKXkGzC9ytmnba5s9fQM9BAorXNKoiQHJuZVCH7UwTE++
			FlU0rAyMYlSKgStOH7iUTpuyUjSZW6Cm8rA1CoR2aLOlhVQdUemdBEsgMaeCTrzHl0F0/Sky
			WdfH9SbzwcvpI745T4dUXip47FpHh8/KwGjRidAGr7sNTQZ71UgrqBa6FonB+ZZUyXQlsUC2
			rRfmLcsqBTBug9Vf6HFbNxc58kxfX0dPl57eJ8KVhMKAix33NL2wut2xdzIRZCE/Y9b3ErJz
			n5yU16qD0bK3Q7C8MmNG0tva2l4ZsvO+bhx1Lz0BQw/OUweROZpiZEjZDFSKS/GFHp0Xg2yg
			vKr+kJpvKSqD6GXbkBFtMtEIKqs3x3ZMkYKH5M1x1s/3d/MW1jWIUnh7YqBCXo/08vnux9uW
			7IskE34e+8BH6nrlQmw+HQWqd9WZCSPXWNsvT0ia2HQ6/zP5oHIi2qBvEFyrq4lFvClARGFK
			Q2SadV0hqC356kgp2qlOHvI1rcA6j2LCt5fIHPVmc8tfpnU09vUrBbwekDWhf7f35S4LiBLs
			4Z6bockGH8i/yFr+drtjFuc14twc1yjFQgdrdQW7pDb1TgPxWeXj1l9UyHTU2gs3kovNlhb1
			tNhwmVLAz4rXGRSJCHKsYMTrtbFex4/YawYCXG0SUbStAzwAwtm943VItIZFVinGf3sRbh9t
			ykoxb+dND9tSQV+7D5BNQfEHbHNsricXCWe0qvO6v6CbWeRRAfMNTYZcUvKqZN9qPGxzd5vM
			4sdJUIp/zT0RkVrayuAmC5QC3uRls/CweRguc9rQKlGKfktPw2lqiE5vQ/x4b+s6ykd7dax3
			IBMbfjqyY4BepBQx9vmrwpEdocnkyJP2pZekaSMap1B+CKVK8frQ3STWtM4bYwmIep9I4Bfs
			S0c1N6/udhITk5ytFH0WnVKu93JLnTsv12WExRW4zBT8CLk5GnYjNYo8uSdNZ5+ngIETY47f
			yDIqqS4Bnk94OQRLpAYRUvIqyaNLvsK9ED4LsURH2m3TZSEdelevW7dLRL8F5ZJI6/Zgxc2n
			LicUCo2gdttt9Q5KgDIoZ3TPI90UtbKyyqjEI9S2QH3Z8z+0KYcgCHJ3UVdXRysFtDL0pzlx
			46X7uyl5aQbz8rliiD9tBEEQxAVUVlbSYmEycbej94WlfbAg+OeSLkRZ++Vo/yyDmvwIgiCI
			y6C30r51K5x9fwp6LFLVXhzkdzWJezYFgiAI4j7k5uaCThC9aGlhmhRU19jMohF/s+/GgiAI
			gtwDNDQ0QLMCxKK6msmT6rOf+joSiF5fncwuqW3F8QgEQZB7FLPZYjarLwIlu4893nsLcf7s
			E5wo+HZAEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARB
			EARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARB
			EARBEARBEARBEARBEARBEARBEARBEARBEARBEAS5S/n/wuw+kw0KZW5kc3RyZWFtDWVuZG9i
			ag0yMCAwIG9iag08PC9CQm94Wy0wLjI1IDIwLjQ0MiA1OTUuNTUgODQyLjI5XS9GaWx0ZXIv
			RmxhdGVEZWNvZGUvR3JvdXA8PC9DUy9EZXZpY2VSR0IvSSB0cnVlL1MvVHJhbnNwYXJlbmN5
			L1R5cGUvR3JvdXA+Pi9MZW5ndGggMjk0Ny9SZXNvdXJjZXM8PC9FeHRHU3RhdGU8PC9HUzAg
			MjcgMCBSL0dTMSA1MyAwIFI+Pi9Qcm9jU2V0Wy9QREYvVGV4dC9JbWFnZUNdL1hPYmplY3Q8
			PC9JbTAgMTkgMCBSPj4+Pi9TdWJ0eXBlL0Zvcm0vVHlwZS9YT2JqZWN0Pj5zdHJlYW0NCkiJ
			jFfLiiXHEd33V9TSNlR1PiJfMMxCM8IINCAj+wOMkeWFJJD8/+CIExFZWT2NyU13nVtZmfE8
			cTIcf//+5feX1x+ODx9ev3z67vMRjo8fv/n86XgJR7hST/y39H788fPL619/DMfP/+UXlOIV
			6SijXJlBuMbxx08v//7Ly7df+MNlszg3u1otvFWlzH9zbrLh7/yeT+G/JfYrHq3Vq9Pxr1/l
			7OPXl5MoXsSfHb/IcznOcJE+9ysxjFcpwIXtOc58ZYP54rflagbFzLNfVVGVPc8Yr178hy4/
			FNvccO3pimX9pHbectmx9n6N9cQ6eNPFoDroSqvBddTpSx3N91c38Yu8D/ejbWsrq3hkm/CG
			8lj4nMcW8wfirMACO7KJrfwDR0lN5GyoyYYTMPvU3KWhPlvciOPziAp+uMOG9RxWDwn24wit
			p0kUFmtoYlib/FvzJl3FPdVHDYClHbHRigiokf9ICf5tLatU2bnW6MprWcmGWlOcLdkBh0b2
			W/4IkIrmcsJz0rjhHNh7Dv2C8EGCg3iubVy1zGW1Z+TCNugVtRA0ql0LBYfWEaxsxJ46kqbQ
			MpzumtDHiDyMiDxlfNIHkljkeJxEGq2uVsi5Dbu5hUBmO5YN7R3bAQZg66wZwplBO+YR7His
			fRxbFmdr5qobS8SjtANCjqeztKs4kk7t1ouMEbmgEWAoKFqVaMueNWlTsflYnK9QDDdAjWzW
			t6TlGTVQZBUWtZiL574AmBEWhGrHVPR69aUVCazaFbFduhQ9wywWFHaDZYVDW7QaLzFvpnJv
			lZQyqpEYQ5yD56QWFeO7BKYTjDAlgmf2jnQtvM7S7GcL5nWWyJ0tWcAyarFpfZxpSEiaxSs1
			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
			g5WmkFTtEn3IBGzfvo7lM8yYnx7/rsPGE1CWinjWx7N4IMtvVMAS3QgXY3n4BU2agpxhxXsy
			aaCnk1uMKqN8zx7em8L0Ww6ohoa8y+YdRWsGVX4Exdz0PEJPJ6+WZjUpD8NzVx7Pc3xW3Akf
			SNc1Yfr10bJdcZWdCNNCpZ5AdJYPidq4Gybto0pIM9Ii1KjfYJu0zWm3zIYxN3T/JhPP6aS1
			axmdLfjkiH5Aw0hStugYUG5JNWHXppcn6XEKVEXM8HyFbbEF0swut0Atcph1F3R3tvpXZW0F
			RGLc6eVEQmKnt3tZNSmRqQnyZNOMj4Lss93Gx1c4zItifwf66gqZ8ES2FGBOqapiIM5ns8ae
			lTwQZCc9iUKzSha3bVGwzGcb8HTPt2WSf/vl0/Hy+sPx4cPr9//87efjTz/9dv7jxz+/fvn0
			3ecjHR8/fvOZF/zfVXlrFW2tKlur6taqtrWqb60aW6ti2FsW95bthT/uxT/uJSDuZSDupSDu
			5SDuJSHuZSHtZSHtZSHtZSHtZSHtZSHtZSHtZSHtZSHtZSHtZSHvZSHvZSFvUtFeFvJeFvJe
			FvJeFvJeFvJeFvJeFmgvC/ReFvTNe4HXN+/FWt+8F159sxdR2oso7UWU9iJKexEtexEte3Vd
			9uq67NV12Ryye1ko/xNxsWCKLRYgMvCAL+TSdw82VEgv5jI0NwK1QUAtEGAnygwY6EbATosF
			uKFrAkxsyblc+p65Bgou+bDGSSAXQIABAAWPPCMNCmVuZHN0cmVhbQ1lbmRvYmoNNTIgMCBv
			YmoNPDwvRmlsdGVyL0ZsYXRlRGVjb2RlL0xlbmd0aCAyMj4+c3RyZWFtDQpIiSrk0nfLNVBw
			yecK5AIIMAATZALGDQplbmRzdHJlYW0NZW5kb2JqDTUzIDAgb2JqDTw8L0JNL05vcm1hbC9D
			QSAxL1R5cGUvRXh0R1N0YXRlL2NhIDE+Pg1lbmRvYmoNNTggMCBvYmoNPDwvRGVjb2RlUGFy
			bXM8PC9Db2x1bW5zIDMvUHJlZGljdG9yIDEyPj4vRmlsdGVyL0ZsYXRlRGVjb2RlL0lEWzwx
			NEY4QzYwQUQzMzU3NzQ2OTg5RTAyRDk4NUEzQzFCRT48OERDMUI5Qzk5MzEzNDU0Mzk1NjQx
			MTVDMEMzQjhDNDE+XS9JbmZvIDYgMCBSL0xlbmd0aCA5OC9Sb290IDggMCBSL1NpemUgNTkv
			VHlwZS9YUmVmL1dbMSAyIDBdPj5zdHJlYW0NCmjeYmJgYGBiZOZg+v/3BxOIDcJMDOZAmpHp
			H8MJJkaBcCbGD4+A7ONweVyYUWAyE4N+JNP/gyJY5ZkYzIDmnCJoDiWY0acHSEczMWzRBNJ9
			TAyMvUD8mYnBmxEgwACKYhLkDQplbmRzdHJlYW0NZW5kb2JqDXN0YXJ0eHJlZg0KMTk3NDMN
			CiUlRU9GDQo=
			</xsl:text>
	</xsl:variable>
	<xsl:variable name="JSA-Cover-ja" select="normalize-space($JSA-Cover-ja_)"/>

	<xsl:variable name="JSA-Cover-en_">
		<!-- cover in PDF -->
		<xsl:text>JVBERi0xLjcNJeLjz9MNCjcgMCBvYmoNPDwvTGluZWFyaXplZCAxL0wgODU5NjcvTyA5L0Ug
		ODE4ODkvTiAxL1QgODU2NzYvSCBbIDQ2MCAxNDNdPj4NZW5kb2JqDSAgICAgICAgICAgICAg
		ICAgICAgDQoxNiAwIG9iag08PC9EZWNvZGVQYXJtczw8L0NvbHVtbnMgNC9QcmVkaWN0b3Ig
		MTI+Pi9GaWx0ZXIvRmxhdGVEZWNvZGUvSURbPDUxNjg2NjZEQjgxODIyNEI5OEVGNTM4RDBG
		QzREM0U3PjxGOTZGRDc0OUZENDUwRDQ1QjhCQTAzNUUxNzk1MTk4RD5dL0luZGV4WzcgMTJd
		L0luZm8gNiAwIFIvTGVuZ3RoIDYxL1ByZXYgODU2NzcvUm9vdCA4IDAgUi9TaXplIDE5L1R5
		cGUvWFJlZi9XWzEgMyAwXT4+c3RyZWFtDQpo3mJiZGAQYGJgYPIGEgw2QIJxM4gVDWL1AYnU
		W0wMjIvKgCyjn0wM/w//YALqmM70n4HxIECAAQDQhgrnDQplbmRzdHJlYW0NZW5kb2JqDXN0
		YXJ0eHJlZg0KMA0KJSVFT0YNCiAgICAgICANCjE4IDAgb2JqDTw8L0ZpbHRlci9GbGF0ZURl
		Y29kZS9JIDc1L0xlbmd0aCA2NC9TIDM2Pj5zdHJlYW0NCmjeYmBgYGdgYOJgYGBgtPViwAQs
		DBxIPHYoZmCIZhBgiADSxin1i6QN5zFxgQSZGRh9d4OMAuKPAAEGAJTEBiMNCmVuZHN0cmVh
		bQ1lbmRvYmoNOCAwIG9iag08PC9NZXRhZGF0YSAxIDAgUi9QYWdlcyA1IDAgUi9UeXBlL0Nh
		dGFsb2c+Pg1lbmRvYmoNOSAwIG9iag08PC9Db250ZW50cyAxMCAwIFIvQ3JvcEJveFswIDAg
		NTk1LjU2IDg0Mi4wNF0vTWVkaWFCb3hbMCAwIDU5NS41NiA4NDIuMDRdL1BhcmVudCA1IDAg
		Ui9SZXNvdXJjZXM8PC9Qcm9jU2V0Wy9QREYvVGV4dF0vWE9iamVjdDw8L0ZtMCAxNSAwIFI+
		Pj4+L1JvdGF0ZSAwL1R5cGUvUGFnZT4+DWVuZG9iag0xMCAwIG9iag08PC9GaWx0ZXIvRmxh
		dGVEZWNvZGUvTGVuZ3RoIDIyPj5zdHJlYW0NCkiJKuTSd8s1UHDJ5wrkAggwABNkAsYNCmVu
		ZHN0cmVhbQ1lbmRvYmoNMTEgMCBvYmoNPDwvRmlsdGVyL0ZsYXRlRGVjb2RlL0ZpcnN0IDUv
		TGVuZ3RoIDQ5L04gMS9UeXBlL09ialN0bT4+c3RyZWFtDQpo3jI0VzBQsLHRd/LV98svyk3M
		0Q+pLEjVd60ocQ8uSSxJ1U9OVDC0swMIMADgHgvgDQplbmRzdHJlYW0NZW5kb2JqDTEyIDAg
		b2JqDTw8L0JpdHNQZXJDb21wb25lbnQgOC9Db2xvclNwYWNlL0RldmljZUdyYXkvRmlsdGVy
		L0ZsYXRlRGVjb2RlL0hlaWdodCAxODYwL0ludGVycG9sYXRlIGZhbHNlL0xlbmd0aCAyNTYy
		NC9NYXR0ZVswIDAgMF0vU3VidHlwZS9JbWFnZS9UeXBlL1hPYmplY3QvV2lkdGggMTI1OT4+
		c3RyZWFtDQp4nOzdd6BcRdnH8d30hEASgzQhNAXktYSmgCAIogR9IYioVEFF6eUFIUhVARED
		AQUEfZFIh4CUkFekhi6ICkhRWkJCIsUkkARI3zd79+7MnDnPzCl3k3svz/fzT3L3zMyZveW3
		u3PmzFQqcb2GbbPXCRfd9uTMGgB0NTOfvO2iE/baZlivjCSLW/ekZxZ39jMBgEyLnzlp3ZI5
		N/Tghzq79wCQ24MHDy2cc/33vGVBZ/cbAApZcMue/YsEXe/j3+nsLgNACe+c0Dt30m3xZGf3
		FgBKenKLfEE38Lz0pYglUyaOuwEAupZxE6cuSeXV4jEDcyTdiMmJOs/cNuaIXTbqm/sdIQAs
		T3032uWIMbc9s8gNrskjsmqtcrVb/s0z11oeXQWADlrrzDfd8Lp6lWjpDaY5ZR/fv99y6iQA
		dFS//R938mvaBpGiTtLNv+Izy62HANAKn7lifp6sc5Luwvi7PwDoilb5VXbW2aSb+83l2jkA
		aJVvzs3IOpt0z318OfcNAFrl489Fs84m3XV55qQAQNc08LpI1q3STLqFR1Y7oW8A0CrVIxc2
		sy511eGa9iOvb90ZPQOAFtr69eb8Ou/AiOZ7uq06pV8A0EpbN9/X7Zx4eGDzbrAjOqlfANBK
		R7Zn2uTEtYcx7Y9eyzgdgA+CavPaxHnOg1u0r2XyHNdeAXwwrPh8I9YWb24e6t2+Pt1c5tMB
		+KDYuH0u8ZNmrc5R7W/0uEcCwAfHt9qT7YT2r/vPbr/vtVN7BQCtdWEj2t5p32/iG40v53OH
		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
		pb7p9jM31J+tXTH8pS4qqVuG/gWpp3N+3Q8dPiVztJHLMH6gGtA6+6D+cOSs1pBS6urfvPYJ
		YLufuhOb2/+y2nx+e8jqpu5Lzc2N97/FeeuOaH93nj38LFacuofXN91h5ob6U5RPt4a0Uze9
		x9ItA6l7Un3T7HndZ1TbpW6fWNXU3av0YIU513b6+dKoZfq/455kfU3HO2ZvqM/iPas1pJS6
		+u/O9uk0u5+6xza3n1dt7pxYt7qpu7i5uXESYPHEusabn53mnOK9J1P3YzM31L/Bn24N6aSu
		+uxlIHWNS+Vmb6gP3ErdPrGqqfuJ0oMNTm3znNKoZbps3IzX9bGbc2dvqCd1PKs1pJS661Wb
		22dd7H7q/ntz+3nV5s6s9aubus81NzdSd5/SXk9tf3fmnOK9EKn7r6WPbgdS15gnavYremG1
		Xer2iVVNXednZ0nv1d5L3lUatVxHjXqSH67u/xezN1x49ZIzW0Pmp25Ta8QeSt0Zm5ec1x6y
		D1N3t+pZbT56UtA9xfL2pbvusBCpmy7NgjqQuqfUN82eafP86sfHxxL7xKqm7talB+tcVdqw
		/rLSqOUat7h2fZj6r8d+XaXUHVJtvqg1Yg+lbsA+TN0IBy6d/XzZ28d9YYuRuqVLAgdS9z/q
		m9bsdE39pG4ZCou0TqcPHBh0VGnQsr1u4FFq9Xd0zFJmO5RSt6HafHFrRHrqqrPM3l9dUvLa
		wQGLkbqrdp0SM5C6xnVhtxz8itYcqVuGYur6l0fYqTh59bJ9dtSTrA8fXzr26yql7uBqc/us
		0fTU/d7SwFPuX3qJZi1G6pauXxtIXeMqkL3xK7QPSd0yFFPXvvqw6czSoOXbOOZJPr6+/7iD
		e2NSt5eO1Q1Y7NRVZ3g8uqrG8CneC5K6XXMVDqSuMQXCc4a+oLUnL3XHX9qvvExz5cjSgw3N
		9XBRadDyDf2dXLlPff+zx9x/Uk7dxmrzh1sj0lNXzRR31KS63n7wFO8FSd3WnfNqDl0D+1/V
		Td/cOPQVrTl5qStMHDK9Zv6DHVl6sIHZ0DfuoROIt3vumFfkoMaEa/2L9nXMP4W4fU5feOpu
		uTTuyv0m71z678FTvBckddOn7rhlKHXvqG/78541P9YuqVuyZf6DHVl6sIHF4B9YGrMbulOl
		93lfY8Tpo1bfKaXuztXmN7dGhKeuOnb/0cmkWjWzPf3xjEVJ3c61zYZS98TGvT/5Y+1b1zCp
		WzIidYXlXEtTp+/w3NKY3fDtUScR/15zyNeeOXx97g6l1NUTxbdX9Q5P3cuWxp02mTx06b8H
		T/FelNTtHDyUuls1/wzZ8sa7j579etGt9dTdqe/bud3eSF3xFOI7l8e8uzRmd/QtmNpxw9lJ
		I68594HzCllK3VOrze0FZcJT97GlcY+dTG5e7WToLdA+Tl119t/OGaAG15ZozZm96YSeJWbX
		orWeurtPC5aduq3zH6x4YdgPFYcUJ2nfLb1LsXd0Zmz/8rOGV3kqpG79p6rND2iNyE7ddaup
		6O86mayrjuMPneK9j1P3qOrH8Mvb/90bTN2Dpi1Xvv7o/x/e2q311BWvwN8bqbt3YejAfHV3
		KA3ZLW8Y9ZrcrLvk35Z3/kJ5Qt1S6hqr8d2gNeIR9QpdF17QdqfOA+zZ1F1TueV12rq/k3sh
		dT+zNOwH24/b/+3S/w2d4r2PU/fw+pSne0/mpG7dX3V+fKYXPGnjwNNeG9Z66h7Q/bbstOzU
		XTv/wR5cGHp1+R+9x5We325pr3Fa8Ji+sV995o1L9+9P3S3rhQI7c+wOrgN7j/a999q7uq7u
		n/h7IXW/vzTsk9v/r7oOfugU732duvoUpO1TDw4veX3EZT0v7NVvKE9Tujas9dT9Rv9P/MDh
		s1LqWtNz9Sn9gg+ckveGwpDd1H531W9d/2chV55cOOrSl7oDTmwsRtE5jyI7decuDdvxPq5+
		89tZLre2r1O3/ktL/3nZgfNSN/mZ7/S+tn/dfbu+lqz11PUvsbpN8ejUE0oj5l/y98TCyE+V
		h1xcerTdM3QFWtMz+4f/x0N6791I3WnH7/CEVzTXqN5yi/aI6NStu3Rp2I55Rm9T7WXgTPJ9
		nbrGinHHzE3d5OjLel/cLS9qL6u5lqz11BUWTZ1Oi2c//lppxF3nPlhp5rm/Ko44rPRgu+mP
		xr4uD76kfwfP7ftb+3b99628qTMiOnVHVsN+avv/rv/20v8+rzxmn6eu/h6fOz91kyPf2//y
		fnjcnxULaa2n7tP935Lp5cURDyuMmD5q7oOVuvqy4ojS0b3XvXqOwrvBeYtr1w47c0vvHk7p
		ue+c1F3dXTcrOnXV8uFbdx7zqFbIGDjFe5+nrj5B5vuHzU/dZP0J9QViTZ/ZOPD0F9saT92G
		/t/n6fSLxSE/VxgxffXcR3t/YeRvF0c8v3/AN+Z+eP+M/oHfHfgcte2Hz/h+3y7ai8BO5qau
		XYhJeOpeuTRq1+cQf7z0/wOneO/71NWLRjx+ROomk4N/99+nPf5u3FzYC2iNp+7hfd+N7TrL
		slSKJ8fNXWh1v/6jtdPpg4tD3tM/4N1zv7DSJ8sDJyt3HXFSz0/r1T/Sud9w6vp+uKNT94ml
		UW/Z+f+/PvDoS/Z96m5UvaIfHJW6yeTAx3y05xV+ysDzX2hrPHV/1vO92OEvi0OuXxoyvfWc
		B7tLaeBtSyNKceysZd9x48JDPXHuyBn7H9ON7Ts69xpM3af7PrZNTt1B1VPbee1849zJ3yoO
		2vepq+clmN5qXOq2ufMZ322/wt/eODhica3t1N30e+1vxJKB0zn/szSmfaFn2/8ujLtq/9KI
		Hy+MeGRpQO2r/SO7nxDM86Onts4o3tr5PHUodecf3rfT5NTVJ5Lfb+eG/a9a2vDG4qAFSN0j
		qv/7w9Gpm0wOPfHC1kv8O3NGLKq1nbqXFn/kB2bU+VBpzLeGz6zb718L48p/LJdObBlxMdU7
		+0d+Yf7IjoOO3zSzj99t32Egdadft3eXx15RueMhbd3jiXs0dY/518rnO7pvsPd46p5ejdq4
		a0t1xL98ivcCpO66ly3930WNvxnmX2u47t5v39r8keisTr5GrOnU/UjxTV15Ac/m2r1tzygP
		2ua40rBXFYec1T/g8hGXFP6v/qHTG80f2rXumC83dtGZbaiYuo+UFgdMvgb2vKVBm5e2/Em1
		n+K5GAuQuslrqv9tLE086rLq29VrM02n124cM2TxrOXU7decmW3WdwbOdSwma3r10NG6g75Q
		GvabxTH/3D/g/SO+uF8sPFj/ScBzHdx4l/id9ucM/an77Kndv0SXBKduXXUA5JylTfXVf8VT
		vBchddWlu9M317eMm0FiXfPvk6E5txfYwqduw9l/WHoP9MJpUfmk3snkpuVh7x74JL38x/Id
		SkNuWBjQd25b280KY18wYmyfQxvnFLfPk2uk7uxnb/e0Jz7q7oNLJQSnrl4h85lLm+5WbSqe
		4r0IqVu3uf3DNB2bupkrHJ82csiCWfTU3foz0+mr+698+IP2d63hyUP7HFjt4bTin5bFi22n
		lxbHlN6ZPXrMV/4f/WOHflMG1ZPPTX+udVNpvrqy4NTVV9tU724OrJ7s+0qjFiF1k+d1fprG
		p67x1M4YOWTBLHjq7r/j08OP9vxhuf/Ler5vlcGl1k8ZGPiyQrd+85rikPLMSi/YnWe35G/6
		x15R/Lh3jrvW+2j/xS11y0jdadWgm1Tbqmt2iqd4L0Tq+mbRHpu6yb9UQ0Yvpb5YFjp16/7n
		ro9+rvi99hu7I0tXLuzwb4PH/YszF2/3jh/uGXG9Vw2M+NXiAxWe4xWjLnn4o/7BIy7V7ddY
		9e73WzdJ3TJS98mlMT94SaU+Jls6xXshUjc5v/PTND519YHxj40dslgWOXUbGicIf+HXm7G7
		wfOu6H7TGuZMYflPQ2O//+L2x2jXO6H3Epldtt6w9DD7F57kR0Z99ccUHu/EUaO71l1Z7eKF
		rZukbnzqipci7lQ6xXsxUndC9wmPTl39Yu3OCU8LYIFTt/0wXcOlL//5jTu23+Q3zu29uLOh
		dI7ELk8aHr31/JPuediuDygOu9uJ53ROGJ/xnuLDlK6ueMWoL/9WhdF/Omp0j0uKT0Dqxqfu
		vuWfhO1Kp3gvRupu8INp2+jUvbwacsnYIYtlcVN3/+604dNLL/r4P17a3dw279D99S+bv4+t
		X/vcP130ryNWhjiu+DA9/4buUD45pWndN/pH/8syXsMZ9edvr23dInXjU1eYh2FJ6R3PYqRu
		8hedJzw6dS+phnxr7JDFsqipqw7T7Y77zdv7Sbu/77bL+i8n2O7NhSEjJ3P9u8Lw3iu1Rqgv
		9mhfNSd141PXs/DCjMKs9guSuu5RkdGpO7kacvnYIYtlQVO3oXgd/wgfmnsxwsY9t47XaeVH
		+Zf+Ed8bOZXriwuP+LDBUXc7s9JaAbZO3etbY/ZZ6v5405K3tIfsw9TduXpWm+7e3tu6rw/9
		MGzz0P5nsSCpO7Dzp1I7da+tfnx+cfaGOnXfHvgKFthipq51mG6Z2qeN9ThpJftvuvao4mMc
		Xhjy8ZEvwrGF8S8eHFVf1D293ewtX6puOL01Zp+l7rzyi7IPU3fPekTnoG9x1fMl7Y98dlmQ
		1DWuYdulnbp6wetnzd5Qn0L/9YGvYIEtZOr6DtON95ERV5geXLp0f7k670Zqv1QY8icjX4Xb
		FMZ/cHBU40+UVuq+Ut3QnjV5AVLXOYFhMVJ37/be6rnpCgolW5TU/XT7+bZTVx83aqXu1OqG
		fxv4ChbYAqZuRYfptrn/mAf5hRU9RGVrcaq6yeRFhTGPG/k61GsWzLpq8A/gxq9E60zlegbt
		Z7fGrGbqHtvcfl61+R/aQ1Y3dRc3NzdS15k1ovOuqO3K/lO892TqZi9EPKfa/unWkL7UrWsf
		VWmnrj6XpvVTUn/l7cdZIxYvdSs6TLfNWeNWIn/Hyh5ll6Hp4/6+MGb0epofKOzgbkODGu8l
		j565YX39Q9yec301UzczOf151ebORFirm7qvNDc3Uvcz7b1tKnxPav3f3hWnrrFKyU/N3FCt
		uN15Z9yXus6MOe3U1aejtKZvfHt1Q/n0qoW2cKlb2WG66fQz85dz3eHwESetzHXZwO/a/lf2
		j/nBgWNfilP7dzCwlMU2jfl5HjNzQ2Pxsge2xuz11B1a333mWFZ9Bn7nr/LVSF09q9H3mu/F
		HlSPaM/tckj1B8fWY3+lqf5KntT7LFacunrN6ka3tttUbW9fgNubunq2gp3aqas/sHvn7A31
		V3jmwFewwBYtdSs7TDedXt5dOaHgviv7M3mH4wf2X1rDYmDR2JbSMo5vGxrUmPj4rJkbGu9V
		2nXa66nbv757c7K8A75ZbX5ne8hqpO5l9U3NE4Aab3x+tDXiZ6tbLpy9oZ5Mof/o7YpTd9v6
		ppOb2w+t36yf3RrSm7rJR6Yz2qmrpyr71sy/yfXit9M/GPgKFtiCpW7DV6YrM3wmxozCstDL
		8O6hv5V/uzBo/L+Jty/s4UtDgw6u73fVzDlep1fbh+ar2zupa0xy//3GUhWPrvfSmddqNVL3
		tPqm59Rb96/nut/SPixar7DeOnRx3+qGzZM+K07dAfW/zF9tNqixDPvzW0P6U/db0xnt1P11
		fdPMqe6NhfbMV7dH3LYwd9FI89enqa1/64oeajr9z1sO7b609xNGP8H9Shf63nRoVGNl3OZS
		B3esf1X+vj1k76eusfRUfbT7Oo1jFZ1rTlYjdY1D/f9RH/do7L/zDrwOQWvhrOvXg3pP8V5x
		6iYX1Lc1ltY+ovH78sutEf2pO2z2qsp26p5d33RJ41+l/Rrfq8JZ0otu0VI3Oaq4ys0I71/W
		DEcH/O38PQ646icH9146neXowVEzPlLYxTFDg05u3PEZ1dvOwxsF7Ky7sfdT98r6/lf/9K5t
		B9UHuqfXduq9GqlrXmb8p0sv1YMa/8C0F1ZqXKzX/mz2i9UtvX9YrDx19TWojc7evLnGTXve
		if7UtT6Qa6fuHo3bPni9pa3rG48+dxHRBbVwqZvcujix+VyblvnvzSEfm7/Pomvb/4jOuklh
		2NaRH5ts98rCPk4eGjSzStkHHrJh+7brP6t5eUgn0ctP3TEfrZzwa12dFv9y4+GvPumHtm3Z
		+OjmDKndKS1XI3WT5rS8H/r5A7b9St/9T65tbGt/mlofMLv2eq2b6m73nuK98tTVC5Vtc8aO
		qcYOeFhzyp3Oa1hI3cOaO+qkbl1zkYBLTtzxh8t+D28WdfCnb4EtXuomN+pbaHeM8zcu96Gu
		/4HdfKjpnImOy4txXzg8bMbxhX18eHDUB2fuu+XSz16wufnrO/185wjjit7V9flq+/4bZs8R
		/Mbn/3l2LqTuapGrkrrZKfu/9+ULvzmz4R/br1T9DemsDVavI/ahvmex8tStu3jmuX3+ggsu
		mH22j2qPKKTugJl5JDrXwLaOMX/rCxd89uqZLSMv4V44C5i6yUG7dxDtvYcs/6EO/PP5++21
		pfOj2PKSwsDlLORaWkb26v4Z6He535yn/tTOiL2fuuIb1J0+152sdFVS98PDn8J3rmetz07p
		fApen+TTe4r3ylM3edTgc+15DQupa8yjPO1J3XWHJmecDi0FuuAWMXWTdU8uT29e9PLB3/+S
		/YZmXy+7qrg01JIPF0YuZ8Hg65QWfywv5bXd2wujdvrahs6AVUjdEYWzDHd6QPcRViV1jXb1
		eE/n7W/90UB7IufmkkmdOQImeyR164f/2un+RJZSd3RzWHdmk0cOPkznpMw1YyFTN5ncc84/
		LR1XHLu7D/WQwrxwQ77Y99M844CrC0MHFqjt+nhhJ08ZHDV8dnTPbHmrkLrGH3hd7ZlWtlud
		1B0+MFHJtztT7x9aHwj42c6u6pV2+w5t7IHUTW47NPX2Wd37l1I3czium7p1g5cr/c24i5EW
		0IKmbnLDc0qvda/zR61M0+/m5eVkC86c/6fyTxaGdg5nDzq9sJc/Gx52r/JS4NO/7PlRXY3U
		7Ve6Tm463dT3cq5O6lrH6Jt6PnZqXIlyWOfGc6vb+k7x3hOpmzxs5pjrjE/1fNpVSl3zhJK+
		+eoOvaCz+8rXbzHw9BfboqZusu7XC1e797j8iQPrt454qEcv6z3kpWNOU/6dwuDO4exBjy/s
		5Stzxj28O7H2Lp/uS+1qpG5yo8L0fdPNR/Q9wiqlrnFScEvP5XfPqZ/z0I76TvHeI6mbPKa0
		sMVFN+m5dzF1P9QY2Tc15xGlb9X06nsOPPsFt7Cpm0yOnDfh6y5b3jDmJ37QIS+4atxjTaff
		eXb3WFePswvDBy/q6rhbYS/T3jo03L/w78Q/9K75syqpm9zi4t77Xnjz3kdYrdSta1//vtOW
		3+q577uqm8/p3ti4Hr/nae2Z1E0e/J3eZ/v+G/XduZi65of0vbMQ3+QTvQ8zvXzOoi0LbYFT
		N5ncp3Ssqvkz+cZR57DOc+PnfXPuQ21z1ctHnrr35cIOlrcy+oGld2dzi3Tr3mPYp/Wf1Lc6
		qZts7JtN5s2FfzlWK3WTybE9/yz8+3177rj+sur2Z3RvbZxI2XPG5R5K3eR2/9h9stc8t39a
		r3LqHlff0j/h+oEv6/tb+RMDU5YtvoVO3WTdIwcOG2x36Uv2SOi22/Dbg2smbvfJEzaO3NkR
		pV38t+U9qU8VdtO5ZLRj/fGdyzU+Xvo3eZVSN1l3zD+37nhx8ZPs1Uvd5GZntf4u/P7LD+27
		31H1Pfo+hqyPgrQvspjsudRN9n9i+9LJ80oTYZdTt7E+mFtaW+KunaVN/uvJI1cKWFCLnbpt
		7vSCze3XfMk3z37QqMWjR7vtSZ8rPdZ06ydOvsv4PT2itJvu4exBryvsZszJTfv/yjsbH098
		/U33KX52tlqpm0z2e+hb63fPW9/7q+Xv3yqmbjI58qTGdXP//sLCtc2Pre/Td51rfbylZ6Hf
		PZa6be+4jntXfRnr5peW32mVU9f4tS8vo3PXVzWi+r33/eYyLvNZSAufum3vBe7x9Ld9rnWu
		55bN5/7Oj6/os4iCmx37qk3t80Su/er7T33o9eePbTj8Lv1+fJlP56aF/dxx3PDr3vvEU15/
		9htPe/aj7jj0Yq0/uDLyIuL9Dx500NCD/dhxzzn9LW89/ZkPG8z+hkr7fMnr1DeN+QlYV999
		6F3JYfd/yilvPPsNL33cnYr/IhxQ76nv5gOrW3uicFB14+BrUz/C4Ddiw/2e8oo3ve3M5z36
		NkOnfgzsrf5Shl6Tdbf/jee/5q1/esaLHnfvoWe9RqyB1O1w8NHHPv5pz3/F608/5XlPf8ID
		f2SvvpVef/P7Pvbpzz/1Na9/1Yuf89QnPOSo8vKHwBqxVlIHsAJSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		AKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVAAKkDAkgdEEDqgABSBwSQOiCA1AEBpA4IIHVA
		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
		XHXtP7D7HLg62bF0W1r3/Prx73A8gP/d8evP36R0W1o3mdw57fsmgN1i7+k7m/r1jaX78ujv
		xqbnTp5c8p2JwG5w8NKTzfG6seN7cMuPNj9/7f7q5bPLRxzeAW+nvUeWz15evf+vzeF69Oo1
		Eq+zdGVt8qqXn9y++UeAt8vN25++3NartStveG7wsbvbfhdgd7j75l8Jtnj+s7GnBfgWPruw
		uHPivrZvZfXFzn8U4C3yxerKvp3z9or9Zz4ae26AN/bhmf3/decGhy8+2P4RBcDbZu3BxcPf
		snODxUMnT124duve07H/E4Btnt67de3CqZOHdnyD7t87BLOsDQplbmRzdHJlYW0NZW5kb2Jq
		DTEzIDAgb2JqDTw8L0JpdHNQZXJDb21wb25lbnQgOC9Db2xvclNwYWNlL0RldmljZVJHQi9G
		aWx0ZXIvRmxhdGVEZWNvZGUvSGVpZ2h0IDE4NjAvSW50ZXJwb2xhdGUgZmFsc2UvTGVuZ3Ro
		IDQxMzk3L1NNYXNrIDEyIDAgUi9TdWJ0eXBlL0ltYWdlL1R5cGUvWE9iamVjdC9XaWR0aCAx
		MjU5Pj5zdHJlYW0NCnic7N19kFV1/cBxzYXdQLEQrERBRdRfoQKiP9HGIdBmCKWUfOAZNU3U
		ZjSoMJ/40Q+dFM0G0sFfPARUFDYNIqmDIovZgzPNkGRlU2rOYPZA9sBgpMLvGzvjONzdu+fe
		e87e/ey+XvP9w4G753zPd+9dz5u995wDDijWQQcddNSRA844fcQF558z6/IL531+yuIFM9Ys
		mvHYsslPrb7YMAzDMAzDMAzDiDVSzaWmS2WX+i5VXmq9VHyp+1L9FdyXRRk0aOBnrpz43cUz
		mlfVf3kNwzAMwzAMwzCMokeqv9SAqQRTD9Y7STPp27fvtEvHr7hnZt2XzjAMwzAMwzAMw6jX
		WH73zNSGqRDrHamtaGpqmvCxMYv+d8bmlZfUfaEMwzAMwzAMwzCMzjBSIaZOTLWYmrHe2fof
		DQ0Nsy6/YOPySXVfGcMwDMMwDMMwDKNzjtSMsy6/MPVjHet1xPCT1iyaUfelMAzDMAzDMAzD
		MDr/SP2YKrLj07V379433TCpugs0bVl18foHpi1bOPMr82d85X+mG4ZhGIZhGIZhGGHG/Bmp
		5h56YNqWqnowVeRNn52UirLD6nXsR85ct2Raxrl9d/F/rq6cZnjZ1AnnjDnr+CGDe/bs2WFT
		BQAAoAip7FLfpcpLrZeKL3Vfqr/N2ao2FWXqyqJn2L9/v7tunZ5lPo98fcqcay85csARRU8J
		AACATiI1YCrB1INZsjHVZWrMgmZy3OBjH/6/qe3OYdW9My664KONjY0FTQMAAIDOLPVgqsLU
		hu32Y2rMVJq5T6Dden1y5SVfvmX6qcNPzn3XAAAARJQKMXXik2Vvt5p7w7Zbr7d9bkpxv/kF
		AAAgrlSLt86Z3DENW75eH19x6cfPG5vLjgAAAOiqUjmmfiy0YcvX69qvTT/h+ONyORYAAAC6
		ttSPqSILatjy9Xr3vOkdee8eAAAAoksVmVoy94bt379fW/W6eeUll0+dkPuBAAAA0B2kotzc
		xpWdUodWcYWlhW3c73XD16ecftrwIg4BAACAbiJ15YY2bhd7163TK9rU2I+c2dbvXk8bOayY
		6QMAANCNpIZt6/ewY0efmXEjvXv3XrdkWqsbucw7hwEAAMjJ5VMntNqeqUkzXnPpps9OanUL
		C2+r7Ne4AAAAUF5b13S66YZJ7X7tiOEnNa9q/Y45rjkMAABAvg4++OAH75tRGqGpTIcPG1rm
		CxsaGtYsauULH19xqfu9AgAAUIQTTxiSqrM0RVOfpkpt66uuueLCVn91+/Hzxnbk5AEAAOhW
		PnHe2FZrdNblF7b6+Kampo3LJ5c+/rbPTengmQMAANDdpPYsDdKNyyelVi198ITxY0of/OTK
		S6q4hywAAABU5PDD+z/Z2l11JnxsTOmDFy9o5dOvX77FlYcBAADoCHfe0sodXRctmLHfww47
		rG+rN5A9dfjJdZk2AAAA3c3IEaeUZmlq1b59+77zYdMnnVf6sFX3zqzTrAEAAOiOVt3bynuD
		p106/p2PWXFPK4/55Cc+Wq85AwAA0A1ddMFHS+N0xT0z337A0UcPLH3AI0unNDY21m/WAAAA
		dDupQ1ONlibqoEEDWx7wmas+Wfq3c669pL7TBgAAoBv63HWtXKDpM1dObPnbtV/b//3Dzasu
		PurIAfWdMwAAAN1QqtHUpPtVaurW9FcNDQ1bSv7qu4v3v0wxAAAAdIxWf82a6nXgwKOy3GcH
		AAAAOsbiBa1cZ3jgUUeO+u9TS//8phsm1Xu+AAAAdFM3fXZSaaiecfqIiR8/t/TPZ045v97z
		BQAAoJu6bOqE0lC9cMI511xxYemfj/3ImfWeLwAAAN3UOWPOKg3VWZdfOO/zrdxhZ8hxg+s9
		XwAAALqp44cMLg3VVK9fu33/z8ZuWXVxz5496z1fAAAAuqnGxsbS2+UsXjBjzaL9A3b9A9Pq
		PVkAAAC6tYcemLZfq6Z6fWzZ5P3+cOlC99ABAACgnpYtnLlfqz66rJUPwH5lvoAFAACgnlKZ
		luZqKwH7P9PrPVMAAAC6tVSmAhYAAIDOT8ACAAAQgoAFAAAgBAELAABACAIWAACAEAQsAAAA
		IQhYAAAAQhCwAAAAhCBgAQAACEHAAgAAEIKABQAAIAQBCwAAQAgCFgAAgBAELAAAACEIWAAA
		AEIQsAAAAIQgYAEAAAhBwAIAABCCgAUAACAEAQsAAEAIAhYAAIAQBCwAAAAhCFgAAABCELAA
		AACEIGABAAAIQcACAAAQgoAFAAAgBAELAABACAIWAACAEAQsAAAAIQhYAAAAQhCwAAAAhCBg
		AQAACEHAAgAAEIKABQAAIAQBCwAAQAgCFgAAgBAELAAAACEIWAAAAEIQsAAAAIQgYAEAAAhB
		wAIAABCCgAUAACAEAQsAAEAIAhYAAIAQBCwAAAAhCFgAAABCELAAAACEIGABAAAIQcACAAAQ
		goAFAAAgBAELAABACAIWAACAEAQsAAAAIQhYAAAAQhCwAAAAhCBgAQAACEHAAgAAEIKABQAA
		IAQBCwAAQAgCFgAAgBAELAAAACEIWAAAAEIQsAAAAIQgYAEAAAhBwAIAABCCgAUAACAEAQsA
		AEAIAhYAAIAQBCwAAAAhCFgAAABCELAAAACEIGABAAAIQcACAAAQgoAFAAAgBAELAABACAIW
		AACAEAQsAAAAIQhYAAAAQhCwAAAAhCBgAQAACEHAAgAAEIKABQAAIAQBCwAAQAgCFgAAgBAE
		LAAAACEIWAAAAEIQsAAAAIQgYAEAAAhBwAIAABCCgAUAACAEAQsAAEAIAhYAAIAQBCwAAAAh
		CFgAAABCELAAAACEIGABAAAIQcACAAAQgoAFAAAgBAELAABACAIWAACAEAQsAAAAIQhYAAAA
		QhCwAAAAhCBgAQAACEHAAgAAEIKABQAAIAQBCwAAQAgCFgAAgBAELAAAACEIWAAAAEIQsAAA
		AIQgYAEAAAhBwAIAABCCgAUAACAEAQsAAEAIAhYAAIAQBCwAAAAhCFgAAABCELAAAACEIGAB
		AAAIQcACAAAQgoAFAAAgBAELAABACAIWAACAEAQsAAAAIQhYAAAAQhCwAAAAhCBgAQAACEHA
		AgAAEIKABQAAIAQBCwAAQAgCFgAAgBAELAAAACEIWAAAAEIQsAAAAIQgYAEAAAhBwAIAABCC
		gAUAACAEAQsAAEAIAhYAAIAQBCwAAAAhCFgAAABCELAAAACEIGABAAAIQcACAAAQgoAFAAAg
		BAELAABACAIWAACAEAQsAAAAIQhYAAAAQhCwAAAAhCBgAQAACEHAAgAAEIKABQAAIAQBCwAA
		QAgCFgAAgBAELAAAACEIWAAAAEIQsAAAAIQgYAEAAAhBwAIAABCCgAUAACAEAQsAAEAIAhYA
		AIAQBCwAAAAhCFgAAABCELAAAACEIGABAAAIQcACAAAQgoAFAAAgBAELAABACAIWAACAEAQs
		AAAAIQhYAAAAQhCwAAAAhCBgAQAACEHAAgAAEIKABQAAIAQBCwAAQAgCFgAAgBAELAAAACEI
		WAAAAEIQsAAAAIQgYAEAAAhBwAIAABCCgAUAACAEAQsAAEAIAhYAAIAQBCwAAAAhCFgAAABC
		ELAAAACEIGABAAAIQcACAAAQgoAFAAAgBAELAABACAIWAACAEAQsAAAAIQhYAAAAQhCwAAAA
		hCBgAQAACEHAAgAAEIKABQAAIAQBCwAAQAgCFgAAgBAELAAAACEIWAAAAEIQsAAAAIQgYAEA
		AAhBwAIAABCCgAUAACAEAQsAAEAIAhYAAIAQBCwAAAAhCFgAAABCELAAAACEIGABAAAIQcAC
		AAAQgoAFAAAgBAELAABACAIWAACAEAQsAAAAIQhYAAAAQhCwAAAAhCBgAQAACEHAAgAAEIKA
		BQAAIAQBCwAAQAgCFgAAgBAELAAAACEIWAAAAEIQsAAAAIQgYAEAAAhBwAIAABCCgAUAACAE
		AQsAAEAIAhYAAIAQBCwAAAAhCFgAAABCELAAAACEIGABAAAIQcACAAAQgoAFAAAgBAELAABA
		CAIWAACAEAQsAAAAIQhYAAAAQhCwAAAAhCBgAQAACEHAAgAAEIKABQAAIAQBCwAAQAgCFgAA
		gBAELAAAACEIWAAAAEIQsAAAAIQgYAEAAAhBwAIAABCCgAUAACAEAQsAAEAIAhYAAIAQBCwA
		AAAhCFgAAABCELAAAACEIGABAAAIQcACAAAQgoAFAAAgBAELAABACAIWAACAEAQsAAAAIQhY
		AAAAQhCwAAAAhCBgAQAACEHAAgAAEIKABQAAIAQBCwAAQAgCFgAAgBAELAAAACEIWAAAAEIQ
		sAAAAIQgYAEAAAhBwAIAABCCgAUAACAEAQsAAEAIAhYAAIAQBCwAAAAhCFgAAABCELAAAACE
		IGABAAAIQcACAAAQgoAFAAAgBAELAABACAIWAACAEAQsAAAAIQhYAAAAQhCwAAAAhCBgAQAA
		CEHAAgAAEIKABQAAIAQBCwAAQAgCFgAAgBAELAAAACEIWAAAAEIQsAAAAIQgYAEAAAhBwAIA
		ABCCgAUAACAEAQsAAEAIAhYAAIAQBCwAAAAhCFgAAABCELAAAACEIGABAAAIQcACAAAQgoAF
		AAAgBAELAABACAIWAACAEAQsAAAAIQhYAAAAQhCwAAAAhCBgAQAACEHAAgAAEIKABQAAIAQB
		CwAAQAgCFgAAgBAELAAAACEIWAAAAEIQsAAAAIQgYAEAAAhBwAIAABCCgAUAACAEAQsAAEAI
		AhYAAIAQBCwAAAAhCFgAAABCELAAAACEIGABAAAIQcACAAAQgoAFAAAgBAELAABACAIWAACA
		EAQsAAAAIQhYAAAAQhCwAAAAhCBgAQAACEHAAgAAEIKABQAAIAQBCwAAQAgCFgAAgBAELAAA
		ACEIWAAAAEIQsFC1Aw88sF+/fqNGjZo8efLVV189e/bs22677c4771y8ePHChQvnzZs3Z86c
		WbNmTZw4cejQoe9+97vrPV8AAIhNwFKLxsbGE3ISpe+OPPLI6dOnL1++/Jlnnnnttdf2ZrZn
		z56XXnppw4YNqWpHjBhx0EEH1ftQ6qZv375VP0+OO+64ek+/Ixx88MHjxo2bO3fu0qVL169f
		v2nTpi1btqQnT3ri3XjjjWPGjMn99TJkyJD/Kt6xxx5b9QzTmrS12X79+uW4FG/r3bt3jsfS
		1NRUfnEOOeSQijaYjrqixT/mmGP69Olz4IEHVrSX3L3nPe9pa4bpr4rbb/rpUdFyJe9973uL
		m8/b3v/+91c0q4EDB6bXQt2/jy3SD/MLLrjglltuWblyZfoBtXnz5ubm5vQfS5YsmT179qhR
		o3r06FHvOdZqwIABbX0vCjq6I444oswToNIfd+973/vKbC29Liqd3uDBg7M/XU888cQPfOAD
		6Vyx0r1AeQKWWgwdOjR7wZV35pln1vto2pROFT784Q/fd999zz//fF7H+9e//nXNmjUpUhoa
		Gup9fB3t/vvvr3rd3nrrrXTyVu8jKMq73vWu888/PxXrG2+8UX4ddu3atXr16vS0zGvXr7zy
		StXflOx+/vOfVz3Da665pq3NLlu2LK91eKexY8eWOZbdu3dXFDgnnXRS+cVJ3/qKpvfFL36x
		im9Bemq9+uqrzzzzzF133TV+/PhDDz20wlWp1YIFC9qa25e+9KXi9pt+5FaxXNu3b9+4ceO9
		99571VVXnXXWWanXcp/Y4sWLq5hYevql1+zTTz+d1vPcc8/t3bt37hMro2fPnlOmTEm5umfP
		nvLzfO2119L/OtOTvyOnl6+f/OQnbR3d6NGji9jjihUryizpgw8+WNHW0iu9/Deo0un96le/
		Kv9Nb9XOnTtffvnlhx9+eM6cOSNHjuyGZz7kS8BSiy4fsIcddtj111//y1/+Mq/DLJVOkO64
		447BgwfX+1g7ztatW2tZsTFjxtT7CApx9tln/+xnP6t0NZ544olTTjml9r13/oBdtWpVW5tN
		J1S1r0Cp8gGbXHnlldm31kkCdj9vvfVWOh8eNmxYZUtTg02bNrU1mccff7y4/VYXsKXSK2Xu
		3Lk5voWmuoDdz7///e9ly5YNGTIkr1mVMXHixN/+9reVznDt2rVHH310B0wvX01NTWlt2zqo
		G2+8sYidlg/Y3bt3V/RehU4SsPvZsWPHrbfeWuibLujaBCy16MIBm9L17rvv/te//pXXAZb3
		5ptvLl++vDu8P/aQQw5J58y1rNXNN99c74PIWY8ePe65555anjy33357jW9m6/wBW/6cuYh3
		e7YbsM3Nzdm31jkD9m3r1q3rgPxpaGjYuXNnW3P4xz/+UdxnK/IK2BZPPfXUMccck8vEcgnY
		FulH6+rVq4844ohcJlaqT58+3/72t6ue3q5du6677rpO8ubnjNKZSZkjeuihh4rYafmATT71
		qU9l31rnDNgWf//73+fPn9+zZ89K5wACllp0yYDt1avX3Llz08/VvA4tu3T68Y1vfOOoo46q
		9xoUqN0oaNeGDRvqfRB5SueEGzdurP3Js2XLllre39jJA/bwww8vv+Vx48ZVfextyfJcHTRo
		UMatdfKA3bvvVPbcc8+tfJ0qMGzYsPJzOPnkkwvadb4Bm/zzn/+87LLLas+xHAO2xfbt20eO
		HJnLor3TgAED0uu39ul95zvfaWpqyn16BZk9e3aZY/nzn/9cRI+3G7CbN2/OvrXOHLAt0v+8
		+vfvX+k06OYELLXoegGbTllffvnlvA6qOjt37kz/0+wC175o1c0331zj+uzYsSPWv+GX0djY
		WOYdlZX6xS9+UXXDdvKAnTBhQvktz58/v7otl5ElYLO/h7DzB+zeff+Gdu2111a+VFnNmjWr
		/AQ+/elPF7Tr3AO2xfe///0az71zD9jk9ddfv+iii/JaugP2vSUpx4/SPPHEE1F+6fbggw+W
		P5Yi3jfVbsAmAwcOzLi1zh+wyUsvvfShD32o0pnQnQlYatGVArZXr15f/epX8zqc2j377LOn
		n356fdekCBs2bKh9caq4cGLntHTp0tpX450ee+yx6t6E2ckD9o477ii/5Y0bN1a35TKyBOxz
		zz2X8Z9TQgRsi/POO6+qBWvfypUry+86nboXtOuCAnbvvnPvWq4KXkTA7t33qdjTTjstl6VL
		P1JScuY7vSVLluQyt0Kll/b27dvLH8j06fmfHmcJ2C984QsZtxYiYJMXXnjBR2LJTsBSiy4T
		sB/84Ad//etf53UseXnjjTduuOGGLvPbxgP2nQ/s2LGj9pWZOXNmvQ8lB5MmTap9KUql05Uq
		JtPJA7a5ubn8lov4+GTGt7sPHz48y9YCBWx6kWb//U5F2r34z/PPP1/Efg8oMmCT9IO66okV
		FLDJiy++mMtnw2t/20yrrr766trnVqhBgwa1exT3339/7vvNErDbtm3LeG4QJWCT733ve13p
		hIdCCVhq0TUCdvTo0RXd0bWDrVu3roh7N9TFCSeckMuahPjX+/IOPfTQV199NZfVKFXFq6kz
		B2yPHj127drV7sZz//hkxoBduHBhlq0FCti9+65PlfuZZLsfZG5R0F19Cw3YP/3pT1Xf3qu4
		gE2+9a1v1bhugwcPLuhihrt3787+EfK6uPTSS9s9iq1bt+a+3ywBm2S8/nyggN1b4fWp6M4E
		LLXoAgE7derUMhfJ7yR+85vfRLwBQamZM2fmsiDbtm2r96HUat68ebksRaueeuqpSuujMwfs
		qaeemmXjuX98MmPApqXL8svfWAGbnH322dWuXOva/SBzi4LewFxowCbp21HdxAoN2D179tR4
		cenVq1cXN73i3jGeiyyfKiri1uQZAzbjm21iBewLL7xQ3KXI6UoELLWIHrBXXHFFXvMvWjpJ
		Lu76nB3mgQceyGU10llZnz596n001evVq1fGt1Kn7/ujjz66YcOGH/3oR7///e+zL1GlFbBy
		5cqH2/P0008/07Yf/vCH7W5h0aJFVSzXddddl+WQcz8Zzn7F7HPOOafdrXV8wL5z5dNTqLm5
		+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
		1nDKdMb1LOMU7tvb21xfj8fjLOPDw8NqtZok+d8fGQAA2gQsAAAACQIWAACABAELAABAgoAF
		AAAgQcACAACQIGABAABIELAAAAAkCFgAAAASBCwAAAAJAhYAAIAEAQsAAECCgAUAACBBwAIA
		AJAgYAEAAEgQsAAAACQIWAAAABIELAAAAAkCFgAAgAQBCwAAQIKABQAAIEHAAgAAkCBgAQAA
		SBCwAAAAJAhYAAAAEgQsAAAACQIWAACABAELAABAgoAFAAAgQcACAACQIGABAABIELAAAAAk
		CFgAAAASBCwAAAAJAhYAAIAEAQsAAECCgAUAACBBwAIAAJAgYAEAAEgQsAAAACQIWAAAABIE
		LAAAAAkCFgAAgAQBCwAAQIKABQAAIEHAAgAAkCBgAQAASBCwAAAAJAhYAAAAEgQsAAAACQIW
		AACABAELAABAgoAFAAAgQcACAACQIGABAABIELAAAAAkCFgAAAASBCwAAAAJAhYAAIAEAQsA
		AECCgAUAACBBwAIAAJAgYAEAAEgQsAAAACQIWAAAABIELAAAAAkCFgAAgAQBCwAAQIKABQAA
		IEHAAgAAkCBgAQAASBCwAAAAJAhYAAAAEgQsAAAACQIWAACABAELAABAgoAFAAAgQcACAACQ
		IGABAABIELAAAAAkCFgAAAASBCwAAAAJAhYAAIAEAQsAAECCgAUAACBBwAIAAJAgYAEAAEgQ
		sAAAACQIWAAAABIELAAAAAkCFgAAgAQBCwAAQIKABQAAIEHAAgAAkCBgAQAASBCwAAAAJAhY
		AAAAEgQsAAAACQIWAACABAELAABAgoAFAAAgQcACAACQIGABAABIELAAAAAkCFgAAAASBCwA
		AAAJAhYAAIAEAQsAAECCgAUAACBBwAIAAJAgYAEAAEgQsAAAACQIWAAAABIELAAAAAkCFgAA
		gAQBCwAAQIKABQAAIEHAAgAAkCBgAQAASBCwAAAAJAhYAAAAEgQsAAAACQIWAACABAELAABA
		goAFAAAgQcACAACQIGABAABIELAAAAAkCFgAAAASBCwAAAAJAhYAAIAEAQsAAECCgAUAACBB
		wAIAAJAgYAEAAEgQsAAAACQIWAAAABIELAAAAAkCFgAAgAQBCwAAQIKABQAAIEHAAgAAkCBg
		AQAASBCwAAAAJAhYAAAAEgQsAAAACQIWAACABAELAABAgoAFAAAgQcACAACQIGABAABIELAA
		AAAkCFgAAAASBCwAAAAJAhYAAIAEAQsAAECCgAUAACBBwAIAAJAgYAEAAEgQsAAAACQIWAAA
		ABIELAAAAAkCFgAAgAQBCwAAQIKABQAAIEHAAgAAkCBgAQAASBCwAAAAJAhYAAAAEgQsAAAA
		CQIWAACABAELAABAgoAFAAAgQcACAACQIGABAABIELAAAAAkCFgAAAASBCwAAAAJAhYAAIAE
		AQsAAECCgAUAACBBwAIAAJAgYAEAAEgQsAAAACQIWAAAABIELAAAAAkCFgAAgAQBCwAAQIKA
		BQAAIEHAAgAAkCBgAQAASBCwAAAAJAhYAAAAEgQsAAAACQIWAACABAELAABAgoAFAAAgQcAC
		AACQIGABAABIELAAAAAkCFgAAAASBCwAAAAJAhYAAIAEAQsAAECCgAUAACBBwAIAAJAgYAEA
		AEgQsAAAACQIWAAAABIELAAAAAkCFgAAgAQBCwAAQIKABQAAIEHAAgAAkCBgAQAASBCwAAAA
		JAhYAAAAEgQsAAAACQIWAACABAELAABAgoAFAAAgQcACAACQIGABAABIELAAAAAkCFgAAAAS
		BCwAAAAJAhYAAIAEAQsAAECCgAUAACBBwAIAAJAgYAEAAEgQsAAAACQIWAAAABIELAAAAAkC
		FgAAgAQBCwAAQIKABQAAIEHAAgAAkCBgAQAASBCwAAAAJAhYAAAAEgQsAAAACQIWAACABAEL
		AABAgoAFAAAgQcACAACQIGABAABIELAAAAAkCFgAAAASBCwAAAAJAhYAAIAEAQsAAECCgAUA
		ACBBwAIAAJAgYAEAAEgQsAAAACQIWAAAABIELAAAAAkCFgAAgAQBCwAAQIKABQAAIEHAAgAA
		kCBgAQAASBCwAAAAJAhYAAAAEgQsAAAACQIWAACABAELAABAgoAFAAAgQcACAACQIGABAABI
		ELAAAAAkCFgAAAASBCwAAAAJAhYAAIAEAQsAAECCgAUAACBBwAIAAJAgYAEAAEgQsAAAACQI
		WAAAABIELAAAAAkCFgAAgAQBCwAAQIKABQAAIEHAAgAAkCBgAQAASBCwAAAAJAhYAAAAEgQs
		AAAACQIWAACABAELAABAgoAFAAAgQcACAACQIGABAABIELAAAAAkCFgAAAASBCwAAAAJAhYA
		AIAEAQsAAECCgAUAACBBwAIAAJAgYAEAAEgQsAAAACQIWAAAABIELAAAAAkCFgAAgAQBCwAA
		QIKABQAAIEHAAgAAkCBgAQAASBCwAAAAJAhYAAAAEgQsAAAACQIWAACABAELAABAgoAFAAAg
		QcACAACQIGABAABIELAAAAAkCFgAAAASBCwAAAAJAhYAAIAEAQsAAECCgAUAACBBwAIAAJAg
		YAEAAEgQsAAAACQIWAAAABIELAAAAAkCFgAAgAQBCwAAQIKABQAAIEHAAgAAkCBgAQAASBCw
		AAAAJAhYAAAAEgQsAAAACQIWAACABAELAABAgoAFAAAgQcACAACQIGABAABIELAAAAAkCFgA
		AAASBCwAAAAJAhYAAIAEAQsAAECCgAUAACBBwAIAAJAgYAEAAEgQsAAAACQIWAAAABIELAAA
		AAkCFgAAgAQBCwAAQIKABQAAIEHAAgAAkCBgAQAASBCwAAAAJAhYAAAAEgQsAAAACQIWAACA
		BAELAABAgoAFAAAgQcACAACQIGABAABIELAAAAAkCFgAAAASBCwAAAAJAhYAAIAEAQsAAECC
		gAUAACBBwAIAAJAgYAEAAEgQsAAAACQIWAAAABIELAAAAAkCFgAAgAQBCwAAQIKABQAAIEHA
		AgAAkCBgAQAASBCwAAAAJAhYAAAAEgQsAAAACQIWAACABAELAABAgoAFAAAgQcACAACQIGAB
		AABIELAAAAAkCFgAAAASBCwAAAAJAhYAAIAEAQsAAECCgAUAACBBwAIAAJAgYAEAAEgQsAAA
		ACQIWAAAABIELAAAAAkCFgAAgAQBCwAAQIKABQAAIEHAAgAAkCBgAQAASBCwAAAAJAhYAAAA
		EgQsAAAACQIWAACABAELAABAgoAFAAAgQcACAACQIGABAABIELAAAAAkCFgAAAASBCwAAAAJ
		AhYAAIAEAQsAAECCgAUAACBBwAIAAJAgYAEAAEgQsAAAACQIWAAAABIELAAAAAkCFgAAgAQB
		CwAAQIKABQAAIEHAAgAAkCBgAQAASBCwAAAAJAhYAAAAEgQsAAAACQIWAACABAELAABAgoAF
		AAAgQcACAACQIGABAABIELAAAAAkCFgAAAASBCwAAAAJAhYAAIAEAQsAAECCgAUAACBBwAIA
		AJAgYAEAAEgQsAAAACQIWAAAABIELAAAAAkCFgAAgAQBCwAAQIKABQAAIEHAAgAAkCBgAQAA
		SBCwAAAAJAhYAAAAEgQsAAAACQIWAACABAELAABAgoAFAAAgQcACAACQIGABAABIELAAAAAk
		CFgAAAASBCwAAAAJAhYAAIAEAQsAAECCgAUAACBBwAIAAJAgYAEAAEgQsAAAACQIWAAAABIE
		LAAAAAkCFgAAgAQBCwAAQIKABQAAIEHAAgAAkCBgAQAASBCwAAAAJAhYAAAAEgQsAAAACQIW
		AACABAELAABAgoAFAAAgQcACAACQIGABAABIELAAAAAkCFgAAAASBCwAAAAJAhYAAIAEAQsA
		AECCgAUAACBBwAIAAJAgYAEAAEgQsAAAACQIWAAAABIELAAAAAkCFgAAgAQBCwAAQIKABQAA
		IEHAAgAAkCBgAQAASBCwAAAAJAhYAAAAEgQsAAAACQIWAACABAELAABAgoAFAAAgQcACAACQ
		IGABAABIELAAAAAkCFgAAAASBCwAAAAJAhYAAIAEAQsAAECCgAUAACBBwAIAAJAgYAEAAEgQ
		sAAAACQIWAAAABIELAAAAAkCFgAAgAQBCwAAQIKABQAAIEHAAgAAkCBgAQAASBCwAAAAJAhY
		AAAAEgQsAAAACQIWAACABAELAABAgoAFAAAgQcACAACQIGABAABIELAAAAAkCFgAAAASBCwA
		AAAJf9ivAxIAAAAAQf9ftyPQFwosAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCC
		wAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAA
		AAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAA
		CwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILA
		AgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAA
		ACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAAL
		AgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsAC
		AACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAA
		LAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsC
		CwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIA
		ALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAs
		CCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwIL
		AADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAA
		sCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwI
		LAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsA
		AMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACw
		ILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgs
		AAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAA
		wILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAg
		sAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwA
		AAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADA
		gsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCw
		AAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAA
		AAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCC
		wAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAA
		AAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAA
		CwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILA
		AgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAA
		ACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAAL
		AgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsAC
		AACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAA
		LAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsC
		CwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIA
		ALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAs
		CCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwIL
		AADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAA
		sCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwI
		LAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsA
		AMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACw
		ILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgs
		AAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAA
		wILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAg
		sAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwA
		AAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADA
		gsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCw
		AAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAA
		AAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCC
		wAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAA
		AAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAA
		CwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILA
		AgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAA
		ACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAAL
		AgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsAC
		AACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAA
		LAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsC
		CwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwAIA
		ALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwILAADAgsACAACwILAAAAAs
		CCwAAAALAgsAAMCCwAIAALAgsAAAACwILAAAAAsCCwAAwILAAgAAsCCwAAAALAgsAAAACwIL
		AADAgsACAACwILAAAAAsCCwAAAALAgsAAMCCwNbevfxmWSZgHN40bZPuKmwUihkOrnAGcMaR
		WXEYFgNUpzLFngtkTICwABk3dYAhqQmZDpK0LESQhm5QVuIYYiTh8Jf5mCbE9H0LpWn7efNe
		V+7Vd+Ipu1++wwsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsA
		AEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsA
		AEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsA
		AEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsA
		AEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsA
		AEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsA
		AEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsA
		AEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsA
		AEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsA
		AEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsA
		AEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsA
		AEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsA
		AEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsA
		AEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsA
		AEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsA
		AEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsA
		AEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsA
		AEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsA
		AEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAEAEAQsAAECEpQbs5bFWnxQAAIBGK2Va
		zdUfbw8uuOXWlIAFAACglb6eGl9Yr18P3p1eWLXf3xhp9UkBAABotPs3Rha0aqnX658vDNin
		c/3t7e2tPiwAAAAN1dHRUcp0QavOTI5d+nSo+rnirVs2t/q8AAAANNS2rZuroVrq9dSJvurt
		+/bsbvV5AQAAaKj9e/9SDdWTx/s+fP+v1dvHhw63+rwAAAA01LHh3mqo9vXuf+/dXdXbJ84O
		tPq8AAAANNTEuYFqqP75Tzt7ejZWb5+edCUdAAAAWmNmsuYisD0bN7S1tVV/3OmbGQELAABA
		a3w7szBgn8z1l3otd927XnPXhjdeb/WRAQAAaJxSo08qb7OWbp2/98zHR6pvzn5yur+1ZwYA
		AKCBzp8+Wk3UM//8cP7eN9/sqd774OZQe3t7a48NAABAo3R0dDy4NVRN1E2bep49ZvZqzTdk
		j3xwoIXHBgAAoGn+8fcD1TidvTr+68eMDhyqPmbu2nj9KwIAAMAqmLtW8+7qyEcHf/2Y117r
		fnyn5mPGO3dsb9WxAQAAaJRdO96uZmlp1e7u7gWPrL3OzpXPRlpybAAAAJrmyr9Hq1k6PVlz
		mdfeg3urj3x05+j69evW/tgAAAA0SmnPR3UfDO79297qgzs7O3+6PVh98IXzg2t/cgAAABrl
		4r9qfny4VGpp1drHnzrRV338L8F7sCZ4AQAAYEW8f2hfbY2ePN632FPa2truTtd8E/bh7MC2
		rZvX8vAAAAA0xFvbtjyc/aiaoqVPS6U+54k7d2x/MleTvfeuj3Z1da3Z+QEAAGiCUpqlN6sR
		Wsp0KZfFmTg3UPvW7dTF0TU4PAAAAM3xv0s19Vo2cXZgKU8v/Xv/xkjtKxwb7l3twwMAANAQ
		x4d7a9vzuy9Hlv4Z4H17dte+yOM7R9/Z9ftVPT8AAABN8Md3/vC47ro5ZaVJX+qlpi7Uv437
		w1fD5V9ZneMDAADQCKUrf7hZc92csv9eeOmvr65fv+7/Xw0v9j7s+NDh1fgTAAAAeOUdG+5d
		7L3X0qGlRpfxmls2/26xhv3lN50u+F1iAAAAXkKpyKmL9R/3na/X0qHLfvHnN+y966Nvbduy
		gn8LAAAAr6rSj7VXzFmRep33/IZ9ODvQe3DvivwtAAAAvKpKOZZ+XNV6nff8hi27cH5weZ9S
		BgAA4NVWarE043OKcgXrdd4LG/bRnaNXPhvZtePtFfxHAQAAyFUKsXTio0V+r2mV6nXeCxt2
		fnPXxo98cKC9vX3FDwAAAMBvX+nBUoWlDV/Yj6tUr/PWr1+32PVhF+zBzaFPTvdveOP1VToJ
		AAAAvzWlAUsJPljkAq/VS9uswXdR9+3Z/d2XI0s5z5O5/m9mxqYnxybODowPHS5P3Lplszdn
		AQAA0pWyK31XKq+0Xim+0n2l/h7PvbgTy0pRlieu2VG7uromzg08WdrZFuzpXP/9GyO3psa+
		uDz2xX9GzczMzMzMLGaXx0rNfX9j5OmyerBUZGnJUpRrVq/P7Nyx/e702DLObGZmZmZmZk1b
		6cdSkWufrs+0tbWdPN730+1Fr+ZjZmZmZmZmDV9pxlMn+ko/trBen+ns7Ow9uHd6cuzxc38e
		2czMzMzMzJqzUoilE0stlmZsdbbW6O7uHh04NHvV54rNzMzMzMyau9mr46UNSyG2OlKXZNOm
		njMfH/l2Zmx5P/RkZmZmZmZmWSv1VxqwlGDpwVYn6TK1tbX1bNzw3ru7+nr3nzrRd+nToeuf
		j92dHvvx9mDL/3vNzMzMzMzsZVdqrjRdKbvSd6XySuuV4ivdtwZfcf0ZbdOYGw0KZW5kc3Ry
		ZWFtDWVuZG9iag0xNCAwIG9iag08PC9CaXRzUGVyQ29tcG9uZW50IDgvQ29sb3JTcGFjZS9E
		ZXZpY2VSR0IvRmlsdGVyL0ZsYXRlRGVjb2RlL0hlaWdodCAxNDUvSW50ZXJwb2xhdGUgZmFs
		c2UvTGVuZ3RoIDEyNjE1L1N1YnR5cGUvSW1hZ2UvVHlwZS9YT2JqZWN0L1dpZHRoIDUzMD4+
		c3RyZWFtDQp4nO2dB3gUx9nHReIS23Hi2HFL4tipTo8TJ873JfniOJ1mXDAgeijGmGJsejVg
		DBgXMDYgiSZ6RyCQ6EhgEKihhiqoo957133v7dyN5mb39mabJOD9PfPcs2Xa7t7Of6e+NhuC
		IAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiC
		IAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiCIAiC
		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
		OyNUNUjV6Z5+vn+eGkDWPOTsfyEIgiDGaWtvr29smetvt0jypZ4da9QrqgYpvbOKqjnViL6m
		vLSRl7TIfHNLG3FtbW6nlclVg5jtYB0xqfPSouA7e68jM9S4ukYrXIx0HH7vedG35zw91m0Q
		BEEQETYy1l1tblTDJhmU9JJsYbCq8TOn5SwOIy1UhOSc8vyy2t9P3sf2sIsMzXp44CZc3QJB
		EMREMguqvz1kS25xDdl99b1jIqoBFZM7etmNfVDVmL81nB0cuysk7S/TAmhAg6oRnlL4kGSV
		g1p0DYrIog6OD/ngFLFQWVpdvyvEsUi+/0m7DQ75EusIgiCIbi4mFhBjT9RR4xeK8zVowG1n
		UlnVsNlHybrYGn7M258NKDJfQ1E1SJBHBm3OLqpRDMW2UM3efIlN6Knh27TdDgRBEESA8ppG
		qA7klda2MkNn4SBx7C4Xihuk1NDUkltSA1FV1jbK4+EilNPS2iY/W1RRrxKExF/PjByuqG3M
		Kqrm8oAgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIg
		CIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgCIIgSKfx/6ew/7kNCmVuZHN0cmVhbQ1l
		bmRvYmoNMTUgMCBvYmoNPDwvQkJveFstMC4yNSAyMC40NCA1OTUuNTUgODQyLjI5XS9GaWx0
		ZXIvRmxhdGVEZWNvZGUvR3JvdXA8PC9DUy9EZXZpY2VSR0IvSSB0cnVlL1MvVHJhbnNwYXJl
		bmN5L1R5cGUvR3JvdXA+Pi9MZW5ndGggMzMwL1Jlc291cmNlczw8L0V4dEdTdGF0ZTw8L0dT
		MCAxNyAwIFI+Pi9Qcm9jU2V0Wy9QREYvVGV4dC9JbWFnZUNdL1hPYmplY3Q8PC9JbTAgMTMg
		MCBSL0ltMSAxNCAwIFI+Pj4+L1N1YnR5cGUvRm9ybS9UeXBlL1hPYmplY3Q+PnN0cmVhbQ0K
		SImM1U1Lw0AQBuD7/oo5asHNfOxmd6H0YCtSaEGp4lmk9tRK6v8HN00jFhXeSyDZdzOTPCTD
		9LRynWseaDpt1vPlgphms9vFnBwTe81ajzFnOu5cc79h2n3WhaDiJVAs0Vs9YV/ouHXvE3e3
		rhs714rPRqn4ohSSelZqS/bS9rGXCR3OBVevhx1dbQ83z5vrobqM1U93+i+lF6nHn+3buDR0
		QZk9h9qE+NKemqhnYxOd66+nWJ+Z61rykfo98bzpbe+a5Z5p8VFLXFT63VGA+o5QqoVSCUpl
		KFWglDAWwwxFsZhhMQxAMAHBCAQzEAxBMAXFFBT8kjAFxRQUU1BMQTEFxRQUU1BMwTAFwxQM
		UzBMwTAFwxQMUzBMwTAFwxQCphD+UhhWvl985ySFOs36URCSb2P9gtjX/0WdbmGcBXIxC74E
		GACZU654DQplbmRzdHJlYW0NZW5kb2JqDTEgMCBvYmoNPDwvTGVuZ3RoIDMzMzAvU3VidHlw
		ZS9YTUwvVHlwZS9NZXRhZGF0YT4+c3RyZWFtDQo8P3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9
		Ilc1TTBNcENlaGlIenJlU3pOVGN6a2M5ZCI/Pgo8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2Jl
		Om5zOm1ldGEvIiB4OnhtcHRrPSJBZG9iZSBYTVAgQ29yZSA1LjYtYzAxNyA5MS4xNjQ0NjQs
		IDIwMjAvMDYvMTUtMTA6MjA6MDUgICAgICAgICI+CiAgIDxyZGY6UkRGIHhtbG5zOnJkZj0i
		aHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgICAgIDxy
		ZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5zOnhtcD0iaHR0
		cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLyIKICAgICAgICAgICAgeG1sbnM6ZGM9Imh0dHA6
		Ly9wdXJsLm9yZy9kYy9lbGVtZW50cy8xLjEvIgogICAgICAgICAgICB4bWxuczp4bXBNTT0i
		aHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIKICAgICAgICAgICAgeG1sbnM6cGRm
		PSJodHRwOi8vbnMuYWRvYmUuY29tL3BkZi8xLjMvIj4KICAgICAgICAgPHhtcDpNb2RpZnlE
		YXRlPjIwMjQtMTItMTBUMTQ6MzA6MTQrMDM6MDA8L3htcDpNb2RpZnlEYXRlPgogICAgICAg
		ICA8eG1wOkNyZWF0ZURhdGU+MjAyNC0xMi0xMFQxNDoyNzoxNyswMzowMDwveG1wOkNyZWF0
		ZURhdGU+CiAgICAgICAgIDx4bXA6TWV0YWRhdGFEYXRlPjIwMjQtMTItMTBUMTQ6MzA6MTQr
		MDM6MDA8L3htcDpNZXRhZGF0YURhdGU+CiAgICAgICAgIDx4bXA6Q3JlYXRvclRvb2w+UERG
		bGliIENvb2tib29rPC94bXA6Q3JlYXRvclRvb2w+CiAgICAgICAgIDxkYzpmb3JtYXQ+YXBw
		bGljYXRpb24vcGRmPC9kYzpmb3JtYXQ+CiAgICAgICAgIDxkYzp0aXRsZT4KICAgICAgICAg
		ICAgPHJkZjpBbHQ+CiAgICAgICAgICAgICAgIDxyZGY6bGkgeG1sOmxhbmc9IngtZGVmYXVs
		dCI+UERGIERPV05MT0FEPC9yZGY6bGk+CiAgICAgICAgICAgIDwvcmRmOkFsdD4KICAgICAg
		ICAgPC9kYzp0aXRsZT4KICAgICAgICAgPHhtcE1NOkRvY3VtZW50SUQ+dXVpZDphNGY5Mjdj
		MS02ZDVkLTRhY2UtOTYyZC1hYzM0MDY4NzIwOWU8L3htcE1NOkRvY3VtZW50SUQ+CiAgICAg
		ICAgIDx4bXBNTTpJbnN0YW5jZUlEPnV1aWQ6NDYzNjUwZTEtOGU0ZC00OGE5LWE4ZDEtZjIx
		MDY3MzEzM2UyPC94bXBNTTpJbnN0YW5jZUlEPgogICAgICAgICA8cGRmOlByb2R1Y2VyPlBE
		RmxpYitQREkgOS4yLjBwNSAoUEhQNy9MaW51eC14ODZfNjQpPC9wZGY6UHJvZHVjZXI+CiAg
		ICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgogICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAog
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
		ICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgCjw/eHBhY2tl
		dCBlbmQ9InciPz4NCmVuZHN0cmVhbQ1lbmRvYmoNMiAwIG9iag08PC9GaWx0ZXIvRmxhdGVE
		ZWNvZGUvRmlyc3QgNC9MZW5ndGggNDgvTiAxL1R5cGUvT2JqU3RtPj5zdHJlYW0NCmjeMlUw
		ULCx0XfOL80rUTDU985MKY62BIoFxeqHVBak6gckpqcW29kBBBgA1ncLgA0KZW5kc3RyZWFt
		DWVuZG9iag0zIDAgb2JqDTw8L0ZpbHRlci9GbGF0ZURlY29kZS9GaXJzdCA0L0xlbmd0aCAx
		NDgvTiAxL1R5cGUvT2JqU3RtPj5zdHJlYW0NCmjeMlMwULCx0XcuSk0syczPc0ksSdVwsTIy
		MDIxNDI0MDQxMjc01zYwVjcwUNeEqMov0ghwccvJTFJwzs/PTgJiTX3f/BQMncZADNcZUJSf
		UpqcCtOqHeDiqWCpZ6RnUGCqEKMR4BFgru+TmVdaoVthYRZvZhKjqakfklmSkwpSr+DiH+7n
		4+/oomlnBxBgAIU9MGMNCmVuZHN0cmVhbQ1lbmRvYmoNNCAwIG9iag08PC9EZWNvZGVQYXJt
		czw8L0NvbHVtbnMgNC9QcmVkaWN0b3IgMTI+Pi9GaWx0ZXIvRmxhdGVEZWNvZGUvSURbPDUx
		Njg2NjZEQjgxODIyNEI5OEVGNTM4RDBGQzREM0U3PjxGOTZGRDc0OUZENDUwRDQ1QjhCQTAz
		NUUxNzk1MTk4RD5dL0luZm8gNiAwIFIvTGVuZ3RoIDM5L1Jvb3QgOCAwIFIvU2l6ZSA3L1R5
		cGUvWFJlZi9XWzEgMyAwXT4+c3RyZWFtDQpo3mJiAAImRkb7h0wMDHz+QIKhB0gwfmRi/L8p
		FMRlBAgwAEinBRQNCmVuZHN0cmVhbQ1lbmRvYmoNc3RhcnR4cmVmDQoxMTYNCiUlRU9GDQo=
		</xsl:text>
	</xsl:variable>
	<xsl:variable name="JSA-Cover-en" select="normalize-space($JSA-Cover-en_)"/>

			<!-- <xsl:strip-space elements="jis:xref"/> -->

	<xsl:variable name="namespace_full_">
		<xsl:choose>
			<xsl:when test="local-name(/*) = 'metanorma-collection'"><xsl:value-of select="namespace-uri(//*[local-name() = 'metanorma'][1])"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="namespace-uri(/*)"/></xsl:otherwise><!-- example: https://www.metanorma.org/ns/standoc -->
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="namespace_full" select="normalize-space($namespace_full_)"/>

	<xsl:variable name="root_element_">
		<xsl:choose>
			<xsl:when test="local-name(/*) = 'metanorma-collection'"><xsl:value-of select="local-name(//*[local-name() = 'metanorma'][1])"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="local-name(/*)"/></xsl:otherwise><!-- example: metanorma (former iso-standard) -->
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="root_element" select="normalize-space($root_element_)"/>

	<xsl:variable name="document_scheme" select="normalize-space(//*[local-name() = 'metanorma']/*[local-name() = 'metanorma-extension']/*[local-name() = 'presentation-metadata'][*[local-name() = 'name'] = 'document-scheme']/*[local-name() = 'value'])"/>

	<!-- external parameters -->

	<xsl:param name="svg_images"/> <!-- svg images array -->
	<xsl:variable name="images" select="document($svg_images)"/>
	<xsl:param name="basepath"/> <!-- base path for images -->
	<xsl:param name="inputxml_basepath"/> <!-- input xml file path -->
	<xsl:param name="inputxml_filename"/> <!-- input xml file name -->
	<xsl:param name="output_path"/> <!-- output PDF file name -->
	<xsl:param name="external_index"/><!-- path to index xml, generated on 1st pass, based on FOP Intermediate Format -->
	<xsl:param name="syntax-highlight">false</xsl:param> <!-- syntax highlighting feature, default - off -->
	<xsl:param name="add_math_as_text">true</xsl:param> <!-- add math in text behind svg formula, to copy-paste formula from PDF as text -->

	<xsl:param name="table_if">false</xsl:param> <!-- generate extended table in IF for autolayout-algorithm -->
	<xsl:param name="table_widths"/> <!-- (debug: path to) xml with table's widths, generated on 1st pass, based on FOP Intermediate Format -->
	<!-- Example: <tables>
		<table page-width="509103" id="table1" width_max="223561" width_min="223560">
			<column width_max="39354" width_min="39354"/>
			<column width_max="75394" width_min="75394"/>
			<column width_max="108813" width_min="108813"/>
			<tbody>
				<tr>
					<td width_max="39354" width_min="39354">
						<p_len>39354</p_len>
						<word_len>39354</word_len>
					</td>
					
		OLD:
			<tables>
					<table id="table_if_tab-symdu" page-width="75"> - table id prefixed by 'table_if_' to simple search in IF 
						<tbody>
							<tr>
								<td id="tab-symdu_1_1">
									<p_len>6</p_len>
									<p_len>100</p_len>  for 2nd paragraph
									<word_len>6</word_len>
									<word_len>20</word_len>
								...
	-->

	<!-- for command line debug: <xsl:variable name="table_widths_from_if" select="document($table_widths)"/> -->
	<xsl:variable name="table_widths_from_if" select="xalan:nodeset($table_widths)"/>

	<xsl:variable name="table_widths_from_if_calculated_">
		<xsl:for-each select="$table_widths_from_if//table">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:call-template name="calculate-column-widths-autolayout-algorithm"/>
			</xsl:copy>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="table_widths_from_if_calculated" select="xalan:nodeset($table_widths_from_if_calculated_)"/>

	<xsl:param name="table_if_debug">false</xsl:param> <!-- set 'true' to put debug width data before table or dl -->

	<xsl:variable name="isApplyAutolayoutAlgorithm_">
		true
	</xsl:variable>
	<xsl:variable name="isApplyAutolayoutAlgorithm" select="normalize-space($isApplyAutolayoutAlgorithm_)"/>

	<xsl:variable name="isGenerateTableIF_">
		<xsl:choose>
			<xsl:when test="$isApplyAutolayoutAlgorithm = 'true'">
				<xsl:value-of select="normalize-space($table_if) = 'true'"/>
			</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="isGenerateTableIF" select="normalize-space($isGenerateTableIF_)"/>

	<xsl:variable name="lang">
		<xsl:call-template name="getLang"/>
	</xsl:variable>

	<xsl:variable name="inputxml_filename_prefix">
		<xsl:choose>
			<xsl:when test="contains($inputxml_filename, '.presentation.xml')">
				<xsl:value-of select="substring-before($inputxml_filename, '.presentation.xml')"/>
			</xsl:when>
			<xsl:when test="contains($inputxml_filename, '.xml')">
				<xsl:value-of select="substring-before($inputxml_filename, '.xml')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$inputxml_filename"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- Note 1: Each xslt has declated variable `namespace` that allows to set some properties, processing logic, etc. for concrete xslt.
	You can put such conditions by using xslt construction `xsl:if test="..."` or <xsl:choose><xsl:when test=""></xsl:when><xsl:otherwiste></xsl:otherwiste></xsl:choose>,
	BUT DON'T put any another conditions together with $namespace = '...' (such conditions will be ignored). For another conditions, please use nested xsl:if or xsl:choose -->

	<!--
	<metanorma-extension>
		<presentation-metadata>
			<papersize>letter</papersize>
		</presentation-metadata>
	</metanorma-extension>
	-->

	<xsl:variable name="papersize" select="java:toLowerCase(java:java.lang.String.new(normalize-space(//*[local-name() = 'metanorma']/*[local-name() = 'metanorma-extension']/*[local-name() = 'presentation-metadata']/*[local-name() = 'papersize'])))"/>
	<xsl:variable name="papersize_width_">
		<xsl:choose>
			<xsl:when test="$papersize = 'letter'">215.9</xsl:when>
			<xsl:when test="$papersize = 'a4'">210</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="papersize_width" select="normalize-space($papersize_width_)"/>
	<xsl:variable name="papersize_height_">
		<xsl:choose>
			<xsl:when test="$papersize = 'letter'">279.4</xsl:when>
			<xsl:when test="$papersize = 'a4'">297</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="papersize_height" select="normalize-space($papersize_height_)"/>

	<!-- page width in mm -->
	<xsl:variable name="pageWidth_">
		<xsl:choose>
			<xsl:when test="$papersize_width != ''"><xsl:value-of select="$papersize_width"/></xsl:when>
			<xsl:otherwise>
				210
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="pageWidth" select="normalize-space($pageWidth_)"/>

	<!-- page height in mm -->
	<xsl:variable name="pageHeight_">
		<xsl:choose>
			<xsl:when test="$papersize_height != ''"><xsl:value-of select="$papersize_height"/></xsl:when>
			<xsl:otherwise>
				297
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="pageHeight" select="normalize-space($pageHeight_)"/>

	<!-- Page margins in mm (just digits, without 'mm')-->
	<!-- marginLeftRight1 and marginLeftRight2 - is left or right margin depends on odd/even page,
	for example, left margin on odd page and right margin on even page -->
	<xsl:variable name="marginLeftRight1_">

				<xsl:choose>
					<xsl:when test="$vertical_layout = 'true'">19</xsl:when>
					<xsl:otherwise>22</xsl:otherwise>
				</xsl:choose>

	</xsl:variable>
	<xsl:variable name="marginLeftRight1" select="normalize-space($marginLeftRight1_)"/>

	<xsl:variable name="marginLeftRight2_">

				<xsl:choose>
					<xsl:when test="$vertical_layout = 'true'">17</xsl:when>
					<xsl:otherwise>22</xsl:otherwise>
				</xsl:choose>

	</xsl:variable>
	<xsl:variable name="marginLeftRight2" select="normalize-space($marginLeftRight2_)"/>

	<xsl:variable name="marginTop_">

				<xsl:choose>
					<xsl:when test="$vertical_layout = 'true'">16</xsl:when> <!-- 9.4 -->
					<xsl:otherwise>30</xsl:otherwise>
				</xsl:choose>

	</xsl:variable>
	<xsl:variable name="marginTop" select="normalize-space($marginTop_)"/>

	<xsl:variable name="marginBottom_">

				<xsl:choose>
					<xsl:when test="$vertical_layout = 'true'">15.2</xsl:when>
					<xsl:otherwise>24.5</xsl:otherwise>
				</xsl:choose>

	</xsl:variable>
	<xsl:variable name="marginBottom" select="normalize-space($marginBottom_)"/>

	<xsl:variable name="layout_columns_default">1</xsl:variable>
	<xsl:variable name="layout_columns_" select="normalize-space((//*[local-name() = 'metanorma'])[1]/*[local-name() = 'metanorma-extension']/*[local-name() = 'presentation-metadata']/*[local-name() = 'layout-columns'])"/>
	<xsl:variable name="layout_columns">
		<xsl:choose>
			<xsl:when test="$layout_columns_ != ''"><xsl:value-of select="$layout_columns_"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$layout_columns_default"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- Note 2: almost all localized string determined in the element //localized-strings in metanorma xml, but there are a few cases when:
	 - string didn't determined yet
	 - we need to put the string on two-languages (for instance, on English and French both), but xml contains only localized strings for one language
	 - there is a difference between localized string value and text that should be displayed in PDF
	-->
	<xsl:variable name="titles_">

		<!-- These titles of Table of contents renders different than determined in localized-strings -->
		<!-- <title-toc lang="en">
			<xsl:if test="$namespace = 'csd' or $namespace = 'ieee' or $namespace = 'iho' or $namespace = 'mpfd' or $namespace = 'ogc' or $namespace = 'unece-rec'">
				<xsl:text>Contents</xsl:text>
			</xsl:if>
			<xsl:if test="$namespace = 'csa' or $namespace = 'm3d' or $namespace = 'nist-sp' or $namespace = 'ogc-white-paper'">
				<xsl:text>Table of Contents</xsl:text>
			</xsl:if>
			<xsl:if test="$namespace = 'gb'">
				<xsl:text>Table of contents</xsl:text>
			</xsl:if>
		</title-toc> -->
		<title-toc lang="en">Table of contents</title-toc>
		<!-- <title-toc lang="fr">
			<xsl:text>Sommaire</xsl:text>
		</title-toc> -->
		<!-- <title-toc lang="zh">
			<xsl:choose>
				<xsl:when test="$namespace = 'gb'">
					<xsl:text>目次</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Contents</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</title-toc> -->
		<title-toc lang="zh">目次</title-toc>

		<title-part lang="en">

		</title-part>
		<title-part lang="fr">

		</title-part>
		<title-part lang="ru">

		</title-part>
		<title-part lang="zh">第 # 部分:</title-part>

		<title-subpart lang="en">Sub-part #</title-subpart>
		<title-subpart lang="fr">Partie de sub #</title-subpart>

	</xsl:variable>
	<xsl:variable name="titles" select="xalan:nodeset($titles_)"/>

	<xsl:variable name="title-list-tables">
		<xsl:variable name="toc_table_title" select="//*[local-name() = 'metanorma']/*[local-name() = 'metanorma-extension']/*[local-name() = 'toc'][@type='table']/*[local-name() = 'title']"/>
		<xsl:value-of select="$toc_table_title"/>
		<xsl:if test="normalize-space($toc_table_title) = ''">
			<xsl:call-template name="getLocalizedString">
				<xsl:with-param name="key">toc_tables</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:variable>

	<xsl:variable name="title-list-figures">
		<xsl:variable name="toc_figure_title" select="//*[local-name() = 'metanorma']/*[local-name() = 'metanorma-extension']/*[local-name() = 'toc'][@type='figure']/*[local-name() = 'title']"/>
		<xsl:value-of select="$toc_figure_title"/>
		<xsl:if test="normalize-space($toc_figure_title) = ''">
			<xsl:call-template name="getLocalizedString">
				<xsl:with-param name="key">toc_figures</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:variable>

	<xsl:variable name="title-list-recommendations">
		<xsl:variable name="toc_requirement_title" select="//*[local-name() = 'metanorma']/*[local-name() = 'metanorma-extension']/*[local-name() = 'toc'][@type='requirement']/*[local-name() = 'title']"/>
		<xsl:value-of select="$toc_requirement_title"/>
		<xsl:if test="normalize-space($toc_requirement_title) = ''">
			<xsl:call-template name="getLocalizedString">
				<xsl:with-param name="key">toc_recommendations</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:variable>

	<xsl:variable name="bibdata">
		<xsl:copy-of select="//*[local-name() = 'metanorma']/*[local-name() = 'bibdata']"/>
		<xsl:copy-of select="//*[local-name() = 'metanorma']/*[local-name() = 'localized-strings']"/>
	</xsl:variable>

	<!-- Characters -->
	<xsl:variable name="linebreak">&#8232;</xsl:variable>
	<xsl:variable name="tab_zh">　</xsl:variable>
	<xsl:variable name="non_breaking_hyphen">‑</xsl:variable>
	<xsl:variable name="thin_space"> </xsl:variable>
	<xsl:variable name="zero_width_space">​</xsl:variable>
	<xsl:variable name="hair_space"> </xsl:variable>
	<xsl:variable name="en_dash">–</xsl:variable>
	<xsl:variable name="em_dash">—</xsl:variable>
	<xsl:variable name="cr">&#13;</xsl:variable>
	<xsl:variable name="lf">
</xsl:variable>

	<xsl:template name="getTitle">
		<xsl:param name="name"/>
		<xsl:param name="lang"/>
		<xsl:variable name="lang_">
			<xsl:choose>
				<xsl:when test="$lang != ''">
					<xsl:value-of select="$lang"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="getLang"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="language" select="normalize-space($lang_)"/>
		<xsl:variable name="title_" select="$titles/*[local-name() = $name][@lang = $language]"/>
		<xsl:choose>
			<xsl:when test="normalize-space($title_) != ''">
				<xsl:value-of select="$title_"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$titles/*[local-name() = $name][@lang = 'en']"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
	<xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

	<xsl:variable name="en_chars" select="concat($lower,$upper,',.`1234567890-=~!@#$%^*()_+[]{}\|?/')"/>

	<!-- ====================================== -->
	<!-- STYLES -->
	<!-- ====================================== -->
	<xsl:variable name="font_noto_sans">Noto Sans, Noto Sans HK, Noto Sans JP, Noto Sans KR, Noto Sans SC, Noto Sans TC</xsl:variable>
	<xsl:variable name="font_noto_sans_mono">Noto Sans Mono, Noto Sans Mono CJK HK, Noto Sans Mono CJK JP, Noto Sans Mono CJK KR, Noto Sans Mono CJK SC, Noto Sans Mono CJK TC</xsl:variable>
	<xsl:variable name="font_noto_serif">Noto Serif, Noto Serif HK, Noto Serif JP, Noto Serif KR, Noto Serif SC, Noto Serif TC</xsl:variable>
	<xsl:attribute-set name="root-style">

			<xsl:attribute name="font-family">IPAexMincho, STIX Two Math, <xsl:value-of select="$font_noto_serif"/></xsl:attribute>
			<xsl:attribute name="font-family-generic">Serif</xsl:attribute>
			<xsl:attribute name="font-size">10pt</xsl:attribute>

	</xsl:attribute-set> <!-- root-style -->

	<xsl:template name="insertRootStyle">
		<xsl:param name="root-style"/>
		<xsl:variable name="root-style_" select="xalan:nodeset($root-style)"/>

		<xsl:variable name="additional_fonts_">
			<xsl:for-each select="//*[local-name() = 'metanorma'][1]/*[local-name() = 'metanorma-extension']/*[local-name() = 'presentation-metadata'][*[local-name() = 'name'] = 'fonts']/*[local-name() = 'value'] |       //*[local-name() = 'metanorma'][1]/*[local-name() = 'presentation-metadata'][*[local-name() = 'name'] = 'fonts']/*[local-name() = 'value']">
				<xsl:value-of select="."/><xsl:if test="position() != last()">, </xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="additional_fonts" select="normalize-space($additional_fonts_)"/>

		<xsl:variable name="font_family_generic" select="$root-style_/root-style/@font-family-generic"/>

		<xsl:for-each select="$root-style_/root-style/@*">

			<xsl:choose>
				<xsl:when test="local-name() = 'font-family-generic'"><!-- skip, it's using for determine 'sans' or 'serif' --></xsl:when>
				<xsl:when test="local-name() = 'font-family'">

					<xsl:variable name="font_regional_prefix">
						<xsl:choose>
							<xsl:when test="$font_family_generic = 'Sans'">Noto Sans</xsl:when>
							<xsl:otherwise>Noto Serif</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<xsl:attribute name="{local-name()}">

						<xsl:variable name="font_extended">
							<xsl:choose>
								<xsl:when test="$lang = 'zh'"><xsl:value-of select="$font_regional_prefix"/> SC</xsl:when>
								<xsl:when test="$lang = 'hk'"><xsl:value-of select="$font_regional_prefix"/> HK</xsl:when>
								<xsl:when test="$lang = 'jp'"><xsl:value-of select="$font_regional_prefix"/> JP</xsl:when>
								<xsl:when test="$lang = 'kr'"><xsl:value-of select="$font_regional_prefix"/> KR</xsl:when>
								<xsl:when test="$lang = 'sc'"><xsl:value-of select="$font_regional_prefix"/> SC</xsl:when>
								<xsl:when test="$lang = 'tc'"><xsl:value-of select="$font_regional_prefix"/> TC</xsl:when>
							</xsl:choose>
						</xsl:variable>
						<xsl:if test="normalize-space($font_extended) != ''">
							<xsl:value-of select="$font_regional_prefix"/><xsl:text>, </xsl:text>
							<xsl:value-of select="$font_extended"/><xsl:text>, </xsl:text>
						</xsl:if>

						<xsl:variable name="font_family" select="."/>

						<xsl:choose>
							<xsl:when test="$additional_fonts = ''">
								<xsl:value-of select="$font_family"/>
							</xsl:when>
							<xsl:otherwise> <!-- $additional_fonts != '' -->
								<xsl:choose>
									<xsl:when test="contains($font_family, ',')">
										<xsl:value-of select="substring-before($font_family, ',')"/>
										<xsl:text>, </xsl:text><xsl:value-of select="$additional_fonts"/>
										<xsl:text>, </xsl:text><xsl:value-of select="substring-after($font_family, ',')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$font_family"/>
										<xsl:text>, </xsl:text><xsl:value-of select="$additional_fonts"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="."/>
				</xsl:otherwise>
			</xsl:choose>

			<!-- <xsl:choose>
				<xsl:when test="local-name() = 'font-family'">
					<xsl:attribute name="{local-name()}">
						<xsl:value-of select="."/>, <xsl:value-of select="$additional_fonts"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="."/>
				</xsl:otherwise>
			</xsl:choose> -->
		</xsl:for-each>
	</xsl:template> <!-- insertRootStyle -->

	<!-- Preface sections styles -->
	<xsl:attribute-set name="copyright-statement-style">

	</xsl:attribute-set> <!-- copyright-statement-style -->

	<xsl:attribute-set name="copyright-statement-title-style">

	</xsl:attribute-set> <!-- copyright-statement-title-style -->

	<xsl:attribute-set name="copyright-statement-p-style">

	</xsl:attribute-set> <!-- copyright-statement-p-style -->

	<xsl:attribute-set name="license-statement-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="license-statement-title-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>

	</xsl:attribute-set> <!-- license-statement-title-style -->

	<xsl:attribute-set name="license-statement-p-style">

	</xsl:attribute-set> <!-- license-statement-p-style -->

	<xsl:attribute-set name="legal-statement-style">

	</xsl:attribute-set> <!-- legal-statement-style -->

	<xsl:attribute-set name="legal-statement-title-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>

	</xsl:attribute-set> <!-- legal-statement-title-style -->

	<xsl:attribute-set name="legal-statement-p-style">

	</xsl:attribute-set> <!-- legal-statement-p-style -->

	<xsl:attribute-set name="feedback-statement-style">

	</xsl:attribute-set> <!-- feedback-statement-style -->

	<xsl:attribute-set name="feedback-statement-title-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>

	</xsl:attribute-set> <!-- feedback-statement-title-style -->

	<xsl:attribute-set name="feedback-statement-p-style">

	</xsl:attribute-set> <!-- feedback-statement-p-style -->

	<!-- End Preface sections styles -->

	<xsl:attribute-set name="link-style">

	</xsl:attribute-set>

	<xsl:template name="refine_link-style">

	</xsl:template> <!-- refine_link-style -->

	<xsl:attribute-set name="sourcecode-container-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="sourcecode-style">
		<xsl:attribute name="white-space">pre</xsl:attribute>
		<xsl:attribute name="wrap-option">wrap</xsl:attribute>
		<xsl:attribute name="role">Code</xsl:attribute>

	</xsl:attribute-set>

	<xsl:template name="refine_sourcecode-style">

	</xsl:template> <!-- refine_sourcecode-style -->

	<xsl:attribute-set name="pre-style">
		<xsl:attribute name="font-family">Courier New, <xsl:value-of select="$font_noto_sans_mono"/></xsl:attribute>
		<xsl:attribute name="margin-bottom">6pt</xsl:attribute>

	</xsl:attribute-set>

	<xsl:attribute-set name="permission-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="permission-name-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="permission-label-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="requirement-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="requirement-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>

	</xsl:attribute-set>

	<xsl:attribute-set name="requirement-label-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="subject-style">
	</xsl:attribute-set>

	<xsl:attribute-set name="inherit-style">
	</xsl:attribute-set>

	<xsl:attribute-set name="description-style">
	</xsl:attribute-set>

	<xsl:attribute-set name="specification-style">
	</xsl:attribute-set>

	<xsl:attribute-set name="measurement-target-style">
	</xsl:attribute-set>

	<xsl:attribute-set name="verification-style">
	</xsl:attribute-set>

	<xsl:attribute-set name="import-style">
	</xsl:attribute-set>

	<xsl:attribute-set name="component-style">
	</xsl:attribute-set>

	<xsl:attribute-set name="recommendation-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="recommendation-name-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="recommendation-label-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="termexample-style">

			<xsl:attribute name="margin-top">4pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">4pt</xsl:attribute>

	</xsl:attribute-set>

	<xsl:template name="refine_termexample-style">

	</xsl:template>

	<xsl:attribute-set name="example-style">

			<xsl:attribute name="margin-top">4pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">4pt</xsl:attribute>

	</xsl:attribute-set> <!-- example-style -->

	<xsl:template name="refine_example-style">

	</xsl:template> <!-- refine_example-style -->

	<xsl:attribute-set name="example-body-style">

	</xsl:attribute-set> <!-- example-body-style -->

	<xsl:attribute-set name="example-name-style">

	</xsl:attribute-set> <!-- example-name-style -->

	<xsl:template name="refine_example-name-style">

			<xsl:if test="not($vertical_layout = 'true')">
				<xsl:attribute name="font-family">IPAexGothic</xsl:attribute>
			</xsl:if>
			<xsl:if test="$vertical_layout = 'true'">
				<xsl:attribute name="font-family">Noto Sans JP</xsl:attribute>
				<xsl:attribute name="font-weight">500</xsl:attribute>
			</xsl:if>

	</xsl:template>

	<xsl:attribute-set name="example-p-style">

			<xsl:attribute name="margin-bottom">2pt</xsl:attribute>

	</xsl:attribute-set> <!-- example-p-style -->

	<xsl:template name="refine_example-p-style">

	</xsl:template> <!-- refine_example-p-style -->

	<xsl:attribute-set name="termexample-name-style">

	</xsl:attribute-set> <!-- termexample-name-style -->

	<xsl:template name="refine_termexample-name-style">

			<xsl:if test="not($vertical_layout = 'true')">
				<xsl:attribute name="font-family">IPAexGothic</xsl:attribute>
			</xsl:if>

	</xsl:template>

	<!-- ========================== -->
	<!-- Table styles -->
	<!-- ========================== -->
	<xsl:variable name="table-border_">

		0.5pt solid black

	</xsl:variable>
	<xsl:variable name="table-border" select="normalize-space($table-border_)"/>

	<xsl:variable name="table-cell-border_">

	</xsl:variable>
	<xsl:variable name="table-cell-border" select="normalize-space($table-cell-border_)"/>

	<xsl:attribute-set name="table-container-style">
		<xsl:attribute name="margin-left">0mm</xsl:attribute>
		<xsl:attribute name="margin-right">0mm</xsl:attribute>

			<xsl:attribute name="font-size">9pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">8pt</xsl:attribute>

	</xsl:attribute-set> <!-- table-container-style -->

	<xsl:template name="refine_table-container-style">
		<xsl:param name="margin-side"/>

		<!-- end table block-container attributes -->
	</xsl:template> <!-- refine_table-container-style -->

	<xsl:attribute-set name="table-style">
		<xsl:attribute name="table-omit-footer-at-break">true</xsl:attribute>
		<xsl:attribute name="table-layout">fixed</xsl:attribute>

			<xsl:attribute name="border"><xsl:value-of select="$table-border"/></xsl:attribute>

	</xsl:attribute-set><!-- table-style -->

	<xsl:template name="refine_table-style">
		<xsl:param name="margin-side"/>

		<xsl:call-template name="setBordersTableArray"/>

			<xsl:if test="ancestor::*[local-name()='preface']">
				<xsl:attribute name="border">none</xsl:attribute>
			</xsl:if>

	</xsl:template> <!-- refine_table-style -->

	<xsl:attribute-set name="table-name-style">
		<xsl:attribute name="role">Caption</xsl:attribute>
		<xsl:attribute name="keep-with-next">always</xsl:attribute>

			<xsl:attribute name="text-align">center</xsl:attribute>
			<xsl:attribute name="margin-bottom">4pt</xsl:attribute>

	</xsl:attribute-set> <!-- table-name-style -->

	<xsl:template name="refine_table-name-style">
		<xsl:param name="continued"/>
		<xsl:if test="$continued = 'true'">
			<xsl:attribute name="role">SKIP</xsl:attribute>
		</xsl:if>

			<xsl:if test="not($vertical_layout = 'true')">
				<xsl:attribute name="font-family">IPAexGothic</xsl:attribute>
			</xsl:if>

	</xsl:template> <!-- refine_table-name-style -->

	<xsl:attribute-set name="table-row-style">
		<xsl:attribute name="min-height">4mm</xsl:attribute>

	</xsl:attribute-set>

	<xsl:attribute-set name="table-header-row-style" use-attribute-sets="table-row-style">
		<xsl:attribute name="font-weight">bold</xsl:attribute>

			<xsl:attribute name="border-top"><xsl:value-of select="$table-border"/></xsl:attribute>
			<xsl:attribute name="border-bottom"><xsl:value-of select="$table-border"/></xsl:attribute>

	</xsl:attribute-set>

	<xsl:template name="refine_table-header-row-style">

		<xsl:call-template name="setBordersTableArray"/>

			<xsl:if test="ancestor::*[local-name() = 'preface']">
				<xsl:attribute name="border-top">none</xsl:attribute>
				<xsl:attribute name="border-bottom">none</xsl:attribute>
			</xsl:if>

	</xsl:template> <!-- refine_table-header-row-style -->

	<xsl:attribute-set name="table-footer-row-style" use-attribute-sets="table-row-style">

			<xsl:attribute name="border-left"><xsl:value-of select="$table-border"/></xsl:attribute>
			<xsl:attribute name="border-right"><xsl:value-of select="$table-border"/></xsl:attribute>

	</xsl:attribute-set>

	<xsl:template name="refine_table-footer-row-style">

	</xsl:template> <!-- refine_table-footer-row-style -->

	<xsl:attribute-set name="table-body-row-style" use-attribute-sets="table-row-style">

	</xsl:attribute-set>

	<xsl:template name="refine_table-body-row-style">

		<xsl:call-template name="setBordersTableArray"/>

	</xsl:template> <!-- refine_table-body-row-style -->

	<xsl:attribute-set name="table-header-cell-style">
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="padding-left">1mm</xsl:attribute>
		<xsl:attribute name="padding-right">1mm</xsl:attribute>
		<xsl:attribute name="display-align">center</xsl:attribute>

			<xsl:attribute name="font-weight">normal</xsl:attribute>
			<xsl:attribute name="border"><xsl:value-of select="$table-border"/></xsl:attribute>
			<xsl:attribute name="padding-top">0.5mm</xsl:attribute>
			<xsl:attribute name="text-align">center</xsl:attribute>

	</xsl:attribute-set> <!-- table-header-cell-style -->

	<xsl:template name="refine_table-header-cell-style">

			<xsl:attribute name="text-align">center</xsl:attribute>

		<xsl:call-template name="setBordersTableArray"/>

			<xsl:if test="ancestor::*[local-name()='preface']">
				<xsl:attribute name="border">none</xsl:attribute>
			</xsl:if>

		<xsl:if test="$lang = 'ar'">
			<xsl:attribute name="padding-right">1mm</xsl:attribute>
		</xsl:if>

		<xsl:call-template name="setTableCellAttributes"/>

	</xsl:template> <!-- refine_table-header-cell-style -->

	<xsl:attribute-set name="table-cell-style">
		<xsl:attribute name="display-align">center</xsl:attribute>
		<xsl:attribute name="padding-left">1mm</xsl:attribute>
		<xsl:attribute name="padding-right">1mm</xsl:attribute>

			<xsl:attribute name="padding-top">0.5mm</xsl:attribute>
			<xsl:attribute name="border"><xsl:value-of select="$table-border"/></xsl:attribute>

	</xsl:attribute-set> <!-- table-cell-style -->

	<xsl:template name="refine_table-cell-style">

		<xsl:if test="$lang = 'ar'">
			<xsl:attribute name="padding-right">1mm</xsl:attribute>
		</xsl:if>

		 <!-- bsi -->

		<xsl:call-template name="setBordersTableArray"/>

			<xsl:if test="ancestor::*[local-name() = 'preface']">
				<xsl:attribute name="border">none</xsl:attribute>
			</xsl:if>

	</xsl:template> <!-- refine_table-cell-style -->

	<xsl:attribute-set name="table-footer-cell-style">
		<xsl:attribute name="border">solid black 1pt</xsl:attribute>
		<xsl:attribute name="padding-left">1mm</xsl:attribute>
		<xsl:attribute name="padding-right">1mm</xsl:attribute>
		<xsl:attribute name="padding-top">1mm</xsl:attribute>

			<xsl:attribute name="border"><xsl:value-of select="$table-border"/></xsl:attribute>
			<xsl:attribute name="border-top">solid black 0pt</xsl:attribute>

	</xsl:attribute-set> <!-- table-footer-cell-style -->

	<xsl:template name="refine_table-footer-cell-style">

	</xsl:template> <!-- refine_table-footer-cell-style -->

	<xsl:attribute-set name="table-note-style">
		<xsl:attribute name="font-size">10pt</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>

			<xsl:attribute name="font-size">inherit</xsl:attribute>
			<xsl:attribute name="margin-bottom">1pt</xsl:attribute>
			<xsl:attribute name="margin-left"><xsl:value-of select="$text_indent"/></xsl:attribute>

	</xsl:attribute-set><!-- table-note-style -->

	<xsl:template name="refine_table-note-style">

	</xsl:template> <!-- refine_table-note-style -->

	<xsl:attribute-set name="table-fn-style">
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>

			<xsl:attribute name="font-size">inherit</xsl:attribute>
			<xsl:attribute name="margin-bottom">1pt</xsl:attribute>

	</xsl:attribute-set> <!-- table-fn-style -->

	<xsl:template name="refine_table-fn-style">

	</xsl:template>

	<xsl:attribute-set name="table-fn-number-style">
		<!-- <xsl:attribute name="padding-right">5mm</xsl:attribute> -->

			<!-- <xsl:attribute name="padding-right">0mm</xsl:attribute> -->

	</xsl:attribute-set> <!-- table-fn-number-style -->

	<xsl:attribute-set name="table-fmt-fn-label-style">
		<xsl:attribute name="font-size">80%</xsl:attribute>

			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="font-size">67%</xsl:attribute>
			<xsl:attribute name="vertical-align">super</xsl:attribute>

	</xsl:attribute-set> <!-- table-fmt-fn-label-style -->

	<xsl:template name="refine_table-fmt-fn-label-style">

			<xsl:if test="not($vertical_layout = 'true')">
				<xsl:attribute name="font-family">Times New Roman</xsl:attribute>
			</xsl:if>

	</xsl:template>

	<xsl:attribute-set name="fn-container-body-style">
		<xsl:attribute name="text-indent">0</xsl:attribute>
		<xsl:attribute name="start-indent">0</xsl:attribute>

	</xsl:attribute-set>

	<xsl:attribute-set name="table-fn-body-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="figure-fn-number-style">
		<xsl:attribute name="padding-right">5mm</xsl:attribute>
	</xsl:attribute-set> <!-- figure-fn-number-style -->

	<xsl:attribute-set name="figure-fmt-fn-label-style">
		<xsl:attribute name="font-size">80%</xsl:attribute>
		<xsl:attribute name="vertical-align">super</xsl:attribute>

	</xsl:attribute-set> <!-- figure-fmt-fn-label-style -->

	<xsl:template name="refine_figure-fmt-fn-label-style">

	</xsl:template>

	<xsl:attribute-set name="figure-fn-body-style">
		<xsl:attribute name="text-align">justify</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>

	</xsl:attribute-set>
	<!-- ========================== -->
	<!-- END Table styles -->
	<!-- ========================== -->

	<!-- ========================== -->
	<!-- Definition's list styles -->
	<!-- ========================== -->

	<xsl:attribute-set name="dl-block-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="dt-row-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="dt-cell-style">

	</xsl:attribute-set>

	<xsl:template name="refine_dt-cell-style">

	</xsl:template> <!-- refine_dt-cell-style -->

	<xsl:attribute-set name="dt-block-style">
		<xsl:attribute name="margin-top">0pt</xsl:attribute>

			<xsl:attribute name="line-height">1.5</xsl:attribute>

	</xsl:attribute-set>

	<xsl:template name="refine_dt-block-style">

	</xsl:template> <!-- refine_dt-block-style -->

	<xsl:attribute-set name="dl-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		<xsl:attribute name="margin-bottom">6pt</xsl:attribute>

	</xsl:attribute-set> <!-- dl-name-style -->

	<xsl:attribute-set name="dd-cell-style">
		<xsl:attribute name="padding-left">2mm</xsl:attribute>

	</xsl:attribute-set>

	<xsl:template name="refine_dd-cell-style">

	</xsl:template> <!-- refine_dd-cell-style -->

	<!-- ========================== -->
	<!-- END Definition's list styles -->
	<!-- ========================== -->

	<xsl:attribute-set name="appendix-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="appendix-example-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="xref-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="eref-style">

	</xsl:attribute-set>

	<xsl:template name="refine_eref-style">
		<xsl:variable name="citeas" select="java:replaceAll(java:java.lang.String.new(@citeas),'^\[?(.+?)\]?$','$1')"/> <!-- remove leading and trailing brackets -->
		<xsl:variable name="text" select="normalize-space()"/>

	</xsl:template> <!-- refine_eref-style -->

	<xsl:attribute-set name="note-style">

			<xsl:attribute name="text-indent">0mm</xsl:attribute>
			<xsl:attribute name="space-before">2pt</xsl:attribute>

	</xsl:attribute-set>

	<xsl:template name="refine_note-style">

	</xsl:template>

	<xsl:variable name="note-body-indent">10mm</xsl:variable>
	<xsl:variable name="note-body-indent-table">5mm</xsl:variable>

	<xsl:attribute-set name="note-name-style">

	</xsl:attribute-set>

	<xsl:template name="refine_note-name-style">

			<xsl:if test="not($vertical_layout = 'true')">
				<xsl:attribute name="font-family">IPAexGothic</xsl:attribute>
			</xsl:if>
			<xsl:if test="$vertical_layout = 'true'">
				<xsl:attribute name="font-family">Noto Sans JP</xsl:attribute>
				<xsl:attribute name="font-weight">500</xsl:attribute>
			</xsl:if>

	</xsl:template> <!-- refine_note-name-style -->

	<xsl:attribute-set name="table-note-name-style">
		<xsl:attribute name="padding-right">2mm</xsl:attribute>

	</xsl:attribute-set>

	<xsl:template name="refine_table-note-name-style">

	</xsl:template> <!-- refine_table-note-name-style -->

	<xsl:attribute-set name="note-p-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="termnote-style">

			<xsl:attribute name="text-indent">0mm</xsl:attribute>
			<xsl:attribute name="space-before">4pt</xsl:attribute>
			<xsl:attribute name="space-after">4pt</xsl:attribute>

	</xsl:attribute-set>

	<xsl:template name="refine_termnote-style">

	</xsl:template> <!-- refine_termnote-style -->

	<xsl:attribute-set name="termnote-name-style">

	</xsl:attribute-set>

	<xsl:template name="refine_termnote-name-style">

		<!-- <xsl:if test="$namespace = 'ieee'">
			<xsl:attribute name="padding-right">0mm</xsl:attribute>
		</xsl:if> -->

			<xsl:if test="not($vertical_layout = 'true')">
				<xsl:attribute name="font-family">IPAexGothic</xsl:attribute>
			</xsl:if>

	</xsl:template>

	<xsl:attribute-set name="termnote-p-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="quote-style">
		<xsl:attribute name="margin-left">12mm</xsl:attribute>
		<xsl:attribute name="margin-right">12mm</xsl:attribute>

			<xsl:attribute name="margin-left">0mm</xsl:attribute>
			<xsl:attribute name="margin-right">0mm</xsl:attribute>

	</xsl:attribute-set>

	<xsl:template name="refine_quote-style">

			<xsl:if test="ancestor::*[local-name() = 'li']">
				<xsl:attribute name="margin-left">7.5mm</xsl:attribute>
			</xsl:if>

	</xsl:template>

	<xsl:attribute-set name="quote-source-style">
		<xsl:attribute name="text-align">right</xsl:attribute>

	</xsl:attribute-set>

	<xsl:attribute-set name="termsource-style">

			<xsl:attribute name="margin-left">6mm</xsl:attribute>

	</xsl:attribute-set>

	<xsl:template name="refine_termsource-style">

	</xsl:template> <!-- refine_termsource-style -->

	<xsl:attribute-set name="termsource-text-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="origin-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="term-style">

			<xsl:attribute name="space-before">12pt</xsl:attribute>

	</xsl:attribute-set>

	<xsl:attribute-set name="term-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>

			<xsl:attribute name="space-after">2pt</xsl:attribute>

	</xsl:attribute-set>

	<xsl:attribute-set name="figure-block-style">
		<xsl:attribute name="role">SKIP</xsl:attribute>

	</xsl:attribute-set>

	<xsl:template name="refine_figure-block-style">

			<xsl:if test="ancestor::*[local-name() = 'example'] or ancestor::*[local-name() = 'note']">
				<xsl:attribute name="margin-left">0mm</xsl:attribute>
			</xsl:if>
			<xsl:if test="$vertical_layout = 'true' and not(*[local-name() = 'figure'])">
				<xsl:attribute name="reference-orientation">90</xsl:attribute>
				<xsl:attribute name="display-align">center</xsl:attribute>
				<!-- <xsl:attribute name="border">1pt solid blue</xsl:attribute> -->
				<xsl:attribute name="margin-left">0mm</xsl:attribute>

				<!-- determine block-container width for rotated image -->
				<xsl:for-each select="*[local-name() = 'image'][1]"> <!-- set context to 'image' element -->

					<xsl:variable name="width">
						<xsl:call-template name="setImageWidth"/>
					</xsl:variable>

					<xsl:choose>
						<xsl:when test="normalize-space($width) != ''">
							<xsl:attribute name="width">
								<xsl:value-of select="$width"/>
							</xsl:attribute>
						</xsl:when>
						<xsl:when test="*[local-name() = 'svg']">
							<xsl:variable name="svg_content">
								<xsl:apply-templates select="*[local-name() = 'svg'][1]" mode="svg_update"/>
							</xsl:variable>
							<xsl:variable name="svg_width_" select="xalan:nodeset($svg_content)/*/@width"/>
							<xsl:variable name="svg_width" select="number(translate($svg_width_, 'px', ''))"/>

							<xsl:variable name="scale_width">
								<xsl:choose>
									<xsl:when test="$svg_width &gt; $height_effective_px">
										<xsl:value-of select="$height_effective_px div $svg_width"/>
									</xsl:when>
									<xsl:otherwise>1</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:attribute name="width"><xsl:value-of select="$svg_width * $scale_width"/>px</xsl:attribute>

						</xsl:when>
						<xsl:otherwise> <!-- determine image width programmatically -->
							<xsl:variable name="img_src">
								<xsl:call-template name="getImageSrc"/>
							</xsl:variable>
							<xsl:variable name="image_width_programmatically" select="java:org.metanorma.fop.utils.ImageUtils.getImageWidth($img_src, $height_effective, $width_effective)"/>

							<xsl:variable name="scale">
								<xsl:call-template name="getImageScale"/>
							</xsl:variable>

							<xsl:if test="normalize-space($image_width_programmatically) != '0'">
								<xsl:attribute name="width">
									<xsl:value-of select="concat($image_width_programmatically, 'mm')"/> <!-- * ($scale div 100) -->
								</xsl:attribute>
								<xsl:if test="$scale != 100">
									<xsl:attribute name="display-align">before</xsl:attribute>
								</xsl:if>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				<!-- end: $vertical_layout = 'true -->
			</xsl:if>
			<!-- end: $namespace = 'jis' -->

	</xsl:template>

	<xsl:attribute-set name="figure-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="figure-name-style">
		<xsl:attribute name="role">Caption</xsl:attribute>

			<xsl:attribute name="text-align">center</xsl:attribute>
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
			<xsl:attribute name="keep-with-previous">always</xsl:attribute>

	</xsl:attribute-set>

	<xsl:template name="refine_figure-name-style">

			<xsl:if test="ancestor::jis:figure">
				<xsl:attribute name="margin-top">0</xsl:attribute>
				<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
			</xsl:if>
			<xsl:if test="not($vertical_layout = 'true')">
				<xsl:attribute name="font-family">IPAexGothic</xsl:attribute>
			</xsl:if>

	</xsl:template> <!-- refine_figure-name-style -->

	<xsl:attribute-set name="figure-source-style">

	</xsl:attribute-set>

	<!-- Formula's styles -->
	<xsl:attribute-set name="formula-style">
		<xsl:attribute name="margin-top">6pt</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>

	</xsl:attribute-set> <!-- formula-style -->

	<xsl:attribute-set name="formula-stem-block-style">
		<xsl:attribute name="text-align">center</xsl:attribute>

	</xsl:attribute-set> <!-- formula-stem-block-style -->

	<xsl:template name="refine_formula-stem-block-style">

	</xsl:template> <!-- refine_formula-stem-block-style -->

	<xsl:attribute-set name="formula-stem-number-style">
		<xsl:attribute name="text-align">right</xsl:attribute>

	</xsl:attribute-set> <!-- formula-stem-number-style -->
	<!-- End Formula's styles -->

	<xsl:template name="refine_formula-stem-number-style">

	</xsl:template>

	<xsl:attribute-set name="image-style">
		<xsl:attribute name="role">SKIP</xsl:attribute>
		<xsl:attribute name="text-align">center</xsl:attribute>

	</xsl:attribute-set>

	<xsl:template name="refine_image-style">

			<xsl:if test="$vertical_layout = 'true'">
				<xsl:attribute name="text-align">inherit</xsl:attribute>
			</xsl:if>

	</xsl:template>

	<xsl:attribute-set name="figure-pseudocode-p-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="image-graphic-style">
		<xsl:attribute name="width">100%</xsl:attribute>
		<xsl:attribute name="content-height">100%</xsl:attribute>
		<xsl:attribute name="scaling">uniform</xsl:attribute>

	</xsl:attribute-set>

	<xsl:attribute-set name="tt-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="sourcecode-name-style">
		<xsl:attribute name="font-size">11pt</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="text-align">center</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		<xsl:attribute name="keep-with-previous">always</xsl:attribute>

	</xsl:attribute-set>

	<xsl:attribute-set name="preferred-block-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="preferred-term-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>

			<xsl:attribute name="font-weight">normal</xsl:attribute>

	</xsl:attribute-set>

	<xsl:attribute-set name="domain-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="admitted-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="deprecates-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="related-block-style" use-attribute-sets="preferred-block-style">
	</xsl:attribute-set>

	<xsl:attribute-set name="definition-style">

			<xsl:attribute name="space-before">2pt</xsl:attribute>
			<xsl:attribute name="space-after">2pt</xsl:attribute>

	</xsl:attribute-set>

	<xsl:variable name="color-added-text">
		<xsl:text>rgb(0, 255, 0)</xsl:text>
	</xsl:variable>
	<xsl:attribute-set name="add-style">

				<xsl:attribute name="color">red</xsl:attribute>
				<xsl:attribute name="text-decoration">underline</xsl:attribute>
				<!-- <xsl:attribute name="color">black</xsl:attribute>
				<xsl:attribute name="background-color"><xsl:value-of select="$color-added-text"/></xsl:attribute>
				<xsl:attribute name="padding-top">1mm</xsl:attribute>
				<xsl:attribute name="padding-bottom">0.5mm</xsl:attribute> -->

	</xsl:attribute-set>

	<xsl:variable name="add-style">
			<add-style xsl:use-attribute-sets="add-style"/>
		</xsl:variable>
	<xsl:template name="append_add-style">
		<xsl:copy-of select="xalan:nodeset($add-style)/add-style/@*"/>
	</xsl:template>

	<xsl:variable name="color-deleted-text">
		<xsl:text>red</xsl:text>
	</xsl:variable>
	<xsl:attribute-set name="del-style">
		<xsl:attribute name="color"><xsl:value-of select="$color-deleted-text"/></xsl:attribute>
		<xsl:attribute name="text-decoration">line-through</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="mathml-style">
		<xsl:attribute name="font-family">STIX Two Math</xsl:attribute>

	</xsl:attribute-set>

	<xsl:template name="refine_mathml-style">

	</xsl:template>

	<xsl:attribute-set name="list-style">

			<xsl:attribute name="provisional-distance-between-starts">7.5mm</xsl:attribute>
			<xsl:attribute name="space-after">4pt</xsl:attribute>

	</xsl:attribute-set> <!-- list-style -->

	<xsl:template name="refine_list-style">

	</xsl:template> <!-- refine_list-style -->

	<xsl:attribute-set name="list-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>

	</xsl:attribute-set> <!-- list-name-style -->

	<xsl:attribute-set name="list-item-style">

	</xsl:attribute-set>

	<xsl:template name="refine_list-item-style">

	</xsl:template> <!-- refine_list-item-style -->

	<xsl:attribute-set name="list-item-label-style">

			<xsl:attribute name="line-height">1.5</xsl:attribute>

	</xsl:attribute-set>

	<xsl:template name="refine_list-item-label-style">

			<xsl:if test="parent::*[local-name() = 'ol'] and not($vertical_layout = 'true')">
				<xsl:attribute name="font-family">Times New Roman</xsl:attribute>
				<xsl:attribute name="font-weight">bold</xsl:attribute>
			</xsl:if>

	</xsl:template> <!-- refine_list-item-label-style -->

	<xsl:attribute-set name="list-item-body-style">

	</xsl:attribute-set>

	<xsl:template name="refine_list-item-body-style">

	</xsl:template> <!-- refine_list-item-body-style -->

	<xsl:attribute-set name="toc-style">
		<xsl:attribute name="line-height">135%</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="fn-reference-style">
		<xsl:attribute name="font-size">80%</xsl:attribute>
		<xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>

			<xsl:attribute name="font-size">67%</xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="vertical-align">super</xsl:attribute>

	</xsl:attribute-set>

	<xsl:template name="refine_fn-reference-style">

			<xsl:if test="not($vertical_layout = 'true')">
				<xsl:attribute name="font-family">Times New Roman</xsl:attribute>
			</xsl:if>

	</xsl:template> <!-- refine_fn-reference-style -->

	<xsl:attribute-set name="fn-style">
		<xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="fn-num-style">
		<xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>

			<xsl:attribute name="font-size">67%</xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="vertical-align">super</xsl:attribute>

	</xsl:attribute-set>

	<xsl:attribute-set name="fn-body-style">
		<xsl:attribute name="font-weight">normal</xsl:attribute>
		<xsl:attribute name="font-style">normal</xsl:attribute>
		<xsl:attribute name="text-indent">0</xsl:attribute>
		<xsl:attribute name="start-indent">0</xsl:attribute>

	</xsl:attribute-set>

	<xsl:template name="refine_fn-body-style">

			<xsl:if test="not($vertical_layout = 'true')">
				<xsl:attribute name="font-family">IPAexMincho</xsl:attribute> <!-- prevent font for footnote in Times New Roman main text -->
			</xsl:if>

	</xsl:template> <!-- refine_fn-body-style -->

	<xsl:attribute-set name="fn-body-num-style">
		<xsl:attribute name="keep-with-next.within-line">always</xsl:attribute>

			<xsl:attribute name="font-size">67%</xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="vertical-align">super</xsl:attribute>

	</xsl:attribute-set> <!-- fn-body-num-style -->

	<xsl:template name="refine_fn-body-num-style">

			<xsl:if test="not($vertical_layout = 'true')">
				<xsl:attribute name="font-family">Times New Roman</xsl:attribute>
			</xsl:if>
			<xsl:if test="$vertical_layout = 'true'">
				<xsl:attribute name="vertical-align">baseline</xsl:attribute>
				<xsl:attribute name="font-size">100%</xsl:attribute>
			</xsl:if>

	</xsl:template> <!-- refine_fn-body-num-style -->

	<!-- admonition -->
	<xsl:attribute-set name="admonition-style">

	</xsl:attribute-set> <!-- admonition-style -->

	<xsl:attribute-set name="admonition-container-style">
		<xsl:attribute name="margin-left">0mm</xsl:attribute>
		<xsl:attribute name="margin-right">0mm</xsl:attribute>

	</xsl:attribute-set> <!-- admonition-container-style -->

	<xsl:attribute-set name="admonition-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>

	</xsl:attribute-set> <!-- admonition-name-style -->

	<xsl:attribute-set name="admonition-p-style">

	</xsl:attribute-set> <!-- admonition-p-style -->
	<!-- end admonition -->

	<!-- bibitem in Normative References (references/@normative="true") -->
	<xsl:attribute-set name="bibitem-normative-style">

			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
			<xsl:attribute name="start-indent">6mm</xsl:attribute>
			<xsl:attribute name="text-indent">-6mm</xsl:attribute>

	</xsl:attribute-set> <!-- bibitem-normative-style -->

	<!-- bibitem in Normative References (references/@normative="true"), renders as list -->
	<xsl:attribute-set name="bibitem-normative-list-style">
		<xsl:attribute name="provisional-distance-between-starts">12mm</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>

		<!-- <xsl:if test="$namespace = 'ieee'">
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
			<xsl:attribute name="provisional-distance-between-starts">9.5mm</xsl:attribute>
		</xsl:if> -->

	</xsl:attribute-set> <!-- bibitem-normative-list-style -->

	<xsl:attribute-set name="bibitem-non-normative-style">

	</xsl:attribute-set> <!-- bibitem-non-normative-style -->

	<!-- bibitem in bibliography section (references/@normative="false"), renders as list -->
	<xsl:attribute-set name="bibitem-non-normative-list-style">
		<xsl:attribute name="provisional-distance-between-starts">12mm</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>

	</xsl:attribute-set> <!-- bibitem-non-normative-list-style -->

	<xsl:attribute-set name="bibitem-non-normative-list-item-style">
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>

	</xsl:attribute-set>

	<!-- bibitem in bibliography section (references/@normative="false"), list body -->
	<xsl:attribute-set name="bibitem-normative-list-body-style">

	</xsl:attribute-set>

	<xsl:attribute-set name="bibitem-non-normative-list-body-style">

	</xsl:attribute-set> <!-- bibitem-non-normative-list-body-style -->

	<!-- footnote reference number for bibitem, in the text  -->
	<xsl:attribute-set name="bibitem-note-fn-style">
		<xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
		<xsl:attribute name="font-size">65%</xsl:attribute>

			<xsl:attribute name="font-size">67%</xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="vertical-align">super</xsl:attribute>

	</xsl:attribute-set> <!-- bibitem-note-fn-style -->

	<!-- footnote number on the page bottom -->
	<xsl:attribute-set name="bibitem-note-fn-number-style">
		<xsl:attribute name="keep-with-next.within-line">always</xsl:attribute>

	</xsl:attribute-set> <!-- bibitem-note-fn-number-style -->

	<!-- footnote body (text) on the page bottom -->
	<xsl:attribute-set name="bibitem-note-fn-body-style">
		<xsl:attribute name="font-size">10pt</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		<xsl:attribute name="start-indent">0pt</xsl:attribute>

	</xsl:attribute-set> <!-- bibitem-note-fn-body-style -->

	<xsl:attribute-set name="references-non-normative-style">

	</xsl:attribute-set> <!-- references-non-normative-style -->

	<!-- Highlight.js syntax GitHub styles -->
	<xsl:attribute-set name="hljs-doctag">
		<xsl:attribute name="color">#d73a49</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-keyword">
		<xsl:attribute name="color">#d73a49</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-meta_hljs-keyword">
		<xsl:attribute name="color">#d73a49</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-template-tag">
		<xsl:attribute name="color">#d73a49</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-template-variable">
		<xsl:attribute name="color">#d73a49</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-type">
		<xsl:attribute name="color">#d73a49</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-variable_and_language_">
		<xsl:attribute name="color">#d73a49</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="hljs-title">
		<xsl:attribute name="color">#6f42c1</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-title_and_class_">
		<xsl:attribute name="color">#6f42c1</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-title_and_class__and_inherited__">
		<xsl:attribute name="color">#6f42c1</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-title_and_function_">
		<xsl:attribute name="color">#6f42c1</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="hljs-attr">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-attribute">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-literal">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-meta">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-number">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-operator">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-variable">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-selector-attr">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-selector-class">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-selector-id">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="hljs-regexp">
		<xsl:attribute name="color">#032f62</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-string">
		<xsl:attribute name="color">#032f62</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-meta_hljs-string">
		<xsl:attribute name="color">#032f62</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="hljs-built_in">
		<xsl:attribute name="color">#e36209</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-symbol">
		<xsl:attribute name="color">#e36209</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="hljs-comment">
		<xsl:attribute name="color">#6a737d</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-code">
		<xsl:attribute name="color">#6a737d</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-formula">
		<xsl:attribute name="color">#6a737d</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="hljs-name">
		<xsl:attribute name="color">#22863a</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-quote">
		<xsl:attribute name="color">#22863a</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-selector-tag">
		<xsl:attribute name="color">#22863a</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-selector-pseudo">
		<xsl:attribute name="color">#22863a</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="hljs-subst">
		<xsl:attribute name="color">#24292e</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="hljs-section">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="hljs-bullet">
		<xsl:attribute name="color">#735c0f</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="hljs-emphasis">
		<xsl:attribute name="color">#24292e</xsl:attribute>
		<xsl:attribute name="font-style">italic</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="hljs-strong">
		<xsl:attribute name="color">#24292e</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="hljs-addition">
		<xsl:attribute name="color">#22863a</xsl:attribute>
		<xsl:attribute name="background-color">#f0fff4</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="hljs-deletion">
		<xsl:attribute name="color">#b31d28</xsl:attribute>
		<xsl:attribute name="background-color">#ffeef0</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="hljs-char_and_escape_">
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-link">
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-params">
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-property">
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-punctuation">
	</xsl:attribute-set>
	<xsl:attribute-set name="hljs-tag">
	</xsl:attribute-set>
	<!-- End Highlight syntax styles -->

	<!-- Index section styles -->
	<xsl:attribute-set name="indexsect-title-style">
		<xsl:attribute name="role">H1</xsl:attribute>

	</xsl:attribute-set>

	<xsl:attribute-set name="indexsect-clause-title-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>

	</xsl:attribute-set>

	<!-- End Index section styles -->
	<!-- ====================================== -->
	<!-- END STYLES -->
	<!-- ====================================== -->

	<xsl:variable name="border-block-added">2.5pt solid rgb(0, 176, 80)</xsl:variable>
	<xsl:variable name="border-block-deleted">2.5pt solid rgb(255, 0, 0)</xsl:variable>

	<xsl:variable name="ace_tag">ace-tag_</xsl:variable>

	<xsl:template name="processPrefaceSectionsDefault_Contents">
		<xsl:variable name="nodes_preface_">
			<xsl:for-each select="/*/*[local-name()='preface']/*[not(local-name() = 'note' or local-name() = 'admonition' or @type = 'toc')]">
				<node id="{@id}"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="nodes_preface" select="xalan:nodeset($nodes_preface_)"/>

		<xsl:for-each select="/*/*[local-name()='preface']/*[not(local-name() = 'note' or local-name() = 'admonition' or @type = 'toc')]">
			<xsl:sort select="@displayorder" data-type="number"/>

			<!-- process Section's title -->
			<xsl:variable name="preceding-sibling_id" select="$nodes_preface/node[@id = current()/@id]/preceding-sibling::node[1]/@id"/>
			<xsl:if test="$preceding-sibling_id != ''">
				<xsl:apply-templates select="parent::*/*[@type = 'section-title' and @id = $preceding-sibling_id and not(@displayorder)]" mode="contents_no_displayorder"/>
			</xsl:if>

			<xsl:apply-templates select="." mode="contents"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="processMainSectionsDefault_Contents">

		<xsl:variable name="nodes_sections_">
			<xsl:for-each select="/*/*[local-name()='sections']/*">
				<node id="{@id}"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="nodes_sections" select="xalan:nodeset($nodes_sections_)"/>

		<xsl:for-each select="/*/*[local-name()='sections']/* | /*/*[local-name()='bibliography']/*[local-name()='references'][@normative='true'] |    /*/*[local-name()='bibliography']/*[local-name()='clause'][*[local-name()='references'][@normative='true']]">
			<xsl:sort select="@displayorder" data-type="number"/>

			<!-- process Section's title -->
			<xsl:variable name="preceding-sibling_id" select="$nodes_sections/node[@id = current()/@id]/preceding-sibling::node[1]/@id"/>
			<xsl:if test="$preceding-sibling_id != ''">
				<xsl:apply-templates select="parent::*/*[@type = 'section-title' and @id = $preceding-sibling_id and not(@displayorder)]" mode="contents_no_displayorder"/>
			</xsl:if>

			<xsl:apply-templates select="." mode="contents"/>
		</xsl:for-each>

		<!-- <xsl:for-each select="/*/*[local-name()='annex']">
			<xsl:sort select="@displayorder" data-type="number"/>
			<xsl:apply-templates select="." mode="contents"/>
		</xsl:for-each> -->

		<xsl:for-each select="/*/*[local-name()='annex'] | /*/*[local-name()='bibliography']/*[not(@normative='true') and not(*[local-name()='references'][@normative='true'])][count(.//*[local-name() = 'bibitem'][not(@hidden) = 'true']) &gt; 0] |          /*/*[local-name()='bibliography']/*[local-name()='clause'][*[local-name()='references'][not(@normative='true')]][count(.//*[local-name() = 'bibitem'][not(@hidden) = 'true']) &gt; 0]">
			<xsl:sort select="@displayorder" data-type="number"/>
			<xsl:apply-templates select="." mode="contents"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="processTablesFigures_Contents">
		<xsl:param name="always"/>
		<xsl:if test="(//*[local-name() = 'metanorma']/*[local-name() = 'metanorma-extension']/*[local-name() = 'toc'][@type='table']/*[local-name() = 'title']) or normalize-space($always) = 'true'">
			<xsl:call-template name="processTables_Contents"/>
		</xsl:if>
		<xsl:if test="(//*[local-name() = 'metanorma']/*[local-name() = 'metanorma-extension']/*[local-name() = 'toc'][@type='figure']/*[local-name() = 'title']) or normalize-space($always) = 'true'">
			<xsl:call-template name="processFigures_Contents"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="processTables_Contents">
		<tables>
			<xsl:for-each select="//*[local-name() = 'table'][not(ancestor::*[local-name() = 'metanorma-extension'])][@id and *[local-name() = 'name'] and normalize-space(@id) != '']">
				<xsl:choose>
					<xsl:when test="*[local-name() = 'fmt-name']">
						<xsl:variable name="fmt_name">
							<xsl:apply-templates select="*[local-name() = 'fmt-name']" mode="update_xml_step1"/>
						</xsl:variable>
						<table id="{@id}" alt-text="{normalize-space($fmt_name)}">
							<xsl:copy-of select="$fmt_name"/>
						</table>
					</xsl:when>
					<xsl:otherwise>
						<table id="{@id}" alt-text="{*[local-name() = 'name']}">
							<xsl:copy-of select="*[local-name() = 'name']"/>
						</table>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</tables>
	</xsl:template>

	<xsl:template name="processFigures_Contents">
		<figures>
			<xsl:for-each select="//*[local-name() = 'figure'][@id and *[local-name() = 'name'] and not(@unnumbered = 'true') and normalize-space(@id) != ''] | //*[@id and starts-with(*[local-name() = 'name'], 'Figure ') and normalize-space(@id) != '']">
				<xsl:choose>
					<xsl:when test="*[local-name() = 'fmt-name']">
						<xsl:variable name="fmt_name">
							<xsl:apply-templates select="*[local-name() = 'fmt-name']" mode="update_xml_step1"/>
						</xsl:variable>
						<figure id="{@id}" alt-text="{normalize-space($fmt_name)}">
							<xsl:copy-of select="$fmt_name"/>
						</figure>
					</xsl:when>
					<xsl:otherwise>
						<figure id="{@id}" alt-text="{*[local-name() = 'name']}">
							<xsl:copy-of select="*[local-name() = 'name']"/>
						</figure>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</figures>
	</xsl:template>

	<xsl:template name="processPrefaceSectionsDefault">
		<xsl:for-each select="/*/*[local-name()='preface']/*[not(local-name() = 'note' or local-name() = 'admonition')]">
			<xsl:sort select="@displayorder" data-type="number"/>
			<xsl:apply-templates select="."/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="copyCommonElements">
		<!-- copy bibdata, localized-strings, metanorma-extension and boilerplate -->
		<xsl:copy-of select="/*/*[local-name() != 'preface' and local-name() != 'sections' and local-name() != 'annex' and local-name() != 'bibliography' and local-name() != 'indexsect']"/>
	</xsl:template>

	<xsl:template name="processMainSectionsDefault">
		<xsl:for-each select="/*/*[local-name()='sections']/* | /*/*[local-name()='bibliography']/*[local-name()='references'][@normative='true']">
			<xsl:sort select="@displayorder" data-type="number"/>
			<xsl:apply-templates select="."/>

		</xsl:for-each>

		<xsl:for-each select="/*/*[local-name()='annex']">
			<xsl:sort select="@displayorder" data-type="number"/>
			<xsl:apply-templates select="."/>
		</xsl:for-each>

		<xsl:for-each select="/*/*[local-name()='bibliography']/*[not(@normative='true')] |          /*/*[local-name()='bibliography']/*[local-name()='clause'][*[local-name()='references'][not(@normative='true')]]">
			<xsl:sort select="@displayorder" data-type="number"/>
			<xsl:apply-templates select="."/>
		</xsl:for-each>
	</xsl:template><!-- END: processMainSectionsDefault -->

	<!-- Example:
	<metanorma>
		<preface>
			<page_sequence>
				<clause...
			</page_sequence>
			<page_sequence>
				<clause...
			</page_sequence>
		</preface>
		<sections>
			<page_sequence>
				<clause...
			</page_sequence>
			<page_sequence>
				<clause...
			</page_sequence>
		</sections>
		<page_sequence>
			<annex ..
		</page_sequence>
		<page_sequence>
			<annex ..
		</page_sequence>
	</metanorma>
	-->
	<xsl:template name="processPrefaceAndMainSectionsDefault_items">

		<xsl:variable name="updated_xml_step_move_pagebreak">
			<xsl:element name="{$root_element}" namespace="{$namespace_full}">
				<xsl:call-template name="copyCommonElements"/>
				<xsl:call-template name="insertPrefaceSectionsPageSequences"/>
				<xsl:call-template name="insertMainSectionsPageSequences"/>
			</xsl:element>
		</xsl:variable>

		<xsl:variable name="updated_xml_step_move_pagebreak_filename" select="concat($output_path,'_main_', java:getTime(java:java.util.Date.new()), '.xml')"/>

		<redirect:write file="{$updated_xml_step_move_pagebreak_filename}">
			<xsl:copy-of select="$updated_xml_step_move_pagebreak"/>
		</redirect:write>

		<xsl:copy-of select="document($updated_xml_step_move_pagebreak_filename)"/>

		<xsl:if test="$debug = 'true'">
			<redirect:write file="page_sequence_preface_and_main.xml">
				<xsl:copy-of select="$updated_xml_step_move_pagebreak"/>
			</redirect:write>
		</xsl:if>

		<xsl:call-template name="deleteFile">
			<xsl:with-param name="filepath" select="$updated_xml_step_move_pagebreak_filename"/>
		</xsl:call-template>
	</xsl:template> <!-- END: processPrefaceAndMainSectionsDefault_items -->

	<xsl:template name="insertPrefaceSectionsPageSequences">
		<xsl:element name="preface" namespace="{$namespace_full}"> <!-- save context element -->
			<xsl:element name="page_sequence" namespace="{$namespace_full}">
				<xsl:for-each select="/*/*[local-name()='preface']/*[not(local-name() = 'note' or local-name() = 'admonition')]">
					<xsl:sort select="@displayorder" data-type="number"/>
					<xsl:apply-templates select="." mode="update_xml_step_move_pagebreak"/>
				</xsl:for-each>
			</xsl:element>
		</xsl:element>
	</xsl:template> <!-- END: insertPrefaceSectionsPageSequences -->

	<xsl:template name="insertMainSectionsPageSequences">

		<xsl:call-template name="insertSectionsInPageSequence"/>

		<xsl:element name="page_sequence" namespace="{$namespace_full}">
			<xsl:for-each select="/*/*[local-name()='annex']">
				<xsl:sort select="@displayorder" data-type="number"/>
				<xsl:apply-templates select="." mode="update_xml_step_move_pagebreak"/>
			</xsl:for-each>
		</xsl:element>

		<xsl:element name="page_sequence" namespace="{$namespace_full}">
			<xsl:element name="bibliography" namespace="{$namespace_full}"> <!-- save context element -->
				<xsl:for-each select="/*/*[local-name()='bibliography']/*[not(@normative='true')] |            /*/*[local-name()='bibliography']/*[local-name()='clause'][*[local-name()='references'][not(@normative='true')]]">
					<xsl:sort select="@displayorder" data-type="number"/>
					<xsl:apply-templates select="." mode="update_xml_step_move_pagebreak"/>
				</xsl:for-each>
			</xsl:element>
		</xsl:element>
	</xsl:template> <!-- END: insertMainSectionsPageSequences -->

	<xsl:template name="insertSectionsInPageSequence">
		<xsl:element name="sections" namespace="{$namespace_full}"> <!-- save context element -->
			<xsl:element name="page_sequence" namespace="{$namespace_full}">
				<xsl:for-each select="/*/*[local-name()='sections']/* | /*/*[local-name()='bibliography']/*[local-name()='references'][@normative='true']">
					<xsl:sort select="@displayorder" data-type="number"/>
					<xsl:apply-templates select="." mode="update_xml_step_move_pagebreak"/>

				</xsl:for-each>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template name="insertMainSectionsInSeparatePageSequences">
		<xsl:element name="sections" namespace="{$namespace_full}"> <!-- save context element -->
			<xsl:for-each select="/*/*[local-name()='sections']/* | /*/*[local-name()='bibliography']/*[local-name()='references'][@normative='true']">
				<xsl:sort select="@displayorder" data-type="number"/>
				<xsl:element name="page_sequence" namespace="{$namespace_full}">
					<xsl:attribute name="main_page_sequence"/>
					<xsl:apply-templates select="." mode="update_xml_step_move_pagebreak"/>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>

		<xsl:call-template name="insertAnnexAndBibliographyInSeparatePageSequences"/>

		<!-- <xsl:call-template name="insertBibliographyInSeparatePageSequences"/> -->

		<!-- <xsl:call-template name="insertIndexInSeparatePageSequences"/> -->
	</xsl:template> <!-- END: insertMainSectionsInSeparatePageSequences -->

	<xsl:template name="insertAnnexAndBibliographyInSeparatePageSequences">
		<xsl:for-each select="/*/*[local-name()='annex'] |           /*/*[local-name()='bibliography']/*[not(@normative='true')] |           /*/*[local-name()='bibliography']/*[local-name()='clause'][*[local-name()='references'][not(@normative='true')]] |          /*/*[local-name()='indexsect']">
			<xsl:sort select="@displayorder" data-type="number"/>
			<xsl:choose>
				<xsl:when test="local-name() = 'annex' or local-name() = 'indexsect'">
					<xsl:element name="page_sequence" namespace="{$namespace_full}">
						<xsl:attribute name="main_page_sequence"/>
						<xsl:apply-templates select="." mode="update_xml_step_move_pagebreak"/>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise> <!-- bibliography -->
					<xsl:element name="bibliography" namespace="{$namespace_full}"> <!-- save context element -->
						<xsl:element name="page_sequence" namespace="{$namespace_full}">
							<xsl:attribute name="main_page_sequence"/>
							<xsl:apply-templates select="." mode="update_xml_step_move_pagebreak"/>
						</xsl:element>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="insertAnnexInSeparatePageSequences">
		<xsl:for-each select="/*/*[local-name()='annex']">
			<xsl:sort select="@displayorder" data-type="number"/>
			<xsl:element name="page_sequence" namespace="{$namespace_full}">
				<xsl:attribute name="main_page_sequence"/>
				<xsl:apply-templates select="." mode="update_xml_step_move_pagebreak"/>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="insertBibliographyInSeparatePageSequences">
		<xsl:element name="bibliography" namespace="{$namespace_full}"> <!-- save context element -->
			<xsl:for-each select="/*/*[local-name()='bibliography']/*[not(@normative='true')] |           /*/*[local-name()='bibliography']/*[local-name()='clause'][*[local-name()='references'][not(@normative='true')]]">
				<xsl:sort select="@displayorder" data-type="number"/>
				<xsl:element name="page_sequence" namespace="{$namespace_full}">
					<xsl:attribute name="main_page_sequence"/>
					<xsl:apply-templates select="." mode="update_xml_step_move_pagebreak"/>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
	<xsl:template name="insertIndexInSeparatePageSequences">
		<xsl:for-each select="/*/*[local-name()='indexsect']">
			<xsl:sort select="@displayorder" data-type="number"/>
			<xsl:element name="page_sequence" namespace="{$namespace_full}">
				<xsl:attribute name="main_page_sequence"/>
				<xsl:apply-templates select="." mode="update_xml_step_move_pagebreak"/>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="processAllSectionsDefault_items">
		<xsl:variable name="updated_xml_step_move_pagebreak">
			<xsl:element name="{$root_element}" namespace="{$namespace_full}">
				<xsl:call-template name="copyCommonElements"/>
				<xsl:element name="page_sequence" namespace="{$namespace_full}">
					<xsl:call-template name="insertPrefaceSections"/>
					<xsl:call-template name="insertMainSections"/>
				</xsl:element>
			</xsl:element>
		</xsl:variable>

		<xsl:variable name="updated_xml_step_move_pagebreak_filename" select="concat($output_path,'_preface_and_main_', java:getTime(java:java.util.Date.new()), '.xml')"/>
		<!-- <xsl:message>updated_xml_step_move_pagebreak_filename=<xsl:value-of select="$updated_xml_step_move_pagebreak_filename"/></xsl:message>
		<xsl:message>start write updated_xml_step_move_pagebreak_filename</xsl:message> -->
		<redirect:write file="{$updated_xml_step_move_pagebreak_filename}">
			<xsl:copy-of select="$updated_xml_step_move_pagebreak"/>
		</redirect:write>
		<!-- <xsl:message>end write updated_xml_step_move_pagebreak_filename</xsl:message> -->

		<xsl:copy-of select="document($updated_xml_step_move_pagebreak_filename)"/>

		<!-- TODO: instead of 
		<xsl:for-each select=".//*[local-name() = 'page_sequence'][normalize-space() != '' or .//image or .//svg]">
		in each template, add removing empty page_sequence here
		-->

		<xsl:if test="$debug = 'true'">
			<redirect:write file="page_sequence_preface_and_main.xml">
				<xsl:copy-of select="$updated_xml_step_move_pagebreak"/>
			</redirect:write>
		</xsl:if>

		<!-- <xsl:message>start delete updated_xml_step_move_pagebreak_filename</xsl:message> -->
		<xsl:call-template name="deleteFile">
			<xsl:with-param name="filepath" select="$updated_xml_step_move_pagebreak_filename"/>
		</xsl:call-template>
		<!-- <xsl:message>end delete updated_xml_step_move_pagebreak_filename</xsl:message> -->
	</xsl:template> <!-- END: processAllSectionsDefault_items -->

	<xsl:template name="insertPrefaceSections">
		<xsl:element name="preface" namespace="{$namespace_full}"> <!-- save context element -->
			<xsl:for-each select="/*/*[local-name()='preface']/*[not(local-name() = 'note' or local-name() = 'admonition')]">
				<xsl:sort select="@displayorder" data-type="number"/>
				<xsl:apply-templates select="." mode="update_xml_step_move_pagebreak">
					<xsl:with-param name="page_sequence_at_top">true</xsl:with-param>
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<xsl:template name="insertMainSections">
		<xsl:element name="sections" namespace="{$namespace_full}"> <!-- save context element -->

			<xsl:for-each select="/*/*[local-name()='sections']/* | /*/*[local-name()='bibliography']/*[local-name()='references'][@normative='true']">
				<xsl:sort select="@displayorder" data-type="number"/>
				<xsl:apply-templates select="." mode="update_xml_step_move_pagebreak">
					<xsl:with-param name="page_sequence_at_top">true</xsl:with-param>
				</xsl:apply-templates>

			</xsl:for-each>
		</xsl:element>

		<xsl:for-each select="/*/*[local-name()='annex']">
			<xsl:sort select="@displayorder" data-type="number"/>
			<xsl:apply-templates select="." mode="update_xml_step_move_pagebreak">
					<xsl:with-param name="page_sequence_at_top">true</xsl:with-param>
				</xsl:apply-templates>
		</xsl:for-each>

		<xsl:element name="bibliography" namespace="{$namespace_full}"> <!-- save context element -->
			<xsl:for-each select="/*/*[local-name()='bibliography']/*[not(@normative='true')] |           /*/*[local-name()='bibliography']/*[local-name()='clause'][*[local-name()='references'][not(@normative='true')]]">
				<xsl:sort select="@displayorder" data-type="number"/>
				<xsl:apply-templates select="." mode="update_xml_step_move_pagebreak">
					<xsl:with-param name="page_sequence_at_top">true</xsl:with-param>
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<xsl:template name="deleteFile">
		<xsl:param name="filepath"/>
		<xsl:variable name="xml_file" select="java:java.io.File.new($filepath)"/>
		<xsl:variable name="xml_file_path" select="java:toPath($xml_file)"/>
		<xsl:variable name="deletefile" select="java:java.nio.file.Files.deleteIfExists($xml_file_path)"/>
	</xsl:template>

	<xsl:template name="getPageSequenceOrientation">
		<xsl:variable name="previous_orientation" select="preceding-sibling::*[local-name() = 'page_sequence'][@orientation][1]/@orientation"/>
		<xsl:choose>
			<xsl:when test="@orientation = 'landscape'">-<xsl:value-of select="@orientation"/></xsl:when>
			<xsl:when test="$previous_orientation = 'landscape' and not(@orientation = 'portrait')">-<xsl:value-of select="$previous_orientation"/></xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:variable name="regex_standard_reference">([A-Z]{2,}(/[A-Z]{2,})* \d+(-\d+)*(:\d{4})?)</xsl:variable>
	<xsl:variable name="tag_fo_inline_keep-together_within-line_open">###fo:inline keep-together_within-line###</xsl:variable>
	<xsl:variable name="tag_fo_inline_keep-together_within-line_close">###/fo:inline keep-together_within-line###</xsl:variable>
	<xsl:template match="text()" name="text">

				<xsl:choose>
					<xsl:when test="ancestor::*[local-name() = 'table']"><xsl:value-of select="."/></xsl:when>
					<xsl:otherwise>
						<xsl:variable name="text" select="java:replaceAll(java:java.lang.String.new(.),$regex_standard_reference,concat($tag_fo_inline_keep-together_within-line_open,'$1',$tag_fo_inline_keep-together_within-line_close))"/>
						<xsl:call-template name="replace_fo_inline_tags">
							<xsl:with-param name="tag_open" select="$tag_fo_inline_keep-together_within-line_open"/>
							<xsl:with-param name="tag_close" select="$tag_fo_inline_keep-together_within-line_close"/>
							<xsl:with-param name="text" select="$text"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>

	</xsl:template>

	<xsl:template name="replace_fo_inline_tags">
		<xsl:param name="tag_open"/>
		<xsl:param name="tag_close"/>
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="contains($text, $tag_open)">
				<xsl:value-of select="substring-before($text, $tag_open)"/>
				<!-- <xsl:text disable-output-escaping="yes">&lt;fo:inline keep-together.within-line="always"&gt;</xsl:text> -->
				<xsl:variable name="text_after" select="substring-after($text, $tag_open)"/>
				<xsl:choose>
					<xsl:when test="local-name(..) = 'keep-together_within-line'"> <!-- prevent two nested <fo:inline keep-together.within-line="always"><fo:inline keep-together.within-line="always" -->
						<xsl:value-of select="substring-before($text_after, $tag_close)"/>
					</xsl:when>
					<xsl:otherwise>
						<fo:inline keep-together.within-line="always" role="SKIP">
							<xsl:value-of select="substring-before($text_after, $tag_close)"/>
						</fo:inline>
					</xsl:otherwise>
				</xsl:choose>
				<!-- <xsl:text disable-output-escaping="yes">&lt;/fo:inline&gt;</xsl:text> -->
				<xsl:call-template name="replace_fo_inline_tags">
					<xsl:with-param name="tag_open" select="$tag_open"/>
					<xsl:with-param name="tag_close" select="$tag_close"/>
					<xsl:with-param name="text" select="substring-after($text_after, $tag_close)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[local-name()='br']">
		<xsl:value-of select="$linebreak"/>
	</xsl:template>

	<!-- keep-together for standard's name (ISO 12345:2020) -->
	<xsl:template match="*[local-name() = 'keep-together_within-line']">
		<xsl:param name="split_keep-within-line"/>

		<!-- <fo:inline>split_keep-within-line='<xsl:value-of select="$split_keep-within-line"/>'</fo:inline> -->
		<xsl:choose>

			<xsl:when test="normalize-space($split_keep-within-line) = 'true'">
				<xsl:variable name="sep">_</xsl:variable>
				<xsl:variable name="items">
					<xsl:call-template name="split">
						<xsl:with-param name="pText" select="."/>
						<xsl:with-param name="sep" select="$sep"/>
						<xsl:with-param name="normalize-space">false</xsl:with-param>
						<xsl:with-param name="keep_sep">true</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:for-each select="xalan:nodeset($items)/item">
					<xsl:choose>
						<xsl:when test=". = $sep">
							<xsl:value-of select="$sep"/><xsl:value-of select="$zero_width_space"/>
						</xsl:when>
						<xsl:otherwise>
							<fo:inline keep-together.within-line="always" role="SKIP"><xsl:apply-templates/></fo:inline>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>

			<xsl:otherwise>
				<fo:inline keep-together.within-line="always" role="SKIP"><xsl:apply-templates/></fo:inline>
			</xsl:otherwise>

		</xsl:choose>
	</xsl:template>

	<!-- ================================= -->
	<!-- Preface boilerplate sections processing -->
	<!-- ================================= -->
	<xsl:template match="*[local-name()='copyright-statement']">
		<fo:block xsl:use-attribute-sets="copyright-statement-style" role="SKIP">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template> <!-- copyright-statement -->

	<xsl:template match="*[local-name()='copyright-statement']//*[local-name()='title']">

				<!-- process in the template 'title' -->
				<xsl:call-template name="title"/>

	</xsl:template> <!-- copyright-statement//title -->

	<xsl:template match="*[local-name()='copyright-statement']//*[local-name()='p']">

				<!-- process in the template 'paragraph' -->
				<xsl:call-template name="paragraph"/>

	</xsl:template> <!-- copyright-statement//p -->

	<xsl:template match="*[local-name()='license-statement']">
		<fo:block xsl:use-attribute-sets="license-statement-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template> <!-- license-statement -->

	<xsl:template match="*[local-name()='license-statement']//*[local-name()='title']">

				<!-- process in the template 'title' -->
				<xsl:call-template name="title"/>

	</xsl:template> <!-- license-statement/title -->

	<xsl:template match="*[local-name()='license-statement']//*[local-name()='p']">

				<!-- process in the template 'paragraph' -->
				<xsl:call-template name="paragraph"/>

	</xsl:template> <!-- license-statement/p -->

	<xsl:template match="*[local-name()='legal-statement']">
		<xsl:param name="isLegacy">false</xsl:param>
		<fo:block xsl:use-attribute-sets="legal-statement-style">

			<xsl:apply-templates/>
		</fo:block>
	</xsl:template> <!-- legal-statement -->

	<xsl:template match="*[local-name()='legal-statement']//*[local-name()='title']">

				<!-- process in the template 'title' -->
				<xsl:call-template name="title"/>

	</xsl:template> <!-- legal-statement/title -->

	<xsl:template match="*[local-name()='legal-statement']//*[local-name()='p']">
		<xsl:param name="margin"/>

				<!-- process in the template 'paragraph' -->
				<xsl:call-template name="paragraph">
					<xsl:with-param name="margin" select="$margin"/>
				</xsl:call-template>

	</xsl:template> <!-- legal-statement/p -->

	<xsl:template match="*[local-name()='feedback-statement']">
		<fo:block xsl:use-attribute-sets="feedback-statement-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template> <!-- feedback-statement -->

	<xsl:template match="*[local-name()='feedback-statement']//*[local-name()='title']">

				<!-- process in the template 'title' -->
				<xsl:call-template name="title"/>

	</xsl:template>

	<xsl:template match="*[local-name()='feedback-statement']//*[local-name()='p']">
		<xsl:param name="margin"/>

				<!-- process in the template 'paragraph' -->
				<xsl:call-template name="paragraph">
					<xsl:with-param name="margin" select="$margin"/>
				</xsl:call-template>

	</xsl:template>

	<!-- ================================= -->
	<!-- END Preface boilerplate sections processing -->
	<!-- ================================= -->

	<!-- add zero spaces into table cells text -->
	<xsl:template match="*[local-name()='td']//text() | *[local-name()='th']//text() | *[local-name()='dt']//text() | *[local-name()='dd']//text()" priority="1">
		<xsl:choose>
			<xsl:when test="parent::*[local-name() = 'keep-together_within-line']">
				<xsl:value-of select="."/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="addZeroWidthSpacesToTextNodes"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="addZeroWidthSpacesToTextNodes">
		<xsl:variable name="text"><text><xsl:call-template name="text"/></text></xsl:variable>
		<!-- <xsl:copy-of select="$text"/> -->
		<xsl:for-each select="xalan:nodeset($text)/text/node()">
			<xsl:choose>
				<xsl:when test="self::text()"><xsl:call-template name="add-zero-spaces-java"/></xsl:when>
				<xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise> <!-- copy 'as-is' for <fo:inline keep-together.within-line="always" ...  -->
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<!-- for table auto-layout algorithm -->
	<xsl:param name="table_only_with_id"/> <!-- Example: 'table1' -->
	<xsl:param name="table_only_with_ids"/> <!-- Example: 'table1 table2 table3 ' -->

	<xsl:template match="*[local-name()='table']" priority="2">
		<xsl:choose>
			<xsl:when test="$table_only_with_id != '' and @id = $table_only_with_id">
				<xsl:call-template name="table"/>
			</xsl:when>
			<xsl:when test="$table_only_with_id != ''"><fo:block/><!-- to prevent empty fo:block-container --></xsl:when>
			<xsl:when test="$table_only_with_ids != '' and contains($table_only_with_ids, concat(@id, ' '))">
				<xsl:call-template name="table"/>
			</xsl:when>
			<xsl:when test="$table_only_with_ids != ''"><fo:block/><!-- to prevent empty fo:block-container --></xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="table"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[local-name()='table']" name="table">

		<xsl:variable name="table-preamble">

		</xsl:variable>

		<xsl:variable name="table">

			<xsl:variable name="simple-table">
				<xsl:if test="$isGenerateTableIF = 'true' and $isApplyAutolayoutAlgorithm = 'true'">
					<xsl:call-template name="getSimpleTable">
						<xsl:with-param name="id" select="@id"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:variable>
			<!-- <xsl:variable name="simple-table" select="xalan:nodeset($simple-table_)"/> -->

			<!-- simple-table=<xsl:copy-of select="$simple-table"/> -->

			<!-- Display table's name before table as standalone block -->
			<!-- $namespace = 'iso' or  -->

					<xsl:apply-templates select="*[local-name()='name']"/> <!-- table's title rendered before table -->

					<xsl:call-template name="table_name_fn_display"/>

			<xsl:variable name="cols-count" select="count(xalan:nodeset($simple-table)/*/tr[1]/td)"/>

			<xsl:variable name="colwidths">
				<xsl:if test="not(*[local-name()='colgroup']/*[local-name()='col']) and not(@class = 'dl')">
					<xsl:call-template name="calculate-column-widths">
						<xsl:with-param name="cols-count" select="$cols-count"/>
						<xsl:with-param name="table" select="$simple-table"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:variable>
			<!-- <xsl:variable name="colwidths" select="xalan:nodeset($colwidths_)"/> -->

			<!-- DEBUG -->
			<xsl:if test="$table_if_debug = 'true'">
				<fo:block font-size="60%">
					<xsl:apply-templates select="xalan:nodeset($colwidths)" mode="print_as_xml"/>
				</fo:block>
			</xsl:if>

			<!-- <xsl:copy-of select="$colwidths"/> -->

			<!-- <xsl:text disable-output-escaping="yes">&lt;!- -</xsl:text>
			DEBUG
			colwidths=<xsl:copy-of select="$colwidths"/>
		<xsl:text disable-output-escaping="yes">- -&gt;</xsl:text> -->

			<xsl:variable name="margin-side">
				<xsl:choose>
					<xsl:when test="$isApplyAutolayoutAlgorithm = 'true'">0</xsl:when>
					<xsl:when test="$isApplyAutolayoutAlgorithm = 'skip'">0</xsl:when>
					<xsl:when test="sum(xalan:nodeset($colwidths)//column) &gt; 75">15</xsl:when>
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<fo:block-container xsl:use-attribute-sets="table-container-style" role="SKIP">

				<xsl:call-template name="refine_table-container-style">
					<xsl:with-param name="margin-side" select="$margin-side"/>
				</xsl:call-template>

				<!-- display table's name before table for PAS inside block-container (2-columnn layout) -->

				<xsl:variable name="table_width_default">100%</xsl:variable>
				<xsl:variable name="table_width">
					<!-- for centered table always 100% (@width will be set for middle/second cell of outer table) -->
					<xsl:value-of select="$table_width_default"/>
				</xsl:variable>

				<xsl:variable name="table_attributes">

					<xsl:element name="table_attributes" use-attribute-sets="table-style">

						<xsl:if test="$margin-side != 0">
							<xsl:attribute name="margin-left">0mm</xsl:attribute>
							<xsl:attribute name="margin-right">0mm</xsl:attribute>
						</xsl:if>

						<xsl:attribute name="width"><xsl:value-of select="normalize-space($table_width)"/></xsl:attribute>

						<xsl:call-template name="refine_table-style">
							<xsl:with-param name="margin-side" select="$margin-side"/>
						</xsl:call-template>

					</xsl:element>
				</xsl:variable>

				<xsl:if test="$isGenerateTableIF = 'true'">
					<!-- to determine start of table -->
					<fo:block id="{concat('table_if_start_',@id)}" keep-with-next="always" font-size="1pt">Start table '<xsl:value-of select="@id"/>'.</fo:block>
				</xsl:if>

				<fo:table id="{@id}">

					<xsl:if test="$isGenerateTableIF = 'true'">
						<xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
					</xsl:if>

					<xsl:for-each select="xalan:nodeset($table_attributes)/table_attributes/@*">
						<xsl:attribute name="{local-name()}">
							<xsl:value-of select="."/>
						</xsl:attribute>
					</xsl:for-each>

					<xsl:variable name="isNoteOrFnExist" select="./*[local-name()='note'][not(@type = 'units')] or ./*[local-name()='example'] or .//*[local-name()='fn'][local-name(..) != 'name'] or ./*[local-name()='source']"/>
					<xsl:if test="$isNoteOrFnExist = 'true'">
						<!-- <xsl:choose>
							<xsl:when test="$namespace = 'plateau'"></xsl:when>
							<xsl:otherwise>
								
							</xsl:otherwise>
						</xsl:choose> -->
						<xsl:attribute name="border-bottom">0pt solid black</xsl:attribute><!-- set 0pt border, because there is a separete table below for footer -->
					</xsl:if>

					<xsl:choose>
						<xsl:when test="$isGenerateTableIF = 'true'">
							<!-- generate IF for table widths -->
							<!-- example:
								<tr>
									<td valign="top" align="left" id="tab-symdu_1_1">
										<p>Symbol</p>
										<word id="tab-symdu_1_1_word_1">Symbol</word>
									</td>
									<td valign="top" align="left" id="tab-symdu_1_2">
										<p>Description</p>
										<word id="tab-symdu_1_2_word_1">Description</word>
									</td>
								</tr>
							-->
							<!-- Simple_table=<xsl:copy-of select="$simple-table"/> -->
							<xsl:apply-templates select="xalan:nodeset($simple-table)" mode="process_table-if"/>

						</xsl:when>
						<xsl:otherwise>

							<xsl:choose>
								<xsl:when test="*[local-name()='colgroup']/*[local-name()='col']">
									<xsl:for-each select="*[local-name()='colgroup']/*[local-name()='col']">
										<fo:table-column column-width="{@width}"/>
									</xsl:for-each>
								</xsl:when>
								<xsl:when test="@class = 'dl'">
									<xsl:for-each select=".//*[local-name()='tr'][1]/*">
										<fo:table-column column-width="{@width}"/>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="insertTableColumnWidth">
										<xsl:with-param name="colwidths" select="$colwidths"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>

							<xsl:choose>
								<xsl:when test="not(*[local-name()='tbody']) and *[local-name()='thead']">
									<xsl:apply-templates select="*[local-name()='thead']" mode="process_tbody"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="node()[not(local-name() = 'name') and not(local-name() = 'note') and not(local-name() = 'example') and not(local-name() = 'dl') and not(local-name() = 'source') and not(local-name() = 'p')          and not(local-name() = 'thead') and not(local-name() = 'tfoot') and not(local-name() = 'fmt-footnote-container')]"/> <!-- process all table' elements, except name, header, footer, note, source and dl which render separaterely -->
								</xsl:otherwise>
							</xsl:choose>

						</xsl:otherwise>
					</xsl:choose>

				</fo:table>

				<xsl:variable name="colgroup" select="*[local-name()='colgroup']"/>

				<!-- https://github.com/metanorma/metanorma-plateau/issues/171 -->

				<xsl:for-each select="*[local-name()='tbody']"><!-- select context to tbody -->
					<xsl:call-template name="insertTableFooterInSeparateTable">
						<xsl:with-param name="table_attributes" select="$table_attributes"/>
						<xsl:with-param name="colwidths" select="$colwidths"/>
						<xsl:with-param name="colgroup" select="$colgroup"/>
					</xsl:call-template>
				</xsl:for-each>

				<!-- https://github.com/metanorma/metanorma-plateau/issues/171
				<xsl:if test="$namespace = 'plateau'">
					<xsl:apply-templates select="*[not(local-name()='thead') and not(local-name()='tbody') and not(local-name()='tfoot') and not(local-name()='name')]" />
					<xsl:for-each select="*[local-name()='tbody']"> - select context to tbody -
						<xsl:variable name="table_fn_block">
							<xsl:call-template name="table_fn_display" />
						</xsl:variable>
						<xsl:copy-of select="$table_fn_block"/>
					</xsl:for-each>
				</xsl:if> -->

				<xsl:if test="*[local-name()='bookmark']"> <!-- special case: table/bookmark -->
					<fo:block keep-with-previous="always" line-height="0.1">
						<xsl:for-each select="*[local-name()='bookmark']">
							<xsl:call-template name="bookmark"/>
						</xsl:for-each>
					</fo:block>
				</xsl:if>

			</fo:block-container>
		</xsl:variable> <!-- END: variable name="table" -->

		<xsl:variable name="isAdded" select="@added"/>
		<xsl:variable name="isDeleted" select="@deleted"/>

		<xsl:choose>
			<xsl:when test="@width and @width != 'full-page-width' and @width != 'text-width'">

				<!-- centered table when table name is centered (see table-name-style) -->

					<fo:table table-layout="fixed" width="100%" xsl:use-attribute-sets="table-container-style" role="SKIP">

						<fo:table-column column-width="proportional-column-width(1)"/>
						<fo:table-column column-width="{@width}"/>
						<fo:table-column column-width="proportional-column-width(1)"/>
						<fo:table-body role="SKIP">
							<fo:table-row role="SKIP">
								<fo:table-cell column-number="2" role="SKIP">
									<xsl:copy-of select="$table-preamble"/>
									<fo:block role="SKIP">
										<xsl:call-template name="setTrackChangesStyles">
											<xsl:with-param name="isAdded" select="$isAdded"/>
											<xsl:with-param name="isDeleted" select="$isDeleted"/>
										</xsl:call-template>
										<xsl:copy-of select="$table"/>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>

			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$isAdded = 'true' or $isDeleted = 'true'">
						<xsl:copy-of select="$table-preamble"/>
						<fo:block>
							<xsl:call-template name="setTrackChangesStyles">
								<xsl:with-param name="isAdded" select="$isAdded"/>
								<xsl:with-param name="isDeleted" select="$isDeleted"/>
							</xsl:call-template>
							<xsl:copy-of select="$table"/>
						</fo:block>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="$table-preamble"/>
						<xsl:copy-of select="$table"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="setBordersTableArray">

	</xsl:template>

	<!-- table/name-->
	<xsl:template match="*[local-name()='table']/*[local-name() = 'name']">
		<xsl:param name="continued"/>
		<xsl:if test="normalize-space() != ''">

					<fo:block xsl:use-attribute-sets="table-name-style">

						<xsl:call-template name="refine_table-name-style">
							<xsl:with-param name="continued" select="$continued"/>
						</xsl:call-template>

						<xsl:choose>
							<xsl:when test="$continued = 'true'">

							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates/>
							</xsl:otherwise>
						</xsl:choose>

					</fo:block>

					<!-- <xsl:if test="$namespace = 'bsi' or $namespace = 'iec' or $namespace = 'iso'"> -->
					<xsl:if test="$continued = 'true'">
						<fo:block text-align="right">
							<xsl:apply-templates select="../*[local-name() = 'note'][@type = 'units']/node()"/>
						</fo:block>
					</xsl:if>
					<!-- </xsl:if> -->

		</xsl:if>
	</xsl:template> <!-- table/name -->

	<!-- workaround solution for https://github.com/metanorma/metanorma-iso/issues/1151#issuecomment-2033087938 -->
	<xsl:template match="*[local-name()='table']/*[local-name() = 'note'][@type = 'units']/*[local-name() = 'p']/text()" priority="4">
		<xsl:choose>
			<xsl:when test="preceding-sibling::*[local-name() = 'br']">
				<!-- remove CR or LF at start -->
				<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.),'^(&#13;&#10;|&#13;|&#10;)', '')"/>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- SOURCE: ... -->
	<xsl:template match="*[local-name()='table']/*[local-name() = 'source']" priority="2">
		<xsl:call-template name="termsource"/>
	</xsl:template>

	<xsl:template name="calculate-columns-numbers">
		<xsl:param name="table-row"/>
		<xsl:variable name="columns-count" select="count($table-row/*)"/>
		<xsl:variable name="sum-colspans" select="sum($table-row/*/@colspan)"/>
		<xsl:variable name="columns-with-colspan" select="count($table-row/*[@colspan])"/>
		<xsl:value-of select="$columns-count + $sum-colspans - $columns-with-colspan"/>
	</xsl:template>

	<xsl:template name="calculate-column-widths">
		<xsl:param name="table"/>
		<xsl:param name="cols-count"/>
		<xsl:choose>
			<xsl:when test="$isApplyAutolayoutAlgorithm = 'true'">
				<xsl:call-template name="get-calculated-column-widths-autolayout-algorithm"/>
			</xsl:when>
			<xsl:when test="$isApplyAutolayoutAlgorithm = 'skip'"/>
			<xsl:otherwise>
				<xsl:call-template name="calculate-column-widths-proportional">
					<xsl:with-param name="cols-count" select="$cols-count"/>
					<xsl:with-param name="table" select="$table"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ================================================== -->
	<!-- Calculate column's width based on text string max widths -->
	<!-- ================================================== -->
	<xsl:template name="calculate-column-widths-proportional">
		<xsl:param name="table"/>
		<xsl:param name="cols-count"/>
		<xsl:param name="curr-col" select="1"/>
		<xsl:param name="width" select="0"/>

		<!-- table=<xsl:copy-of select="$table"/> -->

		<xsl:if test="$curr-col &lt;= $cols-count">
			<xsl:variable name="widths">
				<xsl:choose>
					<xsl:when test="not($table)"><!-- this branch is not using in production, for debug only -->
						<xsl:for-each select="*[local-name()='thead']//*[local-name()='tr']">
							<xsl:variable name="words">
								<xsl:call-template name="tokenize">
									<xsl:with-param name="text" select="translate(*[local-name()='th'][$curr-col],'- —:', '    ')"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:variable name="max_length">
								<xsl:call-template name="max_length">
									<xsl:with-param name="words" select="xalan:nodeset($words)"/>
								</xsl:call-template>
							</xsl:variable>
							<width>
								<xsl:value-of select="$max_length"/>
							</width>
						</xsl:for-each>
						<xsl:for-each select="*[local-name()='tbody']//*[local-name()='tr']">
							<xsl:variable name="words">
								<xsl:call-template name="tokenize">
									<xsl:with-param name="text" select="translate(*[local-name()='td'][$curr-col],'- —:', '    ')"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:variable name="max_length">
								<xsl:call-template name="max_length">
									<xsl:with-param name="words" select="xalan:nodeset($words)"/>
								</xsl:call-template>
							</xsl:variable>
							<width>
								<xsl:value-of select="$max_length"/>
							</width>

						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<!-- <curr_col><xsl:value-of select="$curr-col"/></curr_col> -->

						<!-- <table><xsl:copy-of select="$table"/></table>
						 -->
						<xsl:for-each select="xalan:nodeset($table)/*/*[local-name()='tr']">
							<xsl:variable name="td_text">
								<xsl:apply-templates select="td[$curr-col]" mode="td_text"/>
							</xsl:variable>
							<!-- <td_text><xsl:value-of select="$td_text"/></td_text> -->
							<xsl:variable name="words">
								<xsl:variable name="string_with_added_zerospaces">
									<xsl:call-template name="add-zero-spaces-java">
										<xsl:with-param name="text" select="$td_text"/>
									</xsl:call-template>
								</xsl:variable>
								<!-- <xsl:message>string_with_added_zerospaces=<xsl:value-of select="$string_with_added_zerospaces"/></xsl:message> -->
								<xsl:call-template name="tokenize">
									<!-- <xsl:with-param name="text" select="translate(td[$curr-col],'- —:', '    ')"/> -->
									<!-- 2009 thinspace -->
									<!-- <xsl:with-param name="text" select="translate(normalize-space($td_text),'- —:', '    ')"/> -->
									<xsl:with-param name="text" select="normalize-space(translate($string_with_added_zerospaces, '​­', '  '))"/> <!-- replace zero-width-space and soft-hyphen to space -->
								</xsl:call-template>
							</xsl:variable>
							<!-- words=<xsl:copy-of select="$words"/> -->
							<xsl:variable name="max_length">
								<xsl:call-template name="max_length">
									<xsl:with-param name="words" select="xalan:nodeset($words)"/>
								</xsl:call-template>
							</xsl:variable>
							<!-- <xsl:message>max_length=<xsl:value-of select="$max_length"/></xsl:message> -->
							<width>
								<xsl:variable name="divider">
									<xsl:choose>
										<xsl:when test="td[$curr-col]/@divide">
											<xsl:value-of select="td[$curr-col]/@divide"/>
										</xsl:when>
										<xsl:otherwise>1</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:value-of select="$max_length div $divider"/>
							</width>

						</xsl:for-each>

					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<!-- widths=<xsl:copy-of select="$widths"/> -->

			<column>
				<xsl:for-each select="xalan:nodeset($widths)//width">
					<xsl:sort select="." data-type="number" order="descending"/>
					<xsl:if test="position()=1">
							<xsl:value-of select="."/>
					</xsl:if>
				</xsl:for-each>
			</column>
			<xsl:call-template name="calculate-column-widths-proportional">
				<xsl:with-param name="cols-count" select="$cols-count"/>
				<xsl:with-param name="curr-col" select="$curr-col +1"/>
				<xsl:with-param name="table" select="$table"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template> <!-- calculate-column-widths-proportional -->

	<!-- ================================= -->
	<!-- mode="td_text" -->
	<!-- ================================= -->
	<!-- replace each each char to 'X', just to process the tag 'keep-together_within-line' as whole word in longest word calculation -->
	<xsl:template match="*[@keep-together.within-line or local-name() = 'keep-together_within-line']/text()" priority="2" mode="td_text">
		<!-- <xsl:message>DEBUG t1=<xsl:value-of select="."/></xsl:message>
		<xsl:message>DEBUG t2=<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.),'.','X')"/></xsl:message> -->
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.),'.','X')"/>

		<!-- if all capitals english letters or digits -->
		<xsl:if test="normalize-space(translate(., concat($upper,'0123456789'), '')) = ''">
			<xsl:call-template name="repeat">
				<xsl:with-param name="char" select="'X'"/>
				<xsl:with-param name="count" select="string-length(normalize-space(.)) * 0.5"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="text()" mode="td_text">
		<xsl:value-of select="translate(., $zero_width_space, ' ')"/><xsl:text> </xsl:text>
	</xsl:template>

	<xsl:template match="*[local-name()='termsource']" mode="td_text">
		<xsl:value-of select="*[local-name()='origin']/@citeas"/>
	</xsl:template>

	<xsl:template match="*[local-name()='link']" mode="td_text">
		<xsl:value-of select="@target"/>
	</xsl:template>

	<xsl:template match="*[local-name()='math']" mode="td_text" name="math_length">
		<xsl:if test="$isGenerateTableIF = 'false'">
			<xsl:variable name="mathml_">
				<xsl:for-each select="*">
					<xsl:if test="local-name() != 'unit' and local-name() != 'prefix' and local-name() != 'dimension' and local-name() != 'quantity'">
						<xsl:copy-of select="."/>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:variable name="mathml" select="xalan:nodeset($mathml_)"/>

			<xsl:variable name="math_text">
				<xsl:value-of select="normalize-space($mathml)"/>
				<xsl:for-each select="$mathml//@open"><xsl:value-of select="."/></xsl:for-each>
				<xsl:for-each select="$mathml//@close"><xsl:value-of select="."/></xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="translate($math_text, ' ', '#')"/><!-- mathml images as one 'word' without spaces -->
		</xsl:if>
	</xsl:template>
	<!-- ================================= -->
	<!-- END mode="td_text" -->
	<!-- ================================= -->
	<!-- ================================================== -->
	<!-- END Calculate column's width based on text string max widths -->
	<!-- ================================================== -->

	<!-- ================================================== -->
	<!-- Calculate column's width based on HTML4 algorithm -->
	<!-- (https://www.w3.org/TR/REC-html40/appendix/notes.html#h-B.5.2) -->
	<!-- ================================================== -->

	<!-- INPUT: table with columns widths, generated by table_if.xsl  -->
	<xsl:template name="calculate-column-widths-autolayout-algorithm">
		<xsl:param name="parent_table_page-width"/> <!-- for nested tables, in re-calculate step -->

		<!-- via intermediate format -->

		<!-- The algorithm uses two passes through the table data and scales linearly with the size of the table -->

		<!-- In the first pass, line wrapping is disabled, and the user agent keeps track of the minimum and maximum width of each cell. -->

		<!-- Since line wrap has been disabled, paragraphs are treated as long lines unless broken by BR elements. -->

		<xsl:variable name="page_width">
			<xsl:choose>
				<xsl:when test="$parent_table_page-width != ''">
					<xsl:value-of select="$parent_table_page-width"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@page-width"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="$table_if_debug = 'true'">
			<page_width><xsl:value-of select="$page_width"/></page_width>
		</xsl:if>

		<!-- There are three cases: -->
		<xsl:choose>
			<!-- 1. The minimum table width is equal to or wider than the available space -->
			<xsl:when test="@width_min &gt;= $page_width and 1 = 2"> <!-- this condition isn't working see case 3 below -->
				<!-- call old algorithm -->
				<case1/>
				<!-- <xsl:variable name="cols-count" select="count(xalan:nodeset($table)/*/tr[1]/td)"/>
				<xsl:call-template name="calculate-column-widths-proportional">
					<xsl:with-param name="cols-count" select="$cols-count"/>
					<xsl:with-param name="table" select="$table"/>
				</xsl:call-template> -->
			</xsl:when>
			<!-- 2. The maximum table width fits within the available space. In this case, set the columns to their maximum widths. -->
			<xsl:when test="@width_max &lt;= $page_width">
				<case2/>
				<autolayout/>
				<xsl:for-each select="column/@width_max">
					<column divider="100"><xsl:value-of select="."/></column>
				</xsl:for-each>
			</xsl:when>
			<!-- 3. The maximum width of the table is greater than the available space, but the minimum table width is smaller. 
			In this case, find the difference between the available space and the minimum table width, lets call it W. 
			Lets also call D the difference between maximum and minimum width of the table. 
			For each column, let d be the difference between maximum and minimum width of that column. 
			Now set the column's width to the minimum width plus d times W over D. 
			This makes columns with large differences between minimum and maximum widths wider than columns with smaller differences. -->
			<xsl:when test="(@width_max &gt; $page_width and @width_min &lt; $page_width) or (@width_min &gt;= $page_width)">
				<!-- difference between the available space and the minimum table width -->
				<_width_min><xsl:value-of select="@width_min"/></_width_min>
				<xsl:variable name="W" select="$page_width - @width_min"/>
				<W><xsl:value-of select="$W"/></W>
				<!-- difference between maximum and minimum width of the table -->
				<xsl:variable name="D" select="@width_max - @width_min"/>
				<D><xsl:value-of select="$D"/></D>
				<case3/>
				<autolayout/>
				<xsl:if test="@width_min &gt;= $page_width">
					<split_keep-within-line>true</split_keep-within-line>
				</xsl:if>
				<xsl:for-each select="column">
					<!-- difference between maximum and minimum width of that column.  -->
					<xsl:variable name="d" select="@width_max - @width_min"/>
					<d><xsl:value-of select="$d"/></d>
					<width_min><xsl:value-of select="@width_min"/></width_min>
					<e><xsl:value-of select="$d * $W div $D"/></e>
					<!-- set the column's width to the minimum width plus d times W over D.  -->
					<xsl:variable name="column_width_" select="round(@width_min + $d * $W div $D)"/> <!--  * 10 -->
					<xsl:variable name="column_width" select="$column_width_*($column_width_ &gt;= 0) - $column_width_*($column_width_ &lt; 0)"/> <!-- absolute value -->
					<column divider="100">
						<xsl:value-of select="$column_width"/>
					</column>
				</xsl:for-each>

			</xsl:when>
			<xsl:otherwise><unknown_case/></xsl:otherwise>
		</xsl:choose>

	</xsl:template> <!-- calculate-column-widths-autolayout-algorithm -->

	<xsl:template name="get-calculated-column-widths-autolayout-algorithm">

		<!-- if nested 'dl' or 'table' -->
		<xsl:variable name="parent_table_id" select="normalize-space(ancestor::*[local-name() = 'table' or local-name() = 'dl'][1]/@id)"/>
		<parent_table_id><xsl:value-of select="$parent_table_id"/></parent_table_id>

		<parent_element><xsl:value-of select="local-name(..)"/></parent_element>

		<ancestor_tree>
			<xsl:for-each select="ancestor::*">
				<ancestor><xsl:value-of select="local-name()"/></ancestor>
			</xsl:for-each>
		</ancestor_tree>

		<xsl:variable name="parent_table_page-width_">
			<xsl:if test="$parent_table_id != ''">
				<!-- determine column number in the parent table -->
				<xsl:variable name="parent_table_column_number">
					<xsl:choose>
						<!-- <xsl:when test="parent::*[local-name() = 'dd']">2</xsl:when> -->
						<xsl:when test="(ancestor::*[local-name() = 'dd' or local-name() = 'table' or local-name() = 'dl'])[last()][local-name() = 'dd' or local-name() = 'dl']">2</xsl:when>
						<xsl:otherwise> <!-- parent is table -->
							<xsl:value-of select="count(ancestor::*[local-name() = 'td'][1]/preceding-sibling::*[local-name() = 'td']) + 1"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<!-- find table by id in the file 'table_widths' and get all Nth `<column>...</column> -->

				<xsl:variable name="parent_table_column_" select="$table_widths_from_if_calculated//table[@id = $parent_table_id]/column[number($parent_table_column_number)]"/>
				<xsl:variable name="parent_table_column" select="xalan:nodeset($parent_table_column_)"/>
				<!-- <xsl:variable name="divider">
					<xsl:value-of select="$parent_table_column/@divider"/>
					<xsl:if test="not($parent_table_column/@divider)">1</xsl:if>
				</xsl:variable> -->
				<xsl:value-of select="$parent_table_column/text()"/> <!--  * 10 -->
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="parent_table_page-width" select="normalize-space($parent_table_page-width_)"/>

		<parent_table_page-width><xsl:value-of select="$parent_table_page-width"/></parent_table_page-width>

		<!-- get current table id -->
		<xsl:variable name="table_id" select="@id"/>

		<xsl:choose>
			<xsl:when test="$parent_table_id = '' or $parent_table_page-width = ''">
				<!-- find table by id in the file 'table_widths' and get all `<column>...</column> -->
				<xsl:copy-of select="$table_widths_from_if_calculated//table[@id = $table_id]/node()"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- recalculate columns width based on parent table width -->
				<xsl:for-each select="$table_widths_from_if//table[@id = $table_id]">
					<xsl:call-template name="calculate-column-widths-autolayout-algorithm">
						<xsl:with-param name="parent_table_page-width" select="$parent_table_page-width"/> <!-- padding-left = 2mm  = 50000-->
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template> <!-- get-calculated-column-widths-autolayout-algorithm -->

	<!-- ================================================== -->
	<!-- Calculate column's width based on HTML4 algorithm -->
	<!-- ================================================== -->

	<xsl:template match="*[local-name()='thead']">
		<xsl:param name="cols-count"/>
		<fo:table-header>

			<xsl:apply-templates/>
		</fo:table-header>
	</xsl:template> <!-- thead -->

	<!-- template is using for iec, iso, jcgm, bsi only -->
	<xsl:template name="table-header-title">
		<xsl:param name="cols-count"/>
		<!-- row for title -->
		<fo:table-row role="SKIP">
			<fo:table-cell number-columns-spanned="{$cols-count}" border-left="1.5pt solid white" border-right="1.5pt solid white" border-top="1.5pt solid white" border-bottom="1.5pt solid black" role="SKIP">

				<xsl:call-template name="refine_table-header-title-style"/>

						<xsl:apply-templates select="ancestor::*[local-name()='table']/*[local-name()='name']">
							<xsl:with-param name="continued">true</xsl:with-param>
						</xsl:apply-templates>

						<xsl:if test="not(ancestor::*[local-name()='table']/*[local-name()='name'])"> <!-- to prevent empty fo:table-cell in case of missing table's name -->
							<fo:block role="SKIP"/>
						</xsl:if>

			</fo:table-cell>
		</fo:table-row>
	</xsl:template> <!-- table-header-title -->

	<xsl:template name="refine_table-header-title-style">

	</xsl:template> <!-- refine_table-header-title-style -->

	<xsl:template match="*[local-name()='thead']" mode="process_tbody">
		<fo:table-body>
			<xsl:apply-templates/>
		</fo:table-body>
	</xsl:template>

	<xsl:template match="*[local-name()='tfoot']">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template name="insertTableFooter">
		<xsl:param name="cols-count"/>
		<xsl:if test="../*[local-name()='tfoot']">
			<fo:table-footer>
				<xsl:apply-templates select="../*[local-name()='tfoot']"/>
			</fo:table-footer>
		</xsl:if>
	</xsl:template>

	<xsl:template name="insertTableFooterInSeparateTable">
		<xsl:param name="table_attributes"/>
		<xsl:param name="colwidths"/>
		<xsl:param name="colgroup"/>

		<xsl:variable name="isNoteOrFnExist" select="../*[local-name()='note'][not(@type = 'units')] or ../*[local-name()='example'] or ../*[local-name()='dl'] or ..//*[local-name()='fn'][local-name(..) != 'name'] or ../*[local-name()='source'] or ../*[local-name()='p']"/>

		<xsl:variable name="isNoteOrFnExistShowAfterTable">

		</xsl:variable>

		<xsl:if test="$isNoteOrFnExist = 'true' or normalize-space($isNoteOrFnExistShowAfterTable) = 'true'">

			<xsl:variable name="cols-count">
				<xsl:choose>
					<xsl:when test="xalan:nodeset($colgroup)//*[local-name()='col']">
						<xsl:value-of select="count(xalan:nodeset($colgroup)//*[local-name()='col'])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="count(xalan:nodeset($colwidths)//column)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="table_fn_block">
				<xsl:call-template name="table_fn_display"/>
			</xsl:variable>

			<xsl:variable name="tableWithNotesAndFootnotes">

				<fo:table keep-with-previous="always" role="SKIP">
					<xsl:for-each select="xalan:nodeset($table_attributes)/table_attributes/@*">
						<xsl:variable name="name" select="local-name()"/>
						<xsl:choose>
							<xsl:when test="$name = 'border-top'">
								<xsl:attribute name="{$name}">0pt solid black</xsl:attribute>
							</xsl:when>
							<xsl:when test="$name = 'border'">
								<xsl:attribute name="{$name}"><xsl:value-of select="."/></xsl:attribute>
								<xsl:attribute name="border-top">0pt solid black</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="{$name}"><xsl:value-of select="."/></xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>

					<xsl:choose>
						<xsl:when test="xalan:nodeset($colgroup)//*[local-name()='col']">
							<xsl:for-each select="xalan:nodeset($colgroup)//*[local-name()='col']">
								<fo:table-column column-width="{@width}"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<!-- $colwidths=<xsl:copy-of select="$colwidths"/> -->
							<xsl:call-template name="insertTableColumnWidth">
								<xsl:with-param name="colwidths" select="$colwidths"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>

					<fo:table-body role="SKIP">
						<fo:table-row role="SKIP">
							<fo:table-cell xsl:use-attribute-sets="table-footer-cell-style" number-columns-spanned="{$cols-count}" role="SKIP">

								<xsl:call-template name="refine_table-footer-cell-style"/>

								<xsl:call-template name="setBordersTableArray"/>

								<!-- fn will be processed inside 'note' processing -->

								<!-- for BSI (not PAS) display Notes before footnotes -->

								<!-- except gb and bsi  -->

										<xsl:apply-templates select="../*[local-name()='p' or local-name()='dl' or (local-name()='note' and not(@type = 'units')) or local-name()='example' or local-name()='source']"/>

								<xsl:variable name="isDisplayRowSeparator">

								</xsl:variable>

								<!-- horizontal row separator -->
								<xsl:if test="normalize-space($isDisplayRowSeparator) = 'true'">
									<xsl:if test="(../*[local-name()='note'][not(@type = 'units')] or ../*[local-name()='example']) and normalize-space($table_fn_block) != ''">
										<fo:block-container border-top="0.5pt solid black" padding-left="1mm" padding-right="1mm">

											<xsl:call-template name="setBordersTableArray"/>
											<fo:block font-size="1pt"> </fo:block>
										</fo:block-container>
									</xsl:if>
								</xsl:if>

								<!-- fn processing -->

										<!-- <xsl:call-template name="table_fn_display" /> -->
										<xsl:copy-of select="$table_fn_block"/>

								<!-- for PAS display Notes after footnotes -->

							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>

				</fo:table>
			</xsl:variable>

			<xsl:if test="normalize-space($tableWithNotesAndFootnotes) != ''">
				<xsl:copy-of select="$tableWithNotesAndFootnotes"/>
			</xsl:if>

		</xsl:if>
	</xsl:template> <!-- insertTableFooterInSeparateTable -->

	<xsl:template match="*[local-name()='tbody']">

		<xsl:variable name="cols-count">
			<xsl:choose>
				<xsl:when test="../*[local-name()='thead']">
					<xsl:call-template name="calculate-columns-numbers">
						<xsl:with-param name="table-row" select="../*[local-name()='thead']/*[local-name()='tr'][1]"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="calculate-columns-numbers">
						<xsl:with-param name="table-row" select="./*[local-name()='tr'][1]"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:apply-templates select="../*[local-name()='thead']">
			<xsl:with-param name="cols-count" select="$cols-count"/>
		</xsl:apply-templates>

		<xsl:call-template name="insertTableFooter">
			<xsl:with-param name="cols-count" select="$cols-count"/>
		</xsl:call-template>

		<fo:table-body>

			<xsl:apply-templates/>

		</fo:table-body>

	</xsl:template> <!-- tbody -->

	<xsl:template match="/" mode="process_table-if">
		<xsl:param name="table_or_dl">table</xsl:param>
		<xsl:apply-templates mode="process_table-if">
			<xsl:with-param name="table_or_dl" select="$table_or_dl"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*[local-name()='tbody']" mode="process_table-if">
		<xsl:param name="table_or_dl">table</xsl:param>

		<fo:table-body>
			<xsl:for-each select="*[local-name() = 'tr']">
				<xsl:variable name="col_count" select="count(*)"/>

				<!-- iteration for each tr/td -->

				<xsl:choose>
					<xsl:when test="$table_or_dl = 'table'">
						<xsl:for-each select="*[local-name() = 'td' or local-name() = 'th']/*">
							<fo:table-row number-columns-spanned="{$col_count}">
								<xsl:copy-of select="../@font-weight"/>
								<!-- <test_table><xsl:copy-of select="."/></test_table> -->
								<xsl:call-template name="td"/>
							</fo:table-row>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise> <!-- $table_or_dl = 'dl' -->
						<xsl:for-each select="*[local-name() = 'td' or local-name() = 'th']">
							<xsl:variable name="is_dt" select="position() = 1"/>

							<xsl:for-each select="*">
								<!-- <test><xsl:copy-of select="."/></test> -->
								<fo:table-row number-columns-spanned="{$col_count}">
									<xsl:choose>
										<xsl:when test="$is_dt">
											<xsl:call-template name="insert_dt_cell"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:call-template name="insert_dd_cell"/>
										</xsl:otherwise>
									</xsl:choose>
								</fo:table-row>
							</xsl:for-each>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:for-each>
		</fo:table-body>
	</xsl:template> <!-- process_table-if -->

	<!-- ===================== -->
	<!-- Table's row processing -->
	<!-- ===================== -->
	<!-- row in table header (thead) thead/tr -->
	<xsl:template match="*[local-name()='thead']/*[local-name()='tr']" priority="2">
		<fo:table-row xsl:use-attribute-sets="table-header-row-style">

			<xsl:call-template name="refine_table-header-row-style"/>

			<xsl:call-template name="setTableRowAttributes"/>

			<xsl:apply-templates/>
		</fo:table-row>
	</xsl:template>

	<xsl:template name="setBorderUnderRow">
		<xsl:variable name="border_under_row_" select="normalize-space(ancestor::*[local-name() = 'table'][1]/@border-under-row)"/>
		<xsl:choose>
			<xsl:when test="$border_under_row_ != ''">
				<xsl:variable name="table_id" select="ancestor::*[local-name() = 'table'][1]/@id"/>
				<xsl:variable name="row_num_"><xsl:number level="any" count="*[local-name() = 'table'][@id = $table_id]//*[local-name() = 'tr']"/></xsl:variable>
				<xsl:variable name="row_num" select="number($row_num_) - 1"/> <!-- because values in border-under-row start with 0 -->
				<xsl:variable name="border_under_row">
					<xsl:call-template name="split">
						<xsl:with-param name="pText" select="$border_under_row_"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="xalan:nodeset($border_under_row)/item[. = normalize-space($row_num)]">
					<xsl:attribute name="border-bottom"><xsl:value-of select="$table-border"/></xsl:attribute>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="border-bottom"><xsl:value-of select="$table-border"/></xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- row in table footer (tfoot), tfoot/tr -->
	<xsl:template match="*[local-name()='tfoot']/*[local-name()='tr']" priority="2">
		<fo:table-row xsl:use-attribute-sets="table-footer-row-style">

			<xsl:call-template name="refine_table-footer-row-style"/>

			<xsl:call-template name="setTableRowAttributes"/>
			<xsl:apply-templates/>
		</fo:table-row>
	</xsl:template>

	<!-- row in table's body (tbody) -->
	<xsl:template match="*[local-name()='tr']">
		<fo:table-row xsl:use-attribute-sets="table-body-row-style">

			<xsl:if test="count(*) = count(*[local-name() = 'th'])"> <!-- row contains 'th' only -->
				<xsl:attribute name="keep-with-next">always</xsl:attribute>
			</xsl:if>

			<xsl:call-template name="refine_table-body-row-style"/>

			<xsl:call-template name="setTableRowAttributes"/>

			<xsl:apply-templates/>
		</fo:table-row>
	</xsl:template>

	<xsl:template name="setTableRowAttributes">

		<xsl:call-template name="setColors"/>

	</xsl:template> <!-- setTableRowAttributes -->
	<!-- ===================== -->
	<!-- END Table's row processing -->
	<!-- ===================== -->

	<!-- cell in table header row -->
	<xsl:template match="*[local-name()='th']">
		<fo:table-cell xsl:use-attribute-sets="table-header-cell-style"> <!-- text-align="{@align}" -->
			<xsl:call-template name="setTextAlignment">
				<xsl:with-param name="default">center</xsl:with-param>
			</xsl:call-template>

			<xsl:copy-of select="@keep-together.within-line"/>

			<xsl:call-template name="refine_table-header-cell-style"/>

			<!-- experimental feature, see https://github.com/metanorma/metanorma-plateau/issues/30#issuecomment-2145461828 -->
			<!-- <xsl:choose>
				<xsl:when test="count(node()) = 1 and *[local-name() = 'span'][contains(@style, 'text-orientation')]">
					<fo:block-container reference-orientation="270">
						<fo:block role="SKIP" text-align="start">
							<xsl:apply-templates />
						</fo:block>
					</fo:block-container>
				</xsl:when>
				<xsl:otherwise>
					<fo:block role="SKIP">
						<xsl:apply-templates />
					</fo:block>
				</xsl:otherwise>
			</xsl:choose> -->

			<fo:block role="SKIP">
				<xsl:apply-templates/>
				<xsl:if test="$isGenerateTableIF = 'false' and count(node()) = 0"> </xsl:if>
			</fo:block>
		</fo:table-cell>
	</xsl:template> <!-- cell in table header row - 'th' -->

	<xsl:template name="setTableCellAttributes">
		<xsl:if test="@colspan">
			<xsl:attribute name="number-columns-spanned">
				<xsl:value-of select="@colspan"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="@rowspan">
			<xsl:attribute name="number-rows-spanned">
				<xsl:value-of select="@rowspan"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:call-template name="display-align"/>
		<xsl:call-template name="setColors"/>
	</xsl:template>

	<xsl:template name="display-align">
		<xsl:if test="@valign">
			<xsl:attribute name="display-align">
				<xsl:choose>
					<xsl:when test="@valign = 'top'">before</xsl:when>
					<xsl:when test="@valign = 'middle'">center</xsl:when>
					<xsl:when test="@valign = 'bottom'">after</xsl:when>
					<xsl:otherwise>before</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:template name="setColors">
		<xsl:variable name="styles__">
			<xsl:call-template name="split">
				<xsl:with-param name="pText" select="concat(@style,';')"/>
				<xsl:with-param name="sep" select="';'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="quot">"</xsl:variable>
		<xsl:variable name="styles_">
			<xsl:for-each select="xalan:nodeset($styles__)/item">
				<xsl:variable name="key" select="normalize-space(substring-before(., ':'))"/>
				<xsl:variable name="value" select="normalize-space(substring-after(translate(.,$quot,''), ':'))"/>
				<xsl:if test="$key = 'color' or $key = 'background-color'">
					<style name="{$key}"><xsl:value-of select="$value"/></style>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="styles" select="xalan:nodeset($styles_)"/>
		<xsl:for-each select="$styles/style">
			<xsl:attribute name="{@name}"><xsl:value-of select="."/></xsl:attribute>
		</xsl:for-each>
	</xsl:template>

	<!-- cell in table body, footer -->
	<xsl:template match="*[local-name()='td']" name="td">
		<fo:table-cell xsl:use-attribute-sets="table-cell-style"> <!-- text-align="{@align}" -->
			<xsl:call-template name="setTextAlignment">
				<xsl:with-param name="default">left</xsl:with-param>
			</xsl:call-template>

			<xsl:copy-of select="@keep-together.within-line"/>

			<xsl:call-template name="refine_table-cell-style"/>

			<xsl:call-template name="setTableCellAttributes"/>

			<xsl:if test=".//*[local-name() = 'table']"> <!-- if there is nested table -->
				<xsl:attribute name="padding-right">1mm</xsl:attribute>
			</xsl:if>

			<xsl:if test="$isGenerateTableIF = 'true'">
				<xsl:attribute name="border">1pt solid black</xsl:attribute> <!-- border is mandatory, to determine page width -->
				<xsl:attribute name="text-align">left</xsl:attribute>
			</xsl:if>

			<xsl:if test="$isGenerateTableIF = 'false'">
				<xsl:if test="@colspan and *[local-name() = 'note'][@type = 'units']">
					<xsl:attribute name="text-align">right</xsl:attribute>
					<xsl:attribute name="border">none</xsl:attribute>
					<xsl:attribute name="border-bottom"><xsl:value-of select="$table-border"/></xsl:attribute>
					<xsl:attribute name="border-top">1pt solid white</xsl:attribute>
					<xsl:attribute name="border-left">1pt solid white</xsl:attribute>
					<xsl:attribute name="border-right">1pt solid white</xsl:attribute>
				</xsl:if>
			</xsl:if>

			<fo:block role="SKIP">

				<xsl:if test="$isGenerateTableIF = 'true'">

							<fo:inline>
								<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
								<xsl:value-of select="$hair_space"/>
							</fo:inline>

				</xsl:if>

				<xsl:apply-templates/>

				<xsl:if test="$isGenerateTableIF = 'true'"> <fo:inline id="{@id}_end">end</fo:inline></xsl:if> <!-- to determine width of text --> <!-- <xsl:value-of select="$hair_space"/> -->

				<xsl:if test="$isGenerateTableIF = 'false' and count(node()) = 0"> </xsl:if>

			</fo:block>
		</fo:table-cell>
	</xsl:template> <!-- td -->

	<!-- table/note, table/example, table/tfoot//note, table/tfoot//example -->
	<xsl:template match="*[local-name()='table']/*[local-name()='note' or local-name() = 'example'] |       *[local-name()='table']/*[local-name()='tfoot']//*[local-name()='note' or local-name() = 'example']" priority="2">

				<fo:list-block id="{@id}" xsl:use-attribute-sets="table-note-style" provisional-distance-between-starts="{9 + $text_indent}mm"> <!-- 12 -->
					<fo:list-item>
						<fo:list-item-label start-indent="{$text_indent}mm" end-indent="label-end()">
							<fo:block>
								<xsl:apply-templates select="*[local-name() = 'name']"/>
							</fo:block>
						</fo:list-item-label>
						<fo:list-item-body start-indent="body-start()" xsl:use-attribute-sets="table-fn-body-style">
							<fo:block>
								<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
							</fo:block>
						</fo:list-item-body>
					</fo:list-item>
				</fo:list-block>
				<!-- jis -->

	</xsl:template> <!-- table/note -->

	<xsl:template match="*[local-name()='table']/*[local-name()='note' or local-name()='example']/*[local-name()='p'] |  *[local-name()='table']/*[local-name()='tfoot']//*[local-name()='note' or local-name()='example']/*[local-name()='p']" priority="2">
		<xsl:apply-templates/>
	</xsl:template>

	<!-- ===================== -->
	<!-- Footnotes processing  -->
	<!-- ===================== -->

	<!-- document text (not figures, or tables) footnotes -->
	<xsl:variable name="footnotes_">
		<xsl:for-each select="//*[local-name() = 'fmt-footnote-container']/*[local-name() = 'fmt-fn-body']"> <!-- commented *[local-name() = 'metanorma']/, because there are fn in figure or table name -->
			<!-- <xsl:copy-of select="."/> -->
			<xsl:variable name="update_xml_step1">
				<xsl:apply-templates select="." mode="update_xml_step1"/>
			</xsl:variable>
			<xsl:apply-templates select="xalan:nodeset($update_xml_step1)" mode="update_xml_enclose_keep-together_within-line"/>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="footnotes" select="xalan:nodeset($footnotes_)"/>

	<!--
	<fn reference="1">
			<p id="_8e5cf917-f75a-4a49-b0aa-1714cb6cf954">Formerly denoted as 15 % (m/m).</p>
		</fn>
	-->
	<!-- footnotes in text (title, bibliography, main body), not for tables, figures and names --> <!-- table's, figure's names -->
	<!-- fn in text -->
	<xsl:template match="*[local-name() = 'fn'][not(ancestor::*[(local-name() = 'table' or local-name() = 'figure')] and not(ancestor::*[local-name() = 'name']))]" priority="2" name="fn">
		<xsl:param name="footnote_body_from_table">false</xsl:param>

		<!-- list of unique footnotes -->
		<xsl:variable name="p_fn_">
			<xsl:call-template name="get_fn_list"/>
		</xsl:variable>
		<xsl:variable name="p_fn" select="xalan:nodeset($p_fn_)"/>

		<xsl:variable name="gen_id" select="generate-id(.)"/>

		<!-- fn sequence number in document -->
		<xsl:variable name="current_fn_number" select="@reference"/>

		<xsl:variable name="current_fn_number_text">

					<xsl:choose>
						<xsl:when test="$autonumbering_style = 'japanese'">
							<xsl:text> </xsl:text>
							<xsl:value-of select="$numbers_japanese//jis:localized-string[@key = $current_fn_number]"/>
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="translate($current_fn_number, ')', '')"/><fo:inline font-weight="normal">)</fo:inline></xsl:otherwise>
					</xsl:choose>

		</xsl:variable>

		<xsl:variable name="ref_id" select="@target"/>

		<xsl:variable name="footnote_inline">
			<fo:inline role="Reference">

				<xsl:variable name="fn_styles">
					<xsl:choose>
						<xsl:when test="ancestor::*[local-name() = 'bibitem']">
							<fn_styles xsl:use-attribute-sets="bibitem-note-fn-style">

									<xsl:if test="not($vertical_layout = 'true')">
										<xsl:attribute name="font-family">Times New Roman</xsl:attribute>
									</xsl:if>

							</fn_styles>
						</xsl:when>
						<xsl:otherwise>
							<fn_styles xsl:use-attribute-sets="fn-num-style">

									<xsl:if test="not($vertical_layout = 'true')">
										<xsl:attribute name="font-family">Times New Roman</xsl:attribute>
									</xsl:if>
									<xsl:if test="$vertical_layout = 'true'">
										<xsl:attribute name="vertical-align">baseline</xsl:attribute>
										<xsl:attribute name="font-size">80%</xsl:attribute>
										<xsl:attribute name="baseline-shift">20%</xsl:attribute>
									</xsl:if>

							</fn_styles>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:for-each select="xalan:nodeset($fn_styles)/fn_styles/@*">
					<xsl:copy-of select="."/>
				</xsl:for-each>

				<xsl:if test="following-sibling::node()[normalize-space() != ''][1][local-name() = 'fn']">
					<xsl:attribute name="padding-right">0.5mm</xsl:attribute>
				</xsl:if>

				<xsl:call-template name="insert_basic_link">
					<xsl:with-param name="element">
						<fo:basic-link internal-destination="{$ref_id}" fox:alt-text="footnote {$current_fn_number}"> <!-- note: role="Lbl" removed in https://github.com/metanorma/mn2pdf/issues/291 -->
							<fo:inline role="Lbl"> <!-- need for https://github.com/metanorma/metanorma-iso/issues/1003 -->

									<xsl:attribute name="keep-together.within-line">always</xsl:attribute>
									<fo:inline font-family="IPAexGothic">
										<xsl:call-template name="insertVerticalChar">
											<xsl:with-param name="str" select="'〔'"/>
										</xsl:call-template>
									</fo:inline>

								<xsl:copy-of select="$current_fn_number_text"/>

									<fo:inline font-family="IPAexGothic">
										<xsl:call-template name="insertVerticalChar">
											<xsl:with-param name="str" select="'〕'"/>
										</xsl:call-template>
									</fo:inline>

							</fo:inline>
						</fo:basic-link>
					</xsl:with-param>
				</xsl:call-template>
			</fo:inline>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="normalize-space(@skip_footnote_body) = 'true'">
				<xsl:copy-of select="$footnote_inline"/>
			</xsl:when>
			<!-- <xsl:when test="$footnotes//*[local-name() = 'fmt-fn-body'][@id = $ref_id] or normalize-space(@skip_footnote_body) = 'false'"> -->
			<xsl:when test="$p_fn//fn[@gen_id = $gen_id] or normalize-space(@skip_footnote_body) = 'false' or $footnote_body_from_table = 'true'">

				<fo:footnote xsl:use-attribute-sets="fn-style" role="SKIP">
					<xsl:copy-of select="$footnote_inline"/>
					<fo:footnote-body role="Note">

						<fo:block-container xsl:use-attribute-sets="fn-container-body-style" role="SKIP">

							<xsl:variable name="fn_block">
								<xsl:call-template name="refine_fn-body-style"/>

								<fo:inline id="{$ref_id}" xsl:use-attribute-sets="fn-body-num-style" role="Lbl">

									<xsl:call-template name="refine_fn-body-num-style"/>

									<xsl:value-of select="$current_fn_number_text"/>

								</fo:inline>
								<!-- <xsl:apply-templates /> -->
								<!-- <ref_id><xsl:value-of select="$ref_id"/></ref_id>
								<here><xsl:copy-of select="$footnotes"/></here> -->
								<xsl:apply-templates select="$footnotes/*[local-name() = 'fmt-fn-body'][@id = $ref_id]"/>
							</xsl:variable>

									<xsl:choose>
										<xsl:when test="$vertical_layout = 'true'">
											<fo:list-block xsl:use-attribute-sets="fn-body-style" role="SKIP" provisional-distance-between-starts="25mm">
												<xsl:call-template name="refine_fn-body-style"/>
												<fo:list-item role="SKIP">
													<fo:list-item-label start-indent="{$text_indent}mm" end-indent="label-end()" role="SKIP">
														<fo:block role="SKIP">
															<fo:inline id="{$ref_id}" xsl:use-attribute-sets="fn-body-num-style" role="Lbl">

																<xsl:call-template name="refine_fn-body-num-style"/>

																<xsl:call-template name="insertVerticalChar">
																	<xsl:with-param name="str" select="'〔'"/>
																</xsl:call-template>

																<xsl:value-of select="$current_fn_number_text"/>

																<xsl:call-template name="insertVerticalChar">
																	<xsl:with-param name="str" select="'〕'"/>
																</xsl:call-template>

															</fo:inline>
														</fo:block>
													</fo:list-item-label>
													<fo:list-item-body start-indent="body-start()" xsl:use-attribute-sets="table-fn-body-style" role="SKIP">
														<fo:block role="SKIP">
															<!-- <xsl:apply-templates /> -->
															<xsl:apply-templates select="$footnotes/*[local-name() = 'fmt-fn-body'][@id = $ref_id]"/>
														</fo:block>
													</fo:list-item-body>
												</fo:list-item>
											</fo:list-block>
										</xsl:when> <!-- $vertical_layout = 'true' -->
										<xsl:otherwise>
											<fo:block xsl:use-attribute-sets="fn-body-style" role="SKIP">
												<xsl:attribute name="text-align">left</xsl:attribute> <!-- because footer is centered -->
												<xsl:copy-of select="$fn_block"/>
											</fo:block>
										</xsl:otherwise>
									</xsl:choose>
									<!-- jis -->

						</fo:block-container>
					</fo:footnote-body>
				</fo:footnote>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$footnote_inline"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template> <!-- fn in text -->

	<xsl:template name="get_fn_list">
		<xsl:choose>
			<xsl:when test="@current_fn_number"> <!-- for BSI, footnote reference number calculated already -->
				<fn gen_id="{generate-id(.)}">
					<xsl:copy-of select="@*"/>
					<xsl:copy-of select="node()"/>
				</fn>
			</xsl:when>
			<xsl:otherwise>
				<!-- itetation for:
				footnotes in bibdata/title
				footnotes in bibliography
				footnotes in document's body (except table's head/body/foot and figure text) 
				-->
				<xsl:for-each select="ancestor::*[local-name() = 'metanorma']/*[local-name() = 'bibdata']/*[local-name() = 'note'][@type='title-footnote']">
					<fn gen_id="{generate-id(.)}">
						<xsl:copy-of select="@*"/>
						<xsl:copy-of select="node()"/>
					</fn>
				</xsl:for-each>
				<xsl:for-each select="ancestor::*[local-name() = 'metanorma']/*[local-name()='boilerplate']/* |       ancestor::*[local-name() = 'metanorma']//*[local-name()='preface']/* |      ancestor::*[local-name() = 'metanorma']//*[local-name()='sections']/* |       ancestor::*[local-name() = 'metanorma']//*[local-name()='annex'] |      ancestor::*[local-name() = 'metanorma']//*[local-name()='bibliography']/*">
					<xsl:sort select="@displayorder" data-type="number"/>
					<!-- commented:
					 .//*[local-name() = 'bibitem'][ancestor::*[local-name() = 'references']]/*[local-name() = 'note'] |
					 because 'fn' there is in biblio-tag -->
					<xsl:for-each select=".//*[local-name() = 'fn'][not(ancestor::*[(local-name() = 'table' or local-name() = 'figure')] and not(ancestor::*[local-name() = 'name']))][generate-id(.)=generate-id(key('kfn',@reference)[1])]">
						<!-- copy unique fn -->
						<fn gen_id="{generate-id(.)}">
							<xsl:copy-of select="@*"/>
							<xsl:copy-of select="node()"/>
						</fn>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ============================ -->
	<!-- table's footnotes rendering -->
	<!-- ============================ -->

	<!-- table/fmt-footnote-container -->
	<xsl:template match="*[local-name() = 'table']/*[local-name() = 'fmt-footnote-container']"/>

	<xsl:template match="*[local-name() = 'table']/*[local-name() = 'tfoot']//*[local-name() = 'fmt-footnote-container']">
		<xsl:for-each select=".">
			<xsl:call-template name="table_fn_display"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="table_fn_display">
		<!-- <xsl:variable name="references">
			<xsl:if test="$namespace = 'bsi'">
				<xsl:for-each select="..//*[local-name()='fn'][local-name(..) = 'name']">
					<xsl:call-template name="create_fn" />
				</xsl:for-each>
			</xsl:if>
			<xsl:for-each select="..//*[local-name()='fn'][local-name(..) != 'name']">
				<xsl:call-template name="create_fn" />
			</xsl:for-each>
		</xsl:variable> -->
		<!-- <xsl:for-each select="xalan:nodeset($references)//fn">
			<xsl:variable name="reference" select="@reference"/>
			<xsl:if test="not(preceding-sibling::*[@reference = $reference])">  --> <!-- only unique reference puts in note-->
		<xsl:for-each select="..//*[local-name() = 'fmt-footnote-container']/*[local-name() = 'fmt-fn-body']">

						<fo:list-block id="{@id}" xsl:use-attribute-sets="table-fn-style" provisional-distance-between-starts="{9 + $text_indent}mm"> <!-- 12 -->
							<fo:list-item>
								<fo:list-item-label start-indent="{$text_indent}mm" end-indent="label-end()">
									<fo:block>
										<!-- <fo:inline font-size="9pt">
											<xsl:if test="not($vertical_layout = 'true')">
												<xsl:attribute name="font-family">IPAexGothic</xsl:attribute>
											</xsl:if>
											<xsl:call-template name="getLocalizedString">
												<xsl:with-param name="key">table_footnote</xsl:with-param>
											</xsl:call-template>
										</fo:inline>
										<xsl:text> </xsl:text> -->

										<xsl:apply-templates select=".//*[local-name() = 'fmt-fn-label']">
											<xsl:with-param name="process">true</xsl:with-param>
										</xsl:apply-templates>

										<!-- <fo:inline xsl:use-attribute-sets="table-fn-number-style table-fmt-fn-label-style"> -->
											<!-- <xsl:if test="not($vertical_layout = 'true')">
												<xsl:attribute name="font-family">Times New Roman</xsl:attribute>
											</xsl:if> -->
											<!-- <xsl:value-of select="@reference"/> -->
											<!-- <xsl:apply-templates select=".//*[local-name() = 'fmt-fn-label']">
												<xsl:with-param name="process">true</xsl:with-param>
											</xsl:apply-templates> -->
											<!-- <xsl:value-of select="normalize-space(.//*[local-name() = 'fmt-fn-label'])"/> -->
											<!-- <xsl:apply-templates select=".//*[local-name() = 'fmt-fn-label']">
												<xsl:with-param name="process">true</xsl:with-param>
											</xsl:apply-templates> -->

											<!-- <fo:inline font-weight="normal">)</fo:inline> --> <!-- commented, https://github.com/metanorma/isodoc/issues/614 -->
										<!-- </fo:inline> -->
									</fo:block>
								</fo:list-item-label>
								<fo:list-item-body start-indent="body-start()" xsl:use-attribute-sets="table-fn-body-style">
									<fo:block>
										<!-- <xsl:copy-of select="./node()"/> -->
										<xsl:apply-templates/>
									</fo:block>
								</fo:list-item-body>
							</fo:list-item>
						</fo:list-block>
						<!-- jis -->

			<!-- </xsl:if> -->
		</xsl:for-each>
	</xsl:template> <!-- table_fn_display -->

	<!-- fmt-fn-body/fmt-fn-label in text -->
	<xsl:template match="*[local-name() = 'fmt-fn-body']//*[local-name() = 'fmt-fn-label']"/>

	<!-- table//fmt-fn-body//fmt-fn-label -->
	<xsl:template match="*[local-name() = 'table']//*[local-name() = 'fmt-fn-body']//*[local-name() = 'fmt-fn-label']"> <!-- *[local-name() = 'fmt-footnote-container']/ -->
		<xsl:param name="process">false</xsl:param>
		<xsl:if test="$process = 'true'">
			<fo:inline xsl:use-attribute-sets="table-fn-number-style" role="SKIP">

				<!-- tab is padding-right -->
				<xsl:apply-templates select=".//*[local-name() = 'tab']">
					<xsl:with-param name="process">true</xsl:with-param>
				</xsl:apply-templates>

				<!-- <xsl:if test="$namespace = 'bipm'">
					<fo:inline font-style="normal">(</fo:inline>
				</xsl:if> -->

				<!-- <xsl:if test="$namespace = 'plateau'">
					<xsl:text>※</xsl:text>
				</xsl:if> -->

				<!-- <xsl:value-of select="@reference"/> -->
				<!-- <xsl:value-of select="normalize-space()"/> -->
				<xsl:apply-templates/>

				<!-- <xsl:if test="$namespace = 'bipm'">
					<fo:inline font-style="normal">)</fo:inline>
				</xsl:if> -->

				<!-- commented https://github.com/metanorma/isodoc/issues/614 -->
				<!-- <xsl:if test="$namespace = 'itu'">
					<xsl:text>)</xsl:text>
				</xsl:if> -->

				<!-- <xsl:if test="$namespace = 'plateau'">
					<xsl:text>：</xsl:text>
				</xsl:if> -->

			</fo:inline>
		</xsl:if>
	</xsl:template> <!--  fmt-fn-body//fmt-fn-label -->

	<xsl:template match="*[local-name() = 'table']//*[local-name() = 'fmt-fn-body']//*[local-name() = 'fmt-fn-label']//*[local-name() = 'tab']" priority="5">
		<xsl:param name="process">false</xsl:param>
		<xsl:if test="$process = 'true'">
			<xsl:attribute name="padding-right">5mm</xsl:attribute>

				<xsl:attribute name="padding-right">0mm</xsl:attribute>

		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'table']//*[local-name() = 'fmt-fn-body']//*[local-name() = 'fmt-fn-label']//*[local-name() = 'sup']" priority="5">
		<fo:inline xsl:use-attribute-sets="table-fmt-fn-label-style" role="SKIP">
			<xsl:call-template name="refine_table-fmt-fn-label-style"/>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<!-- <xsl:template match="*[local-name() = 'fmt-footnote-container']/*[local-name() = 'fmt-fn-body']//*[local-name() = 'fmt-fn-label']//*[local-name() = 'tab']"/> -->
	<!-- 
	<xsl:template name="create_fn">
		<fn reference="{@reference}" id="{@reference}_{ancestor::*[@id][1]/@id}">
			<xsl:if test="ancestor::*[local-name()='table'][1]/@id">  - for footnotes in tables -
				<xsl:attribute name="id">
					<xsl:value-of select="concat(@reference, '_', ancestor::*[local-name()='table'][1]/@id)"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="$namespace = 'itu'">
				<xsl:if test="ancestor::*[local-name()='preface']">
					<xsl:attribute name="preface">true</xsl:attribute>
				</xsl:if>
			</xsl:if>
			<xsl:if test="$namespace = 'ogc' or $namespace = 'ogc-white-paper'">
				<xsl:attribute name="id">
					<xsl:value-of select="@reference"/>
					<xsl:text>_</xsl:text>
					<xsl:value-of select="ancestor::*[local-name()='table'][1]/@id"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates />
		</fn>
	</xsl:template> -->

	<!-- footnotes for table's name rendering -->
	<xsl:template name="table_name_fn_display">
		<xsl:for-each select="*[local-name()='name']//*[local-name()='fn']">
			<xsl:variable name="reference" select="@reference"/>
			<fo:block id="{@reference}_{ancestor::*[@id][1]/@id}"><xsl:value-of select="@reference"/></fo:block>
			<fo:block margin-bottom="12pt">
				<xsl:apply-templates/>
			</fo:block>
		</xsl:for-each>
	</xsl:template>
	<!-- ============================ -->
	<!-- EMD table's footnotes rendering -->
	<!-- ============================ -->

	<!-- ============================ -->
	<!-- figure's footnotes rendering -->
	<!-- ============================ -->

	<!-- figure/fmt-footnote-container -->
	<xsl:template match="*[local-name() = 'figure']//*[local-name() = 'fmt-footnote-container']"/>

	<!-- TO DO: remove, now the figure fn in figure/dl/... https://github.com/metanorma/isodoc/issues/658 -->
	<xsl:template name="figure_fn_display">

		<xsl:variable name="references">
			<xsl:for-each select="./*[local-name() = 'fmt-footnote-container']/*[local-name() = 'fmt-fn-body']">
				<xsl:variable name="curr_id" select="@id"/>
				<!-- <curr_id><xsl:value-of select="$curr_id"/></curr_id>
				<curr><xsl:copy-of select="."/></curr>
				<ancestor><xsl:copy-of select="ancestor::*[local-name() = 'figure'][.//*[local-name() = 'name'][.//*[local-name() = 'fn']]]"/></ancestor> -->
				<xsl:choose>
					<!-- skip figure/name/fn -->
					<xsl:when test="ancestor::*[local-name() = 'figure'][.//*[local-name() = 'name'][.//*[local-name() = 'fn'][@target = $curr_id]]]"><!-- skip --></xsl:when>
					<xsl:otherwise>
						<xsl:element name="figure" namespace="{$namespace_full}">
							<xsl:element name="fmt-footnote-container" namespace="{$namespace_full}">
								<xsl:copy-of select="."/>
							</xsl:element>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		<!-- <references><xsl:copy-of select="$references"/></references> -->

		<xsl:if test="xalan:nodeset($references)//*[local-name() = 'fmt-fn-body']">

			<xsl:variable name="key_iso">

			</xsl:variable>

			<fo:block>
				<!-- current hierarchy is 'figure' element -->
				<xsl:variable name="following_dl_colwidths">
					<xsl:if test="*[local-name() = 'dl']"><!-- if there is a 'dl', then set the same columns width as for 'dl' -->
						<xsl:variable name="simple-table">
							<!-- <xsl:variable name="doc_ns">
								<xsl:if test="$namespace = 'bipm'">bipm</xsl:if>
							</xsl:variable>
							<xsl:variable name="ns">
								<xsl:choose>
									<xsl:when test="normalize-space($doc_ns)  != ''">
										<xsl:value-of select="normalize-space($doc_ns)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="substring-before(name(/*), '-')"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable> -->

							<xsl:for-each select="*[local-name() = 'dl'][1]">
								<tbody>
									<xsl:apply-templates mode="dl"/>
								</tbody>
							</xsl:for-each>
						</xsl:variable>

						<xsl:call-template name="calculate-column-widths">
							<xsl:with-param name="cols-count" select="2"/>
							<xsl:with-param name="table" select="$simple-table"/>
						</xsl:call-template>

					</xsl:if>
				</xsl:variable>

				<xsl:variable name="maxlength_dt">
					<xsl:for-each select="*[local-name() = 'dl'][1]">
						<xsl:call-template name="getMaxLength_dt"/>
					</xsl:for-each>
				</xsl:variable>

				<fo:table width="95%" table-layout="fixed">
					<xsl:if test="normalize-space($key_iso) = 'true'">
						<xsl:attribute name="font-size">10pt</xsl:attribute>

					</xsl:if>
					<xsl:choose>
						<!-- if there 'dl', then set same columns width -->
						<xsl:when test="xalan:nodeset($following_dl_colwidths)//column">
							<xsl:call-template name="setColumnWidth_dl">
								<xsl:with-param name="colwidths" select="$following_dl_colwidths"/>
								<xsl:with-param name="maxlength_dt" select="$maxlength_dt"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<fo:table-column column-width="5%"/>
							<fo:table-column column-width="95%"/>
						</xsl:otherwise>
					</xsl:choose>
					<fo:table-body>
						<!-- <xsl:for-each select="xalan:nodeset($references)//fn"> -->
						<xsl:for-each select="xalan:nodeset($references)//*[local-name() = 'fmt-fn-body']">

							<xsl:variable name="reference" select="@reference"/>
							<!-- <xsl:if test="not(preceding-sibling::*[@reference = $reference])"> --> <!-- only unique reference puts in note-->
								<fo:table-row>
									<fo:table-cell>
										<fo:block>

													<fo:inline id="{@id}" xsl:use-attribute-sets="figure-fmt-fn-label-style">
														<!-- <xsl:attribute name="padding-right">0mm</xsl:attribute> -->
														<!-- <xsl:value-of select="@reference"/> -->
														<xsl:value-of select="normalize-space(.//*[local-name() = 'fmt-fn-label'])"/>
													</fo:inline>

										</fo:block>
									</fo:table-cell>
									<fo:table-cell>
										<fo:block xsl:use-attribute-sets="figure-fn-body-style">
											<xsl:if test="normalize-space($key_iso) = 'true'">

														<xsl:attribute name="margin-bottom">0</xsl:attribute>

											</xsl:if>

											<!-- <xsl:copy-of select="./node()"/> -->
											<xsl:apply-templates/>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							<!-- </xsl:if> -->
						</xsl:for-each>
					</fo:table-body>
				</fo:table>
			</fo:block>
		</xsl:if>
	</xsl:template> <!-- figure_fn_display -->

	<xsl:template match="*[local-name() = 'figure']//*[local-name() = 'fmt-fn-body']//*[local-name() = 'fmt-fn-label']"> <!-- *[local-name() = 'fmt-footnote-container']/ -->
		<xsl:param name="process">false</xsl:param>
		<xsl:if test="$process = 'true'">
			<fo:inline xsl:use-attribute-sets="figure-fn-number-style" role="SKIP">
				<xsl:attribute name="padding-right">0mm</xsl:attribute>

				<!-- tab is padding-right -->
				<xsl:apply-templates select=".//*[local-name() = 'tab']">
					<xsl:with-param name="process">true</xsl:with-param>
				</xsl:apply-templates>

				<xsl:apply-templates/>

			</fo:inline>
		</xsl:if>
	</xsl:template> <!--  figure//fmt-fn-body//fmt-fn-label -->

	<xsl:template match="*[local-name() = 'figure']//*[local-name() = 'fmt-fn-body']//*[local-name() = 'fmt-fn-label']//*[local-name() = 'tab']" priority="5">
		<xsl:param name="process">false</xsl:param>
		<xsl:if test="$process = 'true'">

		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'figure']//*[local-name() = 'fmt-fn-body']//*[local-name() = 'fmt-fn-label']//*[local-name() = 'sup']" priority="5">
		<fo:inline xsl:use-attribute-sets="figure-fmt-fn-label-style" role="SKIP">
			<xsl:call-template name="refine_figure-fmt-fn-label-style"/>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<!-- added for https://github.com/metanorma/isodoc/issues/607 -->
	<!-- figure's footnote label -->
	<!-- figure/dl[@key = 'true']/dt/p/sup -->
	<xsl:template match="*[local-name() = 'figure']/*[local-name() = 'dl'][@key = 'true']/*[local-name() = 'dt']/     *[local-name() = 'p'][count(node()[normalize-space() != '']) = 1]/*[local-name() = 'sup']" priority="3">
		<xsl:variable name="key_iso">

		</xsl:variable>
		<xsl:if test="normalize-space($key_iso) = 'true'">
			<xsl:attribute name="font-size">10pt</xsl:attribute>

		</xsl:if>
		<fo:inline xsl:use-attribute-sets="figure-fn-number-style figure-fmt-fn-label-style"> <!-- id="{@id}"  -->
			<!-- <xsl:value-of select="@reference"/> -->
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<!-- ============================ -->
	<!-- END: figure's footnotes rendering -->
	<!-- ============================ -->

	<!-- fn reference in the table rendering (for instance, 'some text 1) some text' ) -->
	<!-- fn --> <!-- in table --> <!-- for figure see <xsl:template match="*[local-name() = 'figure']/*[local-name() = 'fn']" priority="2"/> -->
	<xsl:template match="*[local-name()='fn']">
		<xsl:variable name="target" select="@target"/>
		<xsl:choose>
			<!-- case for footnotes in Requirement tables (https://github.com/metanorma/metanorma-ogc/issues/791) -->
			<xsl:when test="not(ancestor::*[local-name() = 'table'][1]//*[local-name() = 'fmt-footnote-container']/*[local-name() = 'fmt-fn-body'][@id = $target]) and        $footnotes/*[local-name() = 'fmt-fn-body'][@id = $target]">
				<xsl:call-template name="fn">
					<xsl:with-param name="footnote_body_from_table">true</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>

				<fo:inline xsl:use-attribute-sets="fn-reference-style">

					<xsl:call-template name="refine_fn-reference-style"/>

					<!-- <fo:basic-link internal-destination="{@reference}_{ancestor::*[@id][1]/@id}" fox:alt-text="footnote {@reference}"> --> <!-- @reference   | ancestor::*[local-name()='clause'][1]/@id-->
					<fo:basic-link internal-destination="{@target}" fox:alt-text="footnote {@reference}">
						<!-- <xsl:if test="ancestor::*[local-name()='table'][1]/@id"> --> <!-- for footnotes in tables -->
						<!-- 	<xsl:attribute name="internal-destination">
								<xsl:value-of select="concat(@reference, '_', ancestor::*[local-name()='table'][1]/@id)"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="$namespace = 'ogc' or $namespace = 'ogc-white-paper'">
							<xsl:attribute name="internal-destination">
								<xsl:value-of select="@reference"/><xsl:text>_</xsl:text>
								<xsl:value-of select="ancestor::*[local-name()='table'][1]/@id"/>
							</xsl:attribute>
						</xsl:if> -->
						<!-- <xsl:if test="$namespace = 'plateau'">
							<xsl:text>※</xsl:text>
						</xsl:if> -->
						<!-- <xsl:value-of select="@reference"/> -->

								<xsl:value-of select="normalize-space(*[local-name() = 'fmt-fn-label'])"/>

						<!-- <xsl:if test="$namespace = 'bsi'">
							<xsl:text>)</xsl:text>
						</xsl:if> -->
						<!-- commented, https://github.com/metanorma/isodoc/issues/614 -->
						<!-- <xsl:if test="$namespace = 'jis'">
							<fo:inline font-weight="normal">)</fo:inline>
						</xsl:if> -->
					</fo:basic-link>
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template> <!-- fn -->

	<!-- fn/text() -->
	<xsl:template match="*[local-name()='fn']/text()[normalize-space() != '']">
		<fo:inline role="SKIP"><xsl:value-of select="."/></fo:inline>
	</xsl:template>

	<!-- fn//p fmt-fn-body//p -->
	<xsl:template match="*[local-name()='fn']//*[local-name()='p'] | *[local-name() = 'fmt-fn-body']//*[local-name()='p']">
		<fo:inline role="P">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<xsl:template name="insertFootnoteSeparatorCommon">
		<xsl:param name="leader_length">30%</xsl:param>
		<fo:static-content flow-name="xsl-footnote-separator">
			<fo:block>
				<fo:leader leader-pattern="rule" leader-length="{$leader_length}"/>
			</fo:block>
		</fo:static-content>
	</xsl:template>

	<!-- ===================== -->
	<!-- END Footnotes processing  -->
	<!-- ===================== -->

	<!-- ===================== -->
	<!-- Definition List -->
	<!-- ===================== -->

	<!-- for table auto-layout algorithm -->
	<xsl:template match="*[local-name()='dl']" priority="2">
		<xsl:choose>
			<xsl:when test="$table_only_with_id != '' and @id = $table_only_with_id">
				<xsl:call-template name="dl"/>
			</xsl:when>
			<xsl:when test="$table_only_with_id != ''"><fo:block/><!-- to prevent empty fo:block-container --></xsl:when>
			<xsl:when test="$table_only_with_ids != '' and contains($table_only_with_ids, concat(@id, ' '))">
				<xsl:call-template name="dl"/>
			</xsl:when>
			<xsl:when test="$table_only_with_ids != ''"><fo:block/><!-- to prevent empty fo:block-container --></xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="dl"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[local-name()='dl']" name="dl">
		<xsl:variable name="isAdded" select="@added"/>
		<xsl:variable name="isDeleted" select="@deleted"/>
		<!-- <dl><xsl:copy-of select="."/></dl> -->
		<fo:block-container xsl:use-attribute-sets="dl-block-style" role="SKIP">

			<xsl:call-template name="setBlockSpanAll"/>

					<xsl:if test="not(ancestor::*[local-name() = 'quote'])">
						<xsl:attribute name="margin-left">0mm</xsl:attribute>
					</xsl:if>

			<xsl:if test="ancestor::*[local-name() = 'sourcecode']">
				<!-- set font-size as sourcecode font-size -->
				<xsl:variable name="sourcecode_attributes">
					<xsl:call-template name="get_sourcecode_attributes"/>
				</xsl:variable>
				<xsl:for-each select="xalan:nodeset($sourcecode_attributes)/sourcecode_attributes/@font-size">
					<xsl:attribute name="{local-name()}">
						<xsl:value-of select="."/>
					</xsl:attribute>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="parent::*[local-name() = 'note']">
				<xsl:attribute name="margin-left">
					<xsl:choose>
						<xsl:when test="not(ancestor::*[local-name() = 'table'])"><xsl:value-of select="$note-body-indent"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$note-body-indent-table"/></xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>

			</xsl:if>

			<xsl:call-template name="setTrackChangesStyles">
				<xsl:with-param name="isAdded" select="$isAdded"/>
				<xsl:with-param name="isDeleted" select="$isDeleted"/>
			</xsl:call-template>

			<fo:block-container margin-left="0mm" role="SKIP">

						<xsl:attribute name="margin-right">0mm</xsl:attribute>

				<xsl:variable name="parent" select="local-name(..)"/>

				<xsl:variable name="key_iso">
					 <!-- and  (not(../@class) or ../@class !='pseudocode') -->
				</xsl:variable>

				<xsl:variable name="onlyOneComponent" select="normalize-space($parent = 'formula' and count(*[local-name()='dt']) = 1)"/>

				<xsl:choose>
					<xsl:when test="$onlyOneComponent = 'true'"> <!-- only one component -->

								<fo:block margin-bottom="12pt" text-align="left">

									<!-- <xsl:variable name="title-where">
										<xsl:call-template name="getLocalizedString">
											<xsl:with-param name="key">where</xsl:with-param>
										</xsl:call-template>
									</xsl:variable>
									<xsl:value-of select="$title-where"/> -->
									<xsl:apply-templates select="preceding-sibling::*[1][local-name() = 'p' and @keep-with-next = 'true']/node()"/>
									<xsl:text> </xsl:text>
									<xsl:apply-templates select="*[local-name()='dt']/*"/>
									<xsl:if test="*[local-name()='dd']/node()[normalize-space() != ''][1][self::text()]">
										<xsl:text> </xsl:text>
									</xsl:if>
									<xsl:apply-templates select="*[local-name()='dd']/node()" mode="inline"/>
								</fo:block>

					</xsl:when> <!-- END: only one component -->
					<xsl:when test="$parent = 'formula'"> <!-- a few components -->
						<fo:block margin-bottom="12pt" text-align="left">

							<xsl:call-template name="refine_dl_formula_where_style"/>

							<!-- <xsl:variable name="title-where">
								<xsl:call-template name="getLocalizedString">
									<xsl:with-param name="key">where</xsl:with-param>
								</xsl:call-template>
							</xsl:variable>
							<xsl:value-of select="$title-where"/><xsl:if test="$namespace = 'bsi' or $namespace = 'itu'">:</xsl:if> -->
							<!-- preceding 'p' with word 'where' -->
							<xsl:apply-templates select="preceding-sibling::*[1][local-name() = 'p' and @keep-with-next = 'true']/node()"/>
						</fo:block>
					</xsl:when>  <!-- END: a few components -->
					<xsl:when test="$parent = 'figure' and  (not(../@class) or ../@class !='pseudocode')"> <!-- definition list in a figure -->
						<!-- Presentation XML contains 'Key' caption, https://github.com/metanorma/isodoc/issues/607 -->
						<xsl:if test="not(preceding-sibling::*[1][local-name() = 'p' and @keep-with-next])"> <!-- for old Presentation XML -->

									<fo:block font-weight="bold" text-align="left" margin-bottom="12pt" keep-with-next="always">

										<xsl:call-template name="refine_figure_key_style"/>

										<xsl:variable name="title-key">
											<xsl:call-template name="getLocalizedString">
												<xsl:with-param name="key">key</xsl:with-param>
											</xsl:call-template>
										</xsl:variable>
										<xsl:value-of select="$title-key"/>
									</fo:block>

						</xsl:if>
					</xsl:when>  <!-- END: definition list in a figure -->
				</xsl:choose>

				<!-- a few components -->
				<xsl:if test="$onlyOneComponent = 'false'">
					<fo:block role="SKIP">

						<xsl:call-template name="refine_multicomponent_style"/>

						<xsl:if test="ancestor::*[local-name() = 'dd' or local-name() = 'td']">
							<xsl:attribute name="margin-top">0</xsl:attribute>
						</xsl:if>

						<fo:block role="SKIP">

							<xsl:call-template name="refine_multicomponent_block_style"/>

							<xsl:apply-templates select="*[local-name() = 'name']">
								<xsl:with-param name="process">true</xsl:with-param>
							</xsl:apply-templates>

							<xsl:if test="$isGenerateTableIF = 'true'">
								<!-- to determine start of table -->
								<fo:block id="{concat('table_if_start_',@id)}" keep-with-next="always" font-size="1pt">Start table '<xsl:value-of select="@id"/>'.</fo:block>
							</xsl:if>

							<fo:table width="95%" table-layout="fixed">

								<xsl:if test="$isGenerateTableIF = 'true'">
									<xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
								</xsl:if>

								<xsl:choose>
									<xsl:when test="normalize-space($key_iso) = 'true' and $parent = 'formula'"/>
									<xsl:when test="normalize-space($key_iso) = 'true'">
										<xsl:attribute name="font-size">10pt</xsl:attribute>

									</xsl:when>
								</xsl:choose>

								<xsl:choose>
									<xsl:when test="$isGenerateTableIF = 'true'">
										<!-- generate IF for table widths -->
										<!-- example:
											<tr>
												<td valign="top" align="left" id="tab-symdu_1_1">
													<p>Symbol</p>
													<word id="tab-symdu_1_1_word_1">Symbol</word>
												</td>
												<td valign="top" align="left" id="tab-symdu_1_2">
													<p>Description</p>
													<word id="tab-symdu_1_2_word_1">Description</word>
												</td>
											</tr>
										-->

										<!-- create virtual html table for dl/[dt and dd] -->
										<xsl:variable name="simple-table">
											<!-- initial='<xsl:copy-of select="."/>' -->
											<xsl:variable name="dl_table">
												<tbody>
													<xsl:apply-templates mode="dl_if">
														<xsl:with-param name="id" select="@id"/>
													</xsl:apply-templates>
												</tbody>
											</xsl:variable>

											<!-- dl_table='<xsl:copy-of select="$dl_table"/>' -->

											<!-- Step: replace <br/> to <p>...</p> -->
											<xsl:variable name="table_without_br">
												<xsl:apply-templates select="xalan:nodeset($dl_table)" mode="table-without-br"/>
											</xsl:variable>

											<!-- table_without_br='<xsl:copy-of select="$table_without_br"/>' -->

											<!-- Step: add id to each cell -->
											<!-- add <word>...</word> for each word, image, math -->
											<xsl:variable name="simple-table-id">
												<xsl:apply-templates select="xalan:nodeset($table_without_br)" mode="simple-table-id">
													<xsl:with-param name="id" select="@id"/>
												</xsl:apply-templates>
											</xsl:variable>

											<!-- simple-table-id='<xsl:copy-of select="$simple-table-id"/>' -->

											<xsl:copy-of select="xalan:nodeset($simple-table-id)"/>

										</xsl:variable>

										<!-- DEBUG: simple-table<xsl:copy-of select="$simple-table"/> -->

										<xsl:apply-templates select="xalan:nodeset($simple-table)" mode="process_table-if">
											<xsl:with-param name="table_or_dl">dl</xsl:with-param>
										</xsl:apply-templates>

									</xsl:when>
									<xsl:otherwise>

										<xsl:variable name="simple-table">

											<xsl:variable name="dl_table">
												<tbody>
													<xsl:apply-templates mode="dl">
														<xsl:with-param name="id" select="@id"/>
													</xsl:apply-templates>
												</tbody>
											</xsl:variable>

											<xsl:copy-of select="$dl_table"/>
										</xsl:variable>

										<xsl:variable name="colwidths">
											<xsl:choose>
												<!-- dl from table[@class='dl'] -->
												<xsl:when test="*[local-name() = 'colgroup']">
													<autolayout/>
													<xsl:for-each select="*[local-name() = 'colgroup']/*[local-name() = 'col']">
														<column><xsl:value-of select="translate(@width,'%m','')"/></column>
													</xsl:for-each>
												</xsl:when>
												<xsl:otherwise>
													<xsl:call-template name="calculate-column-widths">
														<xsl:with-param name="cols-count" select="2"/>
														<xsl:with-param name="table" select="$simple-table"/>
													</xsl:call-template>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>

										<!-- <xsl:text disable-output-escaping="yes">&lt;!- -</xsl:text>
											DEBUG
											colwidths=<xsl:copy-of select="$colwidths"/>
										<xsl:text disable-output-escaping="yes">- -&gt;</xsl:text> -->

										<!-- colwidths=<xsl:copy-of select="$colwidths"/> -->

										<xsl:variable name="maxlength_dt">
											<xsl:call-template name="getMaxLength_dt"/>
										</xsl:variable>

										<xsl:variable name="isContainsKeepTogetherTag_">
											false
										</xsl:variable>
										<xsl:variable name="isContainsKeepTogetherTag" select="normalize-space($isContainsKeepTogetherTag_)"/>
										<!-- isContainsExpressReference=<xsl:value-of select="$isContainsExpressReference"/> -->

												<xsl:call-template name="setColumnWidth_dl">
													<xsl:with-param name="colwidths" select="$colwidths"/>
													<xsl:with-param name="maxlength_dt" select="$maxlength_dt"/>
													<xsl:with-param name="isContainsKeepTogetherTag" select="$isContainsKeepTogetherTag"/>
												</xsl:call-template>

										<fo:table-body>

											<!-- DEBUG -->
											<xsl:if test="$table_if_debug = 'true'">
												<fo:table-row>
													<fo:table-cell number-columns-spanned="2" font-size="60%">
														<xsl:apply-templates select="xalan:nodeset($colwidths)" mode="print_as_xml"/>
													</fo:table-cell>
												</fo:table-row>
											</xsl:if>

											<xsl:apply-templates>
												<xsl:with-param name="key_iso" select="normalize-space($key_iso)"/>
												<xsl:with-param name="split_keep-within-line" select="xalan:nodeset($colwidths)/split_keep-within-line"/>
											</xsl:apply-templates>

										</fo:table-body>
									</xsl:otherwise>
								</xsl:choose>
							</fo:table>
						</fo:block>
					</fo:block>
				</xsl:if> <!-- END: a few components -->
			</fo:block-container>
		</fo:block-container>

		<xsl:if test="$isGenerateTableIF = 'true'"> <!-- process nested 'dl' -->
			<xsl:apply-templates select="*[local-name() = 'dd']/*[local-name() = 'dl']"/>
		</xsl:if>

			<!-- display footnotes after after upper-level `dl` -->
			<xsl:if test="not(ancestor::*[local-name() = 'dl'])">
				<xsl:for-each select=".//jis:fn[generate-id(.)=generate-id(key('kfn',@reference)[1])]">
					<xsl:call-template name="fn_jis"/>
				</xsl:for-each>
			</xsl:if>

	</xsl:template> <!-- END: dl -->

	<xsl:template match="@*|node()" mode="dt_clean">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="dt_clean"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'asciimath']" mode="dt_clean"/>

	<!-- caption for figure key and another caption, https://github.com/metanorma/isodoc/issues/607 -->
	<xsl:template match="*[local-name() = 'figure']/*[local-name() = 'p'][@keep-with-next = 'true' and *[local-name() = 'strong']]" priority="3">
		<fo:block text-align="left" margin-bottom="12pt" keep-with-next="always">
			<xsl:call-template name="refine_figure_key_style"/>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template name="refine_dl_formula_where_style">

	</xsl:template> <!-- refine_dl_formula_where_style -->

	<xsl:template name="refine_figure_key_style">

	</xsl:template> <!-- refine_figure_key_style -->

	<xsl:template name="refine_multicomponent_style">
		<xsl:variable name="parent" select="local-name(..)"/>

	</xsl:template> <!-- refine_multicomponent_style -->

	<xsl:template name="refine_multicomponent_block_style">
		<xsl:variable name="parent" select="local-name(..)"/>

	</xsl:template> <!-- refine_multicomponent_block_style -->

	<!-- ignore 'p' with 'where' in formula, before 'dl' -->
	<xsl:template match="*[local-name() = 'formula']/*[local-name() = 'p' and @keep-with-next = 'true' and following-sibling::*[1][local-name() = 'dl']]"/>

	<!-- dl/name -->
	<xsl:template match="*[local-name() = 'dl']/*[local-name() = 'name']">
		<xsl:param name="process">false</xsl:param>
		<xsl:if test="$process = 'true'">
			<fo:block xsl:use-attribute-sets="dl-name-style">

				<xsl:apply-templates/>
			</fo:block>
		</xsl:if>
	</xsl:template>

	<xsl:template name="setColumnWidth_dl">
		<xsl:param name="colwidths"/>
		<xsl:param name="maxlength_dt"/>
		<xsl:param name="isContainsKeepTogetherTag"/>

		<!-- <colwidths><xsl:copy-of select="$colwidths"/></colwidths> -->

		<xsl:choose>
			<!-- <xsl:when test="@class = 'formula_dl' and local-name(..) = 'figure'">
				<fo:table-column column-width="10%"/>
				<fo:table-column column-width="90%"/>
			</xsl:when> -->
			<xsl:when test="xalan:nodeset($colwidths)/autolayout">
				<xsl:call-template name="insertTableColumnWidth">
					<xsl:with-param name="colwidths" select="$colwidths"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="ancestor::*[local-name()='dl']"><!-- second level, i.e. inlined table -->
				<fo:table-column column-width="50%"/>
				<fo:table-column column-width="50%"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="xalan:nodeset($colwidths)/autolayout">
						<xsl:call-template name="insertTableColumnWidth">
							<xsl:with-param name="colwidths" select="$colwidths"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$isContainsKeepTogetherTag">
						<xsl:call-template name="insertTableColumnWidth">
							<xsl:with-param name="colwidths" select="$colwidths"/>
						</xsl:call-template>
					</xsl:when>
					<!-- to set width check most wide chars like `W` -->
					<xsl:when test="normalize-space($maxlength_dt) != '' and number($maxlength_dt) &lt;= 2"> <!-- if dt contains short text like t90, a, etc -->
						<fo:table-column column-width="7%"/>
						<fo:table-column column-width="93%"/>
					</xsl:when>
					<xsl:when test="normalize-space($maxlength_dt) != '' and number($maxlength_dt) &lt;= 5"> <!-- if dt contains short text like ABC, etc -->
						<fo:table-column column-width="15%"/>
						<fo:table-column column-width="85%"/>
					</xsl:when>
					<xsl:when test="normalize-space($maxlength_dt) != '' and number($maxlength_dt) &lt;= 7"> <!-- if dt contains short text like ABCDEF, etc -->
						<fo:table-column column-width="20%"/>
						<fo:table-column column-width="80%"/>
					</xsl:when>
					<xsl:when test="normalize-space($maxlength_dt) != '' and number($maxlength_dt) &lt;= 10"> <!-- if dt contains short text like ABCDEFEF, etc -->
						<fo:table-column column-width="25%"/>
						<fo:table-column column-width="75%"/>
					</xsl:when>
					<!-- <xsl:when test="xalan:nodeset($colwidths)/column[1] div xalan:nodeset($colwidths)/column[2] &gt; 1.7">
						<fo:table-column column-width="60%"/>
						<fo:table-column column-width="40%"/>
					</xsl:when> -->
					<xsl:when test="xalan:nodeset($colwidths)/column[1] div xalan:nodeset($colwidths)/column[2] &gt; 1.3">
						<fo:table-column column-width="50%"/>
						<fo:table-column column-width="50%"/>
					</xsl:when>
					<xsl:when test="xalan:nodeset($colwidths)/column[1] div xalan:nodeset($colwidths)/column[2] &gt; 0.5">
						<fo:table-column column-width="40%"/>
						<fo:table-column column-width="60%"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="insertTableColumnWidth">
							<xsl:with-param name="colwidths" select="$colwidths"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="insertTableColumnWidth">
		<xsl:param name="colwidths"/>

		<xsl:for-each select="xalan:nodeset($colwidths)//column">
			<xsl:choose>
				<xsl:when test=". = 1 or . = 0">
					<fo:table-column column-width="proportional-column-width(2)"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- <fo:table-column column-width="proportional-column-width({.})"/> -->
					<xsl:variable name="divider">
						<xsl:value-of select="@divider"/>
						<xsl:if test="not(@divider)">1</xsl:if>
					</xsl:variable>
					<fo:table-column column-width="proportional-column-width({round(. div $divider)})"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="getMaxLength_dt">
		<xsl:variable name="lengths">
			<xsl:for-each select="*[local-name()='dt']">
				<xsl:variable name="maintext_length" select="string-length(normalize-space(.))"/>
				<xsl:variable name="attributes">
					<xsl:for-each select=".//@open"><xsl:value-of select="."/></xsl:for-each>
					<xsl:for-each select=".//@close"><xsl:value-of select="."/></xsl:for-each>
				</xsl:variable>
				<length><xsl:value-of select="string-length(normalize-space(.)) + string-length($attributes)"/></length>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="maxLength">
			<xsl:for-each select="xalan:nodeset($lengths)/length">
				<xsl:sort select="." data-type="number" order="descending"/>
				<xsl:if test="position() = 1">
					<xsl:value-of select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<!-- <xsl:message>DEBUG:<xsl:value-of select="$maxLength"/></xsl:message> -->
		<xsl:value-of select="$maxLength"/>
	</xsl:template>

	<!-- note in definition list: dl/note -->
	<!-- renders in the 2-column spanned table row -->
	<xsl:template match="*[local-name()='dl']/*[local-name()='note']" priority="2">
		<xsl:param name="key_iso"/>
		<!-- <tr>
			<td>NOTE</td>
			<td>
				<xsl:apply-templates />
			</td>
		</tr>
		 -->
		<!-- OLD Variant -->
		<!-- <fo:table-row>
			<fo:table-cell>
				<fo:block margin-top="6pt">
					<xsl:if test="normalize-space($key_iso) = 'true'">
						<xsl:attribute name="margin-top">0</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates select="*[local-name() = 'name']" />
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block>
					<xsl:apply-templates select="node()[not(local-name() = 'name')]" />
				</fo:block>
			</fo:table-cell>
		</fo:table-row> -->
		<!-- <tr>
			<td number-columns-spanned="2">NOTE <xsl:apply-templates /> </td>
		</tr> 
		-->
		<fo:table-row>
			<fo:table-cell number-columns-spanned="2">
				<fo:block role="SKIP">
					<xsl:call-template name="note"/>
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
	</xsl:template> <!-- END: dl/note -->

	<!-- virtual html table for dl/[dt and dd]  -->
	<xsl:template match="*[local-name()='dt']" mode="dl">
		<xsl:param name="id"/>
		<xsl:variable name="row_number" select="count(preceding-sibling::*[local-name()='dt']) + 1"/>
		<tr>
			<td>
				<xsl:attribute name="id">
					<xsl:value-of select="concat($id,'@',$row_number,'_1')"/>
				</xsl:attribute>
				<xsl:apply-templates/>
			</td>
			<td>
				<xsl:attribute name="id">
					<xsl:value-of select="concat($id,'@',$row_number,'_2')"/>
				</xsl:attribute>

						<xsl:apply-templates select="following-sibling::*[local-name()='dd'][1]">
							<xsl:with-param name="process">true</xsl:with-param>
						</xsl:apply-templates>

			</td>
		</tr>

	</xsl:template>

	<!-- Definition's term -->
	<xsl:template match="*[local-name()='dt']">
		<xsl:param name="key_iso"/>
		<xsl:param name="split_keep-within-line"/>

		<fo:table-row xsl:use-attribute-sets="dt-row-style">

			<xsl:call-template name="insert_dt_cell">
				<xsl:with-param name="key_iso" select="$key_iso"/>
				<xsl:with-param name="split_keep-within-line" select="$split_keep-within-line"/>
			</xsl:call-template>
			<xsl:for-each select="following-sibling::*[local-name()='dd'][1]">
				<xsl:call-template name="insert_dd_cell">
					<xsl:with-param name="split_keep-within-line" select="$split_keep-within-line"/>
				</xsl:call-template>
			</xsl:for-each>
		</fo:table-row>
	</xsl:template> <!-- END: dt -->

	<xsl:template name="insert_dt_cell">
		<xsl:param name="key_iso"/>
		<xsl:param name="split_keep-within-line"/>
		<fo:table-cell xsl:use-attribute-sets="dt-cell-style">

			<xsl:if test="$isGenerateTableIF = 'true'">
				<!-- border is mandatory, to calculate real width -->
				<xsl:attribute name="border">0.1pt solid black</xsl:attribute>
				<xsl:attribute name="text-align">left</xsl:attribute>

			</xsl:if>

			<xsl:call-template name="refine_dt-cell-style"/>

			<fo:block xsl:use-attribute-sets="dt-block-style" role="SKIP">

				<xsl:choose>
					<xsl:when test="$isGenerateTableIF = 'true'">

							<fo:inline>
								<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
								<xsl:value-of select="$hair_space"/>
							</fo:inline>

					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="@id"/>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:if test="normalize-space($key_iso) = 'true'">
					<xsl:attribute name="margin-top">0</xsl:attribute>
				</xsl:if>

				<xsl:call-template name="refine_dt-block-style"/>

				<xsl:apply-templates>
					<xsl:with-param name="split_keep-within-line" select="$split_keep-within-line"/>
				</xsl:apply-templates>

				<xsl:if test="$isGenerateTableIF = 'true'"><fo:inline id="{@id}_end">end</fo:inline></xsl:if> <!-- to determine width of text --> <!-- <xsl:value-of select="$hair_space"/> -->

			</fo:block>
		</fo:table-cell>
	</xsl:template> <!-- insert_dt_cell -->

	<xsl:template name="insert_dd_cell">
		<xsl:param name="split_keep-within-line"/>
		<fo:table-cell xsl:use-attribute-sets="dd-cell-style">

			<xsl:if test="$isGenerateTableIF = 'true'">
				<!-- border is mandatory, to calculate real width -->
				<xsl:attribute name="border">0.1pt solid black</xsl:attribute>
			</xsl:if>

			<xsl:call-template name="refine_dd-cell-style"/>

			<fo:block role="SKIP">

				<xsl:if test="$isGenerateTableIF = 'true'">

							<fo:inline>
								<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
								<xsl:value-of select="$hair_space"/>
							</fo:inline>

				</xsl:if>

				<xsl:choose>
					<xsl:when test="$isGenerateTableIF = 'true'">
						<xsl:apply-templates> <!-- following-sibling::*[local-name()='dd'][1] -->
							<xsl:with-param name="process">true</xsl:with-param>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="."> <!-- following-sibling::*[local-name()='dd'][1] -->
							<xsl:with-param name="process">true</xsl:with-param>
							<xsl:with-param name="split_keep-within-line" select="$split_keep-within-line"/>
						</xsl:apply-templates>
					</xsl:otherwise>

				</xsl:choose>

				<xsl:if test="$isGenerateTableIF = 'true'"><fo:inline id="{@id}_end">end</fo:inline></xsl:if> <!-- to determine width of text --> <!-- <xsl:value-of select="$hair_space"/> -->

			</fo:block>
		</fo:table-cell>
	</xsl:template> <!-- insert_dd_cell -->

	<!-- END Definition's term -->

	<xsl:template match="*[local-name()='dd']" mode="dl"/>
	<xsl:template match="*[local-name()='dd']" mode="dl_process">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="*[local-name()='dd']">
		<xsl:param name="process">false</xsl:param>
		<xsl:param name="split_keep-within-line"/>
		<xsl:if test="$process = 'true'">
			<xsl:apply-templates select="@language"/>
			<xsl:apply-templates>
				<xsl:with-param name="split_keep-within-line" select="$split_keep-within-line"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name()='dd']/*" mode="inline">
		<xsl:variable name="is_inline_element_after_where">
			<xsl:if test="(local-name() = 'p') and not(preceding-sibling::node()[normalize-space() != ''])">true</xsl:if>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$is_inline_element_after_where = 'true'">
				<fo:inline><xsl:text> </xsl:text><xsl:apply-templates/></fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- virtual html table for dl/[dt and dd] for IF (Intermediate Format) -->
	<xsl:template match="*[local-name()='dt']" mode="dl_if">
		<xsl:param name="id"/>
		<tr>
			<td>
				<xsl:copy-of select="node()"/>
			</td>
			<td>
				<!-- <xsl:copy-of select="following-sibling::*[local-name()='dd'][1]/node()[not(local-name() = 'dl')]"/> -->
				<xsl:apply-templates select="following-sibling::*[local-name()='dd'][1]/node()[not(local-name() = 'dl')]" mode="dl_if"/>
				<!-- get paragraphs from nested 'dl' -->
				<xsl:apply-templates select="following-sibling::*[local-name()='dd'][1]/*[local-name() = 'dl']" mode="dl_if_nested"/>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="*[local-name()='dd']" mode="dl_if"/>

	<xsl:template match="*" mode="dl_if">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'p']" mode="dl_if">
		<xsl:param name="indent"/>
		<p>
			<xsl:copy-of select="@*"/>
			<xsl:value-of select="$indent"/>
			<xsl:copy-of select="node()"/>
		</p>

	</xsl:template>

	<xsl:template match="*[local-name() = 'ul' or local-name() = 'ol']" mode="dl_if">
		<xsl:variable name="list_rendered_">
			<xsl:apply-templates select="."/>
		</xsl:variable>
		<xsl:variable name="list_rendered" select="xalan:nodeset($list_rendered_)"/>

		<xsl:variable name="indent">
			<xsl:for-each select="($list_rendered//fo:block[not(.//fo:block)])[1]">
				<xsl:apply-templates select="ancestor::*[@provisional-distance-between-starts]/@provisional-distance-between-starts" mode="dl_if"/>
			</xsl:for-each>
		</xsl:variable>

		<xsl:apply-templates mode="dl_if">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*[local-name() = 'li']" mode="dl_if">
		<xsl:param name="indent"/>
		<xsl:apply-templates mode="dl_if">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="@provisional-distance-between-starts" mode="dl_if">
		<xsl:variable name="value" select="round(substring-before(.,'mm'))"/>
		<!-- emulate left indent for list item -->
		<xsl:call-template name="repeat">
			<xsl:with-param name="char" select="'x'"/>
			<xsl:with-param name="count" select="$value"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="*[local-name()='dl']" mode="dl_if_nested">
		<xsl:for-each select="*[local-name() = 'dt']">
			<p>
				<xsl:copy-of select="node()"/>
				<xsl:text> </xsl:text>
				<xsl:copy-of select="following-sibling::*[local-name()='dd'][1]/*[local-name() = 'p']/node()"/>
			</p>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="*[local-name()='dd']" mode="dl_if_nested"/>
	<!-- ===================== -->
	<!-- END Definition List -->
	<!-- ===================== -->

	<!-- default: ignore title in sections/p -->
	<xsl:template match="*[local-name() = 'sections']/*[local-name() = 'p'][starts-with(@class, 'zzSTDTitle')]" priority="3"/>

	<!-- ========================= -->
	<!-- Rich text formatting -->
	<!-- ========================= -->
	<xsl:template match="*[local-name()='em']">
		<fo:inline font-style="italic">
			<xsl:call-template name="refine_italic_style"/>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<xsl:template name="refine_italic_style">

	</xsl:template>

	<xsl:template match="*[local-name()='strong'] | *[local-name()='b']">
		<xsl:param name="split_keep-within-line"/>
		<fo:inline font-weight="bold">

			<xsl:call-template name="refine_strong_style"/>

			<xsl:apply-templates>
				<xsl:with-param name="split_keep-within-line" select="$split_keep-within-line"/>
			</xsl:apply-templates>
		</fo:inline>
	</xsl:template>

	<xsl:template name="refine_strong_style">

			<xsl:if test="not($vertical_layout = 'true')">
				<xsl:attribute name="font-family">Times New Roman</xsl:attribute>
			</xsl:if>

		<xsl:if test="ancestor::*['preferred']">
			<xsl:attribute name="role">SKIP</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name()='padding']">
		<fo:inline padding-right="{@value}"> </fo:inline>
	</xsl:template>

	<xsl:template match="*[local-name()='sup']">
		<fo:inline font-size="80%" vertical-align="super">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<xsl:template match="*[local-name()='sub']">
		<fo:inline font-size="80%" vertical-align="sub">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<xsl:template match="*[local-name()='tt']">
		<fo:inline xsl:use-attribute-sets="tt-style">

			<xsl:variable name="_font-size">

				 <!-- inherit -->

			</xsl:variable>
			<xsl:variable name="font-size" select="normalize-space($_font-size)"/>
			<xsl:if test="$font-size != ''">
				<xsl:attribute name="font-size">
					<xsl:choose>
						<xsl:when test="$font-size = 'inherit'"><xsl:value-of select="$font-size"/></xsl:when>
						<xsl:when test="contains($font-size, '%')"><xsl:value-of select="$font-size"/></xsl:when>
						<xsl:when test="ancestor::*[local-name()='note'] or ancestor::*[local-name()='example']"><xsl:value-of select="$font-size * 0.91"/>pt</xsl:when>
						<xsl:otherwise><xsl:value-of select="$font-size"/>pt</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template> <!-- tt -->

	<xsl:variable name="regex_url_start">^(http://|https://|www\.)?(.*)</xsl:variable>
	<xsl:template match="*[local-name()='tt']/text()" priority="2">
		<xsl:choose>
			<xsl:when test="java:replaceAll(java:java.lang.String.new(.), $regex_url_start, '$2') != ''">
				 <!-- url -->
				<xsl:call-template name="add-zero-spaces-link-java"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="add_spaces_to_sourcecode"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[local-name()='underline']">
		<fo:inline text-decoration="underline">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<!-- ================= -->
	<!-- Added,deleted text -->
	<!-- ================= -->
	<xsl:template match="*[local-name()='add'] | *[local-name() = 'change-open-tag'] | *[local-name() = 'change-close-tag']" name="tag_add">
		<xsl:param name="skip">true</xsl:param>
		<xsl:param name="block">false</xsl:param>
		<xsl:param name="type"/>
		<xsl:param name="text-align"/>
		<xsl:choose>
			<xsl:when test="starts-with(., $ace_tag) or local-name() = 'change-open-tag' or local-name() = 'change-close-tag'"> <!-- examples: ace-tag_A1_start, ace-tag_A2_end, C1_start, AC_start, or
							<change-open-tag>A<sub>1</sub></change-open-tag>, <change-close-tag>A<sub>1</sub></change-close-tag> -->
				<xsl:choose>
					<xsl:when test="$skip = 'true' and       ((local-name(../..) = 'note' and not(preceding-sibling::node())) or       (local-name(..) = 'title' and preceding-sibling::node()[1][local-name() = 'tab']) or      local-name(..) = 'formattedref' and not(preceding-sibling::node()))      and       ../node()[last()][local-name() = 'add'][starts-with(text(), $ace_tag)]"><!-- start tag displayed in template name="note" and title --></xsl:when>
					<xsl:otherwise>
						<xsl:variable name="tag">
							<xsl:call-template name="insertTag">
								<xsl:with-param name="type">
									<xsl:choose>
										<xsl:when test="local-name() = 'change-open-tag'">start</xsl:when>
										<xsl:when test="local-name() = 'change-close-tag'">end</xsl:when>
										<xsl:when test="$type = ''"><xsl:value-of select="substring-after(substring-after(., $ace_tag), '_')"/> <!-- start or end --></xsl:when>
										<xsl:otherwise><xsl:value-of select="$type"/></xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
								<xsl:with-param name="kind">
									<xsl:choose>
										<xsl:when test="local-name() = 'change-open-tag' or local-name() = 'change-close-tag'">
											<xsl:value-of select="text()"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring(substring-before(substring-after(., $ace_tag), '_'), 1, 1)"/> <!-- A or C -->
										</xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
								<xsl:with-param name="value">
									<xsl:choose>
										<xsl:when test="local-name() = 'change-open-tag' or local-name() = 'change-close-tag'">
											<xsl:value-of select="*[local-name() = 'sub']"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring(substring-before(substring-after(., $ace_tag), '_'), 2)"/> <!-- 1, 2, C -->
										</xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="$block = 'false'">
								<fo:inline>
									<xsl:copy-of select="$tag"/>
								</fo:inline>
							</xsl:when>
							<xsl:otherwise>
								<fo:block> <!-- for around figures -->
									<xsl:if test="$text-align != ''">
										<xsl:attribute name="text-align"><xsl:value-of select="$text-align"/></xsl:attribute>
									</xsl:if>
									<xsl:copy-of select="$tag"/>
								</fo:block>
							</xsl:otherwise>
						</xsl:choose>

					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@amendment">
				<fo:inline>
					<xsl:call-template name="insertTag">
						<xsl:with-param name="kind">A</xsl:with-param>
						<xsl:with-param name="value"><xsl:value-of select="@amendment"/></xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates/>
					<xsl:call-template name="insertTag">
						<xsl:with-param name="type">closing</xsl:with-param>
						<xsl:with-param name="kind">A</xsl:with-param>
						<xsl:with-param name="value"><xsl:value-of select="@amendment"/></xsl:with-param>
					</xsl:call-template>
				</fo:inline>
			</xsl:when>
			<xsl:when test="@corrigenda">
				<fo:inline>
					<xsl:call-template name="insertTag">
						<xsl:with-param name="kind">C</xsl:with-param>
						<xsl:with-param name="value"><xsl:value-of select="@corrigenda"/></xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates/>
					<xsl:call-template name="insertTag">
						<xsl:with-param name="type">closing</xsl:with-param>
						<xsl:with-param name="kind">C</xsl:with-param>
						<xsl:with-param name="value"><xsl:value-of select="@corrigenda"/></xsl:with-param>
					</xsl:call-template>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline xsl:use-attribute-sets="add-style">
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template> <!-- add -->

	<xsl:template name="insertTag">
		<xsl:param name="type"/>
		<xsl:param name="kind"/>
		<xsl:param name="value"/>
		<xsl:variable name="add_width" select="string-length($value) * 20"/>
		<xsl:variable name="maxwidth" select="60 + $add_width"/>
			<fo:instream-foreign-object fox:alt-text="OpeningTag" baseline-shift="-10%"><!-- alignment-baseline="middle" -->
				<xsl:attribute name="height">3.5mm</xsl:attribute> <!-- 5mm -->
				<xsl:attribute name="content-width">100%</xsl:attribute>
				<xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
				<xsl:attribute name="scaling">uniform</xsl:attribute>
				<!-- <svg xmlns="http://www.w3.org/2000/svg" width="{$maxwidth + 32}" height="80">
					<g>
						<xsl:if test="$type = 'closing' or $type = 'end'">
							<xsl:attribute name="transform">scale(-1 1) translate(-<xsl:value-of select="$maxwidth + 32"/>,0)</xsl:attribute>
						</xsl:if>
						<polyline points="0,0 {$maxwidth},0 {$maxwidth + 30},40 {$maxwidth},80 0,80 " stroke="black" stroke-width="5" fill="white"/>
						<line x1="0" y1="0" x2="0" y2="80" stroke="black" stroke-width="20"/>
					</g>
					<text font-family="Arial" x="15" y="57" font-size="40pt">
						<xsl:if test="$type = 'closing' or $type = 'end'">
							<xsl:attribute name="x">25</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="$kind"/><tspan dy="10" font-size="30pt"><xsl:value-of select="$value"/></tspan>
					</text>
				</svg> -->
				<svg xmlns="http://www.w3.org/2000/svg" width="{$maxwidth + 32}" height="80">
					<g>
						<xsl:if test="$type = 'closing' or $type = 'end'">
							<xsl:attribute name="transform">scale(-1 1) translate(-<xsl:value-of select="$maxwidth + 32"/>,0)</xsl:attribute>
						</xsl:if>
						<polyline points="0,2.5 {$maxwidth},2.5 {$maxwidth + 20},40 {$maxwidth},77.5 0,77.5" stroke="black" stroke-width="5" fill="white"/>
						<line x1="9.5" y1="0" x2="9.5" y2="80" stroke="black" stroke-width="19"/>
					</g>
					<xsl:variable name="text_x">
						<xsl:choose>
							<xsl:when test="$type = 'closing' or $type = 'end'">28</xsl:when>
							<xsl:otherwise>22</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<text font-family="Arial" x="{$text_x}" y="50" font-size="40pt">
						<xsl:value-of select="$kind"/>
					</text>
					<text font-family="Arial" x="{$text_x + 33}" y="65" font-size="38pt">
						<xsl:value-of select="$value"/>
					</text>
				</svg>
			</fo:instream-foreign-object>
	</xsl:template>

	<xsl:template match="*[local-name()='del']">
		<fo:inline xsl:use-attribute-sets="del-style">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
	<!-- ================= -->
	<!-- END Added,deleted text -->
	<!-- ================= -->

	<!-- highlight text -->
	<xsl:template match="*[local-name()='hi']">
		<fo:inline background-color="yellow">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<xsl:template match="text()[ancestor::*[local-name()='smallcap']]" name="smallcaps">
		<xsl:param name="txt"/>
		<!-- <xsl:variable name="text" select="normalize-space(.)"/> --> <!-- https://github.com/metanorma/metanorma-iso/issues/1115 -->
		<xsl:variable name="text">
			<xsl:choose>
				<xsl:when test="$txt != ''">
					<xsl:value-of select="$txt"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="ratio_">
			0.75
		</xsl:variable>
		<xsl:variable name="ratio" select="number(normalize-space($ratio_))"/>
		<fo:inline font-size="{$ratio * 100}%" role="SKIP">
				<xsl:if test="string-length($text) &gt; 0">
					<xsl:variable name="smallCapsText">
						<xsl:call-template name="recursiveSmallCaps">
							<xsl:with-param name="text" select="$text"/>
							<xsl:with-param name="ratio" select="$ratio"/>
						</xsl:call-template>
					</xsl:variable>
					<!-- merge neighboring fo:inline -->
					<xsl:for-each select="xalan:nodeset($smallCapsText)/node()">
						<xsl:choose>
							<xsl:when test="self::fo:inline and preceding-sibling::node()[1][self::fo:inline]"><!-- <xsl:copy-of select="."/> --></xsl:when>
							<xsl:when test="self::fo:inline and @font-size">
								<xsl:variable name="curr_pos" select="count(preceding-sibling::node()) + 1"/>
								<!-- <curr_pos><xsl:value-of select="$curr_pos"/></curr_pos> -->
								<xsl:variable name="next_text_" select="count(following-sibling::node()[not(local-name() = 'inline')][1]/preceding-sibling::node())"/>
								<xsl:variable name="next_text">
									<xsl:choose>
										<xsl:when test="$next_text_ = 0">99999999</xsl:when>
										<xsl:otherwise><xsl:value-of select="$next_text_ + 1"/></xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<!-- <next_text><xsl:value-of select="$next_text"/></next_text> -->
								<fo:inline>
									<xsl:copy-of select="@*"/>
									<xsl:copy-of select="./node()"/>
									<xsl:for-each select="following-sibling::node()[position() &lt; $next_text - $curr_pos]"> <!-- [self::fo:inline] -->
										<xsl:copy-of select="./node()"/>
									</xsl:for-each>
								</fo:inline>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="."/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:if>
			</fo:inline>
	</xsl:template>

	<xsl:template name="recursiveSmallCaps">
    <xsl:param name="text"/>
    <xsl:param name="ratio">0.75</xsl:param>
    <xsl:variable name="char" select="substring($text,1,1)"/>
    <!-- <xsl:variable name="upperCase" select="translate($char, $lower, $upper)"/> -->
		<xsl:variable name="upperCase" select="java:toUpperCase(java:java.lang.String.new($char))"/>
    <xsl:choose>
      <xsl:when test="$char=$upperCase">
        <fo:inline font-size="{100 div $ratio}%" role="SKIP">
          <xsl:value-of select="$upperCase"/>
        </fo:inline>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$upperCase"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="string-length($text) &gt; 1">
      <xsl:call-template name="recursiveSmallCaps">
        <xsl:with-param name="text" select="substring($text,2)"/>
        <xsl:with-param name="ratio" select="$ratio"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

	<xsl:template match="*[local-name()='strike']">
		<fo:inline text-decoration="line-through">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<xsl:template match="*[local-name() = 'pagebreak']">
		<fo:block break-after="page"/>
		<fo:block> </fo:block>
		<fo:block break-after="page"/>
	</xsl:template>

	<!-- Example: <span style="font-family:&quot;Noto Sans JP&quot;">styled text</span> -->
	<xsl:template match="*[local-name() = 'span'][@style]" priority="2">
		<xsl:variable name="styles__">
			<xsl:call-template name="split">
				<xsl:with-param name="pText" select="concat(@style,';')"/>
				<xsl:with-param name="sep" select="';'"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="quot">"</xsl:variable>
		<xsl:variable name="styles_">
			<xsl:for-each select="xalan:nodeset($styles__)/item">
				<xsl:variable name="key" select="normalize-space(substring-before(., ':'))"/>
				<xsl:variable name="value_" select="normalize-space(substring-after(translate(.,$quot,''), ':'))"/>
				<xsl:variable name="value">
					<xsl:choose>
						<!-- if font-size is digits only -->
						<xsl:when test="$key = 'font-size' and translate($value_, '0123456789', '') = ''"><xsl:value-of select="$value_"/>pt</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$value_"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:if test="$key = 'font-family' or $key = 'font-size' or $key = 'color'">
					<style name="{$key}"><xsl:value-of select="$value"/></style>
				</xsl:if>
				<xsl:if test="$key = 'text-indent'">
					<style name="padding-left"><xsl:value-of select="$value"/></style>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="styles" select="xalan:nodeset($styles_)"/>
		<xsl:choose>
			<xsl:when test="$styles/style">
				<fo:inline>
					<xsl:for-each select="$styles/style">
						<xsl:attribute name="{@name}"><xsl:value-of select="."/></xsl:attribute>

							<xsl:if test="@name = 'font-family' and . = 'MS Gothic'">
								<xsl:if test="not($vertical_layout = 'true')">
									<xsl:attribute name="{@name}">IPAexGothic</xsl:attribute>
								</xsl:if>
								<xsl:if test="$vertical_layout = 'true'">
									<xsl:attribute name="{@name}">Noto Serif JP</xsl:attribute>
								</xsl:if>
							</xsl:if>

					</xsl:for-each>
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template> <!-- END: span[@style] -->

	<!-- Note: to enable the addition of character span markup with semantic styling for DIS Word output -->
	<xsl:template match="*[local-name() = 'span']">
		<xsl:apply-templates/>
	</xsl:template>

	<!-- Don't break standard's numbers -->
	<!-- Example : <span class="stdpublisher">ISO</span> <span class="stddocNumber">10303</span>-<span class="stddocPartNumber">1</span>:<span class="stdyear">1994</span> -->
	<xsl:template match="*[local-name() = 'span'][@class = 'stdpublisher' or @class = 'stddocNumber' or @class = 'stddocPartNumber' or @class = 'stdyear']" priority="2">
		<xsl:choose>
			<xsl:when test="ancestor::*[local-name() = 'table']"><xsl:apply-templates/></xsl:when>
			<xsl:when test="following-sibling::*[2][local-name() = 'span'][@class = 'stdpublisher' or @class = 'stddocNumber' or @class = 'stddocPartNumber' or @class = 'stdyear']">
				<fo:inline keep-with-next.within-line="always" role="SKIP"><xsl:apply-templates/></fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="text()[not(ancestor::*[local-name() = 'table']) and preceding-sibling::*[1][local-name() = 'span'][@class = 'stdpublisher' or @class = 'stddocNumber' or @class = 'stddocPartNumber' or @class = 'stdyear'] and   following-sibling::*[1][local-name() = 'span'][@class = 'stdpublisher' or @class = 'stddocNumber' or @class = 'stddocPartNumber' or @class = 'stdyear']]" priority="2">
		<fo:inline keep-with-next.within-line="always" role="SKIP"><xsl:value-of select="."/></fo:inline>
	</xsl:template>

	<xsl:template match="*[local-name() = 'span'][contains(@style, 'text-transform:none')]//text()" priority="5">
		<xsl:value-of select="."/>
	</xsl:template>

	<!-- ========================= -->
	<!-- END Rich text formatting -->
	<!-- ========================= -->

	<!-- split string 'text' by 'separator' -->
	<xsl:template name="tokenize">
		<xsl:param name="text"/>
		<xsl:param name="separator" select="' '"/>
		<xsl:choose>

			<xsl:when test="$isGenerateTableIF = 'true' and not(contains($text, $separator))">
				<word><xsl:value-of select="normalize-space($text)"/></word>
			</xsl:when>
			<xsl:when test="not(contains($text, $separator))">
				<word>
					<xsl:variable name="len_str_tmp" select="string-length(normalize-space($text))"/>
					<xsl:choose>
						<xsl:when test="normalize-space(translate($text, 'X', '')) = ''"> <!-- special case for keep-together.within-line -->
							<xsl:value-of select="$len_str_tmp"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="str_no_en_chars" select="normalize-space(translate($text, $en_chars, ''))"/>
							<xsl:variable name="len_str_no_en_chars" select="string-length($str_no_en_chars)"/>
							<xsl:variable name="len_str">
								<xsl:choose>
									<xsl:when test="normalize-space(translate($text, $upper, '')) = ''"> <!-- english word in CAPITAL letters -->
										<xsl:value-of select="$len_str_tmp * 1.5"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$len_str_tmp"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>

							<!-- <xsl:if test="$len_str_no_en_chars div $len_str &gt; 0.8">
								<xsl:message>
									div=<xsl:value-of select="$len_str_no_en_chars div $len_str"/>
									len_str=<xsl:value-of select="$len_str"/>
									len_str_no_en_chars=<xsl:value-of select="$len_str_no_en_chars"/>
								</xsl:message>
							</xsl:if> -->
							<!-- <len_str_no_en_chars><xsl:value-of select="$len_str_no_en_chars"/></len_str_no_en_chars>
							<len_str><xsl:value-of select="$len_str"/></len_str> -->
							<xsl:choose>
								<xsl:when test="$len_str_no_en_chars div $len_str &gt; 0.8"> <!-- means non-english string -->
									<xsl:value-of select="$len_str - $len_str_no_en_chars"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$len_str"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</word>
			</xsl:when>
			<xsl:otherwise>
				<word>
					<xsl:variable name="word" select="normalize-space(substring-before($text, $separator))"/>
					<xsl:choose>
						<xsl:when test="$isGenerateTableIF = 'true'">
							<xsl:value-of select="$word"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="string-length($word)"/>
						</xsl:otherwise>
					</xsl:choose>
				</word>
				<xsl:call-template name="tokenize">
					<xsl:with-param name="text" select="substring-after($text, $separator)"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- split string 'text' by 'separator', enclosing in formatting tags -->
	<xsl:template name="tokenize_with_tags">
		<xsl:param name="tags"/>
		<xsl:param name="text"/>
		<xsl:param name="separator" select="' '"/>
		<xsl:choose>

			<xsl:when test="not(contains($text, $separator))">
				<word>
					<xsl:if test="ancestor::*[local-name() = 'p'][@from_dl = 'true']">
						<xsl:text>
 </xsl:text> <!-- to add distance between dt and dd -->
					</xsl:if>
					<xsl:call-template name="enclose_text_in_tags">
						<xsl:with-param name="text" select="normalize-space($text)"/>
						<xsl:with-param name="tags" select="$tags"/>
					</xsl:call-template>
				</word>
			</xsl:when>
			<xsl:otherwise>
				<word>
					<xsl:if test="ancestor::*[local-name() = 'p'][@from_dl = 'true']">
						<xsl:text>
 </xsl:text> <!-- to add distance between dt and dd -->
					</xsl:if>
					<xsl:call-template name="enclose_text_in_tags">
						<xsl:with-param name="text" select="normalize-space(substring-before($text, $separator))"/>
						<xsl:with-param name="tags" select="$tags"/>
					</xsl:call-template>
				</word>
				<xsl:call-template name="tokenize_with_tags">
					<xsl:with-param name="text" select="substring-after($text, $separator)"/>
					<xsl:with-param name="tags" select="$tags"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="enclose_text_in_tags">
		<xsl:param name="text"/>
		<xsl:param name="tags"/>
		<xsl:param name="num">1</xsl:param> <!-- default (start) value -->

		<xsl:variable name="tag_name" select="normalize-space(xalan:nodeset($tags)//tag[$num])"/>

		<xsl:choose>
			<xsl:when test="$tag_name = ''"><xsl:value-of select="$text"/></xsl:when>
			<xsl:otherwise>
				<xsl:element name="{$tag_name}">
					<xsl:call-template name="enclose_text_in_tags">
						<xsl:with-param name="text" select="$text"/>
						<xsl:with-param name="tags" select="$tags"/>
						<xsl:with-param name="num" select="$num + 1"/>
					</xsl:call-template>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- get max value in array -->
	<xsl:template name="max_length">
		<xsl:param name="words"/>
		<xsl:for-each select="$words//word">
				<xsl:sort select="." data-type="number" order="descending"/>
				<xsl:if test="position()=1">
						<xsl:value-of select="."/>
				</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="add-zero-spaces-java">
		<xsl:param name="text" select="."/>

		<!-- add zero-width space (#x200B) after dot with next non-digit -->
		<xsl:variable name="text1" select="java:replaceAll(java:java.lang.String.new($text),'(\.)([^\d\s])','$1​$2')"/>
		<!-- add zero-width space (#x200B) after characters: dash, equal, underscore, em dash, thin space, arrow right, ;   -->
		<xsl:variable name="text2" select="java:replaceAll(java:java.lang.String.new($text1),'(-|=|_|—| |→|;)','$1​')"/>
		<!-- add zero-width space (#x200B) after characters: colon, if there aren't digits after -->
		<xsl:variable name="text3" select="java:replaceAll(java:java.lang.String.new($text2),'(:)(\D)','$1​$2')"/>
		<!-- add zero-width space (#x200B) after characters: 'great than' -->
		<xsl:variable name="text4" select="java:replaceAll(java:java.lang.String.new($text3), '(\u003e)(?!\u003e)', '$1​')"/><!-- negative lookahead: 'great than' not followed by 'great than' -->
		<!-- add zero-width space (#x200B) before characters: 'less than' -->
		<xsl:variable name="text5" select="java:replaceAll(java:java.lang.String.new($text4), '(?&lt;!\u003c)(\u003c)', '​$1')"/> <!-- (?<!\u003c)(\u003c) --> <!-- negative lookbehind: 'less than' not preceeded by 'less than' -->
		<!-- add zero-width space (#x200B) before character: { -->
		<xsl:variable name="text6" select="java:replaceAll(java:java.lang.String.new($text5), '(?&lt;!\W)(\{)', '​$1')"/> <!-- negative lookbehind: '{' not preceeded by 'punctuation char' -->
		<!-- add zero-width space (#x200B) after character: , -->
		<xsl:variable name="text7" select="java:replaceAll(java:java.lang.String.new($text6), '(\,)(?!\d)', '$1​')"/> <!-- negative lookahead: ',' not followed by digit -->
		<!-- add zero-width space (#x200B) after character: '/' -->
		<xsl:variable name="text8" select="java:replaceAll(java:java.lang.String.new($text7), '(\u002f)(?!\u002f)', '$1​')"/><!-- negative lookahead: '/' not followed by '/' -->

		<xsl:variable name="text9">
			<xsl:choose>
				<xsl:when test="$isGenerateTableIF = 'true'">
					<xsl:value-of select="java:replaceAll(java:java.lang.String.new($text8), '([\u3000-\u9FFF])', '$1​')"/> <!-- 3000 - CJK Symbols and Punctuation ... 9FFF CJK Unified Ideographs-->
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="$text8"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- replace sequence #x200B to one &#x200B -->
		<xsl:variable name="text10" select="java:replaceAll(java:java.lang.String.new($text9), '\u200b{2,}', '​')"/>

		<!-- replace sequence #x200B and space TO space -->
		<xsl:variable name="text11" select="java:replaceAll(java:java.lang.String.new($text10), '\u200b ', ' ')"/>

		<xsl:value-of select="$text11"/>
	</xsl:template>

	<xsl:template name="add-zero-spaces-link-java">
		<xsl:param name="text" select="."/>

		<xsl:value-of select="java:replaceAll(java:java.lang.String.new($text), $regex_url_start, '$1')"/> <!-- http://. https:// or www. -->
		<xsl:variable name="url_continue" select="java:replaceAll(java:java.lang.String.new($text), $regex_url_start, '$2')"/>
		<!-- add zero-width space (#x200B) after characters: dash, dot, colon, equal, underscore, em dash, thin space, comma, slash, @  -->
		<xsl:variable name="url" select="java:replaceAll(java:java.lang.String.new($url_continue),'(-|\.|:|=|_|—| |,|/|@)','$1​')"/>

		<!-- replace sequence #x200B to one &#x200B -->
		<xsl:variable name="url2" select="java:replaceAll(java:java.lang.String.new($url), '\u200b{2,}', '​')"/>

		<!-- remove zero-width space at the end -->
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new($url2), '​$', '')"/>
	</xsl:template>

	<!-- add zero space after dash character (for table's entries) -->
	<xsl:template name="add-zero-spaces">
		<xsl:param name="text" select="."/>
		<xsl:variable name="zero-space-after-chars">-</xsl:variable>
		<xsl:variable name="zero-space-after-dot">.</xsl:variable>
		<xsl:variable name="zero-space-after-colon">:</xsl:variable>
		<xsl:variable name="zero-space-after-equal">=</xsl:variable>
		<xsl:variable name="zero-space-after-underscore">_</xsl:variable>
		<xsl:variable name="zero-space">​</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($text, $zero-space-after-chars)">
				<xsl:value-of select="substring-before($text, $zero-space-after-chars)"/>
				<xsl:value-of select="$zero-space-after-chars"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-chars)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-dot)">
				<xsl:value-of select="substring-before($text, $zero-space-after-dot)"/>
				<xsl:value-of select="$zero-space-after-dot"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-dot)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-colon)">
				<xsl:value-of select="substring-before($text, $zero-space-after-colon)"/>
				<xsl:value-of select="$zero-space-after-colon"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-colon)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-equal)">
				<xsl:value-of select="substring-before($text, $zero-space-after-equal)"/>
				<xsl:value-of select="$zero-space-after-equal"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-equal)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-underscore)">
				<xsl:value-of select="substring-before($text, $zero-space-after-underscore)"/>
				<xsl:value-of select="$zero-space-after-underscore"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-underscore)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="add-zero-spaces-equal">
		<xsl:param name="text" select="."/>
		<xsl:variable name="zero-space-after-equals">==========</xsl:variable>
		<xsl:variable name="regex_zero-space-after-equals">(==========)</xsl:variable>
		<xsl:variable name="zero-space-after-equal">=</xsl:variable>
		<xsl:variable name="regex_zero-space-after-equal">(=)</xsl:variable>
		<xsl:variable name="zero-space">​</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($text, $zero-space-after-equals)">
				<!-- <xsl:value-of select="substring-before($text, $zero-space-after-equals)"/>
				<xsl:value-of select="$zero-space-after-equals"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces-equal">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-equals)"/>
				</xsl:call-template> -->
				<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.),$regex_zero-space-after-equals,concat('$1',$zero_width_space))"/>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-equal)">
				<!-- <xsl:value-of select="substring-before($text, $zero-space-after-equal)"/>
				<xsl:value-of select="$zero-space-after-equal"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces-equal">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-equal)"/>
				</xsl:call-template> -->
				<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.),$regex_zero-space-after-equal,concat('$1',$zero_width_space))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Table normalization (colspan,rowspan processing for adding TDs) for column width calculation -->
	<xsl:template name="getSimpleTable">
		<xsl:param name="id"/>

		<!-- <test0>
			<xsl:copy-of select="."/>
		</test0> -->

		<xsl:variable name="simple-table">

			<xsl:variable name="table_without_semantic_elements">
				<xsl:apply-templates mode="update_xml_pres"/>
			</xsl:variable>

			<!-- Step 0. replace <br/> to <p>...</p> -->
			<xsl:variable name="table_without_br">
				<!-- <xsl:apply-templates mode="table-without-br"/> -->
				<xsl:apply-templates select="xalan:nodeset($table_without_semantic_elements)" mode="table-without-br"/>
			</xsl:variable>

			<!-- Step 1. colspan processing -->
			<xsl:variable name="simple-table-colspan">
				<tbody>
					<xsl:apply-templates select="xalan:nodeset($table_without_br)" mode="simple-table-colspan"/>
				</tbody>
			</xsl:variable>

			<!-- Step 2. rowspan processing -->
			<xsl:variable name="simple-table-rowspan">
				<xsl:apply-templates select="xalan:nodeset($simple-table-colspan)" mode="simple-table-rowspan"/>
			</xsl:variable>

			<!-- Step 3: add id to each cell -->
			<!-- add <word>...</word> for each word, image, math -->
			<xsl:variable name="simple-table-id">
				<xsl:apply-templates select="xalan:nodeset($simple-table-rowspan)" mode="simple-table-id">
					<xsl:with-param name="id" select="$id"/>
				</xsl:apply-templates>
			</xsl:variable>

			<xsl:copy-of select="xalan:nodeset($simple-table-id)"/>

		</xsl:variable>
		<xsl:copy-of select="$simple-table"/>
	</xsl:template>

	<!-- ================================== -->
	<!-- Step 0. replace <br/> to <p>...</p> -->
	<!-- ================================== -->
	<xsl:template match="@*|node()" mode="table-without-br">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="table-without-br"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name()='th' or local-name() = 'td'][not(*[local-name()='br']) and not(*[local-name()='p']) and not(*[local-name()='sourcecode']) and not(*[local-name()='ul']) and not(*[local-name()='ol'])]" mode="table-without-br">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<p>
				<xsl:copy-of select="node()"/>
			</p>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name()='th' or local-name()='td'][*[local-name()='br']]" mode="table-without-br">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:for-each select="*[local-name()='br']">
				<xsl:variable name="current_id" select="generate-id()"/>
				<p>
					<xsl:for-each select="preceding-sibling::node()[following-sibling::*[local-name() = 'br'][1][generate-id() = $current_id]][not(local-name() = 'br')]">
						<xsl:copy-of select="."/>
					</xsl:for-each>
				</p>
				<xsl:if test="not(following-sibling::*[local-name() = 'br'])">
					<p>
						<xsl:for-each select="following-sibling::node()">
							<xsl:copy-of select="."/>
						</xsl:for-each>
					</p>
				</xsl:if>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name()='th' or local-name()='td']/*[local-name() = 'p'][*[local-name()='br']]" mode="table-without-br">
		<xsl:for-each select="*[local-name()='br']">
			<xsl:variable name="current_id" select="generate-id()"/>
			<p>
				<xsl:for-each select="preceding-sibling::node()[following-sibling::*[local-name() = 'br'][1][generate-id() = $current_id]][not(local-name() = 'br')]">
					<xsl:copy-of select="."/>
				</xsl:for-each>
			</p>
			<xsl:if test="not(following-sibling::*[local-name() = 'br'])">
				<p>
					<xsl:for-each select="following-sibling::node()">
						<xsl:copy-of select="."/>
					</xsl:for-each>
				</p>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*[local-name()='th' or local-name()='td']/*[local-name() = 'sourcecode']" mode="table-without-br">
		<xsl:apply-templates mode="table-without-br"/>
	</xsl:template>

	<xsl:template match="*[local-name()='th' or local-name()='td']/*[local-name() = 'sourcecode']/text()[contains(., '&#13;') or contains(., '&#10;')]" mode="table-without-br">

		<xsl:variable name="sep">###SOURCECODE_NEWLINE###</xsl:variable>
		<xsl:variable name="sourcecode_text" select="java:replaceAll(java:java.lang.String.new(.),'(&#13;&#10;|&#13;|&#10;)', $sep)"/>
		<xsl:variable name="items">
			<xsl:call-template name="split">
				<xsl:with-param name="pText" select="$sourcecode_text"/>
				<xsl:with-param name="sep" select="$sep"/>
				<xsl:with-param name="normalize-space">false</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:for-each select="xalan:nodeset($items)/*">
			<p>
				<sourcecode><xsl:copy-of select="node()"/></sourcecode>
			</p>
		</xsl:for-each>
	</xsl:template>

	<!-- remove redundant white spaces -->
	<xsl:template match="text()[not(ancestor::*[local-name() = 'sourcecode'])]" mode="table-without-br">
		<xsl:variable name="text" select="translate(.,'&#9;&#10;&#13;','')"/>
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new($text),' {2,}',' ')"/>
	</xsl:template>

	<xsl:template match="*[local-name()='th' or local-name()='td']//*[local-name() = 'ol' or local-name() = 'ul']" mode="table-without-br">
		<xsl:apply-templates mode="table-without-br"/>
	</xsl:template>

	<xsl:template match="*[local-name()='th' or local-name()='td']//*[local-name() = 'li']" mode="table-without-br">
		<xsl:apply-templates mode="table-without-br"/>
	</xsl:template>

	<!-- mode="table-without-br" -->
	<!-- ================================== -->
	<!-- END: Step 0. replace <br/> to <p>...</p> -->
	<!-- ================================== -->

	<!-- ===================== -->
	<!-- 1. mode "simple-table-colspan" 
			1.1. remove thead, tbody, fn
			1.2. rename th -> td
			1.3. repeating N td with colspan=N
			1.4. remove namespace
			1.5. remove @colspan attribute
			1.6. add @divide attribute for divide text width in further processing 
	-->
	<!-- ===================== -->
	<xsl:template match="*[local-name()='thead'] | *[local-name()='tbody']" mode="simple-table-colspan">
		<xsl:apply-templates mode="simple-table-colspan"/>
	</xsl:template>
	<xsl:template match="*[local-name()='fn']" mode="simple-table-colspan"/>

	<xsl:template match="*[local-name()='th'] | *[local-name()='td']" mode="simple-table-colspan">
		<xsl:choose>
			<xsl:when test="@colspan">
				<xsl:variable name="td">
					<xsl:element name="{local-name()}">
						<xsl:attribute name="divide"><xsl:value-of select="@colspan"/></xsl:attribute>
						<xsl:if test="local-name()='th'">
							<xsl:attribute name="font-weight">bold</xsl:attribute>
						</xsl:if>
						<xsl:apply-templates select="@*" mode="simple-table-colspan"/>
						<xsl:apply-templates mode="simple-table-colspan"/>
					</xsl:element>
				</xsl:variable>
				<xsl:call-template name="repeatNode">
					<xsl:with-param name="count" select="@colspan"/>
					<xsl:with-param name="node" select="$td"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="{local-name()}">
					<xsl:apply-templates select="@*" mode="simple-table-colspan"/>
					<xsl:if test="local-name()='th'">
						<xsl:attribute name="font-weight">bold</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates mode="simple-table-colspan"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@colspan" mode="simple-table-colspan"/>

	<xsl:template match="*[local-name()='tr']" mode="simple-table-colspan">
		<xsl:element name="tr">
			<xsl:apply-templates select="@*" mode="simple-table-colspan"/>
			<xsl:apply-templates mode="simple-table-colspan"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="@*|node()" mode="simple-table-colspan">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="simple-table-colspan"/>
		</xsl:copy>
	</xsl:template>

	<!-- repeat node 'count' times -->
	<xsl:template name="repeatNode">
		<xsl:param name="count"/>
		<xsl:param name="node"/>

		<xsl:if test="$count &gt; 0">
			<xsl:call-template name="repeatNode">
				<xsl:with-param name="count" select="$count - 1"/>
				<xsl:with-param name="node" select="$node"/>
			</xsl:call-template>
			<xsl:copy-of select="$node"/>
		</xsl:if>
	</xsl:template>
	<!-- End mode simple-table-colspan  -->
	<!-- ===================== -->
	<!-- ===================== -->

	<!-- ===================== -->
	<!-- 2. mode "simple-table-rowspan" 
	Row span processing, more information http://andrewjwelch.com/code/xslt/table/table-normalization.html	-->
	<!-- ===================== -->
	<xsl:template match="@*|node()" mode="simple-table-rowspan">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="simple-table-rowspan"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="tbody" mode="simple-table-rowspan">
		<xsl:copy>
				<xsl:copy-of select="tr[1]"/>
				<xsl:apply-templates select="tr[2]" mode="simple-table-rowspan">
						<xsl:with-param name="previousRow" select="tr[1]"/>
				</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="tr" mode="simple-table-rowspan">
		<xsl:param name="previousRow"/>
		<xsl:variable name="currentRow" select="."/>

		<xsl:variable name="normalizedTDs">
				<xsl:for-each select="xalan:nodeset($previousRow)//*[self::td or self::th]">
						<xsl:choose>
								<xsl:when test="@rowspan &gt; 1">
										<xsl:copy>
												<xsl:attribute name="rowspan">
														<xsl:value-of select="@rowspan - 1"/>
												</xsl:attribute>
												<xsl:copy-of select="@*[not(name() = 'rowspan')]"/>
												<xsl:copy-of select="node()"/>
										</xsl:copy>
								</xsl:when>
								<xsl:otherwise>
										<xsl:copy-of select="$currentRow/*[self::td or self::th][1 + count(current()/preceding-sibling::*[self::td or self::th][not(@rowspan) or (@rowspan = 1)])]"/>
								</xsl:otherwise>
						</xsl:choose>
				</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="newRow">
				<xsl:copy>
						<xsl:copy-of select="$currentRow/@*"/>
						<xsl:copy-of select="xalan:nodeset($normalizedTDs)"/>
				</xsl:copy>
		</xsl:variable>
		<xsl:copy-of select="$newRow"/>

		<!-- optimize to prevent StackOverflowError, just copy next 'tr' -->
		<xsl:variable name="currrow_num" select="count(preceding-sibling::tr) + 1"/>
		<xsl:variable name="nextrow_without_rowspan_" select="count(following-sibling::tr[*[@rowspan and @rowspan != 1]][1]/preceding-sibling::tr) + 1"/>
		<xsl:variable name="nextrow_without_rowspan" select="$nextrow_without_rowspan_ - $currrow_num"/>
		<xsl:choose>
			<xsl:when test="not(xalan:nodeset($newRow)/*/*[@rowspan and @rowspan != 1]) and $nextrow_without_rowspan &lt;= 0">
				<xsl:copy-of select="following-sibling::tr"/>
			</xsl:when>
			<!-- <xsl:when test="xalan:nodeset($newRow)/*[not(@rowspan) or (@rowspan = 1)] and $nextrow_without_rowspan &gt; 0">
				<xsl:copy-of select="following-sibling::tr[position() &lt;= $nextrow_without_rowspan]"/>
				
				<xsl:copy-of select="following-sibling::tr[$nextrow_without_rowspan + 1]"/>
				<xsl:apply-templates select="following-sibling::tr[$nextrow_without_rowspan + 2]" mode="simple-table-rowspan">
						<xsl:with-param name="previousRow" select="following-sibling::tr[$nextrow_without_rowspan + 1]"/>
				</xsl:apply-templates>
			</xsl:when> -->
			<xsl:otherwise>
				<xsl:apply-templates select="following-sibling::tr[1]" mode="simple-table-rowspan">
						<xsl:with-param name="previousRow" select="$newRow"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- End mode simple-table-rowspan  -->

	<!-- Step 3: add id for each cell -->
	<!-- mode: simple-table-id -->
	<xsl:template match="/" mode="simple-table-id">
		<xsl:param name="id"/>
		<xsl:variable name="id_prefixed" select="concat('table_if_',$id)"/> <!-- table id prefixed by 'table_if_' to simple search in IF  -->
		<xsl:apply-templates select="@*|node()" mode="simple-table-id">
			<xsl:with-param name="id" select="$id_prefixed"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="@*|node()" mode="simple-table-id">
		<xsl:param name="id"/>
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="simple-table-id">
					<xsl:with-param name="id" select="$id"/>
				</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name()='tbody']" mode="simple-table-id">
		<xsl:param name="id"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
			<xsl:apply-templates select="node()" mode="simple-table-id">
				<xsl:with-param name="id" select="$id"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:variable name="font_main_root_style">
		<root-style xsl:use-attribute-sets="root-style">
		</root-style>
	</xsl:variable>
	<xsl:variable name="font_main_root_style_font_family" select="xalan:nodeset($font_main_root_style)/root-style/@font-family"/>
	<xsl:variable name="font_main">
		<xsl:choose>
			<xsl:when test="contains($font_main_root_style_font_family, ',')"><xsl:value-of select="substring-before($font_main_root_style_font_family, ',')"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$font_main_root_style_font_family"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="*[local-name()='th' or local-name()='td']" mode="simple-table-id">
		<xsl:param name="id"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:variable name="row_number" select="count(../preceding-sibling::*) + 1"/>
			<xsl:variable name="col_number" select="count(preceding-sibling::*) + 1"/>
			<xsl:variable name="divide">
				<xsl:choose>
					<xsl:when test="@divide"><xsl:value-of select="@divide"/></xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:attribute name="id">
				<xsl:value-of select="concat($id,'@',$row_number,'_',$col_number,'_',$divide)"/>
			</xsl:attribute>

			<xsl:for-each select="*[local-name() = 'p']">
				<xsl:copy>
					<xsl:copy-of select="@*"/>
					<xsl:variable name="p_num" select="count(preceding-sibling::*[local-name() = 'p']) + 1"/>
					<xsl:attribute name="id">
						<xsl:value-of select="concat($id,'@',$row_number,'_',$col_number,'_p_',$p_num,'_',$divide)"/>
					</xsl:attribute>

					<!-- <xsl:copy-of select="node()" /> -->
					<xsl:apply-templates mode="simple-table-noid"/>

				</xsl:copy>
			</xsl:for-each>

			<xsl:if test="$isGenerateTableIF = 'true'"> <!-- split each paragraph to words, image, math -->

				<xsl:variable name="td_text">
					<xsl:apply-templates select="." mode="td_text_with_formatting"/>
				</xsl:variable>

				<!-- td_text='<xsl:copy-of select="$td_text"/>' -->

				<xsl:variable name="words_with_width">
					<!-- calculate width for 'word' which contain text only (without formatting tags inside) -->
					<xsl:for-each select="xalan:nodeset($td_text)//*[local-name() = 'word'][normalize-space() != ''][not(*)]">
						<xsl:copy>
							<xsl:copy-of select="@*"/>
							<xsl:attribute name="width">
								<xsl:value-of select="java:org.metanorma.fop.Util.getStringWidth(., $font_main)"/> <!-- Example: 'Times New Roman' -->
							</xsl:attribute>
							<xsl:copy-of select="node()"/>
						</xsl:copy>
					</xsl:for-each>
				</xsl:variable>

				<xsl:variable name="words_with_width_sorted">
					<xsl:for-each select="xalan:nodeset($words_with_width)//*[local-name() = 'word']">
						<xsl:sort select="@width" data-type="number" order="descending"/>
						<!-- select word maximal width only -->
						<xsl:if test="position() = 1">
							<xsl:copy-of select="."/>
						</xsl:if>
					</xsl:for-each>
					<!-- add 'word' with formatting tags inside -->
					<xsl:for-each select="xalan:nodeset($td_text)//*[local-name() = 'word'][normalize-space() != ''][*]">
						<xsl:copy-of select="."/>
					</xsl:for-each>
				</xsl:variable>

				<!-- <xsl:if test="$debug = 'true'">
					<redirect:write file="{generate-id()}_words_with_width_sorted.xml">
						<td_text><xsl:copy-of select="$td_text"/></td_text>
						<words_with_width><xsl:copy-of select="$words_with_width"/></words_with_width>
						<xsl:copy-of select="$words_with_width_sorted"/>
					</redirect:write>
				</xsl:if> -->

				<xsl:variable name="words">
					<xsl:for-each select=".//*[local-name() = 'image' or local-name() = 'stem']">
						<word>
							<xsl:copy-of select="."/>
						</word>
					</xsl:for-each>

					<xsl:for-each select="xalan:nodeset($words_with_width_sorted)//*[local-name() = 'word'][normalize-space() != '']">
						<xsl:copy-of select="."/>
					</xsl:for-each>
					<!-- <xsl:for-each select="xalan:nodeset($td_text)//*[local-name() = 'word'][normalize-space() != '']">
						<xsl:copy-of select="."/>
					</xsl:for-each> -->

				</xsl:variable>

				<xsl:for-each select="xalan:nodeset($words)/word">
					<xsl:variable name="num" select="count(preceding-sibling::word) + 1"/>
					<xsl:copy>
						<xsl:attribute name="id">
							<xsl:value-of select="concat($id,'@',$row_number,'_',$col_number,'_word_',$num,'_',$divide)"/>
						</xsl:attribute>
						<xsl:copy-of select="node()"/>
					</xsl:copy>
				</xsl:for-each>
			</xsl:if>
		</xsl:copy>

	</xsl:template>

	<xsl:template match="*[local-name()='th' or local-name()='td']/*[local-name() = 'p']//*" mode="simple-table-noid">
		<xsl:copy>
			<xsl:choose>
				<xsl:when test="$isGenerateTableIF = 'true'">
					<xsl:copy-of select="@*[local-name() != 'id']"/> <!-- to prevent repeat id in colspan/rowspan cells -->
					<!-- <xsl:if test="local-name() = 'dl' or local-name() = 'table'">
						<xsl:copy-of select="@id"/>
					</xsl:if> -->
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="@*"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="node()" mode="simple-table-noid"/>
		</xsl:copy>
	</xsl:template>

	<!-- End mode: simple-table-id -->
	<!-- ===================== -->
	<!-- ===================== -->

	<!-- =============================== -->
	<!-- mode="td_text_with_formatting" -->
	<!-- =============================== -->
	<xsl:template match="@*|node()" mode="td_text_with_formatting">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="td_text_with_formatting"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'stem' or local-name() = 'image']" mode="td_text_with_formatting"/>

	<xsl:template match="*[local-name() = 'keep-together_within-line']/text()" mode="td_text_with_formatting">
		<xsl:variable name="formatting_tags">
			<xsl:call-template name="getFormattingTags"/>
		</xsl:variable>
		<word>
			<xsl:call-template name="enclose_text_in_tags">
				<xsl:with-param name="text" select="normalize-space(.)"/>
				<xsl:with-param name="tags" select="$formatting_tags"/>
			</xsl:call-template>
		</word>
	</xsl:template>

	<xsl:template match="*[local-name() != 'keep-together_within-line']/text()" mode="td_text_with_formatting">

		<xsl:variable name="td_text" select="."/>

		<xsl:variable name="string_with_added_zerospaces">
			<xsl:call-template name="add-zero-spaces-java">
				<xsl:with-param name="text" select="$td_text"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="formatting_tags">
			<xsl:call-template name="getFormattingTags"/>
		</xsl:variable>

		<!-- <word>text</word> -->
		<xsl:call-template name="tokenize_with_tags">
			<xsl:with-param name="tags" select="$formatting_tags"/>
			<xsl:with-param name="text" select="normalize-space(translate($string_with_added_zerospaces, '​­', '  '))"/> <!-- replace zero-width-space and soft-hyphen to space -->
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="*[local-name() = 'link'][normalize-space() = '']" mode="td_text_with_formatting">
		<xsl:variable name="link">
			<link_updated>
				<xsl:variable name="target_text">
					<xsl:choose>
						<xsl:when test="starts-with(normalize-space(@target), 'mailto:')">
							<xsl:value-of select="normalize-space(substring-after(@target, 'mailto:'))"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(@target)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:value-of select="$target_text"/>
			</link_updated>
		</xsl:variable>
		<xsl:for-each select="xalan:nodeset($link)/*">
			<xsl:apply-templates mode="td_text_with_formatting"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="getFormattingTags">
		<tags>
			<xsl:if test="ancestor::*[local-name() = 'strong']"><tag>strong</tag></xsl:if>
			<xsl:if test="ancestor::*[local-name() = 'em']"><tag>em</tag></xsl:if>
			<xsl:if test="ancestor::*[local-name() = 'sub']"><tag>sub</tag></xsl:if>
			<xsl:if test="ancestor::*[local-name() = 'sup']"><tag>sup</tag></xsl:if>
			<xsl:if test="ancestor::*[local-name() = 'tt']"><tag>tt</tag></xsl:if>
			<xsl:if test="ancestor::*[local-name() = 'sourcecode']"><tag>sourcecode</tag></xsl:if>
			<xsl:if test="ancestor::*[local-name() = 'keep-together_within-line']"><tag>keep-together_within-line</tag></xsl:if>
			<xsl:if test="ancestor::*[local-name() = 'font_en_vertical']"><tag>font_en_vertical</tag></xsl:if>
		</tags>
	</xsl:template>
	<!-- =============================== -->
	<!-- END mode="td_text_with_formatting" -->
	<!-- =============================== -->

	<xsl:template name="getLang">
		<xsl:variable name="language_current" select="normalize-space(//*[local-name()='bibdata']//*[local-name()='language'][@current = 'true'])"/>
		<xsl:variable name="language">
			<xsl:choose>
				<xsl:when test="$language_current != ''">
					<xsl:value-of select="$language_current"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="language_current_2" select="normalize-space(xalan:nodeset($bibdata)//*[local-name()='bibdata']//*[local-name()='language'][@current = 'true'])"/>
					<xsl:choose>
						<xsl:when test="$language_current_2 != ''">
							<xsl:value-of select="$language_current_2"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="language_current_3" select="normalize-space(//*[local-name()='bibdata']//*[local-name()='language'])"/>
							<xsl:choose>
								<xsl:when test="$language_current_3 != ''">
									<xsl:value-of select="$language_current_3"/>
								</xsl:when>
								<xsl:otherwise>en</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$language = 'English'">en</xsl:when>
			<xsl:otherwise><xsl:value-of select="$language"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="getLang_fromCurrentNode">
		<xsl:variable name="language_current" select="normalize-space(.//*[local-name()='bibdata']//*[local-name()='language'][@current = 'true'])"/>
		<xsl:variable name="language">
			<xsl:choose>
				<xsl:when test="$language_current != ''">
					<xsl:value-of select="$language_current"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="language_current_2" select="normalize-space(xalan:nodeset($bibdata)//*[local-name()='bibdata']//*[local-name()='language'][@current = 'true'])"/>
					<xsl:choose>
						<xsl:when test="$language_current_2 != ''">
							<xsl:value-of select="$language_current_2"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select=".//*[local-name()='bibdata']//*[local-name()='language']"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$language = 'English'">en</xsl:when>
			<xsl:otherwise><xsl:value-of select="$language"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="capitalizeWords">
		<xsl:param name="str"/>
		<xsl:variable name="str2" select="translate($str, '-', ' ')"/>
		<xsl:choose>
			<xsl:when test="contains($str2, ' ')">
				<xsl:variable name="substr" select="substring-before($str2, ' ')"/>
				<xsl:call-template name="capitalize">
					<xsl:with-param name="str" select="$substr"/>
				</xsl:call-template>
				<xsl:text> </xsl:text>
				<xsl:call-template name="capitalizeWords">
					<xsl:with-param name="str" select="substring-after($str2, ' ')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="capitalize">
					<xsl:with-param name="str" select="$str2"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="capitalize">
		<xsl:param name="str"/>
		<xsl:value-of select="java:toUpperCase(java:java.lang.String.new(substring($str, 1, 1)))"/>
		<xsl:value-of select="substring($str, 2)"/>
	</xsl:template>

	<!-- ======================================= -->
	<!-- math -->
	<!-- ======================================= -->
	<xsl:template match="*[local-name() = 'stem'][following-sibling::*[1][local-name() = 'fmt-stem']]"/> <!-- for tablesonly.xml generated by mn2pdf -->

	<xsl:template match="mathml:math">
		<xsl:variable name="isAdded" select="@added"/>
		<xsl:variable name="isDeleted" select="@deleted"/>

		<fo:inline xsl:use-attribute-sets="mathml-style">

			<!-- DEBUG -->
			<!-- <xsl:copy-of select="ancestor::*[local-name() = 'stem']/@font-family"/> -->

			<xsl:call-template name="refine_mathml-style"/>

			<xsl:if test="$isGenerateTableIF = 'true' and ancestor::*[local-name() = 'td' or local-name() = 'th' or local-name() = 'dl'] and not(following-sibling::node()[not(self::comment())][normalize-space() != ''])"> <!-- math in table cell, and math is last element -->
				<!-- <xsl:attribute name="padding-right">1mm</xsl:attribute> -->
			</xsl:if>

			<xsl:call-template name="setTrackChangesStyles">
				<xsl:with-param name="isAdded" select="$isAdded"/>
				<xsl:with-param name="isDeleted" select="$isDeleted"/>
			</xsl:call-template>

			<xsl:if test="$add_math_as_text = 'true'">
				<!-- insert helper tag -->
				<!-- set unique font-size (fiction) -->
				<xsl:variable name="font-size_sfx"><xsl:number level="any"/></xsl:variable>
				<fo:inline color="white" font-size="1.{$font-size_sfx}pt" font-style="normal" font-weight="normal"><xsl:value-of select="$zero_width_space"/></fo:inline> <!-- zero width space -->
			</xsl:if>

			<xsl:variable name="mathml_content">
				<xsl:apply-templates select="." mode="mathml_actual_text"/>
			</xsl:variable>

					<xsl:call-template name="mathml_instream_object">
						<xsl:with-param name="mathml_content" select="$mathml_content"/>
					</xsl:call-template>

		</fo:inline>
	</xsl:template>

	<xsl:template name="getMathml_comment_text">
		<xsl:variable name="comment_text_following" select="following-sibling::node()[1][self::comment()]"/>
		<xsl:variable name="comment_text_">
			<xsl:choose>
				<xsl:when test="normalize-space($comment_text_following) != ''">
					<xsl:value-of select="$comment_text_following"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(translate(.,' ⁢','  '))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="comment_text_2" select="java:org.metanorma.fop.Util.unescape($comment_text_)"/>
		<xsl:variable name="comment_text" select="java:trim(java:java.lang.String.new($comment_text_2))"/>
		<xsl:value-of select="$comment_text"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'asciimath']">
		<xsl:param name="process" select="'false'"/>
		<xsl:if test="$process = 'true'">
			<xsl:apply-templates/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'latexmath']"/>

	<xsl:template name="getMathml_asciimath_text">
		<xsl:variable name="asciimath" select="../*[local-name() = 'asciimath']"/>
		<xsl:variable name="latexmath">

		</xsl:variable>
		<xsl:variable name="asciimath_text_following">
			<xsl:choose>
				<xsl:when test="normalize-space($latexmath) != ''">
					<xsl:value-of select="$latexmath"/>
				</xsl:when>
				<xsl:when test="normalize-space($asciimath) != ''">
					<xsl:value-of select="$asciimath"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="following-sibling::node()[1][self::comment()]"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="asciimath_text_">
			<xsl:choose>
				<xsl:when test="normalize-space($asciimath_text_following) != ''">
					<xsl:value-of select="$asciimath_text_following"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(translate(.,' ⁢','  '))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="asciimath_text_2" select="java:org.metanorma.fop.Util.unescape($asciimath_text_)"/>
		<xsl:variable name="asciimath_text" select="java:trim(java:java.lang.String.new($asciimath_text_2))"/>
		<xsl:value-of select="$asciimath_text"/>
	</xsl:template>

	<xsl:template name="mathml_instream_object">
		<xsl:param name="asciimath_text"/>
		<xsl:param name="mathml_content"/>

		<xsl:variable name="asciimath_text_">
			<xsl:choose>
				<xsl:when test="normalize-space($asciimath_text) != ''"><xsl:value-of select="$asciimath_text"/></xsl:when>
				<!-- <xsl:otherwise><xsl:call-template name="getMathml_comment_text"/></xsl:otherwise> -->
				<xsl:otherwise><xsl:call-template name="getMathml_asciimath_text"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="mathml">
			<xsl:apply-templates select="." mode="mathml"/>
		</xsl:variable>

		<fo:instream-foreign-object fox:alt-text="Math" fox:actual-text="Math">

			<xsl:call-template name="refine_mathml_insteam_object_style"/>

			<xsl:if test="$isGenerateTableIF = 'false'">
				<!-- put MathML in Actual Text -->
				<!-- DEBUG: mathml_content=<xsl:value-of select="$mathml_content"/> -->
				<xsl:attribute name="fox:actual-text">
					<xsl:value-of select="$mathml_content"/>
				</xsl:attribute>

				<!-- <xsl:if test="$add_math_as_text = 'true'"> -->
				<xsl:if test="normalize-space($asciimath_text_) != ''">
				<!-- put Mathin Alternate Text -->
					<xsl:attribute name="fox:alt-text">
						<xsl:value-of select="$asciimath_text_"/>
					</xsl:attribute>
				</xsl:if>
				<!-- </xsl:if> -->
			</xsl:if>

			<xsl:copy-of select="xalan:nodeset($mathml)"/>

		</fo:instream-foreign-object>
	</xsl:template>

	<xsl:template name="refine_mathml_insteam_object_style">

	</xsl:template> <!-- refine_mathml_insteam_object_style -->

	<xsl:template match="mathml:*" mode="mathml_actual_text">
		<!-- <xsl:text>a+b</xsl:text> -->
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="local-name()"/>
		<xsl:if test="local-name() = 'math'">
			<xsl:text> xmlns="http://www.w3.org/1998/Math/MathML"</xsl:text>
		</xsl:if>
		<xsl:for-each select="@*">
			<xsl:text> </xsl:text>
			<xsl:value-of select="local-name()"/>
			<xsl:text>="</xsl:text>
			<xsl:value-of select="."/>
			<xsl:text>"</xsl:text>
		</xsl:for-each>
		<xsl:text>&gt;</xsl:text>
		<xsl:apply-templates mode="mathml_actual_text"/>
		<xsl:text>&lt;/</xsl:text>
		<xsl:value-of select="local-name()"/>
		<xsl:text>&gt;</xsl:text>
	</xsl:template>

	<xsl:template match="text()" mode="mathml_actual_text">
		<xsl:value-of select="normalize-space()"/>
	</xsl:template>

	<xsl:template match="@*|node()" mode="mathml">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="mathml"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="mathml:mtext" mode="mathml">
		<xsl:copy>
			<!-- replace start and end spaces to non-break space -->
			<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.),'(^ )|( $)',' ')"/>
		</xsl:copy>
	</xsl:template>

	<!-- <xsl:template match="mathml:mi[. = ',' and not(following-sibling::*[1][local-name() = 'mtext' and text() = '&#xa0;'])]" mode="mathml">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="mathml"/>
		</xsl:copy>
		<xsl:choose>
			if in msub, then don't add space
			<xsl:when test="ancestor::mathml:mrow[parent::mathml:msub and preceding-sibling::*[1][self::mathml:mrow]]"></xsl:when>
			if next char in digit,  don't add space
			<xsl:when test="translate(substring(following-sibling::*[1]/text(),1,1),'0123456789','') = ''"></xsl:when>
			<xsl:otherwise>
				<mathml:mspace width="0.5ex"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template> -->

	<xsl:template match="mathml:math/*[local-name()='unit']" mode="mathml"/>
	<xsl:template match="mathml:math/*[local-name()='prefix']" mode="mathml"/>
	<xsl:template match="mathml:math/*[local-name()='dimension']" mode="mathml"/>
	<xsl:template match="mathml:math/*[local-name()='quantity']" mode="mathml"/>

	<!-- patch: slash in the mtd wrong rendering -->
	<xsl:template match="mathml:mtd/mathml:mo/text()[. = '/']" mode="mathml">
		<xsl:value-of select="."/><xsl:value-of select="$zero_width_space"/>
	</xsl:template>

	<!-- special case for:
		<math xmlns="http://www.w3.org/1998/Math/MathML">
			<mstyle displaystyle="true">
				<msup>
					<mi color="#00000000">C</mi>
					<mtext>R</mtext>
				</msup>
				<msubsup>
					<mtext>C</mtext>
					<mi>n</mi>
					<mi>k</mi>
				</msubsup>
			</mstyle>
		</math>
	-->
	<xsl:template match="mathml:msup/mathml:mi[. = '‌' or . = ''][not(preceding-sibling::*)][following-sibling::mathml:mtext]" mode="mathml">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:variable name="next_mtext" select="ancestor::mathml:msup/following-sibling::*[1][self::mathml:msubsup or self::mathml:msub or self::mathml:msup]/mathml:mtext"/>
			<xsl:if test="string-length($next_mtext) != ''">
				<xsl:attribute name="color">#00000000</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
			<xsl:value-of select="$next_mtext"/>
		</xsl:copy>
	</xsl:template>

	<!-- special case for:
				<msup>
					<mtext/>
					<mn>1</mn>
				</msup>
		convert to (add mspace after mtext and enclose them into mrow):
			<msup>
				<mrow>
					<mtext/>
					<mspace height="1.47ex"/>
				</mrow>
				<mn>1</mn>
			</msup>
	-->
	<xsl:template match="mathml:msup/mathml:mtext[not(preceding-sibling::*)]" mode="mathml">
		<mathml:mrow>
			<xsl:copy-of select="."/>
			<mathml:mspace height="1.47ex"/>
		</mathml:mrow>
	</xsl:template>

	<!-- add space around vertical line -->
	<xsl:template match="mathml:mo[normalize-space(text()) = '|']" mode="mathml">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="mathml"/>
			<xsl:if test="not(@lspace)">
				<xsl:attribute name="lspace">0.2em</xsl:attribute>
			</xsl:if>
			<xsl:if test="not(@rspace) and not(following-sibling::*[1][self::mathml:mo and normalize-space(text()) = '|'])">
				<xsl:attribute name="rspace">0.2em</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates mode="mathml"/>
		</xsl:copy>
	</xsl:template>

	<!-- decrease fontsize for 'Circled Times' char -->
	<xsl:template match="mathml:mo[normalize-space(text()) = '⊗']" mode="mathml">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="mathml"/>
			<xsl:if test="not(@fontsize)">
				<xsl:attribute name="fontsize">55%</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates mode="mathml"/>
		</xsl:copy>
	</xsl:template>

	<!-- increase space before '(' -->
	<xsl:template match="mathml:mo[normalize-space(text()) = '(']" mode="mathml">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="mathml"/>
			<xsl:if test="(preceding-sibling::* and not(preceding-sibling::*[1][self::mathml:mo])) or (../preceding-sibling::* and not(../preceding-sibling::*[1][self::mathml:mo]))">
				<xsl:if test="not(@lspace)">
					<xsl:attribute name="lspace">0.4em</xsl:attribute>
					<xsl:choose>
						<xsl:when test="preceding-sibling::*[1][self::mathml:mi or self::mathml:mstyle]">
							<xsl:attribute name="lspace">0.2em</xsl:attribute>
						</xsl:when>
						<xsl:when test="../preceding-sibling::*[1][self::mathml:mi or self::mathml:mstyle]">
							<xsl:attribute name="lspace">0.2em</xsl:attribute>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
			</xsl:if>
			<xsl:apply-templates mode="mathml"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()" mode="mathml_linebreak">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="mathml_linebreak"/>
		</xsl:copy>
	</xsl:template>

	<!-- split math into two math -->
	<xsl:template match="mathml:mo[@linebreak] | mathml:mspace[@linebreak]" mode="mathml_linebreak">
		<xsl:variable name="math_elements_tree_">
			<xsl:for-each select="ancestor::*[ancestor-or-self::mathml:math]">
				<element pos="{position()}">
					<xsl:copy-of select="@*[local-name() != 'id']"/>
					<xsl:value-of select="name()"/>
				</element>
			</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="math_elements_tree" select="xalan:nodeset($math_elements_tree_)"/>

		<xsl:call-template name="insertClosingElements">
			<xsl:with-param name="tree" select="$math_elements_tree"/>
		</xsl:call-template>

		<xsl:element name="br" namespace="{$namespace_full}"/>

		<xsl:call-template name="insertOpeningElements">
			<xsl:with-param name="tree" select="$math_elements_tree"/>
			<xsl:with-param name="xmlns">http://www.w3.org/1998/Math/MathML</xsl:with-param>
			<xsl:with-param name="add_continue">false</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

	<!-- Examples: 
		<stem type="AsciiMath">x = 1</stem> 
		<stem type="AsciiMath"><asciimath>x = 1</asciimath></stem>
		<stem type="AsciiMath"><asciimath>x = 1</asciimath><latexmath>x = 1</latexmath></stem>
	-->
	<xsl:template match="*[local-name() = 'stem'][@type = 'AsciiMath'][count(*) = 0]/text() | *[local-name() = 'stem'][@type = 'AsciiMath'][*[local-name() = 'asciimath']]" priority="3">
		<fo:inline xsl:use-attribute-sets="mathml-style">

			<xsl:call-template name="refine_mathml-style"/>

			<xsl:choose>
				<xsl:when test="self::text()"><xsl:value-of select="."/></xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates>
						<xsl:with-param name="process">true</xsl:with-param>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>

		</fo:inline>
	</xsl:template>
	<!-- ======================================= -->
	<!-- END: math -->
	<!-- ======================================= -->

	<xsl:template match="*[local-name()='localityStack']"/>

	<xsl:variable name="pdfAttachmentsList_">
		<xsl:for-each select="//*[local-name() = 'metanorma']/*[local-name() = 'metanorma-extension']/*[local-name() = 'attachment']">
			<attachment filename="{@name}"/>
		</xsl:for-each>
		<xsl:if test="not(//*[local-name() = 'metanorma']/*[local-name() = 'metanorma-extension']/*[local-name() = 'attachment'])">
			<xsl:for-each select="//*[local-name() = 'bibitem'][@hidden = 'true'][*[local-name() = 'uri'][@type = 'attachment']]">
				<xsl:variable name="attachment_path" select="*[local-name() = 'uri'][@type = 'attachment']"/>
				<attachment filename="{$attachment_path}"/>
			</xsl:for-each>
		</xsl:if>
	</xsl:variable>
	<xsl:variable name="pdfAttachmentsList" select="xalan:nodeset($pdfAttachmentsList_)"/>

	<xsl:template match="*[local-name()='link']" name="link">
		<xsl:variable name="target_normalized" select="translate(@target, '\', '/')"/>
		<xsl:variable name="target_attachment_name" select="substring-after($target_normalized, '_attachments/')"/>
		<xsl:variable name="isLinkToEmbeddedFile" select="normalize-space(@attachment = 'true' and $pdfAttachmentsList//attachment[@filename = current()/@target])"/>
		<xsl:variable name="target">
			<xsl:choose>
				<xsl:when test="@updatetype = 'true'">
					<xsl:value-of select="concat(normalize-space(@target), '.pdf')"/>
				</xsl:when>
				<!-- link to the PDF attachment -->
				<xsl:when test="$isLinkToEmbeddedFile = 'true'">
					<xsl:variable name="target_file" select="java:org.metanorma.fop.Util.getFilenameFromPath(@target)"/>
					<xsl:value-of select="concat('url(embedded-file:', $target_file, ')')"/>
				</xsl:when>
				<!-- <xsl:when test="starts-with($target_normalized, '_') and contains($target_normalized, '_attachments/') and $pdfAttachmentsList//attachment[@filename = $target_attachment_name]">
					<xsl:value-of select="concat('url(embedded-file:', $target_attachment_name, ')')"/>
				</xsl:when>
				<xsl:when test="contains(@target, concat('_', $inputxml_filename_prefix, '_attachments'))">
					<xsl:variable name="target_" select="translate(@target, '\', '/')"/>
					<xsl:variable name="target__" select="substring-after($target_, concat('_', $inputxml_filename_prefix, '_attachments', '/'))"/>
					<xsl:value-of select="concat('url(embedded-file:', $target__, ')')"/>
				</xsl:when> -->

				<!-- <xsl:when test="not(starts-with(@target, 'http:') or starts-with(@target, 'https') or starts-with(@target, 'www') or starts-with(@target, 'mailto') or starts-with(@target, 'ftp'))">
					<xsl:variable name="target_" select="translate(@target, '\', '/')"/>
					<xsl:variable name="filename">
						<xsl:call-template name="substring-after-last">
							<xsl:with-param name="value" select="$target_"/>
							<xsl:with-param name="delimiter" select="'/'"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="target_filepath" select="concat($inputxml_basepath, @target)"/>
					<xsl:variable name="file_exists" select="normalize-space(java:exists(java:java.io.File.new($target_filepath)))"/>
					<xsl:choose>
						<xsl:when test="$file_exists = 'true'">
							<xsl:value-of select="concat('url(embedded-file:', $filename, ')')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(@target)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when> -->

				<xsl:otherwise>
					<xsl:value-of select="normalize-space(@target)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="target_text">
			<xsl:choose>
				<xsl:when test="starts-with(normalize-space(@target), 'mailto:')">
					<xsl:value-of select="normalize-space(substring-after(@target, 'mailto:'))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(@target)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<fo:inline xsl:use-attribute-sets="link-style">

			<xsl:if test="starts-with(normalize-space(@target), 'mailto:') and not(ancestor::*[local-name() = 'td'])">
				<xsl:attribute name="keep-together.within-line">always</xsl:attribute>
			</xsl:if>

			<xsl:if test="$isLinkToEmbeddedFile = 'true'">
				<xsl:attribute name="color">inherit</xsl:attribute>
				<xsl:attribute name="text-decoration">none</xsl:attribute>
			</xsl:if>

			<xsl:call-template name="refine_link-style"/>

			<xsl:choose>
				<xsl:when test="$target_text = ''">
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="alt_text">
						<xsl:call-template name="getAltText"/>
					</xsl:variable>
					<xsl:call-template name="insert_basic_link">
						<xsl:with-param name="element">
							<fo:basic-link external-destination="{$target}" fox:alt-text="{$alt_text}">
								<xsl:if test="$isLinkToEmbeddedFile = 'true'">
									<xsl:attribute name="role">Annot</xsl:attribute>
								</xsl:if>
								<xsl:choose>
									<xsl:when test="normalize-space(.) = ''">
										<xsl:call-template name="add-zero-spaces-link-java">
											<xsl:with-param name="text" select="$target_text"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<!-- output text from <link>text</link> -->
										<xsl:choose>
											<xsl:when test="starts-with(., 'http://') or starts-with(., 'https://') or starts-with(., 'www.')">
												<xsl:call-template name="add-zero-spaces-link-java">
													<xsl:with-param name="text" select="."/>
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<xsl:apply-templates/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</fo:basic-link>
							<xsl:if test="$isLinkToEmbeddedFile = 'true'">
								<!-- reserve space at right for PaperClip icon -->
								<fo:inline keep-with-previous.within-line="always">        </fo:inline>
							</xsl:if>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>
	</xsl:template> <!-- link -->

	<xsl:template name="getAltText">
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"><xsl:value-of select="@target"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="normalize-space(translate(normalize-space(), ' —', ' -'))"/></xsl:otherwise>
			<!-- <xsl:otherwise><xsl:value-of select="@target"/></xsl:otherwise> -->
		</xsl:choose>
	</xsl:template>

	<!-- ======================== -->
	<!-- Appendix processing -->
	<!-- ======================== -->
	<xsl:template match="*[local-name()='appendix']">
		<fo:block id="{@id}" xsl:use-attribute-sets="appendix-style">
			<xsl:apply-templates select="*[local-name()='title']"/>
		</fo:block>
		<xsl:apply-templates select="node()[not(local-name()='title')]"/>
	</xsl:template>

	<xsl:template match="*[local-name()='appendix']/*[local-name()='title']" priority="2">
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		<fo:inline role="H{$level}"><xsl:apply-templates/></fo:inline>
	</xsl:template>
	<!-- ======================== -->
	<!-- END Appendix processing -->
	<!-- ======================== -->

	<xsl:template match="*[local-name()='appendix']//*[local-name()='example']" priority="2">
		<fo:block id="{@id}" xsl:use-attribute-sets="appendix-example-style">
			<xsl:apply-templates select="*[local-name()='name']"/>
		</fo:block>
		<xsl:apply-templates select="node()[not(local-name()='name')]"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'callout']">
		<xsl:choose>
			<xsl:when test="normalize-space(@target) = ''">&lt;<xsl:apply-templates/>&gt;</xsl:when>
			<xsl:otherwise><fo:basic-link internal-destination="{@target}" fox:alt-text="{normalize-space()}">&lt;<xsl:apply-templates/>&gt;</fo:basic-link></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[local-name() = 'annotation']">
		<xsl:variable name="annotation-id" select="@id"/>
		<xsl:variable name="callout" select="//*[@target = $annotation-id]/text()"/>
		<fo:block id="{$annotation-id}" white-space="nowrap">

			<fo:inline>
				<xsl:apply-templates>
					<xsl:with-param name="callout" select="concat('&lt;', $callout, '&gt; ')"/>
				</xsl:apply-templates>
			</fo:inline>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'annotation']/*[local-name() = 'p']">
		<xsl:param name="callout"/>
		<fo:inline id="{@id}">
			<!-- for first p in annotation, put <x> -->
			<xsl:if test="not(preceding-sibling::*[local-name() = 'p'])"><xsl:value-of select="$callout"/></xsl:if>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<xsl:template match="*[local-name() = 'xref']">
		<xsl:call-template name="insert_basic_link">
			<xsl:with-param name="element">
				<xsl:variable name="alt_text">
					<xsl:call-template name="getAltText"/>
				</xsl:variable>
				<fo:basic-link internal-destination="{@target}" fox:alt-text="{$alt_text}" xsl:use-attribute-sets="xref-style">
					<xsl:if test="string-length(normalize-space()) &lt; 30 and not(contains(normalize-space(), 'http://')) and not(contains(normalize-space(), 'https://')) and not(ancestor::*[local-name() = 'table' or local-name() = 'dl'])">
						<xsl:attribute name="keep-together.within-line">always</xsl:attribute>
					</xsl:if>

						<xsl:if test="not($vertical_layout = 'true')">
							<xsl:attribute name="font-family">IPAexGothic</xsl:attribute>
						</xsl:if>

					<xsl:if test="parent::*[local-name() = 'add']">
						<xsl:call-template name="append_add-style"/>
					</xsl:if>
					<xsl:apply-templates/>
				</fo:basic-link>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- command between two xref points to non-standard bibitem -->
	<xsl:template match="text()[. = ','][preceding-sibling::node()[1][local-name() = 'sup'][*[local-name() = 'xref'][@type = 'footnote']] and    following-sibling::node()[1][local-name() = 'sup'][*[local-name() = 'xref'][@type = 'footnote']]]">
		<xsl:value-of select="."/>
	</xsl:template>

	<!-- ====== -->
	<!-- formula  -->
	<!-- ====== -->
	<xsl:template match="*[local-name() = 'formula']" name="formula">
		<fo:block-container margin-left="0mm" role="SKIP">
			<xsl:if test="parent::*[local-name() = 'note']">
				<xsl:attribute name="margin-left">
					<xsl:choose>
						<xsl:when test="not(ancestor::*[local-name() = 'table'])"><xsl:value-of select="$note-body-indent"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$note-body-indent-table"/></xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>

			</xsl:if>
			<fo:block-container margin-left="0mm" role="SKIP">
				<fo:block id="{@id}">
					<xsl:apply-templates select="node()[not(local-name() = 'name')]"/> <!-- formula's number will be process in 'stem' template -->
				</fo:block>
			</fo:block-container>
		</fo:block-container>
	</xsl:template>

	<xsl:template match="*[local-name() = 'formula']/*[local-name() = 'dt']/*[local-name() = 'stem']">
		<fo:inline>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<xsl:template match="*[local-name() = 'admitted']/*[local-name() = 'stem']">
		<fo:inline>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<xsl:template match="*[local-name() = 'formula']/*[local-name() = 'name']"> <!-- show in 'stem' template -->
		<!-- https://github.com/metanorma/isodoc/issues/607 
		<xsl:if test="normalize-space() != ''">
			<xsl:text>(</xsl:text><xsl:apply-templates /><xsl:text>)</xsl:text>
		</xsl:if> -->
		<xsl:apply-templates/>
	</xsl:template>

	<!-- stem inside formula with name (with formula's number) -->
	<xsl:template match="*[local-name() = 'formula'][*[local-name() = 'name']]/*[local-name() = 'stem']">
		<fo:block xsl:use-attribute-sets="formula-style">

			<fo:table table-layout="fixed" width="100%">
				<fo:table-column column-width="95%"/>
				<fo:table-column column-width="5%"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell display-align="center">
							<fo:block xsl:use-attribute-sets="formula-stem-block-style" role="SKIP">

								<xsl:call-template name="refine_formula-stem-block-style"/>

								<xsl:apply-templates/>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell display-align="center">
							<fo:block xsl:use-attribute-sets="formula-stem-number-style" role="SKIP">

								<xsl:call-template name="refine_formula-stem-number-style"/>

								<xsl:apply-templates select="../*[local-name() = 'name']"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:template>

	<!-- stem inside formula without name (without formula's number) -->
	<xsl:template match="*[local-name() = 'formula'][not(*[local-name() = 'name'])]/*[local-name() = 'stem']">
		<fo:block xsl:use-attribute-sets="formula-style">
			<fo:block xsl:use-attribute-sets="formula-stem-block-style">
				<xsl:apply-templates/>
			</fo:block>
		</fo:block>
	</xsl:template>

	<!-- ====== -->
	<!-- ====== -->

	<xsl:template name="setBlockSpanAll">
		<xsl:if test="@columns = 1 or     (local-name() = 'p' and *[@columns = 1])"><xsl:attribute name="span">all</xsl:attribute></xsl:if>
	</xsl:template>

	<!-- ====== -->
	<!-- note      -->
	<!-- termnote -->
	<!-- ====== -->

	<xsl:template match="*[local-name() = 'note']" name="note">

				<fo:block id="{@id}" xsl:use-attribute-sets="note-style" role="SKIP">
					<xsl:call-template name="setBlockSpanAll"/>

					<xsl:call-template name="refine_note-style"/>

					<fo:list-block>
						<xsl:attribute name="provisional-distance-between-starts">
							<xsl:choose>
								<!-- if last char is digit -->
								<xsl:when test="translate(substring(*[local-name() = 'name'], string-length(*[local-name() = 'name'])),'0123456789','') = ''"><xsl:value-of select="16 + $text_indent"/>mm</xsl:when>
								<xsl:otherwise><xsl:value-of select="10 + $text_indent"/>mm</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<fo:list-item>
							<fo:list-item-label start-indent="{$text_indent}mm" end-indent="label-end()">
								<xsl:if test="$vertical_layout = 'true'">
									<xsl:attribute name="start-indent">0mm</xsl:attribute>
								</xsl:if>
								<fo:block xsl:use-attribute-sets="note-name-style">
									<xsl:call-template name="refine_note-name-style"/>
									<xsl:apply-templates select="*[local-name() = 'name']"/>
								</fo:block>
							</fo:list-item-label>
							<fo:list-item-body start-indent="body-start()">
								<fo:block>
									<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
								</fo:block>
							</fo:list-item-body>
						</fo:list-item>
					</fo:list-block>
				</fo:block>

	</xsl:template>

	<xsl:template name="refine_note_block_style">

	</xsl:template> <!-- refine_note_block_style -->

	<xsl:template match="*[local-name() = 'note']/*[local-name() = 'p']">
		<xsl:variable name="num"><xsl:number/></xsl:variable>
		<xsl:choose>
			<xsl:when test="$num = 1"> <!-- display first NOTE's paragraph in the same line with label NOTE -->
				<fo:inline xsl:use-attribute-sets="note-p-style" role="SKIP">
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:block xsl:use-attribute-sets="note-p-style" role="SKIP">
					<xsl:apply-templates/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[local-name() = 'termnote']">
		<fo:block id="{@id}" xsl:use-attribute-sets="termnote-style">

			<xsl:call-template name="setBlockSpanAll"/>

			<xsl:call-template name="refine_termnote-style"/>

			<fo:inline xsl:use-attribute-sets="termnote-name-style">

				<xsl:call-template name="refine_termnote-name-style"/>

				<!-- if 'p' contains all text in 'add' first and last elements in first p are 'add' -->
				<!-- <xsl:if test="*[not(local-name()='name')][1][node()[normalize-space() != ''][1][local-name() = 'add'] and node()[normalize-space() != ''][last()][local-name() = 'add']]"> -->
				<xsl:if test="*[not(local-name()='name')][1][count(node()[normalize-space() != '']) = 1 and *[local-name() = 'add']]">
					<xsl:call-template name="append_add-style"/>
				</xsl:if>

				<xsl:apply-templates select="*[local-name() = 'name']"/>

			</fo:inline>

			<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'note']/*[local-name() = 'name']">
		<xsl:param name="sfx"/>
		<xsl:variable name="suffix">
			<xsl:choose>
				<xsl:when test="$sfx != ''">
					<xsl:value-of select="$sfx"/>
				</xsl:when>
				<xsl:otherwise>

					<!-- https://github.com/metanorma/isodoc/issues/607 -->
					<!-- <xsl:if test="$namespace = 'ieee'">
						<xsl:text>—</xsl:text> em dash &#x2014;
					</xsl:if> -->
					<!-- <xsl:if test="$namespace = 'iho' or $namespace = 'gb' or $namespace = 'm3d' or $namespace = 'unece-rec' or $namespace = 'unece'  or $namespace = 'rsd'">
						<xsl:text>:</xsl:text>
					</xsl:if> -->

					<!-- <xsl:if test="$namespace = 'itu' or $namespace = 'nist-cswp'  or $namespace = 'nist-sp'">				
						<xsl:text> – </xsl:text> en dash &#x2013;
					</xsl:if> -->
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="normalize-space() != ''">
			<xsl:apply-templates/>
			<xsl:value-of select="$suffix"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'termnote']/*[local-name() = 'name']">
		<xsl:param name="sfx"/>
		<xsl:variable name="suffix">
			<xsl:choose>
				<xsl:when test="$sfx != ''">
					<xsl:value-of select="$sfx"/>
				</xsl:when>
				<xsl:otherwise>

					<!-- https://github.com/metanorma/isodoc/issues/607 -->
					<!-- <xsl:if test="$namespace = 'ieee'">
						<xsl:text>—</xsl:text> em dash &#x2014;
					</xsl:if> -->
					<!-- <xsl:if test="$namespace = 'gb' or $namespace = 'iso' or $namespace = 'iec' or $namespace = 'ogc' or $namespace = 'ogc-white-paper' or $namespace = 'rsd' or $namespace = 'jcgm'">
						<xsl:text>:</xsl:text>
					</xsl:if> -->
					<!-- <xsl:if test="$namespace = 'itu' or $namespace = 'nist-cswp'  or $namespace = 'nist-sp' or $namespace = 'unece-rec' or $namespace = 'unece'">				
						<xsl:text> – </xsl:text> en dash &#x2013;
					</xsl:if> -->
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="normalize-space() != ''">
			<xsl:apply-templates/>
			<xsl:value-of select="$suffix"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'termnote']/*[local-name() = 'p']">
		<xsl:variable name="num"><xsl:number/></xsl:variable>
		<xsl:choose>
			<xsl:when test="$num = 1"> <!-- first paragraph renders in the same line as titlenote name -->
				<fo:inline xsl:use-attribute-sets="termnote-p-style">
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:block xsl:use-attribute-sets="termnote-p-style">
					<xsl:apply-templates/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ====== -->
	<!-- ====== -->

	<!-- ====== -->
	<!-- term      -->
	<!-- ====== -->

	<xsl:template match="*[local-name() = 'terms']">
		<!-- <xsl:message>'terms' <xsl:number/> processing...</xsl:message> -->
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'term']">
		<fo:block id="{@id}" xsl:use-attribute-sets="term-style">

			<xsl:if test="parent::*[local-name() = 'term'] and not(preceding-sibling::*[local-name() = 'term'])">

			</xsl:if>
			<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'term']/*[local-name() = 'name']">
		<xsl:if test="normalize-space() != ''">
			<!-- <xsl:variable name="level">
				<xsl:call-template name="getLevelTermName"/>
			</xsl:variable>
			<fo:inline role="H{$level}">
				<xsl:apply-templates />
			</fo:inline> -->
			<xsl:apply-templates/>
		</xsl:if>
	</xsl:template>
	<!-- ====== -->
	<!-- ====== -->

	<!-- ====== -->
	<!-- figure    -->
	<!-- image    -->
	<!-- ====== -->

	<xsl:template match="*[local-name() = 'figure']" name="figure">
		<xsl:variable name="isAdded" select="@added"/>
		<xsl:variable name="isDeleted" select="@deleted"/>
		<fo:block-container id="{@id}" xsl:use-attribute-sets="figure-block-style">
			<xsl:call-template name="refine_figure-block-style"/>

			<xsl:call-template name="setTrackChangesStyles">
				<xsl:with-param name="isAdded" select="$isAdded"/>
				<xsl:with-param name="isDeleted" select="$isDeleted"/>
			</xsl:call-template>

			<!-- Example: Dimensions in millimeters -->
			<xsl:apply-templates select="*[local-name() = 'note'][@type = 'units']"/>

			<xsl:variable name="show_figure_key_in_block_container">

						<xsl:choose>
							<xsl:when test="$vertical_layout = 'true'">false</xsl:when>
							<xsl:otherwise>true</xsl:otherwise>
						</xsl:choose>

			</xsl:variable>

			<fo:block xsl:use-attribute-sets="figure-style" role="SKIP">
				<xsl:apply-templates select="node()[not(local-name() = 'name') and not(local-name() = 'note' and @type = 'units')]"/>
			</fo:block>

			<xsl:if test="normalize-space($show_figure_key_in_block_container) = 'true'">
				<xsl:call-template name="showFigureKey"/>
			</xsl:if>

					<xsl:apply-templates select="*[local-name() = 'name']"/> <!-- show figure's name AFTER image -->

		</fo:block-container>

			<xsl:if test="$vertical_layout = 'true'">
				<fo:block keep-with-previous="always">
					<xsl:apply-templates select="*[local-name() = 'p'][@class = 'dl']">
						<xsl:with-param name="process">true</xsl:with-param>
					</xsl:apply-templates>
					<xsl:call-template name="showFigureKey"/>
				</fo:block>
				<xsl:apply-templates select="*[local-name() = 'name']">
					<xsl:with-param name="process">true</xsl:with-param>
				</xsl:apply-templates>
			</xsl:if>

	</xsl:template>

	<xsl:template name="showFigureKey">
		<xsl:for-each select="*[(local-name() = 'note' and not(@type = 'units')) or local-name() = 'example']">
			<xsl:choose>
				<xsl:when test="local-name() = 'note'">
					<xsl:call-template name="note"/>
				</xsl:when>
				<xsl:when test="local-name() = 'example'">
					<xsl:call-template name="example"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<!-- TO DO: remove, now the figure fn in figure/dl/... https://github.com/metanorma/isodoc/issues/658 -->
		<xsl:call-template name="figure_fn_display"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'figure'][@class = 'pseudocode']">
		<fo:block id="{@id}">
			<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
		</fo:block>
		<xsl:apply-templates select="*[local-name() = 'name']"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'figure'][@class = 'pseudocode']//*[local-name() = 'p']">
		<fo:block xsl:use-attribute-sets="figure-pseudocode-p-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<!-- SOURCE: ... -->
	<xsl:template match="*[local-name() = 'figure']/*[local-name() = 'source']" priority="2">

				<xsl:call-template name="termsource"/>

	</xsl:template>

	<xsl:template match="*[local-name() = 'image']">
		<xsl:param name="indent">0</xsl:param>
		<xsl:variable name="isAdded" select="../@added"/>
		<xsl:variable name="isDeleted" select="../@deleted"/>
		<xsl:choose>
			<xsl:when test="ancestor::*[local-name() = 'title'] or not(parent::*[local-name() = 'figure']) or parent::*[local-name() = 'p']"> <!-- inline image ( 'image:path' in adoc, with one colon after image) -->
				<fo:inline padding-left="1mm" padding-right="1mm">
					<xsl:if test="not(parent::*[local-name() = 'figure']) or parent::*[local-name() = 'p']">
						<xsl:attribute name="padding-left">0mm</xsl:attribute>
						<xsl:attribute name="padding-right">0mm</xsl:attribute>
					</xsl:if>
					<xsl:variable name="src">
						<xsl:call-template name="image_src"/>
					</xsl:variable>

					<xsl:variable name="scale">
						<xsl:call-template name="getImageScale">
							<xsl:with-param name="indent" select="$indent"/>
						</xsl:call-template>
					</xsl:variable>

					<!-- debug scale='<xsl:value-of select="$scale"/>', indent='<xsl:value-of select="$indent"/>' -->

					<!-- <fo:external-graphic src="{$src}" fox:alt-text="Image {@alt}" vertical-align="middle"/> -->
					<fo:external-graphic src="{$src}" fox:alt-text="Image {@alt}" vertical-align="middle">

						<xsl:variable name="width">
							<xsl:call-template name="setImageWidth"/>
						</xsl:variable>
						<xsl:if test="$width != ''">
							<xsl:attribute name="width"><xsl:value-of select="$width"/></xsl:attribute>
						</xsl:if>
						<xsl:variable name="height">
							<xsl:call-template name="setImageHeight"/>
						</xsl:variable>
						<xsl:if test="$height != ''">
							<xsl:attribute name="height"><xsl:value-of select="$height"/></xsl:attribute>
						</xsl:if>

						<xsl:if test="$width = '' and $height = ''">
							<xsl:if test="number($scale) &lt; 100">
								<xsl:attribute name="content-width"><xsl:value-of select="number($scale)"/>%</xsl:attribute>
								<!-- <xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
								<xsl:attribute name="content-height">100%</xsl:attribute>
								<xsl:attribute name="width">100%</xsl:attribute>
								<xsl:attribute name="scaling">uniform</xsl:attribute> -->
							</xsl:if>
						</xsl:if>

					</fo:external-graphic>

				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:block xsl:use-attribute-sets="image-style">

					<xsl:call-template name="refine_image-style"/>

					<xsl:variable name="src">
						<xsl:call-template name="image_src"/>
					</xsl:variable>

					<xsl:choose>
						<xsl:when test="$isDeleted = 'true'">
							<!-- enclose in svg -->
							<fo:instream-foreign-object fox:alt-text="Image {@alt}">
								<xsl:attribute name="width">100%</xsl:attribute>
								<xsl:attribute name="content-height">100%</xsl:attribute>
								<xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
								<xsl:attribute name="scaling">uniform</xsl:attribute>

								<xsl:apply-templates select="." mode="cross_image"/>

							</fo:instream-foreign-object>
						</xsl:when>
						<xsl:otherwise>
							<!-- <fo:block>debug block image:
							<xsl:variable name="scale">
								<xsl:call-template name="getImageScale">
									<xsl:with-param name="indent" select="$indent"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:value-of select="concat('scale=', $scale,', indent=', $indent)"/>
							</fo:block> -->

							<fo:external-graphic src="{$src}" fox:alt-text="Image {@alt}">

								<xsl:choose>
									<!-- default -->
									<xsl:when test="((@width = 'auto' or @width = 'text-width' or @width = 'full-page-width' or @width = 'narrow') and @height = 'auto') or            (normalize-space(@width) = '' and normalize-space(@height) = '') ">
										<!-- add attribute for automatic scaling -->
										<xsl:variable name="image-graphic-style_attributes">
											<attributes xsl:use-attribute-sets="image-graphic-style"/>
										</xsl:variable>
										<xsl:copy-of select="xalan:nodeset($image-graphic-style_attributes)/attributes/@*"/>

										<xsl:if test="not(@mimetype = 'image/svg+xml') and not(ancestor::*[local-name() = 'table'])">
											<xsl:variable name="scale">
												<xsl:call-template name="getImageScale">
													<xsl:with-param name="indent" select="$indent"/>
												</xsl:call-template>
											</xsl:variable>

											<xsl:variable name="scaleRatio">
												1
											</xsl:variable>

											<xsl:if test="number($scale) &lt; 100">
												<xsl:attribute name="content-width"><xsl:value-of select="number($scale) * number($scaleRatio)"/>%</xsl:attribute>
											</xsl:if>
										</xsl:if>

									</xsl:when> <!-- default -->
									<xsl:otherwise>

										<xsl:variable name="width_height_">
											<attributes>
												<xsl:call-template name="setImageWidthHeight"/>
											</attributes>
										</xsl:variable>
										<xsl:variable name="width_height" select="xalan:nodeset($width_height_)"/>

										<xsl:copy-of select="$width_height/attributes/@*"/>

										<xsl:if test="$width_height/attributes/@content-width != '' and             $width_height/attributes/@content-height != ''">
											<xsl:attribute name="scaling">non-uniform</xsl:attribute>
										</xsl:if>

									</xsl:otherwise>
								</xsl:choose>

								<!-- 
								<xsl:if test="not(@mimetype = 'image/svg+xml') and (../*[local-name() = 'name'] or parent::*[local-name() = 'figure'][@unnumbered = 'true']) and not(ancestor::*[local-name() = 'table'])">
								-->

							</fo:external-graphic>
						</xsl:otherwise>
					</xsl:choose>

				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="setImageWidth">
		<xsl:if test="@width != '' and @width != 'auto' and @width != 'text-width' and @width != 'full-page-width' and @width != 'narrow'">
			<xsl:value-of select="@width"/>
		</xsl:if>
	</xsl:template>
	<xsl:template name="setImageHeight">
		<xsl:if test="@height != '' and @height != 'auto'">
			<xsl:value-of select="@height"/>
		</xsl:if>
	</xsl:template>
	<xsl:template name="setImageWidthHeight">
		<xsl:variable name="width">
			<xsl:call-template name="setImageWidth"/>
		</xsl:variable>
		<xsl:if test="$width != ''">
			<xsl:attribute name="content-width">
				<xsl:value-of select="$width"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:variable name="height">
			<xsl:call-template name="setImageHeight"/>
		</xsl:variable>
		<xsl:if test="$height != ''">
			<xsl:attribute name="content-height">
				<xsl:value-of select="$height"/>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:template name="getImageSrc">
		<xsl:choose>
			<xsl:when test="not(starts-with(@src, 'data:'))">
				<xsl:call-template name="getImageSrcExternal"/>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="@src"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="getImageSrcExternal">
		<xsl:choose>
			<xsl:when test="@extracted = 'true'"> <!-- added in mn2pdf v1.97 -->
				<xsl:value-of select="@src"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="src_with_basepath" select="concat($basepath, @src)"/>
				<xsl:variable name="file_exists" select="normalize-space(java:exists(java:java.io.File.new($src_with_basepath)))"/>
				<xsl:choose>
					<xsl:when test="$file_exists = 'true'">
						<xsl:value-of select="$src_with_basepath"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@src"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="getImageScale">
		<xsl:param name="indent"/>
		<xsl:variable name="indent_left">
			<xsl:choose>
				<xsl:when test="$indent != ''"><xsl:value-of select="$indent"/></xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="img_src">
			<xsl:call-template name="getImageSrc"/>
		</xsl:variable>

		<xsl:variable name="image_width_effective">

					<xsl:value-of select="$width_effective - number($indent_left)"/>

		</xsl:variable>
		<xsl:variable name="image_height_effective" select="$height_effective - number($indent_left)"/>
		<!-- <xsl:message>width_effective=<xsl:value-of select="$width_effective"/></xsl:message>
		<xsl:message>indent_left=<xsl:value-of select="$indent_left"/></xsl:message>
		<xsl:message>image_width_effective=<xsl:value-of select="$image_width_effective"/> for <xsl:value-of select="ancestor::ogc:p[1]/@id"/></xsl:message> -->
		<xsl:variable name="scale">

					<xsl:choose>
						<xsl:when test="$vertical_layout = 'true'">
							<xsl:value-of select="java:org.metanorma.fop.utils.ImageUtils.getImageScale($img_src, $image_height_effective, $width_effective)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="java:org.metanorma.fop.utils.ImageUtils.getImageScale($img_src, $image_width_effective, $height_effective)"/>
						</xsl:otherwise>
					</xsl:choose>

		</xsl:variable>
		<xsl:value-of select="$scale"/>
	</xsl:template>

	<xsl:template name="image_src">
		<xsl:choose>
			<xsl:when test="@mimetype = 'image/svg+xml' and $images/images/image[@id = current()/@id]">
				<xsl:value-of select="$images/images/image[@id = current()/@id]/@src"/>
			</xsl:when>
			<!-- in WebP format, then convert image into PNG -->
			<xsl:when test="starts-with(@src, 'data:image/webp')">
				<xsl:variable name="src_png" select="java:org.metanorma.fop.utils.ImageUtils.convertWebPtoPNG(@src)"/>
				<xsl:value-of select="$src_png"/>
			</xsl:when>
			<xsl:when test="not(starts-with(@src, 'data:')) and        (java:endsWith(java:java.lang.String.new(@src), '.webp') or       java:endsWith(java:java.lang.String.new(@src), '.WEBP'))">
				<xsl:variable name="src_png" select="java:org.metanorma.fop.utils.ImageUtils.convertWebPtoPNG(@src)"/>
				<xsl:value-of select="concat('url(file:///',$basepath, $src_png, ')')"/>
			</xsl:when>
			<xsl:when test="not(starts-with(@src, 'data:'))">
				<xsl:variable name="src_external"><xsl:call-template name="getImageSrcExternal"/></xsl:variable>
				<xsl:value-of select="concat('url(file:///', $src_external, ')')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@src"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[local-name() = 'image']" mode="cross_image">
		<xsl:choose>
			<xsl:when test="@mimetype = 'image/svg+xml' and $images/images/image[@id = current()/@id]">
				<xsl:variable name="src">
					<xsl:value-of select="$images/images/image[@id = current()/@id]/@src"/>
				</xsl:variable>
				<xsl:variable name="width" select="document($src)/@width"/>
				<xsl:variable name="height" select="document($src)/@height"/>
				<svg xmlns="http://www.w3.org/2000/svg" xml:space="preserve" style="enable-background:new 0 0 595.28 841.89;" height="{$height}" width="{$width}" viewBox="0 0 {$width} {$height}" y="0px" x="0px" id="Layer_1" version="1.1">
					<image xlink:href="{$src}" style="overflow:visible;"/>
				</svg>
			</xsl:when>
			<xsl:when test="not(starts-with(@src, 'data:'))">
				<xsl:variable name="src_external"><xsl:call-template name="getImageSrcExternal"/></xsl:variable>
				<xsl:variable name="src" select="concat('url(file:///', $src_external, ')')"/>
				<xsl:variable name="file" select="java:java.io.File.new(@src)"/>
				<xsl:variable name="bufferedImage" select="java:javax.imageio.ImageIO.read($file)"/>
				<xsl:variable name="width" select="java:getWidth($bufferedImage)"/>
				<xsl:variable name="height" select="java:getHeight($bufferedImage)"/>
				<svg xmlns="http://www.w3.org/2000/svg" xml:space="preserve" style="enable-background:new 0 0 595.28 841.89;" height="{$height}" width="{$width}" viewBox="0 0 {$width} {$height}" y="0px" x="0px" id="Layer_1" version="1.1">
					<image xlink:href="{$src}" style="overflow:visible;"/>
				</svg>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="base64String" select="substring-after(@src, 'base64,')"/>
				<xsl:variable name="decoder" select="java:java.util.Base64.getDecoder()"/>
				<xsl:variable name="fileContent" select="java:decode($decoder, $base64String)"/>
				<xsl:variable name="bis" select="java:java.io.ByteArrayInputStream.new($fileContent)"/>
				<xsl:variable name="bufferedImage" select="java:javax.imageio.ImageIO.read($bis)"/>
				<xsl:variable name="width" select="java:getWidth($bufferedImage)"/>
				<xsl:variable name="height" select="java:getHeight($bufferedImage)"/>
				<svg xmlns="http://www.w3.org/2000/svg" xml:space="preserve" style="enable-background:new 0 0 595.28 841.89;" height="{$height}" width="{$width}" viewBox="0 0 {$width} {$height}" y="0px" x="0px" id="Layer_1" version="1.1">
					<image xlink:href="{@src}" height="{$height}" width="{$width}" style="overflow:visible;"/>
					<xsl:call-template name="svg_cross">
						<xsl:with-param name="width" select="$width"/>
						<xsl:with-param name="height" select="$height"/>
					</xsl:call-template>
				</svg>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="svg_cross">
		<xsl:param name="width"/>
		<xsl:param name="height"/>
		<line xmlns="http://www.w3.org/2000/svg" x1="0" y1="0" x2="{$width}" y2="{$height}" style="stroke: rgb(255, 0, 0); stroke-width:4px; "/>
		<line xmlns="http://www.w3.org/2000/svg" x1="0" y1="{$height}" x2="{$width}" y2="0" style="stroke: rgb(255, 0, 0); stroke-width:4px; "/>
	</xsl:template>

	<!-- =================== -->
	<!-- SVG images processing -->
	<!-- =================== -->
	<xsl:variable name="figure_name_height">14</xsl:variable>
	<xsl:variable name="width_effective" select="$pageWidth - $marginLeftRight1 - $marginLeftRight2"/><!-- paper width minus margins -->
	<xsl:variable name="height_effective" select="$pageHeight - $marginTop - $marginBottom - $figure_name_height"/><!-- paper height minus margins and title height -->
	<xsl:variable name="image_dpi" select="96"/>
	<xsl:variable name="width_effective_px" select="$width_effective div 25.4 * $image_dpi"/>
	<xsl:variable name="height_effective_px" select="$height_effective div 25.4 * $image_dpi"/>

	<xsl:template match="*[local-name() = 'figure'][not(*[local-name() = 'image']) and *[local-name() = 'svg']]/*[local-name() = 'name']/*[local-name() = 'bookmark']" priority="2"/>
	<xsl:template match="*[local-name() = 'figure'][not(*[local-name() = 'image'])]/*[local-name() = 'svg']" priority="2" name="image_svg">
		<xsl:param name="name"/>

		<xsl:variable name="svg_content">
			<xsl:apply-templates select="." mode="svg_update"/>
		</xsl:variable>

		<xsl:variable name="alt-text">
			<xsl:choose>
				<xsl:when test="normalize-space(../*[local-name() = 'name']) != ''">
					<xsl:value-of select="../*[local-name() = 'name']"/>
				</xsl:when>
				<xsl:when test="normalize-space($name) != ''">
					<xsl:value-of select="$name"/>
				</xsl:when>
				<xsl:otherwise>Figure</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="isPrecedingTitle" select="normalize-space(ancestor::*[local-name() = 'figure']/preceding-sibling::*[1][local-name() = 'title'] and 1 = 1)"/>

		<xsl:choose>
			<xsl:when test=".//*[local-name() = 'a'][*[local-name() = 'rect'] or *[local-name() = 'polygon'] or *[local-name() = 'circle'] or *[local-name() = 'ellipse']]">
				<fo:block>
					<xsl:variable name="width" select="@width"/>
					<xsl:variable name="height" select="@height"/>

					<xsl:variable name="scale_x">
						<xsl:choose>
							<xsl:when test="$width &gt; $width_effective_px">
								<xsl:value-of select="$width_effective_px div $width"/>
							</xsl:when>
							<xsl:otherwise>1</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<xsl:variable name="scale_y">
						<xsl:choose>
							<xsl:when test="$height * $scale_x &gt; $height_effective_px">
								<xsl:value-of select="$height_effective_px div ($height * $scale_x)"/>
							</xsl:when>
							<xsl:otherwise>1</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<xsl:variable name="scale">
						<xsl:choose>
							<xsl:when test="$scale_y != 1">
								<xsl:value-of select="$scale_x * $scale_y"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$scale_x"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<xsl:variable name="width_scale" select="round($width * $scale)"/>
					<xsl:variable name="height_scale" select="round($height * $scale)"/>

					<fo:table table-layout="fixed" width="100%">
						<fo:table-column column-width="proportional-column-width(1)"/>
						<fo:table-column column-width="{$width_scale}px"/>
						<fo:table-column column-width="proportional-column-width(1)"/>
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell column-number="2">
									<fo:block>
										<fo:block-container width="{$width_scale}px" height="{$height_scale}px">
											<xsl:if test="../*[local-name() = 'name']/*[local-name() = 'bookmark']">
												<fo:block line-height="0" font-size="0">
													<xsl:for-each select="../*[local-name() = 'name']/*[local-name() = 'bookmark']">
														<xsl:call-template name="bookmark"/>
													</xsl:for-each>
												</fo:block>
											</xsl:if>
											<fo:block text-depth="0" line-height="0" font-size="0">

												<fo:instream-foreign-object fox:alt-text="{$alt-text}">
													<xsl:attribute name="width">100%</xsl:attribute>
													<xsl:attribute name="content-height">100%</xsl:attribute>
													<xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
													<xsl:attribute name="scaling">uniform</xsl:attribute>

													<xsl:apply-templates select="xalan:nodeset($svg_content)" mode="svg_remove_a"/>
												</fo:instream-foreign-object>
											</fo:block>

											<xsl:apply-templates select=".//*[local-name() = 'a'][*[local-name() = 'rect'] or *[local-name() = 'polygon'] or *[local-name() = 'circle'] or *[local-name() = 'ellipse']]" mode="svg_imagemap_links">
												<xsl:with-param name="scale" select="$scale"/>
											</xsl:apply-templates>
										</fo:block-container>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				</fo:block>

			</xsl:when>
			<xsl:otherwise>

				<xsl:variable name="image_class" select="ancestor::*[local-name() = 'image']/@class"/>
				<xsl:variable name="ancestor_table_cell" select="normalize-space(ancestor::*[local-name() = 'td'] or ancestor::*[local-name() = 'th'])"/>

				<xsl:variable name="element">
					<xsl:choose>
						<xsl:when test="ancestor::*[local-name() = 'tr'] and $isGenerateTableIF = 'true'">
							<fo:inline xsl:use-attribute-sets="image-style" text-align="left"/>
						</xsl:when>
						<xsl:when test="not(ancestor::*[local-name() = 'figure'])">
							<fo:inline xsl:use-attribute-sets="image-style" text-align="left"/>
						</xsl:when>
						<xsl:otherwise>
							<fo:block xsl:use-attribute-sets="image-style">
								<xsl:if test="ancestor::*[local-name() = 'dt']">
									<xsl:attribute name="text-align">left</xsl:attribute>
								</xsl:if>
							</fo:block>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:for-each select="xalan:nodeset($element)/*">
					<xsl:copy>
						<xsl:copy-of select="@*"/>
					<!-- <fo:block xsl:use-attribute-sets="image-style"> -->
						<fo:instream-foreign-object fox:alt-text="{$alt-text}">

							<xsl:choose>
								<xsl:when test="$image_class = 'corrigenda-tag'">
									<xsl:attribute name="fox:alt-text">CorrigendaTag</xsl:attribute>
									<xsl:attribute name="baseline-shift">-10%</xsl:attribute>
									<xsl:if test="$ancestor_table_cell = 'true'">
										<xsl:attribute name="baseline-shift">-25%</xsl:attribute>
									</xsl:if>
									<xsl:attribute name="height">3.5mm</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:if test="$isGenerateTableIF = 'false'">
										<xsl:attribute name="width">100%</xsl:attribute>
									</xsl:if>
									<xsl:attribute name="content-height">100%</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>

							<xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
							<xsl:variable name="svg_width_" select="xalan:nodeset($svg_content)/*/@width"/>
							<xsl:variable name="svg_width" select="number(translate($svg_width_, 'px', ''))"/>
							<xsl:variable name="svg_height_" select="xalan:nodeset($svg_content)/*/@height"/>
							<xsl:variable name="svg_height" select="number(translate($svg_height_, 'px', ''))"/>

							<!-- Example: -->
							<!-- effective height 297 - 27.4 - 13 =  256.6 -->
							<!-- effective width 210 - 12.5 - 25 = 172.5 -->
							<!-- effective height / width = 1.48, 1.4 - with title -->

							<xsl:variable name="scale_x">
								<xsl:choose>
									<xsl:when test="$svg_width &gt; $width_effective_px">
										<xsl:value-of select="$width_effective_px div $svg_width"/>
									</xsl:when>
									<xsl:otherwise>1</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:variable name="scale_y">
								<xsl:choose>
									<xsl:when test="$svg_height * $scale_x &gt; $height_effective_px">
										<xsl:variable name="height_effective_px_">
											<xsl:choose>
												<!-- title is 'keep-with-next' with following figure -->
												<xsl:when test="$isPrecedingTitle = 'true'"><xsl:value-of select="$height_effective_px - 80"/></xsl:when>
												<xsl:otherwise><xsl:value-of select="$height_effective_px"/></xsl:otherwise>
											</xsl:choose>
										</xsl:variable>
										<xsl:value-of select="$height_effective_px_ div ($svg_height * $scale_x)"/>
									</xsl:when>
									<xsl:otherwise>1</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>

							 <!-- for images with big height -->
							<!-- <xsl:if test="$svg_height &gt; ($svg_width * 1.4)">
								<xsl:variable name="width" select="(($svg_width * 1.4) div $svg_height) * 100"/>
								<xsl:attribute name="width"><xsl:value-of select="$width"/>%</xsl:attribute>
							</xsl:if> -->
							<xsl:attribute name="scaling">uniform</xsl:attribute>

							<xsl:if test="$scale_y != 1">
								<xsl:attribute name="content-height"><xsl:value-of select="round($scale_x * $scale_y * 100)"/>%</xsl:attribute>
							</xsl:if>

							<xsl:copy-of select="$svg_content"/>
						</fo:instream-foreign-object>
					<!-- </fo:block> -->
					</xsl:copy>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ============== -->
	<!-- svg_update     -->
	<!-- ============== -->
	<xsl:template match="@*|node()" mode="svg_update">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="svg_update"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'image']/@href" mode="svg_update">
		<xsl:attribute name="href" namespace="http://www.w3.org/1999/xlink">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>

	<xsl:variable name="regex_starts_with_digit">^[0-9].*</xsl:variable>

	<xsl:template match="*[local-name() = 'svg'][not(@width and @height)]" mode="svg_update">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="svg_update"/>
			<xsl:variable name="viewbox_">
				<xsl:call-template name="split">
					<xsl:with-param name="pText" select="@viewBox"/>
					<xsl:with-param name="sep" select="' '"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="viewbox" select="xalan:nodeset($viewbox_)"/>
			<xsl:variable name="width" select="normalize-space($viewbox//item[3])"/>
			<xsl:variable name="height" select="normalize-space($viewbox//item[4])"/>

			<xsl:variable name="parent_image_width" select="normalize-space(ancestor::*[1][local-name() = 'image']/@width)"/>
			<xsl:variable name="parent_image_height" select="normalize-space(ancestor::*[1][local-name() = 'image']/@height)"/>

			<xsl:attribute name="width">
				<xsl:choose>
					<!-- width is non 'auto', 'text-width', 'full-page-width' or 'narrow' -->
					<xsl:when test="$parent_image_width != '' and normalize-space(java:matches(java:java.lang.String.new($parent_image_width), $regex_starts_with_digit)) = 'true'"><xsl:value-of select="$parent_image_width"/></xsl:when>
					<xsl:when test="$width != ''">
						<xsl:value-of select="round($width)"/>
					</xsl:when>
					<xsl:otherwise>400</xsl:otherwise> <!-- default width -->
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="height">
				<xsl:choose>
					<!-- height non 'auto', 'text-width', 'full-page-width' or 'narrow' -->
					<xsl:when test="$parent_image_height != '' and normalize-space(java:matches(java:java.lang.String.new($parent_image_height), $regex_starts_with_digit)) = 'true'"><xsl:value-of select="$parent_image_height"/></xsl:when>
					<xsl:when test="$height != ''">
						<xsl:value-of select="round($height)"/>
					</xsl:when>
					<xsl:otherwise>400</xsl:otherwise> <!-- default height -->
				</xsl:choose>
			</xsl:attribute>

			<xsl:apply-templates mode="svg_update"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'svg']/@width" mode="svg_update">
		<!-- image[@width]/svg -->
		<xsl:variable name="parent_image_width" select="normalize-space(ancestor::*[2][local-name() = 'image']/@width)"/>
		<xsl:attribute name="width">
			<xsl:choose>
				<xsl:when test="$parent_image_width != '' and normalize-space(java:matches(java:java.lang.String.new($parent_image_width), $regex_starts_with_digit)) = 'true'"><xsl:value-of select="$parent_image_width"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="*[local-name() = 'svg']/@height" mode="svg_update">
		<!-- image[@height]/svg -->
		<xsl:variable name="parent_image_height" select="normalize-space(ancestor::*[2][local-name() = 'image']/@height)"/>
		<xsl:attribute name="height">
			<xsl:choose>
				<xsl:when test="$parent_image_height != '' and normalize-space(java:matches(java:java.lang.String.new($parent_image_height), $regex_starts_with_digit)) = 'true'"><xsl:value-of select="$parent_image_height"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<!-- regex for 'display: inline-block;' -->
	<xsl:variable name="regex_svg_style_notsupported">display(\s|\h)*:(\s|\h)*inline-block(\s|\h)*;</xsl:variable>
	<xsl:template match="*[local-name() = 'svg']//*[local-name() = 'style']/text()" mode="svg_update">
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.), $regex_svg_style_notsupported, '')"/>
	</xsl:template>

	<!-- replace
			stroke="rgba(r, g, b, alpha)" to 
			stroke="rgb(r,g,b)" stroke-opacity="alpha", and
			fill="rgba(r, g, b, alpha)" to 
			fill="rgb(r,g,b)" fill-opacity="alpha" -->
	<xsl:template match="@*[local-name() = 'stroke' or local-name() = 'fill'][starts-with(normalize-space(.), 'rgba')]" mode="svg_update">
		<xsl:variable name="components_">
			<xsl:call-template name="split">
				<xsl:with-param name="pText" select="substring-before(substring-after(., '('), ')')"/>
				<xsl:with-param name="sep" select="','"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="components" select="xalan:nodeset($components_)"/>
		<xsl:variable name="att_name" select="local-name()"/>
		<xsl:attribute name="{$att_name}"><xsl:value-of select="concat('rgb(', $components/item[1], ',', $components/item[2], ',', $components/item[3], ')')"/></xsl:attribute>
		<xsl:attribute name="{$att_name}-opacity"><xsl:value-of select="$components/item[4]"/></xsl:attribute>
	</xsl:template>

	<!-- ============== -->
	<!-- END: svg_update -->
	<!-- ============== -->

	<!-- image with svg and emf -->
	<xsl:template match="*[local-name() = 'figure']/*[local-name() = 'image'][*[local-name() = 'svg']]" priority="3">
		<xsl:variable name="name" select="ancestor::*[local-name() = 'figure']/*[local-name() = 'name']"/>
		<xsl:for-each select="*[local-name() = 'svg']">
			<xsl:call-template name="image_svg">
				<xsl:with-param name="name" select="$name"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- For the structures like: <dt><image src="" mimetype="image/svg+xml" height="" width=""><svg xmlns="http://www.w3.org/2000/svg" ... -->
	<xsl:template match="*[local-name() != 'figure']/*[local-name() = 'image'][*[local-name() = 'svg']]" priority="3">
		<xsl:for-each select="*[local-name() = 'svg']">
			<xsl:call-template name="image_svg"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*[local-name() = 'figure']/*[local-name() = 'image'][@mimetype = 'image/svg+xml' and @src[not(starts-with(., 'data:image/'))]]" priority="2">
		<xsl:variable name="svg_content" select="document(@src)"/>
		<xsl:variable name="name" select="ancestor::*[local-name() = 'figure']/*[local-name() = 'name']"/>
		<xsl:for-each select="xalan:nodeset($svg_content)/node()">
			<xsl:call-template name="image_svg">
				<xsl:with-param name="name" select="$name"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="@*|node()" mode="svg_remove_a">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="svg_remove_a"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'a']" mode="svg_remove_a">
		<xsl:apply-templates mode="svg_remove_a"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'a']" mode="svg_imagemap_links">
		<xsl:param name="scale"/>
		<xsl:variable name="dest">
			<xsl:choose>
				<xsl:when test="starts-with(@href, '#')">
					<xsl:value-of select="substring-after(@href, '#')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@href"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:for-each select="./*[local-name() = 'rect']">
			<xsl:call-template name="insertSVGMapLink">
				<xsl:with-param name="left" select="floor(@x * $scale)"/>
				<xsl:with-param name="top" select="floor(@y * $scale)"/>
				<xsl:with-param name="width" select="floor(@width * $scale)"/>
				<xsl:with-param name="height" select="floor(@height * $scale)"/>
				<xsl:with-param name="dest" select="$dest"/>
			</xsl:call-template>
		</xsl:for-each>

		<xsl:for-each select="./*[local-name() = 'polygon']">
			<xsl:variable name="points">
				<xsl:call-template name="split">
					<xsl:with-param name="pText" select="@points"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="x_coords">
				<xsl:for-each select="xalan:nodeset($points)//item[position() mod 2 = 1]">
					<xsl:sort select="." data-type="number"/>
					<x><xsl:value-of select="."/></x>
				</xsl:for-each>
			</xsl:variable>
			<xsl:variable name="y_coords">
				<xsl:for-each select="xalan:nodeset($points)//item[position() mod 2 = 0]">
					<xsl:sort select="." data-type="number"/>
					<y><xsl:value-of select="."/></y>
				</xsl:for-each>
			</xsl:variable>
			<xsl:variable name="x" select="xalan:nodeset($x_coords)//x[1]"/>
			<xsl:variable name="y" select="xalan:nodeset($y_coords)//y[1]"/>
			<xsl:variable name="width" select="xalan:nodeset($x_coords)//x[last()] - $x"/>
			<xsl:variable name="height" select="xalan:nodeset($y_coords)//y[last()] - $y"/>
			<xsl:call-template name="insertSVGMapLink">
				<xsl:with-param name="left" select="floor($x * $scale)"/>
				<xsl:with-param name="top" select="floor($y * $scale)"/>
				<xsl:with-param name="width" select="floor($width * $scale)"/>
				<xsl:with-param name="height" select="floor($height * $scale)"/>
				<xsl:with-param name="dest" select="$dest"/>
			</xsl:call-template>
		</xsl:for-each>

		<xsl:for-each select="./*[local-name() = 'circle']">
			<xsl:call-template name="insertSVGMapLink">
				<xsl:with-param name="left" select="floor((@cx - @r) * $scale)"/>
				<xsl:with-param name="top" select="floor((@cy - @r) * $scale)"/>
				<xsl:with-param name="width" select="floor(@r * 2 * $scale)"/>
				<xsl:with-param name="height" select="floor(@r * 2 * $scale)"/>
				<xsl:with-param name="dest" select="$dest"/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="./*[local-name() = 'ellipse']">
			<xsl:call-template name="insertSVGMapLink">
				<xsl:with-param name="left" select="floor((@cx - @rx) * $scale)"/>
				<xsl:with-param name="top" select="floor((@cy - @ry) * $scale)"/>
				<xsl:with-param name="width" select="floor(@rx * 2 * $scale)"/>
				<xsl:with-param name="height" select="floor(@ry * 2 * $scale)"/>
				<xsl:with-param name="dest" select="$dest"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="insertSVGMapLink">
		<xsl:param name="left"/>
		<xsl:param name="top"/>
		<xsl:param name="width"/>
		<xsl:param name="height"/>
		<xsl:param name="dest"/>
		<fo:block-container position="absolute" left="{$left}px" top="{$top}px" width="{$width}px" height="{$height}px">
		 <fo:block font-size="1pt">
			<xsl:call-template name="insert_basic_link">
				<xsl:with-param name="element">
					<fo:basic-link internal-destination="{$dest}" fox:alt-text="svg link">
						<fo:inline-container inline-progression-dimension="100%">
							<fo:block-container height="{$height - 1}px" width="100%">
								<!-- DEBUG <xsl:if test="local-name()='polygon'">
									<xsl:attribute name="background-color">magenta</xsl:attribute>
								</xsl:if> -->
							<fo:block> </fo:block></fo:block-container>
						</fo:inline-container>
					</fo:basic-link>
				</xsl:with-param>
			</xsl:call-template>
		 </fo:block>
	  </fo:block-container>
	</xsl:template>
	<!-- =================== -->
	<!-- End SVG images processing -->
	<!-- =================== -->

	<!-- ignore emf processing (Apache FOP doesn't support EMF) -->
	<xsl:template match="*[local-name() = 'emf']"/>

	<xsl:template match="*[local-name() = 'figure']/*[local-name() = 'name'] |                *[local-name() = 'table']/*[local-name() = 'name'] |               *[local-name() = 'permission']/*[local-name() = 'name'] |               *[local-name() = 'recommendation']/*[local-name() = 'name'] |               *[local-name() = 'requirement']/*[local-name() = 'name']" mode="contents">
		<xsl:if test="not(following-sibling::*[1][local-name() = 'fmt-name'])">
			<xsl:apply-templates mode="contents"/>
			<xsl:text> </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'title'][following-sibling::*[1][local-name() = 'fmt-title']]" mode="contents"/>

	<xsl:template match="*[local-name() = 'figure']/*[local-name() = 'fmt-name'] |                *[local-name() = 'table']/*[local-name() = 'fmt-name'] |               *[local-name() = 'permission']/*[local-name() = 'fmt-name'] |               *[local-name() = 'recommendation']/*[local-name() = 'fmt-name'] |               *[local-name() = 'requirement']/*[local-name() = 'fmt-name']" mode="contents">
		<xsl:apply-templates mode="contents"/>
		<xsl:text> </xsl:text>
	</xsl:template>

	<xsl:template match="*[local-name() = 'figure']/*[local-name() = 'name'] |                *[local-name() = 'table']/*[local-name() = 'name'] |               *[local-name() = 'permission']/*[local-name() = 'name'] |               *[local-name() = 'recommendation']/*[local-name() = 'name'] |               *[local-name() = 'requirement']/*[local-name() = 'name'] |               *[local-name() = 'sourcecode']/*[local-name() = 'name']" mode="bookmarks">
		<xsl:if test="not(following-sibling::*[1][local-name() = 'fmt-name'])">
			<xsl:apply-templates mode="bookmarks"/>
			<xsl:text> </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'figure']/*[local-name() = 'fmt-name'] |                *[local-name() = 'table']/*[local-name() = 'fmt-name'] |               *[local-name() = 'permission']/*[local-name() = 'fmt-name'] |               *[local-name() = 'recommendation']/*[local-name() = 'fmt-name'] |               *[local-name() = 'requirement']/*[local-name() = 'fmt-name'] |               *[local-name() = 'sourcecode']/*[local-name() = 'fmt-name']" mode="bookmarks">
		<xsl:apply-templates mode="bookmarks"/>
		<xsl:text> </xsl:text>
	</xsl:template>

	<xsl:template match="*[local-name() = 'figure' or local-name() = 'table' or local-name() = 'permission' or local-name() = 'recommendation' or local-name() = 'requirement']/*[local-name() = 'name']/text()" mode="contents" priority="2">
		<xsl:if test="not(../following-sibling::*[1][local-name() = 'fmt-name'])">
			<xsl:value-of select="."/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'figure' or local-name() = 'table' or local-name() = 'permission' or local-name() = 'recommendation' or local-name() = 'requirement']/*[local-name() = 'fmt-name']/text()" mode="contents" priority="2">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'figure' or local-name() = 'table' or local-name() = 'permission' or local-name() = 'recommendation' or local-name() = 'requirement' or local-name() = 'sourcecode']/*[local-name() = 'name']//text()" mode="bookmarks" priority="2">
		<xsl:if test="not(../following-sibling::*[1][local-name() = 'fmt-name'])">
			<xsl:value-of select="."/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'figure' or local-name() = 'table' or local-name() = 'permission' or local-name() = 'recommendation' or local-name() = 'requirement' or local-name() = 'sourcecode']/*[local-name() = 'fmt-name']//text()" mode="bookmarks" priority="2">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'add'][starts-with(., $ace_tag)]/text()" mode="bookmarks" priority="3"/>

	<xsl:template match="node()" mode="contents">
		<xsl:apply-templates mode="contents"/>
	</xsl:template>

	<!-- special case: ignore preface/section-title and sections/section-title without @displayorder  -->
	<xsl:template match="*[local-name() = 'preface' or local-name() = 'sections']/*[local-name() = 'p'][@type = 'section-title' and not(@displayorder)]" priority="3" mode="contents"/>
	<!-- process them by demand (mode="contents_no_displayorder") -->
	<xsl:template match="*[local-name() = 'p'][@type = 'section-title' and not(@displayorder)]" mode="contents_no_displayorder">
		<xsl:call-template name="contents_section-title"/>
	</xsl:template>
	<xsl:template match="*[local-name() = 'p'][@type = 'section-title']" mode="contents_in_clause">
		<xsl:call-template name="contents_section-title"/>
	</xsl:template>

	<!-- special case: ignore section-title if @depth different than @depth of parent clause, or @depth of parent clause = 1 -->
	<xsl:template match="*[local-name() = 'clause']/*[local-name() = 'p'][@type = 'section-title' and (@depth != ../*[local-name() = 'title' or local-name() = 'fmt-title']/@depth or ../*[local-name() = 'title' or local-name() = 'fmt-title']/@depth = 1)]" priority="3" mode="contents"/>

	<xsl:template match="*[local-name() = 'p'][@type = 'floating-title' or @type = 'section-title']" priority="2" name="contents_section-title" mode="contents">
		<xsl:variable name="level">
			<xsl:call-template name="getLevel">
				<xsl:with-param name="depth" select="@depth"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="section">
			<xsl:choose>
				<xsl:when test="@type = 'section-title'"/>
				<xsl:when test="*[local-name() = 'span'][@class = 'fmt-caption-delim']">
					<xsl:value-of select="*[local-name() = 'span'][@class = 'fmt-caption-delim'][1]/preceding-sibling::node()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="*[local-name() = 'tab'][1]/preceding-sibling::node()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="type"><xsl:value-of select="@type"/></xsl:variable>

		<xsl:variable name="display">
			<xsl:choose>
				<xsl:when test="normalize-space(@id) = ''">false</xsl:when>
				<xsl:when test="$level &lt;= $toc_level">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="skip">false</xsl:variable>

		<xsl:if test="$skip = 'false'">

			<xsl:variable name="title">
				<xsl:choose>
					<!-- https://github.com/metanorma/mn-native-pdf/issues/770 -->
					<xsl:when test="*[local-name() = 'span'][@class = 'fmt-caption-delim']">
						<xsl:choose>
							<xsl:when test="@type = 'section-title'">
								<xsl:value-of select="*[local-name() = 'span'][@class = 'fmt-caption-delim'][1]/preceding-sibling::node()"/>
								<xsl:text>: </xsl:text>
								<xsl:copy-of select="*[local-name() = 'span'][@class = 'fmt-caption-delim'][1]/following-sibling::node()[not(local-name() = 'fmt-xref-label')]"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="*[local-name() = 'span'][@class = 'fmt-caption-delim'][1]/following-sibling::node()[not(local-name() = 'fmt-xref-label')]"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="*[local-name() = 'tab']">
						<xsl:choose>
							<xsl:when test="@type = 'section-title'">
								<xsl:value-of select="*[local-name() = 'tab'][1]/preceding-sibling::node()"/>
								<xsl:text>: </xsl:text>
								<xsl:copy-of select="*[local-name() = 'tab'][1]/following-sibling::node()"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="*[local-name() = 'tab'][1]/following-sibling::node()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="node()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="root">
				<xsl:if test="ancestor-or-self::*[local-name() = 'preface']">preface</xsl:if>
				<xsl:if test="ancestor-or-self::*[local-name() = 'annex']">annex</xsl:if>
			</xsl:variable>

			<item id="{@id}" level="{$level}" section="{$section}" type="{$type}" root="{$root}" display="{$display}">
				<title>
					<xsl:apply-templates select="xalan:nodeset($title)" mode="contents_item"/>
				</title>
			</item>
		</xsl:if>
	</xsl:template>

	<xsl:template match="node()" mode="bookmarks">
		<xsl:apply-templates mode="bookmarks"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'stem']" mode="contents"/>

	<xsl:template match="*[local-name() = 'title' or local-name() = 'name' or local-name() = 'fmt-title' or local-name() = 'fmt-name']//*[local-name() = 'fmt-stem']" mode="contents">
		<xsl:apply-templates select="."/>
	</xsl:template>

	<!-- prevent missing stem for table and figures in ToC -->
	<xsl:template match="*[local-name() = 'name' or local-name() = 'fmt-name']//*[local-name() = 'stem']" mode="contents">
		<xsl:if test="not(following-sibling::*[1][local-name() = 'fmt-stem'])">
			<xsl:apply-templates select="."/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'references'][@hidden='true']" mode="contents" priority="3"/>

	<xsl:template match="*[local-name() = 'references']/*[local-name() = 'bibitem']" mode="contents"/>

	<!-- Note: to enable the addition of character span markup with semantic styling for DIS Word output -->
	<xsl:template match="*[local-name() = 'span']" mode="contents">
		<xsl:apply-templates mode="contents"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'semx']" mode="contents">
		<xsl:apply-templates mode="contents"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'concept']" mode="contents"/>
	<xsl:template match="*[local-name() = 'eref']" mode="contents"/>
	<xsl:template match="*[local-name() = 'xref']" mode="contents"/>
	<xsl:template match="*[local-name() = 'link']" mode="contents"/>
	<xsl:template match="*[local-name() = 'origin']" mode="contents"/>
	<xsl:template match="*[local-name() = 'erefstack ']" mode="contents"/>

	<xsl:template match="*[local-name() = 'requirement'] |             *[local-name() = 'recommendation'] |              *[local-name() = 'permission']" mode="contents" priority="3"/>

	<xsl:template match="*[local-name() = 'stem']" mode="bookmarks"/>
	<xsl:template match="*[local-name() = 'fmt-stem']" mode="bookmarks">
		<xsl:apply-templates mode="bookmarks"/>
	</xsl:template>

	<!-- Note: to enable the addition of character span markup with semantic styling for DIS Word output -->
	<xsl:template match="*[local-name() = 'span']" mode="bookmarks">
		<xsl:apply-templates mode="bookmarks"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'semx']" mode="bookmarks">
		<xsl:apply-templates mode="bookmarks"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'concept']" mode="bookmarks"/>
	<xsl:template match="*[local-name() = 'eref']" mode="bookmarks"/>
	<xsl:template match="*[local-name() = 'xref']" mode="bookmarks"/>
	<xsl:template match="*[local-name() = 'link']" mode="bookmarks"/>
	<xsl:template match="*[local-name() = 'origin']" mode="bookmarks"/>
	<xsl:template match="*[local-name() = 'erefstack ']" mode="bookmarks"/>

	<xsl:template match="*[local-name() = 'requirement'] |             *[local-name() = 'recommendation'] |              *[local-name() = 'permission']" mode="bookmarks" priority="3"/>

	<!-- Bookmarks -->
	<xsl:template name="addBookmarks">
		<xsl:param name="contents"/>
		<xsl:param name="contents_addon"/>
		<xsl:variable name="contents_nodes" select="xalan:nodeset($contents)"/>
		<xsl:if test="$contents_nodes//item">
			<fo:bookmark-tree>
				<xsl:choose>
					<xsl:when test="$contents_nodes/doc">
						<xsl:choose>
							<xsl:when test="count($contents_nodes/doc) &gt; 1">

								<xsl:if test="$contents_nodes/collection">
									<fo:bookmark internal-destination="{$contents/collection/@firstpage_id}">
										<fo:bookmark-title>collection.pdf</fo:bookmark-title>
									</fo:bookmark>
								</xsl:if>

								<xsl:for-each select="$contents_nodes/doc">
									<fo:bookmark internal-destination="{contents/item[@display = 'true'][1]/@id}" starting-state="hide">
										<xsl:if test="@bundle = 'true'">
											<xsl:attribute name="internal-destination"><xsl:value-of select="@firstpage_id"/></xsl:attribute>
										</xsl:if>
										<fo:bookmark-title>
											<xsl:choose>
												<xsl:when test="not(normalize-space(@bundle) = 'true')"> <!-- 'bundle' means several different documents (not language versions) in one xml -->
													<xsl:variable name="bookmark-title_">
														<xsl:call-template name="getLangVersion">
															<xsl:with-param name="lang" select="@lang"/>
															<xsl:with-param name="doctype" select="@doctype"/>
															<xsl:with-param name="title" select="@title-part"/>
														</xsl:call-template>
													</xsl:variable>
													<xsl:choose>
														<xsl:when test="normalize-space($bookmark-title_) != ''">
															<xsl:value-of select="normalize-space($bookmark-title_)"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:choose>
																<xsl:when test="@lang = 'en'">English</xsl:when>
																<xsl:when test="@lang = 'fr'">Français</xsl:when>
																<xsl:when test="@lang = 'de'">Deutsche</xsl:when>
																<xsl:otherwise><xsl:value-of select="@lang"/> version</xsl:otherwise>
															</xsl:choose>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="@title-part"/>
												</xsl:otherwise>
											</xsl:choose>
										</fo:bookmark-title>

										<xsl:apply-templates select="contents/item" mode="bookmark"/>

										<xsl:call-template name="insertFigureBookmarks">
											<xsl:with-param name="contents" select="contents"/>
										</xsl:call-template>

										<xsl:call-template name="insertTableBookmarks">
											<xsl:with-param name="contents" select="contents"/>
											<xsl:with-param name="lang" select="@lang"/>
										</xsl:call-template>

									</fo:bookmark>

								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="$contents_nodes/doc">

									<xsl:apply-templates select="contents/item" mode="bookmark"/>

									<xsl:call-template name="insertFigureBookmarks">
										<xsl:with-param name="contents" select="contents"/>
									</xsl:call-template>

									<xsl:call-template name="insertTableBookmarks">
										<xsl:with-param name="contents" select="contents"/>
										<xsl:with-param name="lang" select="@lang"/>
									</xsl:call-template>

								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="$contents_nodes/contents/item" mode="bookmark"/>

						<xsl:call-template name="insertFigureBookmarks">
							<xsl:with-param name="contents" select="$contents_nodes/contents"/>
						</xsl:call-template>

						<xsl:call-template name="insertTableBookmarks">
							<xsl:with-param name="contents" select="$contents_nodes/contents"/>
							<xsl:with-param name="lang" select="@lang"/>
						</xsl:call-template>

					</xsl:otherwise>
				</xsl:choose>

				<!-- for $namespace = 'nist-sp' $namespace = 'ogc' $namespace = 'ogc-white-paper' -->
				<xsl:copy-of select="$contents_addon"/>

			</fo:bookmark-tree>
		</xsl:if>
	</xsl:template>

	<xsl:template name="insertFigureBookmarks">
		<xsl:param name="contents"/>
		<xsl:variable name="contents_nodes" select="xalan:nodeset($contents)"/>
		<xsl:if test="$contents_nodes/figure">
			<fo:bookmark internal-destination="{$contents_nodes/figure[1]/@id}" starting-state="hide">
				<fo:bookmark-title>Figures</fo:bookmark-title>
				<xsl:for-each select="$contents_nodes/figure">
					<fo:bookmark internal-destination="{@id}">
						<fo:bookmark-title>
							<xsl:value-of select="normalize-space(title)"/>
						</fo:bookmark-title>
					</fo:bookmark>
				</xsl:for-each>
			</fo:bookmark>
		</xsl:if>

				<xsl:if test="$contents_nodes//figures/figure">
					<fo:bookmark internal-destination="empty_bookmark" starting-state="hide">

						<xsl:variable name="bookmark-title">

									<xsl:value-of select="$title-list-figures"/>

						</xsl:variable>
						<fo:bookmark-title><xsl:value-of select="normalize-space($bookmark-title)"/></fo:bookmark-title>
						<xsl:for-each select="$contents_nodes//figures/figure">
							<fo:bookmark internal-destination="{@id}">
								<fo:bookmark-title><xsl:value-of select="normalize-space(.)"/></fo:bookmark-title>
							</fo:bookmark>
						</xsl:for-each>
					</fo:bookmark>
				</xsl:if>

	</xsl:template> <!-- insertFigureBookmarks -->

	<xsl:template name="insertTableBookmarks">
		<xsl:param name="contents"/>
		<xsl:param name="lang"/>
		<xsl:variable name="contents_nodes" select="xalan:nodeset($contents)"/>
		<xsl:if test="$contents_nodes/table">
			<fo:bookmark internal-destination="{$contents_nodes/table[1]/@id}" starting-state="hide">
				<fo:bookmark-title>
					<xsl:choose>
						<xsl:when test="$lang = 'fr'">Tableaux</xsl:when>
						<xsl:otherwise>Tables</xsl:otherwise>
					</xsl:choose>
				</fo:bookmark-title>
				<xsl:for-each select="$contents_nodes/table">
					<fo:bookmark internal-destination="{@id}">
						<fo:bookmark-title>
							<xsl:value-of select="normalize-space(title)"/>
						</fo:bookmark-title>
					</fo:bookmark>
				</xsl:for-each>
			</fo:bookmark>
		</xsl:if>

				<xsl:if test="$contents_nodes//tables/table">
					<fo:bookmark internal-destination="empty_bookmark" starting-state="hide">

						<xsl:variable name="bookmark-title">

									<xsl:value-of select="$title-list-tables"/>

						</xsl:variable>

						<fo:bookmark-title><xsl:value-of select="$bookmark-title"/></fo:bookmark-title>

						<xsl:for-each select="$contents_nodes//tables/table">
							<fo:bookmark internal-destination="{@id}">
								<!-- <fo:bookmark-title><xsl:value-of select="normalize-space(.)"/></fo:bookmark-title> -->
								<fo:bookmark-title><xsl:apply-templates mode="bookmark_clean"/></fo:bookmark-title>
							</fo:bookmark>
						</xsl:for-each>
					</fo:bookmark>
				</xsl:if>

	</xsl:template> <!-- insertTableBookmarks -->
	<!-- End Bookmarks -->

	<!-- ============================ -->
	<!-- mode="bookmark_clean" -->
	<!-- ============================ -->
	<xsl:template match="node()" mode="bookmark_clean">
		<xsl:apply-templates select="node()" mode="bookmark_clean"/>
	</xsl:template>

	<xsl:template match="text()" mode="bookmark_clean">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'math']" mode="bookmark_clean">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'asciimath']" mode="bookmark_clean"/>
	<!-- ============================ -->
	<!-- END: mode="bookmark_clean" -->
	<!-- ============================ -->

	<xsl:template name="getLangVersion">
		<xsl:param name="lang"/>
		<xsl:param name="doctype" select="''"/>
		<xsl:param name="title" select="''"/>
		<xsl:choose>
			<xsl:when test="$lang = 'en'">

				</xsl:when>
			<xsl:when test="$lang = 'fr'">

			</xsl:when>
			<xsl:when test="$lang = 'de'">Deutsche</xsl:when>
			<xsl:otherwise><xsl:value-of select="$lang"/> version</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="item" mode="bookmark">
		<xsl:choose>
			<xsl:when test="@id != ''">
				<fo:bookmark internal-destination="{@id}" starting-state="hide">
					<fo:bookmark-title>
						<xsl:if test="@section != ''">
							<xsl:value-of select="@section"/>
							<xsl:text> </xsl:text>
						</xsl:if>
						<xsl:variable name="title">
							<xsl:for-each select="title/node()">
								<xsl:choose>
									<xsl:when test="local-name() = 'add' and starts-with(., $ace_tag)"><!-- skip --></xsl:when>
									<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</xsl:variable>
						<xsl:value-of select="normalize-space($title)"/>
					</fo:bookmark-title>
					<xsl:apply-templates mode="bookmark"/>
				</fo:bookmark>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="bookmark"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="title" mode="bookmark"/>
	<xsl:template match="text()" mode="bookmark"/>

	<xsl:template match="*[local-name() = 'figure']/*[local-name() = 'name'] |         *[local-name() = 'image']/*[local-name() = 'name']">
		<xsl:if test="normalize-space() != ''">
			<fo:block xsl:use-attribute-sets="figure-name-style">

				<xsl:call-template name="refine_figure-name-style"/>

				<xsl:apply-templates/>
			</fo:block>
		</xsl:if>
	</xsl:template>

	<!-- figure/fn -->
	<xsl:template match="*[local-name() = 'figure']/*[local-name() = 'fn']" priority="2"/>
	<!-- figure/note -->
	<xsl:template match="*[local-name() = 'figure']/*[local-name() = 'note']" priority="2"/>
	<!-- figure/example -->
	<xsl:template match="*[local-name() = 'figure']/*[local-name() = 'example']" priority="2"/>

	<!-- figure/note[@type = 'units'] -->
	<!-- image/note[@type = 'units'] -->
	<xsl:template match="*[local-name() = 'figure']/*[local-name() = 'note'][@type = 'units'] |         *[local-name() = 'image']/*[local-name() = 'note'][@type = 'units']" priority="2">
		<fo:block text-align="right" keep-with-next="always">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<!-- ====== -->
	<!-- ====== -->
	<xsl:template match="*[local-name() = 'title']" mode="contents_item">
		<xsl:param name="mode">bookmarks</xsl:param>
		<xsl:if test="not(following-sibling::*[1][local-name() = 'fmt-title'])">
			<xsl:apply-templates mode="contents_item">
				<xsl:with-param name="mode" select="$mode"/>
			</xsl:apply-templates>
			<!-- <xsl:text> </xsl:text> -->
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'fmt-title']" mode="contents_item">
		<xsl:param name="mode">bookmarks</xsl:param>
		<xsl:apply-templates mode="contents_item">
			<xsl:with-param name="mode" select="$mode"/>
		</xsl:apply-templates>
		<!-- <xsl:text> </xsl:text> -->
	</xsl:template>

	<xsl:template match="*[local-name() = 'span'][                @class = 'fmt-caption-label' or                 @class = 'fmt-element-name' or                @class = 'fmt-caption-delim']" mode="contents_item" priority="3">
		<xsl:apply-templates mode="contents_item"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'semx']" mode="contents_item">
		<xsl:apply-templates mode="contents_item"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'fmt-xref-label']" mode="contents_item"/>

	<xsl:template match="*[local-name() = 'concept']" mode="contents_item"/>
	<xsl:template match="*[local-name() = 'eref']" mode="contents_item"/>
	<xsl:template match="*[local-name() = 'xref']" mode="contents_item"/>
	<xsl:template match="*[local-name() = 'link']" mode="contents_item"/>
	<xsl:template match="*[local-name() = 'origin']" mode="contents_item"/>
	<xsl:template match="*[local-name() = 'erefstack ']" mode="contents_item"/>

	<xsl:template name="getSection">
		<xsl:choose>
			<xsl:when test="*[local-name() = 'fmt-title']">
				<xsl:variable name="fmt_title_section">
					<xsl:copy-of select="*[local-name() = 'fmt-title']//*[local-name() = 'span'][@class = 'fmt-caption-delim'][*[local-name() = 'tab']][1]/preceding-sibling::node()[not(local-name() = 'review')]"/>
				</xsl:variable>
				<xsl:value-of select="normalize-space($fmt_title_section)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="*[local-name() = 'title']/*[local-name() = 'tab'][1]/preceding-sibling::node()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="getName">
		<xsl:choose>
			<xsl:when test="*[local-name() = 'fmt-title']//*[local-name() = 'span'][@class = 'fmt-caption-delim'][*[local-name() = 'tab']]">
				<xsl:copy-of select="*[local-name() = 'fmt-title']//*[local-name() = 'span'][@class = 'fmt-caption-delim'][*[local-name() = 'tab']][1]/following-sibling::node()"/>
			</xsl:when>
			<xsl:when test="*[local-name() = 'fmt-title']">
				<xsl:copy-of select="*[local-name() = 'fmt-title']/node()"/>
			</xsl:when>
			<xsl:when test="*[local-name() = 'title']/*[local-name() = 'tab']">
				<xsl:copy-of select="*[local-name() = 'title']/*[local-name() = 'tab'][1]/following-sibling::node()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="*[local-name() = 'title']/node()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="insertTitleAsListItem">
		<xsl:param name="provisional-distance-between-starts" select="'9.5mm'"/>
		<xsl:variable name="section">
			<xsl:for-each select="..">
				<xsl:call-template name="getSection"/>
			</xsl:for-each>
		</xsl:variable>
		<fo:list-block provisional-distance-between-starts="{$provisional-distance-between-starts}">
			<fo:list-item>
				<fo:list-item-label end-indent="label-end()">
					<fo:block>
						<xsl:value-of select="$section"/>
					</fo:block>
				</fo:list-item-label>
				<fo:list-item-body start-indent="body-start()">
					<fo:block>
						<xsl:choose>
							<xsl:when test="*[local-name() = 'tab']">
								<xsl:apply-templates select="*[local-name() = 'tab'][1]/following-sibling::node()"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates/>
								<xsl:apply-templates select="following-sibling::*[1][local-name() = 'variant-title'][@type = 'sub']" mode="subtitle"/>
							</xsl:otherwise>
						</xsl:choose>
					</fo:block>
				</fo:list-item-body>
			</fo:list-item>
		</fo:list-block>
	</xsl:template>

	<xsl:template name="extractSection">
		<xsl:value-of select="*[local-name() = 'tab'][1]/preceding-sibling::node()"/>
	</xsl:template>

	<xsl:template name="extractTitle">
		<xsl:choose>
				<xsl:when test="*[local-name() = 'tab']">
					<xsl:apply-templates select="*[local-name() = 'tab'][1]/following-sibling::node()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
	</xsl:template>

	<!-- fn -->
	<xsl:template match="*[local-name() = 'fn']" mode="contents"/>
	<xsl:template match="*[local-name() = 'fn']" mode="bookmarks"/>

	<xsl:template match="*[local-name() = 'fn']" mode="contents_item"/>

	<xsl:template match="*[local-name() = 'xref'] | *[local-name() = 'eref']" mode="contents">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'review']" mode="contents_item"/>

	<xsl:template match="*[local-name() = 'tab']" mode="contents_item">
		<xsl:text> </xsl:text>
	</xsl:template>

	<xsl:template match="*[local-name() = 'strong']" mode="contents_item">
		<xsl:param name="element"/>
		<xsl:copy>
			<xsl:apply-templates mode="contents_item">
				<xsl:with-param name="element" select="$element"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'em']" mode="contents_item">
		<xsl:copy>
			<xsl:apply-templates mode="contents_item"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'sub']" mode="contents_item">
		<xsl:copy>
			<xsl:apply-templates mode="contents_item"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'sup']" mode="contents_item">
		<xsl:copy>
			<xsl:apply-templates mode="contents_item"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'stem']" mode="contents_item"/>
	<xsl:template match="*[local-name() = 'fmt-stem']" mode="contents_item">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'br']" mode="contents_item">
		<xsl:text> </xsl:text>
	</xsl:template>

	<xsl:template match="*[local-name() = 'name']" mode="contents_item">
		<xsl:param name="mode">bookmarks</xsl:param>
		<xsl:if test="not(following-sibling::*[1][local-name() = 'fmt-name'])">
			<xsl:apply-templates mode="contents_item">
				<xsl:with-param name="mode" select="$mode"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'fmt-name']" mode="contents_item">
		<xsl:param name="mode">bookmarks</xsl:param>
		<xsl:apply-templates mode="contents_item">
			<xsl:with-param name="mode" select="$mode"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*[local-name() = 'add']" mode="contents_item">
		<xsl:param name="mode">bookmarks</xsl:param>
		<xsl:choose>
			<xsl:when test="starts-with(text(), $ace_tag)">
				<xsl:if test="$mode = 'contents'">
					<xsl:copy>
						<xsl:apply-templates mode="contents_item"/>
					</xsl:copy>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise><xsl:apply-templates mode="contents_item"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="text()" mode="contents_item">
		<xsl:variable name="text">
			<!-- to split by '_' and other chars -->
			<text><xsl:call-template name="add-zero-spaces-java"/></text>
		</xsl:variable>
		<xsl:for-each select="xalan:nodeset($text)/text/text()">
			<xsl:call-template name="keep_together_standard_number"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*[local-name() = 'add'][starts-with(., $ace_tag)]/text()" mode="contents_item" priority="2">
		<xsl:value-of select="."/>
	</xsl:template>

	<!-- Note: to enable the addition of character span markup with semantic styling for DIS Word output -->
	<xsl:template match="*[local-name() = 'span']" mode="contents_item">
		<xsl:param name="element"/>
		<xsl:apply-templates mode="contents_item">
			<xsl:with-param name="element" select="$element"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- =============== -->
	<!-- sourcecode  -->
	<!-- =============== -->

	<xsl:variable name="source-highlighter-css_" select="//*[local-name() = 'metanorma']/*[local-name() = 'metanorma-extension']/*[local-name() = 'source-highlighter-css']"/>
	<xsl:variable name="sourcecode_css_" select="java:org.metanorma.fop.Util.parseCSS($source-highlighter-css_)"/>
	<xsl:variable name="sourcecode_css" select="xalan:nodeset($sourcecode_css_)"/>

	<xsl:template match="*[local-name() = 'property']" mode="css">
		<xsl:attribute name="{@name}">
			<xsl:value-of select="@value"/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template name="get_sourcecode_attributes">
		<xsl:element name="sourcecode_attributes" use-attribute-sets="sourcecode-style">
			<xsl:variable name="_font-size">

				<!-- inherit -->

				<!-- <xsl:if test="$namespace = 'ieee'">							
					<xsl:if test="$current_template = 'standard'">8</xsl:if>
				</xsl:if> -->

			</xsl:variable>

			<xsl:variable name="font-size" select="normalize-space($_font-size)"/>
			<xsl:if test="$font-size != ''">
				<xsl:attribute name="font-size">
					<xsl:choose>
						<xsl:when test="$font-size = 'inherit'"><xsl:value-of select="$font-size"/></xsl:when>
						<xsl:when test="contains($font-size, '%')"><xsl:value-of select="$font-size"/></xsl:when>
						<xsl:when test="ancestor::*[local-name()='note']"><xsl:value-of select="$font-size * 0.91"/>pt</xsl:when>
						<xsl:otherwise><xsl:value-of select="$font-size"/>pt</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="$sourcecode_css//class[@name = 'sourcecode']" mode="css"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*[local-name()='sourcecode']" name="sourcecode">

		<xsl:variable name="sourcecode_attributes">
			<xsl:call-template name="get_sourcecode_attributes"/>
		</xsl:variable>

    <!-- <xsl:copy-of select="$sourcecode_css"/> -->

		<xsl:choose>
			<xsl:when test="$isGenerateTableIF = 'true' and (ancestor::*[local-name() = 'td'] or ancestor::*[local-name() = 'th'])">
				<xsl:for-each select="xalan:nodeset($sourcecode_attributes)/sourcecode_attributes/@*">
					<xsl:attribute name="{local-name()}">
						<xsl:value-of select="."/>
					</xsl:attribute>
				</xsl:for-each>
				<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
			</xsl:when>

			<xsl:otherwise>
				<fo:block-container xsl:use-attribute-sets="sourcecode-container-style" role="SKIP">

					<xsl:if test="not(ancestor::*[local-name() = 'li']) or ancestor::*[local-name() = 'example']">
						<xsl:attribute name="margin-left">0mm</xsl:attribute>
					</xsl:if>

					<xsl:if test="ancestor::*[local-name() = 'example']">
						<xsl:attribute name="margin-right">0mm</xsl:attribute>
					</xsl:if>

					<xsl:copy-of select="@id"/>

					<xsl:if test="parent::*[local-name() = 'note']">
						<xsl:attribute name="margin-left">
							<xsl:choose>
								<xsl:when test="not(ancestor::*[local-name() = 'table'])"><xsl:value-of select="$note-body-indent"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="$note-body-indent-table"/></xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>

					</xsl:if>
					<fo:block-container margin-left="0mm" role="SKIP">

						<fo:block xsl:use-attribute-sets="sourcecode-style">

							<xsl:for-each select="xalan:nodeset($sourcecode_attributes)/sourcecode_attributes/@*">
								<xsl:attribute name="{local-name()}">
									<xsl:value-of select="."/>
								</xsl:attribute>
							</xsl:for-each>

							<xsl:call-template name="refine_sourcecode-style"/>

							<!-- remove margin between rows in the table with sourcecode line numbers -->
							<xsl:if test="ancestor::*[local-name() = 'sourcecode'][@linenums = 'true'] and ancestor::*[local-name() = 'tr'][1]/following-sibling::*[local-name() = 'tr']">
								<xsl:attribute name="margin-top">0pt</xsl:attribute>
								<xsl:attribute name="margin-bottom">0pt</xsl:attribute>
							</xsl:if>

							<xsl:apply-templates select="node()[not(local-name() = 'name' or local-name() = 'dl')]"/>
						</fo:block>

						<xsl:apply-templates select="*[local-name() = 'dl']"/> <!-- Key table -->

								<xsl:apply-templates select="*[local-name()='name']"/> <!-- show sourcecode's name AFTER content -->

					</fo:block-container>
				</fo:block-container>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[local-name()='sourcecode']/text() | *[local-name()='sourcecode']//*[local-name()='span']/text()" priority="2">
		<xsl:choose>
			<!-- disabled -->
			<xsl:when test="1 = 2 and normalize-space($syntax-highlight) = 'true' and normalize-space(../@lang) != ''"> <!-- condition for turn on of highlighting -->
				<xsl:variable name="syntax" select="java:org.metanorma.fop.Util.syntaxHighlight(., ../@lang)"/>
				<xsl:choose>
					<xsl:when test="normalize-space($syntax) != ''"><!-- if there is highlighted result -->
						<xsl:apply-templates select="xalan:nodeset($syntax)" mode="syntax_highlight"/> <!-- process span tags -->
					</xsl:when>
					<xsl:otherwise> <!-- if case of non-succesfull syntax highlight (for instance, unknown lang), process without highlighting -->
						<xsl:call-template name="add_spaces_to_sourcecode"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="add_spaces_to_sourcecode"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- add sourcecode highlighting -->
	<xsl:template match="*[local-name()='sourcecode']//*[local-name()='span'][@class]" priority="2">
		<xsl:variable name="class" select="@class"/>

		<!-- Example: <1> -->
		<xsl:variable name="is_callout">
			<xsl:if test="parent::*[local-name() = 'dt']">
				<xsl:variable name="dt_id" select="../@id"/>
				<xsl:if test="ancestor::*[local-name() = 'sourcecode']//*[local-name() = 'callout'][@target = $dt_id]">true</xsl:if>
			</xsl:if>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$sourcecode_css//class[@name = $class]">
				<fo:inline>
					<xsl:apply-templates select="$sourcecode_css//class[@name = $class]" mode="css"/>
					<xsl:if test="$is_callout = 'true'">&lt;</xsl:if>
					<xsl:apply-templates/>
					<xsl:if test="$is_callout = 'true'">&gt;</xsl:if>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- outer table with line numbers for sourcecode -->
	<xsl:template match="*[local-name() = 'sourcecode'][@linenums = 'true']/*[local-name()='table']" priority="2"> <!-- *[local-name()='table'][@type = 'sourcecode'] |  -->
		<fo:block>
			<fo:table width="100%" table-layout="fixed">
				<xsl:copy-of select="@id"/>
					<fo:table-column column-width="8%"/>
					<fo:table-column column-width="92%"/>
					<fo:table-body>
						<xsl:apply-templates/>
					</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:template>
	<xsl:template match="*[local-name() = 'sourcecode'][@linenums = 'true']/*[local-name()='table']/*[local-name() = 'tbody']" priority="2"> <!-- *[local-name()='table'][@type = 'sourcecode']/*[local-name() = 'tbody'] |  -->
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="*[local-name() = 'sourcecode'][@linenums = 'true']/*[local-name()='table']//*[local-name()='tr']" priority="2"> <!-- *[local-name()='table'][@type = 'sourcecode']//*[local-name()='tr'] |  -->
		<fo:table-row>
			<xsl:apply-templates/>
		</fo:table-row>
	</xsl:template>
	<!-- first td with line numbers -->
	<xsl:template match="*[local-name() = 'sourcecode'][@linenums = 'true']/*[local-name()='table']//*[local-name()='tr']/*[local-name()='td'][not(preceding-sibling::*)]" priority="2"> <!-- *[local-name()='table'][@type = 'sourcecode'] -->
		<fo:table-cell>
			<fo:block>

				<!-- set attibutes for line numbers - same as sourcecode -->
				<xsl:variable name="sourcecode_attributes">
					<xsl:for-each select="following-sibling::*[local-name() = 'td']/*[local-name() = 'sourcecode']">
						<xsl:call-template name="get_sourcecode_attributes"/>
					</xsl:for-each>
				</xsl:variable>
				<xsl:for-each select="xalan:nodeset($sourcecode_attributes)/sourcecode_attributes/@*[not(starts-with(local-name(), 'margin-') or starts-with(local-name(), 'space-'))]">
					<xsl:attribute name="{local-name()}">
						<xsl:value-of select="."/>
					</xsl:attribute>
				</xsl:for-each>

				<xsl:apply-templates/>
			</fo:block>
		</fo:table-cell>
	</xsl:template>

	<!-- second td with sourcecode -->
	<xsl:template match="*[local-name() = 'sourcecode'][@linenums = 'true']/*[local-name()='table']//*[local-name()='tr']/*[local-name()='td'][preceding-sibling::*]" priority="2"> <!-- *[local-name()='table'][@type = 'sourcecode'] -->
		<fo:table-cell>
			<fo:block role="SKIP">
				<xsl:apply-templates/>
			</fo:block>
		</fo:table-cell>
	</xsl:template>
	<!-- END outer table with line numbers for sourcecode -->

	<xsl:template name="add_spaces_to_sourcecode">
		<xsl:variable name="text_step1">
			<xsl:call-template name="add-zero-spaces-equal"/>
		</xsl:variable>
		<xsl:variable name="text_step2">
			<xsl:call-template name="add-zero-spaces-java">
				<xsl:with-param name="text" select="$text_step1"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- <xsl:value-of select="$text_step2"/> -->

		<!-- add zero-width space after space -->
		<xsl:variable name="text_step3" select="java:replaceAll(java:java.lang.String.new($text_step2),' ',' ​')"/>

		<!-- split text by zero-width space -->
		<xsl:variable name="text_step4">
			<xsl:call-template name="split_for_interspers">
				<xsl:with-param name="pText" select="$text_step3"/>
				<xsl:with-param name="sep" select="$zero_width_space"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:for-each select="xalan:nodeset($text_step4)/node()">
			<xsl:choose>
				<xsl:when test="local-name() = 'interspers'"> <!-- word with length more than 30 will be interspersed with zero-width space -->
					<xsl:call-template name="interspers-java">
						<xsl:with-param name="str" select="."/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>

	</xsl:template> <!-- add_spaces_to_sourcecode -->

	<xsl:variable name="interspers_tag_open">###interspers123###</xsl:variable>
	<xsl:variable name="interspers_tag_close">###/interspers123###</xsl:variable>
	<!-- split string by separator for interspers -->
	<xsl:template name="split_for_interspers">
		<xsl:param name="pText" select="."/>
		<xsl:param name="sep" select="','"/>
		<!-- word with length more than 30 will be interspersed with zero-width space -->
		<xsl:variable name="regex" select="concat('([^', $zero_width_space, ']{31,})')"/> <!-- sequence of characters (more 31), that doesn't contains zero-width space -->
		<xsl:variable name="text" select="java:replaceAll(java:java.lang.String.new($pText),$regex,concat($interspers_tag_open,'$1',$interspers_tag_close))"/>
		<xsl:call-template name="replace_tag_interspers">
			<xsl:with-param name="text" select="$text"/>
		</xsl:call-template>
	</xsl:template> <!-- end: split string by separator for interspers -->

	<xsl:template name="replace_tag_interspers">
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="contains($text, $interspers_tag_open)">
				<xsl:value-of select="substring-before($text, $interspers_tag_open)"/>
				<xsl:variable name="text_after" select="substring-after($text, $interspers_tag_open)"/>
				<interspers>
					<xsl:value-of select="substring-before($text_after, $interspers_tag_close)"/>
				</interspers>
				<xsl:call-template name="replace_tag_interspers">
					<xsl:with-param name="text" select="substring-after($text_after, $interspers_tag_close)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- insert 'char' between each character in the string -->
	<xsl:template name="interspers">
		<xsl:param name="str"/>
		<xsl:param name="char" select="$zero_width_space"/>
		<xsl:if test="$str != ''">
			<xsl:value-of select="substring($str, 1, 1)"/>

			<xsl:variable name="next_char" select="substring($str, 2, 1)"/>
			<xsl:if test="not(contains(concat(' -.:=_— ', $char), $next_char))">
				<xsl:value-of select="$char"/>
			</xsl:if>

			<xsl:call-template name="interspers">
				<xsl:with-param name="str" select="substring($str, 2)"/>
				<xsl:with-param name="char" select="$char"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="interspers-java">
		<xsl:param name="str"/>
		<xsl:param name="char" select="$zero_width_space"/>
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new($str),'([^ -.:=_—])',concat('$1', $char))"/> <!-- insert $char after each char excep space, - . : = _ etc. -->
	</xsl:template>

	<xsl:template match="*" mode="syntax_highlight">
		<xsl:apply-templates mode="syntax_highlight"/>
	</xsl:template>

	<xsl:variable name="syntax_highlight_styles_">
		<style class="hljs-addition" xsl:use-attribute-sets="hljs-addition"/>
		<style class="hljs-attr" xsl:use-attribute-sets="hljs-attr"/>
		<style class="hljs-attribute" xsl:use-attribute-sets="hljs-attribute"/>
		<style class="hljs-built_in" xsl:use-attribute-sets="hljs-built_in"/>
		<style class="hljs-bullet" xsl:use-attribute-sets="hljs-bullet"/>
		<style class="hljs-char_and_escape_" xsl:use-attribute-sets="hljs-char_and_escape_"/>
		<style class="hljs-code" xsl:use-attribute-sets="hljs-code"/>
		<style class="hljs-comment" xsl:use-attribute-sets="hljs-comment"/>
		<style class="hljs-deletion" xsl:use-attribute-sets="hljs-deletion"/>
		<style class="hljs-doctag" xsl:use-attribute-sets="hljs-doctag"/>
		<style class="hljs-emphasis" xsl:use-attribute-sets="hljs-emphasis"/>
		<style class="hljs-formula" xsl:use-attribute-sets="hljs-formula"/>
		<style class="hljs-keyword" xsl:use-attribute-sets="hljs-keyword"/>
		<style class="hljs-link" xsl:use-attribute-sets="hljs-link"/>
		<style class="hljs-literal" xsl:use-attribute-sets="hljs-literal"/>
		<style class="hljs-meta" xsl:use-attribute-sets="hljs-meta"/>
		<style class="hljs-meta_hljs-string" xsl:use-attribute-sets="hljs-meta_hljs-string"/>
		<style class="hljs-meta_hljs-keyword" xsl:use-attribute-sets="hljs-meta_hljs-keyword"/>
		<style class="hljs-name" xsl:use-attribute-sets="hljs-name"/>
		<style class="hljs-number" xsl:use-attribute-sets="hljs-number"/>
		<style class="hljs-operator" xsl:use-attribute-sets="hljs-operator"/>
		<style class="hljs-params" xsl:use-attribute-sets="hljs-params"/>
		<style class="hljs-property" xsl:use-attribute-sets="hljs-property"/>
		<style class="hljs-punctuation" xsl:use-attribute-sets="hljs-punctuation"/>
		<style class="hljs-quote" xsl:use-attribute-sets="hljs-quote"/>
		<style class="hljs-regexp" xsl:use-attribute-sets="hljs-regexp"/>
		<style class="hljs-section" xsl:use-attribute-sets="hljs-section"/>
		<style class="hljs-selector-attr" xsl:use-attribute-sets="hljs-selector-attr"/>
		<style class="hljs-selector-class" xsl:use-attribute-sets="hljs-selector-class"/>
		<style class="hljs-selector-id" xsl:use-attribute-sets="hljs-selector-id"/>
		<style class="hljs-selector-pseudo" xsl:use-attribute-sets="hljs-selector-pseudo"/>
		<style class="hljs-selector-tag" xsl:use-attribute-sets="hljs-selector-tag"/>
		<style class="hljs-string" xsl:use-attribute-sets="hljs-string"/>
		<style class="hljs-strong" xsl:use-attribute-sets="hljs-strong"/>
		<style class="hljs-subst" xsl:use-attribute-sets="hljs-subst"/>
		<style class="hljs-symbol" xsl:use-attribute-sets="hljs-symbol"/>
		<style class="hljs-tag" xsl:use-attribute-sets="hljs-tag"/>
		<!-- <style class="hljs-tag_hljs-attr" xsl:use-attribute-sets="hljs-tag_hljs-attr"></style> -->
		<!-- <style class="hljs-tag_hljs-name" xsl:use-attribute-sets="hljs-tag_hljs-name"></style> -->
		<style class="hljs-template-tag" xsl:use-attribute-sets="hljs-template-tag"/>
		<style class="hljs-template-variable" xsl:use-attribute-sets="hljs-template-variable"/>
		<style class="hljs-title" xsl:use-attribute-sets="hljs-title"/>
		<style class="hljs-title_and_class_" xsl:use-attribute-sets="hljs-title_and_class_"/>
		<style class="hljs-title_and_class__and_inherited__" xsl:use-attribute-sets="hljs-title_and_class__and_inherited__"/>
		<style class="hljs-title_and_function_" xsl:use-attribute-sets="hljs-title_and_function_"/>
		<style class="hljs-type" xsl:use-attribute-sets="hljs-type"/>
		<style class="hljs-variable" xsl:use-attribute-sets="hljs-variable"/>
		<style class="hljs-variable_and_language_" xsl:use-attribute-sets="hljs-variable_and_language_"/>
	</xsl:variable>
	<xsl:variable name="syntax_highlight_styles" select="xalan:nodeset($syntax_highlight_styles_)"/>

	<xsl:template match="span" mode="syntax_highlight" priority="2">
		<!-- <fo:inline color="green" font-style="italic"><xsl:apply-templates mode="syntax_highlight"/></fo:inline> -->
		<fo:inline>
			<xsl:variable name="classes_">
				<xsl:call-template name="split">
					<xsl:with-param name="pText" select="@class"/>
					<xsl:with-param name="sep" select="' '"/>
				</xsl:call-template>
				<!-- a few classes together (_and_ suffix) -->
				<xsl:if test="contains(@class, 'hljs-char') and contains(@class, 'escape_')">
					<item>hljs-char_and_escape_</item>
				</xsl:if>
				<xsl:if test="contains(@class, 'hljs-title') and contains(@class, 'class_')">
					<item>hljs-title_and_class_</item>
				</xsl:if>
				<xsl:if test="contains(@class, 'hljs-title') and contains(@class, 'class_') and contains(@class, 'inherited__')">
					<item>hljs-title_and_class__and_inherited__</item>
				</xsl:if>
				<xsl:if test="contains(@class, 'hljs-title') and contains(@class, 'function_')">
					<item>hljs-title_and_function_</item>
				</xsl:if>
				<xsl:if test="contains(@class, 'hljs-variable') and contains(@class, 'language_')">
					<item>hljs-variable_and_language_</item>
				</xsl:if>
				<!-- with parent classes (_ suffix) -->
				<xsl:if test="contains(@class, 'hljs-keyword') and contains(ancestor::*/@class, 'hljs-meta')">
					<item>hljs-meta_hljs-keyword</item>
				</xsl:if>
				<xsl:if test="contains(@class, 'hljs-string') and contains(ancestor::*/@class, 'hljs-meta')">
					<item>hljs-meta_hljs-string</item>
				</xsl:if>
			</xsl:variable>
			<xsl:variable name="classes" select="xalan:nodeset($classes_)"/>

			<xsl:for-each select="$classes/item">
				<xsl:variable name="class_name" select="."/>
				<xsl:for-each select="$syntax_highlight_styles/style[@class = $class_name]/@*[not(local-name() = 'class')]">
					<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
				</xsl:for-each>
			</xsl:for-each>

			<!-- <xsl:variable name="class_name">
				<xsl:choose>
					<xsl:when test="@class = 'hljs-attr' and ancestor::*/@class = 'hljs-tag'">hljs-tag_hljs-attr</xsl:when>
					<xsl:when test="@class = 'hljs-name' and ancestor::*/@class = 'hljs-tag'">hljs-tag_hljs-name</xsl:when>
					<xsl:when test="@class = 'hljs-string' and ancestor::*/@class = 'hljs-meta'">hljs-meta_hljs-string</xsl:when>
					<xsl:otherwise><xsl:value-of select="@class"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:for-each select="$syntax_highlight_styles/style[@class = $class_name]/@*[not(local-name() = 'class')]">
				<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
			</xsl:for-each> -->

		<xsl:apply-templates mode="syntax_highlight"/></fo:inline>
	</xsl:template>

	<xsl:template match="text()" mode="syntax_highlight" priority="2">
		<xsl:call-template name="add_spaces_to_sourcecode"/>
	</xsl:template>

	<!-- end mode="syntax_highlight" -->

	<xsl:template match="*[local-name() = 'sourcecode']/*[local-name() = 'name']">
		<xsl:if test="normalize-space() != ''">
			<fo:block xsl:use-attribute-sets="sourcecode-name-style">
				<xsl:apply-templates/>
			</fo:block>
		</xsl:if>
	</xsl:template>
	<!-- =============== -->
	<!-- END sourcecode  -->
	<!-- =============== -->

	<!-- =============== -->
	<!-- pre  -->
	<!-- =============== -->
	<xsl:template match="*[local-name()='pre']" name="pre">
		<fo:block xsl:use-attribute-sets="pre-style">
			<xsl:copy-of select="@id"/>
			<xsl:choose>

				<xsl:when test="ancestor::*[local-name() = 'sourcecode'][@linenums = 'true'] and ancestor::*[local-name()='td'][1][not(preceding-sibling::*)]"> <!-- pre in the first td in the table with @linenums = 'true' -->
					<xsl:if test="ancestor::*[local-name() = 'tr'][1]/following-sibling::*[local-name() = 'tr']"> <!-- is current tr isn't last -->
						<xsl:attribute name="margin-top">0pt</xsl:attribute>
						<xsl:attribute name="margin-bottom">0pt</xsl:attribute>
					</xsl:if>
					<fo:instream-foreign-object fox:alt-text="{.}" content-width="95%">
						<math xmlns="http://www.w3.org/1998/Math/MathML">
							<mtext><xsl:value-of select="."/></mtext>
						</math>
					</fo:instream-foreign-object>
				</xsl:when>

				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>

			</xsl:choose>
		</fo:block>
	</xsl:template>
	<!-- =============== -->
	<!-- pre  -->
	<!-- =============== -->

	<!-- ========== -->
	<!-- permission -->
	<!-- ========== -->
	<xsl:template match="*[local-name() = 'permission']">
		<fo:block id="{@id}" xsl:use-attribute-sets="permission-style">
			<xsl:apply-templates select="*[local-name()='name']"/>
			<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'permission']/*[local-name() = 'name']">
		<xsl:if test="normalize-space() != ''">
			<fo:block xsl:use-attribute-sets="permission-name-style">
				<xsl:apply-templates/>

			</fo:block>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'permission']/*[local-name() = 'label']">
		<fo:block xsl:use-attribute-sets="permission-label-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<!-- ========== -->
	<!-- ========== -->

	<!-- ========== -->
	<!-- requirement -->
<!-- ========== -->
	<xsl:template match="*[local-name() = 'requirement']">
		<fo:block id="{@id}" xsl:use-attribute-sets="requirement-style">
			<xsl:apply-templates select="*[local-name()='name']"/>
			<xsl:apply-templates select="*[local-name()='label']"/>
			<xsl:apply-templates select="@obligation"/>
			<xsl:apply-templates select="*[local-name()='subject']"/>
			<xsl:apply-templates select="node()[not(local-name() = 'name') and not(local-name() = 'label') and not(local-name() = 'subject')]"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'name']">
		<xsl:if test="normalize-space() != ''">
			<fo:block xsl:use-attribute-sets="requirement-name-style">

				<xsl:apply-templates/>

			</fo:block>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'label']">
		<fo:block xsl:use-attribute-sets="requirement-label-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'requirement']/@obligation">
			<fo:block>
				<fo:inline padding-right="3mm">Obligation</fo:inline><xsl:value-of select="."/>
			</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'subject']" priority="2">
		<fo:block xsl:use-attribute-sets="subject-style">
			<xsl:text>Target Type </xsl:text><xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<!-- ========== -->
	<!-- ========== -->

	<!-- ========== -->
	<!-- recommendation -->
	<!-- ========== -->
	<xsl:template match="*[local-name() = 'recommendation']">
		<fo:block id="{@id}" xsl:use-attribute-sets="recommendation-style">
			<xsl:apply-templates select="*[local-name()='name']"/>
			<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'recommendation']/*[local-name() = 'name']">
		<xsl:if test="normalize-space() != ''">
			<fo:block xsl:use-attribute-sets="recommendation-name-style">
				<xsl:apply-templates/>

			</fo:block>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'recommendation']/*[local-name() = 'label']">
		<fo:block xsl:use-attribute-sets="recommendation-label-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<!-- ========== -->
	<!-- END recommendation -->
	<!-- ========== -->

	<!-- ========== -->
	<!-- ========== -->

	<xsl:template match="*[local-name() = 'subject']">
		<fo:block xsl:use-attribute-sets="subject-style">
			<xsl:text>Target Type </xsl:text><xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'div']">
		<fo:block><xsl:apply-templates/></fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'inherit'] | *[local-name() = 'component'][@class = 'inherit'] |           *[local-name() = 'div'][@type = 'requirement-inherit'] |           *[local-name() = 'div'][@type = 'recommendation-inherit'] |           *[local-name() = 'div'][@type = 'permission-inherit']">
		<fo:block xsl:use-attribute-sets="inherit-style">
			<xsl:text>Dependency </xsl:text><xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'description'] | *[local-name() = 'component'][@class = 'description'] |           *[local-name() = 'div'][@type = 'requirement-description'] |           *[local-name() = 'div'][@type = 'recommendation-description'] |           *[local-name() = 'div'][@type = 'permission-description']">
		<fo:block xsl:use-attribute-sets="description-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'specification'] | *[local-name() = 'component'][@class = 'specification'] |           *[local-name() = 'div'][@type = 'requirement-specification'] |           *[local-name() = 'div'][@type = 'recommendation-specification'] |           *[local-name() = 'div'][@type = 'permission-specification']">
		<fo:block xsl:use-attribute-sets="specification-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'measurement-target'] | *[local-name() = 'component'][@class = 'measurement-target'] |           *[local-name() = 'div'][@type = 'requirement-measurement-target'] |           *[local-name() = 'div'][@type = 'recommendation-measurement-target'] |           *[local-name() = 'div'][@type = 'permission-measurement-target']">
		<fo:block xsl:use-attribute-sets="measurement-target-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'verification'] | *[local-name() = 'component'][@class = 'verification'] |           *[local-name() = 'div'][@type = 'requirement-verification'] |           *[local-name() = 'div'][@type = 'recommendation-verification'] |           *[local-name() = 'div'][@type = 'permission-verification']">
		<fo:block xsl:use-attribute-sets="verification-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'import'] | *[local-name() = 'component'][@class = 'import'] |           *[local-name() = 'div'][@type = 'requirement-import'] |           *[local-name() = 'div'][@type = 'recommendation-import'] |           *[local-name() = 'div'][@type = 'permission-import']">
		<fo:block xsl:use-attribute-sets="import-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'div'][starts-with(@type, 'requirement-component')] |           *[local-name() = 'div'][starts-with(@type, 'recommendation-component')] |           *[local-name() = 'div'][starts-with(@type, 'permission-component')]">
		<fo:block xsl:use-attribute-sets="component-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<!-- ========== -->
	<!-- END  -->
	<!-- ========== -->

	<!-- ========== -->
	<!-- requirement, recommendation, permission table -->
	<!-- ========== -->
	<xsl:template match="*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']">
		<fo:block-container margin-left="0mm" margin-right="0mm" margin-bottom="12pt" role="SKIP">
			<xsl:if test="ancestor::*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']">
				<xsl:attribute name="margin-bottom">0pt</xsl:attribute>
			</xsl:if>
			<fo:block-container margin-left="0mm" margin-right="0mm" role="SKIP">
				<fo:table id="{@id}" table-layout="fixed" width="100%"> <!-- border="1pt solid black" -->
					<xsl:if test="ancestor::*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']">
						<!-- <xsl:attribute name="border">0.5pt solid black</xsl:attribute> -->
					</xsl:if>
					<xsl:variable name="simple-table">
						<xsl:call-template name="getSimpleTable">
							<xsl:with-param name="id" select="@id"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="cols-count" select="count(xalan:nodeset($simple-table)//tr[1]/td)"/>
					<xsl:if test="$cols-count = 2 and not(ancestor::*[local-name()='table'])">
						<fo:table-column column-width="30%"/>
						<fo:table-column column-width="70%"/>
					</xsl:if>
					<xsl:apply-templates mode="requirement"/>
				</fo:table>
				<!-- fn processing -->
				<xsl:if test=".//*[local-name() = 'fn']">
					<xsl:for-each select="*[local-name() = 'tbody']">
						<fo:block font-size="90%" border-bottom="1pt solid black">
							<xsl:call-template name="table_fn_display"/>
						</fo:block>
					</xsl:for-each>
				</xsl:if>
			</fo:block-container>
		</fo:block-container>
	</xsl:template>

	<xsl:template match="*[local-name()='thead']" mode="requirement">
		<fo:table-header>
			<xsl:apply-templates mode="requirement"/>
		</fo:table-header>
	</xsl:template>

	<xsl:template match="*[local-name()='tbody']" mode="requirement">
		<fo:table-body>
			<xsl:apply-templates mode="requirement"/>
		</fo:table-body>
	</xsl:template>

	<xsl:template match="*[local-name()='tr']" mode="requirement">
		<fo:table-row height="7mm" border-bottom="0.5pt solid grey">

			<xsl:if test="parent::*[local-name()='thead'] or starts-with(*[local-name()='td' or local-name()='th'][1], 'Requirement ') or starts-with(*[local-name()='td' or local-name()='th'][1], 'Recommendation ')">
				<xsl:attribute name="font-weight">bold</xsl:attribute>

			</xsl:if>

			<xsl:apply-templates mode="requirement"/>
		</fo:table-row>
	</xsl:template>

	<xsl:template match="*[local-name()='th']" mode="requirement">
		<fo:table-cell text-align="{@align}" display-align="center" padding="1mm" padding-left="2mm"> <!-- border="0.5pt solid black" -->
			<xsl:call-template name="setTextAlignment">
				<xsl:with-param name="default">left</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="setTableCellAttributes"/>

			<fo:block role="SKIP">
				<xsl:apply-templates/>
			</fo:block>
		</fo:table-cell>
	</xsl:template>

	<xsl:template match="*[local-name()='td']" mode="requirement">
		<fo:table-cell text-align="{@align}" display-align="center" padding="1mm" padding-left="2mm"> <!-- border="0.5pt solid black" -->
			<xsl:if test="*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']">
				<xsl:attribute name="padding">0mm</xsl:attribute>
				<xsl:attribute name="padding-left">0mm</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="setTextAlignment">
				<xsl:with-param name="default">left</xsl:with-param>
			</xsl:call-template>

			<xsl:if test="following-sibling::*[local-name()='td'] and not(preceding-sibling::*[local-name()='td'])">
				<xsl:attribute name="font-weight">bold</xsl:attribute>
			</xsl:if>

			<xsl:call-template name="setTableCellAttributes"/>

			<fo:block role="SKIP">
				<xsl:apply-templates/>
			</fo:block>
		</fo:table-cell>
	</xsl:template>

	<xsl:template match="*[local-name() = 'p'][@class='RecommendationTitle' or @class = 'RecommendationTestTitle']" priority="2">
		<fo:block font-size="11pt">

			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'p2'][ancestor::*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']]">
		<fo:block>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<!-- ========== -->
	<!-- END requirement, recommendation, permission table -->
	<!-- ========== -->

	<!-- ====== -->
	<!-- termexample -->
	<!-- ====== -->
	<xsl:template match="*[local-name() = 'termexample']">
		<fo:block id="{@id}" xsl:use-attribute-sets="termexample-style">
			<xsl:call-template name="refine_termexample-style"/>
			<xsl:call-template name="setBlockSpanAll"/>

			<xsl:apply-templates select="*[local-name()='name']"/>
			<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'termexample']/*[local-name() = 'name']">
		<xsl:if test="normalize-space() != ''">
			<fo:inline xsl:use-attribute-sets="termexample-name-style">
				<xsl:call-template name="refine_termexample-name-style"/>
				<xsl:apply-templates/> <!-- commented $namespace = 'ieee', https://github.com/metanorma/isodoc/issues/614-->
			</fo:inline>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'termexample']/*[local-name() = 'p']">
		<xsl:variable name="element">inline


		</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($element, 'block')">
				<fo:block xsl:use-attribute-sets="example-p-style">

					<xsl:apply-templates/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline><xsl:apply-templates/></fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ====== -->
	<!-- ====== -->

	<!-- ====== -->
	<!-- example -->
	<!-- ====== -->

	<!-- There are a few cases:
	1. EXAMPLE text
	2. EXAMPLE
	        text
	3. EXAMPLE text line 1
	     text line 2
	4. EXAMPLE
	     text line 1
			 text line 2
	-->
	<xsl:template match="*[local-name() = 'example']" name="example">

				<fo:block id="{@id}" xsl:use-attribute-sets="example-style" role="SKIP">
					<xsl:call-template name="setBlockSpanAll"/>

					<xsl:call-template name="refine_example-style"/>

					<xsl:variable name="ol_adjust">
						<xsl:choose>
							<xsl:when test="$vertical_layout = 'true' and ancestor::*[local-name() = 'ol']/@provisional-distance-between-starts">
								<xsl:value-of select="number(translate(ancestor::*[local-name() = 'ol']/@provisional-distance-between-starts, 'mm', ''))"/>
							</xsl:when>
							<xsl:otherwise>0</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="provisional_distance_between_starts_">
						<xsl:value-of select="10 + $text_indent - $ol_adjust"/>
					</xsl:variable>
					<xsl:variable name="provisional_distance_between_starts" select="normalize-space($provisional_distance_between_starts_)"/>
					<xsl:variable name="indent_">
						<xsl:value-of select="$text_indent"/>
					</xsl:variable>
					<xsl:variable name="indent" select="normalize-space($indent_)"/>

					<fo:list-block provisional-distance-between-starts="{$provisional_distance_between_starts}mm">
						<xsl:if test="$vertical_layout = 'true'">
							<xsl:attribute name="provisional-distance-between-starts"><xsl:value-of select="$provisional_distance_between_starts + 2"/>mm</xsl:attribute>
						</xsl:if>
						<fo:list-item>
							<fo:list-item-label start-indent="{$indent}mm" end-indent="label-end()">
								<xsl:if test="$vertical_layout = 'true'">
									<xsl:attribute name="start-indent">0mm</xsl:attribute>
								</xsl:if>
								<fo:block>
									<xsl:apply-templates select="*[local-name()='name']">
										<xsl:with-param name="fo_element">block</xsl:with-param>
									</xsl:apply-templates>
								</fo:block>
							</fo:list-item-label>
							<fo:list-item-body start-indent="body-start()">
								<fo:block>
									<xsl:apply-templates select="node()[not(local-name() = 'name')]">
										<xsl:with-param name="fo_element" select="'list'"/>
									</xsl:apply-templates>
								</fo:block>
							</fo:list-item-body>
						</fo:list-item>
					</fo:list-block>

				</fo:block>

	</xsl:template>

	<!-- example/name -->
	<xsl:template match="*[local-name() = 'example']/*[local-name() = 'name']">
		<xsl:param name="fo_element">block</xsl:param>

		<xsl:choose>
			<xsl:when test="ancestor::*[local-name() = 'appendix']">
				<fo:inline>
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:when>
			<xsl:when test="contains(normalize-space($fo_element), 'block')">
				<fo:block xsl:use-attribute-sets="example-name-style">

						<xsl:call-template name="refine_example-name-style"/>

					<xsl:apply-templates/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline xsl:use-attribute-sets="example-name-style">
					<xsl:call-template name="refine_example-name-style"/>
					<xsl:apply-templates/> <!-- $namespace = 'ieee', see https://github.com/metanorma/isodoc/issues/614  -->
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<!-- table/example/name, table/tfoot//example/name -->
	<xsl:template match="*[local-name() = 'table']/*[local-name() = 'example']/*[local-name() = 'name'] |  *[local-name() = 'table']/*[local-name() = 'tfoot']//*[local-name() = 'example']/*[local-name() = 'name']">
		<fo:inline xsl:use-attribute-sets="example-name-style">

				<xsl:if test="not($vertical_layout = 'true')">
					<xsl:attribute name="font-family">IPAexGothic</xsl:attribute>
				</xsl:if>

			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<xsl:template match="*[local-name() = 'example']/*[local-name() = 'p']">
		<xsl:param name="fo_element">block</xsl:param>

		<xsl:variable name="num"><xsl:number/></xsl:variable>
		<xsl:variable name="element">

			<xsl:value-of select="$fo_element"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="starts-with(normalize-space($element), 'block')">
				<fo:block-container role="SKIP">
					<xsl:if test="ancestor::*[local-name() = 'li'] and contains(normalize-space($fo_element), 'block')">
						<xsl:attribute name="margin-left">0mm</xsl:attribute>
						<xsl:attribute name="margin-right">0mm</xsl:attribute>
					</xsl:if>
					<fo:block xsl:use-attribute-sets="example-p-style">

						<xsl:call-template name="refine_example-p-style"/>

						<xsl:apply-templates/>
					</fo:block>
				</fo:block-container>
			</xsl:when>
			<xsl:when test="starts-with(normalize-space($element), 'list')">
				<fo:block xsl:use-attribute-sets="example-p-style">
					<xsl:apply-templates/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline xsl:use-attribute-sets="example-p-style">
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template> <!-- example/p -->

	<!-- ====== -->
	<!-- ====== -->

	<!-- ====== -->
	<!-- termsource -->
	<!-- origin -->
	<!-- modification -->
	<!-- ====== -->
	<xsl:template match="*[local-name() = 'termsource']" name="termsource">
		<fo:block xsl:use-attribute-sets="termsource-style">

			<xsl:call-template name="refine_termsource-style"/>

			<!-- Example: [SOURCE: ISO 5127:2017, 3.1.6.02] -->
			<xsl:variable name="termsource_text">
				<xsl:apply-templates/>
			</xsl:variable>
			<xsl:copy-of select="$termsource_text"/>
			<!-- <xsl:choose>
				<xsl:when test="starts-with(normalize-space($termsource_text), '[')">
					<xsl:copy-of select="$termsource_text"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="$namespace = 'bsi'">
						<xsl:choose>
							<xsl:when test="$document_type = 'PAS' and starts-with(*[local-name() = 'origin']/@citeas, '[')"><xsl:text>{</xsl:text></xsl:when>
							<xsl:otherwise><xsl:text>[</xsl:text></xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="$namespace = 'gb' or $namespace = 'iso' or $namespace = 'iec' or $namespace = 'itu' or $namespace = 'unece' or $namespace = 'unece-rec' or $namespace = 'nist-cswp'  or $namespace = 'nist-sp' or $namespace = 'ogc-white-paper' or $namespace = 'csa' or $namespace = 'csd' or $namespace = 'm3d' or $namespace = 'iho' or $namespace = 'bipm' or $namespace = 'jcgm'">
						<xsl:text>[</xsl:text>
					</xsl:if>
					<xsl:copy-of select="$termsource_text"/>
					<xsl:if test="$namespace = 'bsi'">
						<xsl:choose>
							<xsl:when test="$document_type = 'PAS' and starts-with(*[local-name() = 'origin']/@citeas, '[')"><xsl:text>}</xsl:text></xsl:when>
							<xsl:otherwise><xsl:text>]</xsl:text></xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="$namespace = 'gb' or $namespace = 'iso' or $namespace = 'iec' or $namespace = 'itu' or $namespace = 'unece' or $namespace = 'unece-rec' or $namespace = 'nist-cswp'  or $namespace = 'nist-sp' or $namespace = 'ogc-white-paper' or $namespace = 'csa' or $namespace = 'csd' or $namespace = 'm3d' or $namespace = 'iho' or $namespace = 'bipm' or $namespace = 'jcgm'">
						<xsl:text>]</xsl:text>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose> -->
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'termsource']/text()[starts-with(., '[SOURCE: Adapted from: ') or     starts-with(., '[SOURCE: Quoted from: ') or     starts-with(., '[SOURCE: Modified from: ')]" priority="2">
		<xsl:text>[</xsl:text><xsl:value-of select="substring-after(., '[SOURCE: ')"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'termsource']/text()">
		<xsl:if test="normalize-space() != ''">
			<xsl:value-of select="."/>
		</xsl:if>
	</xsl:template>

	<!-- text SOURCE: -->
	<xsl:template match="*[local-name() = 'termsource']/*[local-name() = 'strong'][1][following-sibling::*[1][local-name() = 'origin']]/text()">
		<fo:inline xsl:use-attribute-sets="termsource-text-style">
			<xsl:value-of select="."/>
		</fo:inline>
	</xsl:template>

	<xsl:template match="*[local-name() = 'origin']">
		<xsl:call-template name="insert_basic_link">
			<xsl:with-param name="element">
				<fo:basic-link internal-destination="{@bibitemid}" fox:alt-text="{@citeas}">
					<xsl:if test="normalize-space(@citeas) = ''">
						<xsl:attribute name="fox:alt-text"><xsl:value-of select="@bibitemid"/></xsl:attribute>
					</xsl:if>
					<fo:inline xsl:use-attribute-sets="origin-style">
						<xsl:apply-templates/>
					</fo:inline>
				</fo:basic-link>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- not using, see https://github.com/glossarist/iev-document/issues/23 -->
	<xsl:template match="*[local-name() = 'modification']">
		<xsl:variable name="title-modified">
			<xsl:call-template name="getLocalizedString">
				<xsl:with-param name="key">modified</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

    <xsl:variable name="text"><xsl:apply-templates/></xsl:variable>
		<xsl:choose>
			<xsl:when test="$lang = 'zh'"><xsl:text>、</xsl:text><xsl:value-of select="$title-modified"/><xsl:if test="normalize-space($text) != ''"><xsl:text>—</xsl:text></xsl:if></xsl:when>
			<xsl:otherwise><xsl:text>, </xsl:text><xsl:value-of select="$title-modified"/><xsl:if test="normalize-space($text) != ''"><xsl:text> — </xsl:text></xsl:if></xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'modification']/*[local-name() = 'p']">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template>

	<xsl:template match="*[local-name() = 'modification']/text()">
		<xsl:if test="normalize-space() != ''">
			<!-- <xsl:value-of select="."/> -->
			<xsl:call-template name="text"/>
		</xsl:if>
	</xsl:template>

	<!-- ====== -->
	<!-- ====== -->

	<!-- ====== -->
	<!-- qoute -->
	<!-- source -->
	<!-- author  -->
	<!-- ====== -->
	<xsl:template match="*[local-name() = 'quote']">
		<fo:block-container margin-left="0mm" role="SKIP">

			<xsl:call-template name="setBlockSpanAll"/>

			<xsl:if test="parent::*[local-name() = 'note']">
				<xsl:if test="not(ancestor::*[local-name() = 'table'])">
					<xsl:attribute name="margin-left">5mm</xsl:attribute>
				</xsl:if>
			</xsl:if>

			<fo:block-container margin-left="0mm" role="SKIP">
				<fo:block-container xsl:use-attribute-sets="quote-style" role="SKIP">

					<xsl:call-template name="refine_quote-style"/>

					<fo:block-container margin-left="0mm" margin-right="0mm" role="SKIP">
						<fo:block role="BlockQuote">
							<xsl:apply-templates select="./node()[not(local-name() = 'author') and         not(local-name() = 'source') and         not(local-name() = 'attribution')]"/> <!-- process all nested nodes, except author and source -->
						</fo:block>
					</fo:block-container>
				</fo:block-container>
				<xsl:if test="*[local-name() = 'author'] or *[local-name() = 'source'] or *[local-name() = 'attribution']">
					<fo:block xsl:use-attribute-sets="quote-source-style">
						<!-- — ISO, ISO 7301:2011, Clause 1 -->
						<xsl:apply-templates select="*[local-name() = 'author']"/>
						<xsl:apply-templates select="*[local-name() = 'source']"/>
						<!-- added for https://github.com/metanorma/isodoc/issues/607 -->
						<xsl:apply-templates select="*[local-name() = 'attribution']/*[local-name() = 'p']/node()"/>
					</fo:block>
				</xsl:if>

					<!-- render footnotes after references -->
					<xsl:apply-templates select=".//jis:fn[generate-id(.)=generate-id(key('kfn',@reference)[1])]" mode="fn_after_element">
						<xsl:with-param name="ancestor">quote</xsl:with-param>
					</xsl:apply-templates>

			</fo:block-container>
		</fo:block-container>
	</xsl:template>

	<xsl:template match="*[local-name() = 'source']">
		<xsl:if test="../*[local-name() = 'author']">
			<xsl:text>, </xsl:text>
		</xsl:if>
		<xsl:call-template name="insert_basic_link">
			<xsl:with-param name="element">
				<fo:basic-link internal-destination="{@bibitemid}" fox:alt-text="{@citeas}">
					<xsl:apply-templates/>
				</fo:basic-link>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="*[local-name() = 'author']">
		<xsl:if test="local-name(..) = 'quote'"> <!-- for old Presentation XML, https://github.com/metanorma/isodoc/issues/607 -->
			<xsl:text>— </xsl:text>
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'quote']//*[local-name() = 'referenceFrom']"/>
	<!-- ====== -->
	<!-- ====== -->

	<xsl:variable name="bibitems_">
		<xsl:for-each select="//*[local-name() = 'bibitem']">
			<xsl:copy-of select="."/>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="bibitems" select="xalan:nodeset($bibitems_)"/>

	<!-- get all hidden bibitems to exclude them from eref/origin processing -->
	<xsl:variable name="bibitems_hidden_">
		<xsl:for-each select="//*[local-name() = 'bibitem'][@hidden='true']">
			<xsl:copy-of select="."/>
		</xsl:for-each>
		<xsl:for-each select="//*[local-name() = 'references'][@hidden='true']//*[local-name() = 'bibitem']">
			<xsl:copy-of select="."/>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="bibitems_hidden" select="xalan:nodeset($bibitems_hidden_)"/>
	<!-- ====== -->
	<!-- eref -->
	<!-- ====== -->
	<xsl:template match="*[local-name() = 'eref']" name="eref">
		<xsl:variable name="current_bibitemid" select="@bibitemid"/>
		<!-- <xsl:variable name="external-destination" select="normalize-space(key('bibitems', $current_bibitemid)/*[local-name() = 'uri'][@type = 'citation'])"/> -->
		<xsl:variable name="external-destination" select="normalize-space($bibitems/*[local-name() ='bibitem'][@id = $current_bibitemid]/*[local-name() = 'uri'][@type = 'citation'])"/>
		<xsl:choose>
			<!-- <xsl:when test="$external-destination != '' or not(key('bibitems_hidden', $current_bibitemid))"> --> <!-- if in the bibliography there is the item with @bibitemid (and not hidden), then create link (internal to the bibitem or external) -->
			<xsl:when test="$external-destination != '' or not($bibitems_hidden/*[local-name() ='bibitem'][@id = $current_bibitemid])"> <!-- if in the bibliography there is the item with @bibitemid (and not hidden), then create link (internal to the bibitem or external) -->
				<fo:inline xsl:use-attribute-sets="eref-style">
					<xsl:if test="@type = 'footnote'">
						<xsl:attribute name="keep-together.within-line">always</xsl:attribute>
						<xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
						<xsl:attribute name="vertical-align">super</xsl:attribute>
						<xsl:attribute name="font-size">80%</xsl:attribute>

					</xsl:if>

					<xsl:call-template name="refine_eref-style"/>

					<xsl:call-template name="insert_basic_link">
						<xsl:with-param name="element">
							<fo:basic-link fox:alt-text="{@citeas}">
								<xsl:if test="normalize-space(@citeas) = ''">
									<xsl:attribute name="fox:alt-text"><xsl:value-of select="."/></xsl:attribute>
								</xsl:if>
								<xsl:if test="@type = 'inline'">

									<xsl:call-template name="refine_basic_link_style"/>

								</xsl:if>

								<xsl:choose>
									<xsl:when test="$external-destination != ''"> <!-- external hyperlink -->
										<xsl:attribute name="external-destination"><xsl:value-of select="$external-destination"/></xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="internal-destination"><xsl:value-of select="@bibitemid"/></xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>

								<xsl:apply-templates/>
							</fo:basic-link>
						</xsl:with-param>
					</xsl:call-template>

				</fo:inline>
			</xsl:when>
			<xsl:otherwise> <!-- if there is key('bibitems_hidden', $current_bibitemid) -->

				<!-- if in bibitem[@hidden='true'] there is url[@type='src'], then create hyperlink  -->
				<xsl:variable name="uri_src" select="normalize-space($bibitems_hidden/*[local-name() ='bibitem'][@id = $current_bibitemid]/*[local-name() = 'uri'][@type = 'src'])"/>
				<xsl:choose>
					<xsl:when test="$uri_src != ''">
						<fo:basic-link external-destination="{$uri_src}" fox:alt-text="{$uri_src}"><xsl:apply-templates/></fo:basic-link>
					</xsl:when>
					<xsl:otherwise><fo:inline><xsl:apply-templates/></fo:inline></xsl:otherwise>
				</xsl:choose>

			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="refine_basic_link_style">

	</xsl:template> <!-- refine_basic_link_style -->

	<!-- ====== -->
	<!-- END eref -->
	<!-- ====== -->

	<!-- Tabulation processing -->
	<xsl:template match="*[local-name() = 'tab']">
		<!-- zero-space char -->
		<xsl:variable name="depth">
			<xsl:call-template name="getLevel">
				<xsl:with-param name="depth" select="../@depth"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="padding">

		</xsl:variable>

		<xsl:variable name="padding-right">
			<xsl:choose>
				<xsl:when test="normalize-space($padding) = ''">0</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space($padding)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$lang = 'zh'">
				<fo:inline role="SKIP"><xsl:value-of select="$tab_zh"/></fo:inline>
			</xsl:when>
			<xsl:when test="../../@inline-header = 'true'">
				<fo:inline font-size="90%" role="SKIP">
					<xsl:call-template name="insertNonBreakSpaces">
						<xsl:with-param name="count" select="$padding-right"/>
					</xsl:call-template>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="direction"><xsl:if test="$lang = 'ar'"><xsl:value-of select="$RLM"/></xsl:if></xsl:variable>
				<fo:inline padding-right="{$padding-right}mm" role="SKIP"><xsl:value-of select="$direction"/>​</fo:inline>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template> <!-- tab -->

	<xsl:template match="*[local-name() = 'note']/*[local-name() = 'name']/*[local-name() = 'tab']" priority="2"/>
	<xsl:template match="*[local-name() = 'termnote']/*[local-name() = 'name']/*[local-name() = 'tab']" priority="2"/>

	<xsl:template match="*[local-name() = 'note']/*[local-name() = 'name']/*[local-name() = 'tab']" mode="tab">

	</xsl:template>

	<xsl:template name="insertNonBreakSpaces">
		<xsl:param name="count"/>
		<xsl:if test="$count &gt; 0">
			<xsl:text> </xsl:text>
			<xsl:call-template name="insertNonBreakSpaces">
				<xsl:with-param name="count" select="$count - 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- Preferred, admitted, deprecated -->
	<xsl:template match="*[local-name() = 'preferred']">
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		<xsl:variable name="font-size">
			inherit
		</xsl:variable>
		<xsl:variable name="levelTerm">
			<xsl:call-template name="getLevelTermName"/>
		</xsl:variable>
		<fo:block font-size="{normalize-space($font-size)}" role="H{$levelTerm}" xsl:use-attribute-sets="preferred-block-style">

				<xsl:if test="$vertical_layout = 'true'">
					<xsl:attribute name="letter-spacing">1mm</xsl:attribute>
					<xsl:attribute name="margin-left">-6mm</xsl:attribute>
				</xsl:if>

			<xsl:if test="parent::*[local-name() = 'term'] and not(preceding-sibling::*[local-name() = 'preferred'])"> <!-- if first preffered in term, then display term's name -->
				<fo:block xsl:use-attribute-sets="term-name-style" role="SKIP">

						<xsl:if test="not($vertical_layout = 'true')">
							<xsl:attribute name="font-family">Times New Roman</xsl:attribute>
						</xsl:if>

					<xsl:apply-templates select="ancestor::*[local-name() = 'term'][1]/*[local-name() = 'name']"/>
				</fo:block>
			</xsl:if>

			<fo:block xsl:use-attribute-sets="preferred-term-style" role="SKIP">
				<xsl:call-template name="setStyle_preferred"/>

					<xsl:if test="$vertical_layout = 'true'">
						<xsl:attribute name="margin-left">6mm</xsl:attribute>
						<xsl:attribute name="font-family">Noto Sans JP</xsl:attribute>
						<xsl:attribute name="font-weight">bold</xsl:attribute>
					</xsl:if>
					<xsl:if test="not($vertical_layout = 'true')">
						<xsl:attribute name="font-family">IPAexGothic</xsl:attribute>
					</xsl:if>

				<xsl:apply-templates/>
			</fo:block>
		</fo:block>
	</xsl:template>

	<!-- <xsl:template match="*[local-name() = 'domain']"> -->
		<!-- https://github.com/metanorma/isodoc/issues/607 
		<fo:inline xsl:use-attribute-sets="domain-style">&lt;<xsl:apply-templates/>&gt;</fo:inline>
		<xsl:text> </xsl:text> -->
		<!-- <xsl:if test="not(@hidden = 'true')">
			<xsl:apply-templates/>
		</xsl:if>
	</xsl:template> -->

	<!-- https://github.com/metanorma/isodoc/issues/632#issuecomment-2567163931 -->
	<xsl:template match="*[local-name() = 'domain']"/>

	<xsl:template match="*[local-name() = 'admitted']">
		<fo:block xsl:use-attribute-sets="admitted-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'deprecates']">
		<fo:block xsl:use-attribute-sets="deprecates-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template name="setStyle_preferred">

				<xsl:if test="*[local-name() = 'strong']">
					<xsl:attribute name="font-weight">normal</xsl:attribute>
				</xsl:if>

	</xsl:template>

	<!-- regarding ISO 10241-1:2011,  If there is more than one preferred term, each preferred term follows the previous one on a new line. -->
	<!-- in metanorma xml preferred terms delimited by semicolons -->
	<xsl:template match="*[local-name() = 'preferred']/text()[contains(., ';')] | *[local-name() = 'preferred']/*[local-name() = 'strong']/text()[contains(., ';')]">
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.), ';', $linebreak)"/>
	</xsl:template>
	<!--  End Preferred, admitted, deprecated -->

	<xsl:template match="*[local-name() = 'fmt-related']">
		<fo:block role="SKIP" xsl:use-attribute-sets="related-block-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<xsl:template match="*[local-name() = 'fmt-related']/*[local-name() = 'p']" priority="4">
		<fo:block>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<!-- ========== -->
	<!-- definition -->
	<!-- ========== -->
	<xsl:template match="*[local-name() = 'definition']">
		<fo:block xsl:use-attribute-sets="definition-style" role="SKIP">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'definition'][preceding-sibling::*[local-name() = 'domain']]">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="*[local-name() = 'definition'][preceding-sibling::*[local-name() = 'domain']]/*[local-name() = 'p'][1]">
		<fo:inline> <xsl:apply-templates/></fo:inline>
		<fo:block/>
	</xsl:template>
	<!-- ========== -->
	<!-- END definition -->
	<!-- ========== -->

	<xsl:variable name="reviews_">
		<xsl:for-each select="//*[local-name() = 'review'][not(parent::*[local-name() = 'review-container'])][@from]">
			<xsl:copy>
				<xsl:copy-of select="@from"/>
				<xsl:copy-of select="@id"/>
			</xsl:copy>
		</xsl:for-each>
		<xsl:for-each select="//*[local-name() = 'fmt-review-start'][@source]">
			<xsl:copy>
				<xsl:copy-of select="@source"/>
				<xsl:copy-of select="@id"/>
			</xsl:copy>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="reviews" select="xalan:nodeset($reviews_)"/>

	<xsl:template name="addReviewHelper">
		<xsl:if test="$isGenerateTableIF = 'false'">
			<!-- if there is review with from="...", then add small helper block for Annot tag adding, see 'review' template -->
			<xsl:variable name="curr_id" select="@id"/>
			<!-- <xsl:variable name="review_id" select="normalize-space(/@id)"/> -->
			<xsl:for-each select="$reviews//*[local-name() = 'review'][@from = $curr_id]"> <!-- $reviews//*[local-name() = 'fmt-review-start'][@source = $curr_id] -->
				<xsl:variable name="review_id" select="normalize-space(@id)"/>
				<xsl:if test="$review_id != ''"> <!-- i.e. if review found -->
					<fo:block keep-with-next="always" line-height="0.1" id="{$review_id}" font-size="1pt" role="SKIP"><xsl:value-of select="$hair_space"/><fo:basic-link internal-destination="{$review_id}" fox:alt-text="Annot___{$review_id}" role="Annot"><xsl:value-of select="$hair_space"/></fo:basic-link></fo:block>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<!-- <fo:block>
			<curr_id><xsl:value-of select="$curr_id"/></curr_id>
			<xsl:copy-of select="$reviews"/>
		</fo:block> -->
	</xsl:template>

	<!-- main sections -->
	<xsl:template match="/*/*[local-name() = 'sections']/*" name="sections_node" priority="2">

		<fo:block>
			<xsl:call-template name="setId"/>

			<xsl:call-template name="sections_element_style"/>

			<xsl:call-template name="addReviewHelper"/>

			<xsl:apply-templates/>
		</fo:block>

	</xsl:template>

	<!-- note: @top-level added in mode=" update_xml_step_move_pagebreak" -->
	<xsl:template match="*[local-name() = 'sections']/*[local-name() = 'page_sequence']/*[not(@top-level)]" priority="2">
		<xsl:choose>
			<xsl:when test="local-name() = 'clause' and normalize-space() = '' and count(*) = 0"/>
			<xsl:otherwise>
				<xsl:call-template name="sections_node"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- page_sequence/sections/clause -->
	<xsl:template match="*[local-name() = 'page_sequence']/*[local-name() = 'sections']/*[not(@top-level)]" priority="2">
		<xsl:choose>
			<xsl:when test="local-name() = 'clause' and normalize-space() = '' and count(*) = 0"/>
			<xsl:otherwise>
				<xsl:call-template name="sections_node"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="sections_element_style">

	</xsl:template> <!-- sections_element_style -->

	<xsl:template match="//*[local-name() = 'metanorma']/*[local-name() = 'preface']/*" priority="2" name="preface_node"> <!-- /*/*[local-name() = 'preface']/* -->

				<fo:block break-after="page"/>

		<fo:block>
			<xsl:call-template name="setId"/>
			<xsl:call-template name="addReviewHelper"/>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<!-- preface/ page_sequence/clause -->
	<xsl:template match="*[local-name() = 'preface']/*[local-name() = 'page_sequence']/*[not(@top-level)]" priority="2"> <!-- /*/*[local-name() = 'preface']/* -->
		<xsl:choose>
			<xsl:when test="local-name() = 'clause' and normalize-space() = '' and count(*) = 0"/>
			<xsl:otherwise>
				<xsl:call-template name="preface_node"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- page_sequence/preface/clause -->
	<xsl:template match="*[local-name() = 'page_sequence']/*[local-name() = 'preface']/*[not(@top-level)]" priority="2"> <!-- /*/*[local-name() = 'preface']/* -->
		<xsl:choose>
			<xsl:when test="local-name() = 'clause' and normalize-space() = '' and count(*) = 0"/>
			<xsl:otherwise>
				<xsl:call-template name="preface_node"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[local-name() = 'clause'][normalize-space() != '' or *[local-name() = 'figure'] or @id]" name="template_clause"> <!-- if clause isn't empty -->
		<fo:block>
			<xsl:if test="parent::*[local-name() = 'copyright-statement']">
				<xsl:attribute name="role">SKIP</xsl:attribute>
			</xsl:if>

			<xsl:call-template name="setId"/>

			<xsl:call-template name="setBlockSpanAll"/>

			<xsl:call-template name="refine_clause_style"/>

			<xsl:call-template name="addReviewHelper"/>

			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template name="refine_clause_style">

	</xsl:template> <!-- refine_clause_style -->

	<xsl:template match="*[local-name() = 'definitions']">
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'annex'][normalize-space() != '']">
		<xsl:choose>
			<xsl:when test="@continue = 'true'"> <!-- it's using for figure/table on top level for block span -->
				<fo:block>
					<xsl:apply-templates/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>

				<fo:block break-after="page"/>
				<fo:block id="{@id}">

					<xsl:call-template name="setBlockSpanAll"/>

					<xsl:call-template name="refine_annex_style"/>

				</fo:block>

				<xsl:apply-templates select="*[local-name() = 'title'][@columns = 1]"/>

				<fo:block>
					<xsl:apply-templates select="node()[not(local-name() = 'title' and @columns = 1)]"/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="refine_annex_style">

	</xsl:template>

	<!-- document text (not figures, or tables) footnotes -->
	<xsl:variable name="reviews_container_">
		<xsl:for-each select="//*[local-name() = 'review-container']/*[local-name() = 'fmt-review-body']">
			<xsl:variable name="update_xml_step1">
				<xsl:apply-templates select="." mode="update_xml_step1"/>
			</xsl:variable>
			<xsl:apply-templates select="xalan:nodeset($update_xml_step1)" mode="update_xml_enclose_keep-together_within-line"/>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="reviews_container" select="xalan:nodeset($reviews_container_)"/>

	<xsl:template match="*[local-name() = 'review-container']"/>

	<!-- for old Presentation XML (before https://github.com/metanorma/isodoc/issues/670) -->
	<xsl:template match="*[local-name() = 'review'][not(parent::*[local-name() = 'review-container'])]">  <!-- 'review' will be processed in mn2pdf/review.xsl -->
		<xsl:variable name="id_from" select="normalize-space(current()/@from)"/>
		<xsl:if test="$isGenerateTableIF = 'false'">
		<xsl:choose>
			<!-- if there isn't the attribute '@from', then -->
			<xsl:when test="$id_from = ''">
				<fo:block id="{@id}" font-size="1pt" role="SKIP"><xsl:value-of select="$hair_space"/><fo:basic-link internal-destination="{@id}" fox:alt-text="Annot___{@id}" role="Annot"><xsl:value-of select="$hair_space"/></fo:basic-link></fo:block>
			</xsl:when>
			<!-- if there isn't element with id 'from', then create 'bookmark' here -->
			<xsl:when test="ancestor::*[local-name() = 'metanorma'] and not(ancestor::*[local-name() = 'metanorma']//*[@id = $id_from])">
				<fo:block id="{@from}" font-size="1pt" role="SKIP"><xsl:value-of select="$hair_space"/><fo:basic-link internal-destination="{@from}" fox:alt-text="Annot___{@id}" role="Annot"><xsl:value-of select="$hair_space"/></fo:basic-link></fo:block>
			</xsl:when>
			<xsl:when test="not(/*[@id = $id_from]) and not(/*//*[@id = $id_from]) and not(preceding-sibling::*[@id = $id_from])">
				<fo:block id="{@from}" font-size="1pt" role="SKIP"><xsl:value-of select="$hair_space"/><fo:basic-link internal-destination="{@from}" fox:alt-text="Annot___{@id}" role="Annot"><xsl:value-of select="$hair_space"/></fo:basic-link></fo:block>
			</xsl:when>
		</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- for new Presentation XML (https://github.com/metanorma/isodoc/issues/670) -->
	<xsl:template match="*[local-name() = 'fmt-review-start']" name="fmt-review-start"> <!-- 'review' will be processed in mn2pdf/review.xsl -->
		<!-- comment 2019-11-29 -->
		<!-- <fo:block font-weight="bold">Review:</fo:block>
		<xsl:apply-templates /> -->

		<xsl:variable name="id_from" select="normalize-space(current()/@source)"/>

		<xsl:variable name="source" select="normalize-space(@source)"/>

		<xsl:if test="$isGenerateTableIF = 'false'">
		<!-- <xsl:variable name="id_from" select="normalize-space(current()/@from)"/> -->

		<!-- <xsl:if test="@source = @end"> -->
		<!-- following-sibling::node()[1][local-name() = 'bookmark'][@id = $source] and
				following-sibling::node()[2][local-name() = 'fmt-review-end'][@source = $source] -->
			<!-- <fo:block id="{$source}" font-size="1pt" role="SKIP"><xsl:value-of select="$hair_space"/><fo:basic-link internal-destination="{$source}" fox:alt-text="Annot___{$source}" role="Annot"><xsl:value-of select="$hair_space"/></fo:basic-link></fo:block> -->
			<fo:block id="{@id}" font-size="1pt" role="SKIP" keep-with-next="always" line-height="0.1"><xsl:value-of select="$hair_space"/><fo:basic-link internal-destination="{@id}" fox:alt-text="Annot___{@id}" role="Annot"><xsl:value-of select="$hair_space"/></fo:basic-link></fo:block>
		<!-- </xsl:if> -->
		</xsl:if>

		<xsl:if test="1 = 2">
		<xsl:choose>
			<!-- if there isn't the attribute '@from', then -->
			<xsl:when test="$id_from = ''">
				<fo:block id="{@id}" font-size="1pt" role="SKIP"><xsl:value-of select="$hair_space"/><fo:basic-link internal-destination="{@id}" fox:alt-text="Annot___{@id}" role="Annot"><xsl:value-of select="$hair_space"/></fo:basic-link></fo:block>
			</xsl:when>
			<!-- if there isn't element with id 'from', then create 'bookmark' here -->
			<xsl:when test="ancestor::*[local-name() = 'metanorma'] and not(ancestor::*[local-name() = 'metanorma']//*[@id = $id_from])">
				<fo:block id="{$id_from}" font-size="1pt" role="SKIP"><xsl:value-of select="$hair_space"/><fo:basic-link internal-destination="{$id_from}" fox:alt-text="Annot___{@id}" role="Annot"><xsl:value-of select="$hair_space"/></fo:basic-link></fo:block>
			</xsl:when>
			<xsl:when test="not(/*[@id = $id_from]) and not(/*//*[@id = $id_from]) and not(preceding-sibling::*[@id = $id_from])">
				<fo:block id="{$id_from}" font-size="1pt" role="SKIP"><xsl:value-of select="$hair_space"/><fo:basic-link internal-destination="{$id_from}" fox:alt-text="Annot___{@id}" role="Annot"><xsl:value-of select="$hair_space"/></fo:basic-link></fo:block>
			</xsl:when>
		</xsl:choose>
		</xsl:if>

    <xsl:if test="1 = 2">
		<xsl:choose>
			<!-- if there isn't the attribute '@from', then -->
			<xsl:when test="$id_from = ''">
				<fo:block id="{@id}" font-size="1pt"><xsl:value-of select="$hair_space"/></fo:block>
			</xsl:when>
			<!-- if there isn't element with id 'from', then create 'bookmark' here -->
			<xsl:when test="ancestor::*[contains(local-name(), '-standard')] and not(ancestor::*[contains(local-name(), '-standard')]//*[@id = $id_from])">
				<fo:block id="{@from}" font-size="1pt"><xsl:value-of select="$hair_space"/></fo:block>
			</xsl:when>
			<xsl:when test="not(/*[@id = $id_from]) and not(/*//*[@id = $id_from]) and not(preceding-sibling::*[@id = $id_from])">
				<fo:block id="{@from}" font-size="1pt"><xsl:value-of select="$hair_space"/></fo:block>
			</xsl:when>
		</xsl:choose>
    </xsl:if>

	</xsl:template>

	<!-- https://github.com/metanorma/mn-samples-bsi/issues/312 -->
	<xsl:template match="*[local-name() = 'review'][@type = 'other']"/>

	<xsl:template match="*[local-name() = 'name']/text()">
		<!-- 0xA0 to space replacement -->
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.),' ',' ')"/>
	</xsl:template>

	<!-- ===================================== -->
	<!-- Lists processing -->
	<!-- ===================================== -->
	<xsl:variable name="ul_labels_">

				<label level="1">－</label> <!-- full-width hyphen minus -->
				<label level="2" font-size="130%" line-height="1.2">・</label> <!-- Katakana Middle Dot -->

	</xsl:variable>
	<xsl:variable name="ul_labels" select="xalan:nodeset($ul_labels_)"/>

	<xsl:template name="setULLabel">
		<xsl:variable name="list_level__">
			<xsl:value-of select="count(ancestor::*[local-name() = 'ul'])"/>
		</xsl:variable>
		<xsl:variable name="list_level_" select="number($list_level__)"/>
		<xsl:variable name="list_level">
			<xsl:choose>
				<xsl:when test="$list_level_ &lt;= 3"><xsl:value-of select="$list_level_"/></xsl:when>
				<xsl:when test="$ul_labels/label[@level = 3]"><xsl:value-of select="$list_level_ mod 3"/></xsl:when>
				<xsl:when test="$list_level_ mod 2 = 0">2</xsl:when>
				<xsl:otherwise><xsl:value-of select="$list_level_ mod 2"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$ul_labels/label[not(@level)]"> <!-- one label for all levels -->
				<xsl:apply-templates select="$ul_labels/label[not(@level)]" mode="ul_labels"/>
			</xsl:when>
			<xsl:when test="$list_level mod 3 = 0 and $ul_labels/label[@level = 3]">
				<xsl:apply-templates select="$ul_labels/label[@level = 3]" mode="ul_labels"/>
			</xsl:when>
			<xsl:when test="$list_level mod 3 = 0">
				<xsl:apply-templates select="$ul_labels/label[@level = 1]" mode="ul_labels"/>
			</xsl:when>
			<xsl:when test="$list_level mod 2 = 0">
				<xsl:apply-templates select="$ul_labels/label[@level = 2]" mode="ul_labels"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$ul_labels/label[@level = 1]" mode="ul_labels"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="label" mode="ul_labels">
		<xsl:copy-of select="@*[not(local-name() = 'level')]"/>
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template name="getListItemFormat">
		<!-- Example: for BSI <?list-type loweralpha?> -->
		<xsl:variable name="processing_instruction_type" select="normalize-space(../preceding-sibling::*[1]/processing-instruction('list-type'))"/>
		<xsl:choose>
			<xsl:when test="local-name(..) = 'ul'">
				<xsl:choose>
					<xsl:when test="normalize-space($processing_instruction_type) = 'simple'"/>
					<!-- https://github.com/metanorma/isodoc/issues/675 -->
					<xsl:when test="@label"><xsl:value-of select="@label"/></xsl:when>
					<xsl:otherwise><xsl:call-template name="setULLabel"/></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- https://github.com/metanorma/isodoc/issues/675 -->
			<xsl:when test="local-name(..) = 'ol' and @label and @full = 'true'"> <!-- @full added in the template li/fmt-name -->
				<xsl:value-of select="@label"/>
			</xsl:when>
			<xsl:when test="local-name(..) = 'ol' and @label"> <!-- for ordered lists 'ol', and if there is @label, for instance label="1.1.2" -->

				<xsl:variable name="type" select="../@type"/>

				<xsl:variable name="label">

					<xsl:variable name="style_prefix_">
						<xsl:if test="$type = 'roman'">
							 <!-- Example: (i) -->
						</xsl:if>
						<xsl:if test="$type = 'alphabet'">

						</xsl:if>
					</xsl:variable>
					<xsl:variable name="style_prefix" select="normalize-space($style_prefix_)"/>

					<xsl:variable name="style_suffix_">
						<xsl:choose>
							<xsl:when test="$type = 'arabic'">
								)
							</xsl:when>
							<xsl:when test="$type = 'alphabet' or $type = 'alphabetic'">
								)
							</xsl:when>
							<xsl:when test="$type = 'alphabet_upper' or $type = 'alphabetic_upper'">
								.
							</xsl:when>
							<xsl:when test="$type = 'roman'">
								)
							</xsl:when>
							<xsl:when test="$type = 'roman_upper'">.</xsl:when> <!-- Example: I. -->
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="style_suffix" select="normalize-space($style_suffix_)"/>

					<xsl:if test="$style_prefix != '' and not(starts-with(@label, $style_prefix))">
						<xsl:value-of select="$style_prefix"/>
					</xsl:if>

					<xsl:value-of select="@label"/>

					<xsl:if test="not(java:endsWith(java:java.lang.String.new(@label),$style_suffix))">
						<xsl:value-of select="$style_suffix"/>
					</xsl:if>
				</xsl:variable>

						<xsl:value-of select="normalize-space($label)"/>

			</xsl:when>
			<xsl:otherwise> <!-- for ordered lists 'ol' -->

				<!-- Example: for BSI <?list-start 2?> -->
				<xsl:variable name="processing_instruction_start" select="normalize-space(../preceding-sibling::*[1]/processing-instruction('list-start'))"/>

				<xsl:variable name="start_value">
					<xsl:choose>
						<xsl:when test="normalize-space($processing_instruction_start) != ''">
							<xsl:value-of select="number($processing_instruction_start) - 1"/><!-- if start="3" then start_value=2 + xsl:number(1) = 3 -->
						</xsl:when>
						<xsl:when test="normalize-space(../@start) != ''">
							<xsl:value-of select="number(../@start) - 1"/><!-- if start="3" then start_value=2 + xsl:number(1) = 3 -->
						</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="curr_value"><xsl:number/></xsl:variable>

				<xsl:variable name="type">
					<xsl:choose>
						<xsl:when test="normalize-space($processing_instruction_type) != ''"><xsl:value-of select="$processing_instruction_type"/></xsl:when>
						<xsl:when test="normalize-space(../@type) != ''"><xsl:value-of select="../@type"/></xsl:when>

						<xsl:otherwise> <!-- if no @type or @class = 'steps' -->

							<xsl:variable name="list_level_" select="count(ancestor::*[local-name() = 'ul']) + count(ancestor::*[local-name() = 'ol'])"/>
							<xsl:variable name="list_level">
								<xsl:choose>
									<xsl:when test="$list_level_ &lt;= 5"><xsl:value-of select="$list_level_"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="$list_level_ mod 5"/></xsl:otherwise>
								</xsl:choose>
							</xsl:variable>

							<xsl:choose>
								<xsl:when test="$list_level mod 5 = 0">roman_upper</xsl:when> <!-- level 5 -->
								<xsl:when test="$list_level mod 4 = 0">alphabet_upper</xsl:when> <!-- level 4 -->
								<xsl:when test="$list_level mod 3 = 0">roman</xsl:when> <!-- level 3 -->
								<xsl:when test="$list_level mod 2 = 0 and ancestor::*/@class = 'steps'">alphabet</xsl:when> <!-- level 2 and @class = 'steps'-->
								<xsl:when test="$list_level mod 2 = 0">arabic</xsl:when> <!-- level 2 -->
								<xsl:otherwise> <!-- level 1 -->
									<xsl:choose>
										<xsl:when test="ancestor::*/@class = 'steps'">arabic</xsl:when>
										<xsl:otherwise>alphabet</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>

						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="format">
					<xsl:choose>
						<xsl:when test="$type = 'arabic'">
							1)
						</xsl:when>
						<xsl:when test="$type = 'alphabet' or $type = 'alphabetic'">
							a)
						</xsl:when>
						<xsl:when test="$type = 'alphabet_upper' or $type = 'alphabetic_upper'">
							A.
						</xsl:when>
						<xsl:when test="$type = 'roman'">
							i)
						</xsl:when>
						<xsl:when test="$type = 'roman_upper'">I.</xsl:when>
						<xsl:otherwise>1.</xsl:otherwise> <!-- for any case, if $type has non-determined value, not using -->
					</xsl:choose>
				</xsl:variable>

				<xsl:number value="$start_value + $curr_value" format="{normalize-space($format)}" lang="en"/>

			</xsl:otherwise>
		</xsl:choose>
	</xsl:template> <!-- getListItemFormat -->

	<xsl:template match="*[local-name() = 'ul'] | *[local-name() = 'ol']">
		<xsl:param name="indent">0</xsl:param>
		<xsl:choose>
			<xsl:when test="parent::*[local-name() = 'note'] or parent::*[local-name() = 'termnote']">
				<fo:block-container role="SKIP">
					<xsl:attribute name="margin-left">
						<xsl:choose>
							<xsl:when test="not(ancestor::*[local-name() = 'table'])"><xsl:value-of select="$note-body-indent"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="$note-body-indent-table"/></xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

					<xsl:call-template name="refine_list_container_style"/>

					<fo:block-container margin-left="0mm" role="SKIP">
						<fo:block>
							<xsl:apply-templates select="." mode="list">
								<xsl:with-param name="indent" select="$indent"/>
							</xsl:apply-templates>
						</fo:block>
					</fo:block-container>
				</fo:block-container>
			</xsl:when>
			<xsl:otherwise>

						<xsl:choose>
							<xsl:when test="$vertical_layout = 'true'">
								<fo:block role="SKIP">
									<xsl:if test="ancestor::jis:ol or ancestor::jis:ul">
										<xsl:attribute name="margin-left">-3.5mm</xsl:attribute>
									</xsl:if>
									<xsl:apply-templates select="." mode="list">
										<xsl:with-param name="indent" select="$indent"/>
									</xsl:apply-templates>
								</fo:block>
							</xsl:when>
							<xsl:otherwise>
								<fo:block-container role="SKIP">
									<xsl:if test="ancestor::jis:ol or ancestor::jis:ul">
										<xsl:attribute name="margin-left">3.5mm</xsl:attribute>
									</xsl:if>
									<fo:block-container margin-left="0mm" role="SKIP">
										<fo:block>
											<xsl:apply-templates select="." mode="list">
												<xsl:with-param name="indent" select="$indent"/>
											</xsl:apply-templates>
										</fo:block>
									</fo:block-container>
								</fo:block-container>
							</xsl:otherwise>
						</xsl:choose>

			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="refine_list_container_style">

	</xsl:template> <!-- refine_list_container_style -->

	<xsl:template match="*[local-name()='ul'] | *[local-name()='ol']" mode="list" name="list">

		<xsl:apply-templates select="*[local-name() = 'name']">
			<xsl:with-param name="process">true</xsl:with-param>
		</xsl:apply-templates>

		<fo:list-block xsl:use-attribute-sets="list-style">

			<xsl:variable name="provisional_distance_between_starts_">
				<attributes xsl:use-attribute-sets="list-style">
					<xsl:call-template name="refine_list-style_provisional-distance-between-starts"/>
				</attributes>
			</xsl:variable>
			<xsl:variable name="provisional_distance_between_starts" select="normalize-space(xalan:nodeset($provisional_distance_between_starts_)/attributes/@provisional-distance-between-starts)"/>
			<xsl:if test="$provisional_distance_between_starts != ''">
				<xsl:attribute name="provisional-distance-between-starts"><xsl:value-of select="$provisional_distance_between_starts"/></xsl:attribute>
			</xsl:if>
			<xsl:variable name="provisional_distance_between_starts_value" select="substring-before($provisional_distance_between_starts, 'mm')"/>

			<!-- increase provisional-distance-between-starts for long lists -->
			<xsl:if test="local-name() = 'ol'">
				<!-- Examples: xiii), xviii), xxviii) -->
				<xsl:variable name="item_numbers">
					<xsl:for-each select="*[local-name() = 'li']">
						<item><xsl:call-template name="getListItemFormat"/></item>
					</xsl:for-each>
				</xsl:variable>

				<xsl:variable name="max_length">
					<xsl:for-each select="xalan:nodeset($item_numbers)/item">
						<xsl:sort select="string-length(.)" data-type="number" order="descending"/>
						<xsl:if test="position() = 1"><xsl:value-of select="string-length(.)"/></xsl:if>
					</xsl:for-each>
				</xsl:variable>

				<!-- base width (provisional-distance-between-starts) for 4 chars -->
				<xsl:variable name="addon" select="$max_length - 4"/>
				<xsl:if test="$addon &gt; 0">
					<xsl:attribute name="provisional-distance-between-starts"><xsl:value-of select="$provisional_distance_between_starts_value + $addon * 2"/>mm</xsl:attribute>
				</xsl:if>
				<!-- DEBUG -->
				<!-- <xsl:copy-of select="$item_numbers"/>
				<max_length><xsl:value-of select="$max_length"/></max_length>
				<addon><xsl:value-of select="$addon"/></addon> -->
			</xsl:if>

			<xsl:call-template name="refine_list-style"/>

			<xsl:if test="*[local-name() = 'name']">
				<xsl:attribute name="margin-top">0pt</xsl:attribute>
			</xsl:if>

			<xsl:apply-templates select="node()[not(local-name() = 'note')]"/>
		</fo:list-block>
		<!-- <xsl:for-each select="./iho:note">
			<xsl:call-template name="note"/>
		</xsl:for-each> -->
		<xsl:apply-templates select="./*[local-name() = 'note']"/>
	</xsl:template>

	<xsl:template name="refine_list-style_provisional-distance-between-starts">

			<xsl:if test="local-name() = 'ol' and $vertical_layout = 'true' and @type = 'arabic'">
				<xsl:copy-of select="@provisional-distance-between-starts"/> <!-- add in update_xml_step1 -->
			</xsl:if>

	</xsl:template> <!-- refine_list-style_provisional-distance-between-starts -->

	<xsl:template match="*[local-name() = 'ol' or local-name() = 'ul']/*[local-name() = 'name']">
		<xsl:param name="process">false</xsl:param>
		<xsl:if test="$process = 'true'">
			<fo:block xsl:use-attribute-sets="list-name-style">
				<xsl:apply-templates/>
			</fo:block>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name()='li']">
		<xsl:param name="indent">0</xsl:param>
		<!-- <fo:list-item xsl:use-attribute-sets="list-item-style">
			<fo:list-item-label end-indent="label-end()"><fo:block>x</fo:block></fo:list-item-label>
			<fo:list-item-body start-indent="body-start()" xsl:use-attribute-sets="list-item-body-style">
				<fo:block>debug li indent=<xsl:value-of select="$indent"/></fo:block>
			</fo:list-item-body>
		</fo:list-item> -->
		<fo:list-item xsl:use-attribute-sets="list-item-style">
			<xsl:copy-of select="@id"/>

			<xsl:call-template name="refine_list-item-style"/>

			<fo:list-item-label end-indent="label-end()">
				<fo:block xsl:use-attribute-sets="list-item-label-style" role="SKIP">

					<xsl:call-template name="refine_list-item-label-style"/>

					<xsl:if test="local-name(..) = 'ul'">
						<xsl:variable name="li_label" select="@label"/>
						<xsl:copy-of select="$ul_labels//label[. = $li_label]/@*[not(local-name() = 'level')]"/>
					</xsl:if>

					<!-- if 'p' contains all text in 'add' first and last elements in first p are 'add' -->
					<xsl:if test="*[1][count(node()[normalize-space() != '']) = 1 and *[local-name() = 'add']]">
						<xsl:call-template name="append_add-style"/>
					</xsl:if>

					<xsl:call-template name="getListItemFormat"/>

				</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()" xsl:use-attribute-sets="list-item-body-style">
				<fo:block role="SKIP">

					<xsl:call-template name="refine_list-item-body-style"/>

					<xsl:apply-templates>
						<xsl:with-param name="indent" select="$indent"/>
					</xsl:apply-templates>

					<!-- <xsl:apply-templates select="node()[not(local-name() = 'note')]" />
					
					<xsl:for-each select="./bsi:note">
						<xsl:call-template name="note"/>
					</xsl:for-each> -->
				</fo:block>
			</fo:list-item-body>
		</fo:list-item>
	</xsl:template>

	<!-- ===================================== -->
	<!-- END Lists processing -->
	<!-- ===================================== -->

	<!-- =================== -->
	<!-- Index section processing -->
	<!-- =================== -->

	<xsl:variable name="index" select="document($external_index)"/>

	<xsl:variable name="bookmark_in_fn">
		<xsl:for-each select="//*[local-name() = 'bookmark'][ancestor::*[local-name() = 'fn']]">
			<bookmark><xsl:value-of select="@id"/></bookmark>
		</xsl:for-each>
	</xsl:variable>

	<xsl:template match="@*|node()" mode="index_add_id">
		<xsl:param name="docid"/>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="index_add_id">
				<xsl:with-param name="docid" select="$docid"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'xref']" mode="index_add_id">
		<xsl:param name="docid"/>
		<xsl:variable name="id">
			<xsl:call-template name="generateIndexXrefId">
				<xsl:with-param name="docid" select="$docid"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:copy> <!-- add id to xref -->
			<xsl:apply-templates select="@*" mode="index_add_id"/>
			<xsl:attribute name="id">
				<xsl:value-of select="$id"/>
			</xsl:attribute>
			<xsl:apply-templates mode="index_add_id">
				<xsl:with-param name="docid" select="$docid"/>
			</xsl:apply-templates>
		</xsl:copy>
		<!-- split <xref target="bm1" to="End" pagenumber="true"> to two xref:
		<xref target="bm1" pagenumber="true"> and <xref target="End" pagenumber="true"> -->
		<xsl:if test="@to">
			<xsl:value-of select="$en_dash"/>
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:attribute name="target"><xsl:value-of select="@to"/></xsl:attribute>
				<xsl:attribute name="id">
					<xsl:value-of select="$id"/><xsl:text>_to</xsl:text>
				</xsl:attribute>
				<xsl:apply-templates mode="index_add_id">
					<xsl:with-param name="docid" select="$docid"/>
				</xsl:apply-templates>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="@*|node()" mode="index_update">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="index_update"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'indexsect']//*[local-name() = 'li']" mode="index_update">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="index_update"/>
		<xsl:apply-templates select="node()[1]" mode="process_li_element"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'indexsect']//*[local-name() = 'li']/node()" mode="process_li_element" priority="2">
		<xsl:param name="element"/>
		<xsl:param name="remove" select="'false'"/>
		<xsl:param name="target"/>
		<!-- <node></node> -->
		<xsl:choose>
			<xsl:when test="self::text()  and (normalize-space(.) = ',' or normalize-space(.) = $en_dash) and $remove = 'true'">
				<!-- skip text (i.e. remove it) and process next element -->
				<!-- [removed_<xsl:value-of select="."/>] -->
				<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element">
					<xsl:with-param name="target"><xsl:value-of select="$target"/></xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="self::text()">
				<xsl:value-of select="."/>
				<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element"/>
			</xsl:when>
			<xsl:when test="self::* and local-name(.) = 'xref'">
				<xsl:variable name="id" select="@id"/>

				<xsl:variable name="id_next" select="following-sibling::*[local-name() = 'xref'][1]/@id"/>
				<xsl:variable name="id_prev" select="preceding-sibling::*[local-name() = 'xref'][1]/@id"/>

				<xsl:variable name="pages_">
					<xsl:for-each select="$index/index/item[@id = $id or @id = $id_next or @id = $id_prev]">
						<xsl:choose>
							<xsl:when test="@id = $id">
								<page><xsl:value-of select="."/></page>
							</xsl:when>
							<xsl:when test="@id = $id_next">
								<page_next><xsl:value-of select="."/></page_next>
							</xsl:when>
							<xsl:when test="@id = $id_prev">
								<page_prev><xsl:value-of select="."/></page_prev>
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="pages" select="xalan:nodeset($pages_)"/>

				<!-- <xsl:variable name="page" select="$index/index/item[@id = $id]"/> -->
				<xsl:variable name="page" select="$pages/page"/>
				<!-- <xsl:variable name="page_next" select="$index/index/item[@id = $id_next]"/> -->
				<xsl:variable name="page_next" select="$pages/page_next"/>
				<!-- <xsl:variable name="page_prev" select="$index/index/item[@id = $id_prev]"/> -->
				<xsl:variable name="page_prev" select="$pages/page_prev"/>

				<xsl:choose>
					<!-- 2nd pass -->
					<!-- if page is equal to page for next and page is not the end of range -->
					<xsl:when test="$page != '' and $page_next != '' and $page = $page_next and not(contains($page, '_to'))">  <!-- case: 12, 12-14 -->
						<!-- skip element (i.e. remove it) and remove next text ',' -->
						<!-- [removed_xref] -->

						<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element">
							<xsl:with-param name="remove">true</xsl:with-param>
							<xsl:with-param name="target">
								<xsl:choose>
									<xsl:when test="$target != ''"><xsl:value-of select="$target"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="@target"/></xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:apply-templates>
					</xsl:when>

					<xsl:when test="$page != '' and $page_prev != '' and $page = $page_prev and contains($page_prev, '_to')"> <!-- case: 12-14, 14, ... -->
						<!-- remove xref -->
						<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element">
							<xsl:with-param name="remove">true</xsl:with-param>
						</xsl:apply-templates>
					</xsl:when>

					<xsl:otherwise>
						<xsl:apply-templates select="." mode="xref_copy">
							<xsl:with-param name="target" select="$target"/>
						</xsl:apply-templates>
						<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="self::* and local-name(.) = 'ul'">
				<!-- ul -->
				<xsl:apply-templates select="." mode="index_update"/>
			</xsl:when>
			<xsl:otherwise>
			 <xsl:apply-templates select="." mode="xref_copy">
					<xsl:with-param name="target" select="$target"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@*|node()" mode="xref_copy">
		<xsl:param name="target"/>
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="xref_copy"/>
			<xsl:if test="$target != '' and not(xalan:nodeset($bookmark_in_fn)//bookmark[. = $target])">
				<xsl:attribute name="target"><xsl:value-of select="$target"/></xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="node()" mode="xref_copy"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="generateIndexXrefId">
		<xsl:param name="docid"/>

		<xsl:variable name="level" select="count(ancestor::*[local-name() = 'ul'])"/>

		<xsl:variable name="docid_curr">
			<xsl:value-of select="$docid"/>
			<xsl:if test="normalize-space($docid) = ''"><xsl:call-template name="getDocumentId"/></xsl:if>
		</xsl:variable>

		<xsl:variable name="item_number">
			<xsl:number count="*[local-name() = 'li'][ancestor::*[local-name() = 'indexsect']]" level="any"/>
		</xsl:variable>
		<xsl:variable name="xref_number"><xsl:number count="*[local-name() = 'xref']"/></xsl:variable>
		<xsl:value-of select="concat($docid_curr, '_', $item_number, '_', $xref_number)"/> <!-- $level, '_',  -->
	</xsl:template>

	<xsl:template match="*[local-name() = 'indexsect']/*[local-name() = 'title']" priority="4">
		<fo:block xsl:use-attribute-sets="indexsect-title-style">
			<!-- Index -->
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'indexsect']/*[local-name() = 'clause']/*[local-name() = 'title']" priority="4">
		<!-- Letter A, B, C, ... -->
		<fo:block xsl:use-attribute-sets="indexsect-clause-title-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'indexsect']/*[local-name() = 'clause']" priority="4">
		<xsl:apply-templates/>
		<fo:block>
			<xsl:if test="following-sibling::*[local-name() = 'clause']">
				<fo:block> </fo:block>
			</xsl:if>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'indexsect']//*[local-name() = 'ul']" priority="4">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'indexsect']//*[local-name() = 'li']" priority="4">
		<xsl:variable name="level" select="count(ancestor::*[local-name() = 'ul'])"/>
		<fo:block start-indent="{5 * $level}mm" text-indent="-5mm">

			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'indexsect']//*[local-name() = 'li']/text()">
		<!-- to split by '_' and other chars -->
		<xsl:call-template name="add-zero-spaces-java"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'table']/*[local-name() = 'bookmark']" priority="2"/>

	<xsl:template match="*[local-name() = 'bookmark']" name="bookmark">
		<xsl:variable name="bookmark_id" select="@id"/>
		<xsl:choose>
			<!-- Example:
				<fmt-review-start id="_7ef81cf7-3f6c-4ed4-9c1f-1ba092052bbd" source="_dda23915-8574-ef1e-29a1-822d465a5b97" target="_ecfb2210-3b1b-46a2-b63a-8b8505be6686" end="_dda23915-8574-ef1e-29a1-822d465a5b97" author="" date="2025-03-24T00:00:00Z"/>
				<bookmark id="_dda23915-8574-ef1e-29a1-822d465a5b97"/>
				<fmt-review-end id="_f336a8d0-08a8-4b7f-a1aa-b04688ed40c1" source="_dda23915-8574-ef1e-29a1-822d465a5b97" target="_ecfb2210-3b1b-46a2-b63a-8b8505be6686" start="_dda23915-8574-ef1e-29a1-822d465a5b97" author="" date="2025-03-24T00:00:00Z"/> -->
			<xsl:when test="1 = 2 and preceding-sibling::node()[local-name() = 'fmt-review-start'][@source = $bookmark_id] and        following-sibling::node()[local-name() = 'fmt-review-end'][@source = $bookmark_id]">
				<!-- skip here, see the template 'fmt-review-start' -->
			</xsl:when>
			<xsl:otherwise>
				<!-- <fo:inline id="{@id}" font-size="1pt"/> -->
				<fo:inline id="{@id}" font-size="1pt"><xsl:if test="preceding-sibling::node()[local-name() = 'fmt-review-start'][@source = $bookmark_id] and        following-sibling::node()[local-name() = 'fmt-review-end'][@source = $bookmark_id]"><xsl:attribute name="line-height">0.1</xsl:attribute></xsl:if><xsl:value-of select="$hair_space"/></fo:inline>
				<!-- we need to add zero-width space, otherwise this fo:inline is missing in IF xml -->
				<xsl:if test="not(following-sibling::node()[normalize-space() != ''])"><fo:inline font-size="1pt"> </fo:inline></xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- =================== -->
	<!-- End of Index processing -->
	<!-- =================== -->

	<!-- ============ -->
	<!-- errata -->
	<!-- ============ -->
	<xsl:template match="*[local-name() = 'errata']">
		<!-- <row>
					<date>05-07-2013</date>
					<type>Editorial</type>
					<change>Changed CA-9 Priority Code from P1 to P2 in <xref target="tabled2"/>.</change>
					<pages>D-3</pages>
				</row>
		-->
		<fo:table table-layout="fixed" width="100%" font-size="10pt" border="1pt solid black">
			<fo:table-column column-width="20mm"/>
			<fo:table-column column-width="23mm"/>
			<fo:table-column column-width="107mm"/>
			<fo:table-column column-width="15mm"/>
			<fo:table-body>
				<fo:table-row text-align="center" font-weight="bold" background-color="black" color="white">

					<fo:table-cell border="1pt solid black"><fo:block role="SKIP">Date</fo:block></fo:table-cell>
					<fo:table-cell border="1pt solid black"><fo:block role="SKIP">Type</fo:block></fo:table-cell>
					<fo:table-cell border="1pt solid black"><fo:block role="SKIP">Change</fo:block></fo:table-cell>
					<fo:table-cell border="1pt solid black"><fo:block role="SKIP">Pages</fo:block></fo:table-cell>
				</fo:table-row>
				<xsl:apply-templates/>
			</fo:table-body>
		</fo:table>
	</xsl:template>

	<xsl:template match="*[local-name() = 'errata']/*[local-name() = 'row']">
		<fo:table-row>
			<xsl:apply-templates/>
		</fo:table-row>
	</xsl:template>

	<xsl:template match="*[local-name() = 'errata']/*[local-name() = 'row']/*">
		<fo:table-cell border="1pt solid black" padding-left="1mm" padding-top="0.5mm">
			<fo:block role="SKIP"><xsl:apply-templates/></fo:block>
		</fo:table-cell>
	</xsl:template>
	<!-- ============ -->
	<!-- END errata -->
	<!-- ============ -->

	<!-- ======================= -->
	<!-- Bibliography rendering -->
	<!-- ======================= -->

	<!-- ========================================================== -->
	<!-- Reference sections (Normative References and Bibliography) -->
	<!-- ========================================================== -->
	<xsl:template match="*[local-name() = 'references'][@hidden='true']" priority="3"/>
	<xsl:template match="*[local-name() = 'bibitem'][@hidden='true']" priority="3">
		<xsl:param name="skip" select="normalize-space(preceding-sibling::*[1][local-name() = 'bibitem'] and 1 = 1)"/>

	</xsl:template>
	<!-- don't display bibitem with @id starts with '_hidden', that was introduced for references integrity -->
	<xsl:template match="*[local-name() = 'bibitem'][starts-with(@id, 'hidden_bibitem_')]" priority="3"/>

	<!-- Normative references -->
	<xsl:template match="*[local-name() = 'references'][@normative='true']" priority="2">

		<fo:block id="{@id}">
			<xsl:apply-templates/>

				<!-- render footnotes after references -->
				<xsl:apply-templates select=".//jis:fn[generate-id(.)=generate-id(key('kfn',@reference)[1])]" mode="fn_after_element">
					<xsl:with-param name="ancestor">references</xsl:with-param>
				</xsl:apply-templates>

		</fo:block>
	</xsl:template>

	<!-- Bibliography (non-normative references) -->
	<xsl:template match="*[local-name() = 'references']">
		<xsl:if test="not(ancestor::*[local-name() = 'annex'])">

					<xsl:choose>
						<xsl:when test="following-sibling::*[local-name() = 'references'] or preceding-sibling::*[local-name() = 'references']"/>
						<xsl:otherwise>
							<fo:block break-after="page"/>
						</xsl:otherwise>
					</xsl:choose>

		</xsl:if>

		<!-- <xsl:if test="ancestor::*[local-name() = 'annex']">
			<xsl:if test="$namespace = 'csa' or $namespace = 'csd' or $namespace = 'gb' or $namespace = 'iec' or $namespace = 'iso' or $namespace = 'itu'">
				<fo:block break-after="page"/>
			</xsl:if>
		</xsl:if> -->

		<fo:block id="{@id}"/>

		<xsl:apply-templates select="*[local-name() = 'title'][@columns = 1]"/>

		<fo:block xsl:use-attribute-sets="references-non-normative-style">
			<xsl:apply-templates select="node()[not(local-name() = 'title' and @columns = 1)]"/>

				<!-- render footnotes after references -->
				<xsl:apply-templates select=".//jis:fn[generate-id(.)=generate-id(key('kfn',@reference)[1])]" mode="fn_after_element">
					<xsl:with-param name="ancestor">references</xsl:with-param>
				</xsl:apply-templates>

		</fo:block>

	</xsl:template> <!-- references -->

	<xsl:template match="*[local-name() = 'bibitem']">
		<xsl:call-template name="bibitem"/>
	</xsl:template>

	<!-- Normative references -->
	<xsl:template match="*[local-name() = 'references'][@normative='true']/*[local-name() = 'bibitem']" name="bibitem" priority="2">
		<xsl:param name="skip" select="normalize-space(preceding-sibling::*[1][local-name() = 'bibitem'] and 1 = 1)"/> <!-- current bibiitem is non-first -->

				<fo:block-container margin-left="6mm" role="SKIP">
					<fo:block-container margin-left="0mm" role="SKIP">
						<fo:block id="{@id}" xsl:use-attribute-sets="bibitem-normative-style">
							<xsl:call-template name="processBibitem"/>
						</fo:block>
					</fo:block-container>
				</fo:block-container>

	</xsl:template> <!-- bibitem -->

	<!-- Bibliography (non-normative references) -->
	<xsl:template match="*[local-name() = 'references'][not(@normative='true')]/*[local-name() = 'bibitem']" name="bibitem_non_normative" priority="2">
		<xsl:param name="skip" select="normalize-space(preceding-sibling::*[1][local-name() = 'bibitem'] and 1 = 1)"/> <!-- current bibiitem is non-first -->
		 <!-- $namespace = 'csd' or $namespace = 'gb' or $namespace = 'iec' or $namespace = 'ieee' or $namespace = 'iso' or $namespace = 'jcgm' or $namespace = 'm3d' or 
			$namespace = 'mpfd' or $namespace = 'ogc' or $namespace = 'ogc-white-paper' -->
				<!-- Example: [1] ISO 9:1995, Information and documentation – Transliteration of Cyrillic characters into Latin characters – Slavic and non-Slavic languages -->
				<fo:list-block id="{@id}" xsl:use-attribute-sets="bibitem-non-normative-list-style">

					<fo:list-item>
						<fo:list-item-label end-indent="label-end()">
							<fo:block role="SKIP">
								<fo:inline role="SKIP">

									<xsl:apply-templates select="*[local-name() = 'biblio-tag']">
										<xsl:with-param name="biblio_tag_part">first</xsl:with-param>
									</xsl:apply-templates>
								</fo:inline>
							</fo:block>
						</fo:list-item-label>
						<fo:list-item-body start-indent="body-start()">
							<fo:block xsl:use-attribute-sets="bibitem-non-normative-list-body-style" role="SKIP">
								<xsl:call-template name="processBibitem">
									<xsl:with-param name="biblio_tag_part">last</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:list-item-body>
					</fo:list-item>
				</fo:list-block>

	</xsl:template> <!-- references[not(@normative='true')]/bibitem -->

	<xsl:template name="insertListItem_Bibitem">
		<xsl:choose>
			<xsl:when test="@hidden = 'true'"><!-- skip --></xsl:when>
			<xsl:otherwise>
				<fo:list-item id="{@id}" xsl:use-attribute-sets="bibitem-non-normative-list-item-style">

					<fo:list-item-label end-indent="label-end()">
						<fo:block role="SKIP">
							<fo:inline role="SKIP">
								<xsl:apply-templates select="*[local-name() = 'biblio-tag']">
									<xsl:with-param name="biblio_tag_part">first</xsl:with-param>
								</xsl:apply-templates>
							</fo:inline>
						</fo:block>
					</fo:list-item-label>
					<fo:list-item-body start-indent="body-start()">
						<fo:block xsl:use-attribute-sets="bibitem-non-normative-list-body-style" role="SKIP">
							<xsl:call-template name="processBibitem">
								<xsl:with-param name="biblio_tag_part">last</xsl:with-param>
							</xsl:call-template>
						</fo:block>
					</fo:list-item-body>
				</fo:list-item>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="following-sibling::*[1][local-name() = 'bibitem']">
			<xsl:with-param name="skip">false</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template name="processBibitem">
		<xsl:param name="biblio_tag_part">both</xsl:param>

				<xsl:if test=".//*[local-name() = 'fn']">
					<xsl:attribute name="line-height-shift-adjustment">disregard-shifts</xsl:attribute>
				</xsl:if>
				<fo:inline font-weight="bold">
					<xsl:if test="not($vertical_layout = 'true')">
						<xsl:attribute name="font-family">Times New Roman</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates select="*[local-name() = 'biblio-tag']">
						<xsl:with-param name="biblio_tag_part" select="$biblio_tag_part"/>
					</xsl:apply-templates>
				</fo:inline>
				<xsl:apply-templates select="*[local-name() = 'formattedref']"/>

	</xsl:template> <!-- processBibitem (bibitem) -->

	<xsl:template match="*[local-name() = 'title']" mode="title">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template>

	<xsl:template match="*[local-name() = 'bibitem']/*[local-name() = 'docidentifier']"/>

	<xsl:template match="*[local-name() = 'formattedref']">
		<!-- <xsl:if test="$namespace = 'unece' or $namespace = 'unece-rec'">
			<xsl:text>, </xsl:text>
		</xsl:if> -->
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'biblio-tag']">
		<xsl:param name="biblio_tag_part">both</xsl:param>
		<xsl:choose>
			<xsl:when test="$biblio_tag_part = 'first' and *[local-name() = 'tab']">
				<xsl:apply-templates select="./*[local-name() = 'tab'][1]/preceding-sibling::node()"/>
			</xsl:when>
			<xsl:when test="$biblio_tag_part = 'last'">
				<xsl:apply-templates select="./*[local-name() = 'tab'][1]/following-sibling::node()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[local-name() = 'biblio-tag']/*[local-name() = 'tab']" priority="2">
		<xsl:text> </xsl:text>
	</xsl:template>

	<!-- ======================= -->
	<!-- END Bibliography rendering -->
	<!-- ======================= -->

	<!-- ========================================================== -->
	<!-- END Reference sections (Normative References and Bibliography) -->
	<!-- ========================================================== -->

	<!-- =================== -->
	<!-- Form's elements processing -->
	<!-- =================== -->
	<xsl:template match="*[local-name() = 'form']">
		<fo:block>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'form']//*[local-name() = 'label']">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template>

	<xsl:template match="*[local-name() = 'form']//*[local-name() = 'input'][@type = 'text' or @type = 'date' or @type = 'file' or @type = 'password']">
		<fo:inline>
			<xsl:call-template name="text_input"/>
		</fo:inline>
	</xsl:template>

	<xsl:template name="text_input">
		<xsl:variable name="count">
			<xsl:choose>
				<xsl:when test="normalize-space(@maxlength) != ''"><xsl:value-of select="@maxlength"/></xsl:when>
				<xsl:when test="normalize-space(@size) != ''"><xsl:value-of select="@size"/></xsl:when>
				<xsl:otherwise>10</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="repeat">
			<xsl:with-param name="char" select="'_'"/>
			<xsl:with-param name="count" select="$count"/>
		</xsl:call-template>
		<xsl:text> </xsl:text>
	</xsl:template>

	<xsl:template match="*[local-name() = 'form']//*[local-name() = 'input'][@type = 'button']">
		<xsl:variable name="caption">
			<xsl:choose>
				<xsl:when test="normalize-space(@value) != ''"><xsl:value-of select="@value"/></xsl:when>
				<xsl:otherwise>BUTTON</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<fo:inline>[<xsl:value-of select="$caption"/>]</fo:inline>
	</xsl:template>

	<xsl:template match="*[local-name() = 'form']//*[local-name() = 'input'][@type = 'checkbox']">
		<fo:inline padding-right="1mm">
			<fo:instream-foreign-object fox:alt-text="Box" baseline-shift="-10%">
				<xsl:attribute name="height">3.5mm</xsl:attribute>
				<xsl:attribute name="content-width">100%</xsl:attribute>
				<xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
				<xsl:attribute name="scaling">uniform</xsl:attribute>
				<svg xmlns="http://www.w3.org/2000/svg" width="80" height="80">
					<polyline points="0,0 80,0 80,80 0,80 0,0" stroke="black" stroke-width="5" fill="white"/>
				</svg>
			</fo:instream-foreign-object>
		</fo:inline>
	</xsl:template>

	<xsl:template match="*[local-name() = 'form']//*[local-name() = 'input'][@type = 'radio']">
		<fo:inline padding-right="1mm">
			<fo:instream-foreign-object fox:alt-text="Box" baseline-shift="-10%">
				<xsl:attribute name="height">3.5mm</xsl:attribute>
				<xsl:attribute name="content-width">100%</xsl:attribute>
				<xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
				<xsl:attribute name="scaling">uniform</xsl:attribute>
				<svg xmlns="http://www.w3.org/2000/svg" width="80" height="80">
					<circle cx="40" cy="40" r="30" stroke="black" stroke-width="5" fill="white"/>
					<circle cx="40" cy="40" r="15" stroke="black" stroke-width="5" fill="white"/>
				</svg>
			</fo:instream-foreign-object>
		</fo:inline>
	</xsl:template>

	<xsl:template match="*[local-name() = 'form']//*[local-name() = 'select']">
		<fo:inline>
			<xsl:call-template name="text_input"/>
		</fo:inline>
	</xsl:template>

	<xsl:template match="*[local-name() = 'form']//*[local-name() = 'textarea']">
		<fo:block-container border="1pt solid black" width="50%">
			<fo:block> </fo:block>
		</fo:block-container>
	</xsl:template>

	<!-- =================== -->
	<!-- End Form's elements processing -->
	<!-- =================== -->

	<!-- =================== -->
	<!-- Table of Contents (ToC) processing -->
	<!-- =================== -->

	<xsl:variable name="toc_level">
		<!-- https://www.metanorma.org/author/ref/document-attributes/ -->
		<xsl:variable name="pdftoclevels" select="normalize-space(//*[local-name() = 'metanorma-extension']/*[local-name() = 'presentation-metadata'][*[local-name() = 'name']/text() = 'PDF TOC Heading Levels']/*[local-name() = 'value'])"/> <!-- :toclevels-pdf  Number of table of contents levels to render in PDF output; used to override :toclevels:-->
		<xsl:variable name="toclevels" select="normalize-space(//*[local-name() = 'metanorma-extension']/*[local-name() = 'presentation-metadata'][*[local-name() = 'name']/text() = 'TOC Heading Levels']/*[local-name() = 'value'])"/> <!-- Number of table of contents levels to render -->
		<xsl:choose>
			<xsl:when test="$pdftoclevels != ''"><xsl:value-of select="number($pdftoclevels)"/></xsl:when> <!-- if there is value in xml -->
			<xsl:when test="$toclevels != ''"><xsl:value-of select="number($toclevels)"/></xsl:when>  <!-- if there is value in xml -->
			<xsl:otherwise><!-- default value -->
				2
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="*[local-name() = 'toc']">
		<xsl:param name="colwidths"/>
		<xsl:variable name="colwidths_">
			<xsl:choose>
				<xsl:when test="not($colwidths)">
					<xsl:variable name="toc_table_simple">
						<tbody>
							<xsl:apply-templates mode="toc_table_width"/>
						</tbody>
					</xsl:variable>
					<xsl:variable name="cols-count" select="count(xalan:nodeset($toc_table_simple)/*/tr[1]/td)"/>
					<xsl:call-template name="calculate-column-widths-proportional">
						<xsl:with-param name="cols-count" select="$cols-count"/>
						<xsl:with-param name="table" select="$toc_table_simple"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$colwidths"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<fo:block role="TOCI" space-after="16pt">
			<fo:table width="100%" table-layout="fixed">
				<xsl:for-each select="xalan:nodeset($colwidths_)/column">
					<fo:table-column column-width="proportional-column-width({.})"/>
				</xsl:for-each>
				<fo:table-body>
					<xsl:apply-templates/>
				</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'toc']//*[local-name() = 'li']" priority="2">
		<fo:table-row min-height="5mm">
			<xsl:apply-templates/>
		</fo:table-row>
	</xsl:template>

	<xsl:template match="*[local-name() = 'toc']//*[local-name() = 'li']/*[local-name() = 'p']">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'toc']//*[local-name() = 'xref']" priority="3">
		<!-- <xref target="cgpm9th1948r6">1.6.3<tab/>&#8220;9th CGPM, 1948:<tab/>decision to establish the SI&#8221;</xref> -->
		<!-- New format: one tab <xref target="cgpm9th1948r6">&#8220;9th CGPM, 1948:<tab/>decision to establish the SI&#8221;</xref> -->
		<!-- <test><xsl:copy-of select="."/></test> -->

		<xsl:variable name="target" select="@target"/>

		<xsl:for-each select="*[local-name() = 'tab']">

			<xsl:if test="position() = 1">
				<!-- first column (data before first `tab`) -->
				<fo:table-cell>
					<fo:block line-height-shift-adjustment="disregard-shifts" role="SKIP">
						<xsl:call-template name="insert_basic_link">
							<xsl:with-param name="element">
								<fo:basic-link internal-destination="{$target}" fox:alt-text="{.}">
									<xsl:for-each select="preceding-sibling::node()">
										<xsl:choose>
											<xsl:when test="self::text()"><xsl:value-of select="."/></xsl:when>
											<xsl:otherwise><xsl:apply-templates select="."/></xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</fo:basic-link>
							</xsl:with-param>
						</xsl:call-template>
					</fo:block>
				</fo:table-cell>
			</xsl:if>

			<xsl:variable name="current_id" select="generate-id()"/>
			<fo:table-cell>
				<fo:block line-height-shift-adjustment="disregard-shifts" role="SKIP">
					<xsl:call-template name="insert_basic_link">
						<xsl:with-param name="element">
							<fo:basic-link internal-destination="{$target}" fox:alt-text="{.}">
								<xsl:for-each select="following-sibling::node()[not(self::*[local-name() = 'tab']) and preceding-sibling::*[local-name() = 'tab'][1][generate-id() = $current_id]]">
									<xsl:choose>
										<xsl:when test="self::text()"><xsl:value-of select="."/></xsl:when>
										<xsl:otherwise><xsl:apply-templates select="."/></xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</fo:basic-link>
						</xsl:with-param>
					</xsl:call-template>
				</fo:block>
			</fo:table-cell>
		</xsl:for-each>
		<!-- last column - for page numbers -->
		<fo:table-cell text-align="right" font-size="10pt" font-weight="bold" font-family="Arial">
			<fo:block role="SKIP">
				<xsl:call-template name="insert_basic_link">
					<xsl:with-param name="element">
						<fo:basic-link internal-destination="{$target}" fox:alt-text="{.}">
							<fo:page-number-citation ref-id="{$target}"/>
						</fo:basic-link>
					</xsl:with-param>
				</xsl:call-template>
			</fo:block>
		</fo:table-cell>
	</xsl:template>

	<!-- ================================== -->
	<!-- calculate ToC table columns widths -->
	<!-- ================================== -->
	<xsl:template match="*" mode="toc_table_width">
		<xsl:apply-templates mode="toc_table_width"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'clause'][@type = 'toc']/*[local-name() = 'title']" mode="toc_table_width"/>
	<xsl:template match="*[local-name() = 'clause'][not(@type = 'toc')]/*[local-name() = 'title']" mode="toc_table_width"/>

	<xsl:template match="*[local-name() = 'li']" mode="toc_table_width">
		<tr>
			<xsl:apply-templates mode="toc_table_width"/>
		</tr>
	</xsl:template>

	<xsl:template match="*[local-name() = 'xref']" mode="toc_table_width">
		<!-- <xref target="cgpm9th1948r6">1.6.3<tab/>&#8220;9th CGPM, 1948:<tab/>decision to establish the SI&#8221;</xref> -->
		<!-- New format - one tab <xref target="cgpm9th1948r6">&#8220;9th CGPM, 1948:<tab/>decision to establish the SI&#8221;</xref> -->
		<xsl:for-each select="*[local-name() = 'tab']">
			<xsl:if test="position() = 1">
				<td>
					<xsl:for-each select="preceding-sibling::node()">
						<xsl:choose>
							<xsl:when test="self::text()"><xsl:value-of select="."/></xsl:when>
							<xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</td>
			</xsl:if>
			<xsl:variable name="current_id" select="generate-id()"/>
			<td>
				<xsl:for-each select="following-sibling::node()[not(self::*[local-name() = 'tab']) and preceding-sibling::*[local-name() = 'tab'][1][generate-id() = $current_id]]">
					<xsl:choose>
						<xsl:when test="self::text()"><xsl:value-of select="."/></xsl:when>
						<xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</td>
		</xsl:for-each>
		<td>333</td> <!-- page number, just for fill -->
	</xsl:template>

	<!-- ================================== -->
	<!-- END: calculate ToC table columns widths -->
	<!-- ================================== -->

	<!-- =================== -->
	<!-- End Table of Contents (ToC) processing -->
	<!-- =================== -->

	<!-- insert fo:basic-link, if external-destination or internal-destination is non-empty, otherwise insert fo:inline -->
	<xsl:template name="insert_basic_link">
		<xsl:param name="element"/>
		<xsl:variable name="element_node" select="xalan:nodeset($element)"/>
		<xsl:variable name="external-destination" select="normalize-space(count($element_node/fo:basic-link/@external-destination[. != '']) = 1)"/>
		<xsl:variable name="internal-destination" select="normalize-space(count($element_node/fo:basic-link/@internal-destination[. != '']) = 1)"/>
		<xsl:choose>
			<xsl:when test="$external-destination = 'true' or $internal-destination = 'true'">
				<xsl:copy-of select="$element_node"/>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline>
					<xsl:for-each select="$element_node/fo:basic-link/@*[local-name() != 'external-destination' and local-name() != 'internal-destination' and local-name() != 'alt-text']">
						<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
					</xsl:for-each>
					<xsl:copy-of select="$element_node/fo:basic-link/node()"/>
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[local-name() = 'variant-title']"/> <!-- [@type = 'sub'] -->
	<xsl:template match="*[local-name() = 'variant-title'][@type = 'sub']" mode="subtitle">
		<fo:inline padding-right="5mm"> </fo:inline>
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template>

	<xsl:template match="*[local-name() = 'blacksquare']" name="blacksquare">
		<fo:inline padding-right="2.5mm" baseline-shift="5%">
			<fo:instream-foreign-object content-height="2mm" content-width="2mm" fox:alt-text="Quad">
					<svg xmlns="http://www.w3.org/2000/svg" xml:space="preserve" viewBox="0 0 2 2">
						<rect x="0" y="0" width="2" height="2" fill="black"/>
					</svg>
				</fo:instream-foreign-object>
		</fo:inline>
	</xsl:template>

	<xsl:template match="@language">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'p'][@type = 'floating-title' or @type = 'section-title']" priority="4">
		<xsl:call-template name="title"/>
	</xsl:template>

	<!-- ================ -->
	<!-- Admonition -->
	<!-- ================ -->
	<xsl:template match="*[local-name() = 'admonition']">

		 <!-- text in the box -->
				<fo:block-container id="{@id}" xsl:use-attribute-sets="admonition-style">

					<xsl:call-template name="setBlockSpanAll"/>

							<fo:block-container xsl:use-attribute-sets="admonition-container-style" role="SKIP">

										<fo:block-container margin-left="0mm" margin-right="0mm" role="SKIP">
											<fo:block>
												<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
											</fo:block>
										</fo:block-container>

							</fo:block-container>

				</fo:block-container>

	</xsl:template>

	<xsl:template name="displayAdmonitionName">
		<xsl:param name="sep"/> <!-- Example: ' - ' -->
		<!-- <xsl:choose>
			<xsl:when test="$namespace = 'nist-cswp' or $namespace = 'nist-sp'">
				<xsl:choose>
					<xsl:when test="@type='important'"><xsl:apply-templates select="@type"/></xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="*[local-name() = 'name']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*[local-name() = 'name']"/>
				<xsl:if test="not(*[local-name() = 'name'])">
					<xsl:apply-templates select="@type"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose> -->
		<xsl:variable name="name">
			<xsl:apply-templates select="*[local-name() = 'name']"/>
		</xsl:variable>
		<xsl:copy-of select="$name"/>
		<xsl:if test="normalize-space($name) != ''">
			<xsl:value-of select="$sep"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'admonition']/*[local-name() = 'name']">
		<xsl:apply-templates/>
	</xsl:template>

	<!-- <xsl:template match="*[local-name() = 'admonition']/@type">
		<xsl:variable name="admonition_type_">
			<xsl:call-template name="getLocalizedString">
				<xsl:with-param name="key">admonition.<xsl:value-of select="."/></xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="admonition_type" select="normalize-space(java:toUpperCase(java:java.lang.String.new($admonition_type_)))"/>
		<xsl:value-of select="$admonition_type"/>
		<xsl:if test="$admonition_type = ''">
			<xsl:value-of select="java:toUpperCase(java:java.lang.String.new(.))"/>
		</xsl:if>
	</xsl:template> -->

	<xsl:template match="*[local-name() = 'admonition']/*[local-name() = 'p']">

				<fo:block xsl:use-attribute-sets="admonition-p-style">

					<xsl:apply-templates/>
				</fo:block>

	</xsl:template>

	<!-- ================ -->
	<!-- END Admonition -->
	<!-- ================ -->

	<!-- ===================================== -->
	<!-- Update xml -->
	<!-- ===================================== -->

	<xsl:template name="updateXML">
		<xsl:if test="$debug = 'true'"><xsl:message>START updated_xml_step1</xsl:message></xsl:if>
		<xsl:variable name="startTime1" select="java:getTime(java:java.util.Date.new())"/>

		<!-- STEP1: Re-order elements in 'preface', 'sections' based on @displayorder -->
		<xsl:variable name="updated_xml_step1">
			<xsl:if test="$table_if = 'false'">
				<xsl:apply-templates mode="update_xml_step1"/>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="endTime1" select="java:getTime(java:java.util.Date.new())"/>
		<xsl:if test="$debug = 'true'">
			<xsl:message>DEBUG: processing time <xsl:value-of select="$endTime1 - $startTime1"/> msec.</xsl:message>
			<xsl:message>END updated_xml_step1</xsl:message>
			<!-- <redirect:write file="updated_xml_step1_{java:getTime(java:java.util.Date.new())}.xml">
				<xsl:copy-of select="$updated_xml_step1"/>
			</redirect:write> -->
		</xsl:if>

		<xsl:if test="$debug = 'true'"><xsl:message>START updated_xml_step2</xsl:message></xsl:if>
		<xsl:variable name="startTime2" select="java:getTime(java:java.util.Date.new())"/>

		<!-- STEP2: add 'fn' after 'eref' and 'origin', if referenced to bibitem with 'note' = Withdrawn.' or 'Cancelled and replaced...'  -->
		<xsl:variable name="updated_xml_step2">

					<xsl:if test="$table_if = 'false'">
						<xsl:apply-templates select="xalan:nodeset($updated_xml_step1)" mode="update_xml_step2"/>
					</xsl:if>

		</xsl:variable>

		<xsl:variable name="endTime2" select="java:getTime(java:java.util.Date.new())"/>
		<xsl:if test="$debug = 'true'">
			<xsl:message>DEBUG: processing time <xsl:value-of select="$endTime2 - $startTime2"/> msec.</xsl:message>
			<xsl:message>END updated_xml_step2</xsl:message>
			<!-- <redirect:write file="updated_xml_step2_{java:getTime(java:java.util.Date.new())}.xml">
				<xsl:copy-of select="$updated_xml_step2"/>
			</redirect:write> -->
		</xsl:if>

		<xsl:if test="$debug = 'true'"><xsl:message>START updated_xml_step3</xsl:message></xsl:if>
		<xsl:variable name="startTime3" select="java:getTime(java:java.util.Date.new())"/>

		<xsl:variable name="updated_xml_step3">
			<xsl:choose>
				<xsl:when test="$table_if = 'false'">
					<xsl:apply-templates select="xalan:nodeset($updated_xml_step2)" mode="update_xml_enclose_keep-together_within-line"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="update_xml_enclose_keep-together_within-line"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="endTime3" select="java:getTime(java:java.util.Date.new())"/>
		<xsl:if test="$debug = 'true'">
			<xsl:message>DEBUG: processing time <xsl:value-of select="$endTime3 - $startTime3"/> msec.</xsl:message>
			<xsl:message>END updated_xml_step3</xsl:message>
			<!-- <redirect:write file="updated_xml_step3_{java:getTime(java:java.util.Date.new())}.xml">
				<xsl:copy-of select="$updated_xml_step3"/>
			</redirect:write> -->
		</xsl:if>

		<!-- <xsl:if test="$debug = 'true'"><xsl:message>START copying updated_xml_step3</xsl:message></xsl:if>
		<xsl:variable name="startTime4" select="java:getTime(java:java.util.Date.new())"/>  -->
		<xsl:copy-of select="$updated_xml_step3"/>
		<!-- <xsl:variable name="endTime4" select="java:getTime(java:java.util.Date.new())"/>
		<xsl:if test="$debug = 'true'">
			<xsl:message>DEBUG: processing time <xsl:value-of select="$endTime4 - $startTime4"/> msec.</xsl:message>
			<xsl:message>END copying updated_xml_step3</xsl:message>
		</xsl:if> -->

	</xsl:template>

	<!-- =========================================================================== -->
	<!-- STEP1:  -->
	<!--   - Re-order elements in 'preface', 'sections' based on @displayorder -->
	<!--   - Put Section title in the correct position -->
	<!--   - Ignore 'span' without style -->
	<!--   - Remove semantic xml part -->
	<!--   - Remove image/emf (EMF vector image for Word) -->
	<!--   - add @id, redundant for table auto-layout algorithm -->
	<!--   - process 'passthrough' element -->
	<!--   - split math by element with @linebreak into maths -->
	<!--   - rename fmt-title to title, fmt-name to name and another changes to convert new presentation XML to  -->
	<!--   - old XML without significant changes in XSLT -->
	<!-- =========================================================================== -->
	<xsl:template match="@*|node()" mode="update_xml_step1">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="update_xml_step1"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()" mode="update_xml_pres">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="update_xml_pres"/>
		</xsl:copy>
	</xsl:template>

	<!-- change section's order based on @displayorder value -->
	<xsl:template match="*[local-name() = 'preface']" mode="update_xml_step1">
		<xsl:copy>
			<xsl:copy-of select="@*"/>

			<xsl:variable name="nodes_preface_">
				<xsl:for-each select="*">
					<node id="{@id}"/>
				</xsl:for-each>
			</xsl:variable>
			<xsl:variable name="nodes_preface" select="xalan:nodeset($nodes_preface_)"/>

			<xsl:for-each select="*">
				<xsl:sort select="@displayorder" data-type="number"/>

				<!-- process Section's title -->
				<xsl:variable name="preceding-sibling_id" select="$nodes_preface/node[@id = current()/@id]/preceding-sibling::node[1]/@id"/>
				<xsl:if test="$preceding-sibling_id != ''">
					<xsl:apply-templates select="parent::*/*[@type = 'section-title' and @id = $preceding-sibling_id and not(@displayorder)]" mode="update_xml_step1"/>
				</xsl:if>

				<xsl:choose>
					<xsl:when test="@type = 'section-title' and not(@displayorder)"><!-- skip, don't copy, because copied in above 'apply-templates' --></xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="update_xml_step1"/>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'sections']" mode="update_xml_step1">
		<xsl:copy>
			<xsl:copy-of select="@*"/>

			<xsl:variable name="nodes_sections_">
				<xsl:for-each select="*">
					<node id="{@id}"/>
				</xsl:for-each>
			</xsl:variable>
			<xsl:variable name="nodes_sections" select="xalan:nodeset($nodes_sections_)"/>

			<!-- move section 'Normative references' inside 'sections' -->
			<xsl:for-each select="* |      ancestor::*[local-name() = 'metanorma']/*[local-name()='bibliography']/*[local-name()='references'][@normative='true'] |     ancestor::*[local-name() = 'metanorma']/*[local-name()='bibliography']/*[local-name()='clause'][*[local-name()='references'][@normative='true']]">
				<xsl:sort select="@displayorder" data-type="number"/>

				<!-- process Section's title -->
				<xsl:variable name="preceding-sibling_id" select="$nodes_sections/node[@id = current()/@id]/preceding-sibling::node[1]/@id"/>
				<xsl:if test="$preceding-sibling_id != ''">
					<xsl:apply-templates select="parent::*/*[@type = 'section-title' and @id = $preceding-sibling_id and not(@displayorder)]" mode="update_xml_step1"/>
				</xsl:if>

				<xsl:choose>
					<xsl:when test="@type = 'section-title' and not(@displayorder)"><!-- skip, don't copy, because copied in above 'apply-templates' --></xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="update_xml_step1"/>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'bibliography']" mode="update_xml_step1">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<!-- copy all elements from bibliography except 'Normative references' (moved to 'sections') -->
			<xsl:for-each select="*[not(@normative='true') and not(*[@normative='true'])]">
				<xsl:sort select="@displayorder" data-type="number"/>
				<xsl:apply-templates select="." mode="update_xml_step1"/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<!-- Example with 'class': <span class="stdpublisher">ISO</span> <span class="stddocNumber">10303</span>-<span class="stddocPartNumber">1</span>:<span class="stdyear">1994</span> -->
	<xsl:template match="*[local-name() = 'span'][@style or @class = 'stdpublisher' or @class = 'stddocNumber' or @class = 'stddocPartNumber' or @class = 'stdyear' or @class = 'horizontal' or @class = 'norotate' or @class = 'halffontsize']" mode="update_xml_step1" priority="2">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_step1"/>
		</xsl:copy>
	</xsl:template>
	<!-- Note: to enable the addition of character span markup with semantic styling for DIS Word output -->
	<xsl:template match="*[local-name() = 'span']" mode="update_xml_step1">
		<xsl:apply-templates mode="update_xml_step1"/>
	</xsl:template>
	<xsl:template match="*[local-name() = 'sections']/*[local-name() = 'p'][starts-with(@class, 'zzSTDTitle')]/*[local-name() = 'span'][@class] | *[local-name() = 'sourcecode']//*[local-name() = 'span'][@class]" mode="update_xml_step1" priority="2">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_step1"/>
		</xsl:copy>
	</xsl:template>

	<!-- remove semantic xml -->
	<xsl:template match="*[local-name() = 'metanorma-extension']/*[local-name() = 'metanorma']/*[local-name() = 'source']" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'metanorma-extension']/*[local-name() = 'metanorma']/*[local-name() = 'source']" mode="update_xml_pres"/>

	<!-- remove image/emf -->
	<xsl:template match="*[local-name() = 'image']/*[local-name() = 'emf']" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'image']/*[local-name() = 'emf']" mode="update_xml_pres"/>

	<!-- remove preprocess-xslt -->
	<xsl:template match="*[local-name() = 'preprocess-xslt']" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'preprocess-xslt']" mode="update_xml_pres"/>

	<xsl:template match="*[local-name() = 'stem']" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'stem']" mode="update_xml_pres"/>

	<xsl:template match="*[local-name() = 'fmt-stem'][not(.//*[local-name() = 'passthrough']) and not(.//*[@linebreak])]" mode="update_xml_step1">
		<xsl:element name="stem" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:choose>
				<xsl:when test="*[local-name() = 'semx'] and count(node()) = 1">
					<xsl:copy-of select="*[local-name() = 'semx']/node()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="node()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	<xsl:template match="*[local-name() = 'fmt-stem'][not(.//*[local-name() = 'passthrough']) and not(.//*[@linebreak])]" mode="update_xml_pres">
		<xsl:element name="stem" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:choose>
				<xsl:when test="*[local-name() = 'semx'] and count(node()) = 1">
					<xsl:copy-of select="*[local-name() = 'semx']/node()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="node()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*[local-name() = 'image'][not(.//*[local-name() = 'passthrough'])] |        *[local-name() = 'bibdata'][not(.//*[local-name() = 'passthrough'])] |        *[local-name() = 'localized-strings']" mode="update_xml_step1">
		<xsl:copy-of select="."/>
	</xsl:template>

	<!-- https://github.com/metanorma/isodoc/issues/651 -->
	<!-- *[local-name() = 'sourcecode'][not(.//*[local-name() = 'passthrough']) and not(.//*[local-name() = 'fmt-name'])] -->
	<xsl:template match="*[local-name() = 'sourcecode']" mode="update_xml_step1">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="*[local-name() = 'fmt-name']" mode="update_xml_step1"/>
			<xsl:choose>
				<xsl:when test="*[local-name() = 'fmt-sourcecode']">
					<xsl:choose>
						<xsl:when test="*[local-name() = 'fmt-sourcecode'][not(.//*[local-name() = 'passthrough'])] and not(.//*[local-name() = 'fmt-name'])">
							<xsl:copy-of select="*[local-name() = 'fmt-sourcecode']/node()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="*[local-name() = 'fmt-sourcecode']/node()" mode="update_xml_step1"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise> <!-- If fmt-sourcecode is not present -->
					<xsl:choose>
						<xsl:when test="not(.//*[local-name() = 'passthrough']) and not(.//*[local-name() = 'fmt-name'])">
							<xsl:copy-of select="node()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="node()[not(local-name() = 'fmt-name')]" mode="update_xml_step1"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="*[local-name() = 'sourcecode']" mode="update_xml_pres">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="*[local-name() = 'fmt-name']" mode="update_xml_pres"/>
			<xsl:choose>
				<xsl:when test="*[local-name() = 'fmt-sourcecode']">
					<xsl:choose>
						<xsl:when test="*[local-name() = 'fmt-sourcecode'][not(.//*[local-name() = 'passthrough'])] and not(.//*[local-name() = 'fmt-name'])">
							<xsl:copy-of select="*[local-name() = 'fmt-sourcecode']/node()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="*[local-name() = 'fmt-sourcecode']/node()" mode="update_xml_pres"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise> <!-- If fmt-sourcecode is not present -->
					<xsl:choose>
						<xsl:when test="not(.//*[local-name() = 'passthrough']) and not(.//*[local-name() = 'fmt-name'])">
							<xsl:copy-of select="node()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="node()[not(local-name() = 'fmt-name')]" mode="update_xml_pres"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<!-- https://github.com/metanorma/isodoc/issues/651 -->
	<xsl:template match="*[local-name() = 'figure'][*[local-name() = 'fmt-figure']]" mode="update_xml_step1" priority="2">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="*[local-name() = 'fmt-name']" mode="update_xml_step1"/>
			<xsl:apply-templates select="*[local-name() = 'fmt-figure']/node()" mode="update_xml_step1"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="*[local-name() = 'figure'][*[local-name() = 'fmt-figure']]" mode="update_xml_pres" priority="2">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="*[local-name() = 'fmt-name']" mode="update_xml_pres"/>
			<xsl:apply-templates select="*[local-name() = 'fmt-figure']/node()" mode="update_xml_pres"/>
		</xsl:copy>
	</xsl:template>

	<!-- https://github.com/metanorma/isodoc/issues/652 -->
	<xsl:template match="*[local-name() = 'quote']/*[local-name() = 'source']"/>
	<xsl:template match="*[local-name() = 'quote']/*[local-name() = 'author']"/>
	<xsl:template match="*[local-name() = 'amend']"/>
	<xsl:template match="*[local-name() = 'quote']/*[local-name() = 'source']" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'quote']/*[local-name() = 'author']" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'quote']/*[local-name() = 'source']" mode="update_xml_pres"/>
	<xsl:template match="*[local-name() = 'quote']/*[local-name() = 'author']" mode="update_xml_pres"/>
	<xsl:template match="*[local-name() = 'amend']" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'amend']" mode="update_xml_pres"/>

	<xsl:template match="*[local-name() = 'metanorma-extension']/*[local-name() = 'attachment']" mode="update_xml_step1">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:if test="1 = 2"> <!-- remove attachment/text(), because attachments added in the template 'addPDFUAmeta' before applying 'update_xml_step1' -->
				<xsl:variable name="name_filepath" select="concat($inputxml_basepath, @name)"/>
				<xsl:variable name="file_exists" select="normalize-space(java:exists(java:java.io.File.new($name_filepath)))"/>
				<xsl:if test="$file_exists = 'false'"> <!-- copy attachment content only if file on disk doesnt exist -->
					<xsl:value-of select="normalize-space(.)"/>
				</xsl:if>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<!-- add @id, mandatory for table auto-layout algorithm -->
	<xsl:template match="*[local-name() = 'dl' or local-name() = 'table'][not(@id)]" mode="update_xml_step1">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:call-template name="add_id"/>
			<xsl:apply-templates mode="update_xml_step1"/>
		</xsl:copy>
	</xsl:template>

	<!-- prevent empty thead processing in XSL-FO, remove it -->
	<xsl:template match="*[local-name() = 'table']/*[local-name() = 'thead'][count(*) = 0]" mode="update_xml_step1"/>

	<xsl:template name="add_id">
		<xsl:if test="not(@id)">
			<!-- add @id - first element with @id plus '_element_name' -->
			<xsl:variable name="prefix_id_" select="(.//*[@id])[1]/@id"/>
			<xsl:variable name="prefix_id"><xsl:value-of select="$prefix_id_"/><xsl:if test="normalize-space($prefix_id_) = ''"><xsl:value-of select="generate-id()"/></xsl:if></xsl:variable>
			<xsl:variable name="document_suffix" select="ancestor::*[local-name() = 'metanorma']/@document_suffix"/>
			<xsl:attribute name="id"><xsl:value-of select="concat($prefix_id, '_', local-name(), '_', $document_suffix)"/></xsl:attribute>
		</xsl:if>
	</xsl:template>

	<!-- optimization: remove clause if table_only_with_id isn't empty and clause doesn't contain table or dl with table_only_with_id -->
	<xsl:template match="*[local-name() = 'clause' or local-name() = 'p' or local-name() = 'definitions' or local-name() = 'annex']" mode="update_xml_step1">
		<xsl:choose>
			<xsl:when test="($table_only_with_id != '' or $table_only_with_ids != '') and local-name() = 'p' and (ancestor::*[local-name() = 'table' or local-name() = 'dl' or local-name() = 'toc'])">
				<xsl:copy>
					<xsl:copy-of select="@*"/>
					<xsl:apply-templates mode="update_xml_step1"/>
				</xsl:copy>
			</xsl:when>
			<!-- for table auto-layout algorithm -->
			<xsl:when test="$table_only_with_id != '' and not(.//*[local-name() = 'table' or local-name() = 'dl'][@id = $table_only_with_id])">
				<xsl:copy>
					<xsl:copy-of select="@*"/>
				</xsl:copy>
			</xsl:when>
			<!-- for table auto-layout algorithm -->
			<xsl:when test="$table_only_with_ids != '' and not(.//*[local-name() = 'table' or local-name() = 'dl'][contains($table_only_with_ids, concat(@id, ' '))])">
				<xsl:copy>
					<xsl:copy-of select="@*"/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:copy-of select="@*"/>
					<xsl:apply-templates mode="update_xml_step1"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:variable name="regex_passthrough">.*\bpdf\b.*</xsl:variable>
	<xsl:template match="*[local-name() = 'passthrough']" mode="update_xml_step1">
		<!-- <xsl:if test="contains(@formats, ' pdf ')"> -->
		<xsl:if test="normalize-space(java:matches(java:java.lang.String.new(@formats), $regex_passthrough)) = 'true'">
			<xsl:apply-templates mode="update_xml_step1"/>
		</xsl:if>
	</xsl:template>

	<!-- split math by element with @linebreak into maths -->
	<xsl:template match="mathml:math[.//mathml:mo[@linebreak] or .//mathml:mspace[@linebreak]]" mode="update_xml_step1">
		<xsl:variable name="maths">
			<xsl:apply-templates select="." mode="mathml_linebreak"/>
		</xsl:variable>
		<xsl:copy-of select="$maths"/>
	</xsl:template>

	<!-- update new Presentation XML -->
	<xsl:template match="*[local-name() = 'title'][following-sibling::*[1][local-name() = 'fmt-title']]" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'title'][following-sibling::*[1][local-name() = 'fmt-title']]" mode="update_xml_pres"/>
	<xsl:template match="*[local-name() = 'name'][following-sibling::*[1][local-name() = 'fmt-name']]" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'name'][following-sibling::*[1][local-name() = 'fmt-name']]" mode="update_xml_pres"/>
	<xsl:template match="*[local-name() = 'section-title'][following-sibling::*[1][local-name() = 'p'][@type = 'section-title' or @type = 'floating-title']]" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'section-title'][following-sibling::*[1][local-name() = 'p'][@type = 'section-title' or @type = 'floating-title']]" mode="update_xml_pres"/>
	<!-- <xsl:template match="*[local-name() = 'preferred'][following-sibling::*[not(local-name() = 'preferred')][1][local-name() = 'fmt-preferred']]" mode="update_xml_step1"/> -->
	<xsl:template match="*[local-name() = 'preferred']" mode="update_xml_step1"/>
	<!-- <xsl:template match="*[local-name() = 'preferred'][following-sibling::*[not(local-name() = 'preferred')][1][local-name() = 'fmt-preferred']]" mode="update_xml_pres"/> -->
	<xsl:template match="*[local-name() = 'preferred']" mode="update_xml_pres"/>
	<!-- <xsl:template match="*[local-name() = 'admitted'][following-sibling::*[not(local-name() = 'admitted')][1][local-name() = 'fmt-admitted']]" mode="update_xml_step1"/> -->
	<xsl:template match="*[local-name() = 'admitted']" mode="update_xml_step1"/>
	<!-- <xsl:template match="*[local-name() = 'admitted'][following-sibling::*[not(local-name() = 'admitted')][1][local-name() = 'fmt-admitted']]" mode="update_xml_pres"/> -->
	<xsl:template match="*[local-name() = 'admitted']" mode="update_xml_pres"/>
	<!-- <xsl:template match="*[local-name() = 'deprecates'][following-sibling::*[not(local-name() = 'deprecates')][1][local-name() = 'fmt-deprecates']]" mode="update_xml_step1"/> -->
	<xsl:template match="*[local-name() = 'deprecates']" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'related']" mode="update_xml_step1"/>
	<!-- <xsl:template match="*[local-name() = 'deprecates'][following-sibling::*[not(local-name() = 'deprecates')][1][local-name() = 'fmt-deprecates']]" mode="update_xml_pres"/> -->
	<xsl:template match="*[local-name() = 'deprecates']" mode="update_xml_pres"/>
	<xsl:template match="*[local-name() = 'related']" mode="update_xml_pres"/>
	<!-- <xsl:template match="*[local-name() = 'definition'][following-sibling::*[1][local-name() = 'fmt-definition']]" mode="update_xml_step1"/> -->
	<xsl:template match="*[local-name() = 'definition']" mode="update_xml_step1"/>
	<!-- <xsl:template match="*[local-name() = 'definition'][following-sibling::*[1][local-name() = 'fmt-definition']]" mode="update_xml_pres"/> -->
	<xsl:template match="*[local-name() = 'definition']" mode="update_xml_pres"/>
	<!-- <xsl:template match="*[local-name() = 'termsource'][following-sibling::*[1][local-name() = 'fmt-termsource']]" mode="update_xml_step1"/> -->
	<xsl:template match="*[local-name() = 'termsource']" mode="update_xml_step1"/>
	<!-- <xsl:template match="*[local-name() = 'termsource'][following-sibling::*[1][local-name() = 'fmt-termsource']]" mode="update_xml_pres"/> -->
	<xsl:template match="*[local-name() = 'termsource']" mode="update_xml_pres"/>

	<xsl:template match="*[local-name() = 'term'][@unnumbered = 'true'][not(.//*[starts-with(local-name(), 'fmt-')])]" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'term'][@unnumbered = 'true'][not(.//*[starts-with(local-name(), 'fmt-')])]" mode="update_xml_pres"/>

	<xsl:template match="*[local-name() = 'p'][@type = 'section-title' or @type = 'floating-title'][preceding-sibling::*[1][local-name() = 'section-title']]" mode="update_xml_step1">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="update_xml_step1"/>
			<xsl:copy-of select="preceding-sibling::*[1][local-name() = 'section-title']/@depth"/>
			<xsl:apply-templates select="node()" mode="update_xml_step1"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="*[local-name() = 'p'][@type = 'section-title' or @type = 'floating-title'][preceding-sibling::*[1][local-name() = 'section-title']]" mode="update_xml_pres">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="update_xml_pres"/>
			<xsl:copy-of select="preceding-sibling::*[1][local-name() = 'section-title']/@depth"/>
			<xsl:apply-templates select="node()" mode="update_xml_pres"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'fmt-title']"/>
	<xsl:template match="*[local-name() = 'fmt-title']" mode="update_xml_step1">
		<xsl:element name="title" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_step1"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="*[local-name() = 'fmt-title']" mode="update_xml_pres">
		<xsl:element name="title" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_pres"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*[local-name() = 'fmt-name']"/>
	<xsl:template match="*[local-name() = 'fmt-name']" mode="update_xml_step1">
		<xsl:choose>
			<xsl:when test="local-name(..) = 'p' and ancestor::*[local-name() = 'table']">
				<xsl:apply-templates mode="update_xml_step1"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="name" namespace="{$namespace_full}">
					<xsl:copy-of select="@*"/>
					<xsl:apply-templates mode="update_xml_step1"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="*[local-name() = 'fmt-name']" mode="update_xml_pres">
		<xsl:choose>
			<xsl:when test="local-name(..) = 'p' and ancestor::*[local-name() = 'table']">
				<xsl:apply-templates mode="update_xml_step1"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="name" namespace="{$namespace_full}">
					<xsl:copy-of select="@*"/>
					<xsl:apply-templates mode="update_xml_pres"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- li/fmt-name -->
	<xsl:template match="*[local-name() = 'li']/*[local-name() = 'fmt-name']" priority="2" mode="update_xml_step1">
		<xsl:attribute name="label"><xsl:value-of select="."/></xsl:attribute>
		<xsl:attribute name="full">true</xsl:attribute>
	</xsl:template>
	<xsl:template match="*[local-name() = 'li']/*[local-name() = 'fmt-name']" priority="2" mode="update_xml_pres">
		<xsl:attribute name="label"><xsl:value-of select="."/></xsl:attribute>
		<xsl:attribute name="full">true</xsl:attribute>
	</xsl:template>

	<xsl:template match="*[local-name() = 'fmt-preferred']"/>
	<xsl:template match="*[local-name() = 'fmt-preferred'][*[local-name() = 'p']]" mode="update_xml_step1">
		<xsl:apply-templates mode="update_xml_step1"/>
	</xsl:template>
	<xsl:template match="*[local-name() = 'fmt-preferred'][not(*[local-name() = 'p'])] | *[local-name() = 'fmt-preferred']/*[local-name() = 'p']" mode="update_xml_step1">
		<xsl:element name="preferred" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_step1"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="*[local-name() = 'fmt-preferred'][*[local-name() = 'p']]" mode="update_xml_pres">
		<xsl:apply-templates mode="update_xml_pres"/>
	</xsl:template>
	<xsl:template match="*[local-name() = 'fmt-preferred'][not(*[local-name() = 'p'])] | *[local-name() = 'fmt-preferred']/*[local-name() = 'p']" mode="update_xml_pres">
		<xsl:element name="preferred" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_pres"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*[local-name() = 'fmt-admitted']"/>
	<xsl:template match="*[local-name() = 'fmt-admitted'][*[local-name() = 'p']]" mode="update_xml_step1">
		<xsl:apply-templates mode="update_xml_step1"/>
	</xsl:template>
	<xsl:template match="*[local-name() = 'fmt-admitted'][not(*[local-name() = 'p'])] | *[local-name() = 'fmt-admitted']/*[local-name() = 'p']" mode="update_xml_step1">
		<xsl:element name="admitted" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_step1"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="*[local-name() = 'fmt-admitted'][*[local-name() = 'p']]" mode="update_xml_pres">
		<xsl:apply-templates mode="update_xml_pres"/>
	</xsl:template>
	<xsl:template match="*[local-name() = 'fmt-admitted'][not(*[local-name() = 'p'])] | *[local-name() = 'fmt-admitted']/*[local-name() = 'p']" mode="update_xml_pres">
		<xsl:element name="admitted" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_pres"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*[local-name() = 'fmt-deprecates']"/>
	<xsl:template match="*[local-name() = 'fmt-deprecates'][*[local-name() = 'p']]" mode="update_xml_step1">
		<xsl:apply-templates mode="update_xml_step1"/>
	</xsl:template>
	<xsl:template match="*[local-name() = 'fmt-deprecates'][not(*[local-name() = 'p'])] | *[local-name() = 'fmt-deprecates']/*[local-name() = 'p']" mode="update_xml_step1">
		<xsl:element name="deprecates" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_step1"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="*[local-name() = 'fmt-deprecates'][*[local-name() = 'p']]" mode="update_xml_pres">
		<xsl:apply-templates mode="update_xml_pres"/>
	</xsl:template>
	<xsl:template match="*[local-name() = 'fmt-deprecates'][not(*[local-name() = 'p'])] | *[local-name() = 'fmt-deprecates']/*[local-name() = 'p']" mode="update_xml_pres">
		<xsl:element name="deprecates" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_pres"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*[local-name() = 'fmt-definition']"/>
	<xsl:template match="*[local-name() = 'fmt-definition']" mode="update_xml_step1">
		<xsl:element name="definition" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_step1"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="*[local-name() = 'fmt-definition']" mode="update_xml_pres">
		<xsl:element name="definition" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_pres"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*[local-name() = 'fmt-termsource']"/>
	<xsl:template match="*[local-name() = 'fmt-termsource']" mode="update_xml_step1">
		<xsl:element name="termsource" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_step1"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="*[local-name() = 'fmt-termsource']" mode="update_xml_pres">
		<xsl:element name="termsource" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_pres"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*[local-name() = 'span'][                @class = 'fmt-caption-label' or                 @class = 'fmt-element-name' or                @class = 'fmt-caption-delim' or                @class = 'fmt-autonum-delim']" mode="update_xml_step1" priority="3">
		<xsl:apply-templates mode="update_xml_step1"/>
	</xsl:template>
	<xsl:template match="*[local-name() = 'span'][                @class = 'fmt-caption-label' or                 @class = 'fmt-element-name' or                @class = 'fmt-caption-delim' or                @class = 'fmt-autonum-delim']" mode="update_xml_pres" priority="3">
		<xsl:apply-templates mode="update_xml_pres"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'semx']">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="*[local-name() = 'semx']" mode="update_xml_step1">
		<xsl:apply-templates mode="update_xml_step1"/>
	</xsl:template>
	<xsl:template match="*[local-name() = 'semx']" mode="update_xml_pres">
		<xsl:apply-templates mode="update_xml_pres"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'fmt-xref-label']"/>
	<xsl:template match="*[local-name() = 'fmt-xref-label']" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'fmt-xref-label']" mode="update_xml_pres"/>

	<xsl:template match="*[local-name() = 'requirement'] | *[local-name() = 'recommendation'] | *[local-name() = 'permission']" mode="update_xml_step1">
		<xsl:apply-templates mode="update_xml_step1"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'requirement'] | *[local-name() = 'recommendation'] | *[local-name() = 'permission']" mode="update_xml_pres">
		<xsl:apply-templates mode="update_xml_pres"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'requirement']/*[not(starts-with(local-name(), 'fmt-'))] |             *[local-name() = 'recommendation']/*[not(starts-with(local-name(), 'fmt-'))] |              *[local-name() = 'permission']/*[not(starts-with(local-name(), 'fmt-'))]" mode="update_xml_step1"/>

	<xsl:template match="*[local-name() = 'requirement']/*[not(starts-with(local-name(), 'fmt-'))] |             *[local-name() = 'recommendation']/*[not(starts-with(local-name(), 'fmt-'))] |              *[local-name() = 'permission']/*[not(starts-with(local-name(), 'fmt-'))]" mode="update_xml_pres"/>

	<xsl:template match="*[local-name() = 'fmt-provision']" mode="update_xml_step1">
		<xsl:apply-templates mode="update_xml_step1"/>
	</xsl:template>
	<xsl:template match="*[local-name() = 'fmt-provision']" mode="update_xml_pres">
		<xsl:apply-templates mode="update_xml_pres"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'identifier']" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'identifier']" mode="update_xml_pres"/>
	<xsl:template match="*[local-name() = 'fmt-identifier']" mode="update_xml_step1">
		<xsl:element name="identifier" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_step1"/>
		</xsl:element>
	</xsl:template>
  <xsl:template match="*[local-name() = 'fmt-identifier']" mode="update_xml_pres">
		<xsl:element name="identifier" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_pres"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*[local-name() = 'concept']"/>
	<xsl:template match="*[local-name() = 'concept']" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'concept']" mode="update_xml_pres"/>

	<xsl:template match="*[local-name() = 'fmt-concept']">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="*[local-name() = 'fmt-concept']" mode="update_xml_step1">
		<xsl:apply-templates mode="update_xml_step1"/>
	</xsl:template>
	<xsl:template match="*[local-name() = 'fmt-concept']" mode="update_xml_pres">
		<xsl:apply-templates mode="update_xml_pres"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'eref']" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'eref']" mode="update_xml_pres"/>

	<xsl:template match="*[local-name() = 'fmt-eref']" mode="update_xml_step1">
		<xsl:element name="eref" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_step1"/>
		</xsl:element>
	</xsl:template>
  <xsl:template match="*[local-name() = 'fmt-eref']" mode="update_xml_pres">
		<xsl:element name="eref" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_pres"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*[local-name() = 'xref']" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'xref']" mode="update_xml_pres"/>

	<xsl:template match="*[local-name() = 'fmt-xref']" mode="update_xml_step1">
		<xsl:element name="xref" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_step1"/>
		</xsl:element>
	</xsl:template>
  <xsl:template match="*[local-name() = 'fmt-xref']" mode="update_xml_pres">
		<xsl:element name="xref" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_pres"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*[local-name() = 'link']" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'link']" mode="update_xml_pres"/>

	<xsl:template match="*[local-name() = 'fmt-link']" mode="update_xml_step1">
		<xsl:element name="link" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_step1"/>
		</xsl:element>
	</xsl:template>
  <xsl:template match="*[local-name() = 'fmt-link']" mode="update_xml_pres">
		<xsl:element name="link" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_pres"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*[local-name() = 'origin']" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'origin']" mode="update_xml_pres"/>

	<xsl:template match="*[local-name() = 'fmt-origin']" mode="update_xml_step1">
		<xsl:element name="origin" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_step1"/>
		</xsl:element>
	</xsl:template>
  <xsl:template match="*[local-name() = 'fmt-origin']" mode="update_xml_pres">
		<xsl:element name="origin" namespace="{$namespace_full}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update_xml_pres"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*[local-name() = 'erefstack']"/>
	<xsl:template match="*[local-name() = 'erefstack']" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'erefstack']" mode="update_xml_pres"/>

	<xsl:template match="*[local-name() = 'svgmap']"/>
	<xsl:template match="*[local-name() = 'svgmap']" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'svgmap']" mode="update_xml_pres"/>

	<xsl:template match="*[local-name() = 'review-container']" mode="update_xml_step1"/>
	<xsl:template match="*[local-name() = 'review-container']" mode="update_xml_pres"/>

	<!-- END: update new Presentation XML -->

	<!-- =========================================================================== -->
	<!-- END STEP1: Re-order elements in 'preface', 'sections' based on @displayorder -->
	<!-- =========================================================================== -->

	<!-- =========================================================================== -->
	<!-- STEP MOVE PAGEBREAK: move <pagebreak/> at top level under 'preface' and 'sections' -->
	<!-- =========================================================================== -->
	<xsl:template match="@*|node()" mode="update_xml_step_move_pagebreak">
		<xsl:param name="page_sequence_at_top">false</xsl:param>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="update_xml_step_move_pagebreak">
				<xsl:with-param name="page_sequence_at_top" select="$page_sequence_at_top"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<!-- replace 'pagebreak' by closing tags + page_sequence and  opening page_sequence + tags -->
	<xsl:template match="*[local-name() = 'pagebreak'][not(following-sibling::*[1][local-name() = 'pagebreak'])]" mode="update_xml_step_move_pagebreak">
		<xsl:param name="page_sequence_at_top"/>
		<!-- <xsl:choose>
			<xsl:when test="ancestor::*[local-name() = 'sections']">
			
			</xsl:when>
			<xsl:when test="ancestor::*[local-name() = 'annex']">
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose> -->

		<!-- determine pagebreak is last element before </fo:flow> or not -->
		<xsl:variable name="isLast">
			<xsl:for-each select="ancestor-or-self::*[ancestor::*[local-name() = 'preface'] or ancestor::*[local-name() = 'sections'] or ancestor-or-self::*[local-name() = 'annex']]">
				<xsl:if test="following-sibling::*">false</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<xsl:if test="contains($isLast, 'false')">

			<xsl:variable name="orientation" select="normalize-space(@orientation)"/>

			<xsl:variable name="tree_">
				<xsl:call-template name="makeAncestorsElementsTree">
					<xsl:with-param name="page_sequence_at_top" select="$page_sequence_at_top"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="tree" select="xalan:nodeset($tree_)"/>

			<!-- close fo:page-sequence (closing preceding fo elements) -->
			<xsl:call-template name="insertClosingElements">
				<xsl:with-param name="tree" select="$tree"/>
			</xsl:call-template>

			<xsl:text disable-output-escaping="yes">&lt;/page_sequence&gt;</xsl:text>

			<!-- create a new page_sequence (opening elements) -->
			<xsl:text disable-output-escaping="yes">&lt;page_sequence xmlns="</xsl:text><xsl:value-of select="$namespace_full"/>"<xsl:if test="$orientation != ''"> orientation="<xsl:value-of select="$orientation"/>"</xsl:if><xsl:text disable-output-escaping="yes">&gt;</xsl:text>

			<xsl:call-template name="insertOpeningElements">
				<xsl:with-param name="tree" select="$tree"/>
			</xsl:call-template>

		</xsl:if>
	</xsl:template>

	<xsl:template name="makeAncestorsElementsTree">
		<xsl:param name="page_sequence_at_top"/>

		<xsl:choose>
			<xsl:when test="$page_sequence_at_top = 'true'">
				<xsl:for-each select="ancestor::*[ancestor::*[local-name() = 'metanorma']]">
					<element pos="{position()}">
						<xsl:copy-of select="@*[local-name() != 'id']"/>
						<xsl:value-of select="name()"/>
					</element>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="ancestor::*[ancestor::*[local-name() = 'preface'] or ancestor::*[local-name() = 'sections'] or ancestor-or-self::*[local-name() = 'annex']]">
					<element pos="{position()}">
						<xsl:copy-of select="@*[local-name() != 'id']"/>
						<xsl:value-of select="name()"/>
					</element>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="insertClosingElements">
		<xsl:param name="tree"/>
		<xsl:for-each select="$tree//element">
			<xsl:sort data-type="number" order="descending" select="@pos"/>
			<xsl:text disable-output-escaping="yes">&lt;/</xsl:text>
				<xsl:value-of select="."/>
			<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
			<xsl:if test="$debug = 'true'">
				<xsl:message>&lt;/<xsl:value-of select="."/>&gt;</xsl:message>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="insertOpeningElements">
		<xsl:param name="tree"/>
		<xsl:param name="xmlns"/>
		<xsl:param name="add_continue">true</xsl:param>
		<xsl:for-each select="$tree//element">
			<xsl:text disable-output-escaping="yes">&lt;</xsl:text>
				<xsl:value-of select="."/>
				<xsl:for-each select="@*[local-name() != 'pos']">
					<xsl:text> </xsl:text>
					<xsl:value-of select="local-name()"/>
					<xsl:text>="</xsl:text>
					<xsl:value-of select="."/>
					<xsl:text>"</xsl:text>
				</xsl:for-each>
				<xsl:if test="position() = 1 and $add_continue = 'true'"> continue="true"</xsl:if>
				<xsl:if test="position() = 1 and $xmlns != ''"> xmlns="<xsl:value-of select="$xmlns"/>"</xsl:if>
			<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
			<xsl:if test="$debug = 'true'">
				<xsl:message>&lt;<xsl:value-of select="."/>&gt;</xsl:message>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- move full page width figures, tables at top level -->
	<xsl:template match="*[local-name() = 'figure' or local-name() = 'table'][normalize-space(@width) != 'text-width']" mode="update_xml_step_move_pagebreak">
		<xsl:param name="page_sequence_at_top">false</xsl:param>
		<xsl:choose>
			<xsl:when test="$layout_columns != 1">

				<xsl:variable name="tree_">
					<xsl:call-template name="makeAncestorsElementsTree">
						<xsl:with-param name="page_sequence_at_top" select="$page_sequence_at_top"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="tree" select="xalan:nodeset($tree_)"/>

				<xsl:call-template name="insertClosingElements">
					<xsl:with-param name="tree" select="$tree"/>
				</xsl:call-template>

				<!-- <xsl:copy-of select="."/> -->
				<xsl:copy>
					<xsl:copy-of select="@*"/>
					<xsl:attribute name="top-level">true</xsl:attribute>
					<xsl:copy-of select="node()"/>
				</xsl:copy>

				<xsl:call-template name="insertOpeningElements">
					<xsl:with-param name="tree" select="$tree"/>
				</xsl:call-template>

			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- =========================================================================== -->
	<!-- END STEP MOVE PAGEBREAK: move <pagebreak/> at top level under 'preface' and 'sections' -->
	<!-- =========================================================================== -->

		<!-- =========================================================================== -->
		<!-- STEP2: add 'fn' after 'eref' and 'origin', if referenced to bibitem with 'note' = Withdrawn.' or 'Cancelled and replaced...'  -->
		<!-- =========================================================================== -->
		<xsl:template match="@*|node()" mode="update_xml_step2">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="update_xml_step2"/>
			</xsl:copy>
		</xsl:template>

		<xsl:variable name="localized_string_withdrawn">
			<xsl:call-template name="getLocalizedString">
				<xsl:with-param name="key">withdrawn</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="localized_string_cancelled_and_replaced">
			<xsl:variable name="str">
				<xsl:call-template name="getLocalizedString">
					<xsl:with-param name="key">cancelled_and_replaced</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="contains($str, '%')"><xsl:value-of select="substring-before($str, '%')"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$str"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- add 'fn' after eref and origin, to reference bibitem with note = 'Withdrawn.' or 'Cancelled and replaced...' -->
		<xsl:template match="*[local-name() = 'eref'] | *[local-name() = 'origin']" mode="update_xml_step2">
			<xsl:copy-of select="."/>

			<xsl:variable name="bibitemid" select="@bibitemid"/>
			<xsl:variable name="local_name" select="local-name()"/>
			<xsl:variable name="position"><xsl:number count="*[local-name() = $local_name][@bibitemid = $bibitemid]" level="any"/></xsl:variable>
			<xsl:if test="normalize-space($position) = '1'">
				<xsl:variable name="fn_text">
					<!-- <xsl:copy-of select="key('bibitems', $bibitemid)[1]/*[local-name() = 'note'][not(@type='Unpublished-Status')][normalize-space() = $localized_string_withdrawn or starts-with(normalize-space(), $localized_string_cancelled_and_replaced)]/node()" /> -->
					<xsl:copy-of select="$bibitems/*[local-name() ='bibitem'][@id = $bibitemid][1]/*[local-name() = 'note'][not(@type='Unpublished-Status')][normalize-space() = $localized_string_withdrawn or starts-with(normalize-space(), $localized_string_cancelled_and_replaced)]/node()"/>
				</xsl:variable>
				<xsl:if test="normalize-space($fn_text) != ''">
					<xsl:element name="fn" namespace="{$namespace_full}">
						<xsl:attribute name="reference">bibitem_<xsl:value-of select="$bibitemid"/></xsl:attribute>
						<xsl:element name="p" namespace="{$namespace_full}">
							<xsl:copy-of select="$fn_text"/>
						</xsl:element>
					</xsl:element>
				</xsl:if>
			</xsl:if>
		</xsl:template>

		<!-- add id for table without id (for autolayout algorithm) -->
		<!-- <xsl:template match="*[local-name() = 'table'][not(@id)]" mode="update_xml_step2">
			<xsl:copy>
				<xsl:apply-templates select="@*" mode="update_xml_step2"/>
				<xsl:attribute name="id">_abc<xsl:value-of select="generate-id()"/></xsl:attribute>
				
				<xsl:apply-templates select="node()" mode="update_xml_step2"/>
			</xsl:copy>
		</xsl:template> -->

		<!-- add @reference for fn -->
		<xsl:template match="*[local-name() = 'fn'][not(@reference)]" mode="update_xml_step2">
			<xsl:copy>
				<xsl:apply-templates select="@*" mode="update_xml_step2"/>
				<xsl:attribute name="reference"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
				<xsl:apply-templates select="node()" mode="update_xml_step2"/>
			</xsl:copy>
		</xsl:template>

		<!-- add @reference for bibitem/note, similar to fn/reference -->
		<!-- <xsl:template match="*[local-name() = 'bibitem']/*[local-name() = 'note']" mode="update_xml_step2">
			<xsl:copy>
				<xsl:apply-templates select="@*" mode="update_xml_step2"/>
				
				<xsl:attribute name="reference">
					<xsl:value-of select="concat('bibitem_', ../@id, '_', count(preceding-sibling::*[local-name() = 'note']))"/>
				</xsl:attribute>
				
				<xsl:apply-templates select="node()" mode="update_xml_step2"/>
			</xsl:copy>
		</xsl:template> -->

		<!-- enclose sequence of 'char x' + 'combining char y' to <lang_none>xy</lang_none> -->
		<xsl:variable name="regex_combining_chars">(.[̀-ͯ])</xsl:variable>
		<xsl:variable name="element_name_lang_none">lang_none</xsl:variable>
		<xsl:variable name="tag_element_name_lang_none_open">###<xsl:value-of select="$element_name_lang_none"/>###</xsl:variable>
		<xsl:variable name="tag_element_name_lang_none_close">###/<xsl:value-of select="$element_name_lang_none"/>###</xsl:variable>

		<xsl:template match="text()" mode="update_xml_step2">
			<xsl:variable name="text_" select="java:replaceAll(java:java.lang.String.new(.), $regex_combining_chars, concat($tag_element_name_lang_none_open,'$1',$tag_element_name_lang_none_close))"/>
			<xsl:call-template name="replace_text_tags">
				<xsl:with-param name="tag_open" select="$tag_element_name_lang_none_open"/>
				<xsl:with-param name="tag_close" select="$tag_element_name_lang_none_close"/>
				<xsl:with-param name="text" select="$text_"/>
			</xsl:call-template>
		</xsl:template>

		<xsl:template match="*[local-name() = 'stem'] | *[local-name() = 'image']" mode="update_xml_step2">
			<xsl:copy-of select="."/>
		</xsl:template>

		<!-- =========================================================================== -->
		<!-- END STEP2: add 'fn' after 'eref' and 'origin', if referenced to bibitem with 'note' = Withdrawn.' or 'Cancelled and replaced...'  -->
		<!-- =========================================================================== -->

	<!-- =========================================================================== -->
	<!-- XML UPDATE STEP: enclose standard's name into tag 'keep-together_within-line'  -->
	<!-- keep-together_within-line for: a/b, aaa/b, a/bbb, /b -->
	<!-- keep-together_within-line for: a.b, aaa.b, a.bbb, .b  in table's cell ONLY  -->
	<!-- =========================================================================== -->
	<!-- Example: <keep-together_within-line>ISO 10303-51</keep-together_within-line> -->
	<xsl:template match="@*|node()" mode="update_xml_enclose_keep-together_within-line">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="update_xml_enclose_keep-together_within-line"/>
		</xsl:copy>
	</xsl:template>

	<xsl:variable name="express_reference_separators">_.\</xsl:variable>
	<xsl:variable name="express_reference_characters" select="concat($upper,$lower,'1234567890',$express_reference_separators)"/>
	<xsl:variable name="regex_express_reference">(^([A-Za-z0-9_.\\]+)$)</xsl:variable>

	<xsl:variable name="element_name_keep-together_within-line">keep-together_within-line</xsl:variable>
	<xsl:variable name="tag_keep-together_within-line_open">###<xsl:value-of select="$element_name_keep-together_within-line"/>###</xsl:variable>
	<xsl:variable name="tag_keep-together_within-line_close">###/<xsl:value-of select="$element_name_keep-together_within-line"/>###</xsl:variable>

	<!-- \S matches any non-whitespace character (equivalent to [^\r\n\t\f\v ]) -->
	<!-- <xsl:variable name="regex_solidus_units">((\b((\S{1,3}\/\S+)|(\S+\/\S{1,3}))\b)|(\/\S{1,3})\b)</xsl:variable> -->
	<!-- add &lt; and &gt; to \S -->
	<xsl:variable name="regex_S">[^\r\n\t\f\v \&lt;&gt;\u3000-\u9FFF]</xsl:variable>
	<xsl:variable name="regex_solidus_units">((\b((<xsl:value-of select="$regex_S"/>{1,3}\/<xsl:value-of select="$regex_S"/>+)|(<xsl:value-of select="$regex_S"/>+\/<xsl:value-of select="$regex_S"/>{1,3}))\b)|(\/<xsl:value-of select="$regex_S"/>{1,3})\b)</xsl:variable>

	<xsl:variable name="non_white_space">[^\s\u3000-\u9FFF]</xsl:variable>
	<xsl:variable name="regex_dots_units">((\b((<xsl:value-of select="$non_white_space"/>{1,3}\.<xsl:value-of select="$non_white_space"/>+)|(<xsl:value-of select="$non_white_space"/>+\.<xsl:value-of select="$non_white_space"/>{1,3}))\b)|(\.<xsl:value-of select="$non_white_space"/>{1,3})\b)</xsl:variable>

	<xsl:template match="text()[not(ancestor::*[local-name() = 'bibdata'] or      ancestor::*[local-name() = 'link'][not(contains(.,' '))] or      ancestor::*[local-name() = 'sourcecode'] or      ancestor::*[local-name() = 'math'] or     ancestor::*[local-name() = 'svg'] or     ancestor::*[local-name() = 'name'] or     starts-with(., 'http://') or starts-with(., 'https://') or starts-with(., 'www.') or normalize-space() = '' )]" name="keep_together_standard_number" mode="update_xml_enclose_keep-together_within-line">

		<xsl:variable name="parent" select="local-name(..)"/>

		<xsl:if test="1 = 2"> <!-- alternative variant -->

			<xsl:variable name="regexs">
				<!-- enclose standard's number into tag 'keep-together_within-line' -->
				<xsl:if test="not(ancestor::*[local-name() = 'table'])"><regex><xsl:value-of select="$regex_standard_reference"/></regex></xsl:if>
				<!-- if EXPRESS reference -->

				<!-- keep-together_within-line for: a/b, aaa/b, a/bbb, /b -->
				<regex><xsl:value-of select="$regex_solidus_units"/></regex>
				<!-- keep-together_within-line for: a.b, aaa.b, a.bbb, .b  in table's cell ONLY -->
				<xsl:if test="ancestor::*[local-name() = 'td' or local-name() = 'th']">
					<regex><xsl:value-of select="$regex_dots_units"/></regex>
				</xsl:if>
			</xsl:variable>

			<xsl:variable name="regex_replacement"><xsl:text>(</xsl:text>
				<xsl:for-each select="xalan:nodeset($regexs)/regex">
					<xsl:value-of select="."/>
					<xsl:if test="position() != last()">|</xsl:if>
				</xsl:for-each>
				<xsl:text>)</xsl:text>
			</xsl:variable>

			<!-- regex_replacement='<xsl:value-of select="$regex_replacement"/>' -->

			<xsl:variable name="text_replaced" select="java:replaceAll(java:java.lang.String.new(.), $regex_replacement, concat($tag_keep-together_within-line_open,'$1',$tag_keep-together_within-line_close))"/>

			<!-- text_replaced='<xsl:value-of select="$text_replaced"/>' -->

			<xsl:call-template name="replace_text_tags">
				<xsl:with-param name="tag_open" select="$tag_keep-together_within-line_open"/>
				<xsl:with-param name="tag_close" select="$tag_keep-together_within-line_close"/>
				<xsl:with-param name="text" select="$text_replaced"/>
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="1 = 1">

		<!-- enclose standard's number into tag 'keep-together_within-line' -->
		<xsl:variable name="text">
			<xsl:element name="text" namespace="{$namespace_full}">
				<xsl:choose>
					<xsl:when test="ancestor::*[local-name() = 'table']"><xsl:value-of select="."/></xsl:when> <!-- no need enclose standard's number into tag 'keep-together_within-line' in table cells -->
					<xsl:otherwise>
						<xsl:variable name="text_" select="java:replaceAll(java:java.lang.String.new(.), $regex_standard_reference, concat($tag_keep-together_within-line_open,'$1',$tag_keep-together_within-line_close))"/>
						<!-- <xsl:value-of select="$text__"/> -->

						<xsl:call-template name="replace_text_tags">
							<xsl:with-param name="tag_open" select="$tag_keep-together_within-line_open"/>
							<xsl:with-param name="tag_close" select="$tag_keep-together_within-line_close"/>
							<xsl:with-param name="text" select="$text_"/>
						</xsl:call-template>

					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:variable>

		<xsl:variable name="text2">
			<xsl:element name="text" namespace="{$namespace_full}">
				<xsl:for-each select="xalan:nodeset($text)/*[local-name() = 'text']/node()">
					<xsl:copy-of select="."/>
				</xsl:for-each>
			</xsl:element>
		</xsl:variable>

		<!-- keep-together_within-line for: a/b, aaa/b, a/bbb, /b -->
		<xsl:variable name="text3">
			<xsl:element name="text" namespace="{$namespace_full}">
				<xsl:for-each select="xalan:nodeset($text2)/*[local-name() = 'text']/node()">
					<xsl:choose>
						<xsl:when test="self::text()">
							<xsl:variable name="text_units" select="java:replaceAll(java:java.lang.String.new(.),$regex_solidus_units,concat($tag_keep-together_within-line_open,'$1',$tag_keep-together_within-line_close))"/>
							<!-- <xsl:variable name="text_units">
								<xsl:element name="text" namespace="{$namespace_full}"> -->
									<xsl:call-template name="replace_text_tags">
										<xsl:with-param name="tag_open" select="$tag_keep-together_within-line_open"/>
										<xsl:with-param name="tag_close" select="$tag_keep-together_within-line_close"/>
										<xsl:with-param name="text" select="$text_units"/>
									</xsl:call-template>
								<!-- </xsl:element>
							</xsl:variable>
							<xsl:copy-of select="xalan:nodeset($text_units)/*[local-name() = 'text']/node()"/> -->
						</xsl:when>
						<xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise> <!-- copy 'as-is' for <fo:inline keep-together.within-line="always" ...  -->
					</xsl:choose>
				</xsl:for-each>
			</xsl:element>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="ancestor::*[local-name() = 'td' or local-name() = 'th']">
				<!-- keep-together_within-line for: a.b, aaa.b, a.bbb, .b  in table's cell ONLY -->
				<xsl:for-each select="xalan:nodeset($text3)/*[local-name() = 'text']/node()">
					<xsl:choose>
						<xsl:when test="self::text()">
							<xsl:variable name="text_dots" select="java:replaceAll(java:java.lang.String.new(.),$regex_dots_units,concat($tag_keep-together_within-line_open,'$1',$tag_keep-together_within-line_close))"/>
							<!-- <xsl:variable name="text_dots">
								<xsl:element name="text" namespace="{$namespace_full}"> -->
									<xsl:call-template name="replace_text_tags">
										<xsl:with-param name="tag_open" select="$tag_keep-together_within-line_open"/>
										<xsl:with-param name="tag_close" select="$tag_keep-together_within-line_close"/>
										<xsl:with-param name="text" select="$text_dots"/>
									</xsl:call-template>
								<!-- </xsl:element>
							</xsl:variable>
							<xsl:copy-of select="xalan:nodeset($text_dots)/*[local-name() = 'text']/node()"/> -->
						</xsl:when>
						<xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise> <!-- copy 'as-is' for <fo:inline keep-together.within-line="always" ...  -->
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise><xsl:copy-of select="xalan:nodeset($text3)/*[local-name() = 'text']/node()"/></xsl:otherwise>
		</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name() = 'stem'] | *[local-name() = 'image']" mode="update_xml_enclose_keep-together_within-line">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template name="replace_text_tags">
		<xsl:param name="tag_open"/>
		<xsl:param name="tag_close"/>
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="contains($text, $tag_open)">
				<xsl:value-of select="substring-before($text, $tag_open)"/>
				<xsl:variable name="text_after" select="substring-after($text, $tag_open)"/>

				<xsl:element name="{substring-before(substring-after($tag_open, '###'),'###')}" namespace="{$namespace_full}">
					<xsl:value-of select="substring-before($text_after, $tag_close)"/>
				</xsl:element>

				<xsl:call-template name="replace_text_tags">
					<xsl:with-param name="tag_open" select="$tag_open"/>
					<xsl:with-param name="tag_close" select="$tag_close"/>
					<xsl:with-param name="text" select="substring-after($text_after, $tag_close)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ===================================== -->
	<!-- END XML UPDATE STEP: enclose standard's name into tag 'keep-together_within-line'  -->
	<!-- ===================================== -->

	<!-- ===================================== -->
	<!-- ===================================== -->
	<!-- Make linear XML (need for landscape orientation) -->
	<!-- ===================================== -->
	<!-- ===================================== -->
	<xsl:template match="@*|node()" mode="linear_xml">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="linear_xml"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="processing-instruction()" mode="linear_xml">
		<xsl:copy-of select="."/>
	</xsl:template>

	<!-- From:
		<clause>
			<title>...</title>
			<p>...</p>
		</clause>
		To:
			<clause/>
			<title>...</title>
			<p>...</p>
		-->
	<xsl:template match="*[local-name() = 'foreword'] |            *[local-name() = 'foreword']//*[local-name() = 'clause'] |            *[local-name() = 'preface']//*[local-name() = 'clause'][not(@type = 'corrigenda') and not(@type = 'policy') and not(@type = 'related-refs')] |            *[local-name() = 'introduction'] |            *[local-name() = 'introduction']//*[local-name() = 'clause'] |            *[local-name() = 'sections']//*[local-name() = 'clause'] |             *[local-name() = 'annex'] |             *[local-name() = 'annex']//*[local-name() = 'clause'] |             *[local-name() = 'references'][not(@hidden = 'true')] |            *[local-name() = 'bibliography']/*[local-name() = 'clause'] |             *[local-name() = 'colophon'] |             *[local-name() = 'colophon']//*[local-name() = 'clause'] |             *[local-name()='sections']//*[local-name()='terms'] |             *[local-name()='sections']//*[local-name()='definitions'] |            *[local-name()='annex']//*[local-name()='definitions']" mode="linear_xml" name="clause_linear">

		<xsl:copy>
			<xsl:apply-templates select="@*" mode="linear_xml"/>

			<xsl:attribute name="keep-with-next">always</xsl:attribute>

			<xsl:if test="local-name() = 'foreword' or local-name() = 'introduction' or    local-name(..) = 'preface' or local-name(..) = 'sections' or     (local-name() = 'references' and parent::*[local-name() = 'bibliography']) or    (local-name() = 'clause' and parent::*[local-name() = 'bibliography']) or    local-name() = 'annex' or     local-name(..) = 'annex' or    local-name(..) = 'colophon'">
				<xsl:attribute name="mainsection">true</xsl:attribute>
			</xsl:if>
		</xsl:copy>

		<xsl:apply-templates mode="linear_xml"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'term']" mode="linear_xml" priority="2">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="linear_xml"/>
			<xsl:attribute name="keep-with-next">always</xsl:attribute>
			<xsl:variable name="level">
				<xsl:call-template name="getLevel"/>
			</xsl:variable>
			<xsl:attribute name="depth"><xsl:value-of select="$level"/></xsl:attribute>
			<xsl:attribute name="ancestor">sections</xsl:attribute>
			<xsl:apply-templates select="node()[not(local-name() = 'term')]" mode="linear_xml"/>
		</xsl:copy>
		<xsl:apply-templates select="*[local-name() = 'term']" mode="linear_xml"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'introduction']//*[local-name() = 'title'] |     *[local-name() = 'foreword']//*[local-name() = 'title'] |     *[local-name() = 'preface']//*[local-name() = 'title'] |     *[local-name() = 'sections']//*[local-name() = 'title'] |     *[local-name() = 'annex']//*[local-name() = 'title'] |     *[local-name() = 'bibliography']/*[local-name() = 'clause']/*[local-name() = 'title'] |     *[local-name() = 'references']/*[local-name() = 'title'] |     *[local-name() = 'colophon']//*[local-name() = 'title']" mode="linear_xml" priority="2">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="linear_xml"/>

			<xsl:attribute name="keep-with-next">always</xsl:attribute>

			<xsl:variable name="level">
				<xsl:call-template name="getLevel"/>
			</xsl:variable>
			<xsl:attribute name="depth"><xsl:value-of select="$level"/></xsl:attribute>

			<xsl:if test="parent::*[local-name() = 'annex']">
				<xsl:attribute name="depth">1</xsl:attribute>
			</xsl:if>

			<xsl:if test="../@inline-header = 'true' and following-sibling::*[1][local-name() = 'p']">
				<xsl:copy-of select="../@inline-header"/>
			</xsl:if>

			<xsl:variable name="ancestor">
				<xsl:choose>
					<xsl:when test="ancestor::*[local-name() = 'foreword']">foreword</xsl:when>
					<xsl:when test="ancestor::*[local-name() = 'introduction']">introduction</xsl:when>
					<xsl:when test="ancestor::*[local-name() = 'sections']">sections</xsl:when>
					<xsl:when test="ancestor::*[local-name() = 'annex']">annex</xsl:when>
					<xsl:when test="ancestor::*[local-name() = 'bibliography']">bibliography</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:attribute name="ancestor">
				<xsl:value-of select="$ancestor"/>
			</xsl:attribute>

			<xsl:attribute name="parent">
				<xsl:choose>
					<xsl:when test="ancestor::*[local-name() = 'preface']">preface</xsl:when>
					<xsl:otherwise><xsl:value-of select="$ancestor"/></xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>

			<xsl:apply-templates mode="linear_xml"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'li']" mode="linear_xml" priority="2">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="linear_xml"/>

			<xsl:variable name="ancestor">
				<xsl:choose>
					<xsl:when test="ancestor::*[local-name() = 'preface']">preface</xsl:when>
					<xsl:when test="ancestor::*[local-name() = 'sections']">sections</xsl:when>
					<xsl:when test="ancestor::*[local-name() = 'annex']">annex</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:attribute name="ancestor">
				<xsl:value-of select="$ancestor"/>
			</xsl:attribute>

			<xsl:apply-templates mode="linear_xml"/>
		</xsl:copy>
	</xsl:template>

	<!-- add @to = figure, table, clause -->
	<!-- add @depth = from  -->
	<xsl:template match="*[local-name() = 'xref']" mode="linear_xml">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="linear_xml"/>
			<xsl:variable name="target" select="@target"/>
			<xsl:attribute name="to">
				<xsl:value-of select="local-name(//*[@id = current()/@target][1])"/>
			</xsl:attribute>
			<xsl:attribute name="depth">
				<xsl:value-of select="//*[@id = current()/@target][1]/*[local-name() = 'title']/@depth"/>
			</xsl:attribute>
			<xsl:apply-templates select="node()" mode="linear_xml"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[not(ancestor::*[local-name() = 'sourcecode'])]/*[local-name() = 'p' or local-name() = 'strong' or local-name() = 'em']/text()" mode="linear_xml">
		<xsl:choose>
			<xsl:when test="contains(., $non_breaking_hyphen)">
				<xsl:call-template name="replaceChar">
					<xsl:with-param name="text" select="."/>
					<xsl:with-param name="replace" select="$non_breaking_hyphen"/>
					<xsl:with-param name="by" select="'-'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="replaceChar">
		<xsl:param name="text"/>
		<xsl:param name="replace"/>
		<xsl:param name="by"/>
		<xsl:choose>
			<xsl:when test="$text = '' or $replace = '' or not($replace)">
				<xsl:value-of select="$text"/>
			</xsl:when>
			<xsl:when test="contains($text, $replace)">
				<xsl:value-of select="substring-before($text,$replace)"/>
				<xsl:element name="inlineChar" namespace="https://www.metanorma.org/ns/standoc"><xsl:value-of select="$by"/></xsl:element>
				<xsl:call-template name="replaceChar">
						<xsl:with-param name="text" select="substring-after($text,$replace)"/>
						<xsl:with-param name="replace" select="$replace"/>
						<xsl:with-param name="by" select="$by"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[local-name() = 'inlineChar']">
		<fo:inline><xsl:value-of select="."/></fo:inline>
	</xsl:template>

	<!-- change @reference to actual value, and add skip_footnote_body="true" for repeatable (2nd, 3rd, ...) -->
	<!--
	<fn reference="1">
			<p id="_8e5cf917-f75a-4a49-b0aa-1714cb6cf954">Formerly denoted as 15 % (m/m).</p>
		</fn>
	-->
	<!-- fn in text -->
	<xsl:template match="*[local-name() = 'fn'][not(ancestor::*[(local-name() = 'table' or local-name() = 'figure')] and not(ancestor::*[local-name() = 'name']))]" mode="linear_xml" name="linear_xml_fn">
		<xsl:variable name="p_fn_">
			<xsl:call-template name="get_fn_list"/>
			<!-- <xsl:choose>
				<xsl:when test="$namespace = 'jis'">
					<xsl:call-template name="get_fn_list_for_element"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="get_fn_list"/>
				</xsl:otherwise>
			</xsl:choose> -->
		</xsl:variable>
		<xsl:variable name="p_fn" select="xalan:nodeset($p_fn_)"/>
		<xsl:variable name="gen_id" select="generate-id(.)"/>
		<xsl:variable name="lang" select="ancestor::*[local-name() = 'metanorma']/*[local-name()='bibdata']//*[local-name()='language'][@current = 'true']"/>
		<xsl:variable name="reference" select="@reference"/>
		<!-- fn sequence number in document -->
		<xsl:variable name="current_fn_number" select="count($p_fn//fn[@reference = $reference]/preceding-sibling::fn) + 1"/>

		<xsl:copy>
			<xsl:apply-templates select="@*" mode="linear_xml"/>
			<!-- put actual reference number -->
			<xsl:attribute name="current_fn_number">
				<xsl:value-of select="$current_fn_number"/>
			</xsl:attribute>
			<xsl:variable name="skip_footnote_body_" select="not($p_fn//fn[@gen_id = $gen_id] and (1 = 1))"/>
			<xsl:attribute name="skip_footnote_body"> <!-- false for repeatable footnote -->

						<xsl:choose>
							<xsl:when test="ancestor::*[local-name() = 'ul' or local-name() ='ol' or local-name() = 'bibitem' or local-name() = 'quote']">true</xsl:when>
							<xsl:otherwise><xsl:value-of select="$skip_footnote_body_"/></xsl:otherwise>
						</xsl:choose>

			</xsl:attribute>
			<xsl:attribute name="ref_id">
				<xsl:value-of select="concat('footnote_', $lang, '_', $reference, '_', $current_fn_number)"/>
			</xsl:attribute>
			<xsl:apply-templates select="node()" mode="linear_xml"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'p'][@type = 'section-title']" priority="3" mode="linear_xml">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="linear_xml"/>
			<xsl:if test="@depth = '1'">
				<xsl:attribute name="mainsection">true</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="node()" mode="linear_xml"/>
		</xsl:copy>
	</xsl:template>
	<!-- ===================================== -->
	<!-- ===================================== -->
	<!-- END: Make linear XML (need for landscape orientation) -->
	<!-- ===================================== -->
	<!-- ===================================== -->

	<!-- for correct rendering combining chars -->
	<xsl:template match="*[local-name() = 'lang_none']">
		<fo:inline xml:lang="none"><xsl:value-of select="."/></fo:inline>
	</xsl:template>

	<!-- ===================================== -->
	<!-- ===================================== -->
	<!-- Ruby text (CJK languages) rendering -->
	<!-- ===================================== -->
	<!-- ===================================== -->
	<xsl:template match="*[local-name() = 'ruby']">
		<fo:inline-container text-indent="0mm" last-line-end-indent="0mm">
			<xsl:if test="not(ancestor::*[local-name() = 'ruby'])">
				<xsl:attribute name="alignment-baseline">central</xsl:attribute>
			</xsl:if>
			<xsl:variable name="rt_text" select="*[local-name() = 'rt']"/>
			<xsl:variable name="rb_text" select=".//*[local-name() = 'rb'][not(*[local-name() = 'ruby'])]"/>
			<!-- Example: width="2em"  -->
			<xsl:variable name="text_rt_width" select="java:org.metanorma.fop.Util.getStringWidthByFontSize($rt_text, $font_main, 6)"/>
			<xsl:variable name="text_rb_width" select="java:org.metanorma.fop.Util.getStringWidthByFontSize($rb_text, $font_main, 10)"/>
			<xsl:variable name="text_width">
				<xsl:choose>
					<xsl:when test="$text_rt_width &gt;= $text_rb_width"><xsl:value-of select="$text_rt_width"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$text_rb_width"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:attribute name="width"><xsl:value-of select="$text_width div 10"/>em</xsl:attribute>

			<xsl:choose>
				<xsl:when test="ancestor::*[local-name() = 'ruby']">
					<xsl:apply-templates select="*[local-name() = 'rb']"/>
					<xsl:apply-templates select="*[local-name() = 'rt']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="*[local-name() = 'rt']"/>
					<xsl:apply-templates select="*[local-name() = 'rb']"/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:apply-templates select="node()[not(local-name() = 'rt') and not(local-name() = 'rb')]"/>
		</fo:inline-container>
	</xsl:template>

	<xsl:template match="*[local-name() = 'rb']">
		<fo:block line-height="1em" text-align="center"><xsl:apply-templates/></fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'rt']">
		<fo:block font-size="0.5em" text-align="center" line-height="1.2em" space-before="-1.4em" space-before.conditionality="retain"> <!--  -->
			<xsl:if test="ancestor::*[local-name() = 'ruby'][last()]//*[local-name() = 'ruby'] or      ancestor::*[local-name() = 'rb']">
				<xsl:attribute name="space-before">0em</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>

	</xsl:template>

	<!-- ===================================== -->
	<!-- ===================================== -->
	<!-- END: Ruby text (CJK languages) rendering -->
	<!-- ===================================== -->
	<!-- ===================================== -->

	<xsl:template name="printEdition">
		<xsl:variable name="edition_i18n" select="normalize-space((//*[local-name() = 'metanorma'])[1]/*[local-name() = 'bibdata']/*[local-name() = 'edition'][normalize-space(@language) != ''])"/>

		<xsl:choose>
			<xsl:when test="$edition_i18n != ''">
				<!-- Example: <edition language="fr">deuxième édition</edition> -->
				<xsl:call-template name="capitalize">
					<xsl:with-param name="str" select="$edition_i18n"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="edition" select="normalize-space((//*[local-name() = 'metanorma'])[1]/*[local-name() = 'bibdata']/*[local-name() = 'edition'])"/>
				<xsl:if test="$edition != ''"> <!-- Example: 1.3 -->
					<xsl:call-template name="capitalize">
						<xsl:with-param name="str">
							<xsl:call-template name="getLocalizedString">
								<xsl:with-param name="key">edition</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text> </xsl:text>
					<xsl:value-of select="$edition"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- convert YYYY-MM-DD to 'Month YYYY' or 'Month DD, YYYY' or DD Month YYYY -->
	<xsl:template name="convertDate">
		<xsl:param name="date"/>
		<xsl:param name="format" select="'short'"/>
		<xsl:variable name="year" select="substring($date, 1, 4)"/>
		<xsl:variable name="month" select="substring($date, 6, 2)"/>
		<xsl:variable name="day" select="substring($date, 9, 2)"/>
		<xsl:variable name="monthStr">
			<xsl:call-template name="getMonthByNum">
				<xsl:with-param name="num" select="$month"/>
				<xsl:with-param name="lowercase" select="'true'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="monthStr_localized">
			<xsl:if test="normalize-space($monthStr) != ''"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_<xsl:value-of select="$monthStr"/></xsl:with-param></xsl:call-template></xsl:if>
		</xsl:variable>
		<xsl:variable name="result">
			<xsl:choose>
				<xsl:when test="$format = 'ddMMyyyy'"> <!-- convert date from format 2007-04-01 to 1 April 2007 -->
					<xsl:if test="$day != ''"><xsl:value-of select="number($day)"/></xsl:if>
					<xsl:text> </xsl:text>
					<xsl:value-of select="normalize-space(concat($monthStr_localized, ' ' , $year))"/>
				</xsl:when>
				<xsl:when test="$format = 'ddMM'">
					<xsl:if test="$day != ''"><xsl:value-of select="number($day)"/></xsl:if>
					<xsl:text> </xsl:text><xsl:value-of select="$monthStr_localized"/>
				</xsl:when>
				<xsl:when test="$format = 'short' or $day = ''">
					<xsl:value-of select="normalize-space(concat($monthStr_localized, ' ', $year))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(concat($monthStr_localized, ' ', $day, ', ' , $year))"/> <!-- January 01, 2022 -->
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$result"/>
	</xsl:template> <!-- convertDate -->

	<!-- return Month's name by number -->
	<xsl:template name="getMonthByNum">
		<xsl:param name="num"/>
		<xsl:param name="lang">en</xsl:param>
		<xsl:param name="lowercase">false</xsl:param> <!-- return 'january' instead of 'January' -->
		<xsl:variable name="monthStr_">
			<xsl:choose>
				<xsl:when test="$lang = 'fr'">
					<xsl:choose>
						<xsl:when test="$num = '01'">Janvier</xsl:when>
						<xsl:when test="$num = '02'">Février</xsl:when>
						<xsl:when test="$num = '03'">Mars</xsl:when>
						<xsl:when test="$num = '04'">Avril</xsl:when>
						<xsl:when test="$num = '05'">Mai</xsl:when>
						<xsl:when test="$num = '06'">Juin</xsl:when>
						<xsl:when test="$num = '07'">Juillet</xsl:when>
						<xsl:when test="$num = '08'">Août</xsl:when>
						<xsl:when test="$num = '09'">Septembre</xsl:when>
						<xsl:when test="$num = '10'">Octobre</xsl:when>
						<xsl:when test="$num = '11'">Novembre</xsl:when>
						<xsl:when test="$num = '12'">Décembre</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$num = '01'">January</xsl:when>
						<xsl:when test="$num = '02'">February</xsl:when>
						<xsl:when test="$num = '03'">March</xsl:when>
						<xsl:when test="$num = '04'">April</xsl:when>
						<xsl:when test="$num = '05'">May</xsl:when>
						<xsl:when test="$num = '06'">June</xsl:when>
						<xsl:when test="$num = '07'">July</xsl:when>
						<xsl:when test="$num = '08'">August</xsl:when>
						<xsl:when test="$num = '09'">September</xsl:when>
						<xsl:when test="$num = '10'">October</xsl:when>
						<xsl:when test="$num = '11'">November</xsl:when>
						<xsl:when test="$num = '12'">December</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="normalize-space($lowercase) = 'true'">
				<xsl:value-of select="java:toLowerCase(java:java.lang.String.new($monthStr_))"/>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="$monthStr_"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template> <!-- getMonthByNum -->

	<!-- return Month's name by number from localized strings -->
	<xsl:template name="getMonthLocalizedByNum">
		<xsl:param name="num"/>
		<xsl:variable name="monthStr">
			<xsl:choose>
				<xsl:when test="$num = '01'">january</xsl:when>
				<xsl:when test="$num = '02'">february</xsl:when>
				<xsl:when test="$num = '03'">march</xsl:when>
				<xsl:when test="$num = '04'">april</xsl:when>
				<xsl:when test="$num = '05'">may</xsl:when>
				<xsl:when test="$num = '06'">june</xsl:when>
				<xsl:when test="$num = '07'">july</xsl:when>
				<xsl:when test="$num = '08'">august</xsl:when>
				<xsl:when test="$num = '09'">september</xsl:when>
				<xsl:when test="$num = '10'">october</xsl:when>
				<xsl:when test="$num = '11'">november</xsl:when>
				<xsl:when test="$num = '12'">december</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="getLocalizedString">
			<xsl:with-param name="key">month_<xsl:value-of select="$monthStr"/></xsl:with-param>
		</xsl:call-template>
	</xsl:template> <!-- getMonthLocalizedByNum -->

	<xsl:template name="insertKeywords">
		<xsl:param name="sorting" select="'true'"/>
		<xsl:param name="meta" select="'false'"/>
		<xsl:param name="charAtEnd" select="'.'"/>
		<xsl:param name="charDelim" select="', '"/>
		<xsl:choose>
			<xsl:when test="$sorting = 'true' or $sorting = 'yes'">
				<xsl:for-each select="//*[local-name() = 'metanorma']/*[local-name() = 'bibdata']//*[local-name() = 'keyword']">
					<xsl:sort data-type="text" order="ascending"/>
					<xsl:call-template name="insertKeyword">
						<xsl:with-param name="meta" select="$meta"/>
						<xsl:with-param name="charAtEnd" select="$charAtEnd"/>
						<xsl:with-param name="charDelim" select="$charDelim"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="//*[local-name() = 'metanorma']/*[local-name() = 'bibdata']//*[local-name() = 'keyword']">
					<xsl:call-template name="insertKeyword">
						<xsl:with-param name="meta" select="$meta"/>
						<xsl:with-param name="charAtEnd" select="$charAtEnd"/>
						<xsl:with-param name="charDelim" select="$charDelim"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="insertKeyword">
		<xsl:param name="charAtEnd"/>
		<xsl:param name="charDelim"/>
		<xsl:param name="meta"/>
		<xsl:choose>
			<xsl:when test="$meta = 'true'">
				<xsl:value-of select="."/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="position() != last()"><xsl:value-of select="$charDelim"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$charAtEnd"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="addPDFUAmeta">
		<pdf:catalog>
			<pdf:dictionary type="normal" key="ViewerPreferences">
				<pdf:boolean key="DisplayDocTitle">true</pdf:boolean>
			</pdf:dictionary>
		</pdf:catalog>
		<x:xmpmeta xmlns:x="adobe:ns:meta/">
			<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
				<!-- Commented after upgrade to Apache FOP 2.10
				<rdf:Description xmlns:pdfaExtension="http://www.aiim.org/pdfa/ns/extension/" xmlns:pdfaProperty="http://www.aiim.org/pdfa/ns/property#" xmlns:pdfaSchema="http://www.aiim.org/pdfa/ns/schema#" rdf:about="">
					<pdfaExtension:schemas>
						<rdf:Bag>
							<rdf:li rdf:parseType="Resource">
								<pdfaSchema:namespaceURI>http://www.aiim.org/pdfua/ns/id/</pdfaSchema:namespaceURI>
								<pdfaSchema:prefix>pdfuaid</pdfaSchema:prefix>
								<pdfaSchema:schema>PDF/UA identification schema</pdfaSchema:schema>
								<pdfaSchema:property>
									<rdf:Seq>
										<rdf:li rdf:parseType="Resource">
											<pdfaProperty:category>internal</pdfaProperty:category>
											<pdfaProperty:description>PDF/UA version identifier</pdfaProperty:description>
											<pdfaProperty:name>part</pdfaProperty:name>
											<pdfaProperty:valueType>Integer</pdfaProperty:valueType>
										</rdf:li>
										<rdf:li rdf:parseType="Resource">
											<pdfaProperty:category>internal</pdfaProperty:category>
											<pdfaProperty:description>PDF/UA amendment identifier</pdfaProperty:description>
											<pdfaProperty:name>amd</pdfaProperty:name>
											<pdfaProperty:valueType>Text</pdfaProperty:valueType>
										</rdf:li>
										<rdf:li rdf:parseType="Resource">
											<pdfaProperty:category>internal</pdfaProperty:category>
											<pdfaProperty:description>PDF/UA corrigenda identifier</pdfaProperty:description>
											<pdfaProperty:name>corr</pdfaProperty:name>
											<pdfaProperty:valueType>Text</pdfaProperty:valueType>
										</rdf:li>
									</rdf:Seq>
								</pdfaSchema:property>
							</rdf:li>
						</rdf:Bag>
					</pdfaExtension:schemas>
				</rdf:Description> -->
				<rdf:Description xmlns:pdf="http://ns.adobe.com/pdf/1.3/" xmlns:dc="http://purl.org/dc/elements/1.1/" rdf:about="">
				<!-- Dublin Core properties go here -->
					<dc:title>
						<xsl:variable name="title">
							<xsl:for-each select="(//*[local-name() = 'metanorma'])[1]/*[local-name() = 'bibdata']">

										<xsl:choose>
											<xsl:when test="*[local-name() = 'title'][@language = $lang and @type = 'main']">
												<xsl:value-of select="*[local-name() = 'title'][@language = $lang and @type = 'main']"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="*[local-name() = 'title'][@language = $lang and @type = 'title-main']"/>
											</xsl:otherwise>
										</xsl:choose>

							</xsl:for-each>
						</xsl:variable>
						<rdf:Alt>
							<rdf:li xml:lang="x-default">
								<xsl:choose>
									<xsl:when test="normalize-space($title) != ''">
										<xsl:value-of select="$title"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text> </xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</rdf:li>
						</rdf:Alt>
					</dc:title>
					<xsl:variable name="dc_creator">
						<xsl:for-each select="(//*[local-name() = 'metanorma'])[1]/*[local-name() = 'bibdata']">

									<rdf:Seq>
										<xsl:for-each select="*[local-name() = 'contributor'][*[local-name() = 'role']/@type='author']">
											<rdf:li>
												<xsl:value-of select="*[local-name() = 'organization']/*[local-name() = 'name']"/>
											</rdf:li>
											<!-- <xsl:if test="position() != last()">; </xsl:if> -->
										</xsl:for-each>
									</rdf:Seq>

						</xsl:for-each>
					</xsl:variable>
					<xsl:if test="normalize-space($dc_creator) != ''">
						<dc:creator>
							<xsl:copy-of select="$dc_creator"/>
						</dc:creator>
					</xsl:if>

					<xsl:variable name="dc_description">
						<xsl:variable name="abstract">

									<xsl:copy-of select="//*[local-name() = 'metanorma']/*[local-name() = 'preface']/*[local-name() = 'abstract']//text()[not(ancestor::*[local-name() = 'fmt-title']) and not(ancestor::*[local-name() = 'title']) and not(ancestor::*[local-name() = 'fmt-xref-label'])]"/>

						</xsl:variable>
						<rdf:Alt>
							<rdf:li xml:lang="x-default">
								<xsl:value-of select="normalize-space($abstract)"/>
							</rdf:li>
						</rdf:Alt>
					</xsl:variable>
					<xsl:if test="normalize-space($dc_description)">
						<dc:description>
							<xsl:copy-of select="$dc_description"/>
						</dc:description>
					</xsl:if>

					<pdf:Keywords>
						<xsl:call-template name="insertKeywords">
							<xsl:with-param name="meta">true</xsl:with-param>
						</xsl:call-template>
					</pdf:Keywords>
				</rdf:Description>
				<rdf:Description xmlns:xmp="http://ns.adobe.com/xap/1.0/" rdf:about="">
					<!-- XMP properties go here -->
					<xmp:CreatorTool/>
				</rdf:Description>
			</rdf:RDF>
		</x:xmpmeta>
		<!-- add attachments -->
		<xsl:for-each select="//*[local-name() = 'metanorma']/*[local-name() = 'metanorma-extension']/*[local-name() = 'attachment']">
			<xsl:variable name="bibitem_attachment_" select="//*[local-name() = 'bibitem'][@hidden = 'true'][*[local-name() = 'uri'][@type = 'attachment'] = current()/@name]"/>
			<xsl:variable name="bibitem_attachment" select="xalan:nodeset($bibitem_attachment_)"/>
			<xsl:variable name="description" select="normalize-space($bibitem_attachment/*[local-name() = 'formattedref'])"/>
			<xsl:variable name="filename" select="java:org.metanorma.fop.Util.getFilenameFromPath(@name)"/>
			<!-- Todo: need update -->
			<xsl:variable name="afrelationship" select="normalize-space($bibitem_attachment//*[local-name() = 'classification'][@type = 'pdf-AFRelationship'])"/>
			<xsl:variable name="volatile" select="normalize-space($bibitem_attachment//*[local-name() = 'classification'][@type = 'pdf-volatile'])"/>

			<pdf:embedded-file filename="{$filename}" link-as-file-annotation="true">
				<xsl:attribute name="src">
					<xsl:choose>
						<xsl:when test="normalize-space() != ''">
							<xsl:variable name="src_attachment" select="java:replaceAll(java:java.lang.String.new(.),'(&#13;&#10;|&#13;|&#10;)', '')"/> <!-- remove line breaks -->
							<xsl:value-of select="$src_attachment"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="url" select="concat('url(file:///',$inputxml_basepath , @name, ')')"/>
							<xsl:value-of select="$url"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:if test="$description != ''">
					<xsl:attribute name="description"><xsl:value-of select="$description"/></xsl:attribute>
				</xsl:if>
				<xsl:if test="$afrelationship != ''">
					<xsl:attribute name="afrelationship"><xsl:value-of select="$afrelationship"/></xsl:attribute>
				</xsl:if>
				<xsl:if test="$volatile != ''">
					<xsl:attribute name="volatile"><xsl:value-of select="$volatile"/></xsl:attribute>
				</xsl:if>
			</pdf:embedded-file>
		</xsl:for-each>
		<!-- references to external attachments (no binary-encoded within the Metanorma XML file) -->
		<xsl:if test="not(//*[local-name() = 'metanorma']/*[local-name() = 'metanorma-extension']/*[local-name() = 'attachment'])">
			<xsl:for-each select="//*[local-name() = 'bibitem'][@hidden = 'true'][*[local-name() = 'uri'][@type = 'attachment']]">
				<xsl:variable name="attachment_path" select="*[local-name() = 'uri'][@type = 'attachment']"/>
				<xsl:variable name="attachment_name" select="java:org.metanorma.fop.Util.getFilenameFromPath($attachment_path)"/>
				<xsl:variable name="url" select="concat('url(file:///',$basepath, $attachment_path, ')')"/>
				<xsl:variable name="description" select="normalize-space(*[local-name() = 'formattedref'])"/>
				<!-- Todo: need update -->
				<xsl:variable name="afrelationship" select="normalize-space(.//*[local-name() = 'classification'][@type = 'pdf-AFRelationship'])"/>
				<xsl:variable name="volatile" select="normalize-space(.//*[local-name() = 'classification'][@type = 'pdf-volatile'])"/>
				<pdf:embedded-file src="{$url}" filename="{$attachment_name}" link-as-file-annotation="true">
					<xsl:if test="$description != ''">
						<xsl:attribute name="description"><xsl:value-of select="$description"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="$afrelationship != ''">
						<xsl:attribute name="afrelationship"><xsl:value-of select="$afrelationship"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="$volatile != ''">
						<xsl:attribute name="volatile"><xsl:value-of select="$volatile"/></xsl:attribute>
					</xsl:if>
				</pdf:embedded-file>
			</xsl:for-each>
		</xsl:if>
	</xsl:template> <!-- addPDFUAmeta -->

	<xsl:template name="getId">
		<xsl:choose>
			<xsl:when test="../@id">
				<xsl:value-of select="../@id"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(generate-id(..), '_', text())"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Get or calculate depth of the element -->
	<xsl:template name="getLevel">
		<xsl:param name="depth"/>
		<!-- <xsl:message>
			<xsl:choose>
				<xsl:when test="local-name() = 'title'">title=<xsl:value-of select="."/></xsl:when>
				<xsl:when test="local-name() = 'clause'">clause/title=<xsl:value-of select="*[local-name() = 'title']"/></xsl:when>
			</xsl:choose>
		</xsl:message> -->
		<xsl:choose>
			<xsl:when test="normalize-space(@depth) != ''">
				<xsl:value-of select="@depth"/>
			</xsl:when>
			<xsl:when test="normalize-space($depth) != ''">
				<xsl:value-of select="$depth"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="level_total" select="count(ancestor::*[local-name() != 'page_sequence'])"/>
				<xsl:variable name="level">
					<xsl:choose>
						<xsl:when test="parent::*[local-name() = 'preface']">
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'preface'] and not(ancestor::*[local-name() = 'foreword']) and not(ancestor::*[local-name() = 'introduction'])"> <!-- for preface/clause -->
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'preface']">
							<xsl:value-of select="$level_total - 2"/>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'sections'] and self::*[local-name() = 'title']">
							<!-- determine 'depth' depends on upper clause with title/@depth -->
							<!-- <xsl:message>title=<xsl:value-of select="."/></xsl:message> -->
							<xsl:variable name="clause_with_depth_depth" select="ancestor::*[local-name() = 'clause'][*[local-name() = 'title']/@depth][1]/*[local-name() = 'title']/@depth"/>
							<!-- <xsl:message>clause_with_depth_depth=<xsl:value-of select="$clause_with_depth_depth"/></xsl:message> -->
							<xsl:variable name="clause_with_depth_level" select="count(ancestor::*[local-name() = 'clause'][*[local-name() = 'title']/@depth][1]/ancestor::*)"/>
							<!-- <xsl:message>clause_with_depth_level=<xsl:value-of select="$clause_with_depth_level"/></xsl:message> -->
							<xsl:variable name="curr_level" select="count(ancestor::*) - 1"/>
							<!-- <xsl:message>curr_level=<xsl:value-of select="$curr_level"/></xsl:message> -->
							<!-- <xsl:variable name="upper_clause_depth" select="normalize-space(ancestor::*[local-name() = 'clause'][2]/*[local-name() = 'title']/@depth)"/> -->
							<xsl:variable name="curr_clause_depth" select="number($clause_with_depth_depth) + (number($curr_level) - number($clause_with_depth_level)) "/>
							<!-- <xsl:message>curr_clause_depth=<xsl:value-of select="$curr_clause_depth"/></xsl:message> -->
							<xsl:choose>
								<xsl:when test="string(number($curr_clause_depth)) != 'NaN'">
									<xsl:value-of select="number($curr_clause_depth)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$level_total - 2"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'sections'] and self::*[local-name() = 'name'] and parent::*[local-name() = 'term']">
							<xsl:variable name="upper_terms_depth" select="normalize-space(ancestor::*[local-name() = 'terms'][1]/*[local-name() = 'title']/@depth)"/>
							<xsl:choose>
								<xsl:when test="string(number($upper_terms_depth)) != 'NaN'">
									<xsl:value-of select="number($upper_terms_depth + 1)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$level_total - 2"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'sections']">
							<xsl:variable name="upper_clause_depth" select="normalize-space(ancestor::*[local-name() = 'clause' or local-name() = 'terms'][1]/*[local-name() = 'title']/@depth)"/>
							<xsl:choose>
								<xsl:when test="string(number($upper_clause_depth)) != 'NaN'">
									<xsl:value-of select="number($upper_clause_depth + 1)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$level_total - 1"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'bibliography']">
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when>
						<xsl:when test="parent::*[local-name() = 'annex']">
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'annex'] and self::*[local-name() = 'title']">
							<xsl:variable name="upper_clause_depth" select="normalize-space(ancestor::*[local-name() = 'clause'][2]/*[local-name() = 'title']/@depth)"/>
							<xsl:choose>
								<xsl:when test="string(number($upper_clause_depth)) != 'NaN'">
									<xsl:value-of select="number($upper_clause_depth + 1)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$level_total - 1"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'annex']">
							<xsl:value-of select="$level_total"/>
						</xsl:when>
						<xsl:when test="local-name() = 'annex'">1</xsl:when>
						<xsl:when test="local-name(ancestor::*[1]) = 'annex'">1</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$level_total - 1"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:value-of select="$level"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template> <!-- getLevel -->

	<!-- Get or calculate depth of term's name -->
	<xsl:template name="getLevelTermName">
		<xsl:choose>
			<xsl:when test="normalize-space(../@depth) != ''">
				<xsl:value-of select="../@depth"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="title_level_">
					<xsl:for-each select="../preceding-sibling::*[local-name() = 'title'][1]">
						<xsl:call-template name="getLevel"/>
					</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="title_level" select="normalize-space($title_level_)"/>
				<xsl:choose>
					<xsl:when test="$title_level != ''"><xsl:value-of select="$title_level + 1"/></xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="getLevel"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template> <!-- getLevelTermName -->

	<!-- split string by separator -->
	<xsl:template name="split">
		<xsl:param name="pText" select="."/>
		<xsl:param name="sep" select="','"/>
		<xsl:param name="normalize-space" select="'true'"/>
		<xsl:param name="keep_sep" select="'false'"/>
		<xsl:if test="string-length($pText) &gt;0">
			<item>
				<xsl:choose>
					<xsl:when test="$normalize-space = 'true'">
						<xsl:value-of select="normalize-space(substring-before(concat($pText, $sep), $sep))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring-before(concat($pText, $sep), $sep)"/>
					</xsl:otherwise>
				</xsl:choose>
			</item>
			<xsl:if test="$keep_sep = 'true' and contains($pText, $sep)"><item><xsl:value-of select="$sep"/></item></xsl:if>
			<xsl:call-template name="split">
				<xsl:with-param name="pText" select="substring-after($pText, $sep)"/>
				<xsl:with-param name="sep" select="$sep"/>
				<xsl:with-param name="normalize-space" select="$normalize-space"/>
				<xsl:with-param name="keep_sep" select="$keep_sep"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template> <!-- split -->

	<xsl:template name="getDocumentId">
		<xsl:call-template name="getLang"/><xsl:value-of select="//*[local-name() = 'p'][1]/@id"/>
	</xsl:template>

	<xsl:template name="getDocumentId_fromCurrentNode">
		<xsl:call-template name="getLang_fromCurrentNode"/><xsl:value-of select=".//*[local-name() = 'p'][1]/@id"/>
	</xsl:template>

	<xsl:template name="namespaceCheck">
		<xsl:variable name="documentNS" select="$namespace_full"/> <!-- namespace-uri(/*) -->
		<xsl:variable name="XSLNS">

		</xsl:variable>
		<!-- <xsl:if test="$documentNS != $XSLNS">
			<xsl:message>[WARNING]: Document namespace: '<xsl:value-of select="$documentNS"/>' doesn't equal to xslt namespace '<xsl:value-of select="$XSLNS"/>'</xsl:message>
		</xsl:if> -->
	</xsl:template> <!-- namespaceCheck -->

	<xsl:template name="getLanguage">
		<xsl:param name="lang"/>
		<xsl:variable name="language" select="java:toLowerCase(java:java.lang.String.new($lang))"/>
		<xsl:choose>
			<xsl:when test="$language = 'en'">English</xsl:when>
			<xsl:when test="$language = 'fr'">French</xsl:when>
			<xsl:when test="$language = 'de'">Deutsch</xsl:when>
			<xsl:when test="$language = 'cn'">Chinese</xsl:when>
			<xsl:otherwise><xsl:value-of select="$language"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="setId">
		<xsl:param name="prefix"/>
		<xsl:attribute name="id">
			<xsl:choose>
				<xsl:when test="@id">
					<xsl:value-of select="concat($prefix, @id)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($prefix, generate-id())"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<xsl:template name="add-letter-spacing">
		<xsl:param name="text"/>
		<xsl:param name="letter-spacing" select="'0.15'"/>
		<xsl:if test="string-length($text) &gt; 0">
			<xsl:variable name="char" select="substring($text, 1, 1)"/>
			<fo:inline padding-right="{$letter-spacing}mm">
				<xsl:if test="$char = '®'">
					<xsl:attribute name="font-size">58%</xsl:attribute>
					<xsl:attribute name="baseline-shift">30%</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="$char"/>
			</fo:inline>
			<xsl:call-template name="add-letter-spacing">
				<xsl:with-param name="text" select="substring($text, 2)"/>
				<xsl:with-param name="letter-spacing" select="$letter-spacing"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="repeat">
		<xsl:param name="char" select="'*'"/>
		<xsl:param name="count"/>
		<xsl:if test="$count &gt; 0">
			<xsl:value-of select="$char"/>
			<xsl:call-template name="repeat">
				<xsl:with-param name="char" select="$char"/>
				<xsl:with-param name="count" select="$count - 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="getLocalizedString">
		<xsl:param name="key"/>
		<xsl:param name="formatted">false</xsl:param>
		<xsl:param name="lang"/>
		<xsl:param name="returnEmptyIfNotFound">false</xsl:param>
		<xsl:param name="bibdata_updated"/>

		<xsl:variable name="curr_lang">
			<xsl:choose>
				<xsl:when test="$lang != ''"><xsl:value-of select="$lang"/></xsl:when>
				<xsl:when test="$returnEmptyIfNotFound = 'true'"/>
				<xsl:otherwise>
					<xsl:call-template name="getLang"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="data_value">
			<xsl:choose>
				<xsl:when test="$formatted = 'true' and string-length($bibdata_updated) != 0">
					<xsl:apply-templates select="xalan:nodeset($bibdata_updated)//*[local-name() = 'localized-string'][@key = $key and @language = $curr_lang]"/>
				</xsl:when>
				<xsl:when test="string-length($bibdata_updated) != 0">
					<xsl:value-of select="xalan:nodeset($bibdata_updated)//*[local-name() = 'localized-string'][@key = $key and @language = $curr_lang]"/>
				</xsl:when>
				<xsl:when test="$formatted = 'true'">
					<xsl:apply-templates select="xalan:nodeset($bibdata)//*[local-name() = 'localized-string'][@key = $key and @language = $curr_lang]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(xalan:nodeset($bibdata)//*[local-name() = 'localized-string'][@key = $key and @language = $curr_lang])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="normalize-space($data_value) != ''">
				<xsl:choose>
					<xsl:when test="$formatted = 'true'"><xsl:copy-of select="$data_value"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$data_value"/></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="/*/*[local-name() = 'localized-strings']/*[local-name() = 'localized-string'][@key = $key and @language = $curr_lang]">
				<xsl:choose>
					<xsl:when test="$formatted = 'true'">
						<xsl:apply-templates select="/*/*[local-name() = 'localized-strings']/*[local-name() = 'localized-string'][@key = $key and @language = $curr_lang]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="/*/*[local-name() = 'localized-strings']/*[local-name() = 'localized-string'][@key = $key and @language = $curr_lang]"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$returnEmptyIfNotFound = 'true'"/>
			<xsl:otherwise>
				<xsl:variable name="key_">
					<xsl:call-template name="capitalize">
						<xsl:with-param name="str" select="translate($key, '_', ' ')"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="$key_"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template> <!-- getLocalizedString -->

	<xsl:template name="setTrackChangesStyles">
		<xsl:param name="isAdded"/>
		<xsl:param name="isDeleted"/>
		<xsl:choose>
			<xsl:when test="local-name() = 'math'">
				<xsl:if test="$isAdded = 'true'">
					<xsl:attribute name="background-color"><xsl:value-of select="$color-added-text"/></xsl:attribute>
				</xsl:if>
				<xsl:if test="$isDeleted = 'true'">
					<xsl:attribute name="background-color"><xsl:value-of select="$color-deleted-text"/></xsl:attribute>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$isAdded = 'true'">
					<xsl:attribute name="border"><xsl:value-of select="$border-block-added"/></xsl:attribute>
					<xsl:attribute name="padding">2mm</xsl:attribute>
				</xsl:if>
				<xsl:if test="$isDeleted = 'true'">
					<xsl:attribute name="border"><xsl:value-of select="$border-block-deleted"/></xsl:attribute>
					<xsl:if test="local-name() = 'table'">
						<xsl:attribute name="background-color">rgb(255, 185, 185)</xsl:attribute>
					</xsl:if>
					<xsl:attribute name="padding">2mm</xsl:attribute>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template> <!-- setTrackChangesStyles -->

	<!--  see https://xmlgraphics.apache.org/fop/2.5/complexscripts.html#bidi_controls-->
	<xsl:variable name="LRM" select="'‎'"/> <!-- U+200E - LEFT-TO-RIGHT MARK (LRM) -->
	<xsl:variable name="RLM" select="'‏'"/> <!-- U+200F - RIGHT-TO-LEFT MARK (RLM) -->
	<xsl:template name="setWritingMode">
		<xsl:if test="$lang = 'ar'">
			<xsl:attribute name="writing-mode">rl-tb</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:template name="setAlignment">
		<xsl:param name="align" select="normalize-space(@align)"/>
		<xsl:choose>
			<xsl:when test="$lang = 'ar' and $align = 'left'">start</xsl:when>
			<xsl:when test="$lang = 'ar' and $align = 'right'">end</xsl:when>
			<xsl:when test="$align != ''">
				<xsl:value-of select="$align"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="setTextAlignment">
		<xsl:param name="default">left</xsl:param>
		<xsl:variable name="align" select="normalize-space(@align)"/>
		<xsl:attribute name="text-align">
			<xsl:choose>
				<xsl:when test="$lang = 'ar' and $align = 'left'">start</xsl:when>
				<xsl:when test="$lang = 'ar' and $align = 'right'">end</xsl:when>
				<xsl:when test="$align = 'justified'">justify</xsl:when>
				<xsl:when test="$align != '' and not($align = 'indent')"><xsl:value-of select="$align"/></xsl:when>
				<xsl:when test="ancestor::*[local-name() = 'td']/@align"><xsl:value-of select="ancestor::*[local-name() = 'td']/@align"/></xsl:when>
				<xsl:when test="ancestor::*[local-name() = 'th']/@align"><xsl:value-of select="ancestor::*[local-name() = 'th']/@align"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$default"/></xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:if test="$align = 'indent'">
			<xsl:attribute name="margin-left">7mm</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:template name="setBlockAttributes">
		<xsl:param name="text_align_default">left</xsl:param>
		<xsl:call-template name="setTextAlignment">
			<xsl:with-param name="default" select="$text_align_default"/>
		</xsl:call-template>
		<xsl:call-template name="setKeepAttributes"/>
	</xsl:template>

	<xsl:template name="setKeepAttributes">
		<!-- https://www.metanorma.org/author/topics/document-format/text/#avoiding-page-breaks -->
		<!-- Example: keep-lines-together="true" -->
		<xsl:if test="@keep-lines-together = 'true'">
			<xsl:attribute name="keep-together.within-column">always</xsl:attribute>
		</xsl:if>
		<!-- Example: keep-with-next="true" -->
		<xsl:if test="@keep-with-next =  'true'">
			<xsl:attribute name="keep-with-next">always</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<!-- insert cover page image -->
		<!-- background cover image -->
	<xsl:template name="insertBackgroundPageImage">
		<xsl:param name="number">1</xsl:param>
		<xsl:param name="name">coverpage-image</xsl:param>
		<xsl:param name="suffix"/>
		<xsl:variable name="num" select="number($number)"/>
		<!-- background image -->
		<fo:block-container absolute-position="fixed" left="0mm" top="0mm" font-size="0" id="__internal_layout__coverpage{$suffix}_{$name}_{$number}_{generate-id()}">
			<fo:block>
				<xsl:for-each select="/*[local-name() = 'metanorma']/*[local-name() = 'metanorma-extension']/*[local-name() = 'presentation-metadata'][*[local-name() = 'name'] = $name][1]/*[local-name() = 'value']/*[local-name() = 'image'][$num]">
					<xsl:choose>
						<xsl:when test="*[local-name() = 'svg'] or java:endsWith(java:java.lang.String.new(@src), '.svg')">
							<fo:instream-foreign-object fox:alt-text="Image Front">
								<xsl:attribute name="content-height"><xsl:value-of select="$pageHeight"/>mm</xsl:attribute>
								<xsl:call-template name="getSVG"/>
							</fo:instream-foreign-object>
						</xsl:when>
						<xsl:when test="starts-with(@src, 'data:application/pdf;base64')">
							<fo:external-graphic src="{@src}" fox:alt-text="Image Front"/>
						</xsl:when>
						<xsl:otherwise> <!-- bitmap image -->
							<xsl:variable name="coverimage_src" select="normalize-space(@src)"/>
							<xsl:if test="$coverimage_src != ''">
								<xsl:variable name="coverpage">
									<xsl:call-template name="getImageURL">
										<xsl:with-param name="src" select="$coverimage_src"/>
									</xsl:call-template>
								</xsl:variable>
								<!-- <xsl:variable name="coverpage" select="concat('url(file:',$basepath, 'coverpage1.png', ')')"/> --> <!-- for DEBUG -->
								<fo:external-graphic src="{$coverpage}" width="{$pageWidth}mm" content-height="scale-to-fit" scaling="uniform" fox:alt-text="Image Front"/>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</fo:block>
		</fo:block-container>
	</xsl:template>

	<xsl:template name="getImageURL">
		<xsl:param name="src"/>
		<xsl:choose>
			<xsl:when test="starts-with($src, 'data:image')">
				<xsl:value-of select="$src"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="src_external"><xsl:call-template name="getImageSrcExternal"/></xsl:variable>
				<xsl:value-of select="concat('url(file:///', $src_external, ')')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="getSVG">
		<xsl:choose>
			<xsl:when test="*[local-name() = 'svg']">
				<xsl:apply-templates select="*[local-name() = 'svg']" mode="svg_update"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="svg_content" select="document(@src)"/>
				<xsl:for-each select="xalan:nodeset($svg_content)/node()">
					<xsl:apply-templates select="." mode="svg_update"/>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- END: insert cover page image -->

	<!-- https://github.com/metanorma/docs/blob/main/109.adoc -->
	<xsl:variable name="regex_ja_spec_half_width_">
		\u0028  <!-- U+0028 LEFT PARENTHESIS (() -->
		\u0029 <!-- U+0029 RIGHT PARENTHESIS ()) -->
		\u007B <!-- U+007B LEFT CURLY BRACKET ({) -->
		\u007D <!-- U+007D RIGHT CURLY BRACKET (}) -->
		\uFF62 <!-- U+FF62 HALFWIDTH LEFT CORNER BRACKET (｢) -->
		\uFF63 <!-- U+FF63 HALFWIDTH RIGHT CORNER BRACKET (｣) -->
		\u005B <!-- U+005B LEFT SQUARE BRACKET ([) -->
		\u005D <!-- U+005D RIGHT SQUARE BRACKET (]) -->
	</xsl:variable>
	<xsl:variable name="regex_ja_spec_half_width" select="translate(normalize-space($regex_ja_spec_half_width_), ' ', '')"/>
	<xsl:variable name="regex_ja_spec_">[
		<!-- Rotate 90° clockwise -->
		<xsl:value-of select="$regex_ja_spec_half_width"/>
		\uFF08 <!-- U+FF08 FULLWIDTH LEFT PARENTHESIS (（) -->
		\uFF09 <!-- U+FF09 FULLWIDTH RIGHT PARENTHESIS (）) -->
		\uFF5B <!-- U+FF5B FULLWIDTH LEFT CURLY BRACKET (｛) -->
		\uFF5D <!-- U+FF5D FULLWIDTH RIGHT CURLY BRACKET (｝) -->
		\u3014 <!-- U+3014 LEFT TORTOISE SHELL BRACKET (〔) -->
		\u3015 <!-- U+3015 RIGHT TORTOISE SHELL BRACKET (〕) -->
		\u3010 <!-- U+3010 LEFT BLACK LENTICULAR BRACKET (【) -->
		\u3011 <!-- U+3011 RIGHT BLACK LENTICULAR BRACKET (】) -->
		\u300A <!-- U+300A LEFT DOUBLE ANGLE BRACKET (《) -->
		\u300B <!-- U+300B RIGHT DOUBLE ANGLE BRACKET (》) -->
		\u300C <!-- U+300C LEFT CORNER BRACKET (「) -->
		\u300D <!-- U+300D RIGHT CORNER BRACKET (」) -->
		\u300E <!-- U+300E LEFT WHITE CORNER BRACKET (『) -->
		\u300F <!-- U+300F RIGHT WHITE CORNER BRACKET (』) -->
		\uFF3B <!-- U+FF3B FULLWIDTH LEFT SQUARE BRACKET (［) -->
		\uFF3D <!-- U+FF3D FULLWIDTH RIGHT SQUARE BRACKET (］) -->
		\u3008 <!-- U+3008 LEFT ANGLE BRACKET (〈) -->
		\u3009 <!-- U+3009 RIGHT ANGLE BRACKET (〉) -->
		\u3016 <!-- U+3016 LEFT WHITE LENTICULAR BRACKET (〖) -->
		\u3017 <!-- U+3017 RIGHT WHITE LENTICULAR BRACKET (〗) -->
		\u301A <!-- U+301A LEFT WHITE SQUARE BRACKET (〚) -->
		\u301B <!-- U+301B RIGHT WHITE SQUARE BRACKET (〛) -->
		\u301C <!-- U+301C WAVE DASH (〜) -->
		\u3030 <!-- U+3030 WAVY DASH (〰 )-->
		\u30FC <!-- U+30FC KATAKANA-HIRAGANA PROLONGED SOUND MARK (ー) -->
		\u2329 <!-- U+2329 LEFT-POINTING ANGLE BRACKET (〈) -->
		\u232A <!-- U+232A RIGHT-POINTING ANGLE BRACKET (〉) -->
		\u3018 <!-- U+3018 LEFT WHITE TORTOISE SHELL BRACKET (〘) -->
		\u3019 <!-- U+3019 RIGHT WHITE TORTOISE SHELL BRACKET (〙) -->
		\u30A0 <!-- U+30A0 KATAKANA-HIRAGANA DOUBLE HYPHEN (゠) -->
		\uFE59 <!-- U+FE59 SMALL LEFT PARENTHESIS (﹙) -->
		\uFE5A <!-- U+FE5A SMALL RIGHT PARENTHESIS (﹚) -->
		\uFE5B <!-- U+FE5B SMALL LEFT CURLY BRACKET (﹛) -->
		\uFE5C <!-- U+FE5C SMALL RIGHT CURLY BRACKET (﹜) -->
		\uFE5D <!-- U+FE5D SMALL LEFT TORTOISE SHELL BRACKET (﹝) -->
		\uFE5E <!-- U+FE5E SMALL RIGHT TORTOISE SHELL BRACKET (﹞) -->
		\uFF5C <!-- U+FF5C FULLWIDTH VERTICAL LINE (｜) -->
		\uFF5F <!-- U+FF5F FULLWIDTH LEFT WHITE PARENTHESIS (｟) -->
		\uFF60 <!-- U+FF60 FULLWIDTH RIGHT WHITE PARENTHESIS (｠) -->
		\uFFE3 <!-- U+FFE3 FULLWIDTH MACRON (￣) -->
		\uFF3F <!-- U+FF3F FULLWIDTH LOW LINE (＿) -->
		\uFF5E <!-- U+FF5E FULLWIDTH TILDE (～) -->
		<!-- Rotate 180° -->
		\u309C <!-- U+309C KATAKANA-HIRAGANA SEMI-VOICED SOUND MARK (゜) -->
		\u3002 <!-- U+3002 IDEOGRAPHIC FULL STOP (。) -->
		\uFE52 <!-- U+FE52 SMALL FULL STOP (﹒) -->
		\uFF0E <!-- U+FF0E FULLWIDTH FULL STOP (．) -->
		]</xsl:variable>
	<xsl:variable name="regex_ja_spec"><xsl:value-of select="translate(normalize-space($regex_ja_spec_), ' ', '')"/></xsl:variable>
	<xsl:template name="insertVerticalChar">
		<xsl:param name="str"/>
		<xsl:param name="char_prev"/>
		<xsl:param name="writing-mode">lr-tb</xsl:param>
		<xsl:param name="reference-orientation">90</xsl:param>
		<xsl:param name="add_zero_width_space">false</xsl:param>
		<xsl:choose>
			<xsl:when test="ancestor::*[local-name() = 'span'][@class = 'norotate']">
				<xsl:value-of select="$str"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="string-length($str) &gt; 0">

					<!-- <xsl:variable name="horizontal_mode" select="normalize-space(ancestor::*[local-name() = 'span'][@class = 'horizontal'] and 1 = 1)"/> -->
					<xsl:variable name="char" select="substring($str,1,1)"/>
					<xsl:variable name="char_next" select="substring($str,2,1)"/>

					<xsl:variable name="char_half_width" select="normalize-space(java:matches(java:java.lang.String.new($char), concat('([', $regex_ja_spec_half_width, ']{1,})')))"/>

					<xsl:choose>
						<xsl:when test="$char_half_width = 'true'">
							<fo:inline>
								<xsl:attribute name="baseline-shift">7%</xsl:attribute>
								<xsl:value-of select="$char"/>
							</fo:inline>
						</xsl:when>
						<xsl:otherwise>
							<!--  namespace-uri(ancestor::*[local-name() = 'title']) != '' to skip title from $contents  -->
							<xsl:if test="namespace-uri(ancestor::*[local-name() = 'title']) != '' and ($char_prev = '' and ../preceding-sibling::node())">
								<fo:inline padding-left="1mm"><xsl:value-of select="$zero_width_space"/></fo:inline>
							</xsl:if>
							<fo:inline-container text-align="center" alignment-baseline="central" width="1em" margin="0" padding="0" text-indent="0mm" last-line-end-indent="0mm" start-indent="0mm" end-indent="0mm" role="SKIP" text-align-last="center">
								<xsl:if test="normalize-space($writing-mode) != ''">
									<xsl:attribute name="writing-mode"><xsl:value-of select="$writing-mode"/></xsl:attribute>
									<xsl:attribute name="reference-orientation">90</xsl:attribute>
								</xsl:if>
								<xsl:if test="normalize-space(java:matches(java:java.lang.String.new($char), concat('(', $regex_ja_spec, '{1,})'))) = 'true'">
									<xsl:attribute name="reference-orientation">0</xsl:attribute>
								</xsl:if>
								<xsl:if test="$char = '゜' or $char = '。' or $char = '﹒' or $char = '．'">
									<!-- Rotate 180°: 
										U+309C KATAKANA-HIRAGANA SEMI-VOICED SOUND MARK (゜)
										U+3002 IDEOGRAPHIC FULL STOP (。)
										U+FE52 SMALL FULL STOP (﹒)
										U+FF0E FULLWIDTH FULL STOP (．)
									-->
									<xsl:attribute name="reference-orientation">-90</xsl:attribute>
								</xsl:if>
								<fo:block-container width="1em" role="SKIP"><!-- border="0.5pt solid blue" -->
									<fo:block line-height="1em" role="SKIP">
										<!-- <xsl:choose>
											<xsl:when test="$horizontal_mode = 'true'">
												<xsl:value-of select="$str"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$char"/>
											</xsl:otherwise>
										</xsl:choose> -->
										<xsl:value-of select="$char"/>
									</fo:block>
								</fo:block-container>
							</fo:inline-container>
							<xsl:if test="namespace-uri(ancestor::*[local-name() = 'title']) != '' and ($char_next != '' or ../following-sibling::node())">
								<fo:inline padding-left="1mm"><xsl:value-of select="$zero_width_space"/></fo:inline>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:if test="$add_zero_width_space = 'true' and ($char = ',' or $char = '.' or $char = ' ' or $char = '·' or $char = ')' or $char = ']' or $char = '}' or $char = '/')"><xsl:value-of select="$zero_width_space"/></xsl:if>
						<!-- <xsl:if test="$horizontal_mode = 'false'"> -->
							<xsl:call-template name="insertVerticalChar">
								<xsl:with-param name="str" select="substring($str, 2)"/>
								<xsl:with-param name="char_prev" select="$char"/>
								<xsl:with-param name="writing-mode" select="$writing-mode"/>
								<xsl:with-param name="reference-orientation" select="$reference-orientation"/>
								<xsl:with-param name="add_zero_width_space" select="$add_zero_width_space"/>
							</xsl:call-template>
						<!-- </xsl:if> -->
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="insertHorizontalChars">
		<xsl:param name="str"/>
		<xsl:param name="writing-mode">lr-tb</xsl:param>
		<xsl:param name="reference-orientation">90</xsl:param>
		<xsl:param name="add_zero_width_space">false</xsl:param>
		<xsl:choose>
			<xsl:otherwise>
				<fo:inline-container text-align="center" alignment-baseline="central" width="1em" margin="0" padding="0" text-indent="0mm" last-line-end-indent="0mm" start-indent="0mm" end-indent="0mm" role="SKIP">
					<xsl:if test="normalize-space($writing-mode) != ''">
						<xsl:attribute name="writing-mode"><xsl:value-of select="$writing-mode"/></xsl:attribute>
						<xsl:attribute name="reference-orientation">90</xsl:attribute>
					</xsl:if>
					<fo:block-container width="1em" role="SKIP"> <!-- border="0.5pt solid green" -->
						<fo:block line-height="1em" role="SKIP">
							<xsl:value-of select="$str"/>
						</fo:block>
					</fo:block-container>
				</fo:inline-container>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="number-to-words">
		<xsl:param name="number"/>
		<xsl:param name="first"/>
		<xsl:if test="$number != ''">
			<xsl:variable name="words">
				<words>
					<xsl:choose>
						<xsl:when test="$lang = 'fr'"> <!-- https://en.wiktionary.org/wiki/Appendix:French_numbers -->
							<word cardinal="1">Une-</word>
							<word ordinal="1">Première </word>
							<word cardinal="2">Deux-</word>
							<word ordinal="2">Seconde </word>
							<word cardinal="3">Trois-</word>
							<word ordinal="3">Tierce </word>
							<word cardinal="4">Quatre-</word>
							<word ordinal="4">Quatrième </word>
							<word cardinal="5">Cinq-</word>
							<word ordinal="5">Cinquième </word>
							<word cardinal="6">Six-</word>
							<word ordinal="6">Sixième </word>
							<word cardinal="7">Sept-</word>
							<word ordinal="7">Septième </word>
							<word cardinal="8">Huit-</word>
							<word ordinal="8">Huitième </word>
							<word cardinal="9">Neuf-</word>
							<word ordinal="9">Neuvième </word>
							<word ordinal="10">Dixième </word>
							<word ordinal="11">Onzième </word>
							<word ordinal="12">Douzième </word>
							<word ordinal="13">Treizième </word>
							<word ordinal="14">Quatorzième </word>
							<word ordinal="15">Quinzième </word>
							<word ordinal="16">Seizième </word>
							<word ordinal="17">Dix-septième </word>
							<word ordinal="18">Dix-huitième </word>
							<word ordinal="19">Dix-neuvième </word>
							<word cardinal="20">Vingt-</word>
							<word ordinal="20">Vingtième </word>
							<word cardinal="30">Trente-</word>
							<word ordinal="30">Trentième </word>
							<word cardinal="40">Quarante-</word>
							<word ordinal="40">Quarantième </word>
							<word cardinal="50">Cinquante-</word>
							<word ordinal="50">Cinquantième </word>
							<word cardinal="60">Soixante-</word>
							<word ordinal="60">Soixantième </word>
							<word cardinal="70">Septante-</word>
							<word ordinal="70">Septantième </word>
							<word cardinal="80">Huitante-</word>
							<word ordinal="80">Huitantième </word>
							<word cardinal="90">Nonante-</word>
							<word ordinal="90">Nonantième </word>
							<word cardinal="100">Cent-</word>
							<word ordinal="100">Centième </word>
						</xsl:when>
						<xsl:when test="$lang = 'ru'">
							<word cardinal="1">Одна-</word>
							<word ordinal="1">Первое </word>
							<word cardinal="2">Две-</word>
							<word ordinal="2">Второе </word>
							<word cardinal="3">Три-</word>
							<word ordinal="3">Третье </word>
							<word cardinal="4">Четыре-</word>
							<word ordinal="4">Четвертое </word>
							<word cardinal="5">Пять-</word>
							<word ordinal="5">Пятое </word>
							<word cardinal="6">Шесть-</word>
							<word ordinal="6">Шестое </word>
							<word cardinal="7">Семь-</word>
							<word ordinal="7">Седьмое </word>
							<word cardinal="8">Восемь-</word>
							<word ordinal="8">Восьмое </word>
							<word cardinal="9">Девять-</word>
							<word ordinal="9">Девятое </word>
							<word ordinal="10">Десятое </word>
							<word ordinal="11">Одиннадцатое </word>
							<word ordinal="12">Двенадцатое </word>
							<word ordinal="13">Тринадцатое </word>
							<word ordinal="14">Четырнадцатое </word>
							<word ordinal="15">Пятнадцатое </word>
							<word ordinal="16">Шестнадцатое </word>
							<word ordinal="17">Семнадцатое </word>
							<word ordinal="18">Восемнадцатое </word>
							<word ordinal="19">Девятнадцатое </word>
							<word cardinal="20">Двадцать-</word>
							<word ordinal="20">Двадцатое </word>
							<word cardinal="30">Тридцать-</word>
							<word ordinal="30">Тридцатое </word>
							<word cardinal="40">Сорок-</word>
							<word ordinal="40">Сороковое </word>
							<word cardinal="50">Пятьдесят-</word>
							<word ordinal="50">Пятидесятое </word>
							<word cardinal="60">Шестьдесят-</word>
							<word ordinal="60">Шестидесятое </word>
							<word cardinal="70">Семьдесят-</word>
							<word ordinal="70">Семидесятое </word>
							<word cardinal="80">Восемьдесят-</word>
							<word ordinal="80">Восьмидесятое </word>
							<word cardinal="90">Девяносто-</word>
							<word ordinal="90">Девяностое </word>
							<word cardinal="100">Сто-</word>
							<word ordinal="100">Сотое </word>
						</xsl:when>
						<xsl:otherwise> <!-- default english -->
							<word cardinal="1">One-</word>
							<word ordinal="1">First </word>
							<word cardinal="2">Two-</word>
							<word ordinal="2">Second </word>
							<word cardinal="3">Three-</word>
							<word ordinal="3">Third </word>
							<word cardinal="4">Four-</word>
							<word ordinal="4">Fourth </word>
							<word cardinal="5">Five-</word>
							<word ordinal="5">Fifth </word>
							<word cardinal="6">Six-</word>
							<word ordinal="6">Sixth </word>
							<word cardinal="7">Seven-</word>
							<word ordinal="7">Seventh </word>
							<word cardinal="8">Eight-</word>
							<word ordinal="8">Eighth </word>
							<word cardinal="9">Nine-</word>
							<word ordinal="9">Ninth </word>
							<word ordinal="10">Tenth </word>
							<word ordinal="11">Eleventh </word>
							<word ordinal="12">Twelfth </word>
							<word ordinal="13">Thirteenth </word>
							<word ordinal="14">Fourteenth </word>
							<word ordinal="15">Fifteenth </word>
							<word ordinal="16">Sixteenth </word>
							<word ordinal="17">Seventeenth </word>
							<word ordinal="18">Eighteenth </word>
							<word ordinal="19">Nineteenth </word>
							<word cardinal="20">Twenty-</word>
							<word ordinal="20">Twentieth </word>
							<word cardinal="30">Thirty-</word>
							<word ordinal="30">Thirtieth </word>
							<word cardinal="40">Forty-</word>
							<word ordinal="40">Fortieth </word>
							<word cardinal="50">Fifty-</word>
							<word ordinal="50">Fiftieth </word>
							<word cardinal="60">Sixty-</word>
							<word ordinal="60">Sixtieth </word>
							<word cardinal="70">Seventy-</word>
							<word ordinal="70">Seventieth </word>
							<word cardinal="80">Eighty-</word>
							<word ordinal="80">Eightieth </word>
							<word cardinal="90">Ninety-</word>
							<word ordinal="90">Ninetieth </word>
							<word cardinal="100">Hundred-</word>
							<word ordinal="100">Hundredth </word>
						</xsl:otherwise>
					</xsl:choose>
				</words>
			</xsl:variable>

			<xsl:variable name="ordinal" select="xalan:nodeset($words)//word[@ordinal = $number]/text()"/>

			<xsl:variable name="value">
				<xsl:choose>
					<xsl:when test="$ordinal != ''">
						<xsl:value-of select="$ordinal"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="$number &lt; 100">
								<xsl:variable name="decade" select="concat(substring($number,1,1), '0')"/>
								<xsl:variable name="digit" select="substring($number,2)"/>
								<xsl:value-of select="xalan:nodeset($words)//word[@cardinal = $decade]/text()"/>
								<xsl:value-of select="xalan:nodeset($words)//word[@ordinal = $digit]/text()"/>
							</xsl:when>
							<xsl:otherwise>
								<!-- more 100 -->
								<xsl:variable name="hundred" select="substring($number,1,1)"/>
								<xsl:variable name="digits" select="number(substring($number,2))"/>
								<xsl:value-of select="xalan:nodeset($words)//word[@cardinal = $hundred]/text()"/>
								<xsl:value-of select="xalan:nodeset($words)//word[@cardinal = '100']/text()"/>
								<xsl:call-template name="number-to-words">
									<xsl:with-param name="number" select="$digits"/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$first = 'true'">
					<xsl:variable name="value_lc" select="java:toLowerCase(java:java.lang.String.new($value))"/>
					<xsl:call-template name="capitalize">
						<xsl:with-param name="str" select="$value_lc"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$value"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template> <!-- number-to-words -->

	<!-- st for 1, nd for 2, rd for 3, th for 4, 5, 6, ... -->
	<xsl:template name="number-to-ordinal">
		<xsl:param name="number"/>
		<xsl:param name="curr_lang"/>
		<xsl:choose>
			<xsl:when test="$curr_lang = 'fr'">
				<xsl:choose>
					<xsl:when test="$number = '1'">re</xsl:when>
					<xsl:otherwise>e</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$number = 1">st</xsl:when>
					<xsl:when test="$number = 2">nd</xsl:when>
					<xsl:when test="$number = 3">rd</xsl:when>
					<xsl:otherwise>th</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template> <!-- number-to-ordinal -->

	<!-- add the attribute fox:alt-text, required for PDF/UA -->
	<xsl:template name="setAltText">
		<xsl:param name="value"/>
		<xsl:attribute name="fox:alt-text">
			<xsl:choose>
				<xsl:when test="normalize-space($value) != ''">
					<xsl:value-of select="$value"/>
				</xsl:when>
				<xsl:otherwise>_</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<xsl:template name="substring-after-last">
		<xsl:param name="value"/>
		<xsl:param name="delimiter"/>
		<xsl:choose>
			<xsl:when test="contains($value, $delimiter)">
				<xsl:call-template name="substring-after-last">
					<xsl:with-param name="value" select="substring-after($value, $delimiter)"/>
					<xsl:with-param name="delimiter" select="$delimiter"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="print_as_xml">
		<xsl:param name="level">0</xsl:param>

		<fo:block margin-left="{2*$level}mm">
			<xsl:text>
&lt;</xsl:text>
			<xsl:value-of select="local-name()"/>
			<xsl:for-each select="@*">
				<xsl:text> </xsl:text>
				<xsl:value-of select="local-name()"/>
				<xsl:text>="</xsl:text>
				<xsl:value-of select="."/>
				<xsl:text>"</xsl:text>
			</xsl:for-each>
			<xsl:text>&gt;</xsl:text>

			<xsl:if test="not(*)">
				<fo:inline font-weight="bold"><xsl:value-of select="."/></fo:inline>
				<xsl:text>&lt;/</xsl:text>
					<xsl:value-of select="local-name()"/>
					<xsl:text>&gt;</xsl:text>
			</xsl:if>
		</fo:block>

		<xsl:if test="*">
			<fo:block>
				<xsl:apply-templates mode="print_as_xml">
					<xsl:with-param name="level" select="$level + 1"/>
				</xsl:apply-templates>
			</fo:block>
			<fo:block margin-left="{2*$level}mm">
				<xsl:text>&lt;/</xsl:text>
				<xsl:value-of select="local-name()"/>
				<xsl:text>&gt;</xsl:text>
			</fo:block>
		</xsl:if>
	</xsl:template>

	<xsl:template match="@*|node()" mode="set_table_role_skip">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="set_table_role_skip"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[starts-with(local-name(), 'table')]" mode="set_table_role_skip">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="set_table_role_skip"/>
			<xsl:attribute name="role">SKIP</xsl:attribute>
			<xsl:apply-templates select="node()" mode="set_table_role_skip"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>