/**
 * Class for performing database operations with Conversation Participant
 * junction objects.
 */
public class ConversationParticipantRepository {

    /**
     * Performs the 'insert' DML operation on a record.
     */
    public static void insertRecord(Conversation_Participant__c record) {
        insert record;
    }

    /**
     * Performs the 'update' DML operation on a record.
     */
    public static void updateRecord(Conversation_Participant__c record) {
        update record;
    }

    /**
     * Performs the 'delete' DML operation on a record.
     */
    public static void deleteRecord(Conversation_Participant__c record) {
        delete record;
    }

    /**
     * Performs the 'insert' DML operation on a list of records.
     */
    public static void insertRecords(List<Conversation_Participant__c> records) {
        insert records;
    }

    /**
     * Performs the 'update' DML operation on a list of records.
     */
    public static void updateRecords(List<Conversation_Participant__c> records) {
        update records;
    }

    /**
     * Performs the 'delete' DML operation on a list of records.
     */
    public static void deleteRecords(List<Conversation_Participant__c> records) {
        delete records;
    }

    /**
     * Retrieve all Participant junction objects by their Conversation's ID.
     */
    public static List<Conversation_Participant__c> getParticipantsByConversationId(
            Id conversationId) {
        return [
            SELECT
                Id,
                Conversation__c,
                Team_Member__c
            FROM Conversation_Participant__c
            WHERE Conversation__c = :conversationId
        ];
    }

    /**
     * Retrieve all Participant junctions which link to the given Team Member.
     */
    public static List<Conversation_Participant__c> getParticipantsByTeamMemberId(
            Id tmId) {
        return [
            SELECT
                Id,
                Conversation__c,
                Team_Member__c
            FROM Conversation_Participant__c
            WHERE Team_Member__c = :tmId
        ];
    }
}
