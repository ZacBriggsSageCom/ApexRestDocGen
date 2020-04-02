@isTest
public class ObjectiveCollaboratorUtilsTest {

    private static Objective__c objective1;
    private static Objective__c objective2;
    private static Objective_Collaborator__c junction;
    private static Objective_Collaborator__c junction2;
    private static fHCM2__Team_Member__c subject1;
    private static fHCM2__Team_Member__c subject2;
    private static fHCM2__Team_Member__c manager1;
    private static fHCM2__Team_Member__c manager2;
    private static fHCM2__Team_Member__c collaborator1;
    private static fHCM2__Team_Member__c collaborator2;
    private static fHCM2__Policy__c pol;

    private static void setUp() {
        pol = new fHCM2__Policy__c();
        insert pol;

        manager1 = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .build();
        manager2 = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .build();
        subject1 = new TeamMemberTestUtils.TeamMemberBuilder()
                .setManager(manager1.id)
                .setPolicy(pol.Id)
                .build();
        subject2 = new TeamMemberTestUtils.TeamMemberBuilder()
                .setManager(manager2.id)
                .setPolicy(pol.Id)
                .build();
        collaborator1 = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .build();
        collaborator2 = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .build();

        objective1 = new Objective__c(
            Team_Member__c = subject1.Id,
            Title__c = 'Watch Aquila'
        );
        insert objective1;

        objective2 = new Objective__c(
            Team_Member__c = subject2.Id,
            Title__c = 'Learn Russian'
        );
        insert objective2;

        junction = new Objective_Collaborator__c(
            Objective__c = objective1.Id,
            Team_Member__c = collaborator1.Id,
            Access_Type__c = 'Child'
        );
        insert junction;
        junction2 = new Objective_Collaborator__c(
            Objective__c = objective2.Id,
            Team_Member__c = collaborator2.Id,
            Access_Type__c = 'Spy'
        );
        insert junction2;
    }


    @isTest
    private static void testGetCollaboratorsForSingleObjective() {

        // GIVEN an objective with one collaborator
        setUp();

        // WHEN I build its collaborators
        List<ObjectiveCollaboratorModel> collaborators =
                ObjectiveCollaboratorUtils.getCollaboratorsFor(objective1);

        // THEN I get three
        System.assertEquals(3, collaborators.size());

        // AND they have the correct IDs - subject, manager and collaborator
        System.assertEquals(subject1.Id, collaborators[0].person.id);
        System.assertEquals(manager1.Id, collaborators[1].person.id);
        System.assertEquals(collaborator1.Id, collaborators[2].person.id);
    }

    @isTest
    private static void testGetCollaboratorsForManyObjectives() {

        // GIVEN two objectives, each with one collaborator
        setUp();

        // WHEN I build their collaborators
        Test.startTest();
        List<Objective__c> objectives = new List<Objective__c>{objective1, objective2};
        Map<Id, List<ObjectiveCollaboratorModel>> collaborators =
                ObjectiveCollaboratorUtils.getCollaboratorsFor(objectives);

        // THEN I get the correct three collaborators for each
        System.assertEquals(2, collaborators.size());
        System.assertEquals(3, collaborators.get(objective1.Id).size());
        System.assertEquals(subject1.Id, collaborators.get(objective1.Id)[0].person.id);
        System.assertEquals(manager1.Id, collaborators.get(objective1.Id)[1].person.id);
        System.assertEquals(collaborator1.Id, collaborators.get(objective1.Id)[2].person.id);

        System.assertEquals(3, collaborators.get(objective2.Id).size());
        System.assertEquals(subject2.Id, collaborators.get(objective2.Id)[0].person.id);
        System.assertEquals(manager2.Id, collaborators.get(objective2.Id)[1].person.id);
        System.assertEquals(collaborator2.Id, collaborators.get(objective2.Id)[2].person.id);

        // AND we have used a fixed number of queries
        System.assertEquals(4, Limits.getQueries());
        Test.stopTest();
    }
}