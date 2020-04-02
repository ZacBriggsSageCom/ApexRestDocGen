/**
 * Tests covering remote actions for the Performance app. As the remote actions
 * are just wrappers for the controller methods, the underlying logic is tested
 * by the controller tests.
 */
@isTest
public class PerformanceRemotingTest {

    private static fHCM2__Team_Member__c subject;
    private static FeedItemModel feedback;
    private static ConversationModel conversation;
    private static ObjectiveModel objective;

    /**
     * Set up the data in stub form.
     */
    private static void setUp() {
        fHCM2__Policy__c pol = new fHCM2__Policy__c(Allow_Edit_Feedback__c = true);
        insert pol;

        subject = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setPolicy(pol.Id)
                .build();

        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(subject.Id)
                .addParticipant(subject)
                .save()
                .build();

        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setConversation(conversation.id)
                .setAuthor(subject.Id)
                .save()
                .build();
    }

    private static void setUpObjective(String status) {
        objective = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTeamMember(subject.Id)
                .setTitle('Title')
                .setStatus(status)
                .save()
                .build();
    }

    //==========================================================================
    // Team
    //==========================================================================

    @isTest
    private static void testGetTeam() {
        // WHEN I request the list of subjects
        // THEN the response is not null
        System.assertNotEquals(null, PerformanceRemoting.getTeam());
    }

    //==========================================================================
    // Conversation
    //==========================================================================

    @isTest
    private static void testGetConversation() {
        // GIVEN a Conversation
        setUp();

        // WHEN I ask for it, THEN the response is not null
        System.assertNotEquals(null, PerformanceRemoting.getConversation(conversation.id));
    }

    @isTest
    private static void testGetConversationBySubject() {
        // GIVEN a Conversation
        setUp();

        // WHEN I ask for it by subject, THEN the response is not null
        System.assertNotEquals(null, PerformanceRemoting.getConversationBySubject(subject.id));
    }

    @isTest
    private static void testInsertConversation() {
        // GIVEN a Conversation to save
        setUp();
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(subject.Id)
                .addParticipant(subject)
                .build();

        // WHEN I save it, THEN the response is not null
        System.assertNotEquals(null, PerformanceRemoting.insertConversation(conversation));
    }

    //==========================================================================
    // Comments
    //==========================================================================

    @isTest
    private static void testGetCommentVersions() {
        // GIVEN some Feedback
        setUp();

        // WHEN I ask for all Feedback versions, THEN the response is not null
        System.assertNotEquals(null, PerformanceRemoting.getCommentVersions(feedback.id));
    }

    @isTest
    private static void testInsertComment() {
        // GIVEN some Feedback
        setUp();

        // WHEN I insert it, THEN the response is not null
        System.assertNotEquals(null, PerformanceRemoting.insertComment(feedback));
    }

    @isTest
    private static void testUpdateComment() {
        // GIVEN some Feedback
        setUp();

        // WHEN I update it, THEN the response is not null
        System.assertNotEquals(null, PerformanceRemoting.updateComment(feedback));
    }

    //==========================================================================
    // Objectives
    //==========================================================================

    @isTest
    private static void testGetObjectives() {
        // GIVEN a team member
        setUp();
        setUpObjective(ObjectiveUtils.STATUS_DRAFT);

        // WHEN I ask for all their objectives, THEN the response is not null
        System.assertNotEquals(null, PerformanceRemoting.getObjectives(subject.Id));
    }

    @isTest
    public static void testInsertObjective() {
        // GIVEN an objective model
        ObjectiveModel om = ObjectiveTestUtils.getMockObjective();

        // WHEN I ask to insert it, THEN I get some response
        System.assertNotEquals(null, PerformanceRemoting.insertObjective(om));
    }

    @isTest
    public static void testDeleteObjective() {
        // GIVEN an objective
        setUp();
        setUpObjective(ObjectiveUtils.STATUS_DRAFT);

        // WHEN I ask to delete it, THEN I get some response
        System.assertNotEquals(null, PerformanceRemoting.deleteObjective(objective.id));
    }

    @isTest
    public static void testEditObjective() {
        // GIVEN an objective
        setUp();
        setUpObjective(ObjectiveUtils.STATUS_DRAFT);

        // WHEN I ask to delete it, THEN I get some response
        System.assertNotEquals(null, PerformanceRemoting.editObjective(objective));
    }

    @isTest
    public static void testActivateObjective() {
        // GIVEN an objective
        setUp();
        setUpObjective(ObjectiveUtils.STATUS_DRAFT);

        // AND the edited model of the objective for same id
        ObjectiveModel om = ObjectiveTestUtils.getMockObjective();
        om.id = objective.id;
        om.title = 'Edited Objective';

        // WHEN I ask to activate it
        EditObjectiveResponseModel model =
                ObjectivesController.activateObjective(om);

        // THEN I get some response
        System.assertEquals(model.objective.id, om.id);
        System.assertEquals(model.objective.title, om.title);
        System.assertEquals(model.objective.status, ObjectiveUtils.STATUS_ACTIVE);
    }

    @isTest
    public static void testCloseObjective() {
        // GIVEN an objective
        setUp();
        setUpObjective(ObjectiveUtils.STATUS_ACTIVE);

        // WHEN I ask to close it
        EditObjectiveResponseModel model =
                      PerformanceRemoting.closeObjective(objective.id);

        //THEN I get some response
        System.assertNotEquals(null, model);
        System.assertEquals(null, model.error);
        System.assertEquals(model.objective.id, objective.id);
        System.assertEquals(model.objective.status, ObjectiveUtils.STATUS_CLOSED);
    }

    //==========================================================================
    // Performance
    //==========================================================================

    @isTest
    private static void testGetGlobalConfig() {
        setUp(); // need to be logged in
        System.assertNotEquals(null, PerformanceRemoting.getGlobalConfig());
    }

    @isTest
    private static void testGetWhoAmI() {
        System.assertNotEquals(null, PerformanceRemoting.getViewerContext());
    }

    @isTest
    private static void testGetManagerDashboard() {
        System.assertNotEquals(null, PerformanceRemoting.getManagerDashboard());
    }

    //==========================================================================
    // Process Details
    //==========================================================================

    @isTest
    private static void testGetPerformanceOverviewDetails() {
        // GIVEN some Team Member Id
        setUp();

        // WHEN I ask for details of their Performance Overview processes,
        // THEN the response is not null
        System.assertNotEquals(
                null, PerformanceRemoting.getPerformanceOverviewDetails(subject.Id));
    }

}