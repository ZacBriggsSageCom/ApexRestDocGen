/**
 * Tests exercising utilities for creating Notifications about Objective events.
 */
@isTest
public class ObjectiveNotificationUtilsTest {

    private static fHCM2__Team_Member__c subject;
    private static fHCM2__Team_Member__c viewer;
    private static ObjectiveModel objective;

    private static void setUp() {

        viewer = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setName('Wilma Worm')
                .build();

        subject = new TeamMemberTestUtils.TeamMemberBuilder()
                .setManager(viewer.Id)
                .setUser(TeamMemberTestUtils.createUser('Terrence', 'Tenrec').Id)
                .setName('Terrence Tenrec')
                .build();

        objective = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTeamMember(subject.Id)
                .setTitle('Title')
                .setStatus(ObjectiveUtils.STATUS_ACTIVE)
                .save()
                .build();
    }

    @isTest
    private static void testBuildLink() {

        // GIVEN some Objective
        setUp();

        // WHEN I build a link to the objective
        String actual = UrlTestUtils.replaceWithTestDomain(
                ObjectiveNotificationUtils.buildLinkSection(objective));

        // THEN I get the expected text
        String expectedLink = String.format(
                '<br />' + UrlTestUtils.TEST_DOMAIN + ObjectiveUrlUtils.OBJECTIVE_PAGE,
                new List<String>{subject.Id, objective.Id}
        );
        String expected = String.format(
                Label.Objective_Status_Change_Notification_Body_Link,
                new List<String>{expectedLink}
        );
        System.assertEquals(expected, actual);
    }

    @isTest
    private static void testGetNotificationRecipients() {
        // GIVEN some Objective
        setUp();

        // WHEN I try to get the recipients for the notification, THEN I get it
        System.assertEquals(
               subject.Id, 
               ObjectiveNotificationUtils.getNotificationRecipients(subject.Id));
    }
}