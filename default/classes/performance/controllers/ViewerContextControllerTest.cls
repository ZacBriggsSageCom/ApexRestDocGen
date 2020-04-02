@isTest
public class ViewerContextControllerTest {

    @isTest
    private static void testViewerContext_ReturnsValidTmId() {

        // GIVEN a team member as the user
        fHCM2__Team_Member__c tm = new fHCM2__Team_Member__c(
            fHCM2__User__c = UserInfo.getUserId()
        );
        insert tm;

        // WHEN we ask for their context
        ViewerContextResponseModel model = ViewerContextController.getViewerContext();

        // THEN what we get back matches the user, and has no errors
        System.assertEquals(null, model.error);
        System.assertNotEquals(null, model.data);
        System.assertEquals(tm.Id, model.data.id);
        System.assertNotEquals(null, model.data.pictureUrl);
    }

    @isTest
    private static void testGetViewerContext_ReturnsManager() {

        // GIVEN a user who is a manager
        fHCM2__Team_Member__c tm = new fHCM2__Team_Member__c(
            fHCM2__User__c = UserInfo.getUserId()
        );
        insert tm;
        fHCM2__Team_Member__c directReport = new fHCM2__Team_Member__c(
            fHCM2__Manager__c = tm.Id
        );
        insert directReport;

        // WHEN we request their context
        ViewerContextResponseModel model = ViewerContextController.getViewerContext();

        // THEN we have no errors
        System.assertEquals(null, model.error);
        System.assertNotEquals(null, model.data);
        System.assertNotEquals(null, model.data.pictureUrl);

        // AND they are indeed  a manager
        System.assertEquals(true, model.data.isManager);
    }

    @isTest
    private static void testGetViewerContext_ReturnsDrIfManager() {

        // Given a user who has a direct report (is a manager)
        fHCM2__Team_Member__c tm = new fHCM2__Team_Member__c(
                fHCM2__User__c = UserInfo.getUserId()
        );
        insert tm;
        fHCM2__Team_Member__c directReport = new fHCM2__Team_Member__c(
                fHCM2__Manager__c = tm.Id
        );
        insert directReport;

        // When we request such a users context
        ViewerContextResponseModel model = ViewerContextController.getViewerContext();

        // THEN there are no errors & we get some data back
        System.assertEquals(null, model.error);
        System.assertNotEquals(null, model.data);

        // AND particularly, included in the data, we get the correct direct report
        System.assertEquals(directReport.id, model.data.directReports[0].id);
    }

    @isTest
    private static void testGetViewerContext_ReturnsViewersManager() {

        // GIVEN a user who has a manager
        fHCM2__Team_Member__c manager = new fHCM2__Team_Member__c();
        insert manager;
        fHCM2__Team_Member__c viewer = new fHCM2__Team_Member__c(
                fHCM2__Manager__c = manager.Id,
                fHCM2__User__c = UserInfo.getUserId()
        );
        insert viewer;

        // WHEN we request their context
        ViewerContextResponseModel model = ViewerContextController.getViewerContext();

        // THEN we get no errors
        System.assertEquals(null, model.error);

        // AND the known manager is found in the returned data
        System.assertEquals(manager.Id, model.data.manager.id);
    }

    @isTest
    private static void testGetViewerContext_ReturnsNotManager() {

        // GIVEN a user who is not a manager
        fHCM2__Team_Member__c tm = new fHCM2__Team_Member__c(
            fHCM2__User__c = UserInfo.getUserId()
        );
        insert tm;

        // WHEN we request their context
        ViewerContextResponseModel model = ViewerContextController.getViewerContext();

        // THEN there are no errors
        System.assertEquals(null, model.error);
        System.assertNotEquals(null, model.data);
        System.assertNotEquals(null, model.data.pictureUrl);

        // AND the isManager field correctly asserts the user is not a manager
        System.assertEquals(false, model.data.isManager);

    }

    @isTest
    private static void testGetViewerContext_ReturnsErrorIfUserHasNoTeamMember() {

        // GIVEN the user has no team member
        ViewerContextResponseModel model = ViewerContextController.getViewerContext();

        // THEN we return, correctly, errors
        System.assertEquals(null, model.data);
        System.assertNotEquals(null, model.error);
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, model.error.statusCode);
        System.assertEquals(Label.Error_No_Team_Member_For_User, model.error.error);
    }

}