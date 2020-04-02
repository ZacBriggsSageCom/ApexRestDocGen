@isTest
public class FeedEventBuilderTest {

    public class MockFeedEventBuilder extends FeedEventBuilder {
        public override FeedItemModel addDetails(
                FeedItemModel item, Id viewerId, SObject subject) {
            return item;
        }
    }

    @isTest
    private static void testCreateBaseEvent() {

        // GIVEN the subject of an event
        fHCM2__Team_Member__c tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setName('Nutbad Gudsuyze')
                .build();
        PersonModel actor = TeamMemberUtils.createPerson(tm);
        Feed_Event__c event = FeedEventUtils.create(actor.id, 'Have a look at that');

        // WHEN I create a "base" event about it
        FeedItemModel baseEvent =
                new MockFeedEventBuilder().createBaseEvent(actor, event);

        // THEN it has the correct details
        System.assertEquals(event.Id, baseEvent.id);
        System.assertEquals(actor.id, baseEvent.event.actor.id);
        System.assertNotEquals(null, baseEvent.itemDate);
    }
}