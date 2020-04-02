/**
 * Model representing a possible Conversation to choose.
 */
public class ConversationSelectionModel {

    // The ID of the Conversation in question
    public String conversationId { get; set; }

    // The person with whom the viewer will converse
    public PersonModel recipient { get; set; }

    public ConversationSelectionModel(PersonModel recipient) {
        this.recipient = recipient;
    }

    public ConversationSelectionModel(String conversationId, PersonModel recipient) {
        this.conversationId = conversationId;
        this.recipient = recipient;
    }
}
