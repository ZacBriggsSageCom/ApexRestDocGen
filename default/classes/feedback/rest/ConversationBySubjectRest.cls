/**
 * REST endpoint for Conversations, referenced by their subjects.
 */
@RestResource(urlMapping='/conversation/subject/*')
global class ConversationBySubjectRest {

    @TestVisible
    private static final String CONVERSATION_PARAM = 'conversation';

    @TestVisible
    private static final String SUBJECT_PARAM = 'subject';

    /**
     * Gets subject ID from the URL.
     */
    @TestVisible
    private static Id getSubjectId() {
        return Id.valueOf(RestUtils.getUrlParam(SUBJECT_PARAM));
    }

    //==========================================================================
    // Operations
    //==========================================================================

    @HttpGet
    global static void getConversationBySubject() {
        try {

            // Get subject ID
            Id subjectId = getSubjectId();

            // Attempt retrieval and construct response
            RestUtils.setResponseBody(
                    ConversationController.getConversationBySubject(subjectId));

        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            RestUtils.setResponseBody(new ConversationResponseModel(), e);
        }
    }
}