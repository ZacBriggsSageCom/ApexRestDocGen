/**
 * Model representing details specific to a comment in a conversation.
 */
public class CommentModel {
    public Integer version;
    public String latestVersionDate;
    public List<FileModel> attachments;
    public PersonModel author;
}
