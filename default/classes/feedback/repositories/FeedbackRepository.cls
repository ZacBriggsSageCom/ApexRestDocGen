/**
 * Class for performing database operations with Feedback records.
 */
public class FeedbackRepository {

    /**
     * Performs the 'insert' DML operation on a record.
     */
    public static void insertRecord(Comment__c record) {
        // Set the artificial created date (SPPLDEV-5734)
        record.Created_Date__c = Datetime.now();
        insert record;
    }

    /**
     * Performs the 'update' DML operation on a record.
     */
    public static void updateRecord(Comment__c record) {
        update record;
    }

    /**
     * Performs the 'delete' DML operation on a record.
     */
    public static void deleteRecord(Comment__c record) {
        delete record;
    }

    /**
     * Performs the 'insert' DML operation on a list of records.
     */
    public static void insertRecords(List<Comment__c> records) {

        // Set the artificial created date (SPPLDEV-5734)
        Datetime createdDate = Datetime.now();
        for (Comment__c record : records) {
            record.Created_Date__c = createdDate;
        }

        insert records;
    }

    /**
     * Performs the 'update' DML operation on a list of records.
     */
    public static void updateRecords(List<Comment__c> records) {
        update records;
    }

    /**
     * Performs the 'delete' DML operation on a list of records.
     */
    public static void deleteRecords(List<Comment__c> records) {
        delete records;
    }

    /**
     * Finds the saved Feedback item with the given Id.
     */
    public static Comment__c getFeedback(Id feedbackId) {
        List<Comment__c> feedback = [
            SELECT
                Id,
                Author__c,
                Author_Type__c,
                Conversation__c,
                Created_Date__c,
                Current_Version__c,
                (
                    SELECT
                        Id,
                        Content__c,
                        Created_Date__c,
                        Version__c
                    FROM Versions__r
                    ORDER BY Version__c DESC
                )
            FROM Comment__c
            WHERE Id = :feedbackId
            LIMIT 1
        ];
        return feedback.isEmpty() ? null : feedback.get(0);
    }

    /**
     * Finds all saved Feedback items whose Ids appear in a given Set.
     */
    public static List<Comment__c> getFeedbackWithIds(Set<Id> feedbackIds) {
        return [
            SELECT
                Id,
                Author__c,
                Author_Type__c,
                Conversation__c,
                Created_Date__c,
                Current_Version__c,
                (
                    SELECT
                        Id,
                        Content__c,
                        Created_Date__c,
                        Version__c
                    FROM Versions__r
                    ORDER BY Version__c DESC
                    LIMIT 1
                )
            FROM Comment__c
            WHERE Id IN :feedbackIds
            ORDER BY Created_Date__c DESC
        ];
    }

    /**
     * Finds all saved Feedback items which are part of a set of conversations.
     */
    public static List<Comment__c> getFeedbackWithConversationIds(Set<Id> conversationIds) {
        List<Comment__c> feedback = [
                SELECT
                    Id,
                    Author__c,
                    Author_Type__c,
                    Conversation__c,
                    Created_Date__c,
                    Current_Version__c,
                    (
                        SELECT
                            Id,
                            Content__c,
                            Created_Date__c,
                            Version__c
                        FROM Versions__r
                        ORDER BY Version__c DESC
                        LIMIT 1
                    )
                FROM Comment__c
                WHERE Conversation__c IN :conversationIds
                ORDER BY Created_Date__c DESC
        ];
        return feedback;
    }

}
