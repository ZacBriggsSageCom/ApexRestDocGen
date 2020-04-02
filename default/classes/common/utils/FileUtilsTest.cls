/**
 * Tests exercising methods for dealing with Files.
 */
@isTest
public class FileUtilsTest {

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
        document = FileRepository.getContentDocumentById(version.ContentDocumentId);
        link = FileRepository.getContentDocumentLinksByLinkedEntityId(feedback.Id).get(0);
    }

    private static Integer getScheduledJobs() {
        return [SELECT Count() FROM CronTrigger];
    }

    //==========================================================================
    // Test Methods
    //==========================================================================

    @isTest
    private static void testDoesUserHaveAccessTo_WhenTheyShouldNot() {

        // GIVEN a File which is not linked to anything
        setUp();
        delete FileRepository.getContentDocumentLinksByContentDocumentId(
                document.Id);

        // WHEN I determine whether I should have access to it, THEN I find I do not
        System.assert(!FileUtils.doesUserHaveAccessTo(document.Id));
    }

    @isTest
    private static void testDoesUserHaveAccessTo_WhenTheyShould() {

        // GIVEN a File I have created
        setUp();

        // WHEN I determine whether I should have access to it, THEN I find I do
        System.assert(FileUtils.doesUserHaveAccessTo(document.Id));
    }

    @isTest
    private static void testGetLinkedNonUserEntityIds() {

        // GIVEN a File which is linked to a Feedback item and a User
        setUp();

        // WHEN I get all its linked entities which are not Users
        Set<Id> linkedIds = FileUtils.getLinkedNonUserEntityIds(document.Id);

        // THEN I get the Feedback item
        System.assertEquals(1, linkedIds.size());
        System.assert(linkedIds.contains(feedback.Id));
    }

    @isTest
    private static void testGetLinkedEntityIds() {

        // GIVEN a File which is linked to a Feedback item (and incidentally a User)
        setUp();

        // WHEN I use the ContentDocumentId to get the Id of the record
        // THEN I get the correct Id
        System.assert(FileUtils.getLinkedEntityIds(document.Id).contains(feedback.Id));
    }

    @isTest
    private static void testGetFiles_ForManyLinkedEntities() {

        // GIVEN two Files in the database which are linked to two records
        setUp();

        Comment__c feedback2 = new Comment__c(Conversation__c = conversation.Id);
        insert feedback2;
        ContentVersion version2 = FileRepository.getContentVersionById(
                LightningFileHelper.save(
                        'Abacus.docx',
                        'Abacus.docx',
                        Blob.valueOf('The story of a noble robot.'),
                        feedback2.Id
                ).fileId
        );

        ContentDocument document2 =
                FileRepository.getContentDocumentById(version2.ContentDocumentId);

        // WHEN I get all Files which are linked to these records
        Map<Id, List<FileModel>> files =
                FileUtils.getFiles(new Set<Id>{feedback.Id, feedback2.Id});

        // THEN I get a mapping of our records' Ids to the correct Files
        System.assertEquals(2, files.size());

        System.assert(files.containsKey(feedback.Id));
        List<FileModel> files1 = files.get(feedback.Id);
        System.assertEquals(1, files1.size());
        System.assertEquals(document.Id, files1.get(0).contentDocumentId);
        System.assertEquals(version.Title, files1.get(0).title);

        System.assert(files.containsKey(feedback2.Id));
        List<FileModel> files2 = files.get(feedback2.Id);
        System.assertEquals(1, files2.size());
        System.assertEquals(document2.Id, files2.get(0).contentDocumentId);
        System.assertEquals(version2.Title, files2.get(0).title);
    }

    @isTest
    private static void testGetFiles_ForSingleLinkedEntity() {

        // GIVEN a File in the database which is linked to a record
        setUp();

        // WHEN I get all Files which are linked to that record
        List<FileModel> files = FileUtils.getFiles(feedback.Id);

        // THEN I get the original File
        System.assertEquals(1, files.size());
        System.assertEquals(document.Id, files.get(0).contentDocumentId);
        System.assertEquals(version.Title, files.get(0).title);
    }

    @isTest
    private static void testCopyFilesToParent() {

        // GIVEN a File in the database which is to be copied and linked to a record
        // AND a FileModel representing this File
        setUp();
        delete link;
        Comment__c otherFeedback = new Comment__c(Conversation__c = conversation.Id);
        insert otherFeedback;

        ContentVersion version =
                FileTestUtils.createDefaultFileLinkedTo(otherFeedback.Id);
        FileModel file = FileModelBuilder.build(version);

        // WHEN I copy it to the record
        FileUtils.copyFilesToParent(new List<FileModel>{file}, feedback.Id);

        // THEN a new link is added
        List<ContentDocumentLink> links =
                FileRepository.getContentDocumentLinksByLinkedEntityId(feedback.Id);
        System.assertEquals(1, links.size());

        // AND the File has been copied
        System.assertNotEquals(
                version.ContentDocumentId, links.get(0).ContentDocumentId);
    }

    @isTest
    private static void testCopyFilesToParent_WhenAlreadyCopied() {

        // GIVEN a File in the database which is linked to some record
        // AND a FileModel representing this file
        setUp();
        FileModel file = FileModelBuilder.build(version);

        // WHEN I attempt to copy it to the record
        FileUtils.copyFilesToParent(new List<FileModel>{file}, feedback.Id);

        // THEN no additional link is added
        List<ContentDocumentLink> links =
                FileRepository.getContentDocumentLinksByLinkedEntityId(feedback.Id);
        System.assertEquals(1, links.size());
        System.assertEquals(link.Id, links.get(0).Id);

        // AND the file has not been duplicated
        List<ContentVersion> matchingVersions = [
            SELECT Id, Title FROM ContentVersion WHERE Title = :file.title
        ];
        System.assertEquals(1, matchingVersions.size());
    }

    @isTest
    private static void testCopyFilesToParent_WhenFileHasTwoVersions() {

        // GIVEN a File in the database which is to be copied and linked to something
        // but which has two Versions, because it was uploaded in parts
        setUp();
        delete link;
        ContentVersion newerVersion = new ContentVersion(
                ContentDocumentId = document.Id,
                Title = 'The Worst of Times.txt',
                Description = 'The Worst of Times.txt',
                PathOnClient = '/worst.txt',
                VersionData = Blob.valueOf(
                        'It was the best of times; it was the worst of times')
        );
        insert newerVersion;

        // WHEN I attempt to copy it to the new parent
        FileModel file = FileModelBuilder.build(newerVersion);
        FileUtils.copyFilesToParent(new List<FileModel>{file}, feedback.Id);

        // THEN one new link has been added
        List<ContentDocumentLink> links =
                FileRepository.getContentDocumentLinksByLinkedEntityId(feedback.Id);
        System.assertEquals(1, links.size());

        // AND only the latest ContentVersion has been copied
        List<ContentVersion> versions =
                FileUtils.getContentVersionsForContentDocumentLinks(links);
        System.assertEquals(1, versions.size());
        System.assertEquals('The Worst of Times.txt', versions.get(0).Title);
    }

    @isTest
    private static void testGetContentVersionsForContentDocumentLinks() {

        // GIVEN a list of one ContentDocumentLink which links to some File
        setUp();
        List<ContentDocumentLink> links = new List<ContentDocumentLink>{link};

        // WHEN I get the ContentVersions the list's contents apply to
        List<ContentVersion> versions = FileUtils.getContentVersionsForContentDocumentLinks(links);

        // THEN I get the original ContentVersion
        System.assertEquals(1, versions.size());
        System.assertEquals(version.Id, versions.get(0).Id);
        System.assertEquals(version.Title, versions.get(0).Title);
        System.assertEquals(
                version.ContentDocumentId, versions.get(0).ContentDocumentId);
    }

    @isTest
    private static void testGrantTemporaryAccessTo() {

        // GIVEN a ContentDocument which I am not linked to
        setUp();
        delete FileRepository.getContentDocumentLinksByLinkedEntityId(
                        UserInfo.getUserId());
        Integer previousJobs = getScheduledJobs();

        // WHEN I try to grant temporary access
        Id newDocumentId = FileUtils.grantTemporaryAccessTo(version.ContentDocumentId);

        // THEN a new ContentDocument has been created
        System.assertNotEquals(document.Id, newDocumentId);

        // AND I am its owner
        ContentDocument newDocument = FileRepository.getContentDocumentById(newDocumentId);
        System.assertEquals(UserInfo.getUserId(), newDocument.OwnerId);

        // AND the batch job for deleting it has been scheduled
        System.assertEquals(1, getScheduledJobs() - previousJobs);
    }
}
