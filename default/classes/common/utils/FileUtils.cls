/**
 * Helper class for dealing with Files.
 */
public class FileUtils {

    private static final String USER_NAME = 'User';

    /**
     * Determines whether the current User has access to a given File, by
     * ContentDocumentId.
     */
    public static Boolean doesUserHaveAccessTo(Id contentDocumentId) {
        Set<Id> linkedRecordIds = getLinkedEntityIds(contentDocumentId);

        for (Id id : linkedRecordIds) {
            if (id == UserInfo.getUserId()) {
                return true;
            }
        }
        return false;
    }

    /**
     * Given a ContentDocument Id, locates the SObjects to which it is linked
     * which are not Users.
     */
    public static Set<Id> getLinkedNonUserEntityIds(Id contentDocumentId) {
        Set<Id> linkedRecordIds = getLinkedEntityIds(contentDocumentId);
        Set<Id> filteredIds = new Set<Id>();

        for (Id id : linkedRecordIds) {
            if (!SObjectUtils.isOfType(id, USER_NAME)) {
                filteredIds.add(id);
            }
        }
        return filteredIds;
    }

    /**
     * Given a ContentDocument Id, locates the SObjects to which it is linked, if
     * any.
     */
    public static Set<Id> getLinkedEntityIds(Id contentDocumentId) {

        // Find ContentDocumentLinks which link from our File
        List<ContentDocumentLink> links =
                FileRepository.getContentDocumentLinksByContentDocumentId(contentDocumentId);

        // Return their linked entity Ids
        Set<Id> ids = new Set<Id>();
        for (ContentDocumentLink link : links) {
            ids.add(link.LinkedEntityId);
        }
        return ids;
    }

    /**
     * Given some Ids of linked entities, gets all Files that are linked to them
     * in the form Entity Id => List<FileModel>.
     */
    public static Map<Id, List<FileModel>> getFiles(Set<Id> linkedEntityIds) {

        // Get ContentDocumentLink objects
        List<ContentDocumentLink> links =
                FileRepository.getContentDocumentLinksByLinkedEntityIds(linkedEntityIds);

        // Get ContentVersion objects
        List<ContentVersion> versions = getContentVersionsForContentDocumentLinks(links);

        // Build mapping of linked entity Id => FileModels
        Map<Id, List<FileModel>> filesByLinkedEntity = new Map<Id, List<FileModel>>();
        for (ContentDocumentLink link : links) {

            // Initialize entry if not available already
            if (!filesByLinkedEntity.containsKey(link.LinkedEntityId)) {
                filesByLinkedEntity.put(link.LinkedEntityId, new List<FileModel>());
            }

            // Find ContentVersions for this ContentDocumentLink, and add them to
            // our mapping as FileModels
            for (ContentVersion version : versions) {
                if (version.ContentDocumentId == link.ContentDocumentId) {
                    filesByLinkedEntity
                            .get(link.LinkedEntityId)
                            .add(FileModelBuilder.build(version));
                }
            }
        }

        return filesByLinkedEntity;
    }

    /**
     * Given the Id of a linked entity, gets all Files that are linked to it, as
     * a list of FileModels.
     */
    public static List<FileModel> getFiles(Id linkedEntityId) {
        List<ContentDocumentLink> links =
                FileRepository.getContentDocumentLinksByLinkedEntityId(linkedEntityId);
        List<ContentVersion> versions =
                getContentVersionsForContentDocumentLinks(links);

        return FileModelBuilder.build(versions);
    }

    /**
     * Given some ContentDocumentLinks, finds the ContentVersions which have the
     * same ContentDocumentIds as the ContentDocumentLinks.
     */
    @TestVisible
    private static List<ContentVersion> getContentVersionsForContentDocumentLinks(
            List<ContentDocumentLink> links) {

        Set<Id> documentIds = new Set<Id>();
        for (ContentDocumentLink link : links) {
            documentIds.add(link.ContentDocumentId);
        }
        return FileRepository.getContentVersionsByContentDocumentIds(documentIds);
    }

    /**
     * For some FileModels, checks which ones have already been saved against the
     * given record Id. For those which haven't, copies and saves them with a
     * link to said record Id.
     */
    public static void copyFilesToParent(List<FileModel> files, Id recordId) {

        if (files == null || files.isEmpty()) {
            return;
        }

        // Get latest ContentVersion for each File
        Set<Id> documentIds = new Set<Id>();
        for (FileModel file : files) {
            documentIds.add(file.contentDocumentId);
        }
        List<ContentVersion> versions =
                getLatestVersionsOfContentDocuments(documentIds);

        // Get existing ContentDocumentLinks, so we know which files we don't
        // need to copy
        List<ContentDocumentLink> existingLinks =
                FileRepository.getContentDocumentLinksByLinkedEntityId(recordId);
        Set<Id> alreadyLinkedDocumentIds = new Set<Id>();
        for (ContentDocumentLink link : existingLinks) {
            alreadyLinkedDocumentIds.add(link.ContentDocumentId);
        }

        // Create new files linked to parent record, where required
        for (ContentVersion version : versions) {
            if (!alreadyLinkedDocumentIds.contains(version.ContentDocumentId)) {
                LightningFileHelper.save(
                        version.Title,
                        version.Description,
                        version.VersionData,
                        recordId
                );
            }
        }
    }

    /**
     * Given some ContentDocumentIds, returns a list of each of their latest
     * ContentVersions.
     */
    private static List<ContentVersion> getLatestVersionsOfContentDocuments(
            Set<Id> documentIds) {

        // Get all ContentVersions, ordered by Document and Version Number
        List<ContentVersion> allVersions =
                FileRepository.getContentVersionsByContentDocumentIds(documentIds);

        // Collect first (i.e. latest) Version for each DocumentId
        Map<Id, ContentVersion> latestVersionByDoc = new Map<Id, ContentVersion>();
        for (ContentVersion version : allVersions) {
            if (!latestVersionByDoc.containsKey(version.ContentDocumentId)) {
                latestVersionByDoc.put(version.ContentDocumentId, version);
            }
        }
        return latestVersionByDoc.values();
    }

    /**
     * Give the current User temporary access to a File by copying it under their
     * ownership and scheduling it for deletion in one minute.
     *
     * @return the Id of the copied ContentDocument
     */
    public static Id grantTemporaryAccessTo(Id contentDocumentId) {

        // Locate original File
        ContentVersion oldVersion = FileRepository.getContentVersionsByContentDocumentIds(
                new Set<Id>{contentDocumentId}).get(0);

        // Copy file
        ContentVersion newVersion = new ContentVersion(
                ContentLocation = 'S',
                VersionData = oldVersion.VersionData,
                Title = oldVersion.Title,
                Description = oldVersion.Description,
                PathOnClient = '/' + oldVersion.Title
        );
        insert newVersion;

        // Schedule for deletion
        Id newDocumentId =
                FileRepository.getContentVersionById(newVersion.Id).ContentDocumentId;
        System.scheduleBatch(
                new ContentDocumentDeletionBatch(newDocumentId),
                ContentDocumentDeletionBatch.NAME + Datetime.now(),
                1
        );

        // Return ContentDocumentId
        return newDocumentId;
    }
}
