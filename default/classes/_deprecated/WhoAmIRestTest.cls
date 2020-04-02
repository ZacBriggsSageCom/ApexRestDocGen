// Deprecated
// (but preserved for coverage purposes)
@isTest
public class WhoAmIRestTest {

    @isTest
    private static void testGet() {
        RestTestUtils.setupRestContext('GET', 'me');
        WhoAmIRest.getWhoAmI();
        BaseResponseModel response = (BaseResponseModel)
                RestTestUtils.getResponseBody(BaseResponseModel.class);
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, response.getStatusCode());
    }

}
