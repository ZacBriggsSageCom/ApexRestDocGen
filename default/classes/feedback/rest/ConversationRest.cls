/**
 * REST endpoint for Conversations.
 */
@RestResource(urlMapping='/conversation/*')
global class ConversationRest {

    @TestVisible
    private static final String CONVERSATION_PARAM = 'conversation';

    /**
     * Get Conversation ID from the URL.
     */
    @TestVisible
    private static Id getConversationId() {
        return Id.valueOf(RestUtils.getUrlParam(CONVERSATION_PARAM));
    }

    //==========================================================================
    // Operations
    //==========================================================================

    /**
     * Get a Conversation by ID.
     */
    @HttpGet
    global static void getConversation() {
        try {

            // Get Conversation ID
            Id conversationId = getConversationId();

            // Attempt retrieval and construct response
            RestUtils.setResponseBody(ConversationController.getConversation(
                    conversationId));

        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            RestUtils.setResponseBody(new ConversationResponseModel(), e);
        }
    }

    /**
     * Save a new Conversation.
     */
    @HttpPost
    global static void insertConversation() {
        try {

            // Retrieve Conversation from request body
            ConversationModel conversation = (ConversationModel)
                    RestUtils.getRequestBody(ConversationModel.class);

            // Attempt insertion and construct response
            RestUtils.setResponseBody(
                    ConversationController.insertConversation(conversation));

        } catch (Exception e) {
            RestUtils.setResponseBody(new ConversationResponseModel(), e);
        }
    }
}
