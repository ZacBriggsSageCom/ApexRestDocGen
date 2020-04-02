@IsTest
public class ObjectiveRestTest {

    private static ObjectiveModel om;
    private static fHCM2__Team_Member__c subject;

    private static void setUp() {
        om = ObjectiveTestUtils.getMockObjective();
        subject = TeamMemberRepository.get(om.tmId);
    }

    //==========================================================================
    // Utilities
    //==========================================================================

    /**
     * Get response, if expecting a EditObjectiveResponseModel.
     * (for per-item ops)
     */
    private static EditObjectiveResponseModel receiveResponse() {
        return (EditObjectiveResponseModel) RestTestUtils.getResponseBody(
                EditObjectiveResponseModel.class);
    }

    /**
     * Get response, if expecting a list of objectives.
     */
    private static ObjectiveListResponseModel receiveListResponse() {
        return (ObjectiveListResponseModel) RestTestUtils.getResponseBody(
                ObjectiveListResponseModel.class);
    }

    private static String buildURI(String tmId, String objectiveId) {
        return '/' + ObjectiveRest.TM_PARAM
                + '/' + tmId
                + '/' + ObjectiveRest.OBJECTIVE_PARAM
                + '/' + objectiveId;
    }

    //==========================================================================
    // Test Methods
    //==========================================================================

    @isTest
    private static void testGetObjectives() {

        // GIVEN a team member with some objective
        setUp();

        // WHEN I get all their objectives
        RestTestUtils.setupRestContext('GET', buildURI(subject.Id, om.id));
        ObjectiveRest.getObjectives();
        ObjectiveListResponseModel response = receiveListResponse();

        // THEN the response code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND the response does not contain an error
        System.assertEquals(null, response.error);

        // AND we get their objectives
        System.assertNotEquals(null, response.items);
    }

    @isTest
    private static void testInsertObjective() {

        //GIVEN an objective
        setUp();

        //WHEN I try to insert it
        RestTestUtils.setupRestContext('POST', buildURI(subject.Id, om.id));
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(om));
        ObjectiveRest.insertObjective();
        EditObjectiveResponseModel response = receiveResponse();

        // THEN the response code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND some arbitrary value still exists
        System.assertEquals(om.category, response.objective.category);

        // AND some value we didn't provide has been populated
        System.assertNotEquals(response.objective.creator, null);

        // AND the response does not contain an error
        System.assertEquals(null, response.error);
    }

    @isTest
    private static void testEditObjective() {

        //GIVEN an objective
        setUp();
        Objective__c objective = ObjectiveUtils.createObjective(om);

        //And I set the id of the model to the persisted objective
        om.id = objective.Id;
        //And I edit the title of the objective model
        om.title = 'Something I will do';

        //WHEN I try to edit it
        RestTestUtils.setupRestContext('PUT', buildURI(subject.Id, om.id));
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(om));
        ObjectiveRest.editObjective();
        EditObjectiveResponseModel response = receiveResponse();

        // THEN the response code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND the edited value exists
        System.assertEquals('Something I will do', response.objective.title);

        // AND some arbitrary value still exists
        System.assertEquals(om.category, response.objective.category);

        // AND some value we didn't provide has been populated
        System.assertEquals('Wilma Worm', response.objective.creator.name);

        // AND the response does not contain an error
        System.assertEquals(null, response.error);
    }

    @isTest
    private static void testDeleteObjective() {

        // GIVEN a draft objective
        setUp();
        Objective__c obj = new Objective__c(
            Title__c = 'Ceci n\'est pas un objectif',
            Team_Member__c = subject.Id,
            Status__c = 'Draft'
        );
        insert obj;

        // WHEN I try to delete it
        RestTestUtils.setupRestContext('DELETE', buildURI(subject.Id, obj.Id));
        ObjectiveRest.deleteObjective();
        BaseResponseModel response = (BaseResponseModel) RestTestUtils.getResponseBody(
                BaseResponseModel.class);

        // THEN the response code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND the response does not contain an error
        System.assertEquals(null, response.error);
    }
}