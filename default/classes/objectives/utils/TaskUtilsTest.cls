@isTest
public class TaskUtilsTest {

    @isTest
    private static void testTaskIsActiveWhenCompleteNotProvided() {
        // GIVEN a Task whose Complete flag has not been set
        // WHEN I get its status, THEN I find it is active
        System.assertEquals(
                TaskUtils.STATUS_ACTIVE,
                TaskUtils.getTaskStatus(new TaskModel())
        );
    }

    @isTest
    private static void testTaskIsActiveWhenCompleteIsFalse() {
        // GIVEN a Task whose Complete flag is set to false
        TaskModel task = new TaskModel();
        task.complete = false;

        // WHEN I get its status, THEN I find it is active
        System.assertEquals(TaskUtils.STATUS_ACTIVE, TaskUtils.getTaskStatus(task));
    }

    @isTest
    private static void testTaskIsCompleteWhenCompleteIsTrue() {
        // GIVEN a Task whose Complete flag is set to true
        TaskModel task = new TaskModel();
        task.complete = true;

        // WHEN I get its status, THEN I find it is completed
        System.assertEquals(TaskUtils.STATUS_COMPLETED, TaskUtils.getTaskStatus(task));
    }
}
