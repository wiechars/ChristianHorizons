using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data.SqlClient;
using System.Data;
using System.Web.Services;
using System.Xml;


namespace ChristianHorizons
{
    public class Sharepoint
    {
        /// <summary>
        /// Constants
        /// </summary>
        protected string NON_FINANCIAL_LIST = "{BA7AB7CE-E28C-459B-A0C4-BCE88EB7E5B3}";
        protected string INDIVID_FUNDING_DATA = "{CBB8C7AC-B33D-4517-BD10-5E573065618E}";
        protected string SHAREPOINT_URL = "https://odb.chconnect.org/_vti_bin/Lists.asmx";

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

//        private void UpdateSharepointList()
//        {
//            Web_Reference.Lists listService = new Web_Reference.Lists();
//listService.Credentials= System.Net.CredentialCache.DefaultCredentials;

//string strBatch = "<Method ID='1' Cmd='Update'>" + 
//    "<Field Name='ID'>4</Field>" +
//    "<Field Name='Field_Number'>999</Field></Method>" +
//    "<Method ID='2' Cmd='Update'><Field Name='ID' >6</Field></Method>"; 

//XmlDocument xmlDoc = new System.Xml.XmlDocument();

//System.Xml.XmlElement elBatch = xmlDoc.CreateElement("Batch");

//elBatch.SetAttribute("OnError","Continue");
//elBatch.SetAttribute("ListVersion","1");
//elBatch.SetAttribute("ViewName",
//    "0d7fcacd-1d7c-45bc-bcfc-6d7f7d2eeb40");

//elBatch.InnerXml = strBatch;

//XmlNode ndReturn = listService.UpdateListItems("List_Name", elBatch);
//        }

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

        private SqlDataReader QueryFetch(String commandText)
        {
            String connectionString = "Persist Security Info=False;Integrated Security=true;Initial Catalog=ChristianHorizons;server=(local)";
            SqlConnection conn = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand();

            cmd.CommandText = commandText;
            cmd.CommandType = CommandType.Text;
            cmd.Connection = conn;

            conn.Open();
            return cmd.ExecuteReader();
        }

        private bool QueryUpdate(String commandText)
        {
            try
            {
                String connectionString = "Persist Security Info=False;Integrated Security=true;Initial Catalog=ChristianHorizons;server=(local)";
                SqlConnection conn = new SqlConnection(connectionString);
                SqlCommand cmd = new SqlCommand();

                cmd.CommandText = commandText;
                cmd.Connection = conn;

                conn.Open();
                cmd.ExecuteNonQuery();
                conn.Close();
                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
        }


        public List<Individual> GetIndividuals(string month, string year, string exited)
        {
            XmlNode results = GetNonFinancialList(month, year);
            List<Individual> list = new List<Individual>();
            int value;

            if (results != null && results.HasChildNodes == true)
            {
                foreach (XmlNode node in results)
                {
                    if (node.Name == "rs:data")
                    {
                        for (int i = 0; i < node.ChildNodes.Count; i++)
                        {
                            if (node.ChildNodes[i].NodeType.ToString() == "Element")
                            {
                                Individual individ = new Individual();
                                individ.Name = node.ChildNodes[i].Attributes["ows_Individuals"].Value.ToString().Split('#')[1];
                                individ.DaysOfSupport = Int32.TryParse(node.ChildNodes[i].Attributes["ows_DaysOfSupport"].Value.ToString(), out value) ? value : 0;
                                individ.LevelOfSupport = node.ChildNodes[i].Attributes["ows_LanguageServedAtServiceFromIndiv"].Value;
                                //individ.OnHoldDays = node.ChildNodes[i].Attributes["ows_OnHoldDays"].Value;
                                individ.MinistryDetailCode = node.ChildNodes[i].Attributes["ows_MinistryDetailCode"].Value.ToString().Split('#')[1];
                                individ.Language = node.ChildNodes[i].Attributes["ows_LanguageServedAtServiceFromIndiv"].Value;
                                //individ.Comments =  node.ChildNodes[i].Attributes["ows_Comments"].Value;
                                list.Add(individ);

                            }
                        }
                    }
                }
            }
            return list;
        }


        //public List<Individual> GetIndividuals(string month, string year, string exited)
        //{
        //    GetNonFinancialList();
        //    List<Individual> list = new List<Individual>();
        //    SqlDataReader reader = this.QueryFetch("SELECT ISNULL(NonFinancialData.Individual,IndividFundingData.Individual)AS 'Individual' " +
        //                                        ",ISNULL(NonFinancialData.Month,'" + month + "') AS 'Month' " +
        //                                        ",ISNULL(NonFinancialData.Year,'" + year + "') AS 'Year' " +
        //                                        ",NonFinancialData.DaysOfSupp " +
        //                                        ",NonFinancialData.LevelOfSupport " +
        //                                        ",NonFinancialData.OnHoldDays " +
        //                                        ",NonFinancialData.LanguageServedAtServiceFromIndividInfo " +
        //                                        ",NonFinancialData.MinistryDetailCode " +
        //                                        ",NonFinancialData.Comments " +
        //                                        ",NonFinancialData.Residences " +
        //                                        "FROM NonFinancialData " +
        //                                        "RIGHT JOIN IndividFundingData ON (IndividFundingData.Individual = NonFinancialData.Individual AND (Year = '" + year + "' AND Month = '" + month + "')) " +
        //                                        "WHERE IndividFundingData.ActiveYesNo = '" + exited + "';");
        //    if (reader.HasRows == true)
        //    {
        //        while (reader.Read())
        //        {
        //            Individual individ = new Individual();
        //            individ.Name = reader["Individual"].ToString();
        //            individ.DaysOfSupport = reader["DaysOfSupp"].ToString();
        //            individ.LevelOfSupport = reader["LevelOfSupport"].ToString();
        //            individ.OnHoldDays = reader["OnHoldDays"].ToString();
        //            individ.MinistryDetailCode = reader["MinistryDetailCode"].ToString();
        //            individ.Language = reader["LanguageServedAtServiceFromIndividInfo"].ToString();
        //            individ.Comments = reader["Comments"].ToString();
        //            list.Add(individ);

        //        }
        //    }
        //    return list;
        //}

        public bool SaveIndividualRecord(Individual record)
        {
            return (this.QueryUpdate("SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; " +
                                "BEGIN TRANSACTION; " +
                                "UPDATE NonFinancialData " +
                                "SET DaysOfSupp = '" + record.DaysOfSupport + "' " +
                                "	,LevelOfSupport = '" + record.LevelOfSupport + "' " +
                                "	,OnHoldDays = '" + record.OnHoldDays + "' " +
                                "	,LanguageServedAtServiceFromIndividInfo = '" + record.Language + "' " +
                                "	,MinistryDetailCode = '" + record.MinistryDetailCode + "' " +
                                "	,Comments = '" + record.Comments + "' " +
                                "WHERE Individual = '" + record.Name + "' " +
                                "	AND Month = '" + record.Month + "' " +
                                "	AND Year = '" + record.Year + "'; " +
                                "IF @@ROWCOUNT = 0 " +
                                "BEGIN " +
                                "	INSERT INTO NonFinancialData(Individual, Month, Year, DaysOfSupp, LevelOfSupport,OnHoldDays " +
                                "		,LanguageServedAtServiceFromIndividInfo,MinistryDetailCode, Comments) " +
                                "	VALUES ('" + record.Name + "', '" + record.Month + "', '" + record.Year + "', '" + record.DaysOfSupport + "', '" + record.LevelOfSupport + "','" + record.OnHoldDays + "'," +
                                            "'" + record.Language + "','" + record.MinistryDetailCode + "','" + record.Comments + "') " +
                                "END " +
                                "COMMIT TRANSACTION; "));


        }
    }
}