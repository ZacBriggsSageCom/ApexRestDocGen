@isTest
public class GlobalConfigRestTest {

    @isTest
    private static void testGet() {
        RestTestUtils.setupRestContext('GET', '/config');
        GlobalConfigRest.getGlobalConfig();
        GlobalConfigResponseModel response = (GlobalConfigResponseModel)
                RestTestUtils.getResponseBody(GlobalConfigResponseModel.class);
        System.assertNotEquals(null, response);
    }

}
