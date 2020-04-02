@isTest
public class ObjectiveConversationHandlerTest {

    private static ConversationHandler handler;
    private static ConversationModel conversation;
    private static FeedItemModel feedback;
    private static fHCM2__Team_Member__c tm;
    private static ObjectiveModel obj;

    private static void setUp() {
        fHCM2__Policy__c pol = new fHCM2__Policy__c();
        insert pol;

        tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setName('Deepti')
                .setPolicy(pol.Id)
                .setUser(UserInfo.getUserId())
                .build();

        obj = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTitle('Do more work')
                .setTeamMember(tm.Id)
                .save()
                .build();

        handler = new ObjectiveConversationHandler();
        handler.setSubject(obj.Id);
    }

    private static void createConversation() {
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .addParticipant(tm)
                .setSubject(obj.Id)
                .save()
                .build();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(tm.Id)
                .setConversation(conversation.id)
                .setContent('You are oozeless')
                .save()
                .build();
    }

    @isTest
    private static void testCreateSubject() {

        // GIVEN an objective conversation handler
        setUp();

        // WHEN I use it to create a SubjectModel
        SubjectModel subject = handler.createSubject();

        // THEN I get the correct details
        System.assertEquals(obj.id, subject.id);
        System.assertEquals(obj.title, subject.name);
        System.assertEquals(tm.Id, subject.tmId);}

    @isTest
    private static void testGetTmId() {

        // GIVEN an objective conversation handler
        setUp();

        // WHEN I ask for the subject's TM ID, THEN I get the correct ID
        System.assertEquals(tm.Id, handler.getTmId());
    }

    @isTest
    private static void testGetJunctionField() {

        // GIVEN an objective conversation handler
        setUp();

        // WHEN I ask for the junction object's subject field
        // THEN I get the objective field
        System.assertEquals(
                ConversationSubjectUtils.OBJECTIVE_FIELD,
                handler.getJunctionField()
        );
    }

    @isTest
    private static void testGetLinkToComment() {

        // GIVEN an objective conversation and a handler for it
        setUp();
        createConversation();

        // WHEN I get the link to a specific comment
        String link = UrlTestUtils.replaceWithTestDomain(
                handler.getLinkToComment(feedback.id));

        // THEN it is of the correct format
        System.assert(Pattern.matches(
                UrlTestUtils.TEST_DOMAIN
                        + '/apex/Performance#/tm/'
                        + tm.Id
                        + '/objectives/'
                        + obj.id
                        + '#'                       // fragment identifier
                        + feedback.id,
                link
        ));
    }
}