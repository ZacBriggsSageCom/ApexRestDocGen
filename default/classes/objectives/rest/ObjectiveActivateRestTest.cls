/**
 * Created by zac.briggs on 07/01/2020.
 */
@IsTest
public class ObjectiveActivateRestTest {
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

    private static String buildURI() {
        return ObjectiveRest.OBJECTIVE_PARAM + '/activate';
    }

    //==========================================================================
    // Test Methods
    //==========================================================================

    @isTest
    private static void testActivate() {

        //GIVEN an objective
        setUp();
        Objective__c objective = new ObjectiveRecordBuilder(om)
                .save()
                .build();

        //And I set the id of the model to the persisted objective
        om.id = objective.Id;
        //And I edit the title of the objective model
        om.title = 'Something I will do';

        //WHEN I try to edit it
        RestTestUtils.setupRestContext('POST', buildURI());
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(om));
        ObjectiveActivateRest.activateObjective();
        EditObjectiveResponseModel response = receiveResponse();

        System.assertNotEquals(null, response);
    }
}