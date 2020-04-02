@isTest
public class ConversationBySubjectRestTest {

    private static fHCM2__Team_Member__c subject;
    private static ConversationModel conversation;

    private static void setUp() {
        fHCM2__Policy__c pol = new fHCM2__Policy__c();
        insert pol;

        subject = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .setUser(UserInfo.getUserId())
                .build();

        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(subject.Id)
                .addParticipant(subject.Id)
                .save()
                .build();
    }

    //==========================================================================
    // Utility Methods
    //==========================================================================

    /**
     * Buils URI string, given the subject ID URL param.
     */
    private static String buildURI(String subjectId) {
        return '/' + ConversationBySubjectRest.CONVERSATION_PARAM
                + '/' + ConversationBySubjectRest.SUBJECT_PARAM
                + '/' + subjectId;
    }

    /**
     * Gets HTTP response, if expecting a ConversationResponseModel.
     */
    private static ConversationResponseModel receiveResponse() {
        return (ConversationResponseModel) RestTestUtils.getResponseBody(
                ConversationResponseModel.class);
    }

    //==========================================================================
    // Test Methods
    //==========================================================================

    @isTest
    private static void testGetSubjectId() {

        // GIVEN I am viewing a conversation by subject
        setUp();
        RestTestUtils.setupRestContext('GET', buildURI(subject.Id));

        // WHEN I get the subject ID from the URL, THEN it is correct
        System.assertEquals(subject.id, ConversationBySubjectRest.getSubjectId());
    }

    @isTest
    private static void testGetConversationBySubject() {

        // GIVEN a conversation
        setUp();
        RestTestUtils.setupRestContext('GET', buildURI(subject.Id));

        // WHEN I ask for it by its subject's ID
        ConversationBySubjectRest.getConversationBySubject();
        ConversationResponseModel response = receiveResponse();

        // THEN the status code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND the response does not contain an error
        System.assertEquals(null, response.error);

        // AND the response contains the Conversation
        System.assertNotEquals(null, response.conversation);
    }
}