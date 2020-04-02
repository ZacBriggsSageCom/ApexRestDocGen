/**
 * Batch job for deleting ContentDocuments.
 */
public class ContentDocumentDeletionBatch implements Database.Batchable<SObject> {

    public static final String NAME = 'ContentDocument Deletion Batch';

    private Set<Id> docIds;

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
            SELECT Id 
            FROM ContentDocument
            WHERE Id IN :docIds
        ]);
    }

    public void execute(Database.BatchableContext context, List<ContentDocument> scope) {
        delete scope;
    }

    public void finish(Database.BatchableContext context) {}

    public ContentDocumentDeletionBatch(Id docId) {
        this.docIds = new Set<Id>{docId};
    }

    public ContentDocumentDeletionBatch(Set<Id> docIds) {
        this.docIds = docIds;
    }
}
