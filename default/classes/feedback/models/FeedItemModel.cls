/**
 * Model representing an item in a Conversation feed.
 */
public class FeedItemModel implements Comparable {
    public String id;
    public String itemDate;
    public String content;
    public String conversationId;
    public CommentModel comment;
    public FeedEventModel event;

    /**
     * Compares items chronologically.
     */
    public Integer compareTo(Object otherObject) {
        FeedItemModel other = (FeedItemModel) otherObject;
        if (itemDate == other.itemDate) {
            return 0;
        }
        if (DateUtils.stringToDateTime(itemDate)
                < DateUtils.stringToDateTime(other.itemDate)) {
            return 1;
        }
        return -1;
    }
}