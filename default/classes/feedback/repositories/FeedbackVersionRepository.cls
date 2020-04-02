/**
 * Class for performing database operations with Feedback Item Version records.
 */
public class FeedbackVersionRepository {

    /**
     * Performs the 'insert' DML operation on a record.
     */
    public static void insertRecord(Comment_Version__c record) {
        // Set the artificial created date (SPPLDEV-5734)
        record.Created_Date__c = Datetime.now();
        insert record;
    }

    /**
     * Performs the 'update' DML operation on a record.
     */
    public static void updateRecord(Comment_Version__c record) {
        update record;
    }

    /**
     * Performs the 'delete' DML operation on a record.
     */
    public static void deleteRecord(Comment_Version__c record) {
        delete record;
    }

    /**
     * Performs the 'insert' DML operation on a list of records.
     */
    public static void insertRecords(List<Comment_Version__c> records) {

        // Set the artificial created date (SPPLDEV-5734)
        Datetime createdDate = Datetime.now();
        for (Comment_Version__c record : records) {
            record.Created_Date__c = createdDate;
        }

        insert records;
    }

    /**
     * Performs the 'update' DML operation on a list of records.
     */
    public static void updateRecords(List<Comment_Version__c> records) {
        update records;
    }

    /**
     * Performs the 'delete' DML operation on a list of records.
     */
    public static void deleteRecords(List<Comment_Version__c> records) {
        delete records;
    }

    /**
     * Find the Feedback Version with the given Id.
     */
    public static Comment_Version__c getFeedbackVersion(Id versionId) {
        List<Comment_Version__c> versions = [
            SELECT
                Id,
                Content__c,
                Created_Date__c,
                Version__c,
                Comment__c
            FROM Comment_Version__c
            WHERE Id = :versionId
        ];
        return versions.isEmpty() ? null : versions.get(0);
    }
}
