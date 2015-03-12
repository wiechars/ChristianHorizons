<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeBehind="Default.aspx.cs" Inherits="ChristianHorizons._Default" %>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
</asp:Content>
<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
    <h2>Christian Horizons Non Financial Data
    </h2>
    <label for="startDate">Date :</label>
    <input runat="server" name="startDate" id="startDate" class="date-picker" />
    <table id="activeIndividuals">
    </table>
    <div id="activeIndividualsPager">
    </div>
    <!--<button id="sendAll" type="submit">Save</button>-->
    <div style="height: 50px;"></div>
    <table id="exitedIndividuals">
    </table>
    <div id="exitedIndividualsPager">
    </div>


    <script type="text/javascript">
        var lastsel2

        var grid = $("#activeIndividuals");
        grid.jqGrid({
            url: GetUrl("Yes"),
            datatype: "json",
            colNames: ['ID', 'NonFinancialID', 'Individual', 'Days of Support', 'Level of Support', 'On Hold Days', 'Ministry Detail Code', 'Language Served', 'Comments'],
            colModel: [
                        { name: 'IndividID', index: 'IndividID', width: 30, stype: 'text', sortable: true, editable: true, editoptions: { disabled: true } },
                        { name: 'NonFinancialID', index: 'NonFinancialID', width: 30, stype: 'text', sortable: true, editable: true, editoptions: { disabled: true } },
                        { name: 'Name', index: 'NameVisible', width: 140, stype: 'text', sortable: true, editable: true, editoptions: { disabled: true } },
                        { name: 'DaysOfSupport', index: 'DaysOfSupport', width: 100, stype: 'text', sortable: true, editable: true },
                        {
                            name: 'LevelOfSupport', index: 'LevelOfSupport', width: 100, editable: true,
                            edittype: "select", editoptions: { value: "0-8 Hrs/Day:0-8 Hrs/Day;8-24 Hrs/Day:8-24 Hrs/Day;Once/Week:Once/Week;Once/Month:Once/Month" },
                            cellattr: function () { return ' title="This field is only required for the following Ministry Detail Codes: 9112, 9131, 8871."'; }
                        },
                        {
                            name: 'OnHoldDays', index: 'OnHoldDays', width: 100, editable: true,
                            cellattr: function () { return ' title="This field is only required for the following Ministry Detail Codes: 8847"'; }

                        },
                        { name: 'MinistryDetailCode', index: 'MinistryDetailCode', width: 250, editable: true, edittype: "select", editoptions: { value: "9112:9112;9131:9131;8871:8871;" } },
                         {
                             name: 'Language', index: 'LanguageVisible', width: 100, align: "right", editable: true, editoptions: { disabled: true },
                             // edittype: "select", editoptions: { value: "English:English;French:French" },
                             cellattr: function () { return ' title="This field is specified in Individuals Information. Please navigate to the individual’s page should an update be necessary."'; }
                         },
                        { name: 'Comments', index: 'Comments', width: 100, sortable: false, editable: true }
            ],
            loadComplete: function () {
                var ids = grid.jqGrid('getDataIDs');
                //for (var i = 0; i < ids.length; i++) {
                $.each(ids, function (i, row) {
                    var id = ids[i];
                    if (grid.jqGrid('getCell', id, 'MinistryDetailCode') === '9112') {
                        //grid.jqGrid('setCell', id, 'LevelOfSupport', '', 'not-editable-cell');


                    }
                });
            },

            ///*************** check out cellsubmit property for edits **************/
            rowNum: 10,
            height: '100%',
            mtype: 'GET',
            loadonce: true,
            rowList: [10, 20, 30],
            pager: '#activeIndividualsPager',
            sortname: '_id',
            viewrecords: true,
            sortorder: 'desc',
            caption: "Current Individuals",
            editurl: GetUrl("Yes")
        });
        $('#activeIndividuals').jqGrid('navGrid', '#activeIndividualsPager',
           {
               edit: false,
               add: false,
               del: false,
               search: false
           }
        ); $("#activeIndividuals").jqGrid('inlineNav', '#activeIndividualsPager',
                    {
                        edit: true,
                        editicon: "ui-icon-pencil",
                        add: false,
                        addicon: "ui-icon-plus",
                        save: true,
                        saveicon: "ui-icon-disk",
                        cancel: true,
                        cancelicon: "ui-icon-cancel",

                        editParams: {
                            keys: false,
                            oneditfunc: null,
                            successfunc: function (val) {
                                if (val.responseText != "") {
                                    alert(val.responseText);
                                    $(this).jqGrid('setGridParam', { datatype: 'json' }).trigger('reloadGrid');
                                }
                            },
                            url: null,
                            extraparam: {
                                EmpId: function () {
                                    var sel_id = $('#activeIndividuals').jqGrid('getGridParam', 'selrow');
                                    var value = $('#activeIndividuals').jqGrid('getCell', sel_id, '_id');
                                    return value;
                                }
                            },
                            aftersavefunc: null,
                            errorfunc: null,
                            afterrestorefunc: null,
                            restoreAfterError: true,
                            mtype: "POST"
                        },
                        addParams: {
                            useDefValues: true,
                            addRowParams: {
                                keys: true,
                                extraparam: {},
                                // oneditfunc: function () { alert(); },
                                successfunc: function (val) {
                                    if (val.responseText != "") {
                                        alert(val.responseText);
                                        $(this).jqGrid('setGridParam', { datatype: 'json' }).trigger('reloadGrid');
                                    }
                                }
                            }
                        }
                    }
        );


        function GetUrl(active) {
            var url = " http://localhost:44930/NonFinancialHandler.ashx";
            var queryString = "?date=".concat($('#MainContent_startDate').val());
            queryString = queryString.concat("&active=" + active);
            return (url.concat(queryString));
        };

        $(function () {
            $('.date-picker').datepicker({
                changeMonth: true,
                changeYear: true,
                showButtonPanel: true,
                dateFormat: 'MM yy',
                monthNames: ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                             "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
                onClose: function (dateText, inst) {
                    var month = $("#ui-datepicker-div .ui-datepicker-month :selected").val();
                    var year = $("#ui-datepicker-div .ui-datepicker-year :selected").val();
                    $(this).datepicker('setDate', new Date(year, month, 1));
                    $(this).change();
                }
            });
        });


        //Update Grid when date changes.
        $('#MainContent_startDate').change(function () {
            $("#activeIndividuals").setGridParam({ url: GetUrl("Yes"), editurl: GetUrl("Yes"), datatype: 'json', page: 1 }).trigger('reloadGrid');
        });

        $("#activeIndividuals tr").click(function () {
            jQuery("#activeIndividuals ").jqGrid('editGridRow', rowid, properties);
        });


        /****************************************************/
        /*************** Exited Individuals *****************/
        /****************************************************/
        var lastExitedRowSelected
        jQuery("#exitedIndividuals").jqGrid({
            url: GetUrl("No"),
            datatype: "json",
            colNames: ['Individual', 'Days of Support', 'Level of Support', 'On Hold Days', 'Ministry Detail Code', 'Language Served', 'Comments'],
            colModel: [
                        { name: 'Name', index: 'Name', width: 100, stype: 'text', sortable: true, editable: true },
                        { name: 'DaysOfSupport', index: 'DaysOfSupport', width: 100, stype: 'text', sortable: true, editable: true },
                        {
                            name: 'LevelOfSupport', index: 'LevelOfSupport', width: 100, editable: true,
                            edittype: "select", editoptions: { value: "0-8 Hrs/Day:0-8 Hrs/Day;8-24 Hrs/Day:8-24 Hrs/Day;Once/Week:Once/Week;Once/Month:Once/Month" },
                            cellattr: function () { return ' title="This field is only required for the following Ministry Detail Codes: 9112, 9131, 8871."'; }

                        },
                        {
                            name: 'OnHoldDays', index: 'OnHoldDays', width: 100, editable: true,
                            cellattr: function () { return ' title="This field is only required for the following Ministry Detail Codes: 8847"'; }

                        },
                        { name: 'MinistryDetailCode', index: 'MinistryDetailCode', width: 250, editable: true, edittype: "select", editoptions: { value: "FE:FedEx;IN:InTime;TN:TNT;AR:ARAMEX" } },
                        {
                            name: 'Language', index: 'Language', width: 100, align: "right", editable: true,
                            edittype: "select", editoptions: { value: "English:English;French:French" },
                            cellattr: function () { return ' title="This field is specified in Individuals Information. Please navigate to the individual’s page should an update be necessary."'; }
                        },
                        { name: 'Comments', index: 'Comments', width: 100, sortable: false, editable: true }
            ],
            onSelectRow: function (id) {
                if (id && id !== lastExitedRowSelected) {
                    jQuery('#exitedIndividuals').restoreRow(lastExitedRowSelected);
                    jQuery('#exitedIndividuals').editRow(id, true);
                    lastExitedRowSelected = id;
                }
            },
            ///*************** check out cellsubmit property for edits **************/
            rowNum: 10,
            height: '100%',
            mtype: 'GET',
            loadonce: true,
            rowList: [10, 20, 30],
            pager: '#exitedIndividualsPager',
            sortname: '_id',
            viewrecords: true,
            sortorder: 'desc',
            caption: "Exited Individuals (within last four months)",
            editurl: GetUrl("No")
        });


        $('#exitedIndividuals').jqGrid('navGrid', '#exitedIndividualsPager',
                {
                    edit: true,
                    editicon: "ui-icon-pencil",
                    add: false,
                    addicon: "ui-icon-plus",
                    save: true,
                    saveicon: "ui-icon-disk",
                    cancel: true,
                    cancelicon: "ui-icon-cancel"
                },
                   {
                       closeOnEscape: true, //Closes the popup on pressing escape key
                       reloadAfterSubmit: true,
                       drag: true,
                       afterSubmit: function (response, postdata) {
                           if (response.responseText == "") {

                               $(this).jqGrid('setGridParam', { datatype: 'json' }).trigger('reloadGrid'); //Reloads the grid after edit
                               return [true, '']
                           }
                           else {
                               $(this).jqGrid('setGridParam', { datatype: 'json' }).trigger('reloadGrid'); //Reloads the grid after edit
                               return [false, response.responseText]//Captures and displays the response text on th Edit window
                           }
                       },
                       editData: {
                           EmpId: function () {
                               var sel_id = $('#exitedIndividuals').jqGrid('getGridParam', 'selrow');
                               var value = $('#exitedIndividuals').jqGrid('getCell', sel_id, '_id');
                               return value;
                           }
                       }
                   },
                   {
                       closeAfterAdd: true, //Closes the add window after add
                       afterSubmit: function (response, postdata) {
                           if (response.responseText == "") {

                               $(this).jqGrid('setGridParam', { datatype: 'json' }).trigger('reloadGrid')//Reloads the grid after Add
                               return [true, '']
                           }
                           else {
                               $(this).jqGrid('setGridParam', { datatype: 'json' }).trigger('reloadGrid')//Reloads the grid after Add
                               return [false, response.responseText]
                           }
                       }
                   },
                   {   //DELETE
                       closeOnEscape: true,
                       closeAfterDelete: true,
                       reloadAfterSubmit: true,
                       closeOnEscape: true,
                       drag: true,
                       afterSubmit: function (response, postdata) {
                           if (response.responseText == "") {

                               $("#exitedIndividuals").trigger("reloadGrid", [{ current: true }]);
                               return [false, response.responseText]
                           }
                           else {
                               $(this).jqGrid('setGridParam', { datatype: 'json' }).trigger('reloadGrid');
                               return [true, response.responseText]
                           }
                       },
                       delData: {
                           EmpId: function () {
                               var sel_id = $('#exitedIndividuals').jqGrid('getGridParam', 'selrow');
                               var value = $('#exitedIndividuals').jqGrid('getCell', sel_id, '_id');
                               return value;
                           }
                       }
                   },
                   {//SEARCH
                       closeOnEscape: true

                   }


       );





        //Update Grid when date changes.
        $('#MainContent_startDate').change(function () {
            $("#exitedIndividuals").setGridParam({ url: GetUrl("No"), editurl: GetUrl("No"), datatype: 'json', page: 1 }).trigger('reloadGrid');
        });

        $("#exitedIndividuals tr").click(function () {
            jQuery("#exitedIndividuals ").jqGrid('editGridRow', rowid, properties);
        });

        var localGridData = $("#activeIndividuals").jqGrid('getGridParam', 'data');
        var idsToDataIndex = $("#activeIndividuals").jqGrid('getGridParam', '_index');

        var sendData = function (data) {
            var dataToSend = JSON.stringify(data);
            alert("The following data are sending to the server:\n" + dataToSend);
            $.ajax({
                type: "POST",
                url: GetUrl("Yes"),
                dataType: "json",
                data: dataToSend,
                contentType: "application/json; charset=utf-8",
                success: function (response, textStatus, jqXHR) {
                    // display an success message if needed
                    alert("success");
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    // display an error message in any way
                    alert("error");
                }
            });
        };



        $("#sendAll").click(function () {
            var localGridData = grid.jqGrid('getGridParam', 'data');
            sendData(localGridData);
        });

        var grid = $("#activeIndividuals"),
        decodeErrorMessage = function (jqXHR, textStatus, errorThrown) {
            var html, errorInfo, i, errorText = textStatus + '\n<br />' + errorThrown;
            if (jqXHR.responseText.charAt(0) === '[') {
                try {
                    errorInfo = $.parseJSON(jqXHR.responseText);
                    errorText = "";
                    for (i = 0; i < errorInfo.length; i++) {
                        if (errorText.length !== 0) {
                            errorText += "<hr/>";
                        }
                        errorText += errorInfo[i].Source + ": " + errorInfo[i].Message;
                    }
                }
                catch (e) { }
            } else {
                html = /<body.*?>([\s\S]*)<\/body>/i.exec(jqXHR.responseText);
                if (html !== null && html.length > 1) {
                    errorText = html[1];
                }
            }
            return errorText;
        },
    sendData = function (data) {
        var dataToSend = JSON.stringify(data);
        alert("The following data are sending to the server:\n" + dataToSend);
        $.ajax({
            type: "POST",
            url: GetUrl("Yes"),
            dataType: "json",
            data: dataToSend,
            contentType: "application/json; charset=utf-8",
            success: function (response, textStatus, jqXHR) {
                // remove error div if exist
                $('#' + grid[0].id + '_err').remove();
                alert("success");
            },
            error: function (jqXHR, textStatus, errorThrown) {
                // remove error div if exist
                $('#' + grid[0].id + '_err').remove();
                // insert div with the error description before the grid
                grid.closest('div.ui-jqgrid').before(
                    '<div id="' + grid[0].id + '_err" style="max-width:' + grid[0].style.width +
                    ';"><div class="ui-state-error ui-corner-all" style="padding:0.7em;float:left;"><span class="ui-icon ui-icon-alert" ' +
                    'style="float:left; margin-right: .3em;"></span><span style="clear:left">' +
                    decodeErrorMessage(jqXHR, textStatus, errorThrown) + '</span></div><div style="clear:left"/></div>');
            }
        });
    };

    </script>
</asp:Content>
