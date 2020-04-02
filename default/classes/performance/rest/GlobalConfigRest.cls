/**
 * REST endpoint for getting the global configuration for the Performance app.
 */
@RestResource(urlMapping='/config')
global class GlobalConfigRest {

    @HttpGet
    global static void getGlobalConfig() {
        try {
            RestUtils.setResponseBody(GlobalConfigController.getGlobalConfig());
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            RestUtils.setResponseBody(new GlobalConfigResponseModel(), e);
        }
    }

}