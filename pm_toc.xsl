<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:template name="output-string">
        <xsl:param name="value"/>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="translate($value, '', '\')"/>
        <xsl:text>"</xsl:text>
    </xsl:template>
    <xsl:template name="generate-dmc-string">
        <xsl:param name="dmCodeNode"/>
        <xsl:value-of select="$dmCodeNode/@modelIdentCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$dmCodeNode/@systemDiffCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$dmCodeNode/@systemCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$dmCodeNode/@subSystemCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$dmCodeNode/@subSubSystemCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$dmCodeNode/@assyCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$dmCodeNode/@disassyCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$dmCodeNode/@disassyCodeVariant"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$dmCodeNode/@infoCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$dmCodeNode/@infoCodeVariant"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$dmCodeNode/@itemLocationCode"/>
    </xsl:template>
    <!-- Root template -->
    <xsl:template match="/pm">
        <xsl:text>const ToC = [</xsl:text>
        <!-- Apply templates to ALL dmRef elements found within the content section -->
        <xsl:apply-templates select=".//content//dmRef"/>
        <xsl:text>
];</xsl:text>
        <!-- Add newline before closing bracket -->
        <xsl:text>

module.exports = ToC;</xsl:text>
    </xsl:template>
    <!-- Template for each dmRef - THIS IS THE MAIN CHANGE -->
    <xsl:template match="dmRef">
        <!-- Get the nearest ancestor pmEntry for CategoryId -->
        <xsl:variable name="parentPmEntry" select="ancestor::pmEntry[1]"/>
        <!-- Construct the DMC string for this dmRef -->
        <xsl:variable name="dmcString">
            <xsl:call-template name="generate-dmc-string">
                <xsl:with-param name="dmCodeNode" select="dmRefIdent/dmCode"/>
            </xsl:call-template>
        </xsl:variable>
        <!-- Construct the DisplayName -->
        <xsl:variable name="techNameValue" select="normalize-space(dmRefAddressItems/dmTitle/techName)"/>
        <xsl:variable name="infoNameValue" select="normalize-space(dmRefAddressItems/dmTitle/infoName)"/>
        <xsl:variable name="displayNameValue">
            <xsl:value-of select="$dmcString"/>
            <xsl:if test="$techNameValue != ''">
                <xsl:text> </xsl:text>
                <xsl:value-of select="$techNameValue"/>
            </xsl:if>
            <xsl:if test="$infoNameValue != ''">
                <xsl:text>-</xsl:text>
                <xsl:value-of select="$infoNameValue"/>
            </xsl:if>
        </xsl:variable>
        <xsl:text>
  {</xsl:text>
        <!-- ID: Using generate-id based on the dmRef node -->
        <xsl:text>
    "ID": "</xsl:text>
        <xsl:value-of select="generate-id(.)"/>
        <xsl:text>",</xsl:text>
        <!-- CategoryId: ID of the nearest ancestor pmEntry -->
        <xsl:text>
    "CategoryId": </xsl:text>
        <xsl:choose>
            <xsl:when test="$parentPmEntry">
                <xsl:text>"</xsl:text>
                <xsl:value-of select="generate-id($parentPmEntry)"/>
                <xsl:text>"</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>null</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>,</xsl:text>
        <!-- DisplayName -->
        <xsl:text>
    "DisplayName": </xsl:text>
        <xsl:call-template name="output-string">
            <xsl:with-param name="value" select="$displayNameValue"/>
        </xsl:call-template>
        <xsl:text>,</xsl:text>
        <!-- PMEntryType -->
        <xsl:text>
    "PMEntryType": null,</xsl:text>
        <!-- Assuming null -->
        <!-- DMC -->
        <xsl:text>
    "DMC": </xsl:text>
        <xsl:call-template name="output-string">
            <xsl:with-param name="value" select="$dmcString"/>
        </xsl:call-template>
        <xsl:text>,</xsl:text>
        <!-- Hardcoded fields based on example -->
        <xsl:text>
    "AddedNew": false,</xsl:text>
        <xsl:text>
    "dmIdUpissued": false,</xsl:text>
        <xsl:text>
    "dmId": 0,</xsl:text>
        <xsl:text>
    "pmId": 0,</xsl:text>
        <xsl:text>
    "expanded": false,</xsl:text>
        <!-- Type: Always 1 when processing a dmRef -->
        <xsl:text>
    "Type": 1,</xsl:text>
        <!-- dmRef object: Process the current dmRef node -->
        <xsl:text>
    "dmRef": </xsl:text>
        <xsl:apply-templates select="." mode="json"/>
        <xsl:text>,</xsl:text>
        <!-- pmRefs -->
        <xsl:text>
    "pmRefs": null,</xsl:text>
        <!-- Assuming null -->
        <!-- Children -->
        <xsl:text>
    "Children": []</xsl:text>
        <!-- Flattened list, no children here -->
        <xsl:text>
  }</xsl:text>
        <!-- Add comma if this is NOT the last dmRef processed in the whole selection -->
        <xsl:if test="following::dmRef[ancestor::content]">
            <xsl:text>,</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- Templates to generate the nested dmRef JSON object -->
    <!-- These remain largely the same, but are now called with the specific dmRef context -->
    <xsl:template match="dmRef" mode="json">
        <xsl:text>{</xsl:text>
        <xsl:text>
      "DmRefIdent": </xsl:text>
        <xsl:apply-templates select="dmRefIdent" mode="json"/>
        <xsl:text>,</xsl:text>
        <xsl:text>
      "DmRefAddressItems": </xsl:text>
        <xsl:apply-templates select="dmRefAddressItems" mode="json"/>
        <xsl:text>,</xsl:text>
        <xsl:text>
      "ApplicRefId": null</xsl:text>
        <!-- Assuming null -->
        <xsl:text>
    }</xsl:text>
    </xsl:template>
    <xsl:template match="dmRefIdent" mode="json">
        <xsl:text>{</xsl:text>
        <xsl:text>
        "DmCode": </xsl:text>
        <xsl:apply-templates select="dmCode" mode="json"/>
        <xsl:text>,</xsl:text>
        <xsl:text>
        "IssueInfo": </xsl:text>
        <xsl:apply-templates select="issueInfo" mode="json"/>
        <xsl:text>,</xsl:text>
        <xsl:text>
        "Language": </xsl:text>
        <xsl:apply-templates select="language" mode="json"/>
        <xsl:text>
      }</xsl:text>
    </xsl:template>
    <xsl:template match="dmCode" mode="json">
        <xsl:text>{</xsl:text>
        <xsl:text>"ModelIdentCode": "</xsl:text>
        <xsl:value-of select="@modelIdentCode"/>
        <xsl:text>", </xsl:text>
        <xsl:text>"SystemDiffCode": "</xsl:text>
        <xsl:value-of select="@systemDiffCode"/>
        <xsl:text>", </xsl:text>
        <xsl:text>"SystemCode": "</xsl:text>
        <xsl:value-of select="@systemCode"/>
        <xsl:text>", </xsl:text>
        <xsl:text>"SubSystemCode": "</xsl:text>
        <xsl:value-of select="@subSystemCode"/>
        <xsl:text>", </xsl:text>
        <xsl:text>"SubSubSystemCode": "</xsl:text>
        <xsl:value-of select="@subSubSystemCode"/>
        <xsl:text>", </xsl:text>
        <xsl:text>"AssyCode": "</xsl:text>
        <xsl:value-of select="@assyCode"/>
        <xsl:text>", </xsl:text>
        <xsl:text>"DisassyCode": "</xsl:text>
        <xsl:value-of select="@disassyCode"/>
        <xsl:text>", </xsl:text>
        <xsl:text>"DisassyCodeVariant": "</xsl:text>
        <xsl:value-of select="@disassyCodeVariant"/>
        <xsl:text>", </xsl:text>
        <xsl:text>"InfoCode": "</xsl:text>
        <xsl:value-of select="@infoCode"/>
        <xsl:text>", </xsl:text>
        <xsl:text>"InfoCodeVariant": "</xsl:text>
        <xsl:value-of select="@infoCodeVariant"/>
        <xsl:text>", </xsl:text>
        <xsl:text>"ItemLocationCode": "</xsl:text>
        <xsl:value-of select="@itemLocationCode"/>
        <xsl:text>"</xsl:text>
        <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="issueInfo" mode="json">
        <xsl:text>{</xsl:text>
        <xsl:text>"IssueNumber": "</xsl:text>
        <xsl:value-of select="@issueNumber"/>
        <xsl:text>", </xsl:text>
        <xsl:text>"InWork": "</xsl:text>
        <xsl:value-of select="@inWork"/>
        <xsl:text>"</xsl:text>
        <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="language" mode="json">
        <xsl:text>{</xsl:text>
        <xsl:text>"CountryIsoCode": "</xsl:text>
        <xsl:value-of select="@countryIsoCode"/>
        <xsl:text>", </xsl:text>
        <xsl:text>"LanguageIsoCode": "</xsl:text>
        <xsl:value-of select="@languageIsoCode"/>
        <xsl:text>"</xsl:text>
        <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="dmRefAddressItems" mode="json">
        <xsl:text>{</xsl:text>
        <xsl:text>
        "DmTitle": </xsl:text>
        <xsl:apply-templates select="dmTitle" mode="json"/>
        <xsl:text>,</xsl:text>
        <xsl:text>
        "IssueDate": null</xsl:text>
        <!-- Assuming null -->
        <xsl:text>
      }</xsl:text>
    </xsl:template>
    <xsl:template match="dmTitle" mode="json">
        <xsl:text>{</xsl:text>
        <xsl:text>
           "TechName": </xsl:text>
        <!-- Check if techName exists and is not empty before processing -->
        <xsl:choose>
            <xsl:when test="techName and normalize-space(techName) != ''">
                <xsl:apply-templates select="techName" mode="json-text"/>
            </xsl:when>
            <xsl:otherwise>null</xsl:otherwise>
            <!-- Output null if missing or empty -->
        </xsl:choose>
        <xsl:text>,</xsl:text>
        <xsl:text>
           "InfoName": </xsl:text>
        <!-- Check if infoName exists and is not empty before processing -->
        <xsl:choose>
            <xsl:when test="infoName and normalize-space(infoName) != ''">
                <xsl:apply-templates select="infoName" mode="json-text"/>
            </xsl:when>
            <xsl:otherwise>null</xsl:otherwise>
            <!-- Output null if missing or empty -->
        </xsl:choose>
        <xsl:text>
         }</xsl:text>
    </xsl:template>
    <!-- Template for simple text elements within dmTitle -->
    <xsl:template match="techName | infoName" mode="json-text">
        <xsl:text>{</xsl:text>
        <xsl:text>"Text": </xsl:text>
        <xsl:call-template name="output-string">
            <xsl:with-param name="value" select="normalize-space(.)"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
    </xsl:template>
    <!-- Ignore text nodes that are just whitespace -->
    <xsl:template match="text()[normalize-space(.)='']"/>
    <!-- Prevent default processing of pmEntry if encountered directly -->
    <xsl:template match="pmEntry"/>
</xsl:stylesheet>