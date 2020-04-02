/**
 * Model representing a prototype response, with a notion of an error.
 */
public virtual class BaseResponseModel implements ErrorContainer {

    // The response's error.
    public ErrorModel error { get; set; }

    public BaseResponseModel() {}

    public BaseResponseModel(ErrorModel error) {
        this.error = error;
    }

    public void setError(ErrorModel error) {
        this.error = error;
    }

    public Integer getStatusCode() {
        return error == null ? HttpUtils.STATUS_OK : error.statusCode;
    }

}
