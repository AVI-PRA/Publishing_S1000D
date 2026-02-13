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
    <!-- Key for ID lookup -->
    <xsl:key name="ids" match="*[@id]" use="@id"/>
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
                <style>
                    .prelim-req-table { margin-bottom: 1.5rem; }
                    .prelim-req-table th, .prelim-req-table td { vertical-align: top; padding: 0.5rem; }
                    .fault-procedure-list { margin-top: 2rem; padding-left: 1rem; border-left: 3px solid #eee; }
                    .fault-procedure-list ol { list-style-type: none; counter-reset: main-step-counter; padding-left: 0; }
                    .fault-procedure-list ol > li { counter-increment: main-step-counter; margin-bottom: 1rem; }
                    .fault-procedure-list ol > li::before { content: counter(main-step-counter) ". "; font-weight: bold; margin-right: 0.5em; }
                    .fault-step-content { display: inline; }
                    .fault-answers { list-style-type: none; padding-left: 2em; margin-top: 0.5rem; counter-reset: sub-step-counter; }
                    .fault-answers li { counter-increment: sub-step-counter; margin-bottom: 0.25rem; }
                    .fault-answers li::before { content: counter(main-step-counter) "." counter(sub-step-counter) ". "; font-weight: bold; margin-right: 0.5em; }
                    .fault-closeout-link { display: block; font-style: italic; color: #555; padding-left: 2.2em; margin-top: 0.5em; }
                    [id] { scroll-margin-top: 70px; }
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
    <!-- Page Setup -->
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
            <xsl:variable name="all_references_in_dm"
                  select="ancestor::dmodule[1]//(dmRef | externalPubRef | pmRef)[ancestor::content or ancestor::refs]"/>
            <xsl:if test="$show-references-table">
                <div class="container-fluid">
                    <h2 id="tblReferences" class="ps-Title_font ps-Title_2 ps-Title_color">References</h2>
                    <table class="tblReferences mb-5 table table-borderless prelim-req-table s1000d-table">
                        <caption class="italic spaceAfter-sm s1000d-table-title">Table 1  References</caption>
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
        </body>
    </xsl:template>
    <!-- Content processing -->
    <xsl:template match="content">
        <div class="container-fluid">
            <xsl:apply-templates select="description | procedure | faultIsolation | preliminaryRqmts"/>
        </div>
        <xsl:if test="ancestor::dmodule and not(ancestor::dmodule/identAndStatusSection)">
            <script src="{$jquery-js-path}"></script>
            <script src="{$bootstrap-js-path}"></script>
        </xsl:if>
    </xsl:template>
    <!-- ====== PRELIMINARY REQUIREMENTS TEMPLATES (CORRECTED) ====== -->
    <xsl:template match="preliminaryRqmts">
        <div class="preliminary-requirements-section mt-4 mb-4 p-3 border rounded">
            <h3 id="{@id}" class="mb-3">Preliminary Requirements</h3>
            <xsl:apply-templates select="reqCondGroup"/>
            <xsl:apply-templates select="reqPersons"/>
            <xsl:apply-templates select="reqTechInfoGroup"/>
            <xsl:apply-templates select="reqSupportEquips"/>
            <xsl:apply-templates select="reqSupplies"/>
            <xsl:apply-templates select="reqSpares"/>
            <xsl:apply-templates select="reqSafety"/>
        </div>
    </xsl:template>
    <xsl:template match="reqCondGroup">
        <div class="req-cond-group mt-3">
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
                        <xsl:when test="reqCondPm | reqCondDm | reqCondNoRef">
                            <xsl:apply-templates select="reqCondPm | reqCondDm | reqCondNoRef"/>
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
    <xsl:template match="reqPersons">
        <div class="req-persons mt-3">
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
                        <xsl:when test="person">
                            <xsl:apply-templates select="person"/>
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
    <!-- MODIFIED: The parent template now just creates the heading and applies templates. -->
    <xsl:template match="reqSupportEquips | reqSupplies | reqSpares">
        <div class="mt-3">
            <h4 id="{@id}" class="mb-2">
                <xsl:choose>
                    <xsl:when test="self::reqSupportEquips">Support Equipment</xsl:when>
                    <xsl:when test="self::reqSupplies">Consumables, materials and expendables</xsl:when>
                    <xsl:when test="self::reqSpares">Spares</xsl:when>
                </xsl:choose>
            </h4>
            <!-- This will either call the template for the group, or the template for an empty section -->
            <xsl:apply-templates select="*"/>
        </div>
    </xsl:template>
    <!-- MODIFIED: This is the main template that builds the table when data exists -->
    <xsl:template match="supportEquipDescrGroup | supplyDescrGroup | spareDescrGroup">
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
                <xsl:choose>
                    <xsl:when test="supportEquipDescr | supplyDescr | spareDescr">
                        <xsl:apply-templates select="supportEquipDescr | supplyDescr | spareDescr"/>
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
    <!-- ADDED: A new template to handle cases where the section is empty (e.g., contains <noSupportEquips/>) -->
    <xsl:template match="reqSupportEquips/*[not(self::supportEquipDescrGroup)] | 
                         reqSupplies/*[not(self::supplyDescrGroup)] | 
                         reqSpares/*[not(self::spareDescrGroup)]">
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
    <xsl:template match="reqSafety">
        <div class="req-safety mt-3">
            <h4 id="{@id}" class="mb-2">Safety Requirements</h4>
            <xsl:choose>
                <xsl:when test="safetyRqmts/*">
                    <xsl:apply-templates select="safetyRqmts"/>
                </xsl:when>
                <xsl:otherwise>
                    <p>None</p>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    <!-- ... (rest of the file is unchanged) ... -->
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
    <xsl:template name="generate-title-bar">
        <xsl:param name="identSection"/>
        <div class="dmTitleBar bg-light p-3 mb-3">
            <h1 class="text-center">
                <xsl:apply-templates select="$identSection/dmAddress/dmAddressItems/dmTitle"/>
            </h1>
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
    <xsl:template match="refs" mode="table">
        <table class="tblReferences mb-5 table table-sm table-striped prelim-req-table">
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
    <xsl:template match="description | procedure">
        <xsl:apply-templates select="title"/>
        <xsl:apply-templates select="preliminaryRqmts | mainProcedure | closeRqmts"/>
        <xsl:apply-templates select="levelledPara | para | figure | note | sequentialList | randomList | table"/>
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
            <h3 id="{@id}" class="mb-3">Closeout Requirements</h3>
            <xsl:apply-templates select="reqCondGroup"/>
        </div>
    </xsl:template>
    <xsl:template match="description/title | procedure/title">
        <div class="row">
            <div class="col-md-12 mainDoctypeTitle">
                <h2 id="{generate-id()}" class="mt-4 mb-3">
                    <xsl:apply-templates/>
                </h2>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="levelledPara">
        <div class="row">
            <div class="col-12">
                <div class="levelOneBar mb-3 p-3 border rounded">
                    <div class="d-flex align-items-center mb-2">
                        <xsl:if test="count(ancestor::levelledPara) = 0 and (ancestor::procedure or ancestor::description)">
                            <div class="roundedBullet mr-2" style="display:inline-block; width: 25px; height: 25px; background-color: #007bff; color: white; text-align: center; line-height: 25px; border-radius: 50%;">
                                <xsl:number level="single" count="levelledPara[ancestor::procedure or ancestor::description]"/>
                            </div>
                        </xsl:if>
                        <xsl:if test="title">
                            <h4 class="para0Title mb-0">
                                <span class="text-decoration-underline">
                                    <xsl:apply-templates select="title" mode="inline"/>
                                </span>
                            </h4>
                        </xsl:if>
                    </div>
                    <div class="pl-4">
                        <xsl:apply-templates select="para | figure | note | sequentialList | randomList | table | levelledPara"/>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="levelledPara/title" mode="inline">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="para">
        <xsl:choose>
            <xsl:when test="parent::levelledPara | parent::note[not(ancestor::safetyRqmts)]">
                <p class="pb-2">
                    <xsl:apply-templates/>
                </p>
            </xsl:when>
            <xsl:when test="parent::listItem | parent::entry">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="parent::listItemDefinition">
                <dd>
                    <xsl:apply-templates/>
                </dd>
            </xsl:when>
            <xsl:when test="parent::proceduralStep and count(preceding-sibling::*) = 0 and count(following-sibling::*) = 0">
                <p class="mb-0">
                    <xsl:apply-templates/>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <p class="pb-3">
                    <xsl:apply-templates/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="faultIsolation">
        <xsl:apply-templates select="faultDescrGroup"/>
        <xsl:apply-templates select="faultIsolationProcedure"/>
    </xsl:template>
    <xsl:template match="faultDescrGroup">
        <div class="fault-codes-section mt-4">
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
                        <xsl:when test="faultDescr">
                            <xsl:apply-templates select="faultDescr"/>
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
    <xsl:template match="faultDescr">
        <tr>
            <td>
                <xsl:value-of select="faultCode"/>
            </td>
            <td>
                <xsl:apply-templates select="faultDescrText/simplePara/node()"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="faultIsolationProcedure | isolationProcedure">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="isolationMainProcedure">
        <div class="fault-procedure-list">
            <h3 class="mt-4 mb-3">Fault Isolation Procedure</h3>
            <ol>
                <xsl:apply-templates select="isolationStep | isolationProcedureEnd"/>
            </ol>
        </div>
    </xsl:template>
    <xsl:template match="isolationStep">
        <li id="{@id}">
            <div class="fault-step-content">
                <xsl:if test="action">
                    <xsl:apply-templates select="action"/>
                    <br/>
                </xsl:if>
                <xsl:apply-templates select="isolationStepQuestion"/>
                <xsl:apply-templates select="isolationStepAnswer"/>
            </div>
        </li>
    </xsl:template>
    <xsl:template match="isolationProcedureEnd">
        <li id="{@id}">
            <div class="fault-step-content">
                <xsl:apply-templates select="action"/>
            </div>
            <div class="fault-closeout-link">
                <xsl:variable name="closeoutId" select="ancestor::*[self::faultIsolation or self::isolationProcedure][1]/closeRqmts/@id"/>
                <xsl:if test="$closeoutId">
                    <a href="#{$closeoutId}">Go to Requirements after job completion.</a>
                </xsl:if>
            </div>
        </li>
    </xsl:template>
    <xsl:template match="action | isolationStepQuestion">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="isolationStepAnswer">
        <ul class="fault-answers">
            <xsl:apply-templates select="yesNoAnswer/*"/>
        </ul>
    </xsl:template>
    <xsl:template match="yesAnswer | noAnswer">
        <li>
            <xsl:variable name="targetId" select="@nextActionRefId"/>
            <xsl:variable name="targetNode" select="key('ids', $targetId)"/>
            <xsl:variable name="targetNumber" select="count($targetNode/preceding-sibling::*[self::isolationStep or self::isolationProcedureEnd]) + 1"/>
            <xsl:choose>
                <xsl:when test="self::yesAnswer">Yes: </xsl:when>
                <xsl:otherwise>No: </xsl:otherwise>
            </xsl:choose>
            <a href="#{$targetId}">Go to Step
                <xsl:value-of select="$targetNumber"/>.
            </a>
        </li>
    </xsl:template>
    <xsl:template match="reqCond/text() | reqCond/internalRef">
        <xsl:apply-imports/>
    </xsl:template>
    <xsl:template match="sequentialList">
        <ol class="pl-4 mb-2">
            <xsl:apply-templates select="listItem"/>
        </ol>
    </xsl:template>
    <xsl:template match="randomList">
        <ul class="pl-4 mb-2">
            <xsl:apply-templates select="listItem"/>
        </ul>
    </xsl:template>
    <xsl:template match="listItem">
        <li class="mb-1">
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    <xsl:template match="note[not(ancestor::safetyRqmts)]">
        <div class="alert alert-secondary mt-2">
            <strong>Note
                <xsl:number level="any" count="note[not(ancestor::safetyRqmts)]" from="content | procedure | description | mainProcedure"/>:
            </strong>
            <xsl:apply-templates select="para | sequentialList | randomList | node()[self::text() and normalize-space()]"/>
        </div>
    </xsl:template>
    <xsl:template match="emphasis">
        <span class="font-weight-bold">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="underline">
        <span class="text-decoration-underline">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="table">
        <div class="table-responsive mb-3">
            <xsl:if test="title">
                <h5 class="text-center font-italic mt-2 mb-1" id="tbl-{generate-id(.)}">Table
                    <xsl:number level="any" count="table" from="content | procedure | description | mainProcedure"/>:
                    <xsl:apply-templates select="title" mode="inline"/>
                </h5>
            </xsl:if>
            <table class="table table-bordered table-sm prelim-req-table">
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
        <xsl:if test="@cols">
            <colgroup>
                <xsl:for-each select="1 to @cols">
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
                    <xsl:value-of select="@morerows + 1"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:variable name="colspecs" select="ancestor::tgroup[1]/colspec"/>
            <xsl:variable name="start-col-num">
                <xsl:for-each select="$colspecs">
                    <xsl:if test="@colname = current()/../@namest">
                        <xsl:value-of select="position()"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="end-col-num">
                <xsl:for-each select="$colspecs">
                    <xsl:if test="@colname = current()/../@nameend">
                        <xsl:value-of select="position()"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <xsl:if test="@namest and @nameend and $start-col-num and $end-col-num and $end-col-num > $start-col-num">
                <xsl:attribute name="colspan">
                    <xsl:value-of select="$end-col-num - $start-col-num + 1"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </td>
    </xsl:template>
    <xsl:template match="figure">
        <div class="figure text-center my-3 p-3 border rounded container-fluid" id="{@id}">
            <xsl:if test="title">
                <h5 class="figure-caption font-italic mb-2" id="fig-{generate-id(.)}"> Fig
                    <xsl:number level="any" count="figure" from="content | procedure | description | mainProcedure"/>:
                    <xsl:apply-templates select="title" mode="inline"/>
                </h5>
            </xsl:if>
            <xsl:apply-templates select="graphic"/>
            <xsl:if test="graphic/@infoEntityIdent">
                <!-- <div class="mt-2 text-center"> -->
                <!-- <div class="container-fluid"> -->
                <!-- <object type="image/svg+xml">
                            <xsl:attribute name="id">
                                <xsl:value-of select="graphic/@infoEntityIdent"/>
                            </xsl:attribute>
                            <xsl:attribute name="data">
                                <xsl:value-of select="concat('illustrations/${', graphic/@infoEntityIdent, '}')" />
                            </xsl:attribute>
                        </object> -->
                <br/>
                <button class="btn btn-sm btn-outline-secondary icn-link" type="button">View</button>
                <br/>
                <div class="icn">
                    <xsl:value-of select="graphic/@infoEntityIdent"/>
                </div>
                <!-- </div> -->
                <!-- </div> -->
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
                        <xsl:value-of select="../title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@infoEntityIdent"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </img>
        <!-- <object type="image/svg+xml">
            <xsl:attribute name="id">
                <xsl:value-of select="@infoEntityIdent"/>
            </xsl:attribute>
            <xsl:attribute name="data">
                <xsl:value-of select="concat('illustrations/', @infoEntityIdent, '.png')"/>
            </xsl:attribute>
        </object> -->
    </xsl:template>
    <xsl:template match="title" mode="inline">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="internalRef">
        <xsl:variable name="target-id" select="@internalRefId"/>
        <xsl:variable name="target" select="key('ids', $target-id)"/>
        <a href="#{$target-id}">
            <xsl:choose>
                <xsl:when test="name($target)='figure'">
                    <xsl:text>Fig </xsl:text>
                    <xsl:variable name="fig_scope" select="$target/ancestor::content[1] | $target/ancestor::procedure[1] | $target/ancestor::description[1] | $target/ancestor::mainProcedure[1]"/>
                    <xsl:number format="1" value="count($target/preceding-sibling::figure[count(.|$fig_scope/descendant::figure) = count($fig_scope/descendant::figure)]) + 1"/>
                </xsl:when>
                <xsl:when test="name($target)='table'">
                    <xsl:text>Table </xsl:text>
                    <xsl:variable name="tbl_scope" select="$target/ancestor::content[1] | $target/ancestor::procedure[1] | $target/ancestor::description[1] | $target/ancestor::mainProcedure[1]"/>
                    <xsl:number format="1" value="count($target/preceding-sibling::table[count(.|$tbl_scope/descendant::table) = count($tbl_scope/descendant::table)]) + 1"/>
                </xsl:when>
                <xsl:when test="name($target)='levelledPara'">
                    <xsl:text>Para </xsl:text>
                    <xsl:variable name="lp_scope" select="$target/ancestor::procedure[1] | $target/ancestor::description[1]"/>
                    <xsl:number format="1" value="count($target/preceding-sibling::levelledPara[count(.|$lp_scope/levelledPara) = count($lp_scope/levelledPara)]) + 1"/>
                </xsl:when>
                <xsl:when test="name($target)='proceduralStep'">
                    <xsl:text>Step </xsl:text>(
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
    <xsl:template match="pmRef">
        <xsl:variable name="pmIdent" select="pmRefIdent"/>
        <xsl:variable name="pmCodeEl" select="$pmIdent/pmCode"/>
        <xsl:variable name="langEl" select="$pmIdent/language"/>
        <xsl:variable name="issueEl" select="$pmIdent/issueInfo"/>
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
    <xsl:template match="reqTechInfoGroup">
        <div class="req-tech-info-group mt-3">
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
                        <xsl:when test="reqTechInfo">
                            <xsl:apply-templates select="reqTechInfo"/>
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
    <!-- MODIFIED: Renders a single row for the Required Technical Information table -->
    <xsl:template match="reqTechInfo">
        <tr>
            <td>
                <xsl:value-of select="@reqTechInfoCategory"/>
            </td>
            <td>
                <xsl:apply-templates select="dmRef"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="safetyRqmts">
        <xsl:apply-templates select="warning | caution | note"/>
    </xsl:template>
    <xsl:template match="warning">
        <div class="alert alert-danger mt-2" role="alert">
            <h5 class="alert-heading">WARNING</h5>
            <xsl:apply-templates select="warningAndCautionPara"/>
        </div>
    </xsl:template>
    <xsl:template match="caution">
        <div class="alert alert-warning mt-2" role="alert">
            <h5 class="alert-heading">CAUTION</h5>
            <xsl:apply-templates select="warningAndCautionPara"/>
        </div>
    </xsl:template>
    <xsl:template match="safetyRqmts/note">
        <div class="alert alert-info mt-2" role="alert">
            <h5 class="alert-heading">NOTE</h5>
            <xsl:apply-templates select="notePara"/>
        </div>
    </xsl:template>
    <xsl:template match="warningAndCautionPara | notePara">
        <p class="mb-0">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="dmRef">
        <xsl:variable name="ref-dmc">
            <xsl:apply-templates select="dmRefIdent/dmCode" mode="text"/>
        </xsl:variable>
        <xsl:variable name="ref-filename">
            <xsl:value-of select="translate($ref-dmc, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>.html
        </xsl:variable>
        <a href="{$ref-filename}">
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
                    <xsl:when test="dmRefAddressItems/dmTitle/descendant-or-self::*/text()[normalize-space()]">
                        <xsl:apply-templates select="dmRefAddressItems/dmTitle/node()"/>
                    </xsl:when>
                    <xsl:otherwise>N/A</xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="externalPubRef" mode="refs">
        <tr>
            <td>
                <xsl:choose>
                    <xsl:when test="@xlink:href">
                        <a href="{@xlink:href}" target="_blank" rel="noopener noreferrer">
                            <xsl:value-of select="externalPubRefIdent/externalPubCode"/>
                            <xsl:text> (External)</xsl:text>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="externalPubRefIdent/externalPubCode"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <td>
                <xsl:choose>
                    <xsl:when test="externalPubRefAddressItems/externalPubTitle/descendant-or-self::*/text()[normalize-space()]">
                        <xsl:apply-templates select="externalPubRefAddressItems/externalPubTitle/node()"/>
                    </xsl:when>
                    <xsl:when test="externalPubRefIdent/externalPubTitle/descendant-or-self::*/text()[normalize-space()]">
                        <xsl:apply-templates select="externalPubRefIdent/externalPubTitle/node()"/>
                    </xsl:when>
                    <xsl:otherwise>N/A</xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="pmRef" mode="refs">
        <tr>
            <td>
                <xsl:apply-templates select="."/>
            </td>
            <td>
                <xsl:text>Publication Module</xsl:text>
                <xsl:if test="pmRefAddressItems/pmTitle/descendant-or-self::*/text()[normalize-space()]">
                    <xsl:text> – </xsl:text>
                    <xsl:apply-templates select="pmRefAddressItems/pmTitle/node()"/>
                </xsl:if>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="dmIdent | dmRefIdent">
        <xsl:apply-templates select="dmCode" mode="text"/>
    </xsl:template>
    <xsl:template match="dmCode" mode="text">
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
    <xsl:template match="text()[normalize-space(.) = '']"/>
</xsl:stylesheet>