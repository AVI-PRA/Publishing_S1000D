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
    <!-- Helper templates for applicability -->
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
    <!-- Page Setup -->
    <xsl:template match="*[local-name()='identAndStatusSection']" mode="page-setup">
        <xsl:call-template name="generate-title-bar">
            <xsl:with-param name="identSection" select="."/>
        </xsl:call-template>
        <div class="container-fluid my-3 p-3 border rounded bg-light">
            <div class="row align-items-center">
                <div class="col-md-auto">
                    <label for="applic-selector" class="font-weight-bold mb-0">Applicability Filter:</label>
                </div>
                <div class="col-md-5">
                    <select id="applic-selector" class="form-control">
                        <option value="all">Show All Applicable Content</option>
                        <xsl:for-each select="*[local-name()='dmStatus']/*[local-name()='applic']">
                            <option>
                                <xsl:attribute name="value">
                                    <xsl:call-template name="generate-applic-string">
                                        <xsl:with-param name="applicNode" select="."/>
                                    </xsl:call-template>
                                </xsl:attribute>
                                <xsl:call-template name="get-product-display-text">
                                    <xsl:with-param name="applicNode" select="."/>
                                </xsl:call-template>
                            </option>
                        </xsl:for-each>
                    </select>
                </div>
            </div>
        </div>
        <div class="container-fluid idstatusTitle">
            <button type="button" class="btn btn-primary mt-1 mb-3" data-toggle="modal" data-target="#idstatusModal">View Identification and Status</button>
        </div>
        <xsl:call-template name="generate-id-status-modal">
            <xsl:with-param name="identSection" select="."/>
        </xsl:call-template>
        <xsl:variable name="all_references_in_dm" select="ancestor::*[local-name()='dmodule'][1]//*[local-name()='dmRef' or local-name()='externalPubRef' or local-name()='pmRef'][ancestor::*[local-name()='content'] or ancestor::*[local-name()='refs']]"/>
        <xsl:if test="$show-references-table">
            <div class="container-fluid">
                <h2 id="tblReferences" class="ps-Title_font ps-Title_2 ps-Title_color">References</h2>
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
        </xsl:if>
    </xsl:template>
    <!-- Content processing -->
    <xsl:template match="*[local-name()='content']">
        <div class="container-fluid">
            <xsl:apply-templates select="*[local-name()='description'] | *[local-name()='procedure'] | *[local-name()='faultIsolation'] | *[local-name()='preliminaryRqmts']"/>
        </div>
    </xsl:template>
    <!-- All original templates below, modified to be namespace-agnostic -->
    <xsl:template match="*[local-name()='description']">
        <xsl:call-template name="add-applic-attribute"/>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="*[local-name()='procedure']">
        <xsl:call-template name="add-applic-attribute"/>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="*[local-name()='preliminaryRqmts']">
        <div class="preliminary-requirements-section mt-4 mb-4 p-3 border rounded">
            <xsl:call-template name="add-applic-attribute"/>
            <h3 id="{@id}" class="mb-3">Preliminary Requirements</h3>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='reqCondGroup']">
        <div class="req-cond-group mt-3">
            <xsl:call-template name="add-applic-attribute"/>
            <h4 class="mb-2">Required Conditions</h4>
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
    </xsl:template>
    <xsl:template match="*[local-name()='reqPersons']">
        <div class="req-persons mt-3">
            <xsl:call-template name="add-applic-attribute"/>
            <h4 class="mb-2">Required Personnel</h4>
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
    </xsl:template>
    <xsl:template match="*[local-name()='reqSupportEquips'] | *[local-name()='reqSupplies'] | *[local-name()='reqSpares']">
        <div class="mt-3">
            <xsl:call-template name="add-applic-attribute"/>
            <h4 id="{@id}" class="mb-2">
                <xsl:choose>
                    <xsl:when test="local-name()='reqSupportEquips'">Support Equipment</xsl:when>
                    <xsl:when test="local-name()='reqSupplies'">Consumables, materials and expendables</xsl:when>
                    <xsl:when test="local-name()='reqSpares'">Spares</xsl:when>
                </xsl:choose>
            </h4>
            <xsl:apply-templates select="*"/>
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
        <div class="req-safety mt-3">
            <xsl:call-template name="add-applic-attribute"/>
            <h4 id="{@id}" class="mb-2">Safety Requirements</h4>
            <xsl:choose>
                <xsl:when test="*[local-name()='safetyRqmts']/*">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <p>None</p>
                </xsl:otherwise>
            </xsl:choose>
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
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    </div>
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
        <div class="main-procedure-section mt-4">
            <xsl:call-template name="add-applic-attribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='proceduralStep']">
        <div class="procedural-step mb-3 p-3 border rounded" id="{@id}">
            <xsl:call-template name="add-applic-attribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='closeRqmts']">
        <div class="closeout-requirements-section mt-4">
            <xsl:call-template name="add-applic-attribute"/>
            <h3 id="{@id}" class="mb-3">Closeout Requirements</h3>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='description']/*[local-name()='title'] | *[local-name()='procedure']/*[local-name()='title']">
        <div class="row">
            <div class="col-md-12 mainDoctypeTitle">
                <h2 id="{generate-id()}" class="mt-4 mb-3">
                    <xsl:apply-templates/>
                </h2>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='levelledPara']">
        <div class="row">
            <div class="col-12">
                <div class="levelOneBar mb-3 p-3 border rounded">
                    <xsl:call-template name="add-applic-attribute"/>
                    <div class="d-flex align-items-center mb-2">
                        <xsl:if test="count(ancestor::*[local-name()='levelledPara']) = 0 and (ancestor::*[local-name()='procedure'] or ancestor::*[local-name()='description'])">
                            <div class="roundedBullet mr-2" style="display:inline-block; width: 25px; height: 25px; background-color: #007bff; color: white; text-align: center; line-height: 25px; border-radius: 50%;">
                                <xsl:number level="single" count="*[local-name()='levelledPara'][ancestor::*[local-name()='procedure'] or ancestor::*[local-name()='description']]"/>
                            </div>
                        </xsl:if>
                        <xsl:if test="*[local-name()='title']">
                            <h4 class="para0Title mb-0">
                                <span class="text-decoration-underline">
                                    <xsl:apply-templates select="*[local-name()='title']" mode="inline"/>
                                </span>
                            </h4>
                        </xsl:if>
                    </div>
                    <div class="pl-4">
                        <xsl:apply-templates/>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
    <!-- <xsl:template match="*[local-name()='levelledPara']/*[local-name()='title']" mode="inline">
        <xsl:apply-templates/>
    </xsl:template> -->
    <xsl:template match="*[local-name()='para']">
        <p>
            <xsl:call-template name="add-applic-attribute"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="*[local-name()='faultIsolation']">
        <div class="s1k:fault-isolation">
            <xsl:call-template name="add-applic-attribute"/>
            <xsl:apply-templates/>
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
    <xsl:template match="*[local-name()='sequentialList']">
        <ol class="pl-4 mb-2">
            <xsl:call-template name="add-applic-attribute"/>
            <xsl:apply-templates/>
        </ol>
    </xsl:template>
    <xsl:template match="*[local-name()='randomList']">
        <ul class="pl-4 mb-2">
            <xsl:call-template name="add-applic-attribute"/>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    <xsl:template match="*[local-name()='listItem']">
        <li class="mb-1">
            <xsl:call-template name="add-applic-attribute"/>
            <xsl:apply-templates/>
        </li>
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
    <xsl:template match="*[local-name()='table']">
        <div class="table-responsive mb-3">
            <xsl:call-template name="add-applic-attribute"/>
            <xsl:if test="*[local-name()='title']">
                <h5 class="text-center font-italic mt-2 mb-1" id="tbl-{generate-id(.)}">Table
                    <xsl:number level="any" count="*[local-name()='table']" from="*[local-name()='content'] | *[local-name()='procedure'] | *[local-name()='description'] | *[local-name()='mainProcedure']"/>:
                    <xsl:apply-templates select="*[local-name()='title']" mode="inline"/>
                </h5>
            </xsl:if>
            <table class="table table-bordered table-sm prelim-req-table">
                <xsl:apply-templates/>
            </table>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='tgroup']">
        <xsl:if test="@cols">
            <colgroup>
                <xsl:for-each select="1 to @cols">
                    <col/>
                </xsl:for-each>
            </colgroup>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="*[local-name()='thead']">
        <thead class="thead-light">
            <xsl:apply-templates/>
        </thead>
    </xsl:template>
    <xsl:template match="*[local-name()='tbody']">
        <tbody>
            <xsl:apply-templates/>
        </tbody>
    </xsl:template>
    <xsl:template match="*[local-name()='row']">
        <tr>
            <xsl:call-template name="add-applic-attribute"/>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>
    <xsl:template match="*[local-name()='entry']">
        <td>
            <xsl:call-template name="add-applic-attribute"/>
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
                    <xsl:value-of select="@morerows + 1"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </td>
    </xsl:template>
    <xsl:template match="*[local-name()='figure']">
        <div class="figure text-center my-3 p-3 border rounded container-fluid" id="{@id}">
            <xsl:call-template name="add-applic-attribute"/>
            <xsl:if test="*[local-name()='title']">
                <h5 class="figure-caption font-italic mb-2" id="fig-{generate-id(.)}"> Fig
                    <xsl:number level="any" count="*[local-name()='figure']" from="*[local-name()='content'] | *[local-name()='procedure'] | *[local-name()='description'] | *[local-name()='mainProcedure']"/>:
                    <xsl:apply-templates select="*[local-name()='title']" mode="inline"/>
                </h5>
            </xsl:if>
            <xsl:apply-templates/>
            <xsl:if test="*[local-name()='graphic']/@infoEntityIdent">
                <br/>
                <button class="btn btn-sm btn-outline-secondary icn-link" type="button">View</button>
                <br/>
                <div class="icn">
                    <xsl:value-of select="*[local-name()='graphic']/@infoEntityIdent"/>
                </div>
            </xsl:if>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='graphic']">
        <img class="img-fluid fig">
            <xsl:attribute name="src">
                <xsl:value-of select="concat('illustrations/', @infoEntityIdent, '.png')"/>
            </xsl:attribute>
            <xsl:attribute name="alt">
                <xsl:choose>
                    <xsl:when test="../.[local-name()='title']">
                        <xsl:value-of select="../.[local-name()='title']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@infoEntityIdent"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </img>
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
                    <xsl:text>Fig </xsl:text>
                    <xsl:variable name="fig_scope" select="$target/ancestor::*[local-name()='content'][1] | $target/ancestor::*[local-name()='procedure'][1] | $target/ancestor::*[local-name()='description'][1] | $target/ancestor::*[local-name()='mainProcedure'][1]"/>
                    <xsl:number format="1" value="count($target/preceding-sibling::*[local-name()='figure'][count(.|$fig_scope/descendant::*[local-name()='figure']) = count($fig_scope/descendant::*[local-name()='figure'])]) + 1"/>
                </xsl:when>
                <xsl:when test="local-name($target)='table'">
                    <xsl:text>Table </xsl:text>
                    <xsl:variable name="tbl_scope" select="$target/ancestor::*[local-name()='content'][1] | $target/ancestor::*[local-name()='procedure'][1] | $target/ancestor::*[local-name()='description'][1] | $target/ancestor::*[local-name()='mainProcedure'][1]"/>
                    <xsl:number format="1" value="count($target/preceding-sibling::*[local-name()='table'][count(.|$tbl_scope/descendant::*[local-name()='table']) = count($tbl_scope/descendant::*[local-name()='table'])]) + 1"/>
                </xsl:when>
                <xsl:when test="local-name($target)='levelledPara'">
                    <xsl:text>Para </xsl:text>
                    <xsl:variable name="lp_scope" select="$target/ancestor::*[local-name()='procedure'][1] | $target/ancestor::*[local-name()='description'][1]"/>
                    <xsl:number format="1" value="count($target/preceding-sibling::*[local-name()='levelledPara'][count(.|$lp_scope/*[local-name()='levelledPara']) = count($lp_scope/*[local-name()='levelledPara'])]) + 1"/>
                </xsl:when>
                <xsl:when test="local-name($target)='proceduralStep'">
                    <xsl:text>Step </xsl:text>(
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
        <div class="req-tech-info-group mt-3">
            <xsl:call-template name="add-applic-attribute"/>
            <h4 class="mb-2">Required Technical Information</h4>
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
    <!-- === CORRECTED SECTION FOR WARNING, CAUTION, NOTE === -->
    <xsl:template match="*[local-name()='warning']">
        <div class="alert alert-danger mt-2" role="alert">
            <xsl:call-template name="add-applic-attribute"/>
            <h5 class="alert-heading">WARNING</h5>
            <xsl:apply-templates select="*[local-name()='warningAndCautionPara']"/>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='caution']">
        <div class="alert alert-warning mt-2" role="alert">
            <xsl:call-template name="add-applic-attribute"/>
            <h5 class="alert-heading">CAUTION</h5>
            <xsl:apply-templates select="*[local-name()='warningAndCautionPara']"/>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='note']">
        <div class="alert alert-info mt-2" role="alert">
            <xsl:call-template name="add-applic-attribute"/>
            <h5 class="alert-heading">NOTE</h5>
            <xsl:apply-templates select="*[local-name()='notePara']"/>
        </div>
    </xsl:template>
    <xsl:template match="*[local-name()='warningAndCautionPara'] | *[local-name()='notePara']">
        <p class="mb-0">
            <xsl:call-template name="add-applic-attribute"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="*[local-name()='dmRef']">
        <xsl:variable name="ref-dmc">
            <xsl:apply-templates select="*[local-name()='dmRefIdent']/*[local-name()='dmCode']" mode="text"/>
        </xsl:variable>
        <xsl:variable name="ref-filename">
            <xsl:value-of select="translate($ref-dmc, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>.html
        </xsl:variable>
        <a href="{$ref-filename}">
            <xsl:value-of select="$ref-dmc"/>
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
    <xsl:template match="*[local-name()='dmCode']">
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