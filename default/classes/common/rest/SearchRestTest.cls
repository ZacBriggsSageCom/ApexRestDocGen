/**
 * Test for REST search endpoint
 */
@isTest
public class SearchRestTest {
    private static PersonModel tm1;
    private static PersonModel tm2;
    private static PersonModel tm3;
    private static PersonModel tm4;
    private static PersonModel tm5;

    @TestSetup
    private static void setUp() {
        // Creates a series of team-members in the database which we can query against
        String[] names = new String[] {
                'Alison Will',
                'Bob Builder',
                'Hector Heckle',
                'Henry Hades',
                'Justin Williams'
        };
        for (String name : names) {
            new TeamMemberTestUtils.TeamMemberBuilder()
                    .setName(name)
                    .build();
        }
    }

    private static void retrieveTeamMembers() {
        //  (Here we are retrieving the already-inserted records), see the test setUp()
        List<fHCM2__Team_Member__c> tms = [
                SELECT
                        Id,
                        Name,
                        fHCM2__User__c,
                        fHCM2__First_Name__c,
                        fHCM2__Picture_URL__c,
                        fHCM2__Policy__c,
                        fHCM2__Department__r.fHCM2__Policy__c
                FROM fHCM2__Team_Member__c
                ORDER BY Name
        ];

        tm1 = TeamMemberUtils.createPerson(tms[0]);
        tm2 = TeamMemberUtils.createPerson(tms[1]);
        tm3 = TeamMemberUtils.createPerson(tms[2]);
        tm4 = TeamMemberUtils.createPerson(tms[3]);
        tm5 = TeamMemberUtils.createPerson(tms[4]);
    }

    @isTest
    private static void testSearch() {

        // GIVEN some team-members
        retrieveTeamMembers();


        // WHEN we perform a search
        RestTestUtils.setupRestContext('GET', '/search/people?term=Alis');
        SearchRest.search();
        SearchPeopleResponseModel response = (SearchPeopleResponseModel)
                RestTestUtils.getResponseBody(SearchPeopleResponseModel.class);

        // THEN the response does not contain an error
        System.assertEquals(null, response.error);

        // AND the response code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND we get expected data retrieved
        System.assertEquals(tm1.name, response.people[0].name);
    }

    @isTest
    private static void testSearchEmptyValue() {

        // GIVEN some team-members
        retrieveTeamMembers();

        // WHEN we perform a search with no term
        RestTestUtils.setupRestContext('GET', '/search/people?term=');
        SearchRest.search();
        SearchPeopleResponseModel response = (SearchPeopleResponseModel)
                RestTestUtils.getResponseBody(SearchPeopleResponseModel.class);

        // THEN the response does not contain an error
        System.assertEquals(null, response.error);

        // AND the response code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND we get no team-members returned
        System.assertEquals(null, response.people);
    }

    @isTest
    private static void testSearchBadEndpoint() {

        // GIVEN some team-members
        retrieveTeamMembers();

        RestTestUtils.setupRestContext('GET', '/search/meeple?term=alic');
        SearchRest.search();
        SearchPeopleResponseModel response = (SearchPeopleResponseModel)
                RestTestUtils.getResponseBody(SearchPeopleResponseModel.class);

        // THEN the response should contain an error
        System.assertNotEquals(null, response.error);

        // AND the response code should be 'NOT FOUND'
        System.assertEquals(HttpUtils.STATUS_NOT_FOUND, response.getStatusCode());
    }

    @isTest
    private static void testGetSearchType() {

        // GIVEN some URL that fits the format for getting its type of search
        RestTestUtils.setupRestContext('GET', '/search/people?NAME=Alice&group=Morgan');

        // WHEN we parse it
        String searchType = SearchRest.getSearchType();

        // THEN we retrieve the expected output
        System.assertEquals('people', searchType);
    }

    @isTest
    private static void testGetSearchTypeThrowsException() {

        // GIVEN some URL that breaks the format for getting its type of search
        RestTestUtils.setupRestContext('GET', '/search/peopleNAME=Alice&group=Morgan');
        try {

            // WHEN we parse it
            SearchRest.getSearchType();
        } catch (Exception e) {

            // THEN we retrieve the expected output
            System.assert(e instanceof RestUtils.StringNotFoundException);
            System.assertEquals('Unable to find start of search query in url', e.getMessage());
        }
    }
}
