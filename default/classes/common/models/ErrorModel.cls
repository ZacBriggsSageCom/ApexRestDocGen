/**
 * Model representing an error and its properties.
 */
public class ErrorModel {

    public Integer statusCode { get; set; }
    public String error { get; set; }
    public String description { get; set; }

    public ErrorModel(Integer statusCode, String error, String description) {
        this.statusCode = statusCode;
        this.error = error;
        this.description = description;
    }

}
