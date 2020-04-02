/**
 * REST endpoint for getting the context for the viewing team member.
 */
@RestResource(urlMapping='/viewercontext')
global class ViewerContextRest {

    @HttpGet
    global static void getViewerContext() {
        try {
            RestUtils.setResponseBody(ViewerContextController.getViewerContext());
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            RestUtils.setResponseBody(new ViewerContextResponseModel(), e);
        }
    }

}
