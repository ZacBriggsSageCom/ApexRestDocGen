public class GlobalConfigResponseModel extends BaseResponseModel{

    public GlobalConfigModel cfg { get; set; }

    public GlobalConfigResponseModel() {}

    public GlobalConfigResponseModel(ErrorModel error) {
        super(error);
    }

    public GlobalConfigResponseModel(GlobalConfigModel cfg) {
        this.cfg = cfg;
    }

}
