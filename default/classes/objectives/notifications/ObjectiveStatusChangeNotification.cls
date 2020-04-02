/**
 * Class representing a Notification about a status change of Objective.
 */
public class ObjectiveStatusChangeNotification extends Notification {

    private static final String REVEALED_STATUS = 'revealed';
    private static final String CLOSED_STATUS = 'closed';

    private ObjectiveModel objective;

    /**
     * Factory method hiding constructor, which contains queries.
     */
    public static ObjectiveStatusChangeNotification create(
            ObjectiveModel objective) {
        return new ObjectiveStatusChangeNotification(objective);
    }

    private ObjectiveStatusChangeNotification(
            ObjectiveModel objective) {

        this.objective = objective;
        this.recipients = 
            new Set<Id>{ObjectiveNotificationUtils.getNotificationRecipients(objective.tmId)};
        this.title = String.format(
            Label.Objective_Status_Change_Notification_Subject,
            new List<String>{getStatus(objective.status)}
        );
        this.body = buildBody();

    }

    private String getEditorName() {
        Id editorId = new Viewport().getViewerTeamMemberId();
        fHCM2__Team_Member__c tm = TeamMemberRepository.get(editorId);
        return tm != null ? tm.Name : '';
    }

    private String getStatus(String status) {
        return status == ObjectiveUtils.STATUS_ACTIVE 
                ? REVEALED_STATUS 
                : CLOSED_STATUS;
    }

    private String buildBody() {
        String body = String.format(
                Label.Objective_Status_Change_Notification_Body,
                new List<String>{getEditorName(), 
                getStatus(objective.status),
                objective.title}
        );
        String link = ObjectiveNotificationUtils.buildLinkSection(objective);

        return String.join(
                new List<String>{
                        '<p>',
                        body,
                        '</p><br />',
                        link
                }, ''
        );
    }
}