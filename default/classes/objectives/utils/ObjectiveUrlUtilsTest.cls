/**
 * Tests exercising utilities for dealing with URLs of Objective pages.
 */
@isTest
public class ObjectiveUrlUtilsTest {

    @isTest
    private static void testGetObjectivePageUrl() {

        // GIVEN some subject
        fHCM2__Team_Member__c subject = new fHCM2__Team_Member__c(
            fHCM2__User__c = UserInfo.getUserId()
        );
        insert subject;

        // AND some Objective Item
        ObjectiveModel objective = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTitle('Expand and multiply')
                .setTeamMember(subject.Id)
                .setStatus(ObjectiveUtils.STATUS_ACTIVE)
                .save()
                .build();

        // WHEN I get the URL of the Objective page
        // relating to that team member and Objective Item
        String url = UrlTestUtils.replaceWithTestDomain(
                ObjectiveUrlUtils.getObjectivePageUrl(subject.Id, objective.Id));

        // THEN I get the expected value
        String expectedUrl = String.format(
                UrlTestUtils.TEST_DOMAIN + ObjectiveUrlUtils.OBJECTIVE_PAGE,
                new List<String>{
                        String.valueOf(subject.Id),
                        String.valueOf(objective.id)
                }
        );
        System.assertEquals(expectedUrl, url);
    }

}