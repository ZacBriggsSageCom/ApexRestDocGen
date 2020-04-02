public class FeedbackUtils {

    public static final String FEEDBACK_TYPE =
            NamespaceUtils.getNamespacePrefix() + 'Comment__c';

    /**
     * Gets all Feedback with IDs in the given Set as FeedItemModels, populating
     * author details and attachments.
     */
    public static List<FeedItemModel> getFeedback(Set<Id> feedbackIds) {
        List<Comment__c> records = FeedbackRepository.getFeedbackWithIds(feedbackIds);
        List<FeedItemModel> models = FeedItemModelBuilder.buildFromComments(records);
        return addAttachments(models, FileUtils.getFiles(feedbackIds));
    }

    /**
     * Given a Feedback item ID, finds all of its Versions.
     */
    public static List<FeedItemModel> getFeedbackVersionsFor(Id feedbackId) {

        // Get the Feedback item
        Comment__c feedbackRecord = FeedbackRepository.getFeedback(feedbackId);

        // Find the Conversation
        Id conversationId = FeedbackUtils.getConversationId(feedbackId);

        // Convert item to models representing all versions
        return FeedItemModelBuilder.buildFromCommentsByVersion(
                feedbackRecord,
                TeamMemberRepository.get(feedbackRecord.Author__c)
        );
    }

    /**
     * Saves a new item of Feedback and returns it.
     */
    public static FeedItemModel insertFeedback(FeedItemModel feedback) {

        // Add author information from current user
        feedback = addAuthorTo(feedback);

        // Create Feedback parent
        Comment__c feedbackRecord = FeedbackRecordBuilder.build(feedback, 1);
        FeedbackRepository.insertRecord(feedbackRecord);
        feedback.id = feedbackRecord.Id;

        // Create Feedback version
        Comment_Version__c feedbackVersion = new Comment_Version__c(
                Comment__c = feedbackRecord.Id,
                Content__c = feedback.content,
                Version__c = 1
        );
        FeedbackVersionRepository.insertRecord(feedbackVersion);

        // Copy any attachments to the Feedback item
        FileUtils.copyFilesToParent(feedback.comment.attachments, feedbackRecord.Id);

        // Send notification to other participants
        Notification notification = NewCommentNotification.create(feedback);
        notification.send();

        // Refresh local copy
        feedbackRecord = FeedbackRepository.getFeedback(feedbackRecord.Id);

        // Add author details
        fHCM2__Team_Member__c author = TeamMemberRepository.get(feedbackRecord.Author__c);

        // Build model
        FeedItemModel insertedFeedback = FeedItemModelBuilder.buildFromComment(
                feedbackRecord, author);

        // Add attachments
        insertedFeedback.comment.attachments = FileUtils.getFiles(insertedFeedback.id);

        return insertedFeedback;
    }

    /**
     * Updates an existing Feedback item and returns it.
     */
    public static FeedItemModel updateFeedback(FeedItemModel feedback) {

        // Add author information from current user
        feedback = addAuthorTo(feedback);

        // Get details from existing record
        Comment__c existingRecord = FeedbackRepository.getFeedback(feedback.Id);
        Integer nextVersionNumber = (Integer) existingRecord.Current_Version__c + 1;
        Comment_Version__c previousVersion = existingRecord.Versions__r[0];
        feedback.comment.version = nextVersionNumber;

        // Update Feedback record
        Comment__c feedbackRecord =
                FeedbackRecordBuilder.build(feedback, nextVersionNumber);
        FeedbackRepository.updateRecord(feedbackRecord);

        // Create new version
        Comment_Version__c feedbackVersion = new Comment_Version__c(
                Comment__c = feedbackRecord.Id,
                Content__c = feedback.content,
                Version__c = nextVersionNumber
        );
        FeedbackVersionRepository.insertRecord(feedbackVersion);

        // Copy any new attachments to the Feedback item
        FileUtils.copyFilesToParent(feedback.comment.attachments, feedback.id);
        feedback.comment.attachments = FileUtils.getFiles(feedback.id);

        // Send notification to other participants
        Notification notification =
                EditedCommentNotification.create(previousVersion, feedback);
        notification.send();

        // Refresh local copy of new version; use its date in model
        feedbackVersion =
                FeedbackVersionRepository.getFeedbackVersion(feedbackVersion.Id);
        feedback.comment.latestVersionDate = DateUtils.datetimeToStringInUserTimeZone(
                feedbackVersion.Created_Date__c);

        return feedback;
    }

    /**
     * Gets the ID of a Feedback item's parent Conversation.
     */
    public static Id getConversationId(Id feedbackId) {
        return FeedbackRepository.getFeedback(feedbackId).Conversation__c;
    }

    /**
     * Gets the ID of the subject of a Feedback item's parent Conversation.
     */
    public static Id getConversationSubjectId(Id feedbackId) {
        return ConversationUtils.createSubjectForConversation(
                    getConversationId(feedbackId)).id;
    }

    /**
     * Adds Author Id and Type to the supplied FeedItemModel from context.
     */
    public static FeedItemModel addAuthorTo(FeedItemModel feedback) {

        // Find subject
        SubjectModel subject = ConversationUtils.createSubjectForConversation(
                    feedback.conversationId);

        // Add author
        Viewport viewport = new Viewport(subject.tmId);
        feedback.comment.author =
                TeamMemberUtils.createPerson(viewport.getViewerTeamMemberId());
        return feedback;
    }

    /**
     * Given some Feedback items and a map of Feedback item ID => FileModels,
     * adds the FileModels to the Feedback items by ID.
     */
    public static List<FeedItemModel> addAttachments(
            List<FeedItemModel> items,
            Map<Id, List<FileModel>> filesByItem) {

        for (FeedItemModel item : items) {
            for (Id itemId : filesByItem.keySet()) {
                if (itemId == item.id) {
                    item.comment.attachments = filesByItem.get(itemId);
                }
            }
        }
        return items;
    }

    /**
     * Given an item of Feedback, gets the TM Ids of all the people involved in
     * the conversation apart from the author.
     */
    public static Set<Id> getOtherParticipants(FeedItemModel feedback) {

        // Get all participants
        List<PersonModel> participants =
                ConversationUtils.getParticipants(feedback.conversationId);

        // Filter out author
        Set<Id> ids = new Set<Id>();
        for (PersonModel participant : participants) {
            if (participant.id != feedback.comment.author.id) {
                ids.add(participant.id);
            }
        }
        return ids;
    }
}