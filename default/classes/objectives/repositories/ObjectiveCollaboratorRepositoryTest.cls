@isTest
public class ObjectiveCollaboratorRepositoryTest {

    private static Objective__c objective;
    private static Objective_Collaborator__c junction;
    private static fHCM2__Team_Member__c tm;

    private static void setUp() {
        tm = new TeamMemberTestUtils.TeamMemberBuilder().build();

        objective = new Objective__c(
            Title__c = 'Watch Aquila'
        );
        insert objective;

        junction = new Objective_Collaborator__c(
            Objective__c = objective.Id,
            Team_Member__c = tm.Id,
            Access_Type__c = 'Espionager'
        );
        insert junction;
    }

    @isTest
    private static void testGetForObjective() {

        // GIVEN an objective with a collaborator
        setUp();

        // WHEN I get all junction objects pointing to it
        List<Objective_Collaborator__c> junctions =
                ObjectiveCollaboratorRepository.getForObjective(objective.Id);

        // THEN I get one
        System.assertEquals(1, junctions.size());

        // AND it is the right one
        System.assertEquals(junction.Id, junctions[0].Id);
    }

    @isTest
    private static void testGetForObjectives() {

        // GIVEN an objective with a collaborator
        setUp();

        // WHEN I get all junction objects pointing to it as part of a set
        Set<Id> objectiveIds = new Set<Id>{objective.Id};
        List<Objective_Collaborator__c> junctions =
                ObjectiveCollaboratorRepository.getForObjectives(objectiveIds);

        // THEN I get one
        System.assertEquals(1, junctions.size());

        // AND it is the right one
        System.assertEquals(junction.Id, junctions[0].Id);
    }

    @isTest
    private static void testGetForTeamMember() {

        // GIVEN a TM who is a collaborator on an objective
        setUp();

        // WHEN I get all junction objects linking them to objectives
        List<Objective_Collaborator__c> junctions =
                ObjectiveCollaboratorRepository.getForTeamMember(tm.Id);

        // THEN I get one
        System.assertEquals(1, junctions.size());

        // AND it is the right one
        System.assertEquals(junction.Id, junctions[0].Id);
    }
}