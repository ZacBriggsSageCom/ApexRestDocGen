/**
 * Model representing a response regarding a Feedback item.
 */
public class FeedbackResponseModel extends BaseResponseModel {

    // The Feedback item
    public FeedItemModel item { get; set; }

    public FeedbackResponseModel() {}

    public FeedbackResponseModel(ErrorModel error) {
        super(error);
    }

    public FeedbackResponseModel(FeedItemModel item) {
        this.item = item;
    }

}
