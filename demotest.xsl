<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="1.0">
    <xsl:output method="html" doctype-system="about:legacy-compat" encoding="UTF-8" indent="yes"/>
    <!-- Parameters -->
    <xsl:param name="numbered-titles" select="false()"/>
    <xsl:param name="show-references-table" select="true()"/>
    <xsl:param name="reference-resolver" select="false()"/>
    <xsl:param name="extra-header-tags" select="false()"/>
    <xsl:param name="bootstrap-css-path" select="'xignal/assets/bootstrap/4.6.2/css/bootstrap.min.css'"/>
    <xsl:param name="custom-css-path" select="'../main.css'"/>
    <xsl:param name="jquery-js-path" select="'xignal/assets/jquery/3.7.1/jquery-slim-min.js'"/>
    <xsl:param name="bootstrap-js-path" select="'xignal/assets/bootstrap/4.6.2/js/bootstrap.min.js'"/>
    <xsl:param name="applic-js-path" select="'../js/applic.js'"/>
    <xsl:key name="ids" match="*[@id]" use="@id"/>
    <!-- Helper templates for applicability (from new version) -->
    <xsl:template name="generate-applic-string">
        <xsl:param name="applicNode" select="."/>
        <xsl:if test="$applicNode/*[local-name()='evaluate']">
            <xsl:variable name="eval" select="$applicNode/*[local-name()='evaluate'][1]"/>
            <xsl:value-of select="translate($eval/@andOr, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
            <xsl:for-each select="$eval/*[local-name()='assert']">
                <xsl:text>;</xsl:text>
                <xsl:value-of select="@applicPropertyIdent"/>
                <xsl:text>=</xsl:text>
                <xsl:value-of select="@applicPropertyValues"/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <xsl:template name="get-product-display-text">
        <xsl:param name="applicNode" />
        <xsl:choose>
            <xsl:when test="$applicNode/*[local-name()='displayText']/*[local-name()='simplePara']">
                <xsl:value-of select="$applicNode/*[local-name()='displayText']/*[local-name()='simplePara']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$applicNode/*[local-name()='evaluate']/*[local-name()='assert']">
                    <xsl:value-of select="@applicPropertyIdent"/>:
                    <xsl:value-of select="@applicPropertyValues"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="add-applic-attribute">
        <xsl:if test="*[local-name()='applic']">
            <xsl:attribute name="data-applic">
                <xsl:call-template name="generate-applic-string">
                    <xsl:with-param name="applicNode" select="*[local-name()='applic']"/>
                </xsl:call-template>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!-- Root Template -->
    <xsl:template match="/">
        <html lang="en">
            <head>
                <meta charset="UTF-8"/>
                <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
                <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
                <title>
                    <xsl:apply-templates select="//*[local-name()='identAndStatusSection']//*[local-name()='dmTitle']"/>
                </title>
                <link rel="stylesheet" href="{$bootstrap-css-path}" />
                <xsl:if test="$custom-css-path != ''">
                    <link rel="stylesheet" href="{$custom-css-path}" />
                </xsl:if>
                <style>
                    .prelim-req-table { margin-bottom: 1.5rem; }
                    .fault-procedure-list { margin-top: 2rem; padding-left: 1rem; }
                    [id] { scroll-margin-top: 70px; }
                    .hidden-by-applic { display: none !important; }
                    /* You may need to add CSS for the old classes like .para0Indent here if not in main.css */
                    .para0Indent { width: 40px; /* Example value */ flex-shrink: 0; }
                    <!-- .roundedBullet { /* Example styling */
                        display: inline-block;
                        width: 25px;
                        height: 25px;
                        margin-right: 10px;
                        background-color: #337ab7; /* Example color */
                        color: white;
                        text-align: center;
                        line-height: 25px;
                        border-radius: 50%;
                        font-weight: bold;
                    } -->
                </style>
            </head>
            <body>
                <xsl:choose>
                    <xsl:when test="/*[local-name()='dmodule']">
                        <xsl:apply-templates select="/*[local-name()='dmodule']/*[local-name()='identAndStatusSection']" mode="page-setup"/>
                        <div id="s1000d-content">
                            <xsl:apply-templates select="/*[local-name()='dmodule']/*[local-name()='content']"/>
                        </div>
                        <script src="{$jquery-js-path}"></script>
                        <script src="{$bootstrap-js-path}"></script>
                        <script src="{$applic-js-path}"></script>
                    </xsl:when>
                    <xsl:when test="/*[local-name()='preliminaryRqmts']">
                        <div class="container-fluid">
                            <xsl:apply-templates select="."/>
                        </div>
                        <script src="{$jquery-js-path}"></script>
                        <script src="{$bootstrap-js-path}"></script>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </body>
        </html>
    </xsl:template>
    <!-- Page Setup (from new version) -->
    <!-- MODIFIED TEMPLATE -->
    <xsl:template match="*[local-name()='identAndStatusSection']" mode="page-setup">
        <xsl:call-template name="generate-title-bar">
            <xsl:with-param name="identSection" select="."/>
        </xsl:call-template>
        <div class="container-fluid idstatusTitle">
            <button type="button" class="btn btn-primary mt-1 mb-3" data-toggle="modal" data-target="#idstatusModal">View Identification and Status</button>
        </div>
        <xsl:call-template name="generate-id-status-modal">
            <xsl:with-param name="identSection" select="."/>
        </xsl:call-template>
        <xsl:variable name="all_references_in_dm" select="ancestor::*[local-name()='dmodule'][1]//*[local-name()='dmRef' or local-name()='externalPubRef' or local-name()='pmRef'][ancestor::*[local-name()='content'] or ancestor::*[local-name()='refs']]"/>
        <!-- START OF MODIFICATION FOR REFERENCES -->
        <xsl:if test="$show-references-table">
            <xsl:variable name="collapseId" select="'collapse-references'"/>
            <div class="container-fluid">
                <h2 id="tblReferences" class="ps-Title_font ps-Title_2 ps-Title_color" style="cursor: pointer;" data-toggle="collapse" data-target="#{$collapseId}" aria-expanded="true" aria-controls="{$collapseId}">
                References
                    <span class="dm-collapse-icon"></span>
                </h2>
                <div class="dm-collapse show" id="{$collapseId}">
                    <table class="tblReferences mb-5 table table-borderless prelim-req-table s1000d-table">
                        <caption class="italic spaceAfter-sm s1000d-table-title">Table 1 References</caption>
                        <thead>
                            <tr>
                                <th>Data module/Technical publication</th>
                                <th>Title</th>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:choose>
                                <xsl:when test="$all_references_in_dm">
                                    <xsl:apply-templates select="$all_references_in_dm" mode="refs"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <tr>
                                        <td colspan="2" class="text-center">None</td>
                                    </tr>
                                </xsl:otherwise>
                            </xsl:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </xsl:if>
        <!-- END OF MODIFICATION -->
    </xsl:template>
    <!-- Content processing -->
    <!-- MODIFIED Content processing to include illustratedPartsCatalog -->
    <xsl:template match="*[local-name()='content']">
        <div class="container-fluid">
            <xsl:apply-templates select="*[local-name()='description'] | *[local-name()='procedure'] | *[local-name()='faultIsolation'] | *[local-name()='preliminaryRqmts'] | *[local-name()='illustratedPartsCatalog']"/>
        </div>
    </xsl:template>
    <!-- ################################################################## -->
    <!-- ### START OF IPD (Illustrated Parts Data) TEMPLATES          ### -->
    <!-- ################################################################## -->
    <xsl:template match="*[local-name()='illustratedPartsCatalog']">
        <!-- Part 1: Process the figures -->
        <xsl:apply-templates select="*[local-name()='figure']"/>
        <!-- Part 2: Create the parts data table -->
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12">
                    <h3>Catalog sequence numbers</h3>
                    <table class="ipdTbl table table-hover table-borderless">
                        <thead>
                            <tr>
                                <th>Fig</th>
                                <th>Item</th>
                                <th>Units per assembly / Unit of issue</th>
                                <th>CAGE</th>
                                <th>Part No.
                                    <br/>NATO Stock No.
                                </th>
                                <th class="description-cell">Description</th>
                                <th>
                                    <span style="font-size:8px;">🞷</span> Usable on
                                    <br/>code assy
                                    <br/>• MV/ Effect
                                </th>
                                <th>ICY</th>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:apply-templates select="*[local-name()='catalogSeqNumber']"/>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </xsl:template>
    <!-- Template for the <figure> inside an IPD -->
    <xsl:template match="*[local-name()='illustratedPartsCatalog']/*[local-name()='figure']">
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12">
                    <h2>Illustrated Parts Data (IPD)</h2>
                    <div class="text-center font-italic mt-2 mb-1">
                        Fig
                        <xsl:number count="figure" level="any"/>&#160;
                        <xsl:value-of select="title"/>
                    </div>
                    <div class="text-center">
                        <xsl:for-each select="graphic">
                            <span class="font-italic">Sheet
                                <xsl:value-of select="position()"/> of
                                <xsl:value-of select="last()"/>
                            </span>
                            <div class="container-fluid m-0 pb-4">
                                <xsl:apply-templates select="."/>
                                <br/>
                                <button class="btn btn-sm btn-secondary mb-1 icn-link">View</button>
                                <br/>
                                <div class="icn">
                                    <xsl:value-of select="@infoEntityIdent"/>
                                </div>
                            </div>
                        </xsl:for-each>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
    <!-- Template for each catalog sequence number group -->
    <xsl:template match="*[local-name()='catalogSeqNumber']">
        <!-- A catalogSeqNumber can have multiple itemSeqNumbers, each becomes a row -->
        <xsl:for-each select="*[local-name()='itemSeqNumber']">
            <tr>
                <!-- Fig Number (only for the first item in the group) -->
                <td>
                    <xsl:if test="position() = 1">
                        <xsl:value-of select="../@figureNumber"/>
                    </xsl:if>
                </td>
                <!-- Item Number (only for the first item in the group) -->
                <td>
                    <xsl:if test="position() = 1">
                        <xsl:value-of select="../@item"/>
                    </xsl:if>
                </td>
                <!-- Quantity -->
                <td>
                    <xsl:value-of select="*[local-name()='quantityPerNextHigherAssy']"/>
                </td>
                <!-- CAGE Code -->
                <td>
                    <xsl:value-of select="*[local-name()='partRef']/@manufacturerCodeValue"/>
                </td>
                <!-- Part Number -->
                <td>
                    <xsl:value-of select="*[local-name()='partRef']/@partNumberValue"/>
                </td>
                <!-- Description with indentation -->
                <td class="description-cell">
                    <xsl:if test="../@indenture > 1">
                        <xsl:text>• </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="*[local-name()='partSegment']/*[local-name()='itemIdentData']/*[local-name()='descrForPart']"/>
                </td>
                <!-- Empty cells to match the header -->
                <td></td>
                <td></td>
            </tr>
        </xsl:for-each>
    </xsl:template>
    <!-- ################################################################## -->
    <!-- ### END OF IPD TEMPLATES                                     ### -->
    <!-- ################################################################## -->
    <!-- Template for top-level description/procedure (from old version, adapted) -->
    <!-- ################################################################## -->
    <!-- ### START OF RESTORED TEMPLATES FROM OLD VERSION (ADAPTED) ### -->
    <!-- ################################################################## -->
    <!-- Template for top-level description/procedure (from old version, adapted) -->
    <xsl:template match="*[local-name()='description'] | *[local-name()='procedure']">
        <xsl:call-template name="add-applic-attribute"/>
        <xsl:apply-templates/>
    </xsl:template>
    <!-- Template for top-level description/procedure title (from old version, adapted) -->
    <xsl:template match="*[local-name()='description']/*[local-name()='title'] | *[local-name()='procedure']/*[local-name()='title']">
        <div class="row">
            <div class="col-md-12 mainDoctypeTitle">
                <h2 id="{generate-id()}">
                    <xsl:apply-templates/>
                </h2>
            </div>
        </div>
    </xsl:template>
    <!-- Revised levelledPara Template (from old version, adapted) -->
    <xsl:template match="*[local-name()='levelledPara']">
        <div class="row">
            <div class="col-12">
                <div class="levelOneBar mb-3 rounded">
                    <xsl:call-template name="add-applic-attribute"/>
                    <div class="d-flex">
                        <!-- Hierarchical Bullet/Numbering for all levels -->
                        <div class="roundedBullet">
                            <xsl:number level="multiple" count="*[local-name()='levelledPara']" format="1.1"/>
                        </div>
                        <!-- Title -->
                        <xsl:if test="*[local-name()='title']">
                            <div class="para0Title">
                                <span class="text-decoration-underline">
                                    <xsl:apply-templates select="*[local-name()='title']" mode="inline"/>
                                </span>
                            </div>
                        </xsl:if>
                    </div>
                    <!-- Content -->
                    <xsl:apply-templates select="*[local-name()='para'] | *[local-name()='figure'] | *[local-name()='note'] | *[local-name()='seqList'] | *[local-name()='randomList'] | *[local-name()='table'] | *[local-name()='levelledPara']"/>
                </div>
            </div>
        </div>
    </xsl:template>
    <!-- Handling title within levelledPara (from old version, adapted) -->
    <xsl:template match="*[local-name()='levelledPara']/*[local-name()='title']" mode="inline">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="*[local-name()='externalPubRef']">
        <a target="_blank" rel="noopener noreferrer">
            <xsl:attribute name="href">
                <xsl:value-of select="@xlink:href"/>
            </xsl:attribute>
            <!-- Process the content of the link, which is usually the title -->
            <xsl:apply-templates select=".//*[local-name()='externalPubTitle'] | .//*[local-name()='externalPubCode']"/>
        </a>
    </xsl:template>
    <!-- Revised para Template (from old version, adapted) -->
    <!-- Revised para Template (Corrected to remove indent from lists) -->
    <xsl:template match="*[local-name()='para']">
        <xsl:choose>
            <!-- NEW: Handles 'para' inside 'listItem' specifically, without the indent structure -->
            <xsl:when test="parent::*[local-name()='listItem']">
                <span class="m-0 pb-2">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <!-- MODIFIED: The 'listItem' condition has been removed from here -->
            <xsl:when test="parent::*[local-name()='levelledPara'] | parent::*[local-name()='note']">
                <div class="d-flex">
                    <xsl:call-template name="add-applic-attribute"/>
                    <div class="para0Indent"/>
                    <div class="para0TextDescription flex-grow-1 pb-3">
                        <span class="m-0 pb-2">
                            <xsl:apply-templates/>
                        </span>
                    </div>
                </div>
            </xsl:when>
            <!-- The rest of the template remains unchanged -->
            <xsl:when test="parent::*[local-name()='listItemDefinition']">
                <dd>
                    <xsl:call-template name="add-applic-attribute"/>
                    <xsl:apply-templates/>
                </dd>
            </xsl:when>
            <xsl:otherwise>
                <div class="row">
                    <div class="col-12">
                        <p>
                            <xsl:call-template name="add-applic-attribute"/>
                            <xsl:apply-templates/>
                        </p>
                    </div>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Sequential List (Ordered List) (from old version, adapted) -->
    <xsl:template match="*[local-name()='sequentialList']">
        <div class="d-flex">
            <xsl:call-template name="add-applic-attribute"/>
            <div class="para0TextDescription flex-grow-1 pb-3">
                <ol>
                    <xsl:apply-templates select="*[local-name()='listItem']"/>
                </ol>
            </div>
        </div>
    </xsl:template>
    <!-- Random List (Unordered List) (from old version, adapted) -->
    <xsl:template match="*[local-name()='randomList']">
        <div class="d-flex">
            <xsl:call-template name="add-applic-attribute"/>
            <div class="para0TextDescription flex-grow-1 pb-3">
                <ul>
                    <xsl:apply-templates select="*[local-name()='listItem']"/>
                </ul>
            </div>
        </div>
    </xsl:template>
    <!-- List Item (from old version, adapted) -->
    <xsl:template match="*[local-name()='listItem']">
        <li class="m-0 pb-2">
            <xsl:call-template name="add-applic-attribute"/>
            <xsl:if test="position() = last()">
                <xsl:attribute name="class">m-0 pb-0</xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="*[local-name()='para']">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <span class="m-0 p-0">
                        <xsl:apply-templates/>
                    </span>
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>
    <!-- Note Template (from old version, adapted) -->
    <!-- This replaces the alert-style note from the new version -->
    <xsl:template match="*[local-name()='note']">
        <div class="row">
            <xsl:call-template name="add-applic-attribute"/>
            <div class="col-12">
                <table class="noteBackground">
                    <tbody>
                        <tr>
                            <td class="text-center p-4">
                                <table class="noteBody">
                                    <tbody>
                                        <tr>
                                            <td class="text-center font-weight-bold p-4">
                                                <div class="h6 font-weight-bold">Note</div>
                                                <div class="font-weight-bold">
                                                    <p class="pb-0 m-0">
                                                        <xsl:apply-templates/>
                                                    </p>
                                                </div>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </xsl:template>
    <!-- ################################################################## -->
    <!-- ### END OF RESTORED TEMPLATES ### -->
    <!-- ################################################################## -->
    <!-- All other templates from the new version are kept below -->
    <xsl:template match="*[local-name()='preliminaryRqmts']">
        <xsl:variable name="collapseId" select="concat('collapse-', generate-id())"/>
        <div class="preliminary-requirements-section mt-4 mb-4 p-3 border rounded">
            <xsl:call-template name="add-applic-attribute"/>
            <h3 class="mb-3" style="cursor: pointer;" data-toggle="collapse" data-target="#{$collapseId}" aria-expanded="true" aria-controls="{$collapseId}">
            Preliminary Requirements
                <span class="dm-collapse-icon"></span>
                <!-- Down arrow -->
            </h3>
            <div class="dm-collapse show" id="{$collapseId}">
                <xsl:apply-templates/>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='reqCondGroup']">
        <xsl:variable name="collapseId" select="concat('collapse-', generate-id())"/>
        <div class="req-cond-group mt-3">
            <xsl:call-template name="add-applic-attribute"/>
            <h4 class="mb-2" style="cursor: pointer;" data-toggle="collapse" data-target="#{$collapseId}" aria-expanded="true" aria-controls="{$collapseId}">
            Required Conditions
                <span class="dm-collapse-icon"></span>
            </h4>
            <div class="dm-collapse show" id="{$collapseId}">
                <table class="tblReferences table-bordered table-sm table-striped prelim-req-table">
                    <thead class="thead-light">
                        <tr>
                            <th>Action / Condition</th>
                            <th>Data Module / Technical Publication</th>
                        </tr>
                    </thead>
                    <tbody>
                        <xsl:choose>
                            <xsl:when test="*[local-name()='reqCondPm'] | *[local-name()='reqCondDm'] | *[local-name()='reqCondNoRef']">
                                <xsl:apply-templates/>
                            </xsl:when>
                            <xsl:otherwise>
                                <tr>
                                    <td colspan="2" class="text-center">None</td>
                                </tr>
                            </xsl:otherwise>
                        </xsl:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='reqPersons']">
        <xsl:variable name="collapseId" select="concat('collapse-', generate-id())"/>
        <div class="req-persons mt-3">
            <xsl:call-template name="add-applic-attribute"/>
            <h4 class="mb-2" style="cursor: pointer;" data-toggle="collapse" data-target="#{$collapseId}" aria-expanded="true" aria-controls="{$collapseId}">
            Required Personnel
                <span class="dm-collapse-icon"></span>
            </h4>
            <div class="dm-collapse show" id="{$collapseId}">
                <table class="tblReferences table-bordered table-sm table-striped prelim-req-table">
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
                        <xsl:choose>
                            <xsl:when test="*[local-name()='person']">
                                <xsl:apply-templates/>
                            </xsl:when>
                            <xsl:otherwise>
                                <tr>
                                    <td colspan="5" class="text-center">None</td>
                                </tr>
                            </xsl:otherwise>
                        </xsl:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='reqSupportEquips'] | *[local-name()='reqSupplies'] | *[local-name()='reqSpares']">
        <xsl:variable name="collapseId" select="concat('collapse-', generate-id())"/>
        <div class="mt-3">
            <xsl:call-template name="add-applic-attribute"/>
            <h4 id="{@id}" class="mb-2" style="cursor: pointer;" data-toggle="collapse" data-target="#{$collapseId}" aria-expanded="true" aria-controls="{$collapseId}">
                <xsl:choose>
                    <xsl:when test="local-name()='reqSupportEquips'">Support Equipment</xsl:when>
                    <xsl:when test="local-name()='reqSupplies'">Consumables, materials and expendables</xsl:when>
                    <xsl:when test="local-name()='reqSpares'">Spares</xsl:when>
                </xsl:choose>
                <span class="dm-collapse-icon"></span>
            </h4>
            <div class="dm-collapse show" id="{$collapseId}">
                <xsl:apply-templates select="*"/>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='supportEquipDescrGroup'] | *[local-name()='supplyDescrGroup'] | *[local-name()='spareDescrGroup']">
        <table class="tblReferences table-bordered table-sm table-striped prelim-req-table">
            <xsl:call-template name="add-applic-attribute"/>
            <thead class="thead-light">
                <tr>
                    <th>Name</th>
                    <th>Manufacturer / Part No.</th>
                    <th>Quantity</th>
                    <th>Remark</th>
                </tr>
            </thead>
            <tbody>
                <xsl:choose>
                    <xsl:when test="*[local-name()='supportEquipDescr'] | *[local-name()='supplyDescr'] | *[local-name()='spareDescr']">
                        <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <td colspan="4" class="text-center">None</td>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
            </tbody>
        </table>
    </xsl:template>
    <xsl:template match="*[local-name()='reqSupportEquips']/*[not(local-name()='supportEquipDescrGroup')] | *[local-name()='reqSupplies']/*[not(local-name()='supplyDescrGroup')] | *[local-name()='reqSpares']/*[not(local-name()='spareDescrGroup')]">
        <table class="tblReferences table-bordered table-sm table-striped prelim-req-table">
            <thead class="thead-light">
                <tr>
                    <th>Name</th>
                    <th>Manufacturer / Part No.</th>
                    <th>Quantity</th>
                    <th>Remark</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td colspan="4" class="text-center">None</td>
                </tr>
            </tbody>
        </table>
    </xsl:template>
    <xsl:template match="*[local-name()='reqSafety']">
        <xsl:variable name="collapseId" select="concat('collapse-', generate-id())"/>
        <div class="req-safety mt-3">
            <xsl:call-template name="add-applic-attribute"/>
            <h4 id="{@id}" class="mb-2" style="cursor: pointer;" data-toggle="collapse" data-target="#{$collapseId}" aria-expanded="true" aria-controls="{$collapseId}">
            Safety Requirements
                <span class="dm-collapse-icon"></span>
            </h4>
            <div class="dm-collapse show" id="{$collapseId}">
                <xsl:choose>
                    <xsl:when test="*[local-name()='safetyRqmts']/*">
                        <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:otherwise>
                        <p>None</p>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='supportEquipDescr'] | *[local-name()='supplyDescr'] | *[local-name()='spareDescr']">
        <tr>
            <xsl:call-template name="add-applic-attribute"/>
            <td>
                <xsl:value-of select="*[local-name()='name']"/>
            </td>
            <td>
                <xsl:value-of select="*[local-name()='identNumber']/*[local-name()='manufacturerCode']"/>
                <xsl:if test="*[local-name()='identNumber']/*[local-name()='manufacturerCode'] and *[local-name()='identNumber']/*[local-name()='partAndSerialNumber']/*[local-name()='partNumber']"> / </xsl:if>
                <xsl:value-of select="*[local-name()='identNumber']/*[local-name()='partAndSerialNumber']/*[local-name()='partNumber']"/>
            </td>
            <td>
                <xsl:value-of select="*[local-name()='reqQuantity']"/>
                <xsl:if test="local-name()='supplyDescr' and *[local-name()='reqQuantity']/@unitOfMeasure">
                    <xsl:value-of select="*[local-name()='reqQuantity']/@unitOfMeasure"/>
                </xsl:if>
            </td>
            <td>
                <xsl:apply-templates select="*[local-name()='remarks']/*[local-name()='simplePara']/node()"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="*[local-name()='person']">
        <tr>
            <xsl:call-template name="add-applic-attribute"/>
            <td>
                <xsl:value-of select="@man"/>
            </td>
            <td>
                <xsl:value-of select="*[local-name()='personCategory']/@personCategoryCode"/>
            </td>
            <td>
                <xsl:value-of select="*[local-name()='personSkill']/@skillLevelCode"/>
            </td>
            <td>
                <xsl:value-of select="*[local-name()='trade']"/>
            </td>
            <td>
                <xsl:value-of select="*[local-name()='estimatedTime']"/>
                <xsl:value-of select="*[local-name()='estimatedTime']/@unitOfMeasure"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="*[local-name()='reqCondPm'] | *[local-name()='reqCondDm'] | *[local-name()='reqCondNoRef']">
        <tr>
            <xsl:call-template name="add-applic-attribute"/>
            <td>
                <xsl:apply-templates select="*[local-name()='reqCond']/node()"/>
            </td>
            <td>
                <xsl:apply-templates select="*[local-name()='pmRef'] | *[local-name()='dmRef']"/>
                <xsl:if test="not(*[local-name()='pmRef']) and not(*[local-name()='dmRef'])">N/A</xsl:if>
            </td>
        </tr>
    </xsl:template>
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
                                    <xsl:apply-templates select="$identSection//*[local-name()='dmIdent']"/>
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">Language:</div>
                                <div class="col-sm-9">
                                    <xsl:apply-templates select="$identSection//*[local-name()='language']"/>
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">Issue No.:</div>
                                <div class="col-sm-9">
                                    <xsl:value-of select="$identSection//*[local-name()='issueInfo']/@issueNumber"/> (
                                    <xsl:value-of select="$identSection//*[local-name()='issueInfo']/@inWork"/>)
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">Issue Date:</div>
                                <div class="col-sm-9">
                                    <xsl:apply-templates select="$identSection//*[local-name()='issueDate']"/>
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">Title:</div>
                                <div class="col-sm-9">
                                    <xsl:apply-templates select="$identSection//*[local-name()='dmTitle']"/>
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">Security:</div>
                                <div class="col-sm-9">
                                    <xsl:call-template name="decodeSecurity">
                                        <xsl:with-param name="code" select="$identSection/*[local-name()='dmStatus']/*[local-name()='security']/@securityClassification"/>
                                    </xsl:call-template>
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">RPC:</div>
                                <div class="col-sm-9">
                                    <xsl:apply-templates select="$identSection/*[local-name()='dmStatus']/*[local-name()='responsiblePartnerCompany']"/>
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">Originator:</div>
                                <div class="col-sm-9">
                                    <xsl:apply-templates select="$identSection/*[local-name()='dmStatus']/*[local-name()='originator']"/>
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">Applicability:</div>
                                <div class="col-sm-9">
                                    <xsl:apply-templates select="$identSection/*[local-name()='dmStatus']/*[local-name()='applic']/*[local-name()='displayText']/*[local-name()='simplePara']"/>
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">BREX:</div>
                                <div class="col-sm-9">
                                    <xsl:apply-templates select="$identSection/*[local-name()='dmStatus']/*[local-name()='brexDmRef']/*[local-name()='dmRef']"/>
                                </div>
                            </div>
                            <div class="row pb-2">
                                <div class="col-sm-3 font-weight-bold">QA:</div>
                                <div class="col-sm-9">
                                    <xsl:choose>
                                        <xsl:when test="$identSection/*[local-name()='dmStatus']/*[local-name()='qualityAssurance']/*[local-name()='unverified']">Unverified</xsl:when>
                                        <xsl:when test="$identSection/*[local-name()='dmStatus']/*[local-name()='qualityAssurance']/*[local-name()='firstVerification']">First Verification
                                            <xsl:value-of select="$identSection/*[local-name()='dmStatus']/*[local-name()='qualityAssurance']/*[local-name()='firstVerification']/@verificationType"/>
                                        </xsl:when>
                                        <xsl:otherwise>N/A</xsl:otherwise>
                                    </xsl:choose>
                                </div>
                            </div>
                            <xsl:if test="$identSection/*[local-name()='dmStatus']/*[local-name()='reasonForUpdate']">
                                <div class="row pb-2">
                                    <div class="col-sm-3 font-weight-bold">Reason for Update:</div>
                                    <div class="col-sm-9">
                                        <xsl:apply-templates select="$identSection/*[local-name()='dmStatus']/*[local-name()='reasonForUpdate']/*[local-name()='simplePara']"/>
                                    </div>
                                </div>
                            </xsl:if>
                        </div>
                    </div>
                    <!-- <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    </div> -->
                </div>
            </div>
        </div>
    </xsl:template>
    <xsl:template name="generate-title-bar">
        <xsl:param name="identSection"/>
        <div class="dmTitleBar bg-light p-3 mb-3">
            <h1 class="text-center">
                <xsl:apply-templates select="$identSection//*[local-name()='dmTitle']"/>
            </h1>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='simplePara']">
        <p>
            <xsl:call-template name="add-applic-attribute"/>
            <xsl:apply-templates/>
        </p>
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
    <xsl:template match="*[local-name()='refs']" mode="table">
        <table class="tblReferences mb-5 table table-sm table-striped prelim-req-table">
            <caption class="sr-only">References</caption>
            <thead class="thead-light">
                <tr>
                    <th>Data module/Technical publication</th>
                    <th>Title</th>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates select="*[local-name()='dmRef'] | *[local-name()='externalPubRef']" mode="refs"/>
            </tbody>
        </table>
    </xsl:template>
    <xsl:template match="*[local-name()='mainProcedure']">
        <xsl:variable name="collapseId" select="concat('collapse-', generate-id())"/>
        <div class="main-procedure-section mt-4">
            <xsl:call-template name="add-applic-attribute"/>
            <!-- If there's a title, it can become the trigger -->
            <h2 class="container-fluid mainProcedureTitle mb-3" style="cursor: pointer;" data-toggle="collapse" data-target="#{$collapseId}" aria-expanded="true" aria-controls="{$collapseId}">
            Main Procedure
                <span class="dm-collapse-icon"></span>
            </h2>
            <div class="dm-collapse show" id="{$collapseId}">
                <xsl:apply-templates/>
            </div>
        </div>
    </xsl:template>
    <!-- TEMPLATE 1: A single, robust template for ALL procedural steps -->
    <xsl:template match="*[local-name()='proceduralStep']">
        <!-- Store the node that will serve as the step's main text (title or first para) -->
        <xsl:variable name="main-text-node" select="(*[local-name()='title' or local-name()='para'])[1]"/>
        <xsl:variable name="main-text-node-id" select="generate-id($main-text-node)"/>
        <div class="row" id="{@id}">
            <div class="col-12">
                <div class="levelOneBar">
                    <!-- Part 1: The step number and its main text/title -->
                    <div class="d-flex">
                        <!-- Numbering (handles both top-level and nested) -->
                        <div class="step-number-container">
                            <xsl:choose>
                                <xsl:when test="parent::*[local-name()='proceduralStep']">
                                    <div class="subparaNo">
                                        <xsl:number level="multiple" count="*[local-name()='proceduralStep']" format="1.1"/>
                                    </div>
                                </xsl:when>
                                <xsl:otherwise>
                                    <div class="roundedBullet">
                                        <xsl:number level="single" count="*[local-name()='proceduralStep'][not(parent::*[local-name()='proceduralStep'])]" format="1"/>
                                    </div>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                        <!-- Main Text/Title -->
                        <div class="para0Title flex-grow-1">
                            <xsl:apply-templates select="$main-text-node"/>
                        </div>
                    </div>
                    <!-- Part 2: The rest of the step's content (figures, tables, other paras, nested steps) -->
                    <div class="step-content-wrapper" style="margin-left: 45px; margin-top: 10px;">
                        <!-- Process all children EXCEPT the node we already used as the main text -->
                        <xsl:apply-templates select="*[generate-id() != $main-text-node-id]"/>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
    <!-- TEMPLATE 2: A specific template for a <para> inside a step to ensure it's just a simple paragraph -->
    <xsl:template match="*[local-name()='proceduralStep']/*[local-name()='para']">
        <p class="mb-2">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <!-- TEMPLATE 3: A specific template for a <title> inside a step to make it bold -->
    <xsl:template match="*[local-name()='proceduralStep']/*[local-name()='title']">
        <p class="mb-2 font-weight-bold">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <!-- ################################################################## -->
    <!-- ### END OF CORRECTED PROCEDURAL STEP TEMPLATES                 ### -->
    <!-- ################################################################## -->
    <xsl:template match="*[local-name()='closeRqmts']">
        <xsl:variable name="collapseId" select="concat('collapse-', generate-id())"/>
        <div class="closeout-requirements-section mt-4">
            <xsl:call-template name="add-applic-attribute"/>
            <h2 id="{@id}" class="container-fluid closeRqmtsTitle mb-3" style="cursor: pointer;" data-toggle="collapse" data-target="#{$collapseId}" aria-expanded="true" aria-controls="{$collapseId}">
            Closeout Requirements
                <span class="dm-collapse-icon"></span>
            </h2>
            <div class="dm-collapse show" id="{$collapseId}">
                <xsl:apply-templates/>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='faultDescrGroup']">
        <div class="fault-codes-section mt-4">
            <xsl:call-template name="add-applic-attribute"/>
            <h3 class="mb-2">Fault Codes</h3>
            <table class="table table-bordered table-sm prelim-req-table">
                <caption class="sr-only">Fault Codes</caption>
                <thead class="thead-light">
                    <tr>
                        <th>Fault code</th>
                        <th>Fault description</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:choose>
                        <xsl:when test="*[local-name()='faultDescr']">
                            <xsl:apply-templates/>
                        </xsl:when>
                        <xsl:otherwise>
                            <tr>
                                <td colspan="2" class="text-center">None</td>
                            </tr>
                        </xsl:otherwise>
                    </xsl:choose>
                </tbody>
            </table>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='faultDescr']">
        <tr>
            <xsl:call-template name="add-applic-attribute"/>
            <td>
                <xsl:value-of select="*[local-name()='faultCode']"/>
            </td>
            <td>
                <xsl:apply-templates select="*[local-name()='faultDescrText']/*[local-name()='simplePara']/node()"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="*[local-name()='faultIsolationProcedure'] | *[local-name()='isolationProcedure']">
        <xsl:call-template name="add-applic-attribute"/>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="*[local-name()='isolationMainProcedure']">
        <div class="fault-procedure-list">
            <xsl:call-template name="add-applic-attribute"/>
            <h3 class="mt-4 mb-3">Fault Isolation Procedure</h3>
            <ol>
                <xsl:apply-templates/>
            </ol>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='isolationStep']">
        <li id="{@id}">
            <xsl:call-template name="add-applic-attribute"/>
            <div class="fault-step-content">
                <xsl:if test="*[local-name()='action']">
                    <xsl:apply-templates select="*[local-name()='action']"/>
                    <br/>
                </xsl:if>
                <xsl:apply-templates/>
            </div>
        </li>
    </xsl:template>
    <xsl:template match="*[local-name()='isolationProcedureEnd']">
        <li id="{@id}">
            <xsl:call-template name="add-applic-attribute"/>
            <div class="fault-step-content">
                <xsl:apply-templates select="*[local-name()='action']"/>
            </div>
            <div class="fault-closeout-link">
                <xsl:variable name="closeoutId" select="ancestor::*[local-name()='faultIsolation' or local-name()='isolationProcedure'][1]/*[local-name()='closeRqmts']/@id"/>
                <xsl:if test="$closeoutId">
                    <a href="#{$closeoutId}">Go to Requirements after job completion.</a>
                </xsl:if>
            </div>
        </li>
    </xsl:template>
    <xsl:template match="*[local-name()='action'] | *[local-name()='isolationStepQuestion']">
        <xsl:call-template name="add-applic-attribute"/>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="*[local-name()='isolationStepAnswer']">
        <ul class="fault-answers">
            <xsl:call-template name="add-applic-attribute"/>
            <xsl:apply-templates select="*[local-name()='yesNoAnswer']/*"/>
        </ul>
    </xsl:template>
    <xsl:template match="*[local-name()='yesAnswer'] | *[local-name()='noAnswer']">
        <li>
            <xsl:variable name="targetId" select="@nextActionRefId"/>
            <xsl:variable name="targetNode" select="key('ids', $targetId)"/>
            <xsl:variable name="targetNumber" select="count($targetNode/preceding-sibling::*[local-name()='isolationStep' or local-name()='isolationProcedureEnd']) + 1"/>
            <xsl:choose>
                <xsl:when test="local-name()='yesAnswer'">Yes: </xsl:when>
                <xsl:otherwise>No: </xsl:otherwise>
            </xsl:choose>
            <a href="#{$targetId}">Go to Step
                <xsl:value-of select="$targetNumber"/>.
            </a>
        </li>
    </xsl:template>
    <xsl:template match="*[local-name()='reqCond']/text() | *[local-name()='reqCond']/*[local-name()='internalRef']">
        <xsl:apply-imports/>
    </xsl:template>
    <xsl:template match="*[local-name()='emphasis']">
        <span class="font-weight-bold">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="*[local-name()='underline']">
        <span class="text-decoration-underline">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="*[local-name()='acronym']">
        <abbr>
            <xsl:attribute name="title">
                <xsl:value-of select="*[local-name()='acronymDefinition']"/>
            </xsl:attribute>
            <xsl:call-template name="add-applic-attribute"/>
            <xsl:value-of select="*[local-name()='acronymTerm']"/>
        </abbr>
    </xsl:template>
    <xsl:template match="table">
        <div class="row">
            <div class="col-12">
                <div class="levelOneBar">
                    <div class="d-flex" style= "display:flex !important">
                        <div class="para0Indent" style="text-align: left;
                    margin-left: 66px;
                    padding-top: 6px;
                    padding-bottom: 6px"/>
                        <div class="para0TextDescription flex-grow-1 pb-3" style=" padding-bottom: 1rem !important">
                            <!-- Table Title/Caption - S1000D style -->
                            <xsl:if test="title">
                                <div class="text-center font-italic mt-2 mb-1" id="tbl-{generate-id(.)}">
                        Table
                                    <xsl:number level="any" count="table" from="content"/>
                                    <!-- Non-breaking space -->
                                    <xsl:apply-templates select="title" mode="inline"/>
                                </div>
                            </xsl:if>
                            <!-- Actual HTML table, matching desired attributes -->
                            <table border="1" style= "width: 100%;
                                                 text-align: left;
                                                 border-spacing: 0;
                                                 border-collapse: separate;
                                                 border-radius: 8px;
                                                 border: 2px solid #E7E7E7;
                                                 margin-bottom: 16px ">
                                <xsl:apply-templates select="@*"/>
                                <!-- S1000D CALS tables usually have a tgroup -->
                                <xsl:apply-templates select="tgroup"/>
                                <!-- Fallback for tables without tgroup but with tbody (less common for S1000D) -->
                                <xsl:apply-templates select="tbody[not(parent::tgroup)]"/>
                                <!-- Fallback for tables with rows directly under table (simple tables) -->
                                <xsl:if test="not(tgroup) and not(tbody) and row">
                                    <tbody>
                                        <xsl:apply-templates select="row"/>
                                    </tbody>
                                </xsl:if>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="tgroup">
        <!-- colspec can be used to generate <col> elements for styling if needed,
             but the example uses width attribute on <td> -->
        <xsl:apply-templates select="thead"/>
        <xsl:apply-templates select="tbody"/>
    </xsl:template>
    <xsl:template match="thead">
        <thead>
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
            <xsl:if test="@morerows">
                <xsl:attribute name="rowspan">
                    <xsl:value-of select="number(@morerows) + 1"/>
                </xsl:attribute>
            </xsl:if>
            <!-- Handle COLSPAN (CALS namest/nameend → colspan) -->
            <xsl:if test="@namest and @nameend">
                <xsl:variable name="start" select="number(substring-after(@namest, 'c'))"/>
                <xsl:variable name="end" select="number(substring-after(@nameend, 'c'))"/>
                <xsl:attribute name="colspan">
                    <xsl:value-of select="$end - $start + 1"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="valign">top</xsl:attribute>
            <!-- Apply specific attributes to the first cell in a tbody row -->
            <xsl:if test="position() = 1 and ancestor::tbody">
                <xsl:attribute name="class">pb-4</xsl:attribute>
                <xsl:attribute name="width">20%</xsl:attribute>
            </xsl:if>
            <!-- If it's a header cell -->
            <xsl:if test="ancestor::thead">
                <xsl:attribute name="class">pb-4 font-weight-bold</xsl:attribute>
                <!-- Example styling for header -->
            </xsl:if>
            <!-- Content of the cell. The modified para template will handle <para> children correctly.
                 Other children like internalRef, emphasis, or plain text will be processed by their respective templates. -->
            <xsl:apply-templates/>
        </td>
    </xsl:template>
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>
    <!-- Figure Template -->
    <!--
==========================================================================================
  STEP 1: Create a single, reusable template for the main layout.
  This template generates the common DIV structure and accepts the specific content
  (like the image, button, and caption) as a parameter.
==========================================================================================
-->
    <xsl:template name="create-media-container">
        <!-- Define parameters to accept the ID and the content to be placed inside -->
        <xsl:param name="elementId" select="''"/>
        <xsl:param name="content"/>
        <!-- The 'id' from the original <figure> or <symbol> is applied here -->
        <div class="row" id="{$elementId}">
            <div class="col-12">
                <div class="levelOneBar">
                    <div class="d-flex">
                        <div class="para0Indent"/>
                        <div class="para0TextDescription flex-grow-1 pb-3">
                            <!-- The unique content for either a figure or symbol is inserted here -->
                            <xsl:copy-of select="$content"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
    <!--
==========================================================================================
  STEP 2: The <figure> template now only defines its unique content and calls the
  reusable layout template.
==========================================================================================
-->
    <xsl:template match="figure">
        <xsl:call-template name="create-media-container">
            <!-- Pass the figure's ID to the layout template -->
            <xsl:with-param name="elementId" select="@id"/>
            <!-- Define the unique content for a figure -->
            <xsl:with-param name="content">
                <!-- Figure Caption -->
                <xsl:if test="title">
                    <div class="text-center font-italic mt-2 mb-1" id="fig-{generate-id(.)}">
                    Fig
                        <xsl:number level="any" count="figure" from="content"/>
                        <xsl:text> </xsl:text>
                        <!-- Ensures a space after the number -->
                        <xsl:apply-templates select="title" mode="inline"/>
                    </div>
                </xsl:if>
                <!-- Figure Graphic and Controls -->
                <div class="text-center">
                    <div class="container-fluid m-0 pb-4">
                        <xsl:apply-templates select="graphic"/>
                        <br/>
                        <button class="btn btn-sm btn-secondary mb-1 icn-link">View</button>
                        <br/>
                        <div class="icn">
                            <xsl:value-of select="graphic/@infoEntityIdent"/>
                        </div>
                    </div>
                </div>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
==========================================================================================
  STEP 3: The <symbol> template ALSO calls the same layout template, but with its
  own, simpler content.
==========================================================================================
-->
    <xsl:template match="symbol">
        <xsl:call-template name="create-media-container">
            <!-- Pass the symbol's ID to the layout template -->
            <xsl:with-param name="elementId" select="@id"/>
            <!-- Define the unique content for a symbol -->
            <xsl:with-param name="content">
                <div class="text-center">
                    <div class="container-fluid m-0 pb-4">
                        <!-- Apply templates to this symbol to generate the <img> tag -->
                        <xsl:apply-templates select="." mode="generate-image"/>
                        <br/>
                        <div class="icn">
                            <xsl:value-of select="@infoEntityIdent"/>
                        </div>
                    </div>
                </div>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
==========================================================================================
  STEP 4: Consolidate the <img> tag generation into a single, robust template.
  This template now handles both <graphic> and <symbol> elements.
==========================================================================================
-->
    <xsl:template match="graphic | symbol" mode="generate-image">
        <img class="img-fluid fig">
            <xsl:attribute name="src">
                <xsl:value-of select="concat('illustrations/', translate(@infoEntityIdent, '–—', '--'), '.png')"/>
            </xsl:attribute>
            <xsl:attribute name="alt">
                <xsl:choose>
                    <!-- If the parent is a figure and it has a title, use that for better accessibility -->
                    <xsl:when test="parent::figure and ../title">
                        <xsl:value-of select="../title"/>
                    </xsl:when>
                    <!-- Otherwise, fall back to the identifier -->
                    <xsl:otherwise>
                        <xsl:value-of select="@infoEntityIdent"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </img>
    </xsl:template>
    <!-- The original template for graphic just calls the new, consolidated one -->
    <xsl:template match="graphic">
        <xsl:apply-templates select="." mode="generate-image"/>
    </xsl:template>
    <xsl:template match="*[local-name()='title']" mode="inline">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="*[local-name()='internalRef']">
        <xsl:variable name="target-id" select="@internalRefId"/>
        <xsl:variable name="target" select="key('ids', $target-id)"/>
        <a href="#{$target-id}">
            <xsl:choose>
                <xsl:when test="local-name($target)='figure'">
                    <xsl:text>Fig </xsl:text>
                    <xsl:variable name="fig_scope" select="$target/ancestor::*[local-name()='content'][1] | $target/ancestor::*[local-name()='procedure'][1] | $target/ancestor::*[local-name()='description'][1] | $target/ancestor::*[local-name()='mainProcedure'][1]"/>
                    <xsl:number format="1" value="count($target/preceding-sibling::*[local-name()='figure'][count(.|$fig_scope/descendant::*[local-name()='figure']) = count($fig_scope/descendant::*[local-name()='figure'])]) + 1"/>
                </xsl:when>
                <xsl:when test="local-name($target)='table'">
                    <xsl:text>Table </xsl:text>
                    <xsl:variable name="tbl_scope" select="$target/ancestor::*[local-name()='content'][1] | $target/ancestor::*[local-name()='procedure'][1] | $target/ancestor::*[local-name()='description'][1] | $target/ancestor::*[local-name()='mainProcedure'][1]"/>
                    <xsl:number format="1" value="count($target/preceding-sibling::*[local-name()='table'][count(.|$tbl_scope/descendant::*[local-name()='table']) = count($tbl_scope/descendant::*[local-name()='table'])]) + 1"/>
                </xsl:when>
                <xsl:when test="local-name($target)='levelledPara'">
                    <xsl:text>Para </xsl:text>
                    <xsl:variable name="lp_scope" select="$target/ancestor::*[local-name()='procedure'][1] | $target/ancestor::*[local-name()='description'][1]"/>
                    <xsl:number format="1" value="count($target/preceding-sibling::*[local-name()='levelledPara'][count(.|$lp_scope/*[local-name()='levelledPara']) = count($lp_scope/*[local-name()='levelledPara'])]) + 1"/>
                </xsl:when>
                <xsl:when test="local-name($target)='proceduralStep'">
                    <xsl:text>Step </xsl:text>(
                    <xsl:value-of select="$target-id"/>)
                </xsl:when>
                <xsl:when test="normalize-space(.)">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:when test="$target/*[local-name()='title']">
                    <xsl:apply-templates select="$target/*[local-name()='title']" mode="inline"/>
                </xsl:when>
                <xsl:otherwise>Ref (
                    <xsl:value-of select="$target-id"/>)
                </xsl:otherwise>
            </xsl:choose>
        </a>
    </xsl:template>
    <xsl:template match="*[local-name()='pmRef']">
        <xsl:variable name="pmIdent" select="*[local-name()='pmRefIdent']"/>
        <xsl:variable name="pmCodeEl" select="$pmIdent/*[local-name()='pmCode']"/>
        <xsl:variable name="langEl" select="$pmIdent/*[local-name()='language']"/>
        <xsl:variable name="issueEl" select="$pmIdent/*[local-name()='issueInfo']"/>
        <xsl:variable name="pm_mic" select="$pmCodeEl/@modelIdentCode"/>
        <xsl:variable name="pm_issuer" select="$pmCodeEl/@pmIssuer"/>
        <xsl:variable name="pm_number" select="$pmCodeEl/@pmNumber"/>
        <xsl:variable name="pm_volume" select="$pmCodeEl/@pmVolume"/>
        <xsl:variable name="pm_filename">
            <xsl:value-of select="translate(concat($pm_mic, '-', $pm_issuer, '-', $pm_number, '-', $pm_volume), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>.html
        </xsl:variable>
        <a href="{$pm_filename}" class="pm-reference-link">
            <xsl:text>PM: </xsl:text>
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
    <xsl:template match="*[local-name()='reqTechInfoGroup']">
        <xsl:variable name="collapseId" select="concat('collapse-', generate-id())"/>
        <div class="req-tech-info-group mt-3">
            <xsl:call-template name="add-applic-attribute"/>
            <h4 class="mb-2" style="cursor: pointer;" data-toggle="collapse" data-target="#{$collapseId}" aria-expanded="true" aria-controls="{$collapseId}">
            Required Technical Information
                <span class="dm-collapse-icon"></span>
            </h4>
            <div class="dm-collapse show" id="{$collapseId}">
                <table class="tblReferences table-bordered table-sm table-striped prelim-req-table">
                    <thead class="thead-light">
                        <tr>
                            <th>Category</th>
                            <th>Data Module / Technical Publication</th>
                        </tr>
                    </thead>
                    <tbody>
                        <xsl:choose>
                            <xsl:when test="*[local-name()='reqTechInfo']">
                                <xsl:apply-templates/>
                            </xsl:when>
                            <xsl:otherwise>
                                <tr>
                                    <td colspan="2" class="text-center">None</td>
                                </tr>
                            </xsl:otherwise>
                        </xsl:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='reqTechInfo']">
        <tr>
            <xsl:call-template name="add-applic-attribute"/>
            <td>
                <xsl:value-of select="@reqTechInfoCategory"/>
            </td>
            <td>
                <xsl:apply-templates/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="*[local-name()='safetyRqmts']">
        <xsl:call-template name="add-applic-attribute"/>
        <xsl:apply-templates/>
    </xsl:template>
    <!-- === CORRECTED SECTION FOR WARNING, CAUTION (NOTE is handled by old template) === -->
    <xsl:template match="*[local-name()='warning']">
        <div class="row">
            <xsl:call-template name="add-applic-attribute"/>
            <div class="col-12">
                <table class="warningBackground">
                    <tbody>
                        <tr>
                            <td class="text-center p-4">
                                <table class="warningBody">
                                    <tbody>
                                        <tr>
                                            <td class="text-center font-weight-bold p-4">
                                                <div class="h6 font-weight-bold">WARNING</div>
                                                <div class="font-weight-bold">
                                                    <p class="pb-0 m-0">
                                                        <xsl:apply-templates select="*[local-name()='warningAndCautionPara']"/>
                                                    </p>
                                                </div>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='caution']">
        <div class="row">
            <xsl:call-template name="add-applic-attribute"/>
            <div class="col-12">
                <table class="cautionBackground">
                    <tbody>
                        <tr>
                            <td class="text-center p-4">
                                <table class="cautionBody">
                                    <tbody>
                                        <tr>
                                            <td class="text-center font-weight-bold p-4">
                                                <div class="h6 font-weight-bold">CAUTION</div>
                                                <div class="font-weight-bold">
                                                    <p class="pb-0 m-0">
                                                        <xsl:apply-templates select="*[local-name()='warningAndCautionPara']"/>
                                                    </p>
                                                </div>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='warningAndCautionPara'] | *[local-name()='notePara']">
        <p class="mb-0">
            <xsl:call-template name="add-applic-attribute"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="*[local-name()='dmRef']">
        <xsl:variable name="ref-dmc_raw">
            <xsl:apply-templates select="*[local-name()='dmRefIdent']/*[local-name()='dmCode']" mode="text"/>
        </xsl:variable>
        <xsl:variable name="ref-dmc" select="normalize-space($ref-dmc_raw)"/>
        <xsl:variable name="ref-filename" select="concat(translate($ref-dmc, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'), '.htm')"/>
        <a href="{$ref-filename}">
            <xsl:value-of select="translate($ref-dmc, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
        </a>
    </xsl:template>
    <xsl:template match="*[local-name()='dmRef']" mode="refs">
        <tr>
            <xsl:call-template name="add-applic-attribute"/>
            <td>
                <xsl:apply-templates select="."/>
            </td>
            <td>
                <xsl:choose>
                    <xsl:when test="*[local-name()='dmRefAddressItems']/*[local-name()='dmTitle']/descendant-or-self::*/text()[normalize-space()]">
                        <xsl:apply-templates select="*[local-name()='dmRefAddressItems']/*[local-name()='dmTitle']/node()"/>
                    </xsl:when>
                    <xsl:otherwise>N/A</xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="*[local-name()='externalPubRef']" mode="refs">
        <tr>
            <xsl:call-template name="add-applic-attribute"/>
            <td>
                <xsl:choose>
                    <xsl:when test="@xlink:href">
                        <a href="{@xlink:href}" target="_blank" rel="noopener noreferrer">
                            <xsl:value-of select="*[local-name()='externalPubRefIdent']/*[local-name()='externalPubCode']"/>
                            <xsl:text> (External)</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="*[local-name()='externalPubRefIdent']/*[local-name()='externalPubCode']"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <td>
                <xsl:choose>
                    <xsl:when test="*[local-name()='externalPubRefAddressItems']/*[local-name()='externalPubTitle']/descendant-or-self::*/text()[normalize-space()]">
                        <xsl:apply-templates select="*[local-name()='externalPubRefAddressItems']/*[local-name()='externalPubTitle']/node()"/>
                    </xsl:when>
                    <xsl:when test="*[local-name()='externalPubRefIdent']/*[local-name()='externalPubTitle']/descendant-or-self::*/text()[normalize-space()]">
                        <xsl:apply-templates select="*[local-name()='externalPubRefIdent']/*[local-name()='externalPubTitle']/node()"/>
                    </xsl:when>
                    <xsl:otherwise>N/A</xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="*[local-name()='pmRef']" mode="refs">
        <tr>
            <xsl:call-template name="add-applic-attribute"/>
            <td>
                <xsl:apply-templates select="."/>
            </td>
            <td>
                <xsl:text>Publication Module</xsl:text>
                <xsl:if test="*[local-name()='pmRefAddressItems']/*[local-name()='pmTitle']/descendant-or-self::*/text()[normalize-space()]">
                    <xsl:text> – </xsl:text>
                    <xsl:apply-templates select="*[local-name()='pmRefAddressItems']/*[local-name()='pmTitle']/node()"/>
                </xsl:if>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="*[local-name()='dmIdent'] | *[local-name()='dmRefIdent']">
        <xsl:apply-templates select="*[local-name()='dmCode']" mode="text"/>
    </xsl:template>
    <xsl:template match="*[local-name()='dmCode']" mode="text">
        <xsl:value-of select="@modelIdentCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@systemDiffCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@systemCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@subSystemCode"/>
        <xsl:value-of select="@subSubSystemCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@assyCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@disassyCode"/>
        <xsl:value-of select="@disassyCodeVariant"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@infoCode"/>
        <xsl:value-of select="@infoCodeVariant"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@itemLocationCode"/>
    </xsl:template>
    <xsl:template match="*[local-name()='dmCode']">
        <xsl:value-of select="@modelIdentCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@systemDiffCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@systemCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@subSystemCode"/>
        <xsl:value-of select="@subSubSystemCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@assyCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@disassyCode"/>
        <xsl:value-of select="@disassyCodeVariant"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@infoCode"/>
        <xsl:value-of select="@infoCodeVariant"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@itemLocationCode"/>
    </xsl:template>
    <xsl:template match="*[local-name()='issueDate']">
        <xsl:value-of select="@year"/>-
        <xsl:value-of select="@month"/>-
        <xsl:value-of select="@day"/>
    </xsl:template>
    <xsl:template match="*[local-name()='language']">
        <xsl:value-of select="@languageIsoCode"/>/
        <xsl:value-of select="@countryIsoCode"/>
    </xsl:template>
    <xsl:template match="*[local-name()='dmTitle']">
        <xsl:apply-templates select="*[local-name()='techName']"/>
        <xsl:if test="*[local-name()='infoName']"> –
            <xsl:apply-templates select="*[local-name()='infoName']"/>
        </xsl:if>
        <xsl:if test="*[local-name()='infoNameVariant']"> (
            <xsl:apply-templates select="*[local-name()='infoNameVariant']"/>)
        </xsl:if>
    </xsl:template>
    <xsl:template match="*[local-name()='techName'] | *[local-name()='infoName'] | *[local-name()='infoNameVariant']">
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="*[local-name()='responsiblePartnerCompany'] | *[local-name()='originator']">
        <xsl:value-of select="*[local-name()='enterpriseName']"/> (
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
    <xsl:template match="text()[normalize-space(.) = '']"/>
</xsl:stylesheet>
<!-- java -jar saxon9he.jar -s:PMC-P15B-1671Y-00001.xml -xsl:PMtoTOC.xsl -o:Toc.js -->