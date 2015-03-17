<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeBehind="Default.aspx.cs" Inherits="NonFinancialData._Default" %>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
</asp:Content>
<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
    <h2>Christian Horizons Non Financial Data
    </h2>
    <h3>Please select the month and year
        <br />
        to enter your Non-Financial Data</h3>
    <label for="startDate">Date :</label>
    <input runat="server" name="startDate" id="startDate" class="date-picker" />
    <table id="activeIndividuals">
    </table>
    <asp:Button runat="server" ID="SaveButton" OnClientClick="return false;" Text="Save Current Individuals"></asp:Button>
    <div id="activeIndividualsPager">
    </div>
    <table id="exitedIndividuals">
    </table>
    <div id="exitedIndividualsPager">
    </div>

    <script type="text/javascript">

        $(document).ready(function () {
            GetActiveIndividuals();
            GetExitedIndividuals();
        });

        function GetActiveIndividuals() {
            $.ajax({
                type: "POST",
                url: GetIndividualsURL("Yes"),//"../Default.aspx/getData",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var item = $.parseJSON(response.d);
                    if (item != null && item != "" && typeof (item) != 'undefined') {
                        var lastsel2
                        var grid = $("#activeIndividuals");
                        grid.jqGrid({
                            //url: GetIndividualsURL("Yes"),
                            //datatype: "json",
                            data: item,
                            datatype: 'local',
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
                            editurl: GetIndividualsURL("Yes"),
                            cellsubmit: 'clientArray',
                            beforeSelectRow: function (id) {
                                var daysOfSupport = "#" + id + "_DaysOfSupport"
                            },
                            gridComplete: function () {
                                var dataIds = $('#activeIndividuals').jqGrid('getDataIDs');
                                for (var i = 0; i < dataIds.length; i++) {
                                    $("#activeIndividuals").jqGrid('editRow', dataIds[i], false);
                                }
                            }
                        });
                    }
                    else {
                        var result = '<tr align="left"><td>' + "No Record" + '</td></tr>';
                        $('#activeIndividuals').empty().append(result);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("error");
                }
            });
        };

        /*************************************/
        /******** Set Ajax URL **************/
        /***********************************/
        function GetIndividualsURL(active) {
            var url = "../Default.aspx/getData";
            var queryString = "?date=".concat($('#MainContent_startDate').val());
            queryString = queryString.concat("&active=" + active);
            return (url.concat(queryString));
        };

        /*********************************/
        /***** Wire up Date Picker ******/
        /*******************************/
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

        $("#activeIndividuals tr").click(function () {
            jQuery("#activeIndividuals ").jqGrid('editGridRow', rowid, properties);
        });


        /****************************************************/
        /*************** Exited Individuals *****************/
        /****************************************************/
        function GetExitedIndividuals() {
            $.ajax({
                type: "POST",
                url: GetIndividualsURL("Yes"),//"../Default.aspx/getData",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var item = $.parseJSON(response.d);
                    if (item != null && item != "" && typeof (item) != 'undefined') {
                        var lastsel2
                        var grid = $("#exitedIndividuals");
                        grid.jqGrid({
                            //url: GetIndividualsURL("Yes"),
                            //datatype: "json",
                            data: item,
                            datatype: 'local',
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
                            pager: '#exitedIndividualsPager',
                            sortname: '_id',
                            viewrecords: true,
                            sortorder: 'desc',
                            caption: "Exited Individuals",
                            editurl: GetIndividualsURL("No")
                        });
                    }
                    else {
                        var result = '<tr align="left"><td>' + "No Record" + '</td></tr>';
                        $('#list').empty().append(result);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("error");
                }
            });
        };




        //Update Grid when date changes.
        $('#MainContent_startDate').change(function () {
            $('#activeIndividuals').jqGrid('GridUnload');
            $('#exitedIndividuals').jqGrid('GridUnload');
            GetActiveIndividuals();
            GetExitedIndividuals();
        });

        $("#exitedIndividuals tr").click(function () {
            jQuery("#exitedIndividuals ").jqGrid('editGridRow', rowid, properties);
        });

        $("#MainContent_SaveButton").click(function () {
            var batch = new Array();
            //Get ids for all current rows
            var dataIds = $('#activeIndividuals').jqGrid('getDataIDs');
            for (var i = 0; i < dataIds.length; i++) {
                try {
                    //Save row only to the grid
                    $('#activeIndividuals').jqGrid('saveRow', dataIds[i], false, 'clientArray');
                    //Get row data
                    var data = $('#activeIndividuals').jqGrid('getRowData', dataIds[i]);
                    //Data doesnt contain actual id
                    data.Id = dataIds[i];
                    //Add data to the batch
                    batch.push(data)
                }
                catch (ex) {
                    alert(ex.message);
                    $('#activeIndividuals').jqGrid('restoreRow', dataIds[i]);
                }
            }
            //Send batch to the server 
            $.ajax({
            type: "POST",
            url: "../Default.aspx/saveData",
            contentType: "application/json; charset=utf-8",
            data: "{'data':'" + JSON.stringify(batch) + "'}",
            //data: JSON.stringify(batch),
            dataType: "json"
            });

            //$.ajax({
            //    type: 'POST',
            //    contentType: 'application/json; charset=utf-8',
            //    url: '../Default.aspx/saveData',
            //    dataType: 'json',
            //    data: '{"debug": "on"}',
            //    //data: JSON.stringify(batch),
            //    success: function (results) {
            //        alert("done");
            //        $('#activeIndividuals').trigger('reloadGrid');
            //    }
            //});



        });







    </script>
</asp:Content>
