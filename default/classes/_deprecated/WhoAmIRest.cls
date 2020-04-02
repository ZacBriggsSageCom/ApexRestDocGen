// Deprecated
@RestResource(urlMapping='/whoami')
global class WhoAmIRest {

    private static void complain() {
        RestUtils.setResponseBody(
                new BaseResponseModel(new ErrorModel(
                        HttpUtils.STATUS_FORBIDDEN,
                        'Invalid REST URL',
                        '')));
    }

    @HttpGet
    global static void getWhoAmI() {
        complain();
    }

}
