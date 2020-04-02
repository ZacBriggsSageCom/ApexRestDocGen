public class ObjectiveCollaboratorRepository {

    /**
     * Gets all Collaborator junction objects linking to a given Objective ID.
     */
    public static List<Objective_Collaborator__c> getForObjective(Id objectiveId) {
        return [
            SELECT
                Id,
                Access_Type__c,
                Objective__c,
                Team_Member__c
            FROM Objective_Collaborator__c
            WHERE Objective__c = :objectiveId
        ];
    }

    /**
     * Gets all Collaborator junction objects linking to an Objective ID in the
     * given set.
     */
    public static List<Objective_Collaborator__c> getForObjectives(Set<Id> objectiveIds) {
        return [
            SELECT
                Id,
                Access_Type__c,
                Objective__c,
                Team_Member__c
            FROM Objective_Collaborator__c
            WHERE Objective__c IN :objectiveIds
        ];
    }

    /**
     * Gets all Collaborator junction objects linking to a given Team Member ID.
     */
    public static List<Objective_Collaborator__c> getForTeamMember(Id tmId) {
        return [
            SELECT
                Id,
                Access_Type__c,
                Objective__c,
                Team_Member__c
            FROM Objective_Collaborator__c
            WHERE Team_Member__c = :tmId
        ];
    }
}