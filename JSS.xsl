<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:jss="http://www.example.com/jss-custom-functions"

                exclude-result-prefixes="xs jss"
                version="2.0">
    <xsl:output method="html" doctype-system="about:legacy-compat" encoding="UTF-8" indent="yes"/>
    <!-- Parameters -->
    <xsl:param name="numbered-titles" select="true()"/>
    <xsl:param name="show-references-table" select="true()"/>
    <xsl:param name="reference-resolver" select="false()"/>
    <xsl:param name="extra-header-tags" select="false()"/>
    <xsl:param name="bootstrap-css-path" select="'xignal/assets/bootstrap/4.6.2/css/bootstrap.min.css'"/>
    <xsl:param name="custom-css-path" select="'../main.css'"/>
    <!-- Link to your JSS-derived CSS -->
    <xsl:param name="jquery-js-path" select="'xignal/assets/jquery/3.7.1/jquery-slim-min.js'"/>
    <xsl:param name="bootstrap-js-path" select="'xignal/assets/bootstrap/4.6.2/js/bootstrap.min.js'"/>
    <xsl:key name="ids" match="*[@id]" use="@id"/>
    <!-- JSS Custom Function for Alpha List Markers -->
    <xsl:function name="jss:get-jss-alpha-char" as="xs:string">
        <xsl:param name="position" as="xs:integer"/>
        <!-- UPDATE THIS based on JSS 0251 rules! This one skips 'i' and 'o'. -->
        <xsl:variable name="jss_alphabet_level1" 
            select="('a','b','c','d','e','f','g','h','j','k','l','m','n','p','q','r','s','t','u','v','w','x','y','z')"/>
        <xsl:choose>
            <xsl:when test="$position > 0 and $position
                &lt;= count($jss_alphabet_level1)">
                <xsl:sequence select="$jss_alphabet_level1[$position]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="concat('errPos(', xs:string($position), ')')"/>
                <!-- Error/fallback marker -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <!-- Root Template -->
    <xsl:template match="/">
        <html lang="en">
            <head>
                <meta charset="UTF-8"/>
                <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
                <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
                <title>
                    <xsl:apply-templates select="//identAndStatusSection/dmAddress/dmAddressItems/dmTitle"/>
                </title>
                <link rel="stylesheet" href="{$bootstrap-css-path}" />
                <xsl:if test="$custom-css-path != ''">
                    <link rel="stylesheet" href="{$custom-css-path}" />
                </xsl:if>
                <style> /* Basic table style for prelim reqs, can be enhanced by custom CSS */
                    .prelim-req-table { margin-bottom: 1.5rem; }
                    .prelim-req-table th, .prelim-req-table td { vertical-align: top; padding: 0.5rem; }
                </style>
            </head>
            <xsl:choose>
                <xsl:when test="/dmodule">
                    <xsl:apply-templates select="/dmodule/identAndStatusSection" mode="page-setup"/>
                    <xsl:apply-templates select="/dmodule/content"/>
                </xsl:when>
                <xsl:when test="/preliminaryRqmts">
                    <body>
                        <div class="container-fluid">
                            <xsl:apply-templates select="."/>
                        </div>
                        <script src="{$jquery-js-path}"></script>
                        <script src="{$bootstrap-js-path}"></script>
                    </body>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </html>
    </xsl:template>
    <!-- Page Setup Mode for dmodule -->
    <xsl:template match="identAndStatusSection" mode="page-setup">
        <body>
            <xsl:call-template name="generate-title-bar">
                <xsl:with-param name="identSection" select="."/>
            </xsl:call-template>
            <div class="container-fluid idstatusTitle">
                <button type="button" class="btn btn-primary mt-1 mb-3" data-toggle="modal" data-target="#idstatusModal">View Identification and Status</button>
            </div>
            <xsl:call-template name="generate-id-status-modal">
                <xsl:with-param name="identSection" select="."/>
            </xsl:call-template>
            <xsl:if test="$show-references-table and (ancestor::dmodule/refs/dmRef or ancestor::dmodule/refs/externalPubRef)">
                <div class="container-fluid">
                    <h2 id="tblReferences" class="ps-Title_font ps-Title_2 ps-Title_color">References</h2>
                    <xsl:apply-templates select="ancestor::dmodule/refs" mode="table"/>
                </div>
            </xsl:if>
            <xsl:if test="$show-references-table and not(ancestor::dmodule/refs/dmRef or ancestor::dmodule/refs/externalPubRef)">
                <div class="container-fluid">
                    <h2 id="tblReferences" class="ps-Title_font ps-Title_2 ps-Title_color">References</h2>
                    <table class="tblReferences mb-5 table table-borderless prelim-req-table s1000d-table">
                        <caption class="italic spaceAfter-sm s1000d-table-title">Table 1  References</caption>
                        <thead>
                            <tr>
                                <th>Data module/Technical publication</th>
                                <th>Title</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td colspan="2">None</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </xsl:if>
        </body>
    </xsl:template>
    <!-- Main Content Processing -->
    <xsl:template match="content">
        <div class="container-fluid">
            <xsl:apply-templates select="description | procedure | preliminaryRqmts"/>
        </div>
        <xsl:if test="ancestor::dmodule and not(ancestor::dmodule/identAndStatusSection)">
            <script src="{$jquery-js-path}"></script>
            <script src="{$bootstrap-js-path}"></script>
        </xsl:if>
    </xsl:template>
    <!-- Title Bar Generation -->
    <xsl:template name="generate-title-bar">
        <xsl:param name="identSection"/>
        <div class="dmTitleBar bg-light p-3 mb-3">
            <h1 class="text-center ps-Title_font ps-Title_document ps-Title_color">
                <xsl:apply-templates select="$identSection/dmAddress/dmAddressItems/dmTitle"/>
            </h1>
        </div>
    </xsl:template>
    <!-- ID Status Modal (functional, styling is via Bootstrap and general CSS) -->
    <xsl:template name="generate-id-status-modal">
        <xsl:param name="identSection"/>
        <div class="modal fade" id="idstatusModal" tabindex="-1" aria-labelledby="idstatusModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-xl modal-dialog-scrollable">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="idstatusModalLabel">Data Module Identification and Status</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">X</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="container-fluid">
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">DMC:</div>
                                <div class="col-sm-9">
                                    <xsl:apply-templates select="$identSection/dmAddress/dmAddressItems/dmIdent"/>
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">Language:</div>
                                <div class="col-sm-9">
                                    <xsl:apply-templates select="$identSection/dmAddress/dmAddressItems/language"/>
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">Issue No.:</div>
                                <div class="col-sm-9">
                                    <xsl:value-of select="$identSection/dmAddress/dmAddressItems/issueInfo/@issueNumber"/> (
                                    <xsl:value-of select="$identSection/dmAddress/dmAddressItems/issueInfo/@inWork"/>)
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">Issue Date:</div>
                                <div class="col-sm-9">
                                    <xsl:apply-templates select="$identSection/dmAddress/dmAddressItems/issueDate"/>
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">Title:</div>
                                <div class="col-sm-9">
                                    <xsl:apply-templates select="$identSection/dmAddress/dmAddressItems/dmTitle"/>
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">Security:</div>
                                <div class="col-sm-9">
                                    <xsl:call-template name="decodeSecurity">
                                        <xsl:with-param name="code" select="$identSection/dmStatus/security/@securityClassification"/>
                                    </xsl:call-template>
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">RPC:</div>
                                <div class="col-sm-9">
                                    <xsl:apply-templates select="$identSection/dmStatus/responsiblePartnerCompany"/>
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">Originator:</div>
                                <div class="col-sm-9">
                                    <xsl:apply-templates select="$identSection/dmStatus/originator"/>
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">Applicability:</div>
                                <div class="col-sm-9">
                                    <xsl:apply-templates select="$identSection/dmStatus/applic/displayText/simplePara"/>
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">BREX:</div>
                                <div class="col-sm-9">
                                    <xsl:apply-templates select="$identSection/dmStatus/brexDmRef/dmRef"/>
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">QA:</div>
                                <div class="col-sm-9">
                                    <xsl:choose>
                                        <xsl:when test="$identSection/dmStatus/qualityAssurance/unverified">Unverified</xsl:when>
                                        <xsl:when test="$identSection/dmStatus/qualityAssurance/firstVerification">First Verification
                                            <xsl:value-of select="$identSection/dmStatus/qualityAssurance/firstVerification/@verificationType"/>
                                        </xsl:when>
                                        <xsl:otherwise>N/A</xsl:otherwise>
                                    </xsl:choose>
                                </div>
                            </div>
                            <xsl:if test="$identSection/dmStatus/reasonForUpdate">
                                <div class="row pb-2">
                                    <div class="col-sm-3 font-weight-bold">Reason for Update:</div>
                                    <div class="col-sm-9">
                                        <xsl:apply-templates select="$identSection/dmStatus/reasonForUpdate/simplePara"/>
                                    </div>
                                </div>
                            </xsl:if>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="simplePara">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template name="decodeSecurity">
        <xsl:param name="code"/>
        <xsl:choose>
            <xsl:when test="$code = '01'">Unclassified</xsl:when>
            <xsl:when test="$code = '02'">Restricted</xsl:when>
            <xsl:when test="$code = '03'">Confidential</xsl:when>
            <xsl:when test="$code = '04'">Secret</xsl:when>
            <xsl:when test="$code = '05'">Top Secret</xsl:when>
            <xsl:otherwise>Unknown (
                <xsl:value-of select="$code"/>)
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- References Table -->
    <xsl:template match="refs" mode="table">
        <table class="tblReferences mb-5 table table-sm table-striped prelim-req-table s1000d-table">
            <caption class="sr-only">References</caption>
            <thead class="thead-light">
                <tr>
                    <th>Data module/Technical publication</th>
                    <th>Title</th>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates select="dmRef | externalPubRef" mode="refs"/>
            </tbody>
        </table>
    </xsl:template>
    <!-- Main Content Element Templates -->
    <xsl:template match="description | procedure">
        <xsl:apply-templates select="title"/>
        <xsl:apply-templates select="preliminaryRqmts | mainProcedure | closeRqmts"/>
        <xsl:apply-templates select="levelledPara | para | figure | note | sequentialList | randomList | table | symbol"/>
    </xsl:template>
    <xsl:template match="procedure/title">
        <div class="row">
            <div class="col-md-12">
                <h2 id="{generate-id()}" class="s1000d-procedure-title">
                    <xsl:if test="$numbered-titles">
                        <span class="s1000d-procedure-title-prefix">CHAPTER
                            <xsl:number count="procedure" level="single" from="content" format="1"/>
                        </span>
                    </xsl:if>
                    <xsl:apply-templates/>
                </h2>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="description/title">
        <div class="row">
            <div class="col-md-12">
                <h2 id="{generate-id()}" class="mt-4 mb-3 ps-Title_font ps-Title_1 ps-Title_color">
                    <xsl:apply-templates/>
                </h2>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="mainProcedure">
        <div class="main-procedure-section mt-4">
            <xsl:apply-templates select="proceduralStep"/>
        </div>
    </xsl:template>
    <xsl:template match="proceduralStep">
        <div class="procedural-step mb-3 p-3 border rounded" id="{@id}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="closeRqmts">
        <div class="closeout-requirements-section mt-4">
            <h3 id="{@id}" class="mb-3 ps-Title_font ps-Title_3 ps-Title_color">Closeout Requirements</h3>
            <xsl:apply-templates select="reqCondGroup"/>
        </div>
    </xsl:template>
    <xsl:template match="levelledPara">
        <div class="levelled-para-container mb-3" id="{@id}">
            <xsl:if test="title">
                <h4 class="s1000d-levelledPara-title" id="{generate-id(title)}">
                    <xsl:if test="$numbered-titles">
                        <xsl:variable name="procAncestor" select="ancestor::procedure[1]"/>
                        <xsl:variable name="descAncestor" select="ancestor::description[1]"/>
                        <xsl:choose>
                            <xsl:when test="$procAncestor">
                                <span class="s1000d-levelledPara-title-prefix">
                                    <xsl:number count="procedure" level="single" from="content" format="1"/>.
                                    <xsl:number count="levelledPara" level="multiple" from="procedure" format="1"/>
                                </span>
                            </xsl:when>
                            <xsl:when test="$descAncestor">
                                <span class="s1000d-levelledPara-title-prefix">
                                    <xsl:number count="levelledPara" level="multiple" from="description" format="1"/>
                                </span>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:apply-templates select="title" mode="inline"/>
                </h4>
            </xsl:if>
            <div class="levelled-para-content">
                <xsl:apply-templates select="para | figure | note | sequentialList | randomList | table | levelledPara | symbol"/>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="levelledPara/title" mode="inline">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="para">
        <p class="s1000d-para">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="listItem/para[1][parent::ol[contains(@class, 'jss-custom-alpha-list')]]" mode="firstParaInListItemInJssList">
        <span class="s1000d-para">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="listItem/para[1][parent::ol[not(contains(@class, 'jss-custom-alpha-list'))]]">
        <span class="s1000d-para">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="listItem/para[position() > 1]">
        <p class="s1000d-para">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="reqCond/text() | reqCond/internalRef">
        <xsl:apply-imports/>
    </xsl:template>
    <xsl:template match="sequentialList">
        <!-- **** CHANGE sequentialList to your actual S1000D element name **** -->
        <xsl:variable name="listClass">
            <xsl:choose>
                <!-- Primary condition for JSS custom alpha list -->
                <xsl:when test="not(parent::listItem) and 
                                (ancestor::proceduralStep or 
                                 ancestor::mainProcedure or 
                                 ancestor::levelledPara or 
                                 ancestor::note[not(ancestor::safetyRqmts)] or 
                                 ancestor::entry)">
                    s1000d-procedural-ol jss-custom-alpha-list
                </xsl:when>
                <!-- Condition for nested list (e.g., roman numerals) -->
                <xsl:when test="parent::listItem[parent::ol[tokenize(@class, '\s+') = 'jss-custom-alpha-list']]">
                    s1000d-procedural-ol jss-nested-roman-list
                </xsl:when>
                <!-- Fallback for other ordered lists -->
                <xsl:otherwise>s1000d-procedural-ol s1000d-generic-ol</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <ol class="{$listClass} mb-2">
            <xsl:apply-templates select="listItem"/>
        </ol>
    </xsl:template>
    <xsl:template match="randomList">
        <xsl:variable name="listClass">
            <xsl:choose>
                <xsl:when test="ancestor::proceduralStep or ancestor::mainProcedure or ancestor::levelledPara or ancestor::note or ancestor::entry">s1000d-random-ul</xsl:when>
                <xsl:otherwise>s1000d-generic-ul</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <ul class="{$listClass} mb-2">
            <xsl:apply-templates select="listItem"/>
        </ul>
    </xsl:template>
    <xsl:template match="listItem[parent::ol[tokenize(@class, '\s+') = 'jss-custom-alpha-list']]" priority="10">
        <xsl:comment>DEBUG: Matched JSS custom alpha listItem template</xsl:comment>
        <li class="jss-custom-alpha-li">
            <xsl:variable name="raw_position" select="count(preceding-sibling::listItem) + 1"/>
            <span class="jss-list-marker">
                 (
                <xsl:value-of select="jss:get-jss-alpha-char($raw_position)"/>)
            </span>
            <div class="jss-list-item-content">
                <!-- Process first para to be potentially inline, others as blocks -->
                <xsl:apply-templates select="para[1]" mode="listItemFirstPara"/>
                <xsl:apply-templates select="node()[not(self::para[1])]"/>
            </div>
        </li>
    </xsl:template>
    <xsl:template match="listItem[parent::ol[tokenize(@class, '\s+') = 'jss-nested-roman-list']]" priority="9">
        <xsl:comment>DEBUG: Matched JSS nested roman listItem template</xsl:comment>
        <li class="jss-nested-roman-li">
            <div class="jss-list-item-content">
                <xsl:apply-templates select="para[1]" mode="listItemFirstPara"/>
                <xsl:apply-templates select="node()[not(self::para[1])]"/>
            </div>
        </li>
    </xsl:template>
    <xsl:template match="listItem" priority="1">
        <xsl:comment>DEBUG: Matched GENERIC listItem template</xsl:comment>
        <li class="mb-1">
            <xsl:apply-templates select="para[1]" mode="listItemFirstPara"/>
            <xsl:apply-templates select="node()[not(self::para[1])]"/>
        </li>
    </xsl:template>
    <xsl:template match="note[not(ancestor::safetyRqmts)]">
        <div class="alert alert-secondary s1000d-note ps-box" id="{@id}">
            <span class="s1000d-note-prefix">NOTE
                <xsl:if test="$numbered-titles and (count(preceding-sibling::note[not(ancestor::safetyRqmts)]) + count(following-sibling::note[not(ancestor::safetyRqmts)])) > 0">
                    <xsl:text> </xsl:text>
                    <xsl:number level="any" count="note[not(ancestor::safetyRqmts)]" from="*[self::content or self::procedure or self::description or self::mainProcedure or self::levelledPara or self::proceduralStep or self::entry or self::listItem]"/>
                </xsl:if>:
            </span>
            <xsl:apply-templates select="para | sequentialList | randomList | node()[self::text() and normalize-space()]"/>
        </div>
    </xsl:template>
    <xsl:template match="emphasis">
        <span class="font-weight-bold">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="emphasis[@emphasisType='et02']">
        <span class="ps-italic">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="underline">
        <span class="text-decoration-underline">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="table">
        <div class="table-responsive mb-3 s1000d-table" id="{@id}">
            <xsl:if test="title">
                <h5 class="s1000d-table-title text-center mt-2 mb-1" id="{generate-id(title)}">
                    <xsl:if test="$numbered-titles">
                        <span class="s1000d-table-title-prefix">Table
                            <xsl:variable name="chapterNumberDot">
                                <xsl:if test="ancestor::procedure[ancestor::content]">
                                    <xsl:number count="procedure" level="single" from="content" format="1"/>-
                                </xsl:if>
                            </xsl:variable>
                            <xsl:value-of select="$chapterNumberDot"/>
                            <xsl:number level="any" count="table" from="*[self::content or self::procedure[not(ancestor::procedure)] or self::description]" format="1"/>:
                        </span>
                    </xsl:if>
                    <xsl:apply-templates select="title" mode="inline"/>
                </h5>
            </xsl:if>
            <table class="table table-bordered table-sm">
                <xsl:apply-templates select="tgroup"/>
                <xsl:apply-templates select="tbody[not(parent::tgroup)]"/>
                <xsl:if test="not(tgroup) and not(tbody) and row">
                    <tbody>
                        <xsl:apply-templates select="row"/>
                    </tbody>
                </xsl:if>
            </table>
        </div>
    </xsl:template>
    <xsl:template match="tgroup">
        <xsl:if test="@cols and string(xs:integer(number(@cols))) != 'NaN' ">
            <colgroup>
                <xsl:for-each select="1 to xs:integer(number(@cols))">
                    <col/>
                </xsl:for-each>
            </colgroup>
        </xsl:if>
        <xsl:apply-templates select="thead"/>
        <xsl:apply-templates select="tbody"/>
    </xsl:template>
    <xsl:template match="thead">
        <thead class="thead-light">
            <xsl:apply-templates select="row"/>
        </thead>
    </xsl:template>
    <xsl:template match="tbody">
        <tbody>
            <xsl:apply-templates select="row"/>
        </tbody>
    </xsl:template>
    <xsl:template match="row">
        <tr>
            <xsl:apply-templates select="entry"/>
        </tr>
    </xsl:template>
    <xsl:template match="entry">
        <td>
            <xsl:if test="@namest">
                <xsl:attribute name="data-colname">
                    <xsl:value-of select="@namest"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@nameend">
                <xsl:attribute name="data-colname-end">
                    <xsl:value-of select="@nameend"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@morerows">
                <xsl:attribute name="rowspan">
                    <xsl:value-of select="number(@morerows) + 1"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@nameend and not(@namest = @nameend)">
                <xsl:variable name="colspecs" select="ancestor::tgroup[1]/colspec"/>
                <xsl:variable name="start-col-pos" select="count($colspecs[@colname=current()/@namest]/preceding-sibling::colspec) + 1"/>
                <xsl:variable name="end-col-pos" select="count($colspecs[@colname=current()/@nameend]/preceding-sibling::colspec) + 1"/>
                <xsl:if test="$end-col-pos > $start-col-pos">
                    <xsl:attribute name="colspan">
                        <xsl:value-of select="$end-col-pos - $start-col-pos + 1"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates/>
        </td>
    </xsl:template>
    <xsl:template match="figure">
        <div class="text-center my-3 p-3 border rounded" id="{@id}">
            <xsl:if test="title">
                <h5 class="s1000d-figure-title" id="{generate-id(title)}">
                    <xsl:if test="$numbered-titles">
                        <span class="s1000d-figure-title-prefix">Figure
                            <xsl:variable name="chapterNumberDot">
                                <xsl:if test="ancestor::procedure[ancestor::content]">
                                    <xsl:number count="procedure" level="single" from="content" format="1"/>-
                                </xsl:if>
                            </xsl:variable>
                            <xsl:value-of select="$chapterNumberDot"/>
                            <xsl:number level="any" count="figure" from="*[self::content or self::procedure[not(ancestor::procedure)] or self::description]" format="1"/>:
                        </span>
                    </xsl:if>
                    <xsl:apply-templates select="title" mode="inline"/>
                </h5>
            </xsl:if>
            <xsl:apply-templates select="graphic"/>
            <xsl:if test="graphic/@infoEntityIdent">
                <div class="mt-2">
                    <button class="btn btn-sm btn-outline-secondary icn-link" type="button">View
                        <xsl:value-of select="graphic/@infoEntityIdent"/>
                    </button>
                </div>
            </xsl:if>
        </div>
    </xsl:template>
    <xsl:template match="graphic">
        <img class="img-fluid fig">
            <xsl:attribute name="src">
                <xsl:value-of select="concat('illustrations/', @infoEntityIdent, '.png')"/>
            </xsl:attribute>
            <xsl:attribute name="alt">
                <xsl:choose>
                    <xsl:when test="../title">
                        <xsl:value-of select="normalize-space(../title)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@infoEntityIdent"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </img>
    </xsl:template>
    <xsl:template match="title" mode="inline">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="title">
        <h3 class="ps-Title_font ps-Title_3 ps-Title_color">
            <xsl:apply-templates/>
        </h3>
    </xsl:template>
    <xsl:template match="internalRef">
        <xsl:variable name="target-id" select="@internalRefId"/>
        <xsl:variable name="target" select="key('ids', $target-id)"/>
        <a href="#{$target-id}" class="ps-Link">
            <xsl:choose>
                <xsl:when test="name($target)='figure'">Figure
                    <xsl:for-each select="$target">
                        <xsl:variable name="chapterNumberDot">
                            <xsl:if test="ancestor::procedure[ancestor::content]">
                                <xsl:number count="procedure" level="single" from="content" format="1"/>-
                            </xsl:if>
                        </xsl:variable>
                        <xsl:value-of select="$chapterNumberDot"/>
                        <xsl:number level="any" count="figure" from="*[self::content or self::procedure[not(ancestor::procedure)] or self::description]" format="1"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="name($target)='table'">Table
                    <xsl:for-each select="$target">
                        <xsl:variable name="chapterNumberDot">
                            <xsl:if test="ancestor::procedure[ancestor::content]">
                                <xsl:number count="procedure" level="single" from="content" format="1"/>-
                            </xsl:if>
                        </xsl:variable>
                        <xsl:value-of select="$chapterNumberDot"/>
                        <xsl:number level="any" count="table" from="*[self::content or self::procedure[not(ancestor::procedure)] or self::description]" format="1"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="name($target)='levelledPara'">Para
                    <xsl:if test="$numbered-titles">
                        <xsl:variable name="targetProcAncestor" select="$target/ancestor::procedure[1]"/>
                        <xsl:variable name="targetDescAncestor" select="$target/ancestor::description[1]"/>
                        <xsl:choose>
                            <xsl:when test="$targetProcAncestor">
                                <xsl:for-each select="$targetProcAncestor">
                                    <xsl:number count="procedure" level="single" from="content" format="1"/>
                                </xsl:for-each>.
                                <xsl:for-each select="$target">
                                    <xsl:number count="levelledPara" level="multiple" from="procedure" format="1"/>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="$targetDescAncestor">
                                <xsl:for-each select="$target">
                                    <xsl:number count="levelledPara" level="multiple" from="description" format="1"/>
                                </xsl:for-each>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="name($target)='proceduralStep'">Step (
                    <xsl:value-of select="$target-id"/>)
                </xsl:when>
                <xsl:when test="normalize-space(.)">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:when test="$target/title">
                    <xsl:apply-templates select="$target/title" mode="inline"/>
                </xsl:when>
                <xsl:otherwise>Ref (
                    <xsl:value-of select="$target-id"/>)
                </xsl:otherwise>
            </xsl:choose>
        </a>
    </xsl:template>
    <!-- Preliminary Requirements (Styling classes added to titles) -->
    <xsl:template match="preliminaryRqmts">
        <div class="preliminary-requirements-section mt-4 mb-4 p-3 border rounded">
            <h3 id="{@id}" class="mb-3 ps-Title_font ps-Title_3 ps-Title_color">Preliminary Requirements</h3>
            <xsl:apply-templates select="reqCondGroup | reqPersons | reqTechInfoGroup | reqSupportEquips | reqSupplies | reqSpares | reqSafety"/>
        </div>
    </xsl:template>
    <xsl:template match="reqCondGroup">
        <div class="req-cond-group mt-3">
            <h4 class="mb-2 ps-Title_font ps-Title_4 ps-Title_color">Required Conditions</h4>
            <table class="tblReferences table-bordered table-sm table-striped prelim-req-table s1000d-table">
                <thead class="thead-light">
                    <tr>
                        <th>Action / Condition</th>
                        <th>Data Module / Technical Publication</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:apply-templates select="reqCondPm | reqCondDm | reqCondNoRef"/>
                </tbody>
            </table>
        </div>
    </xsl:template>
    <xsl:template match="reqCondPm | reqCondDm | reqCondNoRef">
        <tr>
            <td>
                <xsl:apply-templates select="reqCond/node()"/>
            </td>
            <td>
                <xsl:apply-templates select="pmRef | dmRef"/>
                <xsl:if test="not(pmRef) and not(dmRef)">N/A</xsl:if>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="pmRef">
        <xsl:variable name="pmIdent" select="pmRefIdent"/>
        <xsl:variable name="pmCodeEl" select="$pmIdent/pmCode"/>
        <xsl:variable name="langEl" select="$pmIdent/language"/>
        <xsl:variable name="issueEl" select="$pmIdent/issueInfo"/>
        <xsl:variable name="pm_mic" select="$pmCodeEl/@modelIdentCode"/>
        <xsl:variable name="pm_issuer" select="$pmCodeEl/@pmIssuer"/>
        <xsl:variable name="pm_number" select="$pmCodeEl/@pmNumber"/>
        <xsl:variable name="pm_volume" select="$pmCodeEl/@pmVolume"/>
        <xsl:variable name="pm_filename" select="concat(translate(concat($pm_mic, '-', $pm_issuer, '-', $pm_number, '-', $pm_volume), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), '.html')"/>
        <a href="{$pm_filename}" class="pm-reference-link ps-Link">PM:
            <xsl:value-of select="$pm_mic"/>-
            <xsl:value-of select="$pm_issuer"/>-
            <xsl:value-of select="$pm_number"/>-
            <xsl:value-of select="$pm_volume"/>
            <xsl:if test="$issueEl">; Issue:
                <xsl:value-of select="$issueEl/@issueNumber"/>
                <xsl:if test="$issueEl/@inWork and $issueEl/@inWork != '00'"> (InWork:
                    <xsl:value-of select="$issueEl/@inWork"/>)
                </xsl:if>
            </xsl:if>
            <xsl:if test="$langEl">; Lang:
                <xsl:value-of select="$langEl/@languageIsoCode"/>-
                <xsl:value-of select="$langEl/@countryIsoCode"/>
            </xsl:if>.
        </a>
    </xsl:template>
    <xsl:template match="reqPersons">
        <div class="req-persons mt-3">
            <h4 class="mb-2 ps-Title_font ps-Title_4 ps-Title_color">Required Personnel</h4>
            <table class="tblReferences table-bordered table-sm table-striped prelim-req-table s1000d-table">
                <thead class="thead-light">
                    <tr>
                        <th>Persons</th>
                        <th>Category</th>
                        <th>Skill Level</th>
                        <th>Trade</th>
                        <th>Est. Time</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:apply-templates select="person"/>
                </tbody>
            </table>
        </div>
    </xsl:template>
    <xsl:template match="person">
        <tr>
            <td>
                <xsl:value-of select="@man"/>
            </td>
            <td>
                <xsl:value-of select="personCategory/@personCategoryCode"/>
            </td>
            <td>
                <xsl:value-of select="personSkill/@skillLevelCode"/>
            </td>
            <td>
                <xsl:value-of select="trade"/>
            </td>
            <td>
                <xsl:value-of select="estimatedTime"/>
                <xsl:value-of select="estimatedTime/@unitOfMeasure"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="reqTechInfoGroup">
        <div class="req-tech-info-group mt-3" style="margin: 0 10px" >
            <h4 class="mb-2 ps-Title_font ps-Title_4 ps-Title_color">Required Technical Information</h4>
            <ul class="list-group list-group-flush">
                <xsl:apply-templates select="reqTechInfo"/>
            </ul>
        </div>
    </xsl:template>
    <xsl:template match="reqTechInfo">
        <li class="list-group-item">
            <xsl:if test="@reqTechInfoCategory">
                <span class="badge badge-info mr-2">Category:
                    <xsl:value-of select="@reqTechInfoCategory"/>
                </span>
            </xsl:if>
            <xsl:apply-templates select="dmRef"/>
        </li>
    </xsl:template>
    <xsl:template match="reqSupportEquips | reqSupplies | reqSpares">
        <div class="mt-3">
            <h4 id="{@id}" class="mb-2 ps-Title_font ps-Title_4 ps-Title_color">
                <xsl:choose>
                    <xsl:when test="self::reqSupportEquips">Support Equipment</xsl:when>
                    <xsl:when test="self::reqSupplies">Consumables, materials and expendables</xsl:when>
                    <xsl:when test="self::reqSpares">Spares</xsl:when>
                </xsl:choose>
            </h4>
            <xsl:apply-templates select="supportEquipDescrGroup | supplyDescrGroup | spareDescrGroup"/>
        </div>
    </xsl:template>
    <xsl:template match="supportEquipDescrGroup | supplyDescrGroup | spareDescrGroup">
        <table class="tblReferences table-bordered table-sm table-striped prelim-req-table s1000d-table">
            <thead class="thead-light">
                <tr>
                    <th>Name</th>
                    <th>Manufacturer / Part No.</th>
                    <th>Quantity</th>
                    <th>Remark</th>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates select="supportEquipDescr | supplyDescr | spareDescr"/>
            </tbody>
        </table>
    </xsl:template>
    <xsl:template match="supportEquipDescr | supplyDescr | spareDescr">
        <tr>
            <td>
                <xsl:value-of select="name"/>
            </td>
            <td>
                <xsl:value-of select="identNumber/manufacturerCode"/>
                <xsl:if test="identNumber/manufacturerCode and identNumber/partAndSerialNumber/partNumber">
                    <xsl:text> / </xsl:text>
                </xsl:if>
                <xsl:value-of select="identNumber/partAndSerialNumber/partNumber"/>
            </td>
            <td>
                <xsl:value-of select="reqQuantity"/>
                <xsl:if test="self::supplyDescr and reqQuantity/@unitOfMeasure">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="reqQuantity/@unitOfMeasure"/>
                </xsl:if>
            </td>
            <td>
                <xsl:apply-templates select="remarks/simplePara/node()"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="reqSafety">
        <div class="req-safety mt-3">
            <h4 id="{@id}" class="mb-2 ps-Title_font ps-Title_4 ps-Title_color">Safety Requirements</h4>
            <xsl:apply-templates select="safetyRqmts"/>
        </div>
    </xsl:template>
    <xsl:template match="safetyRqmts">
        <xsl:apply-templates select="warning | caution | note"/>
    </xsl:template>
    <xsl:template match="warning">
        <div class="alert alert-danger mt-2 s1000d-note ps-box" role="alert" id="{@id}">
            <h5 class="alert-heading s1000d-note-prefix">WARNING:</h5>
            <xsl:apply-templates select="warningAndCautionPara"/>
        </div>
    </xsl:template>
    <xsl:template match="caution">
        <div class="alert alert-warning mt-2 s1000d-note ps-box" role="alert" id="{@id}">
            <h5 class="alert-heading s1000d-note-prefix">CAUTION:</h5>
            <xsl:apply-templates select="warningAndCautionPara"/>
        </div>
    </xsl:template>
    <xsl:template match="safetyRqmts/note">
        <div class="alert alert-info mt-2 s1000d-note ps-box" role="alert" id="{@id}">
            <h5 class="alert-heading s1000d-note-prefix">NOTE:</h5>
            <xsl:apply-templates select="notePara"/>
        </div>
    </xsl:template>
    <xsl:template match="warningAndCautionPara | notePara">
        <p class="mb-0 s1000d-para">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <!-- S1000D Identifiers -->
    <xsl:template match="dmRef[not(ancestor::reqTechInfo) and not(ancestor::refs) and not(ancestor::identAndStatusSection)]">
        <xsl:variable name="ref-dmc">
            <xsl:apply-templates select="dmRefIdent/dmCode" mode="text"/>
        </xsl:variable>
        <xsl:variable name="ref-filename" select="concat(translate($ref-dmc, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), '.html')"/>
        <a href="{$ref-filename}" class="ps-Link">
            <xsl:value-of select="$ref-dmc"/>
        </a>
    </xsl:template>
    <xsl:template match="dmRef" mode="refs">
        <tr>
            <td>
                <xsl:apply-templates select="."/>
            </td>
            <td>
                <xsl:choose>
                    <xsl:when test="dmRefAddressItems/dmTitle">
                        <xsl:apply-templates select="dmRefAddressItems/dmTitle"/>
                    </xsl:when>
                    <xsl:otherwise>N/A</xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="dmIdent | dmRefIdent">
        <xsl:apply-templates select="dmCode" mode="text"/>
    </xsl:template>
    <xsl:template match="dmCode" mode="text">
        <xsl:value-of select="@modelIdentCode"/>-
        <xsl:value-of select="@systemDiffCode"/>-
        <xsl:value-of select="@systemCode"/>-
        <xsl:value-of select="@subSystemCode"/>
        <xsl:value-of select="@subSubSystemCode"/>-
        <xsl:value-of select="@assyCode"/>-
        <xsl:value-of select="@disassyCode"/>
        <xsl:value-of select="@disassyCodeVariant"/>-
        <xsl:value-of select="@infoCode"/>
        <xsl:value-of select="@infoCodeVariant"/>-
        <xsl:value-of select="@itemLocationCode"/>
    </xsl:template>
    <xsl:template match="dmCode">
        <xsl:value-of select="@modelIdentCode"/>-
        <xsl:value-of select="@systemDiffCode"/>-
        <xsl:value-of select="@systemCode"/>-
        <xsl:value-of select="@subSystemCode"/>
        <xsl:value-of select="@subSubSystemCode"/>-
        <xsl:value-of select="@assyCode"/>-
        <xsl:value-of select="@disassyCode"/>
        <xsl:value-of select="@disassyCodeVariant"/>-
        <xsl:value-of select="@infoCode"/>
        <xsl:value-of select="@infoCodeVariant"/>-
        <xsl:value-of select="@itemLocationCode"/>
    </xsl:template>
    <xsl:template match="issueDate">
        <xsl:value-of select="@year"/>-
        <xsl:value-of select="@month"/>-
        <xsl:value-of select="@day"/>
    </xsl:template>
    <xsl:template match="language">
        <xsl:value-of select="@languageIsoCode"/>/
        <xsl:value-of select="@countryIsoCode"/>
    </xsl:template>
    <xsl:template match="dmTitle">
        <xsl:apply-templates select="techName"/>
        <xsl:if test="infoName">
            <xsl:text> – </xsl:text>
            <xsl:apply-templates select="infoName"/>
        </xsl:if>
        <xsl:if test="infoNameVariant">
            <xsl:text> (</xsl:text>
            <xsl:apply-templates select="infoNameVariant"/>
            <xsl:text>)</xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="techName | infoName | infoNameVariant">
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="responsiblePartnerCompany | originator">
        <xsl:value-of select="enterpriseName"/> (
        <xsl:value-of select="@enterpriseCode"/>)
    </xsl:template>
    <xsl:template name="object-id">
        <xsl:param name="object" select="."/>
        <xsl:choose>
            <xsl:when test="$object/@id">
                <xsl:value-of select="$object/@id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="generate-id($object)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Symbol for Tool Icon (JSS may have specific iconography) -->
    <xsl:template match="symbol">
        <xsl:if test="@symbolType='toolIcon' or contains(lower-case(@repsSysOrientedSymbolName),'tool') or contains(lower-case(@id),'tool')">
            <img src="images/Tool_Symbol.jpg" alt="Tool Symbol" class="s1000d-tool-icon" style="height: 1em; vertical-align: baseline; margin-right: 0.2em;"/>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    <!-- Remove empty text nodes -->
    <xsl:template match="text()[normalize-space(.) = '']"/>
</xsl:stylesheet>