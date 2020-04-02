public class TaskRepository {

    /**
     * Gets all Tasks for an Objective whose IDs are not present in a Set.
     */
    public static List<Task__c> getMissingTasks(
            Id objectiveId, Set<Id> taskIds) {
        return [
            SELECT Id,
                Objective__c,
                Content__c,
                Status__c,
                Order__c
            FROM Task__c
            WHERE Objective__c = :objectiveId
            AND Id NOT IN :taskIds
        ];
    }

    public static void deleteTasks(List<Task__c> tasks) {
        delete tasks;
    }

}
