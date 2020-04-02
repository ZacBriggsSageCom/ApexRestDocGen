/**
 * Tests exercising the ContentDocument deletion batch.
 */
@isTest
public class ContentDocumentDeletionBatchTest {

    private static Comment__c feedback;
    private static Conversation__c conversation;
    private static ContentDocument document;

    private static void setUp() {
        conversation = new Conversation__c();
        insert conversation;

        feedback = new Comment__c(Conversation__c = conversation.Id);
        insert feedback;

        ContentVersion version = FileTestUtils.createDefaultFileLinkedTo(feedback.Id);
        document = FileRepository.getContentDocumentById(version.ContentDocumentId);
    }

    @isTest
    private static void testDeleteBatch() {

        // GIVEN I have some ContentDocument
        setUp();

        // AND a ContentDocument deletion batch ready to execute
        ContentDocumentDeletionBatch batch = new ContentDocumentDeletionBatch(document.Id);
        Database.QueryLocator locator = batch.start(null);
        List<ContentDocument> docsForDeleting = new List<ContentDocument>();
        Database.QueryLocatorIterator iterator = locator.iterator();
        while (iterator.hasNext()) {
            docsForDeleting.add((ContentDocument) iterator.next());
        }

        // WHEN I use the batch job to delete the document immediately
        batch.execute(null, docsForDeleting);
        batch.finish(null);

        // THEN it no longer exists
        System.assertEquals(null, FileRepository.getContentDocumentById(document.Id));
    }
}
