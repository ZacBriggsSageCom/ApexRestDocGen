@isTest
public class ManagerDashboardControllerTest {

    private static fHCM2__Team_Member__c manager;
    private static fHCM2__Team_Member__c directReport1;
    private static fHCM2__Team_Member__c directReport2;

    private static void setUpManager() {
        manager = new fHCM2__Team_Member__c(
            fHCM2__User__c = UserInfo.getUserId()
        );
        insert manager;
    }
    /**
     * Set up the direct reports for the manager.
     */
    private static void setUpDirectReportsForManager() {
        setUpManager();
        directReport1 = new fHCM2__Team_Member__c(
            fHCM2__Manager__c = manager.Id
        );
        insert directReport1;
        directReport2 = new fHCM2__Team_Member__c(
            fHCM2__Manager__c = manager.Id
        );
        insert directReport2;
    }

    @isTest
    private static void testGetDirectReportsDetails_WithDrs() {
        setUpDirectReportsForManager();

        ManagerDashboardResponseModel model = ManagerDashboardController.getDirectReportsDetails();
        System.assertEquals(null, model.error);
        System.assertEquals(2, model.directReportsSummary.size());  
        
    }

    @isTest
    private static void testGetDirectReportsDetails_NoDrs() {
        setUpManager();
        ManagerDashboardResponseModel model = ManagerDashboardController.getDirectReportsDetails();
        System.assertNotEquals(null, model);
        System.assertEquals(0, model.directReportsSummary.size());
        System.assertEquals(null, model.error);

    }
    
    @isTest
    private static void testGetDirectReportsDetails_ReturnsErrorIfUserHasNoTeamMember() {
        ManagerDashboardResponseModel model = ManagerDashboardController.getDirectReportsDetails();
        System.assertEquals(null, model.directReportsSummary);
        System.assertNotEquals(null, model.error);
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, model.error.statusCode);
        System.assertEquals(Label.Error_No_Team_Member_For_User, model.error.error);

    }
}