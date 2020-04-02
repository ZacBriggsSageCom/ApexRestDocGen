public class ViewerContextResponseModel extends BaseResponseModel {

    public ViewerContextModel data;

    public ViewerContextResponseModel() {}

    public ViewerContextResponseModel(ErrorModel error) {
        super(error);
    }

    public ViewerContextResponseModel(ViewerContextModel data) {
        this.data = data;
    }
}
