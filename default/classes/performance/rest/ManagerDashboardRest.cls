/**
 * REST endpoint for getting the details of the Direct Reports.
 */
@RestResource(urlMapping='/manager-dashboard')
global class ManagerDashboardRest {

    @HttpGet
    global static void getManagerDashboard() {
        try {
            RestUtils.setResponseBody(ManagerDashboardController.getDirectReportsDetails());
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            RestUtils.setResponseBody(new ManagerDashboardResponseModel(
                                                new List<TeamMemberSummaryModel> ()), e);
        }
    }
}