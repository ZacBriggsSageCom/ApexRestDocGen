/**
 * Test class for the Feedback Version REST controller.
 */
@isTest
public class FeedbackVersionRestTest {

    private static FeedItemModel feedback;
    private static ConversationModel conversation;

    private static void setUp() {
        fHCM2__Policy__c pol;
        pol = new fHCM2__Policy__c(Allow_Edit_Feedback__c = true);
        insert pol;
        fHCM2__Team_Member__c subject = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setPolicy(pol.Id)
                .build();
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(subject.Id)
                .addParticipant(subject)
                .save()
                .build();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(subject.Id)
                .setConversation(conversation.id)
                .save()
                .build();
    }

    /**
     * Builds URI string, given the URL params.
     */
    private static String buildURI(String feedbackId) {
        return FeedbackVersionRest.FEEDBACK_PARAM + '/'
                + feedbackId + '/'
                + FeedbackVersionRest.VERSION_PARAM;
    }

    @isTest
    private static void testGetFeedbackItemId() {

        // GIVEN I am viewing an item of my Feedback
        setUp();
        RestTestUtils.setupRestContext('GET', buildURI(feedback.id));

        // WHEN I get the Feedback item Id, THEN I receive the correct Id
        System.assertEquals(
                feedback.Id, FeedbackVersionRest.getFeedbackItemId());
    }

    @isTest
    private static void testGetTeamMemberFeedbackVersions() {

        // GIVEN I am viewing my own Feedback
        setUp();
        RestTestUtils.setupRestContext('GET', buildURI(feedback.id));

        // WHEN I ask for all its Versions via Rest
        FeedbackVersionRest.getTeamMemberFeedbackVersions();
        FeedbackVersionsResponseModel response =
                (FeedbackVersionsResponseModel) RestTestUtils.getResponseBody(
                        FeedbackVersionsResponseModel.class);

        // THEN the response code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND it contains one item
        System.assertEquals(1, response.history.size());

        // AND the item has the same Id as our Feedback's only Version
        Id versionId =
                FeedbackRepository.getFeedback(feedback.Id).Versions__r[0].Id;
        System.assertEquals(versionId, response.history[0].id);
    }

}