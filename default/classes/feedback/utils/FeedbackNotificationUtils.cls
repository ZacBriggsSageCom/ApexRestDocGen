/**
 * Class providing utilities for creating Notifications about Feedback events.
 */
public class FeedbackNotificationUtils {

    /**
     * Builds a link segment for a Notification, i.e. the value of the custom
     * label for introducing it and the URL itself.
     */
    public static String buildLinkSection(FeedItemModel feedback) {
        String url = ConversationHandlerRegistry.getHandlerForConversationId(
                feedback.conversationId).getLinkToComment(feedback.id);
        return String.format(
                Label.Conversation_Notification_Body_Link,
                new List<String>{'<br />' + url}
        );
    }
}