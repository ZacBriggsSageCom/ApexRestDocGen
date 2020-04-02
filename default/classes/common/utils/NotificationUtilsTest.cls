@isTest
public class NotificationUtilsTest {

    private static User user;
    private static fHCM2__Team_Member__c tm;

    private static void setUp() {
        user = TeamMemberTestUtils.createUser('DeAndre', 'Way');
        tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(user.Id)
                .build();
    }

    @isTest
    private static void testSendEmail() {
        setUp();

        // GIVEN an email to send
        // WHEN I send it
        Test.startTest();
        NotificationUtils.sendEmail(
                new Set<Id>{tm.Id},
                'Yooo',
                'Crank that'
        );

        // THEN an email has been sent
        System.assertEquals(1, Limits.getEmailInvocations());
        Test.stopTest();
    }

    @isTest
    private static void testEmailIsNotSent_WhenThereAreNoRecipients() {

        // GIVEN a possible recipient who does not have a User
        setUp();
        tm.fHCM2__User__c = null;
        update tm;

        // WHEN I attempt to send an email
        Test.startTest();
        NotificationUtils.sendEmail(
                new Set<Id>{tm.Id},
                'Hello?',
                'Is anyone there?'
        );

        // THEN no emails were sent
        System.assertEquals(0, Limits.getEmailInvocations());
        Test.stopTest();
    }
}