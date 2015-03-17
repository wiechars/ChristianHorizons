using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Web.Services;
using System.Xml;
using System.Web.Script.Services;
using System.Web.Script.Serialization;


namespace NonFinancialData
{
    public partial class _Default : System.Web.UI.Page
    {
        static string month = "";
        static string year = "";
        static string active = "";
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        public static string GetJson()
        {
            GetValues();
            Sharepoints obj = new Sharepoints();
            List<Individuals> collection = obj.GetIndividuals(month, year, active);
            string strResponse = string.Empty;
            JavaScriptSerializer jsonSerializer = new JavaScriptSerializer();
            return jsonSerializer.Serialize(collection);
        }

        public static string SaveJson(string data)
        {
            string response = "";
            //        JavaScriptSerializer json = new JavaScriptSerializer();
            //      IndividualList list = new JavaScriptSerializer().Deserialize<IndividualList>(data);
            IList<Individuals> list = new JavaScriptSerializer().Deserialize<IList<Individuals>>(data);
            AddEdit(list, out response);
            return response;
        }

        private static void AddEdit(IList<Individuals> collection, out string strResponse)
        {
            foreach (Individuals individ in collection)
            {
                individ.Month = month;
                individ.Year = year;
                if (individ.DaysOfSupport != "")
                {
                    Sharepoint updateQuery = new Sharepoint();
                    if (updateQuery.SaveIndividualRecord(individ))
                    {
                        strResponse = "Individual record successfully updated";
                    }
                }

            }
            strResponse = "Computer Said No!";

        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string getData()
        {
            string data = GetJson();
            return data;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string saveData(string data)
        {
            return SaveJson(data);

        }


        public static void GetValues()
        {
            string[] date;

            try
            {
                if (HttpContext.Current.Request.QueryString["date"].Length > 1)
                {
                    date = HttpContext.Current.Request.QueryString["date"].Split(' ');
                    month = date[0];
                    year = date[1];
                    if (HttpContext.Current.Request.QueryString["active"] != null)
                    {
                        active = HttpContext.Current.Request.QueryString["active"].ToString();
                    }
                }

            }
            catch (Exception e) { }
        }

    }





    public class Sharepoints
    {
        /// <summary>
        /// Constants
        /// </summary>
        protected string NON_FINANCIAL_LIST = "NonFinancialData";
        protected string NON_FINANCIAL_LIST_VIEW_NAME = "{BA7AB7CE-E28C-459B-A0C4-BCE88EB7E5B3}";
        protected string SERVICE_HISTORY = "Service History";
        protected string INDIVID_FUNDING_DATA = "{CBB8C7AC-B33D-4517-BD10-5E573065618E}";
        protected string SHAREPOINT_URL = "https://odb.chconnect.org/_vti_bin/Lists.asmx";

        /// <summary>
        /// Access the specified Sharepoint List and takes an xml input string
        /// then updates the list specified.
        /// </summary>
        /// <param name="query"></param>
        /// <param name="listName"></param>
        private void UpdateSharepointDataList(string query, string listName)
        {
            Web_Reference.Lists listService = new Web_Reference.Lists();

            /*Authenticate the current user by passing their default 
            credentials to the Web service from the system credential cache.*/
            //listService.Credentials =
            // System.Net.CredentialCache.DefaultCredentials;
            //Use Above when live - for now - use below
            listService.PreAuthenticate = true;
            listService.Credentials = new System.Net.NetworkCredential("rwiecha", "cybw83Dr82", "CH");

            string strBatch = query;

            XmlDocument xmlDoc = new System.Xml.XmlDocument();

            System.Xml.XmlElement elBatch = xmlDoc.CreateElement("Batch");

            elBatch.SetAttribute("OnError", "Continue");
            elBatch.SetAttribute("ListVersion", "1");
            //elBatch.SetAttribute("ViewName",listView);
            elBatch.InnerXml = strBatch;

            XmlNode ndReturn = listService.UpdateListItems(listName, elBatch);


        }

        /// <summary>
        /// Establishes a connection to the Sharpoint Webservice Lists and retrieves data
        /// </summary>
        /// <param name="listName"></param>
        /// <param name="viewName"></param>
        /// <param name="rowLimit"></param>
        /// <param name="queryInnerXML"></param>
        /// <param name="viewFieldsInnerXML"></param>
        /// <param name="queryOptionsInnerXML"></param>
        /// <returns></returns>
        private XmlNode GetSharepointDataList(string listName, string viewName, string rowLimit, string queryInnerXML
                , string viewFieldsInnerXML, string queryOptionsInnerXML)
        {
            Web_Reference.Lists listService = new Web_Reference.Lists();

            /*Authenticate the current user by passing their default 
            credentials to the Web service from the system credential cache.*/
            //listService.Credentials =
            // System.Net.CredentialCache.DefaultCredentials;
            //Use Above when live - for now - use below
            listService.PreAuthenticate = true;
            listService.Credentials = new System.Net.NetworkCredential("rwiecha", "cybw83Dr82", "CH");

            listService.Url = SHAREPOINT_URL;
            XmlDocument xmlDoc = new System.Xml.XmlDocument();
            /*Use the CreateElement method of the document object to create elements for the parameters that use XML.*/
            XmlElement query = xmlDoc.CreateElement("Query");
            XmlElement viewFields = xmlDoc.CreateElement("ViewFields");
            XmlElement queryOptions = xmlDoc.CreateElement("QueryOptions");

            /*To specify values for the parameter elements (optional), assign CAML fragments to the InnerXml property of each element.*/
            query.InnerXml = queryInnerXML;
            viewFields.InnerXml = viewFieldsInnerXML;
            queryOptions.InnerXml = queryOptionsInnerXML;

            XmlNode nodeListItems = null;
            try
            {
                nodeListItems =
                    listService.GetListItems
                    (listName, viewName, query, viewFields, rowLimit, queryOptions, null);
            }

            catch (System.Web.Services.Protocols.SoapException ex)
            {
                String Error = "Message:\n" + ex.Message + "\nDetail:\n" +
                    ex.Detail.InnerText +
                     "\nStackTrace:\n" + ex.StackTrace;
            }
            return nodeListItems;


        }

        /// <summary>
        /// Gets Non Financial Data
        /// </summary>
        /// <param name="month"></param>
        /// <param name="year"></param>
        /// <returns></returns>
        private XmlNode GetNonFinancialList(string month, string year)
        {
            string queryInnerXML = "<Where><And><Eq><FieldRef Name='Month'/>" +
                            "<Value Type='String'>" + month + "</Value></Eq><Eq><FieldRef Name='Year'/>" +
                           "<Value Type='String'>" + year + "</Value></Eq></And></Where>";


            return GetSharepointDataList(NON_FINANCIAL_LIST, null, "150", queryInnerXML, null, null);
        }

        /// <summary>
        /// Query used to get individuals by program
        /// </summary>
        /// <param name="month"></param>
        /// <param name="year"></param>
        /// <returns></returns>
        private XmlNode GetProgramIndividuals(string month, string year)
        {
            string queryInnerXML = "<Where><EQ><FieldRef Name=\"RefInd2\" LookupId=\"TRUE\"/>" +
                            "<Value Type=\"Lookup\">2626;</Value></EQ></Where>";


            return GetSharepointDataList(SERVICE_HISTORY, null, "300", null, null, null);
        }

        /// <summary>
        /// Populates a list if individual objects to be used for the NonFinancialDataList
        /// </summary>
        /// <param name="month"></param>
        /// <param name="year"></param>
        /// <param name="exited"></param>
        /// <returns></returns>
        public List<Individuals> GetIndividuals(string month, string year, string exited)
        {

            int result = 0;

            XmlNode programIndividuals = GetProgramIndividuals(month, year);
            XmlNode nonFinancialData = GetNonFinancialList(month, year);
            List<Individuals> nonFinancialList = new List<Individuals>();

            /* First populate the list with all the individuals in the program 
                with null values for all the NonFinancial Data columns*/
            if (programIndividuals != null && programIndividuals.HasChildNodes == true)
            {
                foreach (XmlNode node in programIndividuals)
                {
                    if (node.Name == "rs:data")
                    {
                        for (int i = 0; i < node.ChildNodes.Count; i++)
                        {
                            if (node.ChildNodes[i].NodeType.ToString() == "Element")
                            {
                                Individuals individ = new Individuals();
                                individ.IndividID = Convert.ToInt32(node.ChildNodes[i].Attributes["ows_RefInd2"].Value.ToString().Split(';')[0]);
                                individ.Name = node.ChildNodes[i].Attributes["ows_RefInd2"].Value.ToString().Split('#')[1];
                                nonFinancialList.Add(individ);

                            }
                        }
                    }
                }
            }

            /* Now that we have a list of users, take the NonFinancial Data and update the list of individuals
               to have their financial data if it exists.  **Note this is how I am recreating the equivalent of a 
               MS SQL right join*/
            if (nonFinancialData != null && nonFinancialData.HasChildNodes == true)
            {
                foreach (XmlNode node in nonFinancialData)
                {
                    if (node.Name == "rs:data")
                    {
                        for (int i = 0; i < node.ChildNodes.Count; i++)
                        {
                            if (node.ChildNodes[i].NodeType.ToString() == "Element")
                            {
                                foreach (Individuals obj in nonFinancialList)
                                {

                                    //Check if there is a non financial record for the given month year for the individual
                                    if (obj.IndividID == Convert.ToInt32(node.ChildNodes[i].Attributes["ows_Individuals"].Value.ToString().Split(';')[0]))
                                    {

                                        obj.NonFinancialID = int.TryParse(node.ChildNodes[i].Attributes["ows_ID"].Value.ToString(), out result) ? result : -1;
                                        obj.DaysOfSupport = node.ChildNodes[i].Attributes["ows_DaysOfSupport"].Value.ToString();


                                        //obj.LevelOfSupport = node.ChildNodes[i].Attributes["ows_LevelOfSupport"].Value;
                                        // obj.OnHoldDays = node.ChildNodes[i].Attributes["ows_OnHoldDays"].Value;
                                        //    obj.MinistryDetailCode = node.ChildNodes[i].Attributes["ows_MinistryDetailCode"].Value.ToString().Split('#')[1];
                                        //    obj.Language = node.ChildNodes[i].Attributes["ows_LanguageServedAtServiceFromIndiv"].Value;
                                        //obj.Comments = node.ChildNodes[i].Attributes["ows_Comments"].Value;
                                    }
                                }

                            }
                        }
                    }
                }
            }
            return nonFinancialList;
        }

        /// <summary>
        /// Saves the edited record back into Sharepoint
        /// </summary>
        /// <param name="record"></param>
        /// <returns></returns>
        public bool SaveIndividualRecord(Individuals record)
        {
            string query = "";

            //Update
            if (record.NonFinancialID > 0)
            {

                query = "<Method ID='1' Cmd='Update'>" +
                "<Field Name='ID'>" + record.NonFinancialID + "</Field>" +
                "<Field Name='Month'>" + record.Month + "</Field>" +
                "<Field Name='Year'>" + record.Year + "</Field>" +
                "<Field Name='DaysOfSupport'>" + record.DaysOfSupport + "</Field>" +
                "<Field Name='Comments'>" + record.Comments + "</Field></Method>";

            }
            //New Record
            else
            {

                query = "<Method ID='1' Cmd='New'>" +
                "<Field Name='Individuals'>" + record.IndividID + "</Field>" +
                "<Field Name='Month'>" + record.Month + "</Field>" +
                "<Field Name='Year'>" + record.Year + "</Field>" +
                "<Field Name='DaysOfSupport'>" + record.DaysOfSupport + "</Field>" +
                "<Field Name='Comments'>" + record.Comments + "</Field></Method>";
            }

            UpdateSharepointDataList(query, NON_FINANCIAL_LIST);

            return true;
        }
    }

    public class IndividualList
    {
        public List<Individuals> data { get; set; }
    }

    public class Individuals
    {
        private int individID;
        private int nonFinancialID;
        private String name;
        private String daysOfSupport;
        private String levelOfSupport;
        private String onHoldDays;
        private String ministryDetailCode;
        private String language;
        private String comments;
        private String month;
        private String year;
        private String active;


        public int IndividID
        {
            get { return individID; }
            set { individID = value; }
        }

        public int NonFinancialID
        {
            get { return nonFinancialID; }
            set { nonFinancialID = value; }
        }

        public string Name
        {
            get { return name; }
            set { name = value; }
        }

        public string DaysOfSupport
        {
            get { return daysOfSupport; }
            set { daysOfSupport = value; }
        }

        public string LevelOfSupport
        {
            get { return levelOfSupport; }
            set { levelOfSupport = value; }
        }

        public string OnHoldDays
        {
            get { return onHoldDays; }
            set { onHoldDays = value; }
        }

        public string MinistryDetailCode
        {
            get { return ministryDetailCode; }
            set { ministryDetailCode = value; }
        }

        public string Language
        {
            get { return language; }
            set { language = value; }
        }
        public string Comments
        {
            get { return comments; }
            set { comments = value; }
        }

        public string Year
        {
            get { return year; }
            set { year = value; }
        }
        public string Month
        {
            get { return month; }
            set { month = value; }
        }

        public string Active
        {
            get { return active; }
            set { active = value; }
        }


    }
}
