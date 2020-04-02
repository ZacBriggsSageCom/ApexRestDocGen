@isTest
public class ObjectiveCollaboratorModelBuilderTest {

    private static Objective__c objective;
    private static Objective_Collaborator__c junction;
    private static Objective_Collaborator__c junction2;
    private static fHCM2__Team_Member__c tm;
    private static fHCM2__Team_Member__c tm2;
    private static fHCM2__Policy__c pol;

    private static void setUp() {
        pol = new fHCM2__Policy__c();
        insert pol;

        tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .build();
        tm2 = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .build();

        objective = new Objective__c(Title__c = 'Watch Aquila');
        insert objective;

        junction = new Objective_Collaborator__c(
            Objective__c = objective.Id,
            Team_Member__c = tm.Id,
            Access_Type__c = 'Espionager'
        );
        insert junction;
        junction2 = new Objective_Collaborator__c(
            Objective__c = objective.Id,
            Team_Member__c = tm2.Id,
            Access_Type__c = 'Legitimate'
        );
        insert junction2;
    }

    @isTest
    private static void testBuildMany() {

        // GIVEN two junction objects and two TMs
        setUp();

        // WHEN I get a list of collaborators for my junctions
        List<ObjectiveCollaboratorModel> collaborators =
                ObjectiveCollaboratorModelBuilder.build(
                        new List<Objective_Collaborator__c>{junction, junction2});

        // THEN I get two
        System.assertEquals(2, collaborators.size());

        // AND they are matched correctly
        System.assertEquals(tm.Id, collaborators[0].person.id);
        System.assertEquals('Espionager', collaborators[0].accessType);

        System.assertEquals(tm2.Id, collaborators[1].person.id);
        System.assertEquals('Legitimate', collaborators[1].accessType);
    }

    @isTest
    private static void testBuildManyWhenSupplyingTms() {

        // GIVEN two junction objects and two TMs
        setUp();

        // WHEN I combine them into a list of collaborators
        List<ObjectiveCollaboratorModel> collaborators =
                ObjectiveCollaboratorModelBuilder.build(
                        new List<Objective_Collaborator__c>{junction, junction2},
                        new List<fHCM2__Team_Member__c>{tm, tm2});

        // THEN I get two
        System.assertEquals(2, collaborators.size());

        // AND they are matched correctly
        System.assertEquals(tm.Id, collaborators[0].person.id);
        System.assertEquals('Espionager', collaborators[0].accessType);

        System.assertEquals(tm2.Id, collaborators[1].person.id);
        System.assertEquals('Legitimate', collaborators[1].accessType);
    }

    @isTest
    private static void testBuildSingle() {

        // GIVEN an objective and a TM
        setUp();

        // WHEN I build a collaborator from them with some access type
        ObjectiveCollaboratorModel model =
                ObjectiveCollaboratorModelBuilder.build(objective.Id, 'Owner', tm);

        // THEN it has the correct fields
        System.assertEquals('Owner', model.accessType);
        System.assertEquals(objective.Id, model.objectiveId);
        System.assertEquals(tm.Id, model.person.id);
    }
}