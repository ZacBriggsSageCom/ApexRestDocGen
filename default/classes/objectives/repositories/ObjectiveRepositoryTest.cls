@isTest
public class ObjectiveRepositoryTest {

    private static fHCM2__Team_Member__c tm;
    private static ObjectiveModel objective;

    private static void setUp() {
        tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .build();
        objective = new ObjectiveTestUtils.ObjectiveBuilder()
                .setPriority('High')
                .setTitle('An Objective!')
                .setDescription('This is something I should do.')
                .setTeamMember(tm.Id)
                .setStatus('Active')
                .save()
                .build();
    }

    @isTest
    private static void testGetSingle() {

        // GIVEN an objective
        setUp();

        // WHEN I retrieve its properties
        Objective__c retrievedObjective = ObjectiveRepository.get(objective.id);

        // THEN I get the same information back
        System.assertEquals(objective.id, retrievedObjective.Id);
        System.assertEquals(objective.title, retrievedObjective.Title__c);
    }

    @isTest
    private static void testGetMany() {

        // GIVEN an objective
        setUp();

        // WHEN I retrieve its properties, with it as part of a set
        List<Objective__c> retrievedObjectives =
                ObjectiveRepository.get(new Set<Id>{objective.id});

        // THEN I get one result
        System.assertEquals(1, retrievedObjectives.size());

        // AND I get the same information back
        System.assertEquals(objective.id, retrievedObjectives[0].Id);
        System.assertEquals(objective.title, retrievedObjectives[0].Title__c);
    }

    @isTest
    private static void testGetForTeamMember() {

        // GIVEN an objective is related to a team member
        setUp();

        // WHEN I ask for all of the team member's objectives
        List<Objective__c> objectives = ObjectiveRepository.getForTeamMember(tm.Id);

        // THEN I get the right one
        System.assertEquals(1, objectives.size());
        System.assertEquals(objective.id, objectives.get(0).Id);
    }

    @isTest
    private static void testGetActiveObjectivesForTeamMembers(){

        // GIVEN an active objective is related to a team member
        setUp();
        Set<Id> id = new Set<Id>();
        id.add(tm.Id);

        // WHEN I try to retrieve the active objectives for the team member
        Objective__c activeObjective = ObjectiveRepository.getActiveForTeamMembers(id)[0];

        // THEN I get the objective as expected
        System.assertEquals(objective.id, activeObjective.Id);
    }
}