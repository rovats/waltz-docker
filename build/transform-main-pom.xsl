<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                version="1.0">

    <xsl:template name="identity" match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" />
        </xsl:copy>
    </xsl:template>

    <!-- remove modules tag -->
    <xsl:template match="*">
        <xsl:if test="not(name() = 'modules')">
            <xsl:call-template name="identity" />
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
