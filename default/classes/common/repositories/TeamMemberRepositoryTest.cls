/**
 * Tests exercising methods for dealing with Team Member objects.
 */
@isTest
public class TeamMemberRepositoryTest {

    private static fHCM2__Team_Member__c manager;
    private static fHCM2__Team_Member__c directReport1;
    private static fHCM2__Team_Member__c directReport2;

    private static User managerUser;

    private static void setUpManager() {
        managerUser = TeamMemberTestUtils.createUser('Joy', 'Roy');
        manager = new fHCM2__Team_Member__c(
                fHCM2__User__c = managerUser.Id
            );
        insert manager;
    }

    /**
     * Set up the direct reports for the manager.
     */
    private static void setUpDirectReportsForManager() {
        setUpManager();
        directReport1 = new TeamMemberTestUtils.TeamMemberBuilder()
                .setManager(manager.Id)
                .setUser(TeamMemberTestUtils.createUser('Terrence', 'Tenrec').Id)
                .setName('Terrence Tenrec')
                .build();
        directReport2 = new TeamMemberTestUtils.TeamMemberBuilder()
                .setManager(manager.Id)
                .setUser(TeamMemberTestUtils.createUser('Alison', 'Will').Id)
                .setName('Alison Williams')
                .build();
    }

    @isTest
    private static void testGetDirectReports() {

        setUpDirectReportsForManager();

        List<fHCM2__Team_Member__c> drs = TeamMemberRepository.getDirectReports(manager.Id);

        System.assertNotEquals(null, drs);
        System.assertEquals(2, drs.size());
    }

    @isTest
    private static void testGetTeamMemberForUser() {
        setUpManager();
        fHCM2__Team_Member__c tm = TeamMemberRepository.getTeamMemberForUser(managerUser.Id);

        System.assertNotEquals(null, tm);
        System.assertEquals(manager.Id, tm.Id);
    }

    @isTest
    private static void testGetTeamMemberForUser_NoUser() {
        managerUser = TeamMemberTestUtils.createUser('Joy', 'Roy');
        fHCM2__Team_Member__c tm = TeamMemberRepository.getTeamMemberForUser(managerUser.Id);

        System.assertEquals(null, tm);
    }

    @isTest
    private static void testGet() {
        setUpManager();
        fHCM2__Team_Member__c tm = TeamMemberRepository.get(manager.Id);
        System.assertNotEquals(null, tm);
        System.assertEquals(manager.Id, tm.Id);
    }

    @isTest
    private static void testGetList() {
        setUpDirectReportsForManager();

        Set<Id> tmIds = new Set<Id>();
        tmIds.add(directReport1.Id);
        tmIds.add(directReport2.Id);

        List<fHCM2__Team_Member__c> tms = TeamMemberRepository.get(tmIds);

        System.assertNotEquals(null, tms);
        System.assertEquals(2, tms.size());
    }

    @IsTest
    private static void testGetTeamMemberWithNameLike() {

        // GIVEN some direct reports
        directReport1 = new TeamMemberTestUtils.TeamMemberBuilder()
                .setName('Terrence Tenrec')
                .build();
        directReport2 = new TeamMemberTestUtils.TeamMemberBuilder()
                .setName('Alison Williams')
                .build();

        // WHEN we search for some parts of their names
        List<List<fHCM2__Team_Member__c>> searches = new List<List<fHCM2__Team_Member__c>>();
        searches.add(TeamMemberRepository.searchByName('Ter'));
        searches.add(TeamMemberRepository.searchByName('rec'));
        searches.add(TeamMemberRepository.searchByName('Al'));
        searches.add(TeamMemberRepository.searchByName('Wil'));

        // THEN we get back the  correct team members, and not the other team member
        System.assertEquals(directReport1.Name, searches[0][0].Name);
        System.assertNotEquals(directReport2.Name, searches[0][0].Name);
        System.assert(searches[0].size() == 1);

        System.assertEquals( directReport1.Name, searches[1][0].Name);
        System.assertNotEquals(directReport2.Name, searches[1][0].Name);
        System.assert(searches[1].size() == 1);

        System.assertEquals( directReport2.Name, searches[2][0].Name);
        System.assertNotEquals( directReport1.Name, searches[2][0].Name);
        System.assert(searches[2].size() == 1);

        System.assertEquals(directReport2.Name, searches[3][0].Name);
        System.assertNotEquals( directReport1.Name, searches[3][0].Name);
        System.assert(searches[3].size() == 1);
    }
}