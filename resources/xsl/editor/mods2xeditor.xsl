<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mirddctosndbmapper="xalan://org.mycore.mir.impexp.MIRDDCtoSNDBMapper" exclude-result-prefixes="mcrmods xlink mirddctosndbmapper i18n" version="1.0"
>

  <xsl:include href="copynodes.xsl" />
  <xsl:include href="editor/mods-node-utils.xsl" />

  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="MIR.PPN.DatabaseList" select="'gvk'" />

  <!-- shbib specific stuff needed for group sachgruppe with subject -->
  <xsl:template match="modsSourceContainer[@type='local']/mods:mods">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates
        select="*[not( (local-name()='classification' and contains(@authorityURI,'shbib_sachgruppen')) 
            or (local-name()='subject' and contains(@xlink:href,'shbib_sachgruppen')) )]" />
      <xsl:for-each select="mods:classification[contains(@authorityURI,'shbib_sachgruppen')]">
        <xsl:variable name="position">
          <xsl:value-of select="position()" />
        </xsl:variable>
        <xLinkGroup>
          <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates select="*" />
          </xsl:copy>
          <!-- <xsl:apply-templates select="../mods:subject[contains(@xlink:href,concat('%5B',position(),'%5D'))]" /> -->
          <!-- <xsl:foreach select="../mods:subject">
            <mods:subject><mods:topic><xsl:value-of select="concat('%5B',position(),'%5D')"/></mods:topic></mods:subject>
          </xsl:foreach> -->
          <xsl:variable name="condition">
            <xsl:value-of select="concat('%5B',position(),'%5D')" />
          </xsl:variable>
          <xsl:apply-templates select="../mods:subject[contains(@xlink:href,$condition)]" />
        </xLinkGroup>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <!-- put value string (after authority URI) in attribute valueURIxEditor -->
  <xsl:template match="@valueURI">
    <xsl:attribute name="valueURIxEditor">
      <xsl:value-of select="substring-after(.,'#')" />
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="mods:subject">
    <xsl:copy>
      <!-- <xsl:copy-of select="@*" /> -->
      <xsl:for-each select="./*">
        <mods:mirTopic>
          <xsl:apply-templates select='.'/>
        </mods:mirTopic> 
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mods:classification[@authorityURI='http://www.mycore.org/classifications/shbib_zeitschluessel' or @authorityURI='http://www.mycore.org/classifications/shbib_formschluessel']">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:topic/@valueURI">
    <xsl:attribute name="valueURIxEditor">
      <xsl:value-of select="substring-after(.,../@authorityURI)" />
    </xsl:attribute>
  </xsl:template>

  <!-- Delte from old imported Data - TODO Improve XPATH -->
  <xsl:template match="mods:mods/mods:titleInfo
                      |mods:mods/mods:name
                      |mods:mods/mods:typeOfResource
                      |mods:mods/mods:language
                      |mods:mods/mods:extension
                      |mods:mods/mods:originInfo
                      |mods:mods/mods:accessCondition
                      |mods:mods/mods:genre
                      |mods:mods/mods:identifier[not(@type='intern')]
                      |mods:mods/mods:note[not(@type='admin' or @type='annotation')]
                      |mods:mods/mods:relatedItem
                      |mods:mods/mods:physicalDescription
                      |mods:mods/mods:location
                      |mods:classification
                      |mods:mods/mods:extent">
    
  </xsl:template>

  <xsl:template match="mods:identifier[@type='intern']">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mods:topic[not(@authority)]">
    <mods:topicSimple>
      <xsl:value-of select="."/>
    </mods:topicSimple>
  </xsl:template>


</xsl:stylesheet>