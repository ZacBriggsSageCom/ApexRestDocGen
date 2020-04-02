/**
 * Class representing a Notification about a new comment in a Conversation.
 */
public class NewCommentNotification extends Notification {

    private FeedItemModel feedback;

    /**
     * Factory method hiding constructor, which contains queries.
     */
    public static NewCommentNotification create(FeedItemModel feedback) {
        return new NewCommentNotification(feedback);
    }

    private NewCommentNotification(FeedItemModel feedback) {
        this.feedback = feedback;
        this.recipients = FeedbackUtils.getOtherParticipants(feedback);
        this.title = Label.Conversation_Notification_New_Comment_Subject;
        this.body = buildBody();
    }

    private String buildBody() {
        String intro = String.format(
                Label.Conversation_Notification_New_Comment_Body_Intro,
                new List<String>{feedback.comment.author.name}
        );

        String content = feedback.content;
        String link = FeedbackNotificationUtils.buildLinkSection(feedback);

        return String.join(
                new List<String>{
                        intro,
                        '<p>',
                        content,
                        '</p><br />',
                        link
                }, ''
        );
    }
}
