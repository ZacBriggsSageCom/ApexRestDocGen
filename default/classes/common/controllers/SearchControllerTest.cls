@IsTest
public class SearchControllerTest {
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

    private static Set<Id> getIdsFrom(List<PersonModel> items) {
        Set<Id> idSet = new Set<Id>();
        for (PersonModel item : items) {
            idSet.add(item.id);
        }
        return idSet;
    }

    @isTest
    private static void testSearchPeopleWithSimilarNames() {

        // GIVEN some team-members
        retrieveTeamMembers();

        // WHEN we make searches for some strings we know appear in multiple names
        SearchPeopleResponseModel search1  = SearchController.searchPeople('He');
        SearchPeopleResponseModel search2  = SearchController.searchPeople('Will');
        Set<Id> s1 = getIdsFrom(search1.people);
        Set<Id> s2 = getIdsFrom(search2.people);

        // THEN we get back the team-members we are expecting, and only those results
        System.assert(s1.contains(tm3.id));
        System.assert(s1.contains(tm4.id));
        System.assert(s1.size() == 2);

        System.assert(s2.contains(tm1.id));
        System.assert(s2.contains(tm5.id));
        System.assert(s2.size() == 2);
    }

    @isTest
    private static void testSearchPeopleWithDistinctName() {

        // GIVEN some team-members
        retrieveTeamMembers();

        // WHEN we search for a user whose name is unlike any others
        SearchPeopleResponseModel search1 = SearchController.searchPeople('Bob');
        Set<Id> s1 = getIdsFrom(search1.people);

        // THEN we only get back a single result of the team-members we are expecting
        System.assert(s1.contains(tm2.id));
        System.assert(s1.size() == 1);
    }

    @isTest
    private static void testSearchPeopleForNonexistentName() {

        // GIVEN some team-members
        retrieveTeamMembers();

        // WHEN we search a name for which there is no team-members
        SearchPeopleResponseModel search1 = SearchController.searchPeople('James');
        Set<Id> s1 = getIdsFrom(search1.people);

        // THEN we get back no results
        System.assert(s1.size() == 0);
    }
}
