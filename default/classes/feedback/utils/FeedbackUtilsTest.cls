@isTest
public class FeedbackUtilsTest {

    private static FeedItemModel feedback;
    private static ConversationModel conversation;
    private static ContentVersion contentVersion;
    private static fHCM2__Policy__c pol;
    private static fHCM2__Team_Member__c subject;
    private static fHCM2__Team_Member__c viewer;

    private static void setUp() {
        createPolicy();
        viewer = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .setUser(UserInfo.getUserId())
                .setName('Samantha Shrike')
                .build();
        subject = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .setName('Wilhelm Weasel')
                .setManager(viewer.Id)
                .build();
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(subject.Id)
                .addParticipant(subject)
                .addParticipant(viewer)
                .save()
                .build();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(subject.Id)
                .setAuthorType(TeamMemberUtils.SELF)
                .setConversation(conversation.id)
                .setContent('Gaze upon my works, ye mighty, and despair')
                .save()
                .build();
        contentVersion = FileTestUtils.createDefaultFileLinkedTo(feedback.id);
    }

    private static void createPolicy() {
        pol = new fHCM2__Policy__c(Allow_Edit_Feedback__c = true);
        insert pol;
    }

    //==========================================================================
    // Utilities
    //==========================================================================

    private static String cleanDate(Datetime d) {
        return DateUtils.datetimeToStringInUserTimeZone(d);
    }

    //==========================================================================
    // Test Methods
    //==========================================================================

    @isTest
    private static void testGetFeedback() {

        // GIVEN a set of one Feedback item to get
        setUp();
        Set<Id> feedbackIds = new Set<Id>{feedback.id};

        // WHEN I get it
        List<FeedItemModel> items = FeedbackUtils.getFeedback(feedbackIds);
        FeedItemModel item = items.get(0);

        // THEN I get a list of one item
        System.assertEquals(1, items.size());

        // AND it has the correct ID
        System.assertEquals(feedback.id, item.id);

        // AND it has the correct conversation ID
        System.assertEquals(feedback.conversationId, item.conversationId);

        // AND it has the correct current version
        System.assertEquals(1, item.comment.version);

        // AND it has the correct author
        PersonModel author = item.comment.author;
        System.assertEquals(subject.id, author.id);
        System.assertEquals(subject.Name, author.name);
        System.assert(author.pictureUrl.contains('NoPicture'));

        // AND it has the correct content
        System.assertEquals(feedback.content, item.content);

        // AND it has the correct creation date
        Comment__c record = FeedbackRepository.getFeedback(feedback.id);
        String creationDate = cleanDate(record.Created_Date__c);
        System.assertEquals(creationDate, item.itemDate);

        // AND it has the correct latest version date
        String latestVersionDate = cleanDate(record.Versions__r[0].Created_Date__c);
        System.assertEquals(latestVersionDate, item.comment.latestVersionDate);

        // AND it has the correct attachment
        List<FileModel> files = item.comment.attachments;
        FileModel file = files.get(0);
        System.assertEquals(1, files.size());
        System.assertEquals(contentVersion.ContentDocumentId, file.contentDocumentId);
        System.assertEquals(contentVersion.Title, file.title);
    }

    @isTest
    private static void testGetFeedbackVersionsFor() {

        // GIVEN an ID for some Feedback Item that has two versions
        setUp();
        feedback.content = 'We will fight them on the beaches';
        FeedbackUtils.updateFeedback(feedback);

        // WHEN I get all its versions
        List<FeedItemModel> versions = FeedbackUtils.getFeedbackVersionsFor(feedback.id);

        // THEN I get two versions
        System.assertEquals(2, versions.size());

        // AND they are in the correct order
        System.assertEquals(2, versions.get(0).comment.version);
        System.assertEquals(1, versions.get(1).comment.version);

        // AND they have the correct IDs
        Comment__c parent = FeedbackRepository.getFeedback(feedback.id);
        Id newestId = parent.Versions__r.get(0).Id;
        Id oldestId = parent.Versions__r.get(1).Id;
        System.assertEquals(newestId, versions.get(0).id);
        System.assertEquals(oldestId, versions.get(1).id);

        // AND they have the correct conversation ID
        System.assertEquals(conversation.id, versions.get(0).conversationId);
        System.assertEquals(conversation.id, versions.get(1).conversationId);

        // AND they have the correct author
        PersonModel newestAuthor = versions.get(0).comment.author;
        System.assertEquals(viewer.id, newestAuthor.id);
        System.assertEquals(viewer.Name, newestAuthor.name);
        System.assert(newestAuthor.pictureUrl.contains('NoPicture'));

        PersonModel oldestAuthor = versions.get(1).comment.author;
        System.assertEquals(viewer.id, oldestAuthor.id);
        System.assertEquals(viewer.Name, oldestAuthor.name);
        System.assert(oldestAuthor.pictureUrl.contains('NoPicture'));

        // AND they have the correct content
        System.assertEquals(
                'We will fight them on the beaches', versions.get(0).content);
        System.assertEquals(
                'Gaze upon my works, ye mighty, and despair', versions.get(1).content);

        // AND they have the correct dates
        String newestDate = cleanDate(parent.Versions__r.get(0).Created_Date__c);
        String oldestDate = cleanDate(parent.Versions__r.get(1).Created_Date__c);
        System.assertEquals(newestDate, versions.get(0).itemDate);
        System.assertEquals(oldestDate, versions.get(1).itemDate);
    }

    @isTest
    private static void testInsertFeedback() {

        // GIVEN I have some Feedback to insert
        setUp();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(viewer.Id)
                .setConversation(conversation.id)
                .setContent('Gaze upon my works, ye mighty, and despair')
                .build();

        // Remove author - we needed it to build the FeedItemModel
        feedback.comment.author = null;

        // AND a temporary attachment which should be added to it
        ContentVersion version = FileTestUtils.createDefaultFileLinkedTo(subject.Id);
        feedback.comment.attachments = new List<FileModel>{FileModelBuilder.build(version)};

        // WHEN I insert the item
        FeedItemModel savedItem = FeedbackUtils.insertFeedback(feedback);

        // THEN the ID is populated
        System.assertNotEquals(null, savedItem.id);

        // AND the item has been saved
        System.assertNotEquals(null, FeedbackRepository.getFeedback(savedItem.id));

        // AND the Conversation ID is correct
        System.assertEquals(conversation.id, savedItem.conversationId);

        // AND it has the correct version number
        System.assertEquals(1, savedItem.comment.version);

        // AND it has the correct author
        PersonModel author = savedItem.comment.author;
        System.assertEquals(viewer.id, author.id);
        System.assertEquals(viewer.Name, author.name);
        System.assert(author.pictureUrl.contains('NoPicture'));

        // AND it has the correct created date
        String creationDate = cleanDate(
                FeedbackRepository.getFeedback(feedback.id).Created_Date__c);
        System.assertEquals(creationDate, savedItem.itemDate);

        // AND it has the correct latest version date
        String latestVersionDate = cleanDate(
                FeedbackRepository.getFeedback(feedback.id).Versions__r[0].Created_Date__c);
        System.assertEquals(latestVersionDate, savedItem.comment.latestVersionDate);

        // AND it has the correct contents
        System.assertEquals(feedback.content, savedItem.content);

        // AND it has the correct attachment
        List<FileModel> files = savedItem.comment.attachments;
        FileModel file = files.get(0);
        System.assertEquals(1, files.size());
        System.assertEquals(version.Title, file.title);

        // AND it has been linked to the attachment in the database
        System.assertEquals(1, FileUtils.getFiles(savedItem.id).size());
    }

    @isTest
    private static void testUpdateFeedback() {

        // GIVEN I have some Feedback
        setUp();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(viewer.Id)
                .setConversation(conversation.id)
                .setContent('Gaze upon my works, ye mighty, and despair')
                .save()
                .build();

        // AND an update to make to it
        feedback.content = 'There are no facts, only interpretations.';

        // Remove author - we needed it to build the FeedItemModel
        feedback.comment.author = null;

        // AND a temporary attachment which should be added to it
        ContentVersion version = FileTestUtils.createDefaultFileLinkedTo(subject.Id);
        feedback.comment.attachments = new List<FileModel>{
                FileModelBuilder.build(version)
        };

        // WHEN I update the item
        FeedItemModel updatedItem = FeedbackUtils.updateFeedback(feedback);

        // THEN its ID is unchanged
        System.assertEquals(feedback.id, updatedItem.id);

        // AND a new version has been saved
        System.assertEquals(
                2, FeedbackRepository.getFeedback(updatedItem.id).Versions__r.size());

        // AND the Conversation ID is correct
        System.assertEquals(conversation.id, updatedItem.conversationId);

        // AND it has the correct version number
        System.assertEquals(2, updatedItem.comment.version);

        // AND it has the correct author
        PersonModel author = updatedItem.comment.author;
        System.assertEquals(viewer.id, author.id);
        System.assertEquals(viewer.Name, author.name);
        System.assert(author.pictureUrl.contains('NoPicture'));

        // AND it has the correct created date
        String creationDate = cleanDate(
                FeedbackRepository.getFeedback(feedback.id).Created_Date__c);
        System.assertEquals(creationDate, updatedItem.itemDate);

        // AND it has the correct latest version date
        String latestVersionDate = cleanDate(
                FeedbackRepository.getFeedback(feedback.id).Versions__r[0].Created_Date__c);
        System.assertEquals(latestVersionDate, updatedItem.comment.latestVersionDate);

        // AND it has the correct contents
        System.assertEquals(feedback.content, updatedItem.content);

        // AND it has the correct attachment
        List<FileModel> files = updatedItem.comment.attachments;
        FileModel file = files.get(0);
        System.assertEquals(1, files.size());
        System.assertEquals(version.Title, file.title);
    }

    @isTest
    private static void testGetConversationID() {

        // GIVEN I have some Feedback
        setUp();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(viewer.Id)
                .setConversation(conversation.id)
                .setContent('Gaze upon my works, ye mighty, and despair')
                .build();

        FeedbackUtils.insertFeedback(feedback);

        // WHEN I get the conversation ID for this feedback
        ID retrievedId = FeedbackUtils.getConversationId(feedback.Id);

        // THEN it is the correct conversation ID.
        System.assertEquals(conversation.Id, retrievedId);
    }

    @isTest
    private static void testGetConversationSubjectID() {

        //GIVEN I have some feedback
        setUp();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(viewer.Id)
                .setConversation(conversation.id)
                .setContent('Gaze upon my works, ye mighty, and despair')
                .build();

        FeedbackUtils.insertFeedback(feedback);

        // WHEN I get the subject's ID from conversation for this feedback
        Id retrievedSubjectID = FeedbackUtils.getConversationSubjectId(feedback.Id);
        //THEN it is the correct subject ID
        System.assertEquals(subject.Id, retrievedSubjectID);
    }

    private static void testGetOtherParticipants() {

        // GIVEN a Conversation between two people
        // AND some Feedback written by the subject
        setUp();

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

        // WHEN I get all participants other than this item's author
        Set<Id> otherParticipants = FeedbackUtils.getOtherParticipants(feedback);

        // THEN I get just the viewer's ID
        System.assertEquals(1, otherParticipants.size());
        System.assert(otherParticipants.contains(viewer.Id));
    }

    @isTest
    private static void testAddAuthorTo() {

        // GIVEN a Feedback item whose subject is my direct report
        setUp();
        FeedItemModel feedback = new FeedItemModel();
        feedback.comment = new CommentModel();
        feedback.conversationId = conversation.id;

        // WHEN I add author details to it using the current context
        feedback = FeedbackUtils.addAuthorTo(feedback);

        // THEN it has the correct author ID
        System.assertEquals(viewer.Id, feedback.comment.author.id);
    }
}