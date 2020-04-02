/**
 * Utility methods for database operations with Objectives.
 */
public class ObjectiveRepository {

    public static void deleteRecord(Objective__c objective) {
        delete objective;
    }

    /**
     * Gets the details of an objective by ID.
     */
    public static Objective__c get(Id objectiveId) {
        List<Objective__c> objectives = [
            SELECT
                Id,
                CreatedById,
                Category__c,
                Company_Objective__c,
                Closed_Date__c,
                Created_Date__c,
                Description__c,
                End_Date__c,
                Priority__c,
                Review_Date__c,
                Status__c,
                Team_Member__c,
                Title__c,
                Visibility__c,
                (
                    SELECT
                        Id,
                        Content__c,
                        Status__c,
                        Order__c
                    FROM Tasks__r
                    ORDER BY Order__c
                )
            FROM Objective__c
            WHERE Id = :objectiveId
            ORDER BY Created_Date__c
        ];
        return objectives.isEmpty() ? null : objectives[0];
    }

    /**
     * Gets the details of objectives by a set of IDs.
     */
    public static List<Objective__c> get(Set<Id> objectiveIds) {
        return [
            SELECT Id,
                CreatedById,
                Category__c,
                Company_Objective__c,
                Closed_Date__c,
                Created_Date__c,
                Description__c,
                End_Date__c,
                Priority__c,
                Review_Date__c,
                Status__c,
                Team_Member__c,
                Title__c,
                Visibility__c,
                (
                    SELECT Id,
                        Content__c,
                        Status__c,
                        Order__c
                    FROM Tasks__r
                    ORDER BY Order__c
                )
            FROM Objective__c
            WHERE Id IN :objectiveIds
        ];
    }

    /**
     * Gets the details of all of a team member's objectives.
     */
    public static List<Objective__c> getForTeamMember(Id tmId) {
        List<Objective__c> objectives = [
            SELECT Id,
                CreatedById,
                Category__c,
                Company_Objective__c,
                Closed_Date__c,
                Created_Date__c,
                Description__c,
                End_Date__c,
                Priority__c,
                Review_Date__c,
                Status__c,
                Team_Member__c,
                Title__c,
                Visibility__c,
                (
                    SELECT
                        Id,
                        Content__c,
                        Status__c,
                        Order__c
                    FROM Tasks__r
                    ORDER BY Order__c
                )
            FROM Objective__c
            WHERE Team_Member__c = :tmId
            ORDER BY Created_Date__c
        ];
        return objectives;
    }

    /**
     * Gets the details of all of a team member's objectives.
     */
    public static List<Objective__c> getActiveForTeamMembers(Set<Id> tmIds) {
        List<Objective__c> objectives = [
            SELECT
                Id,
                CreatedById,
                Category__c,
                Company_Objective__c,
                Closed_Date__c,
                Created_Date__c,
                Description__c,
                End_Date__c,
                Priority__c,
                Review_Date__c,
                Status__c,
                Team_Member__c,
                Title__c,
                Visibility__c,
                (
                    SELECT
                        Id,
                        Content__c,
                        Status__c,
                        Order__c
                    FROM Tasks__r
                    ORDER BY Order__c
                )
            FROM Objective__c
            WHERE Team_Member__c IN :tmIds
            AND Status__c = :ObjectiveUtils.STATUS_ACTIVE
            ORDER BY Created_Date__c
        ];
        return objectives;
    }
}
