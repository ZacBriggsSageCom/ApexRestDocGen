@isTest
public class TeamControllerTest {

    @isTest
    private static void testGetTeamForInvalidUser() {

        // GIVEN the current user has no associated Team Member
        // WHEN getting the list of subjects
        ConversationSelectionsResponseModel resp = TeamController.getTeam();

        // THEN the response contains an error
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, resp.error.statusCode);

        // AND the response contains no subjects
        System.assertEquals(null, resp.options);
    }

    @isTest
    private static void testGetTeamForTmWithNoDirectReports() {

        // GIVEN the current user's TM has no direct reports
        fHCM2__Team_Member__c tm = new fHCM2__Team_Member__c(
            Name = 'Me!',
            fHCM2__User__c = UserInfo.getUserId()
        );
        insert tm;

        // WHEN getting the team
        ConversationSelectionsResponseModel resp = TeamController.getTeam();

        // THEN the response contains no error
        System.assertEquals(null, resp.error);

        // AND the response contains only the current Team Member
        System.assertEquals(1, resp.options.size());
        System.assertEquals('Me!', resp.options[0].recipient.name);
        System.assertEquals(TeamMemberUtils.SELF, resp.options[0].recipient.relationship);
    }

    @isTest
    private static void testGetTeamForTmWithDirectReports() {

        // GIVEN the current user's TM has 2 direct reports
        fHCM2__Team_Member__c tm = new fHCM2__Team_Member__c(
            Name = 'Me!',
            fHCM2__User__c = UserInfo.getUserId()
        );
        insert tm;

        fHCM2__Team_Member__c dr1 = new fHCM2__Team_Member__c(
            Name = 'Direct Report 1',
            fHCM2__Manager__c = tm.Id
        );
        fHCM2__Team_Member__c dr2 = new fHCM2__Team_Member__c(
            Name = 'Direct Report 2',
            fHCM2__Manager__c = tm.Id
        );
        insert new List<fHCM2__Team_Member__c> { dr1, dr2 };

        // WHEN getting the team
        ConversationSelectionsResponseModel resp = TeamController.getTeam();

        // THEN the response contains no error
        System.assertEquals(null, resp.error);

        // AND the response contains the current Team Member and both direct
        // reports
        System.assertEquals(3, resp.options.size());
        System.assertEquals('Me!', resp.options[0].recipient.name);
        System.assertEquals(TeamMemberUtils.SELF, resp.options[0].recipient.relationship);
        System.assertEquals('Direct Report 1', resp.options[1].recipient.name);
        System.assertEquals(TeamMemberUtils.DIRECT_REPORT, resp.options[1].recipient.relationship);
        System.assertEquals('Direct Report 2', resp.options[2].recipient.name);
        System.assertEquals(TeamMemberUtils.DIRECT_REPORT, resp.options[2].recipient.relationship);
    }

}