using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data.SqlClient;
using System.Data;

namespace ChristianHorizons
{
    public class Sharepoint
    {

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
            List<Individual> list = new List<Individual>();
            SqlDataReader reader = this.QueryFetch("SELECT ISNULL(NonFinancialData.Individual,IndividFundingData.Individual)AS 'Individual' " +
                                                ",ISNULL(NonFinancialData.Month,'" + month + "') AS 'Month' " +
                                                ",ISNULL(NonFinancialData.Year,'" + year + "') AS 'Year' " +
                                                ",NonFinancialData.DaysOfSupp " +
                                                ",NonFinancialData.LevelOfSupport " +
                                                ",NonFinancialData.OnHoldDays " +
                                                ",NonFinancialData.LanguageServedAtServiceFromIndividInfo " +
                                                ",NonFinancialData.MinistryDetailCode " +
                                                ",NonFinancialData.Comments " +
                                                ",NonFinancialData.Residences " +
                                                "FROM NonFinancialData " +
                                                "RIGHT JOIN IndividFundingData ON (IndividFundingData.Individual = NonFinancialData.Individual AND (Year = '" + year + "' AND Month = '" + month + "')) " +
                                                "WHERE IndividFundingData.ActiveYesNo = '"+exited+"';");
            if (reader.HasRows == true)
            {
                while (reader.Read())
                {
                    Individual individ = new Individual();
                    individ.Name = reader["Individual"].ToString();
                    individ.DaysOfSupport = reader["DaysOfSupp"].ToString();
                    individ.LevelOfSupport = reader["LevelOfSupport"].ToString();
                    individ.OnHoldDays = reader["OnHoldDays"].ToString();
                    individ.MinistryDetailCode = reader["MinistryDetailCode"].ToString();
                    individ.Language = reader["LanguageServedAtServiceFromIndividInfo"].ToString();
                    individ.Comments = reader["Comments"].ToString();
                    list.Add(individ);

                }
            }
            return list;
        }

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