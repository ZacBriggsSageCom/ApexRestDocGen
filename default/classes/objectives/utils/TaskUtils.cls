public class TaskUtils {

    public static final String STATUS_ACTIVE = 'Active';
    public static final String STATUS_COMPLETED = 'Completed';

    /**
     * Given a TaskModel, determines its current status.
     */
    public static String getTaskStatus(TaskModel task) {
        return task.complete == null || task.complete == false
                ? STATUS_ACTIVE
                : STATUS_COMPLETED;
    }

}
