public class TaskModelBuilder {

    public static List<TaskModel> buildTasks(List<Task__c> tasks) {

        List<TaskModel> taskModels = new List<TaskModel>();

        for (Task__c task : tasks) {
            TaskModel taskModel = new TaskModel();
            taskModel.id = task.Id;
            taskModel.content = task.Content__c;
            taskModel.complete = task.Status__c == TaskUtils.STATUS_COMPLETED;
            taskModels.add(taskModel);
        }

        return taskModels;
    }

}
