// Deprecated
// (but preserved for coverage purposes)
@isTest
public class FeedbackRestTest {

    @isTest
    private static void testPost() {
        RestTestUtils.setupRestContext('POST', '/tm/id123/feedback/id123');
        FeedbackRest.insertTeamMemberFeedback();
        BaseResponseModel response = (BaseResponseModel)
                RestTestUtils.getResponseBody(BaseResponseModel.class);
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, response.getStatusCode());
    }

    @isTest
    private static void testPut() {
        RestTestUtils.setupRestContext('PUT', '/tm/id123/feedback/id123');
        FeedbackRest.updateTeamMemberFeedback();
        BaseResponseModel response = (BaseResponseModel)
                RestTestUtils.getResponseBody(BaseResponseModel.class);
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, response.getStatusCode());
    }

    @isTest
    private static void testGet() {
        RestTestUtils.setupRestContext('GET', '/tm/id123/feedback/id123');
        FeedbackRest.getTeamMemberFeedback();
        BaseResponseModel response = (BaseResponseModel)
                RestTestUtils.getResponseBody(BaseResponseModel.class);
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, response.getStatusCode());
    }

    @isTest
    private static void testDelete() {
        RestTestUtils.setupRestContext('DELETE', '/tm/id123/feedback/id123');
        FeedbackRest.deleteTeamMemberFeedback();
        BaseResponseModel response = (BaseResponseModel)
                RestTestUtils.getResponseBody(BaseResponseModel.class);
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, response.getStatusCode());
    }

}