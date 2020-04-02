/**
 * REST endpoint for Comments.
 */
@RestResource(urlMapping='/conversation/*/comment/*')
global class CommentRest {

    @TestVisible
    private static final String CONVERSATION_PARAM = 'conversation';

    @TestVisible
    private static final String COMMENT_PARAM = 'comment';

    /**
     * Get Conversation ID from the URL.
     */
    @TestVisible
    private static Id getConversationId() {
        return Id.valueOf(RestUtils.getUrlParam(CONVERSATION_PARAM));
    }

    /**
     * Get the Feedback item ID from the URL.
     */
    @TestVisible
    private static Id getFeedbackItemId() {
        return Id.valueOf(RestUtils.getUrlParam(COMMENT_PARAM));
    }

    //==========================================================================
    // Operations
    //==========================================================================

    /**
     * Save a new Feedback item.
     * N.B. The "TeamMember" portion of the method name is vestigial.
     */
    @HttpPost
    global static void insertTeamMemberFeedback() {
        try {

            // Retrieve Feedback from request
            FeedItemModel feedback = (FeedItemModel)
                    RestUtils.getRequestBody(FeedItemModel.class);

            // Override stored Conversation ID using URL
            feedback.conversationId = getConversationId();

            // Attempt insertion and construct response
            RestUtils.setResponseBody(FeedbackController.insertFeedback(feedback));

        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            RestUtils.setResponseBody(new FeedbackResponseModel(), e);
        }
    }

    /**
     * Update an existing Feedback item.
     * N.B. The "TeamMember" portion of the method name is vestigial.
     */
    @HttpPut
    global static void updateTeamMemberFeedback() {
        try {

            // Retrieve Feedback from request
            FeedItemModel feedback = (FeedItemModel)
                    RestUtils.getRequestBody(FeedItemModel.class);

            // Override stored Conversation ID using URL
            feedback.conversationId = getConversationId();

            // Attempt update and construct response
            RestUtils.setResponseBody(FeedbackController.updateFeedback(feedback));

        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            RestUtils.setResponseBody(new FeedbackResponseModel(), e);
        }
    }

    //==========================================================================
    // Deprecated Operations
    //==========================================================================

    /**
     * Deprecated because GET method handling has been moved to ConversationRest.
     */
    @HttpGet
    global static void getTeamMemberFeedback() {
        RestUtils.setResponseBody(
                new BaseResponseModel(new ErrorModel(
                        HttpUtils.STATUS_FORBIDDEN,
                        'GET not permitted.',
                        '')));
    }

    /**
     * Deprecated because we did not remove this ability until after the first
     * package had been built.
     */
    @HttpDelete
    global static void deleteTeamMemberFeedback() {
        RestUtils.setResponseBody(
                new BaseResponseModel(new ErrorModel(
                        HttpUtils.STATUS_FORBIDDEN,
                        'DELETE not permitted.',
                        '')));
    }

}
