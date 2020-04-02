/**
 * REST endpoint for closing an Active Objective.
 */
@RestResource(urlMapping='/objective/*/close')
global class ObjectiveCloseRest {

    @TestVisible
    private static final String OBJECTIVE_PARAM = 'objective';

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
     * Closes an active objective.
     */
    @HttpPost
    global static void closeObjective() {
        try {
            // Get objective ID from URL
            String objectiveId = getObjectiveId();

            //Attempt update and construct response
            RestUtils.setResponseBody(
                    ObjectivesController.closeObjective(objectiveId));

        } catch (Exception e) {
            RestUtils.setResponseBody(new EditObjectiveResponseModel(), e);
        }
    }
}
