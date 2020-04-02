@isTest
public class ObjectiveClosedEventBuilderTest {

    private static fHCM2__Team_Member__c tm;
    private static ObjectiveClosedEventBuilder builder;
    private static PersonModel actor;

    private static void setUp() {
        tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setName('Eddie Summers')
                .build();
        actor = TeamMemberUtils.createPerson(tm);

        builder = new ObjectiveClosedEventBuilder();
    }

    @isTest
    private static void testAddDetails() {

        // GIVEN an objective
        setUp();
        ObjectiveModel om = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTeamMember(tm.Id)
                .setTitle('Learn JavaScript')
                .setStatus(ObjectiveUtils.STATUS_CLOSED)
                .save()
                .build();

        // AND an event describing its closure
        Feed_Event__c event =
                FeedEventUtils.create(om.id, FeedEventTypes.OBJECTIVE_CLOSED);

        // AND a half-made FeedItemModel describing the event
        FeedItemModel item = builder.createBaseEvent(actor, event);

        // WHEN I add the remaining details
        item = builder.addDetails(item, actor.id, ObjectiveRepository.get(om.id));

        // THEN they are correct
        System.assertEquals(om.title, item.event.linkText);
        System.assertEquals(Label.Objective_Closed_Event_Message_You, item.content);
        System.assertEquals(Label.Objectives_Process_Name, item.event.processTitle);
    }

    @isTest
    private static void testGetContentWhenActorIsMe() {

        // GIVEN I am the actor of a closure event
        setUp();

        // WHEN I get the content wording for it
        // THEN the label is correct
        System.assertEquals(
                Label.Objective_Closed_Event_Message_You,
                builder.getContent(tm.Id, actor)
        );
    }

    @isTest
    private static void testGetContentWhenActorIsSomeoneElse() {

        // GIVEN someone else is the actor of a closure event
        builder = new ObjectiveClosedEventBuilder();
        fHCM2__Team_Member__c actorTm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setName('Dwight Schrute')
                .build();
        actor = TeamMemberUtils.createPerson(actorTm);
        actor.firstName = 'Dwight';
        fHCM2__Team_Member__c viewer = new TeamMemberTestUtils.TeamMemberBuilder()
                .setName('Jim Halpert')
                .setUser(UserInfo.getUserId())
                .build();

        // WHEN I get the content wording for it
        String content = builder.getContent(viewer.Id, actor);

        // THEN the label is correct
        System.assert(Pattern.matches('Dwight.*?', content));
    }
}