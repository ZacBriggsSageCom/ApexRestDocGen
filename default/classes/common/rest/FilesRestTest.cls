/**
 * Tests exercising the Files REST controller.
 */
@isTest
public class FilesRestTest {

    private static Comment__c feedback;
    private static Conversation__c conversation;
    private static ContentVersion version;
    private static ContentDocument document;

    private static void setUp() {
        conversation = new Conversation__c();
        insert conversation;
        feedback = new Comment__c(Conversation__c = conversation.Id);
        insert feedback;

        version = FileTestUtils.createDefaultFileLinkedTo(feedback.Id);
        document = FileRepository.getContentDocumentById(version.ContentDocumentId);
    }

    @isTest
    private static void testGetFileLink () {

        // GIVEN I want to view a File that belongs to me
        setUp();
        RestTestUtils.setupRestContext('GET', '/file/' + document.Id);

        // WHEN I make the request
        FilesRest.getFileLink();
        FileLinkResponseModel response =
                (FileLinkResponseModel) RestTestUtils.getResponseBody(
                        FileLinkResponseModel.class);

        // THEN the operation is allowed
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND I receive the correct information
        System.assert(response.url.contains(document.Id));
    }
}
