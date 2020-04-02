// Deprecated
@RestResource(urlMapping='/tm/*/feedback/*')
global class FeedbackRest {

    private static void complain() {
        RestUtils.setResponseBody(
                new BaseResponseModel(new ErrorModel(
                        HttpUtils.STATUS_FORBIDDEN,
                        'Invalid REST URL',
                        '')));
    }

    @HttpPost
    global static void insertTeamMemberFeedback() {
        complain();
    }

    @HttpPut
    global static void updateTeamMemberFeedback() {
        complain();
    }

    @HttpGet
    global static void getTeamMemberFeedback() {
        complain();
    }

    @HttpDelete
    global static void deleteTeamMemberFeedback() {
        complain();
    }

}
