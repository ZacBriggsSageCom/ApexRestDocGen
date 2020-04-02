/**
 * Created by zac.briggs on 07/01/2020.
 */
@RestResource(urlMapping='/objective/activate')
global class ObjectiveActivateRest {

    @TestVisible
    private static final String OBJECTIVE_PARAM = 'objective';

    /**
     * Activate an objective
     */
    @HttpPost
    global static void activateObjective() {
        try {
            //Retrieve Objective from request body
            ObjectiveModel objective = (ObjectiveModel)
                    RestUtils.getRequestBody(ObjectiveModel.class);

            //Attempt edit and activation, then construct response
            RestUtils.setResponseBody(
                    ObjectivesController.activateObjective(objective));

        } catch (Exception e) {
            RestUtils.setResponseBody(new EditObjectiveResponseModel(), e);
        }
    }
}