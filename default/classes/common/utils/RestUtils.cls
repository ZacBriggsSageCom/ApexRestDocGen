/**
 * Utility class for REST controllers.
 */
public class RestUtils {

    public class BuildObjectException extends Exception {}

    public class StringNotFoundException extends Exception {}

    /**
     * Set the REST response body and status code, using an ErrorContainer such
     * as BaseResponseModel.
     *
     * @param container
     */
    public static void setResponseBody(ErrorContainer container) {
        setResponseBody(container, container.getStatusCode());
    }

    /**
     * Set the REST response body and status code, using an ErrorContainer and
     * an Exception.
     *
     * @param container
     * @param e - the exception
     */
    public static void setResponseBody(ErrorContainer container, Exception e) {
        if (e instanceof BuildObjectException) {
            // Error during deserialization
            setResponseBody(container, e, HttpUtils.STATUS_BAD_REQUEST);
        } else {
            setResponseBody(container, e, HttpUtils.STATUS_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Set the REST response body and status code, using an ErrorContainer and
     * an Exception, where we already know the status code.
     *
     * @param container
     * @param e - the exception
     * @param statusCode
     */
    public static void setResponseBody(
            ErrorContainer container, Exception e, Integer statusCode) {
        container.setError(new ErrorModel(
            statusCode,
            e.getMessage(),
            e.getStackTraceString()
        ));
        setResponseBody(container);
    }

    /**
     * Set the REST response body and status code.
     *
     * @param payload
     * @param statusCode
     */
    public static void setResponseBody(Object payload, Integer statusCode) {
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(payload, true));
        RestContext.response.statusCode = statusCode;
    }

    /**
     * Deserialize the request body to the given type.
     *
     * @param t - the type
     * @return Object
     */
    public static Object getRequestBody(Type t) {
        try {
            return JSON.deserialize(RestContext.request.requestBody.toString(), t);
        } catch (Exception e) {
            throw new BuildObjectException(Label.Error_Invalid_JSON);
        }
    }

    /**
     * Extract from the current request URL the value of the given parameter,
     * e.g. "tm" would give the TM Id that follows it.
     */
    public static String getUrlParam(String paramName) {
        String url = RestContext.request.requestURI;

        if (!url.contains('/' + paramName + '/')) {
            throw new StringNotFoundException(
                    'Parameter "' + paramName + '" not found in url: ' + url);
        }

        List<String> segments = url.split('/');
        Integer lastIndexOfParamName = 0;

        for (Integer i = 0; i < segments.size(); i++) {
            if (segments.get(i) == paramName) {
                lastIndexOfParamName = i;
            }
        }

        // If ours is the last segment in the URL, there is no value to find
        if (lastIndexOfParamName == segments.size()) {
            throw new StringNotFoundException(
                'Value of "' + paramName + '" not found in url: ' + url);
        }

        return segments.get(lastIndexOfParamName + 1);
}

    /**
     * Extract from the current request URL a list of query parameters
     */
    public static Map<String, String> getUrlQueryParams() {
        List<String> querySegments = new Url(
                Url.getSalesforceBaseUrl().toExternalForm() + RestContext.request.requestURI).getQuery().split('\\&');

        // Build a map from each param to respective values
        Map<String, String> queryValueMap = new Map<String, String>();
        for (String qSegment : querySegments) {
            List<String> queryParts = qSegment.split('=');
            if (queryParts.size() > 1) {
                queryValueMap.put(queryParts[0].toLowerCase(), queryParts[1]);
            }
        }

        return queryValueMap;
    }

}
