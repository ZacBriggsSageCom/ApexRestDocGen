public class FeedItemModelBuilder {

    /**
     * Converts a Comment record into a FeedItemModel.
     */
    public static FeedItemModel buildFromComment(
            Comment__c record,
            fHCM2__Team_Member__c author) {

        FeedItemModel model = new FeedItemModel();
        model.id = record.Id;
        model.itemDate = DateUtils.datetimeToStringInUserTimeZone(record.Created_Date__c);
        model.conversationId = record.Conversation__c;

        model.comment = new CommentModel();
        model.comment.version = (Integer) record.Current_Version__c;
        model.comment.author = TeamMemberUtils.createPerson(author);
        if (!record.Versions__r.isEmpty()) {
            model.content = record.Versions__r[0].Content__c;
            model.comment.latestVersionDate = DateUtils.datetimeToStringInUserTimeZone(
                record.Versions__r[0].Created_Date__c);
        }

        return model;
    }

    /**
     * Converts Comment records into FeedItemModels.
     */
    public static List<FeedItemModel> buildFromComments(List<Comment__c> records) {

        // Collect author details in bulk
        Set<Id> authorIds = new Set<Id>();
        for (Comment__c record : records) {
            authorIds.add(record.Author__c);
        }
        Map<Id, fHCM2__Team_Member__c> authors = new Map<Id, fHCM2__Team_Member__c>(
                TeamMemberRepository.get(authorIds));

        // Build models
        List<FeedItemModel> models = new List<FeedItemModel>();
        for (Comment__c record : records) {
            models.add(buildFromComment(record, authors.get(record.Author__c)));
        }
        return models;
    }

    /**
     * Creates a FeedItemModel for each Version of a supplied Comment record.
     */
    public static List<FeedItemModel> buildFromCommentsByVersion(
            Comment__c record,
            fHCM2__Team_Member__c author) {

        List<FeedItemModel> models = new List<FeedItemModel>();
        PersonModel authorPerson = TeamMemberUtils.createPerson(author);

        for (Comment_Version__c version : record.Versions__r) {
            FeedItemModel model = new FeedItemModel();
            model.id = version.Id;
            model.content = version.Content__c;
            model.conversationId = record.Conversation__c;
            model.itemDate =
                    DateUtils.datetimeToStringInUserTimeZone(version.Created_Date__c);

            model.comment = new CommentModel();
            model.comment.version = (Integer) version.Version__c;
            model.comment.author = authorPerson;
            models.add(model);
        }
        return models;
    }

}