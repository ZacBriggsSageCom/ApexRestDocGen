/**
 * Model representing a list of objectives.
 */
public class ObjectiveListResponseModel extends BaseResponseModel {

    public List<ObjectiveModel> items { get; set; }

    public ObjectiveListResponseModel() {}

    public ObjectiveListResponseModel(ErrorModel error) {
        super(error);
    }

    public ObjectiveListResponseModel(List<ObjectiveModel> items) {
        this.items = items;
    }
}
