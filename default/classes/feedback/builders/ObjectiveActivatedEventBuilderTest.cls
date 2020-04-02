@isTest
public class ObjectiveActivatedEventBuilderTest {

    private static fHCM2__Team_Member__c tm;
    private static ObjectiveActivatedEventBuilder builder;
    private static PersonModel actor;

    private static void setUp() {
        tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setName('Dan Quill')
                .build();
        actor = TeamMemberUtils.createPerson(tm);

        builder = new ObjectiveActivatedEventBuilder();
    }

    @isTest
    private static void testAddDetails() {

        // GIVEN an objective
        setUp();
        ObjectiveModel om = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTeamMember(tm.Id)
                .setTitle('Learn from Jey')
                .setStatus(ObjectiveUtils.STATUS_ACTIVE)
                .save()
                .build();

        // AND an event describing its activation
        Feed_Event__c event =
                FeedEventUtils.create(om.id, FeedEventTypes.OBJECTIVE_ACTIVATED);

        // AND a half-made FeedItemModel describing the event
        FeedItemModel item = builder.createBaseEvent(actor, event);

        // WHEN I add the remaining details
        item = builder.addDetails(item, actor.id, ObjectiveRepository.get(om.id));

        // THEN they are correct
        System.assertEquals(om.title, item.event.linkText);
        System.assertEquals(Label.Objective_Activated_Event_Message_You, item.content);
        System.assertEquals(Label.Objectives_Process_Name, item.event.processTitle);
    }

    @isTest
    private static void testGetContentWhenActorIsMe() {

        // GIVEN I am the actor of an activation event
        setUp();

        // WHEN I get the content wording for it
        // THEN the label is correct
        System.assertEquals(
                Label.Objective_Activated_Event_Message_You,
                builder.getContent(tm.Id, actor)
        );
    }

    @isTest
    private static void testGetContentWhenActorIsSomeoneElse() {

        // GIVEN someone else is the actor of an activation event
        builder = new ObjectiveActivatedEventBuilder();
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