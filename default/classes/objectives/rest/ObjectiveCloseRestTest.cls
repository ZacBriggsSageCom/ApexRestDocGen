@IsTest
public class ObjectiveCloseRestTest {

    private static ObjectiveModel om;
    private static fHCM2__Team_Member__c subject;

    private static void setUp() {
        om = ObjectiveTestUtils.getMockObjective();
        subject = TeamMemberRepository.get(om.tmId);
    }

    //==========================================================================
    // Utilities
    //==========================================================================

    private static String buildURI(String objectiveId) {
        return '/' + ObjectiveCloseRest.OBJECTIVE_PARAM
                + '/' + objectiveId
                + '/close';
    }

    //==========================================================================
    // Test Methods
    //==========================================================================

    @isTest
    private static void testCloseObjective() {

        // GIVEN a draft objective
        setUp();
        Objective__c obj = new Objective__c(
            Title__c = 'Ceci n\'est pas un objectif',
            Team_Member__c = subject.Id,
            Status__c = 'Active'
        );
        insert obj;

        // WHEN I try to close it
        RestTestUtils.setupRestContext('POST', buildURI(obj.Id));
        ObjectiveCloseRest.closeObjective();
        EditObjectiveResponseModel response = (EditObjectiveResponseModel) RestTestUtils.getResponseBody(
                EditObjectiveResponseModel.class);

        // THEN the response code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND the status has been changed to close
        System.assertEquals(ObjectiveUtils.STATUS_CLOSED, response.objective.status);

        // AND the response does not contain an error
        System.assertEquals(null, response.error);
    }
}