/**
 * REST endpoint for Feedback Item Versions.
 */
@RestResource(urlMapping='/feedback/*/versions')
global class FeedbackVersionRest {

    @TestVisible
    private static final String FEEDBACK_PARAM = 'feedback';

    @TestVisible
    private static final String VERSION_PARAM = 'versions';

    /**
     * Get the Feedback item's ID from the URL.
     */
    @TestVisible
    private static Id getFeedbackItemId() {
        return Id.valueOf(RestUtils.getUrlParam(FEEDBACK_PARAM));
    }

    //==========================================================================
    // Operations
    //==========================================================================

    /**
     * Get all Versions for an item of Team Member Feedback.
     */
    @HttpGet
    global static void getTeamMemberFeedbackVersions() {
        try {

            // Retrieve Feedback item ID from URL
            Id feedbackItemId = getFeedbackItemId();

            // Attempt retrieval and construct response
            RestUtils.setResponseBody(
                    FeedbackController.getFeedbackVersions(feedbackItemId));

        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            RestUtils.setResponseBody(new FeedbackVersionsResponseModel(), e);
        }
    }
}
