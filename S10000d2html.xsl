<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="1.0">
    <xsl:output method="html" doctype-system="about:legacy-compat" encoding="UTF-8" indent="yes"/>
    <!-- Parameters (keeping existing ones) -->
    <xsl:param name="numbered-titles" select="false()"/>
    <xsl:param name="show-references-table" select="true()"/>
    <!-- Defaulting to true as it's in the example -->
    <xsl:param name="reference-resolver" select="false()"/>
    <xsl:param name="extra-header-tags" select="false()"/>
    <xsl:param name="bootstrap-css-path" select="'xignal/assets/bootstrap/4.6.2/css/bootstrap.min.css'"/>
    <!-- Make paths parameters -->
    <xsl:param name="custom-css-path" select="'../main.css'"/>
    <!-- Your custom CSS if needed -->
    <xsl:param name="jquery-js-path" select="'xignal/assets/jquery/3.7.1/jquery-slim-min.js'"/>
    <xsl:param name="bootstrap-js-path" select="'xignal/assets/bootstrap/4.6.2/js/bootstrap.min.js'"/>
    <!-- Root Template -->
    <xsl:template match="/">
        <html lang="en">
            <!-- Assuming English, adjust if needed -->
            <!-- <xsl:apply-templates select="//identAndStatusSection" mode="head"/> -->
            <xsl:apply-templates select="//content"/>
        </html>
    </xsl:template>
    <!-- HEAD Section Generation -->
    <!-- <xsl:template match="identAndStatusSection" mode="head"> -->
    <!-- <head>
            <meta charset="UTF-8"/>
            <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
            <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
            <title>
                <xsl:apply-templates select="dmAddress/dmAddressItems/dmTitle"/>
            </title> -->
    <!-- Add other meta tags as needed from original XSLT or example -->
    <!-- <meta name="author">
                <xsl:attribute name="content">
                    <xsl:apply-templates select="dmStatus/originator"/>
                </xsl:attribute>
            </meta>
            <meta name="date">
                <xsl:attribute name="content">
                    <xsl:apply-templates select="dmAddress/dmAddressItems/issueDate"/>
                </xsl:attribute>
            </meta>
            <xsl:if test="$extra-header-tags">
                <xsl:copy-of select="$extra-header-tags"/>
            </xsl:if> -->
    <!-- CSS Links -->
    <!-- <link rel="stylesheet" href="{$bootstrap-css-path}" />
            <xsl:if test="$custom-css-path != ''">
                <link rel="stylesheet" href="{$custom-css-path}" />
            </xsl:if> -->
    <!-- Add any other required head elements -->
    <!-- </head> -->
    <!-- </xsl:template> -->
    <!-- BODY Content Generation -->
    <xsl:template match="content">
        <body>
            <!-- Title Bar -->
            <xsl:apply-templates select="ancestor::dmodule/identAndStatusSection" mode="title-bar"/>
            <!-- ID Status Button -->
            <div class="container-fluid idstatusTitle">
                <button type="button" class="btn btn-xignal mt-1" data-toggle="modal" data-target="#idstatusModal">View Identification and Status</button>
            </div>
            <!-- ID Status Modal -->
            <xsl:apply-templates select="ancestor::dmodule/identAndStatusSection" mode="idStatusModal"/>
            <!-- References Section (conditionally) -->
            <xsl:if test="$show-references-table and (refs/dmRef or refs/externalPubRef)">
                <div class="container-fluid">
                    <h2 id="tblReferences">References</h2>
                    <xsl:apply-templates select="refs" mode="table"/>
                </div>
            </xsl:if>
            <xsl:if test="$show-references-table and not(refs/dmRef or refs/externalPubRef)">
                <div class="container-fluid">
                    <h2 id="tblReferences">References</h2>
                    <table class="tblReferences mb-5 table table-borderless">
                        <caption class="italic spaceAfter-sm">Table 1  References</caption>
                        <!-- Adjust Table numbering if needed -->
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
            <!-- Main Content Area -->
            <div class="container-fluid">
                <!-- Process description or procedure elements -->
                <xsl:apply-templates select="description | procedure"/>
            </div>
            <!-- Footer Scripts -->
            <script src="{$jquery-js-path}"></script>
            <script src="{$bootstrap-js-path}"></script>
        </body>
    </xsl:template>
    <!-- Title Bar Template -->
    <xsl:template match="identAndStatusSection" mode="title-bar">
        <div class="dmTitleBar">
            <!-- Added missing class attribute -->
            <h1 class="text-center pt-[1rem] pb-[1rem] pl-8 pr-16">
                <xsl:apply-templates select="dmAddress/dmAddressItems/dmTitle"/>
            </h1>
        </div>
    </xsl:template>
    <!-- ID Status Modal Template -->
    <xsl:template match="identAndStatusSection" mode="idStatusModal">
        <div class="modal fade" id="idstatusModal" aria-hidden="true">
            <div class="modal-dialog modal-xl modal-dialog-scrollable">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="staticBackdropLabel">Data Module Identification and Status</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">X</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="container-fluid">
                            <!-- DMC -->
                            <div class="row pb-2">
                                <div class="col-sm-2 font-weight-bold">DMC:</div>
                                <div class="col-sm-10">
                                    <xsl:apply-templates select="dmAddress/dmAddressItems/dmIdent"/>
                                </div>
                            </div>
                            <!-- Language -->
                            <div class="row pb-2">
                                <div class="col-sm-2 font-weight-bold">Language:</div>
                                <div class="col-sm-10">
                                    <xsl:apply-templates select="dmAddress/dmAddressItems/language"/>
                                </div>
                            </div>
                            <!-- Issue No. -->
                            <div class="row pb-2">
                                <div class="col-sm-2 font-weight-bold">Issue No.:</div>
                                <div class="col-sm-10">
                                    <xsl:value-of select="dmAddress/dmAddressItems/issueInfo/@issueNumber"/>
                                </div>
                            </div>
                            <!-- Issue Date -->
                            <div class="row pb-2">
                                <div class="col-sm-2 font-weight-bold">Issue Date:</div>
                                <div class="col-sm-10">
                                    <xsl:apply-templates select="dmAddress/dmAddressItems/issueDate"/>
                                </div>
                            </div>
                            <!-- Title -->
                            <div class="row pb-2">
                                <div class="col-sm-2 font-weight-bold">Title:</div>
                                <div class="col-sm-10">
                                    <xsl:apply-templates select="dmAddress/dmAddressItems/dmTitle"/>
                                </div>
                            </div>
                            <!-- Security -->
                            <div class="row pb-2">
                                <div class="col-sm-2 font-weight-bold">Security Classification:</div>
                                <div class="col-sm-10">
                                    <xsl:choose>
                                        <xsl:when test="dmStatus/security/@securityClassification">
                                            <xsl:call-template name="decodeSecurity">
                                                <xsl:with-param name="code" select="dmStatus/security/@securityClassification"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>Unclassified</xsl:otherwise>
                                        <!-- Default -->
                                    </xsl:choose>
                                </div>
                            </div>
                            <!-- RPC -->
                            <div class="row pb-2">
                                <div class="col-lg-2 font-weight-bold">Responsible partner company:</div>
                                <div class="col-sm-10">
                                    <xsl:apply-templates select="dmStatus/responsiblePartnerCompany"/>
                                </div>
                            </div>
                            <!-- Originator -->
                            <div class="row pb-2">
                                <div class="col-sm-2 font-weight-bold">Originator:</div>
                                <div class="col-sm-10">
                                    <xsl:apply-templates select="dmStatus/originator"/>
                                </div>
                            </div>
                            <!-- Applicability -->
                            <div class="row pb-2">
                                <div class="col-sm-2 font-weight-bold">Applicability:</div>
                                <!-- Applicability requires parsing applicability elements, complex logic omitted for brevity -->
                                <div class="col-sm-10">
                                    <xsl:apply-templates select="dmStatus/applicability"/>
                                </div>
                            </div>
                            <!-- Brex -->
                            <div class="row pb-2">
                                <div class="col-sm-2 font-weight-bold">Brex data module reference:</div>
                                <div class="col-sm-10">
                                    <xsl:apply-templates select="dmStatus/brexDmRef/dmRef"/>
                                </div>
                            </div>
                            <!-- QA -->
                            <div class="row pb-2">
                                <div class="col-sm-2 font-weight-bold">QA:</div>
                                <div class="col-sm-10">
                                    <xsl:apply-templates select="dmStatus/qualityAssurance/verification"/>
                                </div>
                            </div>
                            <!-- Add other fields as needed -->
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
    <!-- Template for Applicability (placeholder) -->
    <xsl:template match="applicability">
        <!-- Basic display - real implementation needs parsing display text or complex structure -->
        <xsl:value-of select="."/>
    </xsl:template>
    <!-- Template for QA Verification -->
    <xsl:template match="verification">
        <p class="m-0 p-0">
            <xsl:value-of select="@verificationType"/>
            <!-- e.g., First verification -->
            <xsl:text> </xsl:text>
            <xsl:value-of select="."/>
            <!-- e.g., Cleared Table Top -->
        </p>
    </xsl:template>
    <!-- Template for Security Classification Decoding (Example) -->
    <xsl:template name="decodeSecurity">
        <xsl:param name="code"/>
        <xsl:choose>
            <xsl:when test="$code = '01'">Unclassified</xsl:when>
            <xsl:when test="$code = '02'">Restricted</xsl:when>
            <xsl:when test="$code = '03'">Confidential</xsl:when>
            <!-- Matched example -->
            <xsl:when test="$code = '04'">Secret</xsl:when>
            <xsl:when test="$code = '05'">Top Secret</xsl:when>
            <xsl:otherwise>Unknown (
                <xsl:value-of select="$code"/>)
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- References Table Generation -->
    <xsl:template match="refs" mode="table">
        <table class="tblReferences mb-5 table table-borderless">
            <caption class="italic spaceAfter-sm">Table 1 References</caption>
            <!-- Static Table 1, adjust if dynamic numbering needed -->
            <thead>
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
    <!-- Template for top-level description/procedure -->
    <xsl:template match="description | procedure">
        <!-- Optional: Add a wrapper div if needed -->
        <xsl:apply-templates select="title"/>
        <xsl:apply-templates select="levelledPara | para | figure | note | seqList | randomList | table"/>
        <!-- Process direct children -->
    </xsl:template>
    <!-- Template for top-level description/procedure title -->
    <xsl:template match="description/title | procedure/title">
        <div class="row">
            <div class="col-md-12 mainDoctypeTitle">
                <h2 id="{generate-id()}">
                    <xsl:apply-templates/>
                </h2>
            </div>
        </div>
    </xsl:template>

    <!-- Revised levelledPara Template -->
    <xsl:template match="levelledPara">
        <div class="row">
            <div class="col-12">
                <div class="levelOneBar">
                    <!-- Assuming all are levelOne for this example -->
                    <div class="d-flex">
                        <!-- Bullet/Numbering for first level -->
                        <xsl:if test="count(ancestor::levelledPara) = 0 and count(ancestor::procedure/levelledPara) > 0 or count(ancestor::description/levelledPara) > 0">
                            <div class="roundedBullet">
                                <xsl:number level="single" count="levelledPara"/>
                            </div>
                        </xsl:if>
                        <!-- Title -->
                        <xsl:if test="title">
                            <div class="para0Title">
                                <span class="text-decoration-underline">
                                    <!-- Assuming title is always underlined -->
                                    <xsl:apply-templates select="title" mode="inline"/>
                                </span>
                            </div>
                        </xsl:if>
                    </div>
                    <!-- Content (Paragraphs, Lists, Figures within the levelledPara) -->
                    <!-- Indented content needs to be handled within child templates like para, seqList -->
                    <xsl:apply-templates select="para | figure | note | seqList | randomList | table | levelledPara"/>
                </div>
            </div>
        </div>
    </xsl:template>
    <!-- Handling title within levelledPara (called above) -->
    <xsl:template match="levelledPara/title" mode="inline">
        <xsl:apply-templates/>
    </xsl:template>
    <!-- Revised para Template -->
    <xsl:template match="para">
        <!-- Check if inside a structure that provides the outer divs -->
        <xsl:choose>
            <xsl:when test="parent::levelledPara | parent::note">
                <div class="d-flex">
                    <div class="para0Indent"/>
                    <div class="para0TextDescription flex-grow-1 pb-3">
                        <span class="m-0 pb-2">
                            <xsl:apply-templates/>
                        </span>
                    </div>
                </div>
            </xsl:when>
            <!-- Case 2: Para inside a listItem or table entry (gets just the content span) -->
            <xsl:when test="parent::listItem | parent::entry">
                <span class="m-0 pb-2">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="parent::listItemDefinition">
                <!-- Specific case for definition list -->
                <dd>
                    <!-- Use standard dd -->
                    <xsl:apply-templates/>
                </dd>
            </xsl:when>
            <xsl:otherwise>
                <!-- Fallback or context for para directly under description/procedure? -->
                <div class="row">
                    <div class="col-12">
                        <p class="pb-3">
                            <!-- Added pb-3 for spacing consistency -->
                            <xsl:apply-templates/>
                        </p>
                    </div>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Sequential List (Ordered List) -->
    <xsl:template match="seqList">
        <div class="d-flex">
            <div class="para0Indent"/>
            <div class="para0TextDescription flex-grow-1 pb-3">
                <ol>
                    <xsl:apply-templates select="listItem"/>
                </ol>
            </div>
        </div>
    </xsl:template>
    <!-- Random List (Unordered List) - Adapt if needed -->
    <xsl:template match="randomList">
        <div class="d-flex">
            <div class="para0Indent"/>
            <div class="para0TextDescription flex-grow-1 pb-3">
                <ul>
                    <xsl:apply-templates select="listItem"/>
                </ul>
            </div>
        </div>
    </xsl:template>
    <!-- List Item -->
    <xsl:template match="listItem">
        <!-- Adjust class based on whether it's the last item? pb-0 vs pb-2 -->
        <li class="m-0 pb-2">
            <!-- Defaulting to pb-2 -->
            <xsl:if test="position() = last()">
                <xsl:attribute name="class">m-0 pb-0</xsl:attribute>
            </xsl:if>
            <!-- Content might be simple text or include para -->
            <xsl:choose>
                <xsl:when test="para">
                    <!-- If list item contains paragraphs, apply templates to let para template handle structure -->
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Otherwise, wrap directly -->
                    <span class="m-0 p-0">
                        <xsl:apply-templates/>
                    </span>
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>
    <!-- Note Template -->
    <xsl:template match="note">
        <div class="d-flex">
            <div class="para0Indent"/>
            <div class="para0TextDescription flex-grow-1 pb-3">
                <b>Note
                    <xsl:number level="any" count="note" from="content"/>
                </b>
                <!-- Simple Note numbering -->
                <br/>
                <div style="padding-left:40px;">
                    <!-- Inline style as per example -->
                    <xsl:apply-templates/>
                    <!-- Process content (likely paras) inside note -->
                </div>
            </div>
        </div>
    </xsl:template>
    <!-- Emphasis Template (for bold) -->
    <xsl:template match="emphasis">
        <!-- Check emphasis type if available, default to bold -->
        <span class="font-weight-bold">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- Add template for underline if needed, e.g., match="underline" or emphasis[@emphasisType='typeX'] -->
    <xsl:template match="underline">
        <!-- Hypothetical element -->
        <span class="text-decoration-underline">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- Table Template -->
    <!-- NEW Table Processing Templates -->
    <xsl:template match="table">
        <div class="d-flex">
            <div class="para0Indent"/>
            <div class="para0TextDescription flex-grow-1 pb-3">
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
                <table border="0" cellspacing="0" cellpadding="4" width="100%">
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
    <!-- Figure Template -->
    <xsl:template match="figure">
        <div class="row">
            <div class="col-12">
                <div class="levelOneBar">
                    <div class="d-flex">
                        <div class="para0Indent"/>
                        <div class="para0TextDescription flex-grow-1 pb-3">
                            <!-- Figure Caption -->
                            <xsl:if test="title">
                                <div class="text-center font-italic mt-2 mb-1" id="fig-{generate-id(.)}">
                                     Fig
                                    <xsl:number level="any" count="figure" from="content"/>
                                    <xsl:apply-templates select="title" mode="inline"/>
                                </div>
                            </xsl:if>
                            <!-- Figure Graphic and Controls -->
                            <div class="text-center">
                                <div class="container-fluid m-0 pb-4">
                                    <xsl:apply-templates select="graphic"/>
                                    <br/>
                                    <button class="btn btn-sm btn-secondary mb-1 icn-link">View</button>
                                    <!-- Add JS later if needed -->
                                    <br/>
                                    <div class="icn">
                                        <xsl:value-of select="graphic/@infoEntityIdent"/>
                                    </div>
                                </div>
                            </div>
                            <div class="text-center"/>
                            <!-- Empty div from example -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
    <!-- Graphic Template (within Figure) -->
    <xsl:template match="graphic">
        <img class="fig">
            <xsl:attribute name="src">
                <!-- Basic assumption: path relative to output HTML or absolute -->
                <xsl:value-of select="concat('illustrations/', @infoEntityIdent, '.png')"/>
                <!-- Adjust path/extension as needed -->
            </xsl:attribute>
            <xsl:attribute name="alt">
                <xsl:value-of select="../title"/>
                <!-- Use figure title as alt text -->
            </xsl:attribute>
        </img>
    </xsl:template>
    <!-- Title (inline mode for figures/captions) -->
    <xsl:template match="title" mode="inline">
        <xsl:apply-templates/>
    </xsl:template>
    <!-- Internal Reference -->
    <xsl:template match="internalRef">
        <xsl:variable name="target-id" select="@internalRefId"/>
        <!-- Find target anywhere in the document -->
        <xsl:variable name="target" select="key('ids', $target-id)"/>
        <xsl:variable name="target-node-id">
            <xsl:call-template name="object-id">
                <xsl:with-param name="object" select="$target"/>
            </xsl:call-template>
        </xsl:variable>
        <a href="#{$target-node-id}">
            <xsl:choose>
                <!-- Specific text based on target type -->
                <xsl:when test="name($target)='figure'">
                    <xsl:text>Fig </xsl:text>
                    <xsl:number level="any" count="figure" from="content" format="1"/>
                </xsl:when>
                <xsl:when test="name($target)='table'">
                    <xsl:text>Table </xsl:text>
                    <xsl:number level="any" count="table" from="content" format="1"/>
                </xsl:when>
                <xsl:when test="name($target)='levelledPara'">
                    <xsl:text>Para </xsl:text>
                    <!-- Or Section? -->
                    <xsl:number level="multiple" count="levelledPara" from="description|procedure" format="1.1"/>
                    <!-- Adjust numbering format -->
                </xsl:when>
                <xsl:when test="name($target)='proceduralStep'">
                    <!-- Assuming proceduralStep element -->
                    <xsl:text>Step </xsl:text>
                    <xsl:number level="any" count="proceduralStep" from="procedure" format="a."/>
                    <!-- Example step numbering -->
                </xsl:when>
                <!-- Fallback to provided text or target title -->
                <xsl:when test="normalize-space(.)">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:when test="$target/title">
                    <xsl:apply-templates select="$target/title"/>
                </xsl:when>
                <!-- Generic fallback -->
                <xsl:otherwise>
                    <xsl:text>Ref (</xsl:text>
                    <xsl:value-of select="$target-id"/>
                    <xsl:text>)</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </a>
    </xsl:template>
    <!-- Key for ID lookup -->
    <xsl:key name="ids" match="*[@id]" use="@id"/>
    <!-- Keep other utility templates like dmCode, issueDate, dmTitle etc. as they format text data -->
    <!-- Add/Modify templates for dmRef, externalPubRef formatting if needed -->
    <xsl:template match="dmRef">
        <xsl:variable name="ref-dmc">
            <xsl:apply-templates select="dmRefIdent/dmCode"/>
        </xsl:variable>
        <xsl:variable name="ref-filename">
            <xsl:value-of select="$ref-dmc"/>
            <xsl:text>.htm</xsl:text>
            <!-- Assuming HTML output for refs -->
        </xsl:variable>
        <a href="{$ref-filename}">
            <xsl:value-of select="$ref-dmc"/>
        </a>
    </xsl:template>
    <xsl:template match="dmRef" mode="refs">
        <tr>
            <td>
                <xsl:apply-templates select="."/>
                <!-- Uses the default dmRef template for the link -->
            </td>
            <td>
                <xsl:apply-templates select="dmRefAddressItems/dmTitle"/>
            </td>
        </tr>
    </xsl:template>
    <!-- Keep other existing templates unless they conflict -->
    <xsl:template match="dmIdent | dmRefIdent">
        <xsl:apply-templates select="dmCode"/>
    </xsl:template>
    <xsl:template match="dmCode">
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
    <xsl:template match="issueDate">
        <xsl:value-of select="@year"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@month"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@day"/>
    </xsl:template>
    <xsl:template match="language">
        <xsl:value-of select="@languageIsoCode"/>
        <xsl:text>/</xsl:text>
        <!-- Using / separator like example -->
        <xsl:value-of select="@countryIsoCode"/>
    </xsl:template>
    <xsl:template match="dmTitle">
        <xsl:apply-templates select="techName"/>
        <xsl:if test="infoName">
            <xsl:text> – </xsl:text>
            <!-- Using en-dash like example -->
            <xsl:apply-templates select="infoName"/>
        </xsl:if>
        <xsl:if test="infoNameVariant">
            <xsl:text> (</xsl:text>
            <xsl:apply-templates select="infoNameVariant"/>
            <xsl:text>)</xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="responsiblePartnerCompany | originator">
        <xsl:apply-templates select="enterpriseName | enterprise/@enterpriseCode"/>
        <!-- Allow code as fallback -->
    </xsl:template>
    <xsl:template match="enterpriseName">
        <xsl:value-of select="."/>
    </xsl:template>
    <!-- Utility: Generate ID (simple version) -->
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
    <!-- Template to ignore text nodes that are only whitespace between block elements -->
    <xsl:template match="text()[normalize-space(.) = '']"/>
    <!-- Default template to copy elements not specifically handled (useful for debugging) -->
    <!--
     <xsl:template match="*">
         <xsl:copy>
             <xsl:copy-of select="@*"/>
             <xsl:apply-templates/>
         </xsl:copy>
     </xsl:template>
     -->
</xsl:stylesheet>