/**
 * Model representing a response regarding a Conversation.
 */
public class ConversationResponseModel extends BaseResponseModel {

    public ConversationModel conversation { get; set; }

    public ConversationResponseModel() {}

    public ConversationResponseModel(ErrorModel error) {
        super(error);
    }

    public ConversationResponseModel(ConversationModel conversation) {
        this.conversation = conversation;
    }
}
