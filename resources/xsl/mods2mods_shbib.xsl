<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" 
  xmlns:pica="info:srw/schema/5/picaXML-v1.0"
  xmlns:str="http://exslt.org/strings"
  exclude-result-prefixes="i18n xsl str pica" >
  <xsl:param name="parentId" />
  <xsl:param name="WebApplicationBaseURL" />
  
  <xsl:output method="xml" encoding="UTF-8" indent="yes" />

  <xsl:include href="xslInclude:PPN-mods-simple"/> 
  <xsl:include href="copynodes.xsl" />  
  
  <xsl:variable name="ppn" select="//mods:mods/mods:recordInfo/mods:recordIdentifier[@source='DE-601']" />
  
  <xsl:template match="mods:genre[@authority='marcgt']">
  </xsl:template>
  
  <!-- remove all classifications -->
  <xsl:template match="mods:classification">
  </xsl:template>
  
  <!-- remove all subjects -->
  <xsl:template match="mods:subject">
  </xsl:template>
  
  <xsl:template match="mods:name[@type='corporate'][not(mods:role)]">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="*" />
      <mods:role>
        <mods:roleTerm authority="marcrelator" type="code">ctb</mods:roleTerm>
      </mods:role>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mods:detail[not(@type)]">
  </xsl:template>
  
  
  <xsl:template match="mods:note[@type='action' or @type='bibliography']">
  </xsl:template>
  
  <xsl:template match="mods:part/mods:text">
  </xsl:template>
  
  <xsl:template match="mods:roleTerm[@authority='marcrelator'][@type='code'][text()='edit']">
    <roleTerm authority="marcrelator" type="code">edt</roleTerm>
  </xsl:template>
    
</xsl:stylesheet>