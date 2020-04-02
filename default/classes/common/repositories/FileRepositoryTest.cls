/**
 * Tests exercising methods dealing with File objects.
 */
@isTest
public class FileRepositoryTest {

    private static Comment__c feedback;
    private static Conversation__c conversation;
    private static ContentVersion version;
    private static ContentDocument document;
    private static ContentDocumentLink link;

    private static void setUp() {
        conversation = new Conversation__c();
        insert conversation;
        feedback = new Comment__c(Conversation__c = conversation.Id);
        insert feedback;

        version = FileTestUtils.createDefaultFileLinkedTo(feedback.Id);
        document = [
            SELECT Id, Description, Title
            FROM ContentDocument
            WHERE Id = :version.ContentDocumentId
        ];
        link = [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :feedback.Id
        ].get(0);
    }

    @isTest
    private static void testGetContentDocumentLinksByLinkedEntityIds() {

        // GIVEN a ContentDocumentLink pointing to some record
        setUp();
        Set<Id> linkedIds = new Set<Id>{feedback.Id};

        // WHEN I retrieve all ContentDocumentLinks that point to that record
        List<ContentDocumentLink> links =
                FileRepository.getContentDocumentLinksByLinkedEntityIds(linkedIds);

        // THEN I get the same ContentDocumentLink
        System.assertEquals(1, links.size());
        System.assertEquals(link.Id, links.get(0).Id);
        System.assertEquals(link.ContentDocumentId, links.get(0).ContentDocumentId);
        System.assertEquals(link.LinkedEntityId, links.get(0).LinkedEntityId);
    }

    @isTest
    private static void testGetContentDocumentLinksWithoutLinkedEntityIds() {

        // GIVEN an empty list of IDs
        Set<Id> linkedIds = new Set<Id>{};

        // WHEN I retrieve all ContentDocumentLinks linked to these IDs
        List<ContentDocumentLink> links =
                FileRepository.getContentDocumentLinksByLinkedEntityIds(linkedIds);

        // THEN I get an empty list
        System.assertEquals(0, links.size());
    }

    @isTest
    private static void testGetContentDocumentLinksByLinkedEntityId() {

        // GIVEN a ContentDocumentLink pointing to some record
        setUp();

        // WHEN I retrieve all ContentDocumentLinks that point to that record
        List<ContentDocumentLink> links =
                FileRepository.getContentDocumentLinksByLinkedEntityId(feedback.Id);

        // THEN I get the same ContentDocumentLink
        System.assertEquals(1, links.size());
        System.assertEquals(link.Id, links.get(0).Id);
        System.assertEquals(link.ContentDocumentId, links.get(0).ContentDocumentId);
        System.assertEquals(link.LinkedEntityId, links.get(0).LinkedEntityId);
    }

    @isTest
    private static void testGetContentDocumentLinksByContentDocumentId() {

        // GIVEN ContentDocumentLinks which link a ContentDocument to something
        setUp();

        // WHEN I retrieve all ContentDocumentLinks which link from that document
        List<ContentDocumentLink> links =
                FileRepository.getContentDocumentLinksByContentDocumentId(document.Id);

        // THEN I get two ContentDocumentLinks
        System.assertEquals(2, links.size());

        // AND both of them link from our original ContentDocument
        for (ContentDocumentLink link : links) {
            System.assertEquals(document.Id, link.ContentDocumentId);
        }
    }

    @isTest
    private static void testGetContentDocumentById() {

        // GIVEN a ContentDocument
        setUp();

        // WHEN I retrieve it by Id
        ContentDocument receivedDocument =
                FileRepository.getContentDocumentById(document.Id);

        // THEN I get the original ContentDocument
        System.assertEquals(document.Id, receivedDocument.Id);
        System.assertEquals(document.Description, receivedDocument.Description);
        System.assertEquals(document.Title, receivedDocument.Title);
    }

    @isTest
    private static void testGetContentVersionsByContentDocumentIds() {

        // GIVEN a Set of one ContentDocumentId
        setUp();
        Set<Id> documentIds = new Set<Id>{document.Id};

        // WHEN I retrieve all ContentVersions that belong to that ContentDocument
        List<ContentVersion> versions =
                FileRepository.getContentVersionsByContentDocumentIds(documentIds);

        // THEN I get the child ContentVersion
        System.assertEquals(1, versions.size());
        System.assertEquals(version.Id, versions.get(0).Id);
        System.assertEquals(version.Title, versions.get(0).Title);
        System.assertEquals(
                version.ContentDocumentId, versions.get(0).ContentDocumentId);
    }

    @isTest
    private static void testGetContentVersionsByIds() {

        // GIVEN a ContentVersion, AND a Set of Ids that contain just its one
        setUp();
        Set<Id> versionIds = new Set<Id>{version.Id};

        // WHEN I retrieve all ContentVersion that have Ids in that Set
        List<ContentVersion> versions =
                FileRepository.getContentVersionByIds(versionIds);

        // THEN I get the original ContentVersion
        System.assertEquals(1, versions.size());
        System.assertEquals(version.Id, versions.get(0).Id);
        System.assertEquals(version.Title, versions.get(0).Title);
        System.assertEquals(
                version.ContentDocumentId, versions.get(0).ContentDocumentId);
    }

    @isTest
    private static void testGetContentVersionsById() {

        // GIVEN a ContentVersion
        setUp();

        // WHEN I retrieve it by Id
        ContentVersion receivedVersion =
                FileRepository.getContentVersionById(version.Id);

        // THEN I get the original ContentVersion
        System.assertEquals(version.Id, receivedVersion.Id);
        System.assertEquals(version.Title, receivedVersion.Title);
        System.assertEquals(
                version.ContentDocumentId, receivedVersion.ContentDocumentId);
    }
}