/**
 * Tests exercising methods for database operations with Feedback Item Versions.
 */
@isTest
public class FeedbackVersionRepositoryTest {

    private static Comment_Version__c getDefaultVersion() {
        Conversation__c conversation = new Conversation__c();
        insert conversation;
        Comment__c feedback = new Comment__c(Conversation__c = conversation.Id);
        insert feedback;

        return new Comment_Version__c(
            Comment__c = feedback.Id,
            Content__c = 'Some content',
            Version__c = 1
        );
    }

    private static List<Comment_Version__c> getAllVersions() {
        return [SELECT Id, Version__c FROM Comment_Version__c];
    }

    @isTest
    private static void testInsertRecord() {

        // GIVEN a Feedback Item Version
        Comment_Version__c version = getDefaultVersion();

        // WHEN I insert it
        FeedbackVersionRepository.insertRecord(version);

        // THEN it is persisted
        System.assertEquals(1, getAllVersions().size());
    }

    @isTest
    private static void testUpdateRecord() {

        // GIVEN a Feedback Item Version which already exists
        Comment_Version__c version = getDefaultVersion();
        insert version;

        // WHEN I update it
        version.Version__c = 2;
        FeedbackVersionRepository.updateRecord(version);

        // THEN the update is persisted
        Decimal versionNumber =
                FeedbackVersionRepository.getFeedbackVersion(version.Id).Version__c;
        System.assertEquals(2, versionNumber);
    }

    @isTest
    private static void testDeleteRecord() {

        // GIVEN a Feedback Item Version which exists
        Comment_Version__c version = getDefaultVersion();
        insert version;

        // WHEN I delete it
        FeedbackVersionRepository.deleteRecord(version);

        // THEN it no longer exists
        System.assertEquals(0, getAllVersions().size());
    }

    @isTest
    private static void testInsertRecords() {

        // GIVEN a list of two Feedback Item Versions
        List<Comment_Version__c> versions = new List<Comment_Version__c>{
                getDefaultVersion(), getDefaultVersion()
        };

        // WHEN I insert it
        FeedbackVersionRepository.insertRecords(versions);

        // THEN they are both persisted
        System.assertEquals(2, getAllVersions().size());
    }

    @isTest
    private static void testUpdateRecords() {

        // GIVEN a list of two Feedback Item Versions which already exist
        List<Comment_Version__c> versions = new List<Comment_Version__c>{
                getDefaultVersion(), getDefaultVersion()
        };
        insert versions;

        // WHEN I update them
        versions.get(0).Version__c = 2;
        versions.get(1).Version__c = 2;
        FeedbackVersionRepository.updateRecords(versions);

        // THEN the updates are persisted
        List<Comment_Version__c> savedVersions = getAllVersions();
        System.assertEquals(2, savedVersions.get(0).Version__c);
        System.assertEquals(2, savedVersions.get(1).Version__c);
    }

    @isTest
    private static void testDeleteRecords() {

        // GIVEN a list of two existing Feedback Item Versions
        List<Comment_Version__c> versions = new List<Comment_Version__c>{
                getDefaultVersion(), getDefaultVersion()
        };
        insert versions;

        // WHEN I delete it
        FeedbackVersionRepository.deleteRecords(versions);

        // THEN the Versions no longer exist
        System.assertEquals(0, getAllVersions().size());
    }

    @isTest
    private static void testGetFeedbackVersionWhichDoesExist() {

        // GIVEN an Id for a Feedback Item Version which does exist
        Comment_Version__c version = getDefaultVersion();
        insert version;

        // WHEN I get the object itself
        Comment_Version__c receivedVersion =
                FeedbackVersionRepository.getFeedbackVersion(version.Id);

        // THEN I get the correct object with the expected properties
        System.assertEquals(version.Id, receivedVersion.Id);
        System.assertEquals(version.Content__c, receivedVersion.Content__c);
        System.assertEquals(version.Version__c, receivedVersion.Version__c);
        System.assertEquals(
                version.Comment__c, receivedVersion.Comment__c);
    }

    @isTest
    private static void testGetFeedbackVersionWhichDoesNotExistReturnsNull() {

        // GIVEN a valid Id for a Feedback Item Version which has been deleted
        Comment_Version__c version = getDefaultVersion();
        insert version;
        delete version;

        // WHEN I get the Feedback Item Version object
        Comment_Version__c receivedVersion =
                FeedbackVersionRepository.getFeedbackVersion(version.Id);

        // THEN I get nothing
        System.assertEquals(null, receivedVersion);
    }
}
