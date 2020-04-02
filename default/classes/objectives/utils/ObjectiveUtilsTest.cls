/**
 * Tests exercising objective utilities.
 */
@isTest
public class ObjectiveUtilsTest {

    private static ObjectiveModel objective;
    private static Objective__c record;
    private static ConversationModel conversation;
    private static fHCM2__Team_Member__c subject;
    private static fHCM2__Team_Member__c viewer;
    private static fHCM2__Policy__c policy;

    private static void createObjectiveConversation() {
        createPolicy();
        subject = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setName('Colin Condor')
                .setPolicy(policy.Id)
                .build();
        objective = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTitle('Soar 10% higher')
                .setTeamMember(subject.Id)
                .save()
                .build();
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .addParticipant(subject)
                .setSubject(objective.id)
                .save()
                .build();
    }

    private static void createPolicy() {
        policy = new fHCM2__Policy__c(Allow_Edit_Feedback__c = true);
        insert policy;
    }

    //==========================================================================
    // Test Methods
    //==========================================================================

    @isTest
    private static void testGetVisibleObjectives() {

        // GIVEN an objective which I made
        subject = new TeamMemberTestUtils.TeamMemberBuilder().build();
        viewer = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .build();
        objective = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTitle('Some garbage')
                .setTeamMember(subject.Id)
                .save()
                .build();

        // WHEN I get all visible objectives
        List<ObjectiveModel> objectives = ObjectiveUtils.getVisibleObjectives(subject.Id);

        // THEN I get the one I made
        System.assertEquals(1, objectives.size());
        System.assertEquals(objective.id, objectives.get(0).id);
    }

    @isTest
    private static void testUpdateObjectiveAndActivate() {

        // GIVEN an objective
        createObjectiveConversation();

        // WHEN I update and activate it
        ObjectiveUtils.updateObjectiveAndActivate(objective);

        // THEN the change is persisted
        Objective__c record = ObjectiveRepository.get(objective.id);
        System.assertEquals(ObjectiveUtils.STATUS_ACTIVE, record.Status__c);

        // AND an event has been saved
        Feed_Event__c event = FeedEventRepository.getBySubjects(new Set<Id>{record.Id})[0];
        System.assertEquals(FeedEventTypes.OBJECTIVE_ACTIVATED, event.Type__c);
        System.assertEquals(record.Id, event.Subject__c);
    }

    @isTest
    private static void testIsVisibleToMe_WhenStatusIsNotDraft() {

        // GIVEN an objective which is active
        record = new Objective__c(
            Status__c = ObjectiveUtils.STATUS_ACTIVE,
            Title__c = 'Some garbage'
        );
        insert record;

        // WHEN I determine whether I can see it, THEN I find I can
        System.assert(ObjectiveUtils.isVisibleToMe(record, UserInfo.getUserId()));
    }

    @isTest
    private static void testIsVisibleToMe_WhenStatusIsDraftAndIAmAuthor() {

        // GIVEN an objective which is in draft state, and which I made
        record = new Objective__c(
            Status__c = ObjectiveUtils.STATUS_DRAFT,
            Title__c = 'Some garbage'
        );
        insert record;
        Objective__c savedRecord = ObjectiveRepository.get(record.Id);

        // WHEN I determine whether I can see it, THEN I find I can
        System.assert(ObjectiveUtils.isVisibleToMe(savedRecord, UserInfo.getUserId()));
    }

    @isTest
    private static void testIsVisibleToMe_WhenStatusIsDraftAndIAmNotAuthor() {

        // GIVEN an objective which is in draft state, and which someone else made
        record = new Objective__c(
            Status__c = ObjectiveUtils.STATUS_DRAFT,
            Title__c = 'Some garbage'
        );
        insert record;
        Objective__c savedRecord = ObjectiveRepository.get(record.Id);

        // WHEN I determine whether I can see it, THEN I find I cannot
        System.assert(!ObjectiveUtils.isVisibleToMe(savedRecord, null));
    }

    @isTest
    private static void testDeleteObjective() {

        // GIVEN an objective
        record = new Objective__c(
            Status__c = ObjectiveUtils.STATUS_DRAFT,
            Title__c = 'Some garbage'
        );
        insert record;

        // WHEN I try to delete it
        ObjectiveUtils.deleteObjective(record.Id);

        // THEN it no longer exists
        System.assertEquals(null, ObjectiveRepository.get(record.Id));
    }

    @isTest
    private static void testCreateObjectiveAsSubject() {

        // GIVEN an objective
        objective = ObjectiveTestUtils.getMockObjective();
        record = ObjectiveUtils.createObjective(objective);

        // WHEN I represent it as a subject of something
        SubjectModel subject = ObjectiveUtils.createObjectiveAsSubject(record.Id);

        // THEN it contains the correct details
        System.assertEquals(record.Id, subject.id);
        System.assertEquals(record.Title__c, subject.name);
        System.assertEquals(record.Team_Member__c, subject.tmId);
    }

    @isTest
    private static void testGetConversationId() {

        // GIVEN an objective about which there is a conversation
        createObjectiveConversation();

        // WHEN I get the conversation ID, THEN it is correct
        System.assertEquals(
                conversation.id, ObjectiveUtils.getConversationId(objective.id));
    }

    @isTest
    private static void testGetConversationIds() {

        // GIVEN an objective about which there is a conversation
        createObjectiveConversation();

        // AND a set of IDs containing just its one
        Set<Id> objectiveIds = new Set<Id>{objective.id};

        // WHEN I get the conversation IDs for all objectives in the set
        Map<Id, Id> conversationsByObjectives =
                ObjectiveUtils.getConversationIds(objectiveIds);

        // THEN I get one
        System.assertEquals(1, conversationsByObjectives.size());

        // AND it is the correct one
        System.assertEquals(
                conversation.id, conversationsByObjectives.get(objective.id));
    }

    @isTest
    private static void testDeleteMissingTasks() {

        // GIVEN some Tasks exist
        Objective__c objective = new Objective__c(
            Title__c = 'Learn JavaScript'
        );
        insert objective;
        List<Task__c> tasks = new List<Task__c> {
            new Task__c(
                Content__c = 'Task1',
                Order__c = 0,
                Objective__c = objective.Id),
            new Task__c(
                Content__c = 'Task2',
                Order__c = 1,
                Objective__c = objective.Id),
            new Task__c(
                Content__c = 'Task3',
                Order__c = 2,
                Objective__c = objective.Id)
        };
        insert tasks;

        // WHEN I try to delete missing Tasks, providing some of them
        List<TaskModel> taskModels = TaskModelBuilder.buildTasks(
                new List<Task__c> { tasks[0], tasks[2] });
        ObjectiveUtils.deleteMissingTasks(objective.Id, taskModels);

        // THEN the Tasks whose IDs were not provided, are deleted
        tasks = [
            SELECT Id,
                Objective__c,
                Content__c
            FROM Task__c
            WHERE Objective__c = :objective.Id
            ORDER BY Order__c
        ];
        System.assertEquals(2, tasks.size());
        System.assertEquals('Task1', tasks[0].Content__c);
        System.assertEquals('Task3', tasks[1].Content__c);
    }

    @isTest
    private static void testCloseObjective() {

        // GIVEN an objective
        subject = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .build();
        record = new Objective__c(
            Status__c = ObjectiveUtils.STATUS_ACTIVE,
            Title__c = 'Dont do it',
            Description__c = 'Not worth it',
            Team_Member__c = subject.Id
        );
        insert record;

        // WHEN I close the objective
        ObjectiveUtils.closeObjective(record.id);
        Objective__c closedObjective = ObjectiveRepository.get(record.Id);

        // THEN it has status as closed
        System.assertNotEquals(null, closedObjective);
        System.assertEquals(ObjectiveUtils.STATUS_CLOSED, closedObjective.Status__c);

        // AND an event has been saved
        Feed_Event__c event = FeedEventRepository.getBySubjects(new Set<Id>{record.Id})[0];
        System.assertEquals(FeedEventTypes.OBJECTIVE_CLOSED, event.Type__c);
        System.assertEquals(record.Id, event.Subject__c);
    }

    @isTest
    private static void testBuildAndUpsertTasks() {

        // GIVEN an Objective
        subject = new TeamMemberTestUtils.TeamMemberBuilder()
                .setName('Eddie Summers')
                .setUser(UserInfo.getUserId())
                .build();
        objective = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTeamMember(subject.Id)
                .setTitle('Learn JavaScript')
                .save()
                .build();

        // AND a list of TaskModels
        List<TaskModel> taskModels = new List<TaskModel> {
            ObjectiveTestUtils.createTaskModel('task1', false),
            ObjectiveTestUtils.createTaskModel('task2', false),
            ObjectiveTestUtils.createTaskModel('task3', false)
        };

        // WHEN building and upserting these Tasks
        List<Task__c> tasks = ObjectiveUtils.buildAndUpsertTasks(
                objective.Id, taskModels);

        // THEN they are added to the database and returned
        System.assertEquals(3, tasks.size());
        System.assertNotEquals(null, tasks[0].Id);
        System.assertNotEquals(null, tasks[1].Id);
        System.assertNotEquals(null, tasks[2].Id);
        System.assertEquals('task1', tasks[0].Content__c);
        System.assertEquals('task2', tasks[1].Content__c);
        System.assertEquals('task3', tasks[2].Content__c);
    }

    @isTest
    private static void testGetSubjects() {

        // GIVEN a list of one objective
        subject = new TeamMemberTestUtils.TeamMemberBuilder().build();
        record = new Objective__c(
            Team_Member__c = subject.Id,
            Title__c = 'Some garbage'
        );
        insert record;
        List<Objective__c> objectives = new List<Objective__c>{record};

        // WHEN I get subjects for all objectives in the list
        List<fHCM2__Team_Member__c> subjects = ObjectiveUtils.getSubjects(objectives);

        // THEN I get one
        System.assertEquals(1, subjects.size());

        // AND it is the right one
        System.assertEquals(subject.Id, subjects[0].Id);
    }

    @isTest
    private static void testGetSubjectsDoesNotDuplicate() {

        // GIVEN a list of two objectives which share a subject
        subject = new TeamMemberTestUtils.TeamMemberBuilder().build();
        record = new Objective__c(
            Team_Member__c = subject.Id,
            Title__c = 'Some garbage'
        );
        Objective__c record2 = new Objective__c(
            Team_Member__c = subject.Id,
            Title__c = 'Even more garbage'
        );
        List<Objective__c> objectives = new List<Objective__c>{record, record2};
        insert objectives;

        // WHEN I get subjects for all objectives in the list
        List<fHCM2__Team_Member__c> subjects = ObjectiveUtils.getSubjects(objectives);

        // THEN I get only one
        System.assertEquals(1, subjects.size());

        // AND it is the right one
        System.assertEquals(subject.Id, subjects[0].Id);
    }
}