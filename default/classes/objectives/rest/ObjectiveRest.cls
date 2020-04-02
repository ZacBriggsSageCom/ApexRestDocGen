/**
 * REST endpoint for Objectives.
 */
@RestResource(urlMapping='/tm/*/objective/*')
global class ObjectiveRest {

    @TestVisible
    private static final String TM_PARAM = 'tm';

    @TestVisible
    private static final String OBJECTIVE_PARAM = 'objective';

    /**
     * Get subject team member ID from the URL
     */
    @TestVisible
    private static Id getTmId() {
        return Id.valueOf(RestUtils.getUrlParam(TM_PARAM));
    }

    /**
     * Get objective ID from the URL
     */
    @TestVisible
    private static Id getObjectiveId() {
        return Id.valueOf(RestUtils.getUrlParam(OBJECTIVE_PARAM));
    }

    //==========================================================================
    // Operations
    //==========================================================================

    /**
     * Gets all of the subject team member's objectives.
     */
    @HttpGet
    global static void getObjectives() {
        try {
            // Get team member ID from URL
            Id tmId = getTmId();

            // Attempt retrieval and construct response
            RestUtils.setResponseBody(ObjectivesController.getObjectives(tmId));

        } catch (Exception e) {
            RestUtils.setResponseBody(new ObjectiveListResponseModel(), e);
        }
    }

    /**
     * Saves a new objective.
     */
    @HttpPost
    global static void insertObjective() {
        try {
            //Retrieve Objective from request body
            ObjectiveModel objective = (ObjectiveModel)
                    RestUtils.getRequestBody(ObjectiveModel.class);

            //Attempt insertion and construct response
            RestUtils.setResponseBody(
                    ObjectivesController.createObjective(objective));

        } catch (Exception e) {
            RestUtils.setResponseBody(new EditObjectiveResponseModel(), e);
        }
    }

    /**
     * Edit an existing objective
     */
    @HttpPut
    global static void editObjective() {
        try {
            //Retrieve Objective from request body
            ObjectiveModel objective = (ObjectiveModel)
                    RestUtils.getRequestBody(ObjectiveModel.class);

            //Attempt edit and construct response
            RestUtils.setResponseBody(
                    ObjectivesController.editObjective(objective));

        } catch (Exception e) {
            RestUtils.setResponseBody(new EditObjectiveResponseModel(), e);
        }
    }

    /**
     * Delete an objective by ID
     */
    @HttpDelete
    global static void deleteObjective() {
        try {
            // Get objective ID from URL
            String objectiveId = getObjectiveId();

            // Attempt deletion and construct response
            RestUtils.setResponseBody(ObjectivesController.deleteObjective(objectiveId));

        } catch (Exception e) {
            RestUtils.setResponseBody(new BaseResponseModel(), e);
        }
    }
}
