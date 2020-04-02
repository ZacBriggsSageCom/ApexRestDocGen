@isTest
public class TaskModelBuilderTest {

    @isTest
    private static void testBuildTasks_NoTasks() {
        // GIVEN an empty list of Tasks
        List<Task__c> tasks = new List<Task__c>();
        // WHEN building TaskModels from this list
        List<TaskModel> taskModels = TaskModelBuilder.buildTasks(tasks);
        // THEN none are returned
        System.assertEquals(0, taskModels.size());
    }

    @isTest
    private static void testBuildTasks() {

        // GIVEN a list of Tasks relating to an Objective
        Objective__c objective = new Objective__c(
            Title__c = 'Do a thing'
        );
        insert objective;
        Task__c task1 = new Task__c(
            Objective__c = objective.Id,
            Content__c = 'Get this test to pass',
            Status__c = TaskUtils.STATUS_ACTIVE,
            Order__c = 1
        );
        Task__c task2 = new Task__c(
            Objective__c = objective.Id,
            Content__c = 'Ensure coverage is adequate',
            Status__c = TaskUtils.STATUS_COMPLETED,
            Order__c = 1
        );
        List<Task__c> tasks = new List<Task__c> { task1, task2 };
        insert tasks;

        // WHEN building TaskModels from this list
        List<TaskModel> taskModels = TaskModelBuilder.buildTasks(tasks);

        // THEN all my Tasks are converted to TaskModels
        System.assertEquals(2, taskModels.size());
        System.assertEquals(task1.Id, taskModels[0].id);
        System.assertEquals(task1.Content__c, taskModels[0].content);
        System.assertEquals(false, taskModels[0].complete);
        System.assertEquals(task2.Id, taskModels[1].id);
        System.assertEquals(task2.Content__c, taskModels[1].content);
        System.assertEquals(true, taskModels[1].complete);
    }

}
