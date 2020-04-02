/**
 * Tests exercising the Conversations controller.
 */
@isTest
public class ConversationControllerTest {

    private static fHCM2__Policy__c pol;
    private static fHCM2__Team_Member__c subject;
    private static fHCM2__Team_Member__c viewer;
    private static fHCM2__Team_Member__c manager;
    private static FeedItemModel feedback;
    private static ConversationModel conversation;
    private static ObjectiveModel objective;

    //==========================================================================
    // Setup Methods
    //==========================================================================

    private static void setUpAsTm() {
        createPolicy();
        viewer = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setName('Wilma Worm')
                .setPolicy(pol.Id)
                .build();
        subject = viewer;
    }

    private static void setUpAsManager() {
        createPolicy();
        viewer = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setName('Pandora Panda')
                .setPolicy(pol.Id)
                .build();
        subject = new TeamMemberTestUtils.TeamMemberBuilder()
                .setManager(viewer.Id)
                .setUser(TeamMemberTestUtils.createUser('Terrence', 'Tenrec').Id)
                .setName('Terrence Tenrec')
                .build();
    }

    private static void setUpHavingManager() {
        createPolicy();
        manager = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(TeamMemberTestUtils.createUser('Terrence', 'Tenrec').Id)
                .setName('Terrence Tenrec')
                .setPolicy(pol.Id)
                .build();
        viewer = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setName('Robert Liston')
                .setManager(manager.Id)
                .setPolicy(pol.Id)
                .build();
    }

    private static void setUpAsStranger() {
        createPolicy();
        viewer = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setPolicy(pol.Id)
                .build();
        subject = new TeamMemberTestUtils.TeamMemberBuilder().build();
    }

    private static void createPolicy() {
        pol = new fHCM2__Policy__c(Allow_Edit_Feedback__c = true);
        insert pol;
    }

    private static void createExistingFeedback() {
        createContinuousConversation();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(viewer.Id)
                .setConversation(conversation.id)
                .save()
                .build();
    }

    private static void createContinuousConversation() {
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(subject.Id)
                .addParticipant(subject)
                .addParticipant(viewer)
                .save()
                .build();
    }

    private static void createObjective() {
        objective = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTitle('Expand and multiply')
                .setTeamMember(subject.Id)
                .save()
                .build();
    }

    //==========================================================================
    // Test Methods
    //==========================================================================

    @isTest
    private static void testGetConversation_ForMe() {

        // GIVEN some Feedback that relates to me
        setUpAsTm();
        createExistingFeedback();

        // WHEN I ask for my Conversation
        ConversationResponseModel response =
                ConversationController.getConversation(conversation.Id);

        // THEN the Conversation is built
        System.assertNotEquals(null, response.conversation);

        // AND the status code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());
    }

    @isTest
    private static void testGetConversation_ForMyDirectReport() {

        // GIVEN some Feedback that relates to my direct report
        setUpAsManager();
        createExistingFeedback();

        // WHEN I ask for the Conversation
        ConversationResponseModel response =
                ConversationController.getConversation(conversation.Id);

        // THEN the Conversation is built
        System.assertNotEquals(null, response.conversation);

        // AND the status code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());
    }

    @isTest
    private static void testGetConversation_ForStranger() {

        // GIVEN some Team Member Feedback which I have no business viewing
        setUpAsStranger();
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(subject.Id)
                .addParticipant(subject)
                .save()
                .build();

        // WHEN I ask for their Conversation
        ConversationResponseModel response =
                ConversationController.getConversation(conversation.Id);

        // THEN I do not receive a Conversation
        System.assertEquals(null, response.conversation);

        // AND the status code is FORBIDDEN
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Conversation_Access_Denied, response.error.error);
    }

    @isTest
    private static void testGetConversation_ConversationDoesNotExist() {

        // GIVEN I am trying to get a Conversation which has been deleted
        Conversation__c conv = new Conversation__c();
        insert conv;
        Id conversationId = conv.Id;
        delete conv;

        // WHEN I ask for it
        ConversationResponseModel response =
                ConversationController.getConversation(conversationId);

        // THEN I do not receive a Conversation
        System.assertEquals(null, response.conversation);

        // AND the status code is NOT_FOUND
        System.assertEquals(HttpUtils.STATUS_NOT_FOUND, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Conversation_Does_Not_Exist, response.error.error);
    }

    @isTest
    private static void testGetConversation_InvalidId() {

        // GIVEN some Feedback that relates to me
        setUpAsTm();
        createExistingFeedback();

        // WHEN I ask for a Conversation with an invalid ID
        ConversationResponseModel response =
                ConversationController.getConversation('bejuras');

        // THEN I do not receive a Conversation
        System.assertEquals(null, response.conversation);

        // AND the status code is BAD_REQUEST
        System.assertEquals(
                HttpUtils.STATUS_BAD_REQUEST, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Conversation_Id_Invalid, response.error.error);
    }

    @isTest
    private static void testGetConversationBySubjectWhenSubjectIsMe() {

        // GIVEN a conversation about me
        setUpAsTm();
        createContinuousConversation();

        // WHEN I get it using my own ID
        ConversationResponseModel response =
                ConversationController.getConversationBySubject(subject.Id);

        // THEN the status code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND I get the conversation
        System.assertNotEquals(null, response.conversation);

        // AND there is no error
        System.assertEquals(null, response.error);
    }

    @isTest
    private static void testGetConversationBySubjectWhenSubjectIsMyDirectReport() {

        // GIVEN a conversation about my direct report
        setUpAsManager();
        createContinuousConversation();

        // WHEN I get it using my report's ID
        ConversationResponseModel response =
                ConversationController.getConversationBySubject(subject.Id);

        // THEN the status code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND I get the conversation
        System.assertNotEquals(null, response.conversation);

        // AND there is no error
        System.assertEquals(null, response.error);
    }

    @isTest
    private static void testGetConversationBySubjectWhenSubjectIsMyObjective() {

        // GIVEN an objective and a conversation about it
        setUpAsTm();
        createObjective();
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(objective.id)
                .addParticipant(subject)
                .save()
                .build();

        // WHEN I get the conversation
        ConversationResponseModel response =
                ConversationController.getConversationBySubject(objective.Id);

        // THEN the status code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND I get the conversation
        System.assertNotEquals(null, response.conversation);

        // AND there is no error
        System.assertEquals(null, response.error);

    }

    @isTest
    private static void testGetConversationBySubjectWhenOneNeedsCreating() {

        // GIVEN a valid subject and no conversation
        setUpAsTm();

        // WHEN I start the conversation about the subject
        ConversationResponseModel response =
                ConversationController.getConversationBySubject(subject.Id);

        // THEN the status code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND I get the conversation
        System.assertNotEquals(null, response.conversation);

        // AND there is no error
        System.assertEquals(null, response.error);
    }

    @isTest
    private static void testGetConversationBySubjectWithInvalidId() {

        // GIVEN an invalid ID, WHEN I try to find a conversation using it
        ConversationResponseModel response =
                ConversationController.getConversationBySubject('two seconds in');

        // THEN the status code is BAD REQUEST
        System.assertEquals(HttpUtils.STATUS_BAD_REQUEST, response.getStatusCode());

        // AND I get nothing
        System.assertEquals(null, response.conversation);

        // AND the error message is correct
        System.assertEquals(Label.Subject_ID_Invalid, response.error.error);
    }

    @isTest
    private static void testGetConversationBySubjectWithNonExistentSubject() {

        // GIVEN the ID of an object which does not exist
        setUpAsTm();
        delete subject;

        // WHEN I try to find a conversation about it
        ConversationResponseModel response =
                ConversationController.getConversationBySubject(subject.Id);

        // THEN the status code is NOT FOUND
        System.assertEquals(HttpUtils.STATUS_NOT_FOUND, response.getStatusCode());

        // AND I get nothing
        System.assertEquals(null, response.conversation);

        // AND the error message is correct
        System.assertEquals(Label.Subject_Does_Not_Exist, response.error.error);
    }

    @isTest
    private static void testGetConversationBySubjectWhenNotParticipant() {

        // GIVEN a conversation to which I am not privy
        setUpAsStranger();
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(subject.Id)
                .addParticipant(subject.Id)
                .save()
                .build();

        // WHEN I try to get its contents
        ConversationResponseModel response =
                ConversationController.getConversationBySubject(subject.Id);

        // THEN the status code is FORBIDDEN
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, response.getStatusCode());

        // AND I get nothing
        System.assertEquals(null, response.conversation);

        // AND the error message is correct
        System.assertEquals(Label.Conversation_Access_Denied, response.error.error);
    }

    @isTest
    private static void testGetConversationBySubjectWhenSubjectInvalidType() {

        // GIVEN some object which is not valid as a conversation subject
        setUpAsTm();

        // WHEN I try to start a conversation about it
        ConversationResponseModel response =
                ConversationController.getConversationBySubject(pol.Id);

        // THEN the status code is BAD REQUEST
        System.assertEquals(HttpUtils.STATUS_BAD_REQUEST, response.getStatusCode());

        // AND I get nothing
        System.assertEquals(null, response.conversation);

        // AND the error message is correct
        System.assertEquals(Label.Invalid_Subject_Type, response.error.error);
    }

    @isTest
    private static void testGetConversationBySubjectWhenViewerCannotCreate() {

        // GIVEN I am a stranger
        setUpAsStranger();

        // WHEN I try to start a new conversation about someone
        ConversationResponseModel response =
                ConversationController.getConversationBySubject(subject.Id);

        // THEN the status code is FORBIDDEN
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, response.getStatusCode());

        // AND I get nothing
        System.assertEquals(null, response.conversation);

        // AND the error message is correct
        System.assertEquals(Label.Conversation_Creation_Denied, response.error.error);
    }

    @isTest
    private static void testInsertConversation() {

        // GIVEN I have a Conversation to save
        setUpAsTm();
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(subject.Id)
                .addParticipant(subject)
                .addParticipant(viewer)
                .build();

        // WHEN I try to save it
        ConversationResponseModel response =
                ConversationController.insertConversation(conversation);

        // THEN I receive the built Conversation
        System.assertNotEquals(null, response.conversation);

        // AND the status code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());
    }

    @isTest
    private static void testInsertConversation_WhenConversationAlreadyExists() {

        // GIVEN I have a Conversation to save, but it already exists
        setUpAsTm();
        createContinuousConversation();

        // WHEN I try to save it
        ConversationResponseModel response =
                ConversationController.insertConversation(conversation);

        // THEN I do not receive it back
        System.assertEquals(null, response.conversation);

        // AND the status code is CONFLICT
        System.assertEquals(
                HttpUtils.STATUS_CONFLICT, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Conversation_Already_Exists, response.error.error);
    }

    @isTest
    private static void testInsertConversation_WhenSubjectIsMissing() {

        // GIVEN I have a Conversation to save, but it has no subject
        setUpAsTm();
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .addParticipant(subject)
                .addParticipant(viewer)
                .build();

        // WHEN I try to save it
        ConversationResponseModel response =
                ConversationController.insertConversation(conversation);

        // THEN I do not receive it back
        System.assertEquals(null, response.conversation);

        // AND the status code is BAD_REQUEST
        System.assertEquals(
                HttpUtils.STATUS_BAD_REQUEST, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Conversation_Has_No_Subject, response.error.error);
    }

    @isTest
    private static void testInsertConversation_WhenParticipantsAreMissing() {

        // GIVEN I have a Conversation to save, but it has no participants
        setUpAsTm();
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(subject.Id)
                .build();

        // WHEN I try to save it
        ConversationResponseModel response =
                ConversationController.insertConversation(conversation);

        // THEN I do not receive it back
        System.assertEquals(null, response.conversation);

        // AND the status code is BAD_REQUEST
        System.assertEquals(
                HttpUtils.STATUS_BAD_REQUEST, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(
                Label.Conversation_Has_No_Participants, response.error.error);
    }
}