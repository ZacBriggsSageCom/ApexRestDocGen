/**
 * Interface representing something which has a notion of an error.
 */
public interface ErrorContainer {

    void setError(ErrorModel error);

    Integer getStatusCode();

}
