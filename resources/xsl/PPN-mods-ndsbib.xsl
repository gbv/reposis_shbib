<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" exclude-result-prefixes="i18n xlink xsl mods" >
  <xsl:param name="parentId" />

  <xsl:include href="xslInclude:PPN-mods-simple"/>
  <xsl:include href="copynodes.xsl" />

  <xsl:template match="/">
    <mods:mods>
      <xsl:apply-templates select="mods:mods/*" />
      <mods:identifier invalid="yes" type="uri">
        <xsl:value-of select="concat('//gso.gbv.de/DB=2.1/PPNSET?PPN=', mods:mods/mods:recordInfo/mods:recordIdentifier[@source='DE-601'])" />
      </mods:identifier>
    </mods:mods>
  </xsl:template>

  <xsl:template match="*">
    <xsl:element name="mods:{name()}">
      <xsl:copy-of select="namespace::*" />
      <xsl:apply-templates select="node()|@*" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="mods:originInfo[not(@eventType)]">
    <xsl:if test="not(//mods:mods/mods:originInfo/@eventType='publication')">
      <mods:originInfo eventType="publication">
        <xsl:apply-templates select="node()|@*" />
      </mods:originInfo>
    </xsl:if>
  </xsl:template>

  
  <xsl:template name="yearRAK2w3cdtf">
    <xsl:param name="date"/>
    <xsl:value-of select="translate($date,'[]?ca','')"/>
  </xsl:template>
  

  <xsl:template match="mods:dateIssued[not(@encoding)]">
    <!-- TODO: check date format first! -->
    <xsl:variable name="datevalue">
      <xsl:call-template  name="yearRAK2w3cdtf">
        <xsl:with-param name="date" select="node()"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($datevalue,'-')">
        <mods:dateIssued encoding="w3cdtf" point="start">
          <xsl:value-of select="substring-before($datevalue,'-')"/>
        </mods:dateIssued>
        <xsl:variable name="datevalueAfter" select="substring-after($datevalue,'-')" />
        <xsl:if test="string-length($datevalueAfter)">
          <mods:dateIssued encoding="w3cdtf" point="end">
            <xsl:value-of select="$datevalueAfter"/>
          </mods:dateIssued>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="$datevalue"/>
          <xsl:apply-templates select="@*" />
        </mods:dateIssued>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="mods:languageTerm[@authority='iso639-2b']">
    <xsl:variable name="languages" select="document('classification:metadata:-1:children:rfc4646')" />
    <xsl:variable name="rfcCode">
      <xsl:value-of select="$languages//category[contains(label[@xml:lang='x-bibl']/@text, .)]/@ID" />
    </xsl:variable>
    <mods:languageTerm authority="rfc4646" type="code">
      <xsl:value-of select="$rfcCode"/>    
    </mods:languageTerm>
  </xsl:template>
  
  <!-- remove all classifications -->
  <xsl:template match="mods:classification">
  </xsl:template>
  
  <!-- remove all subjects -->
  <xsl:template match="mods:subject">
  </xsl:template>
  
  <!-- remove invalid mods -->
  <xsl:template match="mods:extent[text()]">
  </xsl:template>
    
</xsl:stylesheet>