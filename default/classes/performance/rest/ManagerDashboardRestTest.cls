@isTest
public class ManagerDashboardRestTest {

    @isTest
    private static void testGet() {
        RestTestUtils.setupRestContext('GET', '/manager-dashboard');
        ManagerDashboardRest.getManagerDashboard();
        ManagerDashboardResponseModel response = (ManagerDashboardResponseModel)
                RestTestUtils.getResponseBody(ManagerDashboardResponseModel.class);
        System.assertNotEquals(null, response);
    }

}