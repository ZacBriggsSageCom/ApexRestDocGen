/**
 * These tests exercises the ProcessDetailsRest class for coverage purposes,
 * but the main logic is tested elsewhere.
 */
@isTest
public class ProcessDetailsRestTest {

    @isTest
    private static void testGetPerformanceOverviewDetails() {

        // GIVEN no Performance Overview process has been configured
        // WHEN requesting the Performance Overview process details
        RestTestUtils.setupRestContext('GET', '/process-details');
        ProcessDetailsRest.getPerformanceOverviewDetails();
        ProcessDetailsResponseModel response = 
                (ProcessDetailsResponseModel) RestTestUtils.getResponseBody(
                        ProcessDetailsResponseModel.class);

        // THEN the response code is 500
        System.assertEquals(
                HttpUtils.STATUS_INTERNAL_SERVER_ERROR,
                response.getStatusCode());

        // AND the response contains an error
        System.assert(response.error != null);
    }

}
