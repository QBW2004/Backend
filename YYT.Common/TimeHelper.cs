using System;
using System.Globalization;

namespace YYT.Common
{
    /// <summary>
    /// 时间帮助类
    /// </summary>
    public static class TimeHelper
    {
        #region 日期扩展

        /// <summary>
        /// 根据年月日获得星期几
        /// </summary>
        /// <param name="year">年</param>
        /// <param name="month">月</param>
        /// <param name="day">日</param>
        /// <returns></returns>
        public static int getWeekDay(int year, int month, int day)
        {
            if (month == 1) month = 13;
            if (month == 2) month = 14;
            int week = (day + 2 * month + 3 * (month + 1) / 5 + year + year / 4 - year / 100 + year / 400) % 7 + 1;
            return week;
        }

        public static int WeekOfYear(this string datetime)
        {
            DateTime resultDate;
            DateTime.TryParse(datetime, out resultDate);
            return resultDate.WeekOfYear();
        }

        public static int WeekOfYear(this string datetime, CalendarWeekRule calendarWeekRule = CalendarWeekRule.FirstDay, DayOfWeek dayOfWeek = DayOfWeek.Monday)
        {
            DateTime resultDate;
            DateTime.TryParse(datetime, out resultDate);
            return WeekOfYear(resultDate, calendarWeekRule, dayOfWeek);
        }

        public static int WeekOfYear(this DateTime day, CalendarWeekRule calendarWeekRule = CalendarWeekRule.FirstDay, DayOfWeek dayOfWeek = DayOfWeek.Monday)
        {
            return new GregorianCalendar().GetWeekOfYear(day, calendarWeekRule, dayOfWeek);
        }

        /// <summary> 
        /// 取指定日期是一年中的第几周 
        /// </summary> 
        /// <param name="dtime">给定的日期</param> 
        /// <returns>数字 一年中的第几周</returns> 
        public static int WeekOfYear(this DateTime dtime)
        {
            try
            {
                //确定此时间在一年中的位置
                int dayOfYear = dtime.DayOfYear;
                //当年第一天
                DateTime tempDate = new DateTime(dtime.Year, 1, 1);
                //确定当年第一天
                int tempDayOfWeek = (int)tempDate.DayOfWeek;
                tempDayOfWeek = tempDayOfWeek == 0 ? 7 : tempDayOfWeek;
                ////确定星期几
                int index = (int)dtime.DayOfWeek;
                index = index == 0 ? 7 : index;

                //当前周的范围
                DateTime retStartDay = dtime.AddDays(-(index - 1));
                DateTime retEndDay = dtime.AddDays(6 - index);

                //确定当前是第几周
                int weekIndex = (int)Math.Ceiling(((double)dayOfYear + tempDayOfWeek - 1) / 7);

                if (retStartDay.Year < retEndDay.Year)
                {
                    weekIndex = 1;
                }

                return weekIndex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

        }

        /// <summary>
        /// 获得星期几
        /// </summary>
        /// <param name="dtime"></param>
        /// <returns></returns>
        public static int getWeekDay(this DateTime dtime)
        {
            return getWeekDay(dtime.Year, dtime.Month, dtime.Day);
        }

        /// <summary>
        /// 求某年有多少周
        /// </summary>
        /// <param name="dtime"></param>
        /// <returns></returns>
        public static int GetWeekOfYear(this DateTime dtime)
        {
            int countDay = DateTime.Parse(dtime.Year + "-12-31").DayOfYear;
            int countWeek = countDay / 7;
            return countWeek;
        }

        /// <summary>   
        /// 取得某月的第一天   
        /// </summary>   
        /// <param name="datetime">要取得月份第一天的时间</param>   
        /// <returns></returns>   
        private static DateTime FirstDayOfMonth(this DateTime datetime)
        {
            return datetime.AddDays(1 - datetime.Day);
        }

        /// <summary>  
        /// 取得某月的最后一天   
        /// </summary>   
        /// <param name="datetime">要取得月份最后一天的时间</param>   
        /// <returns></returns>   
        private static DateTime LastDayOfMonth(this DateTime datetime)
        {
            return datetime.AddDays(1 - datetime.Day).AddMonths(1).AddDays(-1);
        }

        /// <summary>  
        /// 取得上个月第一天   
        /// </summary>   
        /// <param name="datetime">要取得上个月第一天的当前时间</param>   
        /// <returns></returns>   
        private static DateTime FirstDayOfPreviousMonth(this DateTime datetime)
        {
            return datetime.AddDays(1 - datetime.Day).AddMonths(-1);
        }

        /// <summary>  
        /// 取得上个月的最后一天   
        /// </summary>   
        /// <param name="datetime">要取得上个月最后一天的当前时间</param>   
        /// <returns></returns>   
        private static DateTime LastDayOfPrdviousMonth(this DateTime datetime)
        {
            return datetime.AddDays(1 - datetime.Day).AddDays(-1);
        }

        /// <summary>
        /// 把月份转换成季度
        /// </summary>
        /// <param name="month"></param>
        /// <returns></returns>
        public static int GetQuarterByMonth(int month)
        {
            if (month < 1 || month > 12)
            {
                string message = String.Format("Input parameter month ({0}) out of range[1 -- 12].", month);
                throw new ArgumentOutOfRangeException("month", message);
            }

            return (month - 1) / 3 + 1;
        }
        #endregion
    }
}
