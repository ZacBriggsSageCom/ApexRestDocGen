@isTest
public class ViewerContextRestTest {

    @isTest
    private static void testGet() {
        RestTestUtils.setupRestContext('GET', 'viewercontext');
        ViewerContextRest.getViewerContext();
        ViewerContextResponseModel response = (ViewerContextResponseModel)
                RestTestUtils.getResponseBody(ViewerContextResponseModel.class);
        System.assertNotEquals(null, response);
    }

}
