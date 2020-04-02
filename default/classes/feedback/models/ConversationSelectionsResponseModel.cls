/**
 * Response model containing a list of possible Conversations to choose.
 */
public class ConversationSelectionsResponseModel extends BaseResponseModel {

    public List<ConversationSelectionModel> options { get; set; }

    public ConversationSelectionsResponseModel() {}

    public ConversationSelectionsResponseModel(ErrorModel error) {
        super(error);
    }

    public ConversationSelectionsResponseModel(List<ConversationSelectionModel> options) {
        this.options = options;
    }

}
