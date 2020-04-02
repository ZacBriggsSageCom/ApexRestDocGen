/**
 * Test utility class for REST controllers.
 */
@isTest
public class RestTestUtils {

    /**
     * Simulates a REST request to the given resource.
     */
    public static void setupRestContext(String method, String resource) {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/' + resource;
        req.httpMethod = method;

        RestContext.request = req;
        RestContext.response = res;
    }

    public static Object getResponseBody(Type t) {
        return JSON.deserialize(RestContext.response.responseBody.toString(), t);
    }

    public static void addUrlParam(String name, String value) {
        RestContext.request.addParameter(name, value);
    }

    public static void setRequestBody(Object model) {
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(model));
    }

}
