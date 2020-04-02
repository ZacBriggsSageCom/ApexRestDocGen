/**
 * Utility class for dealing with dates.
 */
public class DateUtils {

    /**
     * Converts a Date to an ISO string in the format required by Angular's
     * date pipe.
     *
     * See:
     * https://www.w3.org/TR/NOTE-datetime
     * https://salesforce.stackexchange.com/a/196104
     *
     * @param d
     * @return String
     */
    public static String dateToString(Date d) {
        Datetime dt = (Datetime) d;
        return dt == null
                ? null
                : dt.format('YYYY-MM-dd');
    }

    /**
     * Converts a Datetime to a string, using the user's time zone.
     *
     * @param d
     * @return String
     */
    public static String datetimeToStringInUserTimeZone(Datetime d) {
        return datetimeToString(d, UserInfo.getTimeZone());
    }

    /**
     * Converts a Datetime to an ISO string in the format required by Angular's
     * date pipe.
     *
     * See:
     * https://www.w3.org/TR/NOTE-datetime
     * https://salesforce.stackexchange.com/a/165257
     *
     * @param d
     * @param tz
     * @return String
     */
    public static String datetimeToString(Datetime d, TimeZone tz) {
        return d == null
                ? null
                : d.format('YYYY-MM-dd\'T\'HH:mm:ssXXX', tz.getID());
    }

    /**
     * Converts a String to a Date.
     *
     * @param str Date string in the format "yyyy-MM-dd".
     */
    public static Date stringToDate(String str) {
        return String.isBlank(str)
                ? null
                : Date.valueOf(str + ' 00:00:00');
    }

    /**
     * Converts a String to a DateTime.
     *
     * @param str Date string in the format "yyyy-MM-dd".
     */
    public static Datetime stringToDateTime(String str) {
        return String.isBlank(str)
                ? null
                : Datetime.valueOf(str.replace('T',' '));
    }

}
