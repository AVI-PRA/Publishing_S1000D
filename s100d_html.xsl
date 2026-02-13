<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="xs fo xlink">
    <!-- Added xlink exclusion -->
    <!-- Import FO attribute sets and layout -->
    <xsl:import href="style_fo.xsl"/>
    <!-- Output Parameter: 'html' or 'fo' -->
    <xsl:param name="outputFormat" select="'html'"/>
    <!-- Default to HTML -->
    <!-- Parameter for graphics path -->
    <xsl:param name="graphicPathPrefix" select="'figures/'"/>
    <!-- Key for looking up targets by ID (useful for xrefs) -->
    <xsl:key name="target-by-id" match="*[@id]" use="@id"/>
    <!-- OUTPUT Declarations -->
    <xsl:output method="xml" encoding="UTF-8" indent="yes" name="fo"/>
    <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-system="about:legacy-compat" name="html"/>
    <!-- ========================== -->
    <!-- == Root Template & Mode Dispatch == -->
    <!-- ========================== -->
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$outputFormat = 'fo'">
                <xsl:result-document format="fo">
                    <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
                        <!-- Layout Master Set is imported from style_fo.xsl -->
                        <xsl:apply-imports/>
                        <!-- Process imported templates/masters first -->
                        <!-- Determine Page Sequence Master -->
                        <xsl:variable name="rootElement" select="*[1]"/>
                        <xsl:variable name="pageSequenceMaster">
                            <xsl:choose>
                                <xsl:when test="$rootElement/self::techinfomap or $rootElement/descendant::procedure">A4_Portrait_Chapter</xsl:when>
                                <xsl:when test="$rootElement/self::coverpage[@outputclass='CoverPage']">Cover_Page</xsl:when>
                                <xsl:when test="$rootElement/self::coverpage[@outputclass='Annexure']">Annexure_Page</xsl:when>
                                <xsl:when test="$rootElement/self::toc or $rootElement/self::figurelist or $rootElement/self::tablelist">Anciliary_Pages</xsl:when>
                                <xsl:when test="$rootElement/descendant::*[@outputclass='A4 Landscape']">A4_Landscape_Chapter</xsl:when>
                                <xsl:otherwise>A4_Portrait_Chapter</xsl:otherwise>
                                <!-- Default -->
                            </xsl:choose>
                        </xsl:variable>
                        <!-- Determine Initial Page Number -->
                        <xsl:variable name="initialPageNumberValue">
                            <xsl:choose>
                                <xsl:when test="($pageSequenceMaster = 'A4_Portrait_Chapter' or $pageSequenceMaster = 'A4_Landscape_Chapter')
                                                and not($rootElement/descendant::procedure[1]/@initialPageNumber = 'continue')">1</xsl:when>
                                <xsl:when test="$pageSequenceMaster = 'Anciliary_Pages'">1</xsl:when>
                                <xsl:when test="$pageSequenceMaster = 'Cover_Page' or $pageSequenceMaster = 'Annexure_Page'">1</xsl:when>
                                <xsl:otherwise>auto</xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <!-- CORRECTED fo:page-sequence -->
                        <fo:page-sequence master-reference="{$pageSequenceMaster}"
                             initial-page-number="{$initialPageNumberValue}">
                            <!-- Conditionally add the 'format' attribute -->
                            <xsl:if test="$pageSequenceMaster = 'Anciliary_Pages'">
                                <xsl:attribute name="format">i</xsl:attribute>
                            </xsl:if>
                            <!-- Add other page-sequence attributes if needed -->
                            <!-- Static Content (Headers/Footers) are called from imported style_fo.xsl -->
                            <!-- Main Flow -->
                            <fo:flow flow-name="xsl-region-body">
                                <xsl:apply-templates select="node()" mode="fo"/>
                            </fo:flow>
                        </fo:page-sequence>
                    </fo:root>
                </xsl:result-document>
            </xsl:when>
            <xsl:otherwise>
                <!-- HTML Output -->
                <xsl:result-document format="html">
                    <html>
                        <head>
                            <meta charset="UTF-8"/>
                            <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
                            <title>
                                <!-- Attempt to get title from S1000D metadata or first title -->
                                <xsl:value-of select="*/identAndStatusSection/descendant::title[1] | */descendant::title[1]"/>
                            </title>
                            <link rel="stylesheet" href="style.css"/>
                        </head>
                        <body>
                            <xsl:apply-templates select="node()" mode="html"/>
                        </body>
                    </html>
                </xsl:result-document>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Helper template to copy attributes from a set (for FO mode) -->
    <xsl:template name="copy-attribute-set">
        <xsl:param name="setName"/>
        <!-- Corrected path to style_fo.xsl -->
        <xsl:variable name="styleDoc" select="document('style_fo.xsl', /)"/>
        <xsl:variable name="attributeSetNode" select="$styleDoc//xsl:attribute-set[@name=$setName]"/>
        <xsl:if test="$attributeSetNode">
            <xsl:for-each select="$attributeSetNode/xsl:attribute">
                <xsl:attribute name="{@name}" select="."/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <!-- ========================== -->
    <!-- == HTML Mode Templates == -->
    <!-- ========================== -->
    <!-- Default template for HTML: process children -->
    <xsl:template match="node()|@*" mode="html" priority="-1">
        <xsl:apply-templates select="node()|@*" mode="html"/>
    </xsl:template>
    <xsl:template match="text()" mode="html" priority="-1">
        <xsl:value-of select="."/>
    </xsl:template>
    <!-- Structure -->
    <xsl:template match="dmodule | techinfomap | procedure | topic | concept | task" mode="html">
        <div class="{local-name()}">
            <xsl:if test="@outputclass">
                <xsl:attribute name="class" select="concat(local-name(), ' ', @outputclass)"/>
            </xsl:if>
            <xsl:apply-templates mode="html"/>
        </div>
    </xsl:template>
    <!-- Added Template for <description> -->
    <xsl:template match="description" mode="html">
        <div class="description">
            <xsl:apply-templates mode="html"/>
        </div>
    </xsl:template>
    <!-- Added Template for <levelledPara> -->
    <xsl:template match="levelledPara" mode="html">
        <div class="levelledPara">
            <!-- Add the id attribute for linking -->
            <xsl:if test="@id">
                <xsl:attribute name="id" select="@id"/>
            </xsl:if>
            <xsl:apply-templates mode="html"/>
        </div>
    </xsl:template>
    <xsl:template match="content | reasonForUpdate | procedureBody | topicBody | conceptBody | taskBody | abstract" mode="html">
        <div class="{local-name()}">
            <xsl:apply-templates mode="html"/>
        </div>
    </xsl:template>
    <!-- Ignore metadata sections in main flow for HTML -->
    <xsl:template match="identAndStatusSection | dmStatus | dmIdent | dmAddress | issueInfo | metaDataSection" mode="html" priority="5"/>
    <!-- Paragraphs -->
    <xsl:template match="para | p" mode="html">
        <!-- Basic paragraph mapping -->
        <p>
            <!-- Class will be added by context if needed -->
            <xsl:if test="@outputclass">
                <xsl:attribute name="class" select="@outputclass"/>
            </xsl:if>
            <!-- Handle context like first para in list item -->
            <xsl:if test="parent::listItem[1] and not(preceding-sibling::*)">
                <xsl:attribute name="style">display: inline;</xsl:attribute>
                <!-- Simple inline style for demo -->
            </xsl:if>
            <xsl:apply-templates mode="html"/>
        </p>
    </xsl:template>
    <xsl:template match="abstract/para | abstract/p" mode="html">
        <p class="abstract-para Standard_space">
            <!-- CSS needs to style .abstract-para -->
            <xsl:apply-templates mode="html"/>
        </p>
    </xsl:template>
    <!-- Added Template for <notePara> -->
    <xsl:template match="notePara" mode="html">
        <p class="note-para">
            <!-- Assign a class if specific styling is needed -->
            <xsl:apply-templates mode="html"/>
        </p>
    </xsl:template>
    <!-- Titles -->
    <!-- Refined Title Template -->
    <xsl:template match="title" mode="html">
        <!-- Calculate level based on ancestors -->
        <xsl:variable name="level" select="count(ancestor::*[self::procedure or self::levelledPara or self::topic or self::concept or self::task]) + 1"/>
        <xsl:variable name="headingLevel" select="if ($level > 6) then 6 else $level"/>
        <xsl:element name="h{$headingLevel}">
            <xsl:attribute name="class">
                <xsl:text>title </xsl:text>
                <!-- Add specific title classes based on parent/style -->
                <xsl:choose>
                    <xsl:when test="parent::dmodule | parent::techinfomap">Title_document</xsl:when>
                    <xsl:when test="parent::figure">Title_formalBlock figure-title</xsl:when>
                    <xsl:when test="parent::table | parent::informalTable">Title_formalBlock table-title</xsl:when>
                    <xsl:when test="parent::procedure">Title_1</xsl:when>
                    <xsl:when test="parent::procedure/parent::procedure">Title_2</xsl:when>
                    <xsl:when test="parent::procedure/parent::procedure/parent::procedure">Title_3</xsl:when>
                    <!-- Added rule for levelledPara -->
                    <xsl:when test="parent::levelledPara">
                        <xsl:text>Title_</xsl:text>
                        <!-- Use level for class name -->
                        <xsl:value-of select="$level"/>
                    </xsl:when>
                    <xsl:otherwise>Title_default</xsl:otherwise>
                    <!-- Provide a default class -->
                </xsl:choose>
                <!-- Add common title classes if needed -->
                <xsl:text> Title_font Title_space Title_keeps</xsl:text>
                <!-- Adjust classes as needed -->
                <xsl:if test="../@outputclass">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="../@outputclass"/>
                </xsl:if>
            </xsl:attribute>
            <!-- Process title content (nodes within title) -->
            <xsl:apply-templates mode="html"/>
            <!-- If title element itself has text content directly -->
            <xsl:if test="not(node()) and normalize-space(.)">
                <xsl:value-of select="."/>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <!-- Lists -->
    <xsl:template match="sequentialList | steps | procsteps | procstep" mode="html">
        <ol>
            <xsl:apply-templates mode="html"/>
        </ol>
    </xsl:template>
    <xsl:template match="randomList | itemizedList" mode="html">
        <ul>
            <xsl:apply-templates mode="html"/>
        </ul>
    </xsl:template>
    <xsl:template match="listItem | step1 | step2 | step" mode="html">
        <li>
            <xsl:if test="@outputclass">
                <xsl:attribute name="class" select="@outputclass"/>
            </xsl:if>
            <xsl:apply-templates mode="html"/>
        </li>
    </xsl:template>
    <!-- Tables -->
    <xsl:template match="table" mode="html">
        <div class="table-container Table_space">
            <xsl:apply-templates select="title" mode="html"/>
            <xsl:apply-templates select="tgroup" mode="html"/>
        </div>
    </xsl:template>
    <xsl:template match="informalTable" mode="html">
        <div class="table-container Table_space">
            <xsl:apply-templates select="tgroup" mode="html"/>
        </div>
    </xsl:template>
    <xsl:template match="tgroup" mode="html">
        <table>
            <xsl:apply-templates select="colspec" mode="html"/>
            <xsl:apply-templates select="thead" mode="html"/>
            <xsl:apply-templates select="tbody" mode="html"/>
        </table>
    </xsl:template>
    <xsl:template match="colspec" mode="html">
        <col/>
        <!-- Basic mapping, width/span could be added from @colwidth -->
        <xsl:if test="@colwidth">
            <xsl:attribute name="style">
                <xsl:text>width: </xsl:text>
                <!-- Basic width handling, assumes units or % -->
                <xsl:choose>
                    <xsl:when test="contains(@colwidth, '*')">
                        <xsl:value-of select="concat(number(substring-before(@colwidth, '*')) * 10, '%')"/>
                        <!-- Crude % mapping -->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@colwidth"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>;</xsl:text>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template match="thead" mode="html">
        <thead>
            <xsl:apply-templates mode="html"/>
        </thead>
    </xsl:template>
    <xsl:template match="tbody" mode="html">
        <tbody>
            <xsl:apply-templates mode="html"/>
        </tbody>
    </xsl:template>
    <xsl:template match="row" mode="html">
        <tr>
            <xsl:apply-templates mode="html"/>
        </tr>
    </xsl:template>
    <xsl:template match="entry" mode="html">
        <xsl:variable name="cellElement" select="if (ancestor::thead) then 'th' else 'td'"/>
        <xsl:element name="{$cellElement}">
            <!-- Add spanning -->
            <xsl:if test="@morerows">
                <xsl:attribute name="rowspan" select="@morerows + 1"/>
            </xsl:if>
            <!-- Simple colspanning based on S1000D name/namest -->
            <xsl:if test="@namest and @nameend">
                <xsl:variable name="startCol" select="count(ancestor::tgroup/colspec[@colname = current()/@namest]/preceding-sibling::colspec) + 1"/>
                <xsl:variable name="endCol" select="count(ancestor::tgroup/colspec[@colname = current()/@nameend]/preceding-sibling::colspec) + 1"/>
                <xsl:if test="$endCol > $startCol">
                    <xsl:attribute name="colspan" select="$endCol - $startCol + 1"/>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="html"/>
        </xsl:element>
    </xsl:template>
    <!-- Figures and Graphics -->
    <xsl:template match="figure" mode="html">
        <div class="figure Standard_space">
            <xsl:if test="@id">
                <xsl:attribute name="id" select="@id"/>
            </xsl:if>
            <xsl:apply-templates select="title" mode="html"/>
            <xsl:apply-templates select="graphic | symbol" mode="html"/>
        </div>
    </xsl:template>
    <!-- Refined graphic/symbol template -->
    <xsl:template match="graphic | symbol" mode="html">
        <img class="{local-name()}" >
            <!-- Corrected src logic -->
            <xsl:attribute name="src">
                <xsl:value-of select="$graphicPathPrefix"/>
                <xsl:variable name="graphicIdentNode" select="@infoEntityIdent | @href | @boardno"/>
                <xsl:variable name="graphicIdent" select="$graphicIdentNode[1]/string()"/>
                <!-- Get string value of the first found attribute -->
                <xsl:value-of select="$graphicIdent"/>
                <xsl:if test="$graphicIdent and not(contains($graphicIdent, '.'))">.png</xsl:if>
            </xsl:attribute>
            <!-- Corrected alt logic -->
            <xsl:attribute name="alt">
                <xsl:choose>
                    <xsl:when test="../title">
                        <xsl:value-of select="normalize-space(../title)"/>
                    </xsl:when>
                    <xsl:when test="@infoEntityIdent">
                        <xsl:value-of select="@infoEntityIdent"/>
                    </xsl:when>
                    <xsl:when test="@href">
                        <xsl:value-of select="@href"/>
                    </xsl:when>
                    <xsl:when test="@boardno">
                        <xsl:value-of select="@boardno"/>
                    </xsl:when>
                    <xsl:otherwise>Graphic</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!-- Add width/height if present -->
            <xsl:if test="@width">
                <xsl:attribute name="width" select="@width"/>
            </xsl:if>
            <xsl:if test="@height">
                <xsl:attribute name="height" select="@height"/>
            </xsl:if>
        </img>
    </xsl:template>
    <!-- Notes, Warnings, Cautions -->
    <xsl:template match="note | warning | caution | danger" mode="html">
        <div class="{local-name()} box Standard_space">
            <xsl:if test="@id">
                <xsl:attribute name="id" select="@id"/>
            </xsl:if>
            <!-- Prefix "NOTE:" etc. is handled by CSS ::before based on style.css -->
            <xsl:apply-templates mode="html"/>
        </div>
    </xsl:template>
    <!-- Inline Elements -->
    <xsl:template match="bold | b" mode="html">
        <b>
            <xsl:apply-templates mode="html"/>
        </b>
    </xsl:template>
    <xsl:template match="italic | i" mode="html">
        <i>
            <xsl:apply-templates mode="html"/>
        </i>
    </xsl:template>
    <xsl:template match="subscript" mode="html">
        <sub>
            <xsl:apply-templates mode="html"/>
        </sub>
    </xsl:template>
    <xsl:template match="superscript | sup" mode="html">
        <sup>
            <xsl:apply-templates mode="html"/>
        </sup>
    </xsl:template>
    <!-- Refined emphasis template -->
    <xsl:template match="emphasis" mode="html">
        <em class="{@emphasisType}">
            <!-- Use emphasisType as a class -->
            <xsl:apply-templates mode="html"/>
        </em>
    </xsl:template>
    <xsl:template match="verbatim | tt | code | lines | pre" mode="html">
        <code class="preformatted_font">
            <xsl:apply-templates mode="html"/>
        </code>
    </xsl:template>
    <!-- Cross References -->
    <xsl:template match="xref | internalRef | figRef | tblRef | stepRef" mode="html">
        <a class="Link xref">
            <xsl:attribute name="href">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="@internalRefId | @targetRefId | @rid"/>
            </xsl:attribute>
            <!-- Generate Link Text - Simple version: use content or target ID -->
            <xsl:choose>
                <xsl:when test="normalize-space(.)">
                    <xsl:apply-templates mode="html"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Attempt to get target title (requires key) -->
                    <xsl:variable name="targetId" select="@internalRefId | @targetRefId | @rid"/>
                    <xsl:variable name="targetNode" select="key('target-by-id', $targetId)"/>
                    <xsl:choose>
                        <xsl:when test="$targetNode/title">
                            <xsl:apply-templates select="$targetNode/title/node()" mode="html"/>
                            <!-- Handle case where title has text directly -->
                            <xsl:if test="not($targetNode/title/node()) and normalize-space($targetNode/title)">
                                <xsl:value-of select="$targetNode/title"/>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="$targetNode">
                            <xsl:text>[Ref: </xsl:text>
                            <xsl:value-of select="$targetId"/>
                            <xsl:text>]</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>[Missing Ref: </xsl:text>
                            <xsl:value-of select="$targetId"/>
                            <xsl:text>]</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- More complex: "Figure X", "Table Y", "Step Z" requires numbering context -->
                </xsl:otherwise>
            </xsl:choose>
        </a>
    </xsl:template>
    <!-- Corrected externalRef Template -->
    <xsl:template match="externalRef" mode="html">
        <a class="Link external-link" href="{@xlink:href}" target="_blank" rel="noopener noreferrer">
            <xsl:apply-templates mode="html"/>
        </a>
    </xsl:template>
    <!-- ========================== -->
    <!-- == FO Mode Templates ===== -->
    <!-- ========================== -->
    <!-- Default template for FO: process children -->
    <xsl:template match="node()|@*" mode="fo" priority="-1">
        <xsl:apply-templates select="node()|@*" mode="fo"/>
    </xsl:template>
    <xsl:template match="text()" mode="fo" priority="-1">
        <xsl:value-of select="."/>
    </xsl:template>
    <!-- Structure -->
    <xsl:template match="dmodule | content | reasonForUpdate | procedureBody | topicBody | conceptBody | taskBody | abstract" mode="fo">
        <!-- These often don't map directly to a single block, just process children -->
        <xsl:apply-templates mode="fo"/>
    </xsl:template>
    <!-- Added FO Template for <description> -->
    <xsl:template match="description" mode="fo">
        <!-- Typically doesn't need its own block, just process content -->
        <xsl:apply-templates mode="fo"/>
    </xsl:template>
    <!-- Added FO Template for <levelledPara> -->
    <xsl:template match="levelledPara" mode="fo">
        <!-- Create a block for ID, but process children directly -->
        <fo:block>
            <xsl:if test="@id">
                <xsl:attribute name="id" select="@id"/>
            </xsl:if>
            <xsl:apply-templates mode="fo"/>
        </fo:block>
    </xsl:template>
    <!-- Add ID attribute for linking targets (Generic fallback) -->
    <xsl:template match="*[@id]" mode="fo" priority="-2">
        <!-- Fallback for elements with ID not specifically handled -->
        <fo:block id="{@id}">
            <xsl:apply-templates mode="fo"/>
        </fo:block>
    </xsl:template>
    <!-- Ignore metadata sections -->
    <xsl:template match="identAndStatusSection | dmStatus | dmIdent | dmAddress | issueInfo | metaDataSection" mode="fo" priority="5"/>
    <!-- Paragraphs -->
    <xsl:template match="para | p" mode="fo" name="fo-para">
        <fo:block xsl:use-attribute-sets="Standard_space">
            <xsl:attribute name="font-family">Arial</xsl:attribute>
            <xsl:attribute name="font-size">12pt</xsl:attribute>
            <xsl:attribute name="text-align">justify</xsl:attribute>
            <xsl:attribute name="line-height">1.65em</xsl:attribute>
            <xsl:attribute name="space-after.optimum">6pt</xsl:attribute>
            <!-- Add id if present -->
            <xsl:if test="@id">
                <xsl:attribute name="id" select="@id"/>
            </xsl:if>
            <!-- Contexts -->
            <xsl:if test="parent::listItem[1] and not(preceding-sibling::*)">
                <xsl:attribute name="space-before.optimum">0pt</xsl:attribute>
                <xsl:attribute name="space-after.optimum">0pt</xsl:attribute>
                <fo:inline>
                    <xsl:apply-templates mode="fo"/>
                </fo:inline>
                <!-- Wrap content in fo:inline -->
            </xsl:if>
            <xsl:if test="not(parent::listItem[1] and not(preceding-sibling::*))">
                <xsl:apply-templates mode="fo"/>
            </xsl:if>
        </fo:block>
    </xsl:template>
    <xsl:template match="abstract/para | abstract/p" mode="fo">
        <fo:block xsl:use-attribute-sets="Standard_space">
            <xsl:attribute name="font-family">Arial</xsl:attribute>
            <xsl:attribute name="font-size">16pt</xsl:attribute>
            <xsl:attribute name="font-weight">bold</xsl:attribute>
            <xsl:attribute name="text-align">center</xsl:attribute>
            <xsl:if test="@id">
                <xsl:attribute name="id" select="@id"/>
            </xsl:if>
            <xsl:apply-templates mode="fo"/>
        </fo:block>
    </xsl:template>
    <!-- Added FO Template for <notePara> -->
    <xsl:template match="notePara" mode="fo">
        <fo:block>
            <!-- Inherits styling from parent note block usually -->
            <xsl:apply-templates mode="fo"/>
        </fo:block>
    </xsl:template>
    <!-- Titles -->
    <!-- Refined Title Template for FO -->
    <xsl:template match="title" mode="fo" name="fo-title">
        <fo:block>
            <!-- Apply attribute sets conditionally by copying attributes -->
            <xsl:choose>
                <xsl:when test="parent::dmodule | parent::techinfomap">
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_font'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_alignment'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_keeps'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_space'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_document'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="parent::figure">
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_font'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_alignment'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_keeps'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_space'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_formalBlock'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="parent::table | parent::informalTable">
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_font'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_alignment'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_keeps'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_space'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_formalBlock'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="parent::procedure">
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_font'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_alignment'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_keeps'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_space'"/>
                    </xsl:call-template>
                    <xsl:choose>
                        <xsl:when test="count(ancestor::procedure)=0">
                            <xsl:call-template name="copy-attribute-set">
                                <xsl:with-param name="setName" select="'Title_1'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="count(ancestor::procedure)=1">
                            <xsl:call-template name="copy-attribute-set">
                                <xsl:with-param name="setName" select="'Title_2'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="count(ancestor::procedure)=2">
                            <xsl:call-template name="copy-attribute-set">
                                <xsl:with-param name="setName" select="'Title_3'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="copy-attribute-set">
                                <xsl:with-param name="setName" select="'Title_4'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <!-- Added rule for levelledPara -->
                <xsl:when test="parent::levelledPara">
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_font'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_alignment'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_keeps'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_space'"/>
                    </xsl:call-template>
                    <xsl:variable name="level" select="count(ancestor::levelledPara) + 1"/>
                    <xsl:choose>
                        <!-- Apply appropriate title size -->
                        <xsl:when test="$level=1">
                            <xsl:call-template name="copy-attribute-set">
                                <xsl:with-param name="setName" select="'Title_1'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$level=2">
                            <xsl:call-template name="copy-attribute-set">
                                <xsl:with-param name="setName" select="'Title_2'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$level=3">
                            <xsl:call-template name="copy-attribute-set">
                                <xsl:with-param name="setName" select="'Title_3'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$level=4">
                            <xsl:call-template name="copy-attribute-set">
                                <xsl:with-param name="setName" select="'Title_4'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="copy-attribute-set">
                                <xsl:with-param name="setName" select="'Title_5'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_font'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_alignment'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_keeps'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'Title_space'"/>
                    </xsl:call-template>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'bold'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <!-- Apply specific overrides AFTER copying base sets -->
            <xsl:if test="parent::figure or parent::table or parent::procedure">
                <xsl:attribute name="color">#000000</xsl:attribute>
                <!-- Override Title_color -->
            </xsl:if>
            <xsl:if test="parent::figure or parent::table">
                <xsl:attribute name="text-align">center</xsl:attribute>
                <xsl:attribute name="font-family">Arial</xsl:attribute>
                <xsl:attribute name="font-size">12pt</xsl:attribute>
                <xsl:if test="parent::figure">
                    <xsl:attribute name="font-weight">bold</xsl:attribute>
                </xsl:if>
                <xsl:if test="parent::table">
                    <xsl:attribute name="font-weight">normal</xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:if test="parent::procedure">
                <xsl:attribute name="font-family">Times New Roman</xsl:attribute>
                <xsl:attribute name="font-weight">bold</xsl:attribute>
                <xsl:if test="count(ancestor::procedure) = 0">
                    <xsl:attribute name="font-size">18pt</xsl:attribute>
                    <xsl:attribute name="text-align">center</xsl:attribute>
                    <xsl:attribute name="text-transform">uppercase</xsl:attribute>
                    <xsl:call-template name="copy-attribute-set">
                        <xsl:with-param name="setName" select="'box'"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:if test="count(ancestor::procedure) = 1">
                    <xsl:attribute name="font-size">18pt</xsl:attribute>
                    <xsl:attribute name="text-align">left</xsl:attribute>
                    <xsl:attribute name="start-indent">35pt</xsl:attribute>
                    <xsl:attribute name="text-indent">-35pt</xsl:attribute>
                </xsl:if>
                <xsl:if test="count(ancestor::procedure) = 2">
                    <xsl:attribute name="font-size">16pt</xsl:attribute>
                    <xsl:attribute name="text-align">left</xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:if test="parent::levelledPara">
                <!-- Style for levelledPara titles -->
                <xsl:attribute name="text-align">left</xsl:attribute>
                <xsl:attribute name="font-family">Arial</xsl:attribute>
                <!-- Or specific font -->
                <xsl:attribute name="font-weight">normal</xsl:attribute>
                <!-- Default weight -->
                <xsl:if test="emphasis[@emphasisType='em01'] or emphasis[@emphasisType='em03']">
                    <!-- Overridden by emphasis template -->
                </xsl:if>
                <!-- Handle specific levelledPara title numbering from text -->
                <xsl:variable name="titleText" select="normalize-space(.)"/>
                <xsl:if test="matches($titleText, '^\d+(\.\d+)*\s+')">
                    <fo:inline font-weight="bold">
                        <!-- Number part bold? -->
                        <xsl:value-of select="substring-before($titleText, ' ')"/>
                        <xsl:text> </xsl:text>
                    </fo:inline>
                    <xsl:value-of select="substring-after($titleText, ' ')"/>
                </xsl:if>
                <xsl:if test="not(matches($titleText, '^\d+(\.\d+)*\s+'))">
                    <xsl:apply-templates mode="fo"/>
                    <!-- Apply templates if no number prefix -->
                </xsl:if>
            </xsl:if>
            <xsl:if test="not(parent::levelledPara)">
                <!-- Original numbering/prefix logic for non-levelledPara -->
                <!-- Add id -->
                <xsl:if test="@id">
                    <xsl:attribute name="id" select="@id"/>
                </xsl:if>
                <!-- Add Numbering/Prefix -->
                <xsl:choose>
                    <xsl:when test="parent::figure">
                        <fo:inline>Figure
                            <xsl:number level="any" count="figure" format="1-1" from="procedure | dmodule | description"/>:
                        </fo:inline>
                    </xsl:when>
                    <xsl:when test="parent::table">
                        <fo:inline>Table
                            <xsl:number level="any" count="table | informalTable" format="1-1" from="procedure | dmodule | description"/>:
                        </fo:inline>
                    </xsl:when>
                    <xsl:when test="parent::procedure">
                        <xsl:variable name="procLevel" select="count(ancestor-or-self::procedure)"/>
                        <xsl:if test="$procLevel = 1">
                            <fo:block>CHAPTER
                                <xsl:number level="any" count="procedure[ancestor::procedure] | procedure[not(ancestor::procedure)]" format="1"/>
                            </fo:block>
                        </xsl:if>
                        <xsl:if test="$procLevel > 1">
                            <fo:inline>
                                <xsl:number level="multiple" count="procedure" format="1.1"/>.
                            </fo:inline>
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
                <xsl:apply-templates mode="fo"/>
            </xsl:if>
        </fo:block>
    </xsl:template>
    <!-- Lists -->
    <xsl:template match="sequentialList | steps | procsteps | procstep" mode="fo" name="fo-list-ol">
        <fo:list-block xsl:use-attribute-sets="Standard_space" provisional-distance-between-starts="2.5em" provisional-label-separation="0.5em">
            <xsl:if test="@id">
                <xsl:attribute name="id" select="@id"/>
            </xsl:if>
            <xsl:apply-templates select="listItem | step1 | step2 | step" mode="fo">
                <xsl:with-param name="list-level" select="count(ancestor::*[self::sequentialList|self::steps|self::procsteps|self::procstep]) + 1"/>
                <xsl:with-param name="list-type" select="'ordered'"/>
            </xsl:apply-templates>
        </fo:list-block>
    </xsl:template>
    <xsl:template match="randomList | itemizedList" mode="fo" name="fo-list-ul">
        <fo:list-block xsl:use-attribute-sets="Standard_space" provisional-distance-between-starts="1.25em" provisional-label-separation="0.5em">
            <xsl:if test="@id">
                <xsl:attribute name="id" select="@id"/>
            </xsl:if>
            <xsl:apply-templates select="listItem" mode="fo">
                <xsl:with-param name="list-level" select="count(ancestor::*[self::randomList|self::itemizedList]) + 1"/>
                <xsl:with-param name="list-type" select="'unordered'"/>
            </xsl:apply-templates>
        </fo:list-block>
    </xsl:template>
    <xsl:template match="listItem | step1 | step2 | step" mode="fo" name="fo-list-li">
        <xsl:param name="list-level" select="1"/>
        <xsl:param name="list-type" select="'ordered'"/>
        <!-- 'ordered' or 'unordered' -->
        <fo:list-item xsl:use-attribute-sets="List_item_space">
            <xsl:if test="@id">
                <xsl:attribute name="id" select="@id"/>
            </xsl:if>
            <fo:list-item-label end-indent="label-end()">
                <fo:block font-family="Arial" font-size="12pt">
                    <xsl:choose>
                        <xsl:when test="$list-type = 'ordered'">
                            <xsl:choose>
                                <xsl:when test="$list-level = 1">(
                                    <xsl:number format="a"/>)
                                </xsl:when>
                                <xsl:when test="$list-level = 2">(
                                    <xsl:number format="i"/>)
                                </xsl:when>
                                <xsl:when test="$list-level = 3">
                                    <xsl:number format="i"/>.
                                </xsl:when>
                                <xsl:when test="$list-level = 4">
                                    <xsl:number format="1"/>)
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:number format="1"/>.
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="$list-level = 1">•</xsl:when>
                                <xsl:when test="$list-level = 2">–</xsl:when>
                                <xsl:when test="$list-level = 3">♦</xsl:when>
                                <xsl:otherwise>•</xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="body-start()">
                <fo:block font-family="Arial" font-size="12pt" line-height="1.65em">
                    <xsl:apply-templates mode="fo"/>
                </fo:block>
            </fo:list-item-body>
        </fo:list-item>
    </xsl:template>
    <!-- Tables -->
    <xsl:template match="table | informalTable" mode="fo" name="fo-table">
        <fo:block xsl:use-attribute-sets="Table_space">
            <xsl:if test="@id">
                <xsl:attribute name="id" select="@id"/>
            </xsl:if>
            <fo:table-and-caption>
                <xsl:if test="self::table">
                    <fo:table-caption>
                        <xsl:apply-templates select="title" mode="fo"/>
                    </fo:table-caption>
                </xsl:if>
                <fo:table>
                    <xsl:attribute name="table-layout">auto</xsl:attribute>
                    <xsl:attribute name="border-collapse">collapse</xsl:attribute>
                    <xsl:attribute name="border">0.5pt solid #ccc</xsl:attribute>
                    <!-- Default border -->
                    <xsl:apply-templates select="tgroup/colspec" mode="fo"/>
                    <xsl:apply-templates select="tgroup/thead" mode="fo"/>
                    <xsl:apply-templates select="tgroup/tbody" mode="fo"/>
                </fo:table>
            </fo:table-and-caption>
        </fo:block>
    </xsl:template>
    <xsl:template match="colspec" mode="fo">
        <fo:table-column>
            <xsl:if test="@colwidth and contains(@colwidth, '*')">
                <xsl:attribute name="column-width">proportional-column-width(
                    <xsl:value-of select="substring-before(@colwidth, '*')"/>)
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@colwidth and not(contains(@colwidth, '*'))">
                <xsl:attribute name="column-width">
                    <xsl:value-of select="@colwidth"/>
                </xsl:attribute>
            </xsl:if>
            <!-- Add text align from @align -->
            <xsl:if test="@align">
                <xsl:attribute name="text-align">
                    <xsl:value-of select="@align"/>
                </xsl:attribute>
            </xsl:if>
        </fo:table-column>
    </xsl:template>
    <xsl:template match="thead" mode="fo">
        <fo:table-header>
            <xsl:apply-templates mode="fo"/>
        </fo:table-header>
    </xsl:template>
    <xsl:template match="tbody" mode="fo">
        <fo:table-body>
            <xsl:apply-templates mode="fo"/>
        </fo:table-body>
    </xsl:template>
    <xsl:template match="row" mode="fo">
        <fo:table-row>
            <xsl:apply-templates mode="fo"/>
        </fo:table-row>
    </xsl:template>
    <xsl:template match="entry" mode="fo">
        <fo:table-cell padding="3pt" border="0.5pt solid #ccc">
            <!-- Default padding/border -->
            <xsl:if test="@morerows">
                <xsl:attribute name="number-rows-spanned">
                    <xsl:value-of select="@morerows + 1"/>
                </xsl:attribute>
            </xsl:if>
            <!-- Add colspanning if needed -->
            <xsl:if test="@namest and @nameend">
                <xsl:variable name="startCol" select="count(ancestor::tgroup/colspec[@colname = current()/@namest]/preceding-sibling::colspec) + 1"/>
                <xsl:variable name="endCol" select="count(ancestor::tgroup/colspec[@colname = current()/@nameend]/preceding-sibling::colspec) + 1"/>
                <xsl:if test="$endCol > $startCol">
                    <xsl:attribute name="number-columns-spanned" select="$endCol - $startCol + 1"/>
                </xsl:if>
            </xsl:if>
            <fo:block font-family="Arial" font-size="12pt" line-height="1.65em">
                <xsl:if test="ancestor::thead">
                    <xsl:attribute name="font-weight">bold</xsl:attribute>
                    <xsl:attribute name="text-align">center</xsl:attribute>
                </xsl:if>
                <!-- Apply alignment from parent colspec if cell doesn't override -->
                <xsl:if test="not(@align) and ancestor::tgroup/colspec[count(current()/preceding-sibling::entry)+1]/@align">
                    <xsl:attribute name="text-align" select="ancestor::tgroup/colspec[count(current()/preceding-sibling::entry)+1]/@align"/>
                </xsl:if>
                <xsl:apply-templates mode="fo"/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>
    <!-- Figures and Graphics -->
    <xsl:template match="figure" mode="fo" name="fo-figure">
        <fo:block xsl:use-attribute-sets="Standard_space" text-align="center" keep-together.within-column="always">
            <xsl:if test="@id">
                <xsl:attribute name="id" select="@id"/>
            </xsl:if>
            <xsl:apply-templates select="title" mode="fo"/>
            <xsl:apply-templates select="graphic | symbol" mode="fo"/>
        </fo:block>
    </xsl:template>
    <!-- Refined graphic/symbol FO template -->
    <xsl:template match="graphic | symbol" mode="fo">
        <fo:block text-align="center" space-before="6pt" space-after="6pt">
            <fo:external-graphic content-height="auto" content-width="scale-to-fit" width="80%" scaling="uniform">
                <!-- Adjust width/scaling -->
                <xsl:attribute name="src">
                    <xsl:text>url('</xsl:text>
                    <xsl:value-of select="replace($graphicPathPrefix, '\\', '/')"/>
                    <!-- Ensure forward slashes -->
                    <xsl:variable name="graphicIdentNode" select="@infoEntityIdent | @href | @boardno"/>
                    <xsl:variable name="graphicIdent" select="$graphicIdentNode[1]/string()"/>
                    <xsl:value-of select="replace($graphicIdent, '\\', '/')"/>
                    <!-- Ensure forward slashes -->
                    <xsl:if test="$graphicIdent and not(contains($graphicIdent, '.'))">.png</xsl:if>
                    <xsl:text>')</xsl:text>
                </xsl:attribute>
                <!-- Add width/height if present -->
                <xsl:if test="@width">
                    <xsl:attribute name="width" select="@width"/>
                </xsl:if>
                <xsl:if test="@height">
                    <xsl:attribute name="content-height" select="@height"/>
                </xsl:if>
                <!-- Use content-height for FO -->
                <xsl:if test="@height and not(@width)">
                    <xsl:attribute name="content-width">auto</xsl:attribute>
                </xsl:if>
            </fo:external-graphic>
        </fo:block>
    </xsl:template>
    <!-- Notes, Warnings, Cautions -->
    <xsl:template match="note | warning | caution | danger" mode="fo" name="fo-note">
        <fo:block xsl:use-attribute-sets="Standard_space box">
            <xsl:if test="@id">
                <xsl:attribute name="id" select="@id"/>
            </xsl:if>
            <fo:block font-family="Arial" font-size="12pt" font-weight="bold">
                <xsl:value-of select="upper-case(local-name())"/>
                <!-- NOTE, WARNING, etc. -->
            </fo:block>
            <fo:block font-family="Arial" font-size="12pt" line-height="1.65em">
                <xsl:apply-templates mode="fo"/>
            </fo:block>
        </fo:block>
    </xsl:template>
    <!-- Inline Elements -->
    <xsl:template match="bold | b" mode="fo">
        <fo:inline font-weight="bold">
            <xsl:apply-templates mode="fo"/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="italic | i" mode="fo">
        <fo:inline font-style="italic">
            <xsl:apply-templates mode="fo"/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="subscript" mode="fo">
        <fo:inline vertical-align="sub" font-size="smaller">
            <xsl:apply-templates mode="fo"/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="superscript | sup" mode="fo">
        <fo:inline vertical-align="super" font-size="smaller">
            <xsl:apply-templates mode="fo"/>
        </fo:inline>
    </xsl:template>
    <!-- Refined emphasis for FO -->
    <xsl:template match="emphasis" mode="fo">
        <fo:inline>
            <xsl:choose>
                <xsl:when test="@emphasisType = 'em01'">
                    <xsl:attribute name="font-style">italic</xsl:attribute>
                </xsl:when>
                <xsl:when test="@emphasisType = 'em03'">
                    <xsl:attribute name="font-weight">bold</xsl:attribute>
                </xsl:when>
                <!-- Add other emphasis types -->
            </xsl:choose>
            <xsl:apply-templates mode="fo"/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="verbatim | tt | code | lines | pre" mode="fo">
        <fo:inline xsl:use-attribute-sets="preformatted_font">
            <xsl:apply-templates mode="fo"/>
        </fo:inline>
    </xsl:template>
    <!-- Cross References -->
    <xsl:template match="xref | internalRef | figRef | tblRef | stepRef" mode="fo">
        <fo:basic-link xsl:use-attribute-sets="Link">
            <xsl:attribute name="internal-destination">
                <xsl:value-of select="@internalRefId | @targetRefId | @rid"/>
            </xsl:attribute>
            <!-- Generate Link Text -->
            <xsl:choose>
                <xsl:when test="normalize-space(.)">
                    <xsl:apply-templates mode="fo"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Attempt to get target title/number - Requires more logic/keys -->
                    <xsl:variable name="targetId" select="@internalRefId | @targetRefId | @rid"/>
                    <xsl:variable name="targetNode" select="key('target-by-id', $targetId)"/>
                    <xsl:choose>
                        <xsl:when test="self::figRef and $targetNode">Figure
                            <xsl:apply-templates select="$targetNode" mode="get-figure-number"/>
                        </xsl:when>
                        <xsl:when test="self::tblRef and $targetNode">Table
                            <xsl:apply-templates select="$targetNode" mode="get-table-number"/>
                        </xsl:when>
                        <xsl:when test="self::stepRef and $targetNode">Step
                            <xsl:apply-templates select="$targetNode" mode="get-step-number"/>
                        </xsl:when>
                        <xsl:when test="$targetNode/title">
                            <xsl:apply-templates select="$targetNode/title/node()" mode="fo"/>
                            <xsl:if test="not($targetNode/title/node()) and normalize-space($targetNode/title)">
                                <xsl:value-of select="$targetNode/title"/>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>[Ref:
                            <xsl:value-of select="$targetId"/>]
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </fo:basic-link>
    </xsl:template>
    <!-- Corrected externalRef FO template -->
    <xsl:template match="externalRef" mode="fo">
        <fo:basic-link xsl:use-attribute-sets="Link" external-destination="url('{@xlink:href}')">
            <xsl:apply-templates mode="fo"/>
        </fo:basic-link>
    </xsl:template>
    <!-- Helper templates for getting target numbers (placeholders) -->
    <xsl:template match="*" mode="get-figure-number">
        <xsl:number level="any" count="figure" format="1-1" from="procedure | dmodule | description"/>
    </xsl:template>
    <xsl:template match="*" mode="get-table-number">
        <xsl:number level="any" count="table | informalTable" format="1-1" from="procedure | dmodule | description"/>
    </xsl:template>
    <xsl:template match="*" mode="get-step-number">
        <!-- Needs logic to calculate step number based on list type and nesting -->
        <xsl:number level="multiple" count="listItem[ancestor::sequentialList] | step1 | step2 | step" format="a.i.1"/>
    </xsl:template>
    <!-- TOC/Index Generation (Placeholders) -->
    <xsl:template match="toc | figurelist | tablelist | index" mode="fo">
        <fo:block font-weight="bold" font-size="14pt" text-align="center" space-after="12pt" break-before="page">
            <xsl:choose>
                <xsl:when test="self::toc">TABLE OF CONTENTS</xsl:when>
                <xsl:when test="self::figurelist">LIST OF FIGURES</xsl:when>
                <xsl:when test="self::tablelist">LIST OF TABLES</xsl:when>
                <xsl:when test="self::index">INDEX</xsl:when>
            </xsl:choose>
            <fo:block/>
            <fo:block font-style="italic" text-align="left">[TOC/Index Content Generation Placeholder]</fo:block>
        </fo:block>
    </xsl:template>
</xsl:stylesheet>