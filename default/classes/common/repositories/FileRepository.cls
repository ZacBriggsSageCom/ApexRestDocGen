/**
 * Class for dealing with File objects.
 */
public class FileRepository {

    //==========================================================================
    // ContentDocumentLinks
    //==========================================================================

    /**
     * Returns all ContentDocumentLinks which link to an Id in the given Set.
     */
    public static List<ContentDocumentLink> getContentDocumentLinksByLinkedEntityIds(
            Set<Id> ids) {
        if (ids.isEmpty()) {
            // Trying to query ContentDocumentLinks without supplying any IDs
            // results in a QueryException
            return new List<ContentDocumentLink>();
        }
        return [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :ids
        ];
    }

    /**
     * Returns all ContentDocumentLinks which link to the given Id.
     */
    public static List<ContentDocumentLink> getContentDocumentLinksByLinkedEntityId(
            Id id) {
        return [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :id
        ];
    }

    /**
     * Returns all ContentDocumentLinks which relate to a given ContentDocumentId.
     */
    public static List<ContentDocumentLink> getContentDocumentLinksByContentDocumentId(
            Id id) {
        return [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId = :id
        ];
    }

    //==========================================================================
    // ContentDocuments
    //==========================================================================

    /**
     * Finds a ContentDocument by Id.
     */
    public static ContentDocument getContentDocumentById(Id documentId) {
        List<ContentDocument> documents = [
            SELECT Id, Description, OwnerId, Title
            FROM ContentDocument
            WHERE Id = :documentId
        ];
        return documents.isEmpty() ? null : documents.get(0);
    }

    //==========================================================================
    // ContentVersions
    //==========================================================================

    /**
     * Returns all ContentVersions which belong to ContentDocument objects whose
     * Ids appear in the given Set.
     */
    public static List<ContentVersion> getContentVersionsByContentDocumentIds(
            Set<Id> contentDocumentIds) {
        return [
            SELECT
                Id,
                ContentDocumentId,
                Description,
                Title,
                VersionData,
                VersionNumber
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds
            ORDER BY ContentDocumentId, VersionNumber DESC
        ];
    }

    /**
     * Returns all ContentVersions whose Ids appear in the given Set.
     */
    public static List<ContentVersion> getContentVersionByIds(Set<Id> versionIds) {
        return [
            SELECT Id, ContentDocumentId, Description, Title, VersionData
            FROM ContentVersion
            WHERE Id IN :versionIds
        ];
    }

    /**
     * Finds a ContentVersion by Id.
     */
    public static ContentVersion getContentVersionById(Id versionId) {
        List<ContentVersion> versions = [
            SELECT Id, ContentDocumentId, Description, Title, VersionData
            FROM ContentVersion
            WHERE Id = :versionId
        ];
        return versions.isEmpty() ? null : versions.get(0);
    }
}