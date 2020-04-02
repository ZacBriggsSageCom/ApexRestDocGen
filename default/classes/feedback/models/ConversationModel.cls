/**
 * Model representing a Conversation and its contents.
 */
public class ConversationModel {

    // The ID of the record
    public String id;

    // The name of the conversation
    public String name;

    // The Team Member Id of the viewer
    public Id viewerTmId;

    // Whether the viewer's policy allows editing
    public Boolean viewerCanEdit;

    // The conversation's subject
    public SubjectModel subject;

    // The conversation's participants
    public List<PersonModel> participants;

    // The conversation's contents
    public List<FeedItemModel> items;
}
