/**
 * REST endpoint for retrieving process details.
 */
@RestResource(urlMapping='/tm/*/process-details')
global class ProcessDetailsRest {

    @TestVisible
    private static final String TM_PARAM = 'tm';

    /**
     * Get Team Member's Id from the URL.
     *
     * @return Id
     */
    @TestVisible
    private static Id getTeamMemberId() {
        return Id.valueOf(RestUtils.getUrlParam(TM_PARAM));
    }

    /**
     * Gets the details of the Performance Overview process.
     */
    @HttpGet
    global static void getPerformanceOverviewDetails() {
        try {

            Id tmId = getTeamMemberId();

            RestUtils.setResponseBody(
                    ProcessDetailsController.getPerformanceOverviewDetails(
                            tmId));

        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            RestUtils.setResponseBody(new ProcessDetailsResponseModel(), e);
        }
    }

}
