/**
 * Tests exercising utilities for working with Team Members.
 */
@isTest
public class TeamMemberUtilsTest {

    private static User user;
    private static fHCM2__Team_Member__c tm;
    private static fHCM2__Team_Member__c directReport1;
    private static fHCM2__Team_Member__c directReport2;

    private static List<fHCM2__Team_Member__c> directReports;

    private static Objective__c objective;

    private static void setUpTeamMember() {
        user = TeamMemberTestUtils.createUser('Fry', 'Philip');
        tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(user.Id)
                .build();
    }

    private static void setUpTeamMemberAsViewer() {
        tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setName('Wilma Worm')
                .build();
    }

    private static void setUpObjective() {
        objective = new Objective__c(
            Status__c = ObjectiveUtils.STATUS_ACTIVE,
            Title__c = 'Dont do it',
            Description__c = 'Not worth it',
            Team_Member__c = tm.Id
        );
        insert objective;
    }

    /**
     * Set up the direct reports for the manager.
     */
    private static void setUpDirectReportsForManager() {
         setUpTeamMemberAsViewer();
         directReport1 = new TeamMemberTestUtils.TeamMemberBuilder()
                .setManager(tm.Id)
                .setUser(TeamMemberTestUtils.createUser('Terrence', 'Tenrec').Id)
                .setName('Terrence Tenrec')
                .build();
        directReport2 = new TeamMemberTestUtils.TeamMemberBuilder()
                .setManager(tm.Id)
                .setUser(TeamMemberTestUtils.createUser('Alison', 'Will').Id)
                .setName('Alison Williams')
                .build();

        directReports = new List<fHCM2__Team_Member__c>();
        directReports.add(directReport1);
        directReports.add(directReport2);
    }

    @isTest
    private static void testGetUserEmailAddresses() {

        // GIVEN a Set containing one TM's Id, who has a User with an email address
        setUpTeamMember();
        Set<Id> ids = new Set<Id>{tm.Id};

        // WHEN I retrieve email addresses for all TMs in the Set
        List<String> addresses = TeamMemberUtils.getUserEmailAddresses(ids);

        // THEN I receive a list of one
        System.assertEquals(1, addresses.size());

        // AND it is the correct one
        System.assertEquals(user.Email.toLowerCase(), addresses.get(0).toLowerCase());
    }

    @isTest
    private static void testGetUserEmailAddresses_WhenThereAreNoUsers() {

        // GIVEN a Set containing one TM's Id, who has no User
        tm = new fHCM2__Team_Member__c();
        insert tm;
        Set<Id> ids = new Set<Id>{tm.Id};

        // WHEN I retrieve email addresses for all TMs in the Set
        List<String> addresses = TeamMemberUtils.getUserEmailAddresses(ids);

        // THEN I receive an empty list
        System.assert(addresses.isEmpty());
    }

    @isTest
    private static void testGetViewerPerson() {

        // Given we have a team member associated with an User
        setUpTeamMemberAsViewer();

        // WHEN I retrieve email addresses for all TMs in the Set
        PersonModel model = TeamMemberUtils.getViewerPerson();

        // THEN I receive the model with the viewer id
        System.assertEquals(model.id, tm.Id);
    }

    @isTest
    private static void testCreateTeamMemberSummary(){

        // GIVEN we have a team member object
        setUpDirectReportsForManager();
        // AND they have an objective
        setUpObjective();

        // WHEN create a Team Member Summary for the Team Member object
        List<TeamMemberSummaryModel> teamMemberSummaryModels = TeamMemberUtils.createTeamMemberSummary(directReports);

        // THEN I receive the list of TeamMemberSummaryModel
        System.assertEquals(2, teamMemberSummaryModels.size());
        System.assertNotEquals(null, teamMemberSummaryModels.get(0).teamMember);
        System.assertNotEquals(null,teamMemberSummaryModels.get(0).objectivesSummary);
    }

    @isTest
    private static void testGetPolicyId_UsesDepartmentPolicyByDefault() {

        // GIVEN a TM with a department policy
        fHCM2__Policy__c deptPolicy = new fHCM2__Policy__c();
        insert deptPolicy;
        fHCM2__Department__c dept = new fHCM2__Department__c(
            fHCM2__Policy__c = deptPolicy.Id
        );
        insert dept;
        fHCM2__Team_Member__c tm = new fHCM2__Team_Member__c(
            fHCM2__Department__c = dept.Id
        );
        insert tm;
        tm = TeamMemberRepository.get(tm.Id);

        // WHEN getting the policy ID
        // THEN the department policy ID is returned
        System.assertEquals(deptPolicy.Id, TeamMemberUtils.getPolicyId(tm));
    }

    @isTest
    private static void testGetPolicyId_UsesOverridePolicy() {

        // GIVEN a TM with a department policy and an override policy
        fHCM2__Policy__c tmPolicy = new fHCM2__Policy__c();
        fHCM2__Policy__c deptPolicy = new fHCM2__Policy__c();
        insert new List<fHCM2__Policy__c> { tmPolicy, deptPolicy };
        fHCM2__Department__c dept = new fHCM2__Department__c(
            fHCM2__Policy__c = deptPolicy.Id
        );
        insert dept;
        fHCM2__Team_Member__c tm = new fHCM2__Team_Member__c(
            fHCM2__Policy__c = tmPolicy.Id,
            fHCM2__Department__c = dept.Id
        );
        insert tm;
        tm = TeamMemberRepository.get(tm.Id);

        // WHEN getting the policy ID
        // THEN the override policy ID is returned
        System.assertEquals(tmPolicy.Id, TeamMemberUtils.getPolicyId(tm));
    }

    @isTest
    private static void testGetManagersOf() {

        // GIVEN two direct reports
        setUpDirectReportsForManager();

        // WHEN I ask for their manager(s)
        List<fHCM2__Team_Member__c> managers =
                TeamMemberUtils.getManagersOf(directReports);

        // THEN I get one
        System.assertEquals(1, managers.size());

        // AND it is the correct one
        System.assertEquals(tm.Id, managers[0].Id);
    }
}