@isTest
public class RestUtilsTest {

    private class DummyObject {
        private String x;
    }

    @isTest
    private static void dummyTestForCoverage() {
        System.assertNotEquals(null, new RestUtils());
    }

    @isTest
    private static void testSetResponseBodyForBuildObjectException() {

        // GIVEN some ErrorContainer and a BuildObjectException
        BaseResponseModel response = new BaseResponseModel();
        Exception ex = new RestUtils.BuildObjectException('');

        // WHEN setting the response body with these parameters
        RestTestUtils.setupRestContext('GET', 'whatever');
        RestUtils.setResponseBody(response, ex);

        // THEN the error is set on the ErrorContainer
        System.assert(response.error != null);

        // AND the status code is set to BAD_REQUEST
        System.assertEquals(HttpUtils.STATUS_BAD_REQUEST,
                response.error.statusCode);
        
        // AND the RestContext responseBody is the serialized response
        System.assertEquals(Blob.valueOf(JSON.serialize(response, true)),
                RestContext.response.responseBody);

        // AND the RestContext response statusCode is BAD_REQUEST
        System.assertEquals(HttpUtils.STATUS_BAD_REQUEST,
                RestContext.response.statusCode);
    }

    @isTest
    private static void testSetResponseBodyForInternalError() {

        // GIVEN some ErrorContainer and some Exception
        BaseResponseModel response = new BaseResponseModel();
        Exception ex = new NullPointerException();

        // WHEN setting the response body with these parameters
        RestTestUtils.setupRestContext('GET', 'whatever');
        RestUtils.setResponseBody(response, ex);

        // THEN the error is set on the ErrorContainer
        System.assert(response.error != null);

        // AND the status code is set to INTERNAL_SERVER_ERROR
        System.assertEquals(HttpUtils.STATUS_INTERNAL_SERVER_ERROR,
                response.error.statusCode);
        
        // AND the RestContext responseBody is the serialized response
        System.assertEquals(Blob.valueOf(JSON.serialize(response, true)),
                RestContext.response.responseBody);

        // AND the RestContext response statusCode is BAD_REQUEST
        System.assertEquals(HttpUtils.STATUS_INTERNAL_SERVER_ERROR,
                RestContext.response.statusCode);
    }

    @isTest
    private static void testGetRequestBody() {

        // GIVEN some JSON request body
        RestTestUtils.setupRestContext('GET', 'whatever');
        RestContext.request.requestBody = Blob.valueOf('{"x": "hello"}');

        // WHEN calling getRequestBody with the correct type
        Object body = RestUtils.getRequestBody(DummyObject.class);

        // THEN the correct object is deserialised
        System.assert(body instanceof DummyObject);
        System.assertEquals('hello', ((DummyObject) body).x);
    }

    @isTest
    private static void testGetUrlQueryParams() {

        // GIVEN some URL with params
        RestTestUtils.setupRestContext('GET', '/search/people?NAME=Alice&group=Morgan');

        // WHEN we parse it
        Map<String,String> parsedUrl = RestUtils.getUrlQueryParams();

        // THEN it generates the correct output
        System.assertEquals('Alice', parsedUrl.get('name'));
        System.assertEquals('Morgan', parsedUrl.get('group'));

    }
}
