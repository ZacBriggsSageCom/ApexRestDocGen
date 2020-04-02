public class EditObjectiveResponseModel extends BaseResponseModel {
    
    public ObjectiveModel objective { get; set; }

    public EditObjectiveResponseModel() {}

    public EditObjectiveResponseModel(ErrorModel error) {
        super(error);
    }

    public EditObjectiveResponseModel(ObjectiveModel objective) {
        this.objective = objective;
    }
}
