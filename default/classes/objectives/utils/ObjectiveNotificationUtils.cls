/**
 * Class providing utilities for creating Notifications about Objective events.
 */
public class ObjectiveNotificationUtils {

    /**
     * Builds a link segment for a Notification, i.e. the value of the custom
     * label for introducing it and the URL itself.
     */
    public static String buildLinkSection(ObjectiveModel objective) {
        String linkContent =
                '<br />'
                + ObjectiveUrlUtils.getObjectivePageUrl(objective.tmId, objective.id);
        return String.format(
                Label.Objective_Status_Change_Notification_Body_Link,
                new List<String>{linkContent}
        );
    }

    /**
     * Gets the recipients for the notification for 
     * change in status of the Objective
     */
    public static Id getNotificationRecipients(String tmId) {
        //Get manager of who objective is being created for
        Viewport viewport = new Viewport(tmId);
        Id managerId = viewport.getManagerId();

        //Get current viewer
        Id editorId = viewport.getViewerTeamMemberId();

        return (editorId == managerId) ? tmId : managerId;

    }
}