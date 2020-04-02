/**
 * Utility class for sending Notifications.
 */
public class NotificationUtils {

    /**
     * Send a notification email using the given details.
     *
     * @param recipients
     * @param title
     * @param body
     */
    public static void sendEmail(Set<Id> recipients, String title, String body) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        /*
         * Don't try to send if:
         *  - We can't find valid addresses
         *  - We don't have enough emails left in our daily org allowance
         */
        List<String> toAddresses =
                TeamMemberUtils.getUserEmailAddresses(recipients);
        if (!isAllowanceAvailable(recipients.size()) || toAddresses.isEmpty()) {
            return;
        }

        mail.setToAddresses(toAddresses);
        mail.setSubject(title);
        mail.setHtmlBody(body);

        // Attempt to send email
        try {
            Messaging.sendEmail(new List<Messaging.Email>{mail});
        } catch (Exception e) {
            System.debug('Failed to send email: ' + e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }

    /**
     * Check whether we have enough emails left to send in our allowance to
     * send the specified number.
     *
     * @param numberToSend
     * @return Boolean
     */
    private static Boolean isAllowanceAvailable(Integer numberToSend) {
        return (Limits.getLimitEmailInvocations() - Limits.getEmailInvocations())
                >= numberToSend;
    }

}