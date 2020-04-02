/**
 * Model representing a response to a request to access a File.
 */
public class FileLinkResponseModel extends BaseResponseModel {
    
    // The URL of the requested File
    public String url { get; set; }

    public FileLinkResponseModel() {}

    public FileLinkResponseModel(ErrorModel error) {
        super(error);
    }

    public FileLinkResponseModel(String url) {
        this.url = url;
    }
}
