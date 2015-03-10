<%@ Page Title="About Us" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeBehind="About.aspx.cs" Inherits="JQGridDemo.About" %>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
</asp:Content>
<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
    <h2>
        JqGrid Inline Editing
    </h2>
    <table id="jQGridDemo">
    </table>
    <div id="jQGridDemoPager">
    </div>
    <script type="text/javascript">
        jQuery("#jQGridDemo").jqGrid({
            url: 'http://localhost:58404/JQGridInlineHandler.ashx',
            datatype: "json",
            colNames: ['Id', 'First Name', 'Last Name', 'Last 4 SSN', 'Department', 'Age', 'Salary', 'Marital Status', 'Permenant'],
            colModel: [
                        { name: '_id', index: '_id', width: 20, stype: 'text' },
   		                { name: 'FirstName', index: 'FirstName', width: 150, stype: 'text', sortable: true, editable: true },
   		                { name: 'LastName', index: 'LastName', width: 150, editable: true },
   		                { name: 'LastSSN', index: 'LastSSN', width: 60, editable: true },
   		                { name: 'Department', index: 'Department', width: 80, align: "right", editable: true,edittype: "select", formatter: 'select',editoptions: { value: "IT:IT;Finance:Finance;REFM:REFM;Purchase:Purchase;Retail:Retail" }},
   		                { name: 'Age', index: 'Age', width: 40, align: "right", editable: true },
   		                { name: 'Salary', index: 'Salary', width: 80, align: "right", editable: true },
                        { name: 'MaritalStatus', index: 'MaritalStatus', width: 100, sortable: false, editable: true, edittype: "select", formatter: 'select',editoptions: { value: "Married:Married;Single:Single;Divorced:Divorced" }},
                        { name: 'Permenant', index: 'Permenant', width: 100, sortable: true, editable: true,edittype: "checkbox", editoptions: { value: "Yes:No"}}
   	                  ],
            rowNum: 10,
            mtype: 'GET',
            loadonce: true,
            rowList: [10, 20, 30],
            pager: '#jQGridDemoPager',
            sortname: '_id',
            viewrecords: true,
            sortorder: 'desc',
            caption: "List Employee Details",
            editurl: 'http://localhost:58404/JQGridInlineHandler.ashx'
        });
        $('#jQGridDemo').jqGrid('navGrid', '#jQGridDemoPager',
                   {
                       edit: false,
                       add: false,
                       del: false,
                       search: false
                   }
            );

                   $("#jQGridDemo").jqGrid('inlineNav', '#jQGridDemoPager',
                    {
                        edit: true,
                        editicon: "ui-icon-pencil",
                        add: true,
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
                                    var sel_id = $('#jQGridDemo').jqGrid('getGridParam', 'selrow');
                                    var value = $('#jQGridDemo').jqGrid('getCell', sel_id, '_id');
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
    </script>
</asp:Content>
