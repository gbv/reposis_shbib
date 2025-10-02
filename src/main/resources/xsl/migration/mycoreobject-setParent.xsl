<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mods="http://www.loc.gov/mods/v3" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:math="http://exslt.org/math"
  xmlns:mcrdataurl="xalan://org.mycore.datamodel.common.MCRDataURL">
  
  <xsl:include href="copynodes.xsl" />
  
  <xsl:variable name="setParent" select="'640377122'"/>
  
   
  <xsl:template match="modsSourceContainer[@type='local']/mods:mods/mods:relatedItem[@type='host' or @type='series']/mods:identifier[@type='local']">
    <mods:identifier type="local">
      <xsl:value-of select="concat('(DE-601)',$setParent)" />
    </mods:identifier>
  </xsl:template> 
  
</xsl:stylesheet>