<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="w dc rdf xlink">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <!-- Parameters for identAndStatusSection -->
    <xsl:param name="pDmType" select="'descript'"/>
    <!-- 'descript' or 'proced' -->
    <!-- dmIdent parameters -->
    <xsl:param name="pModelIdentCode" select="'MODELX'"/>
    <xsl:param name="pSystemDiffCode" select="'A'"/>
    <xsl:param name="pSystemCode" select="'00'"/>
    <xsl:param name="pSubSystemCode" select="'0'"/>
    <xsl:param name="pSubSubSystemCode" select="'0'"/>
    <xsl:param name="pAssyCode" select="'0000'"/>
    <xsl:param name="pDisassyCode" select="'00'"/>
    <xsl:param name="pDisassyCodeVariant" select="'A'"/>
    <xsl:param name="pInfoCode" select="'040'"/>
    <!-- 040 for descript, 720 for proced, etc. -->
    <xsl:param name="pInfoCodeVariant" select="'A'"/>
    <xsl:param name="pItemLocationCode" select="'A'"/>
    <xsl:param name="pLanguageIsoCode" select="'en'"/>
    <xsl:param name="pLanguageCountryIsoCode" select="'US'"/>
    <xsl:param name="pIssueNumber" select="'001'"/>
    <xsl:param name="pInWork" select="'00'"/>
    <!-- dmAddressItems parameters -->
    <xsl:param name="pIssueDateYear" select="'2023'"/>
    <xsl:param name="pIssueDateMonth" select="'10'"/>
    <xsl:param name="pIssueDateDay" select="'26'"/>
    <xsl:param name="pTechName" select="'Sample Technical Name'"/>
    <xsl:param name="pInfoName" select="'Sample Information Name'"/>
    <xsl:param name="pInfoNameVariant" select="''"/>
    <!-- dmStatus parameters -->
    <xsl:param name="pSecurityClassification" select="'01'"/>
    <!-- 01 for Unclassified -->
    <xsl:param name="pResponsiblePartnerCompanyEnterpriseName" select="'MyCompany'"/>
    <xsl:param name="pResponsiblePartnerCompanyEnterpriseCode" select="'CAGE01'"/>
    <xsl:param name="pOriginatorEnterpriseName" select="'MyCompany'"/>
    <xsl:param name="pOriginatorEnterpriseCode" select="'CAGE01'"/>
    <xsl:param name="pApplicCrossRefDmCodeModelIdentCode" select="$pModelIdentCode"/>
    <xsl:param name="pApplicCrossRefDmCodeSystemDiffCode" select="$pSystemDiffCode"/>
    <xsl:param name="pApplicCrossRefDmCodeSystemCode" select="'00'"/>
    <xsl:param name="pApplicCrossRefDmCodeSubSystemCode" select="'0'"/>
    <xsl:param name="pApplicCrossRefDmCodeSubSubSystemCode" select="'0'"/>
    <xsl:param name="pApplicCrossRefDmCodeAssyCode" select="'0000'"/>
    <xsl:param name="pApplicCrossRefDmCodeDisassyCode" select="'00'"/>
    <xsl:param name="pApplicCrossRefDmCodeDisassyCodeVariant" select="'A'"/>
    <xsl:param name="pApplicCrossRefDmCodeInfoCode" select="'00W'"/>
    <!-- ACT/CCT -->
    <xsl:param name="pApplicCrossRefDmCodeInfoCodeVariant" select="'A'"/>
    <xsl:param name="pApplicCrossRefDmCodeItemLocationCode" select="'A'"/>
    <xsl:param name="pSkillLevelCode" select="'SKL01'"/>
    <xsl:param name="pRemarksText" select="'Converted from Word document.'"/>
    <!-- Heuristic: Try to get techName from first Heading1 -->
    <xsl:variable name="vFirstHeading1Text" select="normalize-space(string-join(//w:document/w:body/w:p[w:pPr/w:pStyle/@w:val='Heading1'][1]//w:t/text(), ''))"/>
    <xsl:variable name="vEffectiveTechName" select="if (string-length($vFirstHeading1Text) > 0) then $vFirstHeading1Text else $pTechName"/>
    <!-- Main template -->
    <xsl:template match="/w:document">
        <xsl:element name="dmodule">
            <xsl:attribute name="xsi:noNamespaceSchemaLocation">
                <xsl:choose>
                    <xsl:when test="$pDmType = 'proced'">http://www.s1000d.org/S1000D_6/xml_schema_flat/proced.xsd</xsl:when>
                    <xsl:otherwise>http://www.s1000d.org/S1000D_6/xml_schema_flat/descript.xsd</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!-- Add other namespaces if needed by content, e.g. xlink for refs -->
            <xsl:call-template name="identAndStatusSection"/>
            <xsl:call-template name="content"/>
        </xsl:element>
    </xsl:template>
    <!-- Template for identAndStatusSection -->
    <xsl:template name="identAndStatusSection">
        <identAndStatusSection>
            <dmAddress>
                <dmIdent>
                    <dmCode
                        modelIdentCode="{$pModelIdentCode}"
                        systemDiffCode="{$pSystemDiffCode}"
                        systemCode="{$pSystemCode}"
                        subSystemCode="{$pSubSystemCode}"
                        subSubSystemCode="{$pSubSubSystemCode}"
                        assyCode="{$pAssyCode}"
                        disassyCode="{$pDisassyCode}"
                        disassyCodeVariant="{$pDisassyCodeVariant}"
                        infoCode="{if ($pDmType = 'proced') then '720' else '040'}"
                        infoCodeVariant="{$pInfoCodeVariant}"
                        itemLocationCode="{$pItemLocationCode}"/>
                    <language languageIsoCode="{$pLanguageIsoCode}" countryIsoCode="{$pLanguageCountryIsoCode}"/>
                    <issueInfo issueNumber="{$pIssueNumber}" inWork="{$pInWork}"/>
                </dmIdent>
                <dmAddressItems>
                    <issueDate year="{$pIssueDateYear}" month="{$pIssueDateMonth}" day="{$pIssueDateDay}"/>
                    <dmTitle>
                        <techName>
                            <xsl:value-of select="$vEffectiveTechName"/>
                        </techName>
                        <infoName>
                            <xsl:value-of select="$pInfoName"/>
                        </infoName>
                        <xsl:if test="string-length($pInfoNameVariant) > 0">
                            <infoNameVariant>
                                <xsl:value-of select="$pInfoNameVariant"/>
                            </infoNameVariant>
                        </xsl:if>
                    </dmTitle>
                </dmAddressItems>
            </dmAddress>
            <dmStatus issueType="new">
                <!-- Or parameterize -->
                <security securityClassification="{$pSecurityClassification}"/>
                <responsiblePartnerCompany enterpriseName="{$pResponsiblePartnerCompanyEnterpriseName}">
                    <enterpriseCode cageCode="{$pResponsiblePartnerCompanyEnterpriseCode}"/>
                </responsiblePartnerCompany>
                <originator enterpriseName="{$pOriginatorEnterpriseName}">
                    <enterpriseCode cageCode="{$pOriginatorEnterpriseCode}"/>
                </originator>
                <applicCrossRefTableRef>
                    <dmRef>
                        <dmRefIdent>
                            <dmCode
                                modelIdentCode="{$pApplicCrossRefDmCodeModelIdentCode}"
                                systemDiffCode="{$pApplicCrossRefDmCodeSystemDiffCode}"
                                systemCode="{$pApplicCrossRefDmCodeSystemCode}"
                                subSystemCode="{$pApplicCrossRefDmCodeSubSystemCode}"
                                subSubSystemCode="{$pApplicCrossRefDmCodeSubSubSystemCode}"
                                assyCode="{$pApplicCrossRefDmCodeAssyCode}"
                                disassyCode="{$pApplicCrossRefDmCodeDisassyCode}"
                                disassyCodeVariant="{$pApplicCrossRefDmCodeDisassyCodeVariant}"
                                infoCode="{$pApplicCrossRefDmCodeInfoCode}"
                                infoCodeVariant="{$pApplicCrossRefDmCodeInfoCodeVariant}"
                                itemLocationCode="{$pApplicCrossRefDmCodeItemLocationCode}"/>
                        </dmRefIdent>
                    </dmRef>
                </applicCrossRefTableRef>
                <applic>
                    <displayText>
                        <simplePara>All</simplePara>
                        <!-- Or parameterize/derive -->
                    </displayText>
                </applic>
                <brexDmRef>
                    <!-- As per your example -->
                    <dmRef>
                        <dmRefIdent>
                            <dmCode modelIdentCode="S1000D" systemDiffCode="H" systemCode="04" subSystemCode="1" subSubSystemCode="0" assyCode="0301" disassyCode="00" disassyCodeVariant="A" infoCode="022" infoCodeVariant="A" itemLocationCode="D"/>
                        </dmRefIdent>
                    </dmRef>
                </brexDmRef>
                <qualityAssurance>
                    <unverified/>
                    <!-- Or parameterize -->
                </qualityAssurance>
                <skillLevel skillLevelCode="{$pSkillLevelCode}"/>
                <xsl:if test="string-length(normalize-space($pRemarksText)) > 0">
                    <remarks>
                        <simplePara>
                            <xsl:value-of select="$pRemarksText"/>
                        </simplePara>
                    </remarks>
                </xsl:if>
            </dmStatus>
        </identAndStatusSection>
    </xsl:template>
    <!-- Template for content section -->
    <xsl:template name="content">
        <content>
            <xsl:choose>
                <xsl:when test="$pDmType = 'proced'">
                    <procedure>
                        <preliminaryRqmts>
                            <reqCondGroup>
                                <noConds/>
                            </reqCondGroup>
                            <reqSupportEquips>
                                <noSupportEquips/>
                            </reqSupportEquips>
                            <reqSupplies>
                                <noSupplies/>
                            </reqSupplies>
                            <reqSpares>
                                <noSpares/>
                            </reqSpares>
                            <reqSafety>
                                <noSafety/>
                            </reqSafety>
                        </preliminaryRqmts>
                        <mainProcedure>
                            <!-- Group paragraphs: treat numbered lists as steps, others as paras -->
                            <xsl:for-each-group select="w:body/*[self::w:p or self::w:tbl]" group-adjacent="boolean(self::w:p/w:pPr/w:numPr)">
                                <xsl:choose>
                                    <xsl:when test="current-grouping-key()">
                                        <!-- This is a group of list items -->
                                        <xsl:apply-templates select="current-group()" mode="proceduralStep"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- Not a list item, general content -->
                                        <xsl:apply-templates select="current-group()" mode="mainContent"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each-group>
                        </mainProcedure>
                        <closeRqmts>
                            <reqCondGroup>
                                <noConds/>
                            </reqCondGroup>
                        </closeRqmts>
                    </procedure>
                </xsl:when>
                <xsl:otherwise>
                    <!-- descript -->
                    <description>
                        <!-- Skip first H1 if used for techName, or adjust logic -->
                        <xsl:apply-templates select="w:body/*[self::w:p or self::w:tbl][not(position()=1 and w:pPr/w:pStyle/@w:val='Heading1' and string-length($vFirstHeading1Text) > 0)]" mode="mainContent"/>
                    </description>
                </xsl:otherwise>
            </xsl:choose>
        </content>
    </xsl:template>
    <!-- === Content Processing Templates (mode="mainContent") === -->
    <xsl:template match="w:p" mode="mainContent">
        <xsl:variable name="style" select="w:pPr/w:pStyle/@w:val"/>
        <xsl:variable name="listNumId" select="w:pPr/w:numPr/w:numId/@w:val"/>
        <xsl:variable name="text" select="normalize-space(string-join(.//w:t/text(), ''))"/>
        <xsl:if test="string-length($text) > 0 or .//w:drawing">
            <!-- Process non-empty paragraphs or those with drawings -->
            <xsl:choose>
                <xsl:when test="$style = 'Heading1' or $style = 'Heading2' or $style = 'Heading3'">
                    <levelledPara>
                        <title>
                            <xsl:apply-templates select="w:r" mode="inline"/>
                        </title>
                        <!-- S1000D does not allow levelledPara directly inside levelledPara.
                             Following paragraphs will be siblings. This might need adjustment based on Word structure. -->
                    </levelledPara>
                </xsl:when>
                <xsl:when test="$listNumId and not($pDmType = 'proced')">
                    <!-- Handle lists for descript -->
                    <!-- Handled by for-each-group at a higher level for lists -->
                </xsl:when>
                <xsl:otherwise>
                    <para>
                        <xsl:apply-templates select="w:r" mode="inline"/>
                    </para>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!-- Grouping for lists in mainContent (e.g. for descript) -->
    <xsl:template match="w:body/*[self::w:p or self::w:tbl]" mode="mainContent">
        <xsl:for-each-group select="." group-adjacent="boolean(self::w:p/w:pPr/w:numPr)">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <xsl:call-template name="process-list">
                        <xsl:with-param name="list-items" select="current-group()"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="current-group()" mode="mainContent_single_item"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>
    <xsl:template match="w:p" mode="mainContent_single_item">
        <!-- Re-evaluate style for single items not in lists -->
        <xsl:variable name="style" select="w:pPr/w:pStyle/@w:val"/>
        <xsl:variable name="text" select="normalize-space(string-join(.//w:t/text(), ''))"/>
        <xsl:if test="string-length($text) > 0 or .//w:drawing">
            <xsl:choose>
                <xsl:when test="$style = 'Heading1' or $style = 'Heading2' or $style = 'Heading3'">
                    <levelledPara>
                        <title>
                            <xsl:apply-templates select="w:r" mode="inline"/>
                        </title>
                    </levelledPara>
                </xsl:when>
                <xsl:otherwise>
                    <para>
                        <xsl:apply-templates select="w:r" mode="inline"/>
                    </para>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!-- === Procedural Step Processing (mode="proceduralStep") === -->
    <xsl:template match="w:p" mode="proceduralStep">
        <xsl:variable name="text" select="normalize-space(string-join(.//w:t/text(), ''))"/>
        <xsl:if test="string-length($text) > 0 or .//w:drawing">
            <proceduralStep>
                <!-- Could add a <title> here if a certain Word style indicates a step title -->
                <para>
                    <xsl:apply-templates select="w:r" mode="inline"/>
                </para>
                <!-- Basic support for nested lists as subSteps.
                     This requires more robust parsing of w:numPr/w:ilvl -->
                <xsl:variable name="currentLevel" select="w:pPr/w:numPr/w:ilvl/@w:val"/>
                <xsl:if test="following-sibling::w:p[1]/w:pPr/w:numPr/w:ilvl/@w:val > $currentLevel">
                    <!-- This indicates start of a sub-step list -->
                    <xsl:variable name="subStepNumId" select="following-sibling::w:p[1]/w:pPr/w:numPr/w:numId/@w:val"/>
                    <sequentialList listType="lt03">
                        <!-- lt03 for sub-steps -->
                        <xsl:apply-templates select="following-sibling::w:p[w:pPr/w:numPr/w:numId/@w:val = $subStepNumId and w:pPr/w:numPr/w:ilvl/@w:val > $currentLevel]" mode="subProceduralStepItem"/>
                    </sequentialList>
                </xsl:if>
            </proceduralStep>
        </xsl:if>
    </xsl:template>
    <xsl:template match="w:p" mode="subProceduralStepItem">
        <xsl:variable name="text" select="normalize-space(string-join(.//w:t/text(), ''))"/>
        <xsl:if test="string-length($text) > 0 or .//w:drawing">
            <listItem>
                <para>
                    <xsl:apply-templates select="w:r" mode="inline"/>
                </para>
            </listItem>
        </xsl:if>
    </xsl:template>
    <!-- === Common Content Elements === -->
    <!-- Generic List Processing (called by mainContent) -->
    <xsl:template name="process-list">
        <xsl:param name="list-items"/>
        <!-- Heuristic: if numFmt is decimal, it's sequential, otherwise random. Could be improved. -->
        <!-- This needs access to the numbering.xml part of DOCX for robust numFmt checking -->
        <!-- For now, assume all w:numPr are sequential unless a specific style implies bullet -->
        <xsl:variable name="isBulletList" select="$list-items[1]/w:pPr/w:pStyle[contains(@w:val, 'ListBullet') or contains(@w:val, 'BulletList')]"/>
        <xsl:choose>
            <xsl:when test="$isBulletList">
                <randomList>
                    <xsl:apply-templates select="$list-items" mode="listItemContent"/>
                </randomList>
            </xsl:when>
            <xsl:otherwise>
                <!-- Default to sequentialList -->
                <sequentialList>
                    <xsl:apply-templates select="$list-items" mode="listItemContent"/>
                </sequentialList>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="w:p" mode="listItemContent">
        <xsl:variable name="text" select="normalize-space(string-join(.//w:t/text(), ''))"/>
        <xsl:if test="string-length($text) > 0 or .//w:drawing">
            <listItem>
                <para>
                    <xsl:apply-templates select="w:r" mode="inline"/>
                </para>
            </listItem>
        </xsl:if>
    </xsl:template>
    <!-- Tables -->
    <xsl:template match="w:tbl" mode="mainContent">
        <table>
            <!-- For simplicity, all rows go into tbody.
                 Detecting thead/tfoot from Word styles is complex. -->
            <tbody>
                <xsl:apply-templates select="w:tr" mode="tableContent"/>
            </tbody>
        </table>
    </xsl:template>
    <xsl:template match="w:tbl" mode="proceduralStep">
        <!-- table inside a step -->
        <table>
            <tbody>
                <xsl:apply-templates select="w:tr" mode="tableContent"/>
            </tbody>
        </table>
    </xsl:template>
    <xsl:template match="w:tr" mode="tableContent">
        <row>
            <xsl:apply-templates select="w:tc" mode="tableContent"/>
        </row>
    </xsl:template>
    <xsl:template match="w:tc" mode="tableContent">
        <entry>
            <!-- A cell can have multiple paragraphs. Wrap each in a para. -->
            <xsl:apply-templates select="w:p" mode="mainContent_single_item"/>
            <!-- Could also have tables within cells, add template if needed -->
        </entry>
    </xsl:template>
    <!-- Inline content (w:r elements within w:p) -->
    <xsl:template match="w:r" mode="inline">
        <xsl:choose>
            <xsl:when test="w:rPr/w:b[not(@w:val='0' or @w:val='false')]">
                <emphasis emphasisType="em02">
                    <xsl:apply-templates select="w:t" mode="inline"/>
                </emphasis>
            </xsl:when>
            <xsl:when test="w:rPr/w:i[not(@w:val='0' or @w:val='false')]">
                <emphasis emphasisType="em01">
                    <xsl:apply-templates select="w:t" mode="inline"/>
                </emphasis>
            </xsl:when>
            <!-- Add other inline styles like underline, strike, etc. if needed -->
            <xsl:otherwise>
                <xsl:apply-templates select="w:t" mode="inline"/>
            </xsl:otherwise>
        </xsl:choose>
        <!-- Placeholder for images/drawings if you need to handle them -->
        <xsl:apply-templates select="w:drawing" mode="inline"/>
    </xsl:template>
    <xsl:template match="w:t" mode="inline">
        <xsl:value-of select="."/>
    </xsl:template>
    <!-- Handle line breaks <w:br/> -->
    <xsl:template match="w:r/w:br" mode="inline">
        <xsl:text>
</xsl:text>
        <!-- Newline character. S1000D might require <break/> or handle it via para. -->
        <!-- For now, just a newline. If S1000D <break/> is needed, emit that element. -->
    </xsl:template>
    <!-- Basic placeholder for drawings (e.g. inline images) -->
    <xsl:template match="w:drawing" mode="inline">
        <!-- Here you would ideally extract image reference (e.g. r:embed from drawing/wp:inline/a:graphic/a:graphicData/pic:pic/pic:blipFill/a:blip/@r:embed)
             and convert it to an S1000D <figure><graphic infoEntityIdent="ICN-..."/></figure>
             This is complex and requires knowledge of your ICN naming conventions.
             For now, a placeholder comment or simple text. -->
        <xsl:comment> Word Drawing/Image encountered - needs manual conversion to S1000D graphic/figure </xsl:comment>
        <emphasis>[IMAGE]</emphasis>
    </xsl:template>
    <!-- Ignore other elements within w:body for now -->
    <xsl:template match="w:body/*[not(self::w:p or self::w:tbl)]" mode=" proceduralStep"/>
    <xsl:template match="w:sectPr" mode=" proceduralStep"/>
    <!-- Ignore section properties -->
    <!-- Default: copy text nodes if not handled elsewhere (should be minimal) -->
    <xsl:template match="text()" mode="inline">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <!-- Ignore comments and processing instructions from WordML -->
    <xsl:template match="processing-instruction()"/>
</xsl:stylesheet>