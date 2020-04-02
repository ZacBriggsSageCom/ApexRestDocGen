/**
 * Class for performing database operations with Conversation Subject
 * junction objects.
 */
public class ConversationSubjectRepository {

    /**
     * Performs the 'insert' DML operation on a record.
     */
    public static void insertRecord(Conversation_Subject__c record) {
        insert record;
    }

    /**
     * Performs the 'update' DML operation on a record.
     */
    public static void updateRecord(Conversation_Subject__c record) {
        update record;
    }

    /**
     * Performs the 'delete' DML operation on a record.
     */
    public static void deleteRecord(Conversation_Subject__c record) {
        delete record;
    }

    /**
     * Performs the 'insert' DML operation on a list of records.
     */
    public static void insertRecords(List<Conversation_Subject__c> records) {
        insert records;
    }

    /**
     * Performs the 'update' DML operation on a list of records.
     */
    public static void updateRecords(List<Conversation_Subject__c> records) {
        update records;
    }

    /**
     * Performs the 'delete' DML operation on a list of records.
     */
    public static void deleteRecords(List<Conversation_Subject__c> records) {
        delete records;
    }

    /**
     * Retrieve a Subject junction object by its Conversation's ID.
     */
    public static Conversation_Subject__c getSubjectByConversationId(
            Id conversationId) {
        List<Conversation_Subject__c> subjects = [
            SELECT
                Id,
                Conversation__c,
                Objective__c,
                Team_Member__c
            FROM Conversation_Subject__c
            WHERE Conversation__c = :conversationId
            LIMIT 1
        ];
        return subjects.isEmpty() ? null : subjects.get(0);
    }

    /**
     * Retrieves all Subject junction objects whose linked Team Member Ids appear
     * in the given set.
     */
    public static List<Conversation_Subject__c> getSubjectsWithTeamMemberIds(
            Set<Id> tmIds) {
        return [
            SELECT
                Id,
                Conversation__c,
                Objective__c,
                Team_Member__c
            FROM Conversation_Subject__c
            WHERE Team_Member__c IN :tmIds
        ];
    }

    /**
     * Retrieves all Subject junction objects whose linked Objective Ids appear
     * in the given set.
     */
    public static List<Conversation_Subject__c> getSubjectsWithObjectiveIds(
            Set<Id> objectiveIds) {
        return [
            SELECT
                Id,
                Conversation__c,
                Objective__c,
                Team_Member__c
            FROM Conversation_Subject__c
            WHERE Objective__c IN :objectiveIds
        ];
    }

    /**
     * Retrieves all Subject junction objects which link to the given ID.
     */
    public static List<Conversation_Subject__c> getSubjectsWithLinkedId(Id linkedId) {
        return [
            SELECT
                Id,
                Conversation__c,
                Objective__c,
                Team_Member__c
            FROM Conversation_Subject__c
            WHERE Objective__c = :linkedId
            OR Team_Member__c = :linkedId
        ];
    }
}
