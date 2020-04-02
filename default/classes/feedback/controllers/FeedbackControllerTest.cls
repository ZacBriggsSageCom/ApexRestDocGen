/**
 * Tests exercising the Feedback module controller.
 */
@isTest
public class FeedbackControllerTest {

    private static fHCM2__Policy__c pol;
    private static fHCM2__Team_Member__c subject;
    private static fHCM2__Team_Member__c viewer;
    private static FeedItemModel feedback;
    private static ConversationModel conversation;

    //==========================================================================
    // Setup Methods
    //==========================================================================

    /**
     * Set up with the subject being the viewer.
     */
    private static void setUpAsTm() {
        createPolicy();
        viewer = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setName('Wilma Worm')
                .setPolicy(pol.Id)
                .build();
        subject = viewer;
    }

    /**
     * Set up with viewer being the subject's primary manager.
     */
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

    /**
     * Set up with the subject being unrelated to the viewer.
     */
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

    /**
     * Create and save some default Feedback about the subject, by the viewer.
     */
    private static void createExistingFeedback() {
        createConversation();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(viewer.Id)
                .setConversation(conversation.id)
                .save()
                .build();
    }

    /**
     * Create and save a Conversation between the subject and the viewer, and
     * about the subject.
     */
    private static void createConversation() {
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(subject.Id)
                .addParticipant(subject)
                .addParticipant(viewer)
                .save()
                .build();
    }

    //==========================================================================
    // Test Methods
    //==========================================================================

    @isTest
    private static void testGetFeedbackVersions_ForMe() {

        // GIVEN some Feedback with one version that relates to me
        setUpAsTm();
        createExistingFeedback();

        // WHEN I ask for all of its versions
        FeedbackVersionsResponseModel response =
                FeedbackController.getFeedbackVersions(feedback.id);

        // THEN the response is built
        System.assertNotEquals(null, response);

        // AND the status code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());
    }

    @isTest
    private static void testGetFeedbackVersions_ForMyDirectReport() {

        // GIVEN some Feedback with one version that relates to my direct report
        setUpAsManager();
        createExistingFeedback();

        // WHEN I ask for all of its versions
        FeedbackVersionsResponseModel response =
                FeedbackController.getFeedbackVersions(feedback.id);

        // THEN the response is built
        System.assertNotEquals(null, response);

        // AND the status code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());
    }

    @isTest
    private static void testGetFeedbackVersions_ForStranger() {

        // GIVEN some Team Member Feedback which I have no business viewing
        setUpAsStranger();
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(subject.Id)
                .addParticipant(subject)
                .save()
                .build();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(viewer.Id)
                .setConversation(conversation.id)
                .save()
                .build();

        // WHEN I ask for all of its versions
        FeedbackVersionsResponseModel response =
                FeedbackController.getFeedbackVersions(feedback.id);

        // THEN I receive no versions
        System.assertEquals(null, response.history);

        // AND the status code is FORBIDDEN
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Conversation_Access_Denied, response.error.error);
    }

    @isTest
    private static void testGetFeedbackVersions_InvalidFeedbackId() {

        // GIVEN some Feedback with one version that relates to me
        setUpAsTm();
        createExistingFeedback();

        // WHEN I ask for all of its versions using the wrong Id
        FeedbackVersionsResponseModel response =
                FeedbackController.getFeedbackVersions('bejuras');

        // THEN I receive no versions
        System.assertEquals(null, response.history);

        // AND the status code is BAD_REQUEST
        System.assertEquals(
                HttpUtils.STATUS_BAD_REQUEST, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Comment_Id_Invalid, response.error.error);
    }

    @isTest
    private static void testGetFeedbackVersions_FeedbackDoesNotExist() {

        // GIVEN I am trying to get the versions for a Feedback item that has
        // been deleted
        setUpAsTm();
        createConversation();
        Comment__c item = new Comment__c(Conversation__c = conversation.Id);
        insert item;
        Id feedbackId = item.Id;
        delete item;

        // WHEN I ask for it
        FeedbackVersionsResponseModel response =
                FeedbackController.getFeedbackVersions(feedbackId);

        // THEN I receive no versions
        System.assertEquals(null, response.history);

        // AND the status code is NOT_FOUND
        System.assertEquals(
                HttpUtils.STATUS_NOT_FOUND, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Comment_Does_Not_Exist, response.error.error);
    }

    @isTest
    private static void testInsertFeedback_ForMe() {

        // GIVEN some new Feedback relating to me
        setUpAsTm();
        createConversation();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setConversation(conversation.Id)
                .setAuthor(viewer.Id)
                .build();

        // WHEN I try to insert it
        FeedbackResponseModel response =
                FeedbackController.insertFeedback(feedback);

        // THEN the response is built
        System.assertNotEquals(null, response.item);

        // AND the operations returns an OK status code
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());
    }

    @isTest
    private static void testInsertFeedback_ForMyDirectReport() {

        // GIVEN some Feedback relating to my direct report
        setUpAsManager();
        createConversation();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setConversation(conversation.Id)
                .setAuthor(viewer.Id)
                .build();

        // WHEN I try to insert it
        FeedbackResponseModel response =
                FeedbackController.insertFeedback(feedback);

        // THEN the response is built
        System.assertNotEquals(null, response.item);

        // AND the operations returns an OK status code
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());
    }

    @isTest
    private static void testInsertFeedback_ForStranger() {

        // GIVEN some Feedback which I have no business saving
        setUpAsStranger();
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(subject.Id)
                .addParticipant(subject)
                .save()
                .build();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setConversation(conversation.Id)
                .setAuthor(viewer.Id)
                .build();

        // WHEN I try to insert it
        FeedbackResponseModel response =
                FeedbackController.insertFeedback(feedback);

        // THEN the operations returns a FORBIDDEN status code
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Conversation_Access_Denied, response.error.error);

        // AND the Feedback has not been saved
        System.assertEquals(0, [SELECT Id FROM Comment__c].size());
    }

    @isTest
    private static void testInsertFeedback_InvalidConversationId() {

        // GIVEN I am trying to save a Feedback item with an invalid Conversation ID
        setUpAsTm();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(viewer.Id)
                .build();
        feedback.conversationId = 'memory IS RAM';

        // WHEN I attempt to save it
        FeedbackResponseModel response = FeedbackController.insertFeedback(feedback);

        // THEN the status code is BAD_REQUEST
        System.assertEquals(HttpUtils.STATUS_BAD_REQUEST, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Conversation_Id_Invalid, response.error.error);

        // AND the Feedback has not been saved
        System.assertEquals(0, [SELECT Id FROM Comment__c].size());
    }

    @isTest
    private static void testInsertFeedback_ConversationDoesNotExist() {

        // GIVEN I am trying to save a Feedback item to a non-existent Conversation
        setUpAsTm();
        Conversation__c conversation = new Conversation__c();
        insert conversation;
        Id conversationId = conversation.Id;
        delete conversation;
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setConversation(conversationId)
                .setAuthor(viewer.Id)
                .build();

        // WHEN I attempt to save it
        FeedbackResponseModel response = FeedbackController.insertFeedback(feedback);

        // THEN the status code is NOT_FOUND
        System.assertEquals(HttpUtils.STATUS_NOT_FOUND, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Conversation_Does_Not_Exist, response.error.error);

        // AND the Feedback has not been saved
        System.assertEquals(0, [SELECT Id FROM Comment__c].size());
    }

    @isTest
    private static void testInsertFeedback_FeedbackAlreadyExists() {

        // GIVEN some Feedback relating to me but which already exists
        setUpAsTm();
        createConversation();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setConversation(conversation.Id)
                .setAuthor(viewer.Id)
                .save()
                .build();

        // AND some change which has not been saved
        feedback.content = 'some garbage';

        // WHEN I try to insert the Feedback item
        FeedbackResponseModel response =
                FeedbackController.insertFeedback(feedback);

        // THEN the operations returns a CONFLICT status code
        System.assertEquals(HttpUtils.STATUS_CONFLICT, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Comment_Already_Exists, response.error.error);

        // AND the Feedback has not been saved
        Comment__c feedbackRecord = FeedbackRepository.getFeedback(feedback.id);
        System.assertEquals(null, feedbackRecord.Author_Type__c);
    }

    @isTest
    private static void testUpdateFeedback_ForMe() {

        // GIVEN some Feedback relating to me, which I have written
        setUpAsTm();
        createExistingFeedback();

        // AND some change I want to make to it
        feedback.content = 'I am the best';

        // WHEN I try to update the Feedback record
        FeedbackResponseModel response =
                FeedbackController.updateFeedback(feedback);

        // THEN the response is built
        System.assertNotEquals(null, response.item);

        // AND the operations returns an OK status code
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());
    }

    @isTest
    private static void testUpdateFeedback_ForStranger() {

        // GIVEN some Feedback I have no business editing
        setUpAsStranger();
        createConversation();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setConversation(conversation.Id)
                .setAuthor(subject.Id)
                .save()
                .build();

        // AND some change I want to make to it
        feedback.content = 'walking tour?';

        // WHEN I try to update the Feedback record
        FeedbackResponseModel response =
                FeedbackController.updateFeedback(feedback);

        // THEN the operation returns a FORBIDDEN status code
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Comment_Edit_Denied, response.error.error);

        // AND the edit is not saved
        Comment__c feedbackRecord = FeedbackRepository.getFeedback(feedback.id);
        System.assertEquals(null, feedbackRecord.Author_Type__c);
    }

    @isTest
    private static void testUpdateFeedback_InvalidConversationId() {

        // GIVEN I am trying to update a Feedback item with an invalid Conversation ID
        setUpAsTm();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(viewer.Id)
                .build();
        feedback.conversationId = 'memory IS RAM';

        // WHEN I attempt to update it
        FeedbackResponseModel response = FeedbackController.updateFeedback(feedback);

        // THEN the status code is BAD_REQUEST
        System.assertEquals(HttpUtils.STATUS_BAD_REQUEST, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Conversation_Id_Invalid, response.error.error);
    }

    @isTest
    private static void testUpdateFeedback_ConversationDoesNotExist() {

        // GIVEN I am trying to update a Feedback item in a non-existent Conversation
        setUpAsTm();
        Conversation__c conversation = new Conversation__c();
        insert conversation;
        Id conversationId = conversation.Id;
        delete conversation;
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setConversation(conversationId)
                .setAuthor(viewer.Id)
                .build();

        // WHEN I attempt to update it
        FeedbackResponseModel response = FeedbackController.updateFeedback(feedback);

        // THEN the status code is NOT_FOUND
        System.assertEquals(HttpUtils.STATUS_NOT_FOUND, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Conversation_Does_Not_Exist, response.error.error);
    }

    @isTest
    private static void testUpdateFeedback_InvalidFeedbackId() {

        // GIVEN some Feedback relating to me, which has an invalid ID
        setUpAsTm();
        createConversation();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setConversation(conversation.Id)
                .setAuthor(viewer.Id)
                .build();
        feedback.id = 'potato';

        // AND some change I want to make to it
        feedback.content = 'an invalid edit';

        // WHEN I try to update the Feedback record
        FeedbackResponseModel response =
                FeedbackController.updateFeedback(feedback);

        // THEN the operation returns a BAD_REQUEST status code
        System.assertEquals(
                HttpUtils.STATUS_BAD_REQUEST, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Comment_Id_Invalid, response.error.error);

        // AND the Feedback is not saved
        List<Comment__c> records = [SELECT Id FROM Comment__c];
        System.assertEquals(0, records.size());
    }

    @isTest
    private static void testUpdateFeedback_FeedbackDoesNotExist() {

        // GIVEN I am trying to update a Feedback item that has been deleted
        setUpAsTm();
        createExistingFeedback();
        delete [SELECT Id FROM Comment__c];
        feedback.content = 'Sue me now, uncle!';

        // WHEN I attempt to update it
        FeedbackResponseModel response = FeedbackController.updateFeedback(feedback);

        // THEN the status code is NOT_FOUND
        System.assertEquals(HttpUtils.STATUS_NOT_FOUND, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Comment_Does_Not_Exist, response.error.error);
    }

}