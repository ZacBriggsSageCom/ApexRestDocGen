/**
 * Tests exercising the Files controller.
 */
@isTest
public class FilesControllerTest {

    private static fHCM2__Team_Member__c subject;
    private static fHCM2__Team_Member__c viewer;
    private static fHCM2__Policy__c pol;
    private static FeedItemModel feedback;
    private static ConversationModel conversation;
    private static ContentVersion version;
    private static ContentDocument document;

    private static String getUrlForFile(Id contentDocumentId) {
        return fHCM2.UrlHelper.getFullFileUrl(contentDocumentId);
    }

    //==========================================================================
    // Setup Methods
    //==========================================================================

    private static void setUpAsOwner() {
        createPolicy();
        viewer = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setPolicy(pol.Id)
                .setName('Wilma Worm')
                .build();
        subject = viewer;
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(subject.Id)
                .addParticipant(subject)
                .save()
                .build();
        createFile();
    }

    private static void setUpAsManager() {
        createPolicy();
        viewer = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setPolicy(pol.Id)
                .setName('Pandora Panda')
                .build();
        subject = new TeamMemberTestUtils.TeamMemberBuilder()
                .setManager(viewer.Id)
                .setUser(TeamMemberTestUtils.createUser('Terrence', 'Tenrec').Id)
                .setName('Terrence Tenrec')
                .build();
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(subject.Id)
                .addParticipant(subject)
                .addParticipant(viewer)
                .save()
                .build();
        createFile();
        deleteViewersLinkToFile();
    }

    private static void setUpAsStranger() {
        createPolicy();
        viewer = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setPolicy(pol.Id)
                .build();
        subject = new TeamMemberTestUtils.TeamMemberBuilder().build();
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(subject.Id)
                .addParticipant(subject)
                .save()
                .build();
        createFile();
        deleteViewersLinkToFile();
    }

    private static void createPolicy() {
        pol = new fHCM2__Policy__c(Allow_Edit_Feedback__c = true);
        insert pol;
    }

    private static void createFile() {
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(viewer.Id)
                .setConversation(conversation.id)
                .save()
                .build();
        version = FileTestUtils.createDefaultFileLinkedTo(feedback.id);
        document = FileRepository.getContentDocumentById(version.ContentDocumentId);
    }

    private static void deleteViewersLinkToFile() {
        delete FileRepository.getContentDocumentLinksByLinkedEntityId(
                UserInfo.getUserId());
    }

    //==========================================================================
    // Test Methods
    //==========================================================================

    @isTest
    private static void testGetFileLink_ForMyFile() {

        // GIVEN a File linked to some record that belongs to me
        setUpAsOwner();

        // WHEN I ask for the link to it
        FileLinkResponseModel response = FilesController.getFileLink(document.Id);

        // THEN the request is granted
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND I receive a response with the correct URL
        System.assertEquals(getUrlForFile(document.Id), response.url);
    }

    @isTest
    private static void testGetFileLink_ForMyDirectReportsFeedbackFile() {

        // GIVEN a File linked to a Feedback record that my direct report has
        // left
        setUpAsManager();

        // WHEN I ask for the link to it
        FileLinkResponseModel response = FilesController.getFileLink(document.Id);

        // THEN the request is granted
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND I receive a response with the correct URL
        Id copiedDocumentId = FileRepository.getContentDocumentLinksByLinkedEntityId(
                UserInfo.getUserId()).get(0).ContentDocumentId;
        System.assertEquals(getUrlForFile(copiedDocumentId), response.url);
    }

    @isTest
    private static void testGetFileLink_ForStrangersFeedbackFile() {

        // GIVEN a File which I have no business viewing
        setUpAsStranger();

        // WHEN I ask for the link to it
        FileLinkResponseModel response = FilesController.getFileLink(document.Id);

        // THEN the request is denied
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, response.getStatusCode());

        // AND the response does not contain a URL
        System.assertEquals(null, response.url);

        // AND the response contains the correct denial message
        System.assertEquals(Label.Conversation_Access_Denied, response.error.error);
    }

    @isTest
    private static void testGetFileLink_WithInvalidFileId() {

        // GIVEN I have an invalid File Id
        String fileId = 'potato';

        // WHEN I ask for the link to it
        FileLinkResponseModel response = FilesController.getFileLink(fileId);

        // THEN the request is denied
        System.assertEquals(HttpUtils.STATUS_BAD_REQUEST, response.getStatusCode());

        // AND the response does not contain a URL
        System.assertEquals(null, response.url);

        // AND the response contains the correct error message
        System.assertEquals(Label.ContentDocument_Id_Invalid, response.error.error);
    }

    @isTest
    private static void testGetFileLink_WhenFileDoesNotExist() {

        // GIVEN I have a valid ContentDocumentId, but the object does not exist
        setUpAsOwner();
        delete document;

        // WHEN I ask for the link to it
        FileLinkResponseModel response = FilesController.getFileLink(document.Id);

        // THEN the request is denied
        System.assertEquals(HttpUtils.STATUS_NOT_FOUND, response.getStatusCode());

        // AND the response does not contain a URL
        System.assertEquals(null, response.url);

        // AND the response contains the correct error message
        System.assertEquals(Label.File_Does_Not_Exist, response.error.error);
    }

    @isTest
    private static void testGetFileLink_WhenFileIsNotLinkedToARecord() {

        // GIVEN I am asking for the link to a File which is not linked to anything
        setUpAsOwner();
        delete FileRepository.getContentDocumentLinksByContentDocumentId(document.Id);

        // WHEN I ask for the link to it
        FileLinkResponseModel response = FilesController.getFileLink(document.Id);

        // THEN the request is denied, as there is no basis for authorization
        System.assertEquals(HttpUtils.STATUS_BAD_REQUEST, response.getStatusCode());

        // AND the response does not contain a URL
        System.assertEquals(null, response.url);

        // AND the response contains the correct error message
        System.assertEquals(Label.File_Not_Linked, response.error.error);
    }

}