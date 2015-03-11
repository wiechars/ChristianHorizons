<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeBehind="NonFinancial.aspx.cs" Inherits="ChristianHorizons.NonFinancial" %>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
</asp:Content>
<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
    <h2>Christian Horizons Non Financial Data
    </h2>
    <button type="submit">Submit form</button>
    <table id="activeTable" class="display" cellspacing="0" width="100%">
        <thead>
            <tr>
                <th>Individual</th>
                <th>Days of Support</th>
                <th>Level of Support</th>
                <th>On Hold Days</th>
                <th>Ministry Detail Code</th>
                <th>Language Served</th>
                <th>Comments</th>
            </tr>
        </thead>

        <tbody>
        </tbody>
    </table>
    <div style="height: 50px;"></div>



    <script type="text/javascript">

        function GetUrl(active) {
            var url = " http://localhost:44930/NonFinancialHandler.ashx";
            var queryString = "?date=".concat($('#MainContent_startDate').val());
            queryString = queryString.concat("&active=" + active);
            return (url.concat(queryString));
        };

        $(document).ready(function () {
            var urlActive = GetUrl("Yes");

            $("#activeTable").dataTable({
                "sPaginationType": "full_numbers",
                "bProcessing": true,
                "bServerSide": false,
                "sAjaxDataProp": "aaData",
                "sAjaxSource": "http://localhost:44930/NonFinancialHandler.ashx?Date=March 2015&active=Yes",

                "aoColumns": [
                    { "mData": "Name", tooltip: 'Click to edit platforms' },
                                    {
                                        data: "DaysOfSupport",
                                        render: function (data, type, row) {
                                            if (type === 'display') {
                                                return '<input type="text" value="' + data + '" class="editor-active">';
                                            }
                                            return data;
                                        },
                                        className: "dt-body-center"
                                    },
                                    {
                                        data: "LevelOfSupport",
                                        render: function (data, type, row) {
                                            if (type === 'display') {
                                                return '<select><option value="0-8 Hrs/Day">0-8 Hrs/Day</option>' +
                                                    '<option value="0-8 Hrs/Day">0-8 Hrs/Day</option>' +
                                                    '<option value="8-24 Hrs/Day">8-24 Hrs/Day</option>' +
                                                     '<option value="Once/Week">Once/Week</option>' +
                                                     '<option value="Once/Month">Once/Month</option>';
                                            }
                                            return data;
                                        },
                                        className: "dt-body-center"
                                    },
                    { "mData": "OnHoldDays" },
                    { "mData": "MinistryDetailCode" },
                    { "mData": "Language" },

                {
                    data: "Comments",
                    render: function (data, type, row) {
                        if (type === 'display') {
                            return '<input type="text" value="' + data + '" class="editor-active">';
                        }
                        return data;
                    },
                    className: "dt-body-center"
                }


                ]
            });



            $('submit').click(function () {
                var data = table.$('input, select').serialize();
                alert("test");
                //alert(
                //    "The following data would have been submitted to the server: \n\n"+
                //    data.substr( 0, 120 )+'...'
                //);
                return false;
            });
        });

    </script>
</asp:Content>
