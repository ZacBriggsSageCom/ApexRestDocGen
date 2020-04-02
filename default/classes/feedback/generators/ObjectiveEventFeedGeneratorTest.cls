@isTest
public class ObjectiveEventFeedGeneratorTest {

    @isTest
    private static void testGenerate() {

        // GIVEN a TM
        fHCM2__Policy__c pol = new fHCM2__Policy__c();
        insert pol;
        fHCM2__Team_Member__c tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .setUser(UserInfo.getUserId())
                .build();

        // AND two objectives of theirs
        ObjectiveModel objective1 = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTeamMember(tm.Id)
                .setTitle('Dare boldly')
                .save()
                .build();
        ObjectiveModel objective2 = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTeamMember(tm.Id)
                .setTitle('Achieve greatly')
                .save()
                .build();

        // AND events regarding each of these objectives
        Feed_Event__c event1 = FeedEventUtils.create(
                objective1.id, FeedEventTypes.OBJECTIVE_ACTIVATED);
        Feed_Event__c event2 = FeedEventUtils.create(
                objective2.id, FeedEventTypes.OBJECTIVE_CLOSED);

        // WHEN I generate a feed of events
        List<Objective__c> objectives = ObjectiveRepository.getForTeamMember(tm.Id);
        List<FeedItemModel> events =
                new ObjectiveEventFeedGenerator(objectives).generate();

        // Force known ordering
        if (events[0].id != event1.id) {
            events = new List<FeedItemModel>{events[1], events[0]};
        }

        // THEN it should contain the correct number of items
        System.assertEquals(2, events.size());

        // AND they should have the correct details
        // N.B. We don't need to assert everything here as the event generators
        // have their own tests
        System.assertEquals(tm.Id, events[0].event.actor.id);
        System.assertEquals(tm.Id, events[1].event.actor.id);
        System.assertEquals(objective1.title, events[0].event.linkText);
        System.assertEquals(objective2.title, events[1].event.linkText);
        System.assertEquals(
                ObjectiveUtils.OBJECTIVES_PROCESS_NAME, events[0].event.processTitle);
        System.assertEquals(
                ObjectiveUtils.OBJECTIVES_PROCESS_NAME, events[1].event.processTitle);
    }

    @isTest
    private static void testGenerateWithUnknownEventType() {

        // GIVEN a TM
        fHCM2__Policy__c pol = new fHCM2__Policy__c();
        insert pol;
        fHCM2__Team_Member__c tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .setUser(UserInfo.getUserId())
                .build();

        // AND an objective of theirs
        ObjectiveModel objective = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTeamMember(tm.Id)
                .setTitle('Dare boldly')
                .save()
                .build();

        // AND an event regarding this objective which is of an unknown type
        Feed_Event__c event =
                FeedEventUtils.create(objective.Id, 'Objective Obdurated');

        // WHEN I generate a feed of events
        List<Objective__c> objectives = ObjectiveRepository.getForTeamMember(tm.Id);
        List<FeedItemModel> events =
                new ObjectiveEventFeedGenerator(objectives).generate();

        // THEN it should contain no items
        System.assertEquals(0, events.size());
    }
}