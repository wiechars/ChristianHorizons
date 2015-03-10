using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Collections.Specialized;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Web.Services;
using System.Web;

namespace ChristianHorizons
{
    /// <summary>
    /// Summary description for NonFinancialHanlder
    /// </summary>
    public class NonFinancialHandler : IHttpHandler
    {
        private string month = "";
        private string year = "";
        private string active = "";

        public void ProcessRequest(HttpContext context)
        {
            int i = 0;

            active = context.Request.QueryString["active"];

            if (context.Request.QueryString["date"].Length > 1)
            {
                string[] date = context.Request.QueryString["date"].Split(' ');
                foreach (string x in date)
                {
                    if (i == 0)
                    {
                        month = date[i];
                    }
                    if (i == 1)
                    {
                        year = date[i];
                    }
                    i++;

                }

                System.Collections.Specialized.NameValueCollection forms = context.Request.Form;
                string strOperation = forms.Get("oper");
                Sharepoint obj = new Sharepoint();
                var collection = obj.GetIndividuals(month, year, active);
                string strResponse = string.Empty;

                if (strOperation == null)
                {

                    var jsonSerializer = new JavaScriptSerializer();
                    //context.Response.Write("{\"sEcho\":1,\"iTotalRecords\":" + collection.Count + ",\"iTotalDisplayRecords\":" + collection.Count + ", ");
                    //context.Response.Write("\"aaData\":" + (jsonSerializer.Serialize(collection.AsQueryable<Individual>().ToList<Individual>())) + "}");
                    //Below is for jqGrid Above is datables
                    context.Response.Write(jsonSerializer.Serialize(collection.AsQueryable<Individual>().ToList<Individual>()));
                }
                else
                {
                    string strOut = string.Empty;
                    AddEdit(forms, collection, out strOut);
                    context.Response.Write(strOut);
                }

               


            }

        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }

        private void AddEdit(NameValueCollection forms,  List<Individual> collection, out string strResponse)
        {
            string strOperation = forms.Get("oper");
            string strEmpId = string.Empty;

            if (strOperation == "add")
            {
                //var result = collection.AsQueryable<EmployeeInline>().Select(c => c._id).Max();
                //strEmpId = (Convert.ToInt32(result) + 1).ToString();
                //strResponse = "Employee record successfully added";

            }
            else if (strOperation == "edit")
            {
                //strEmpId = forms.Get("Name").ToString();
                strResponse = "Individual record successfully updated";
            }
            else
            {
                strResponse = "";
            }


            string name = forms.Get("Name").ToString();
            string daysOfSupport = forms.Get("DaysOfSupport").ToString();
            string levelOfSupport = forms.Get("LevelOfSupport").ToString();
            string onHoldDays = forms.Get("OnHoldDays").ToString();
            string ministryDetailCode = forms.Get("MinistryDetailCode").ToString();
            string language = forms.Get("Language").ToString();
            string comments = forms.Get("Comments").ToString();

            Individual obj = new Individual();
            obj.Name = name;
            obj.DaysOfSupport = daysOfSupport;
            obj.LevelOfSupport = levelOfSupport;
            obj.OnHoldDays = onHoldDays;
            obj.MinistryDetailCode = ministryDetailCode;
            obj.Language = language;
            obj.Comments = comments;
            obj.Year = year;
            obj.Month = month;
            obj.Active = active;
            Sharepoint updateQuery = new Sharepoint();
            if (updateQuery.SaveIndividualRecord(obj))
            {
                strResponse = "Individual record successfully updated";
            }
            else
            {
                strResponse = "Computer Said No!";
            }

        }
    }
}