@isTest
public class FeedEventUtilsTest {

    @isTest
    private static void testCreate() {

        // GIVEN a subject for an event
        fHCM2__Team_Member__c tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .build();

        // WHEN I create the event
        FeedEventUtils.create(tm.Id, 'TM Created');

        // THEN it has the correct details
        List<Feed_Event__c> events =
                FeedEventRepository.getBySubjects(new Set<Id>{tm.Id});
        System.assertEquals(1, events.size());
        System.assertEquals(tm.Id, events[0].Actor__c);
        System.assertNotEquals(null, events[0].Date__c);
        System.assertEquals(tm.Id, events[0].Subject__c);
        System.assertEquals('TM Created', events[0].Type__c);
    }
}