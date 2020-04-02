/**
 * Class representing a Notification about an edited comment in a Conversation.
 */
public class EditedCommentNotification extends Notification {

    private FeedItemModel feedback;
    private Comment_Version__c previousVersion;

    /**
     * Factory method hiding constructor, which contains queries.
     */
    public static EditedCommentNotification create(
            Comment_Version__c previousVersion, FeedItemModel feedback) {
        return new EditedCommentNotification(previousVersion, feedback);
    }

    private EditedCommentNotification(
            Comment_Version__c previousVersion, FeedItemModel feedback) {
        this.previousVersion = previousVersion;
        this.feedback = feedback;
        this.recipients = FeedbackUtils.getOtherParticipants(feedback);
        this.title = Label.Conversation_Notification_Edited_Comment_Subject;
        this.body = buildBody();
    }

    private String buildBody() {
        String intro = String.format(
                Label.Conversation_Notification_Edited_Comment_Body_Intro,
                new List<String>{feedback.comment.author.name}
        );
        String previousContent = String.format(
                Label.Conversation_Notification_Edited_Comment_Body_Previous,
                new List<String>{previousVersion.Content__c}
        );
        String newContent = String.format(
                Label.Conversation_Notification_Edited_Comment_Body_New,
                new List<String>{feedback.content}
        );
        String link = FeedbackNotificationUtils.buildLinkSection(feedback);

        return String.join(
                new List<String>{
                        intro,
                        '<p>',
                        previousContent,
                        '</p><br /><p>',
                        newContent,
                        '</p><br />',
                        link
                }, ''
        );
    }
}
