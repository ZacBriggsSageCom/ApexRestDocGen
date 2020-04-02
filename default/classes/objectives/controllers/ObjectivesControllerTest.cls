@isTest
public class ObjectivesControllerTest {

    private static ObjectiveModel objective;
    private static fHCM2__Team_Member__c subject;
    private static fHCM2__Team_Member__c viewer;

    private static void setUpAsSubject(String status) {
        subject = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setName('Ptimothy Pterodactyl')
                .build();
        createAndSaveObjective(status);
    }

    private static void setUpAsManager(String status) {
        viewer = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setName('Lizzy Lizard')
                .build();
        subject = new TeamMemberTestUtils.TeamMemberBuilder()
                .setName('Boris Brachiosaurus')
                .setManager(viewer.Id)
                .build();
        createAndSaveObjective(status);
    }

    private static void setUpAsStranger(String status) {
        viewer = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setName('Charles Chameleon')
                .build();
        subject = new TeamMemberTestUtils.TeamMemberBuilder()
                .setName('Becky Bluejay')
                .build();
        createAndSaveObjective(status);
    }

    private static void createAndSaveObjective(String status) {
        objective = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTeamMember(subject.Id)
                .setTitle('Eat more calories')
                .setDescription('Survive by getting more food')
                .setPriority('Maximal')
                .setStatus(status)
                .save()
                .build();
    }

    //==========================================================================
    // Test Methods
    //==========================================================================

    @isTest
    private static void testGetObjectives_WhenSubject() {

        // GIVEN I have an objective
        setUpAsSubject(ObjectiveUtils.STATUS_DRAFT);

        // WHEN I ask for my objectives
        ObjectiveListResponseModel response =
                ObjectivesController.getObjectives(subject.Id);

        // THEN the status code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND the response does not contain an error
        System.assertEquals(null, response.error);

        // AND 1 Objective is returned
        System.assertEquals(1, response.items.size());

        // AND it has the correct properties
        ObjectiveModel item = response.items.get(0);
        System.assertEquals(objective.id, item.id);
        System.assertEquals(objective.tmId, item.tmId);
        System.assertEquals(objective.title, item.title);
        System.assertEquals(objective.status, item.status);
        System.assertEquals(objective.priority, item.priority);
        System.assertEquals(objective.description, item.description);

        // AND its author is correct
        System.assertEquals(subject.Id, item.creator.id);
        System.assertEquals(subject.Name, item.creator.name);
    }

    @isTest
    private static void testGetObjectives_WhenManager() {

        // GIVEN my direct report has an objective
        setUpAsManager(ObjectiveUtils.STATUS_DRAFT);

        // WHEN I ask for all their objectives
        ObjectiveListResponseModel response =
                ObjectivesController.getObjectives(subject.Id);

        // THEN the status code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND the response does not contain an error
        System.assertEquals(null, response.error);

        // AND 1 Objective is returned
        System.assertEquals(1, response.items.size());
    }

    @isTest
    private static void testGetObjectives_InvalidTeamMemberId() {

        // GIVEN some nonsense string
        String id = 'You could bring a shuttle, but not a rocket';

        // WHEN I try to use it to get objectives
        ObjectiveListResponseModel response = ObjectivesController.getObjectives(id);

        // THEN the status code is BAD_REQUEST
        System.assertEquals(HttpUtils.STATUS_BAD_REQUEST, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Error_Team_Member_Id_Invalid, response.error.error);

        // AND no Objective is returned
        System.assertEquals(null, response.items);
    }

    @isTest
    private static void testGetObjectives_WhenStranger() {

        // GIVEN some objectives relating to a stranger to me
        setUpAsStranger(ObjectiveUtils.STATUS_DRAFT);

        // WHEN I try to view their objectives
        ObjectiveListResponseModel response =
                ObjectivesController.getObjectives(subject.Id);

        // THEN the status code is FORBIDDEN
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Objective_Access_Denied, response.error.error);

        // AND no Objective is returned
        System.assertEquals(null, response.items);
    }

    //==========================================================================
    // Insert Objective Test Methods
    //==========================================================================

    @isTest
    private static void testInsertObjectiveForSelf() {

        // GIVEN I have an objective with 2 Tasks
        ObjectiveModel om = ObjectiveTestUtils.getMockObjective();
        ObjectiveTestUtils.addMockTask(om, '1');
        ObjectiveTestUtils.addMockTask(om, '2');

        // WHEN I try to insert the objective
        EditObjectiveResponseModel orm =
                ObjectivesController.createObjective(om);

        // THEN the status code is OK
        System.assertEquals(HttpUtils.STATUS_OK, orm.getStatusCode());

        // AND the response does not contain an error
        System.assertEquals(null, orm.error);

        // AND my Objective is returned, with an ID
        System.assertNotEquals(null, orm.objective.id);
        System.assertEquals(om.category, orm.objective.category);
        System.assertEquals(om.creator, orm.objective.creator);

        // AND the response contains my Tasks, with IDs, in the correct order
        System.assertEquals(2, orm.objective.tasks.size());
        System.assertNotEquals(null, orm.objective.tasks[0].id);
        System.assertEquals('1', orm.objective.tasks[0].content);
        System.assertEquals(false, orm.objective.tasks[0].complete);
        System.assertNotEquals(null, orm.objective.tasks[1].id);
        System.assertEquals('2', orm.objective.tasks[1].content);
        System.assertEquals(false, orm.objective.tasks[1].complete);
    }

    @isTest
    private static void testInsertObjectiveForDirectReport() {

        // GIVEN a new objective which is for my direct report
        setUpAsManager(ObjectiveUtils.STATUS_DRAFT);
        delete [SELECT Id FROM Objective__c];
        objective.id = null;

        // WHEN I try to insert it
        EditObjectiveResponseModel response =
                ObjectivesController.createObjective(objective);

        // THEN the status code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND the response does not contain an error
        System.assertEquals(null, response.error);
    }

    @isTest
    private static void testInsertObjectiveAsStranger() {

        // GIVEN I have an objective
        ObjectiveModel om = ObjectiveTestUtils.getMockObjective();
        // AND The objective is for a stranger
        fHCM2__Team_Member__c stranger = new TeamMemberTestUtils.TeamMemberBuilder()
                .setName('Wilma Worm')
                .build();

        om.tmId = stranger.Id;

        // WHEN I try to insert the objective, which I have no business doing
        EditObjectiveResponseModel orm =
                ObjectivesController.createObjective(om);

        // THEN the status code is STATUS_FORBIDDEN
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, orm.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Objective_Create_Denied, orm.error.error);
    }

    //==========================================================================
    // Edit Objective Test Methods
    //==========================================================================

    @isTest
    private static void testEditObjectiveForSelf() {

        // GIVEN I have an objective
        setUpAsSubject(ObjectiveUtils.STATUS_DRAFT);
        // And I edit an objective title
        objective.title = 'Eat lots of brownies';
        objective.description = 'Coz it is Christmas';

        // WHEN I try to edit the objective
        EditObjectiveResponseModel orm =
                ObjectivesController.editObjective(objective);

        // THEN I get the objective back with the edited fields
        System.assertEquals(orm.objective.title, objective.title);
        System.assertEquals(orm.objective.description, objective.description);
        System.assertEquals(orm.objective.creator, objective.creator);

        // AND the edits have been persisted
        Objective__c editedObjective = ObjectiveRepository.get(objective.id);
        System.assertEquals('Eat lots of brownies', editedObjective.Title__c);
        System.assertEquals('Coz it is Christmas', editedObjective.Description__c);
    }

    @isTest
    private static void testEditObjectiveForDirectReport() {

        // GIVEN an objective for my direct report
        setUpAsManager(ObjectiveUtils.STATUS_ACTIVE);

        // AND some change to make
        objective.title = 'Rise to vote, sir';

        // WHEN I try to edit it
        EditObjectiveResponseModel response =
                ObjectivesController.editObjective(objective);

        // THEN the status code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND the response does not contain an error
        System.assertEquals(null, response.error);
    }

    @isTest
    private static void testEditObjectiveWhenStranger() {

        // GIVEN an objective which is not mine
        System.runAs(TeamMemberTestUtils.createUser('stranger', 'strange')) {
            setUpAsStranger(ObjectiveUtils.STATUS_DRAFT);
        }

        // WHEN I try to edit the objective, which I have no business doing
        EditObjectiveResponseModel orm =
                ObjectivesController.editObjective(objective);

        // THEN the status code is STATUS_FORBIDDEN
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, orm.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Objective_Edit_Denied, orm.error.error);
    }

    @isTest
    private static void testEditObjectiveWhenStatusNotDraftOrActive() {

        // GIVEN my direct report has an objective
        setUpAsManager(ObjectiveUtils.STATUS_DRAFT);

        // And the objective status is not draft or active
        objective.status = 'Potato';

        // WHEN I try to edit the objective
        EditObjectiveResponseModel orm =
                ObjectivesController.editObjective(objective);

        // THEN the status code is STATUS_BAD_REQUEST
        System.assertEquals(HttpUtils.STATUS_BAD_REQUEST, orm.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Objective_Edit_Invalid_Status, orm.error.error);
    }

    @isTest
    private static void testEditObjectiveWhenObjectiveDoesNotExist() {

        // GIVEN I have an objective which was deleted
        Objective__c obj = new Objective__c(
            Status__c = ObjectiveUtils.STATUS_ACTIVE,
            Title__c = 'Some objective'
        );
        insert obj;
        delete obj;

        ObjectiveModel om = new ObjectiveModel();
        om.id = obj.id;

        // WHEN I try to edit the objective
        EditObjectiveResponseModel orm =
                ObjectivesController.editObjective(om);

        // THEN the status code is NOT_FOUND
        System.assertEquals(HttpUtils.STATUS_NOT_FOUND, orm.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Objective_Does_Not_Exist, orm.error.error);

        // AND I do not receive an Objective
        System.assertEquals(null, orm.objective);
    }

    @isTest
    private static void testEditObjectiveUsingInvalidId() {

        // GIVEN I have an Objective
        setUpAsManager(ObjectiveUtils.STATUS_DRAFT);

        // WHEN I try to edit the objective
        EditObjectiveResponseModel orm =
                ObjectivesController.editObjective(
                        ObjectiveTestUtils.getMockObjective());

        // THEN the status code is BAD_REQUEST
        System.assertEquals(
                HttpUtils.STATUS_BAD_REQUEST, orm.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Objective_Id_Invalid, orm.error.error);

        // AND I do not receive an Objective
        System.assertEquals(null, orm.objective);
    }

    //==========================================================================
    // Delete Objective Test Methods
    //==========================================================================

    @isTest
    private static void testDeleteObjectiveWhenDraftAsOwner() {

        // GIVEN an objective of mine in Draft state
        setUpAsSubject(ObjectiveUtils.STATUS_DRAFT);

        // WHEN I try to delete it
        BaseResponseModel response = ObjectivesController.deleteObjective(objective.id);

        // THEN the response status code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND the response does not contain an error
        System.assertEquals(null, response.error);

        // AND the objective has been deleted
        System.assertEquals(null, ObjectiveRepository.get(objective.id));
    }

    @isTest
    private static void testDeleteObjectiveAsStranger() {

        // GIVEN an objective which is not mine
        System.runAs(TeamMemberTestUtils.createUser('some', 'guy')) {
            setUpAsStranger(ObjectiveUtils.STATUS_DRAFT);
        }

        // WHEN I try to delete it
        BaseResponseModel response = ObjectivesController.deleteObjective(objective.id);

        // THEN the response status code is FORBIDDEN
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Objective_Delete_Denied, response.error.error);
    }

    @isTest
    private static void testDeleteObjectiveWhenActive() {

        // GIVEN an active objective
        setUpAsSubject(ObjectiveUtils.STATUS_DRAFT);
        objective = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTeamMember(subject.Id)
                .setTitle('Eat more calories')
                .setStatus(ObjectiveUtils.STATUS_ACTIVE)
                .save()
                .build();

        // WHEN I try to delete it
        BaseResponseModel response = ObjectivesController.deleteObjective(objective.id);

        // THEN the response status code is FORBIDDEN
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, response.getStatusCode());

        // AND the error message is correct
        String errorMessage = String.format(
                Label.Objective_Status_Not_As_Expected,
                new List<String>{ ObjectiveUtils.STATUS_DRAFT }
        );
        System.assertEquals(errorMessage, response.error.error);
    }

    @isTest
    private static void testDeleteObjectiveUsingInvalidId() {

        // GIVEN an invalid ID for an objective
        String invalidId = 'potato';

        // WHEN I try to delete it
        BaseResponseModel response = ObjectivesController.deleteObjective(invalidId);

        // THEN the response status code is BAD_REQUEST
        System.assertEquals(HttpUtils.STATUS_BAD_REQUEST, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Objective_Id_Invalid, response.error.error);
    }

    @isTest
    private static void testDeleteObjectiveWhichDoesNotExist() {

        // GIVEN an ID for an objective which has been deleted
        setUpAsSubject(ObjectiveUtils.STATUS_DRAFT);
        ObjectiveUtils.deleteObjective(objective.id);

        // WHEN I try to delete it
        BaseResponseModel response = ObjectivesController.deleteObjective(objective.id);

        // THEN the response status code is NOT_FOUND
        System.assertEquals(HttpUtils.STATUS_NOT_FOUND, response.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Objective_Does_Not_Exist, response.error.error);
    }

    //==========================================================================
    // Activate Objective Test Methods
    //==========================================================================

    @isTest
    private static void testActivateObjective() {

        // GIVEN I have an objective
        setUpAsSubject(ObjectiveUtils.STATUS_DRAFT);

        // WHEN I Try to activate the objective
        EditObjectiveResponseModel orm =
                ObjectivesController.activateObjective(objective);

        // THEN I get the objective back activated
        System.assertEquals(ObjectiveUtils.STATUS_ACTIVE, orm.objective.status);

    }

    @isTest
    private static void testRetrieveActivatedObjective() {

        // GIVEN I have an objective
        setUpAsSubject(ObjectiveUtils.STATUS_ACTIVE);

        // AND the objective is active
        objective.status = ObjectiveUtils.STATUS_ACTIVE;
        ObjectiveUtils.updateObjective(objective);

        // WHEN I Try to retrieve the activated objective
        Objective__c editedObjective = ObjectiveRepository.get(objective.id);

        // I get the objective back and it has been activated
        System.assertEquals(ObjectiveUtils.STATUS_ACTIVE, editedObjective.Status__c);
    }

    @isTest
    private static void testActivateActiveObjective() {

        // GIVEN I have an active objective
        setUpAsSubject(ObjectiveUtils.STATUS_ACTIVE);

        // WHEN I Try to activate the objective
        EditObjectiveResponseModel orm =
                ObjectivesController.activateObjective(objective);

        // I get the correct error code
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, orm.getStatusCode());
    }

    //==========================================================================
    // Close Objective Test Methods
    //==========================================================================

    @isTest
    private static void testCloseObjectiveForSelf() {

        // GIVEN I have an objective
        setUpAsSubject(ObjectiveUtils.STATUS_ACTIVE);

        // WHEN I try to close the objective
        EditObjectiveResponseModel orm =
                ObjectivesController.closeObjective(objective.id);

        // THEN I get the objective back with status as closed
        System.assertEquals(orm.objective.title, objective.title);
        System.assertEquals(orm.objective.description, objective.description);
        System.assertEquals(orm.objective.status, ObjectiveUtils.STATUS_CLOSED);

        // AND I try to retrieve the closed objective
        Objective__c closedObjective = ObjectiveRepository.get(objective.id);
        // AND I get the objective back with status as closed
        System.assertEquals(ObjectiveUtils.STATUS_CLOSED, closedObjective.Status__c);
    }

    @isTest
    private static void testCloseObjectiveForDirectReport() {

        // GIVEN an active objective for my direct report
        setUpAsManager(ObjectiveUtils.STATUS_ACTIVE);

        // WHEN I try to close it
        EditObjectiveResponseModel response =
                ObjectivesController.closeObjective(objective.id);

        // THEN the status code is OK
        System.assertEquals(HttpUtils.STATUS_OK, response.getStatusCode());

        // AND the response does not contain an error
        System.assertEquals(null, response.error);
    }

    @isTest
    private static void testCloseObjectiveWhenStranger() {

        // GIVEN an objective which is not mine
        System.runAs(TeamMemberTestUtils.createUser('stranger', 'strange')) {
            setUpAsStranger(ObjectiveUtils.STATUS_ACTIVE);
        }

        // WHEN I try to close the objective, which I have no business doing
        EditObjectiveResponseModel orm =
                ObjectivesController.closeObjective(objective.id);

        // THEN the status code is STATUS_FORBIDDEN
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, orm.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Objective_Close_Denied, orm.error.error);
    }

    @isTest
    private static void testCloseObjectiveWhenStatusNotActive() {

        // GIVEN my direct report has an objective and its status is not active
        setUpAsManager(ObjectiveUtils.STATUS_DRAFT);

        // WHEN I try to close the objective
        EditObjectiveResponseModel orm =
                ObjectivesController.closeObjective(objective.id);

        // THEN the status code is STATUS_FORBIDDEN
        System.assertEquals(HttpUtils.STATUS_FORBIDDEN, orm.getStatusCode());

        // AND the error message is correct
        String errorMessage = String.format(
                Label.Objective_Status_Not_As_Expected,
                new List<String>{ ObjectiveUtils.STATUS_ACTIVE }
        );
        System.assertEquals(errorMessage, orm.error.error);
    }

    @isTest
    private static void testCloseObjectiveWhenObjectiveDoesNotExist() {

        // GIVEN I have an objective which was deleted
        Objective__c obj = new Objective__c(
            Status__c = ObjectiveUtils.STATUS_ACTIVE,
            Title__c = 'Some objective'
        );
        insert obj;
        delete obj;

        ObjectiveModel om = new ObjectiveModel();
        om.id = obj.id;

        // WHEN I try to close the objective
        EditObjectiveResponseModel orm =
                ObjectivesController.closeObjective(obj.id);

        // THEN the status code is NOT_FOUND
        System.assertEquals(HttpUtils.STATUS_NOT_FOUND, orm.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Objective_Does_Not_Exist, orm.error.error);

        // AND I do not receive an Objective
        System.assertEquals(null, orm.objective);
    }

    @isTest
    private static void testCloseObjectiveUsingInvalidId() {

        // GIVEN I have an invalid Objective Id
        String invalidObjId = 'invalid';

        // WHEN I try to close the objective
        EditObjectiveResponseModel orm =
                ObjectivesController.closeObjective(invalidObjId);

        // THEN the status code is BAD_REQUEST
        System.assertEquals(
                HttpUtils.STATUS_BAD_REQUEST, orm.getStatusCode());

        // AND the error message is correct
        System.assertEquals(Label.Objective_Id_Invalid, orm.error.error);

        // AND I do not receive an Objective
        System.assertEquals(null, orm.objective);
    }
}