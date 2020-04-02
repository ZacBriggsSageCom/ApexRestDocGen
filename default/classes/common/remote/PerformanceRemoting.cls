/**
 * Remote actions for the Performance app.
 */
public class PerformanceRemoting {

    ////////////////////////////////////////////////////////////////////////////
    // Conversations
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Retrieves the list of possible subjects.
     */
    @RemoteAction
    public static ConversationSelectionsResponseModel getTeam() {
        return TeamController.getTeam();
    }

    /**
     * Retrieve a Conversation by ID.
     */
    @RemoteAction
    public static ConversationResponseModel getConversation(String conversationId) {
        return ConversationController.getConversation(conversationId);
    }

    /**
     * Retrieve a Conversation by its subject's ID.
     */
    @RemoteAction
    public static ConversationResponseModel getConversationBySubject(String subjectId) {
        return ConversationController.getConversationBySubject(subjectId);
    }

    /**
     * Save a new Conversation.
     */
    @RemoteAction
    public static ConversationResponseModel insertConversation(ConversationModel conversation) {
        return ConversationController.insertConversation(conversation);
    }

    ////////////////////////////////////////////////////////////////////////////
    // Comments
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Retrieves all Versions for a Comment
     */
    @RemoteAction
    public static FeedbackVersionsResponseModel getCommentVersions(String feedbackId) {
        return FeedbackController.getFeedbackVersions(feedbackId);
    }

    /**
     * Saves a new Team Member Feedback item.
     */
    @RemoteAction
    public static FeedbackResponseModel insertComment(FeedItemModel feedback) {
        return FeedbackController.insertFeedback(feedback);
    }

    /**
     * Updates an existing Team Member Feedback item.
     */
    @RemoteAction
    public static FeedbackResponseModel updateComment(FeedItemModel feedback) {
        return FeedbackController.updateFeedback(feedback);
    }

    ////////////////////////////////////////////////////////////////////////////
    // Objectives
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Gets all of a team member's objectives.
     */
    @RemoteAction
    public static ObjectiveListResponseModel getObjectives(String tmId) {
        return ObjectivesController.getObjectives(tmId);
    }

    /**
     * Inserts an objective.
     */
    @RemoteAction
    public static EditObjectiveResponseModel insertObjective(ObjectiveModel objective) {
        return ObjectivesController.createObjective(objective);
    }

    /**
     * Edits an objective
     */
    @RemoteAction
    public static EditObjectiveResponseModel editObjective(ObjectiveModel objective) {
        return ObjectivesController.editObjective(objective);
    }

    /**
     * Deletes an objective by ID.
     */
    @RemoteAction
    public static BaseResponseModel deleteObjective(String objectiveId) {
        return ObjectivesController.deleteObjective(objectiveId);
    }

    /**
     * Activates an objective
     */
    @RemoteAction
    public static EditObjectiveResponseModel activateObjective(ObjectiveModel objective) {
        return ObjectivesController.activateObjective(objective);
    }

    /**
     * Changes the status of an active objective to closed.
     */
    @RemoteAction
    public static EditObjectiveResponseModel closeObjective(String objectiveId) {
        return ObjectivesController.closeObjective(objectiveId);
    }

    ////////////////////////////////////////////////////////////////////////////
    // Performance
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Gets the Global Configuration for the Performance app.
     */
    @RemoteAction
    public static GlobalConfigResponseModel getGlobalConfig() {
        return GlobalConfigController.getGlobalConfig();
    }

    /**
     * Gets the Id of the logged-in Team Member.
     */
    @RemoteAction
    public static ViewerContextResponseModel getViewerContext() {
        return ViewerContextController.getViewerContext();
    }

    /**
     * Gets the Manager Dashboard.
     */
    @RemoteAction
    public static ManagerDashboardResponseModel getManagerDashboard() {
        return ManagerDashboardController.getDirectReportsDetails();
    }

    ////////////////////////////////////////////////////////////////////////////
    // Process Details
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Retrieves the details of the Performance Overview process.
     */
    @RemoteAction
    public static ProcessDetailsResponseModel getPerformanceOverviewDetails(
            String tmId) {
        return ProcessDetailsController.getPerformanceOverviewDetails(tmId);
    }
}

