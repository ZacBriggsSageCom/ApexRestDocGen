@isTest
public class ConversationUtilsTest {

    private static ConversationModel conversation;
    private static FeedItemModel feedback;
    private static ObjectiveModel objective;
    private static fHCM2__Policy__c pol;
    private static fHCM2__Team_Member__c report;
    private static fHCM2__Team_Member__c manager;
    private static fHCM2__Team_Member__c stranger;

    //==========================================================================
    // Setup Methods
    //==========================================================================

    private static void setUpAlone() {
        createPolicy();
        report = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .setUser(UserInfo.getUserId())
                .setName('Pandora Panda')
                .build();
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(report.Id)
                .addParticipant(report)
                .setName('The Big Conversation')
                .save()
                .build();
        createFeedback();
    }

    private static void setUpAboutObjective() {
        createPolicy();
        report = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .setUser(UserInfo.getUserId())
                .setName('Pandora Panda')
                .build();
        objective = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTitle('Soar 10% higher')
                .setTeamMember(report.Id)
                .setStatus(ObjectiveUtils.STATUS_ACTIVE)
                .save()
                .build();
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .addParticipant(report)
                .setSubject(objective.id)
                .setName('The Big Conversation')
                .save()
                .build();
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(report.Id)
                .setAuthorType(TeamMemberUtils.SELF)
                .setConversation(conversation.id)
                .setContent('May our coffins be made of 100 year old oak, and may we plant those trees tomorrow.')
                .save()
                .build();
    }

    private static void setUpAsReport() {
        createPolicy();
        manager = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .setName('Socrates Sandfish')
                .build();
        report = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .setUser(UserInfo.getUserId())
                .setManager(manager.Id)
                .setName('Pandora Panda')
                .build();
    }

    private static void setUpAsManager() {
        createPolicy();
        manager = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .setUser(UserInfo.getUserId())
                .setName('Socrates Sandfish')
                .build();
        report = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .setManager(manager.Id)
                .setName('Pandora Panda')
                .build();
        createManagerConversation();
    }

    private static void setUpAsStranger() {
        createPolicy();
        manager = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .setName('Socrates Sandfish')
                .build();
        report = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .setManager(manager.Id)
                .setName('Pandora Panda')
                .build();
        stranger = new TeamMemberTestUtils.TeamMemberbuilder()
                .setPolicy(pol.Id)
                .setUser(UserInfo.getUserId())
                .setManager(manager.Id)
                .setName('Aristotle Aardvark')
                .build();

        createManagerConversation();
    }

    private static void createObjective() {
        objective = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTitle('Expand and multiply')
                .setTeamMember(report.Id)
                .save()
                .build();
    }

    private static void createManagerConversation() {
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(report.Id)
                .addParticipant(report)
                .addParticipant(manager)
                .setName('The Big Conversation')
                .save()
                .build();
    }

    private static void createUnsavedConversation() {
        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(report.Id)
                .addParticipant(spperfmgmt.ConversationUtilsTest.report)
                .setName('The Little Conversation')
                .build();
    }

    private static void createFeedback() {
        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(report.Id)
                .setConversation(conversation.id)
                .save()
                .build();
    }

    private static void createPolicy() {
        pol = new fHCM2__Policy__c(Allow_Edit_Feedback__c = true);
        insert pol;
    }

    //==========================================================================
    // Test Methods
    //==========================================================================

    @isTest
    private static void testGetConversation() {

        // GIVEN a Conversation
        setUpAlone();

        // WHEN I get all its details
        ConversationModel conv =
                ConversationUtils.getConversation(conversation.Id);

        // THEN I receive the correct one
        System.assertEquals(conversation.id, conv.id);

        // AND it has the correct name
        System.assertEquals(conversation.name, conv.name);

        // AND it has the correct viewer TM details
        System.assertEquals(report.Id, conv.viewerTmId);
        System.assert(conv.viewerCanEdit);

        // AND it has the correct subject
        SubjectModel subject = conv.subject;
        System.assertEquals(report.id, subject.id);
        System.assertEquals(report.id, subject.tmId);
        System.assertEquals(report.Name, subject.name);

        // AND it has the correct participants
        List<PersonModel> participants = conv.participants;
        PersonModel person = participants.get(0);
        System.assertEquals(1, participants.size());
        System.assertEquals(report.Id, person.id);
        System.assertEquals(report.Name, person.name);
        System.assert(person.pictureUrl.contains('NoPicture'));

        // AND it contains the correct Feedback items
        List<FeedItemModel> items = conv.items;
        FeedItemModel item = items.get(0);
        System.assertEquals(feedback.id, item.id);
        System.assertEquals(feedback.comment.author.id, item.comment.author.id);
    }

    @isTest
    private static void testGetEnhancedConversation() {

        // GIVEN a conversation about a objective
        setUpAboutObjective();

        // And a conversation about a person
        ConversationModel personConversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(report.Id)
                .addParticipant(report)
                .setName('The Big Conversation')
                .save()
                .build();
        FeedItemModel personFeedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(report.Id)
                .setAuthorType(TeamMemberUtils.SELF)
                .setConversation(personConversation.id)
                .setContent('Some vapid comment')
                .save()
                .build();

        // WHEN I get all the continuous conversations details
        ConversationModel continuousConversation =
                ConversationUtils.getConversation(personConversation.id);

        // THEN I receive the correct one
        System.assertEquals(personConversation.id, continuousConversation.id);

        // AND it has the correct name
        System.assertEquals(personConversation.name, continuousConversation.name);

        // AND it has the correct viewer TM details
        System.assertEquals(report.Id, continuousConversation.viewerTmId);
        System.assert(continuousConversation.viewerCanEdit);

        // AND it has the correct subject
        SubjectModel subject = continuousConversation.subject;
        System.assertEquals(report.id, subject.id);
        System.assertEquals(report.id, subject.tmId);
        System.assertEquals(report.Name, subject.name);

        // AND it has the correct participants
        List<PersonModel> participants = continuousConversation.participants;
        PersonModel person = participants.get(0);
        System.assertEquals(1, participants.size());
        System.assertEquals(report.Id, person.id);
        System.assertEquals(report.Name, person.name);
        System.assert(person.pictureUrl.contains('NoPicture'));

        // AND it contains feedback items for BOTH the
        // person-subject conversation AND their objective conversation
        List<FeedItemModel> items = continuousConversation.items;

        // AND Not only do I have feedback from my conversation, BUT also
        // from my conversation about an objective
        System.assertEquals(items[0].id, personFeedback.id);
        System.assertEquals(items[1].id, feedback.id);

    }

    @isTest
    private static void testInsertConversation() {

        // GIVEN a Conversation I want to save
        setUpAsReport();
        createUnsavedConversation();

        // WHEN I save it and receive the built version
        ConversationModel savedConversation =
                ConversationUtils.insertConversation(conversation);

        // THEN it has been saved
        System.assertNotEquals(null, savedConversation.id);
        System.assertNotEquals(
                null,
                ConversationRepository.getConversationById(savedConversation.id)
        );

        // AND its name is correct
        System.assertEquals(conversation.name, savedConversation.name);

        // AND it has the correct viewer TM details
        System.assertEquals(report.Id, savedConversation.viewerTmId);
        System.assert(savedConversation.viewerCanEdit);

        // AND it has the correct subject
        SubjectModel subject = savedConversation.subject;
        System.assertEquals(report.id, subject.id);
        System.assertEquals(report.id, subject.tmId);
        System.assertEquals(report.Name, subject.name);

        // AND it has the correct participants
        List<PersonModel> participants = savedConversation.participants;
        PersonModel person = participants.get(0);
        System.assertEquals(1, participants.size());
        System.assertEquals(report.Id, person.id);
        System.assertEquals(report.Name, person.name);
        System.assert(person.pictureUrl.contains('NoPicture'));

        // AND it has an empty list of Feedback items
        List<FeedItemModel> items = savedConversation.items;
        System.assertEquals(0, items.size());
    }

    @isTest
    private static void testCreateConversationAboutTeamMember() {

        // GIVEN a TM
        setUpAsReport();

        // WHEN I create a conversation about them
        ConversationModel conv =
                ConversationUtils.createConversationAbout(report.id);

        // THEN the conversation is created
        System.assertNotEquals(
                null, ConversationRepository.getConversationById(conv.id));

        // AND the subject is linked to it
        System.assertEquals(
                1,
                ConversationSubjectRepository.getSubjectsWithTeamMemberIds(
                        new Set<Id>{report.id}).size()
        );

        // AND its participants are linked to it
        System.assertEquals(
                2,
                ConversationParticipantRepository.getParticipantsByConversationId(
                        conv.id).size()
        );
    }

    @isTest
    private static void testCreateConversationAboutObjective() {

        // GIVEN an objective
        setUpAsReport();
        createObjective();

        // WHEN I create a conversation about it
        ConversationModel conv =
                ConversationUtils.createConversationAbout(objective.id);

        // THEN the conversation is created
        System.assertNotEquals(
                null, ConversationRepository.getConversationById(conv.id));

        // AND the subject is linked to it
        System.assertEquals(
                1,
                ConversationSubjectRepository.getSubjectsWithObjectiveIds(
                        new Set<Id>{objective.id}).size()
        );

        // AND its participants are linked to it
        System.assertEquals(
                2,
                ConversationParticipantRepository.getParticipantsByConversationId(
                        conv.id).size()
        );
    }

    @isTest
    private static void testIsParticipantAsParticipant() {

        // GIVEN a Conversation in which I'm a participant
        setUpAsManager();
        createManagerConversation();

        //  WHEN I query isParticipant, THEN isParticipant returns true
        System.assert(ConversationUtils.isParticipant(report.Id, conversation.Id));
    }

    @isTest
    private static void testIsParticipantWhenNotParticipant() {

        // GIVEN a Conversation and a person with no business viewing it
        setUpAsStranger();
        createManagerConversation();

        // WHEN I query isParticipant with the stranger
        Boolean result = ConversationUtils.isParticipant(stranger.Id, conversation.Id);

        // THEN isParticipant returns false
        System.assert(!result);
    }

    @isTest
    private static void testCreateSubjectForContinuousConversation() {

        // GIVEN a conversation about a TM
        setUpAsReport();
        createManagerConversation();

        // WHEN I request the subject of the conversation
        SubjectModel retrievedSubject =
                ConversationUtils.createSubjectForConversation(conversation.Id);

        // THEN I get details about the TM
        System.assertEquals(report.Id, retrievedSubject.id);
        System.assertEquals(report.Name, retrievedSubject.name);
        System.assertEquals(report.Id, retrievedSubject.tmId);
    }

    @isTest
    private static void testCreateSubjectForObjectiveConversation() {

        // GIVEN a conversation about an objective
        setUpAsReport();
        ObjectiveModel objective = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTitle('Be better')
                .setTeamMember(report.Id)
                .save()
                .build();
        ConversationModel conversation = new FeedbackTestUtils.ConversationBuilder()
                .addParticipant(report)
                .setSubject(objective.id)
                .save()
                .build();

        // WHEN I request the subject of the conversation
        SubjectModel retrievedSubject =
                ConversationUtils.createSubjectForConversation(conversation.Id);

        // THEN I get details about the objective
        System.assertEquals(objective.id, retrievedSubject.id);
        System.assertEquals(objective.title, retrievedSubject.name);
        System.assertEquals(report.Id, retrievedSubject.tmId);
    }

    @isTest
    private static void testFindBySubject() {

        // GIVEN a conversation about a TM
        setUpAsReport();
        createManagerConversation();

        // WHEN I look for the conversation using the TM's ID
        // THEN I get the correct ID
        System.assertEquals(
                conversation.Id, ConversationUtils.findBySubject(report.Id));
    }

    @isTest
    private static void testGetParticipants() {

        // GIVEN a conversation
        setUpAsReport();
        createManagerConversation();

        //WHEN I request the participants
        List<PersonModel> participants =
                ConversationUtils.getParticipants(conversation.Id);

        // THEN I get the participants of the conversation
        Set<Id> retrievedParticipantIDs =
                new Set<Id>{participants[0].id, participants[1].id};

        // AND they are the participants I know exist
        Set<Id> participantIDs = new Set<Id>{manager.Id, report.Id};
        Boolean participantsRetrieved =
                retrievedParticipantIDs.containsAll(participantIDs);

        System.assert(participantsRetrieved);
    }

    @isTest
    private static void testfindConversationsWithParticipantForSubjects() {

        // GIVEN a Conversation with a direct report
        setUpAsManager();

        // WHEN I try to find it
        Map<Id, Id> conversationsByTm =
                ConversationUtils.findConversationsWithParticipantForSubjects(
                        manager.Id,
                        new Set<Id>{report.Id});

        // THEN I receive the correct ID
        System.assertEquals(1, conversationsByTm.size());
        System.assertEquals(conversation.id, conversationsByTm.get(report.Id));
    }

    @isTest
    private static void testfindTmConversationBetween() {

        // GIVEN a Conversation with my manager exists
        setUpAsReport();
        createManagerConversation();

        // WHEN I try to find it
        Id conversationId = ConversationUtils.findTmConversationBetween(
                report.Id, manager.Id);

        // THEN I receive the correct ID
        System.assertEquals(conversation.id, conversationId);
    }

    @isTest
    private static void testFindConversationWithNoConversationExisting() {

        //GIVEN a stranger with no manager
        createPolicy();
        manager = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .setName('Socrates Sandfish')
                .build();
        report = new TeamMemberTestUtils.TeamMemberBuilder()
                .setPolicy(pol.Id)
                .setManager(manager.Id)
                .setName('Pandora Panda')
                .build();

        // WHEN I try to find the non-existent conversation
        Id conversationID = ConversationUtils.findTmConversationBetween(
                report.Id, manager.Id);

        // THEN I receive a null value
        System.assertEquals(null, conversationID);
    }
}