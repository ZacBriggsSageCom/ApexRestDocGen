@isTest
public class ObjectiveCommentFeedGeneratorTest {

    private static fHCM2__Team_Member__c tm;
    private static ObjectiveModel objective1;
    private static ObjectiveModel objective2;
    private static ConversationModel conversation1;
    private static ConversationModel conversation2;
    private static FeedItemModel comment1;
    private static FeedItemModel comment2;
    private static ObjectiveCommentFeedGenerator generator;

    private static void setUp() {
        fHCM2__Policy__c pol = new fHCM2__Policy__c();
        insert pol;
        tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .setUser(UserInfo.getUserId())
                .build();
        objective1 = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTeamMember(tm.Id)
                .setTitle('Dare boldly')
                .save()
                .build();
        objective2 = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTeamMember(tm.Id)
                .setTitle('Achieve greatly')
                .save()
                .build();
        conversation1 = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(objective1.Id)
                .addParticipant(tm)
                .save()
                .build();
        comment1 = new FeedbackTestUtils.FeedbackBuilder()
                .setConversation(conversation1.id)
                .setContent('I must')
                .setAuthor(tm)
                .save()
                .build();
        conversation2 = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(objective2.Id)
                .addParticipant(tm)
                .save()
                .build();
        comment2 = new FeedbackTestUtils.FeedbackBuilder()
                .setConversation(conversation2.id)
                .setContent('I shall')
                .setAuthor(tm)
                .save()
                .build();
    }

    private static void buildGenerator() {
        List<Objective__c> objectives = ObjectiveRepository.getForTeamMember(tm.Id);
        generator = new ObjectiveCommentFeedGenerator(objectives);
    }

    ////////////////////////////////////////////////////////////////////////////
    // Test Methods
    ////////////////////////////////////////////////////////////////////////////

    @isTest
    private static void testGenerate() {

        // GIVEN a TM, two objectives and a comment about each
        setUp();

        // AND a built generator
        buildGenerator();

        // WHEN I generate the combined feed of items from all conversations
        List<FeedItemModel> items = generator.generate();

        // THEN it should contain the correct number of items
        System.assertEquals(2, items.size());

        // Force known ordering
        if (items[0].id != comment1.id) {
            items = new List<FeedItemModel>{items[1], items[0]};
        }

        // AND they should have the correct basic details
        System.assertEquals(comment1.content, items[0].content);
        System.assertEquals(tm.Id, items[0].comment.author.id);

        System.assertEquals(comment2.content, items[1].content);
        System.assertEquals(tm.Id, items[1].comment.author.id);

        // AND they should include the proper event details
        System.assertEquals(Label.Objectives_Process_Name, items[0].event.processTitle);
        System.assertEquals(objective1.title, items[0].event.linkText);
        System.assertEquals(tm.Id, items[0].event.actor.id);

        System.assertEquals(Label.Objectives_Process_Name, items[1].event.processTitle);
        System.assertEquals(objective2.title, items[1].event.linkText);
        System.assertEquals(tm.Id, items[1].event.actor.id);
    }

    @isTest
    private static void testAddEventDetails() {

        // GIVEN an item
        setUp();

        // AND the objective it relates to
        Objective__c objective = ObjectiveRepository.get(objective1.id);

        // AND a built generator
        buildGenerator();

        // AND an appropriate conversation handler
        ConversationHandler handler = new ObjectiveConversationHandler();
        handler.setSubject(objective1.id);

        // WHEN I add the event details
        FeedItemModel updatedItem = generator.addEventDetails(comment1, objective, handler);

        // THEN it has the correct process title
        System.assertEquals(Label.Objectives_Process_Name, updatedItem.event.processTitle);

        // AND the correct actor ID
        System.assertEquals(tm.Id, updatedItem.event.actor.id);

        // AND the correct link text
        System.assertEquals(objective.Title__c, updatedItem.event.linkText);

        // AND its URL is of the correct format
        System.assert(Pattern.matches(
                UrlTestUtils.TEST_DOMAIN
                        + '/apex/Performance#/tm/'
                        + tm.Id
                        + '/objectives/'
                        + objective.Id
                        + '#'                           // fragment identifier
                        + comment1.id,
                UrlTestUtils.replaceWithTestDomain(updatedItem.event.url)
        ));
    }
}