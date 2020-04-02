/**
 * Class for performing database operations with Feed_Event__c objects.
 */
public class FeedEventRepository {

    public static Feed_Event__c insertRecord(Feed_Event__c event) {
        insert event;
        return event;
    }

    public static Feed_Event__c get(Id id) {
        List<Feed_Event__c> events = [
            SELECT
                Id,
                Actor__c,
                Date__c,
                Subject__c,
                Type__c
            FROM Feed_Event__c
            WHERE Id = :id
        ];
        return events.isEmpty() ? null : events.get(0);
    }

    public static List<Feed_Event__c> getBySubjects(Set<Id> subjectIds) {
        return [
            SELECT
                Id,
                Actor__c,
                Date__c,
                Subject__c,
                Type__c
            FROM Feed_Event__c
            WHERE Subject__c IN :subjectIds
        ];
    }
}