/**
 * Class for building ConversationModels from Conversation records.
 */
public class ConversationModelBuilder {

    /**
     * Builds a ConversationModel, given the record, subject, participants, and
     * contents.
     */
    public static ConversationModel build(
            Conversation__c conversation,
            SubjectModel subject,
            List<PersonModel> participants,
            List<FeedItemModel> items) {

        ConversationModel model = new ConversationModel();
        Viewport viewport = new Viewport();
        model.id = conversation.Id;
        model.name = conversation.name;
        model.subject = subject;
        model.participants = participants;
        model.items = items;
        model.viewerTmId = viewport.getViewerTeamMemberId();
        model.viewerCanEdit = viewport.canViewerEditFeedback();
        return model;
    }
}
