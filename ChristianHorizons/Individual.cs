using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ChristianHorizons
{
    public class Remove
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