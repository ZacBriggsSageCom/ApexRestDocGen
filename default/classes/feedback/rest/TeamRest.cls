/**
 * REST endpoint for retrieving possible subjects.
 */
@RestResource(urlMapping='/feedback/team')
global class TeamRest {

    /**
     * Gets the list of possible subjects.
     */
    @HttpGet
    global static void getTeam() {
        try {
            RestUtils.setResponseBody(TeamController.getTeam());
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            RestUtils.setResponseBody(new ConversationSelectionsResponseModel(), e);
        }
    }

}
