/**
 * Test class for the Subjects REST controller.
 */
@isTest
public class TeamRestTest {

    @isTest
    private static void testGetTeam() {

        // WHEN requesting subjects
        RestTestUtils.setupRestContext('GET', '/feedback/team');
        TeamRest.getTeam();
        ConversationSelectionsResponseModel response =
                (ConversationSelectionsResponseModel) RestTestUtils.getResponseBody(
                        ConversationSelectionsResponseModel.class);

        // THEN the response is not null
        System.assertNotEquals(null, response);
    }

}
