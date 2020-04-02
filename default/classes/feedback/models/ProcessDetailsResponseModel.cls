public class ProcessDetailsResponseModel extends BaseResponseModel {

    public String serviceId { get; set; }

    public String processId { get; set; }

    public ProcessDetailsResponseModel() { }

    public ProcessDetailsResponseModel(ErrorModel error) {
        super(error);
    }

    public ProcessDetailsResponseModel(String serviceId, String processId) {
        this.serviceId = serviceId;
        this.processId = processId;
    }

}
