/**
 * Class for performing database operations with Conversation records.
 */
public class ConversationRepository {

    /**
     * Performs the 'insert' DML operation on a record.
     */
    public static void insertRecord(Conversation__c record) {
        insert record;
    }

    /**
     * Performs the 'update' DML operation on a record.
     */
    public static void updateRecord(Conversation__c record) {
        update record;
    }

    /**
     * Performs the 'delete' DML operation on a record.
     */
    public static void deleteRecord(Conversation__c record) {
        delete record;
    }

    /**
     * Performs the 'insert' DML operation on a list of records.
     */
    public static void insertRecords(List<Conversation__c> records) {
        insert records;
    }

    /**
     * Performs the 'update' DML operation on a list of records.
     */
    public static void updateRecords(List<Conversation__c> records) {
        update records;
    }

    /**
     * Performs the 'delete' DML operation on a list of records.
     */
    public static void deleteRecords(List<Conversation__c> records) {
        delete records;
    }

    /**
     * Retrieve a Conversation and its child Feedback Items by ID.
     */
    public static Conversation__c getConversationById(Id id) {
        List<Conversation__c> conversations = [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Author__c,
                        Author_Type__c,
                        CreatedDate,
                        Current_Version__c
                    FROM Comments__r
                    ORDER BY CreatedDate DESC
                )
            FROM Conversation__c
            WHERE Id = :id
            LIMIT 1
        ];
        return conversations.isEmpty() ? null : conversations.get(0);
    }

    /**
     * Retrieve all Conversations (with child Comments) whose IDs appear in a Set.
     */
    public static List<Conversation__c> getConversationsByIds(Set<Id> ids) {
        return [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Author__c,
                        Author_Type__c,
                        CreatedDate,
                        Current_Version__c
                    FROM Comments__r
                    ORDER BY CreatedDate DESC
                )
            FROM Conversation__c
            WHERE Id IN :ids
        ];
    }
}
