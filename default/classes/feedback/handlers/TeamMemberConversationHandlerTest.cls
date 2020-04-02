@isTest
public class TeamMemberConversationHandlerTest {

    private static ConversationHandler handler;
    private static ConversationModel conversation;
    private static FeedItemModel feedback;
    private static fHCM2__Team_Member__c tm;

    private static void setUp() {
        fHCM2__Policy__c pol = new fHCM2__Policy__c();
        insert pol;

        tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setName('Deepti')
                .setPolicy(pol.Id)
                .setUser(UserInfo.getUserId())
                .build();

        conversation = new FeedbackTestUtils.ConversationBuilder()
                .addParticipant(tm)
                .setSubject(tm.Id)
                .save()
                .build();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(tm.Id)
                .setConversation(conversation.id)
                .setContent('You are oozeless')
                .save()
                .build();

        handler = new TeamMemberConversationHandler();
        handler.setSubject(tm.Id);
        handler.setRecord(ConversationRepository.getConversationById(conversation.id));
    }

    @isTest
    private static void testCreateSubject() {

        // GIVEN a TM conversation handler
        setUp();

        // WHEN I use it to create a SubjectModel
        SubjectModel subject = handler.createSubject();

        // THEN I get the correct details
        System.assertEquals(tm.Id, subject.id);
        System.assertEquals(tm.Name, subject.name);
        System.assertEquals(tm.Id, subject.tmId);
    }

    @isTest
    private static void testGetTmId() {

        // GIVEN a TM conversation handler
        setUp();

        // WHEN I ask for the subject's TM ID, THEN I get the correct ID
        System.assertEquals(tm.Id, handler.getTmId());
    }

    @isTest
    private static void testGetJunctionField() {

        // GIVEN a TM conversation handler
        setUp();

        // WHEN I ask for the junction object's subject field
        // THEN I get the TM field
        System.assertEquals(
                ConversationSubjectUtils.TEAM_MEMBER_FIELD,
                handler.getJunctionField()
        );
    }

    @isTest
    private static void testGetLinkToComment() {

        // GIVEN a TM conversation and a handler for it
        setUp();

        // WHEN I get the link to a specific comment
        String link = UrlTestUtils.replaceWithTestDomain(
                handler.getLinkToComment(feedback.id));

        // THEN it is of the correct format
        System.assert(Pattern.matches(
                UrlTestUtils.TEST_DOMAIN
                        + '/apex/Performance#/tm/'
                        + tm.Id
                        + '#'                       // fragment identifier
                        + feedback.id,
                link
        ));
    }

    @isTest
    private static void testGetFeed() {

        // GIVEN a TM and a conversation about them
        setUp();

        // AND an objective of theirs
        ObjectiveModel objective = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTeamMember(tm.Id)
                .setTitle('Do more work')
                .setStatus(ObjectiveUtils.STATUS_DRAFT)
                .save()
                .build();

        // AND a conversation about that
        ConversationModel objectiveConv = new FeedbackTestUtils.ConversationBuilder()
                .addParticipant(tm)
                .setSubject(objective.id)
                .save()
                .build();
        FeedItemModel objectiveComment = new FeedbackTestUtils.FeedbackBuilder()
                .setContent('No progress')
                .setAuthor(tm.Id)
                .setConversation(objectiveConv.id)
                .save()
                .build();

        // AND an event relating to the objective
        Feed_Event__c objectiveEvent = FeedEventUtils.create(
                objective.id, FeedEventTypes.OBJECTIVE_ACTIVATED);

        // AND all the items are in some order
        Comment__c firstItem = FeedbackRepository.getFeedback(feedback.id);
        firstItem.Created_Date__c = Date.newInstance(1969, 7, 20);
        Comment__c secondItem = FeedbackRepository.getFeedback(objectiveComment.id);
        secondItem.Created_Date__c = Date.newInstance(1972, 12, 11);
        update new List<Comment__c>{firstItem, secondItem};

        Feed_Event__c thirdItem = FeedEventRepository.get(objectiveEvent.id);
        thirdItem.Date__c = Date.newInstance(1992, 3, 28);
        update thirdItem;

        // WHEN I get their full conversation feed
        List<FeedItemModel> feed = handler.getFeed();

        // THEN it has the expected number of items
        System.assertEquals(3, feed.size());

        // AND it contains the items in reverse chronological order
        System.assertEquals(firstItem.Id, feed[2].id);
        System.assertEquals(secondItem.Id, feed[1].id);
        System.assertEquals(thirdItem.Id, feed[0].id);
    }
}