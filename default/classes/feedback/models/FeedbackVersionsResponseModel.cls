/**
 * Model representing a response regarding a list of Feedback items.
 */
public class FeedbackVersionsResponseModel extends BaseResponseModel {

    public List<FeedItemModel> history { get; set; }

    public FeedbackVersionsResponseModel() {}

    public FeedbackVersionsResponseModel(ErrorModel error) {
        super(error);
    }

    public FeedbackVersionsResponseModel(List<FeedItemModel> history) {
        this.history = history;
    }

}
