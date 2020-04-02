/**
 * Utilities for dealing with Conversations.
 */
public class ConversationUtils {

    public static final String CONVERSATION_TYPE =
            NamespaceUtils.getNamespacePrefix() + 'Conversation__c';

    /**
     * Get a Conversation and its details by ID.
     */
    public static ConversationModel getConversation(Id conversationId) {

        // Get the record
        Conversation__c record = ConversationRepository.getConversationById(conversationId);

        // Create handler object
        ConversationHandler handler =
                ConversationHandlerRegistry.getHandlerForConversationId(conversationId);

        // Build the Conversation
        SubjectModel subject = handler.createSubject();
        List<PersonModel> participants = getParticipants(conversationId);
        List<FeedItemModel> items = handler.getFeed();
        return ConversationModelBuilder.build(record, subject, participants, items);
    }

    /**
     * Save a new Conversation.
     */
    public static ConversationModel insertConversation(ConversationModel conversation) {

        // Save new Conversation record
        Conversation__c record = ConversationRecordBuilder.build(conversation);
        ConversationRepository.insertRecord(record);

        // Build subject
        SubjectModel subject = linkSubject(record.id, conversation.subject.id);

        // Locate participants
        Set<Id> participantIds = new Set<Id>();
        for (PersonModel participant : conversation.participants) {
            participantIds.add(participant.id);
        }

        // Create link to participants
        ConversationParticipantUtils.createJunctions(record.Id, participantIds);

        // Build participants
        List<fHCM2__Team_Member__c> tms =
                TeamMemberRepository.get(participantIds);
        List<PersonModel> participants = TeamMemberUtils.createPeople(tms);

        // Rebuild model
        return ConversationModelBuilder.build(
                record,
                subject,
                participants,
                new List<FeedItemModel>()
        );
    }

    /**
     * Creates a conversation about a subject. Assumes that the conversation
     * should involve the subject's "owner" (or the subject itself, if it is a TM)
     * plus the owner's manager.
     */
    public static ConversationModel createConversationAbout(Id subjectId) {

        // Work out who the subject is associated with
        String subjectType = SObjectUtils.getTypeNameOf(subjectId);
        ConversationHandler handler =
                ConversationHandlerRegistry.getHandlerForSubject(subjectId);
        Id tmId = handler.getTmId();

        // List participants
        fHCM2__Team_Member__c tm = TeamMemberRepository.get(tmId);
        Set<Id> participantIds = new Set<Id>();
        participantIds.add(tmId);
        participantIds.add(tm.fHCM2__Manager__c);

        // Persist objects
        Conversation__c conversation = new Conversation__c();
        ConversationRepository.insertRecord(conversation);
        linkSubject(conversation.id, subjectId);
        ConversationParticipantUtils.createJunctions(conversation.Id, participantIds);

        // Build and return
        return getConversation(conversation.Id);
    }

    /**
     * Determine whether a Team Member is a participant in a Conversation.
     */
    public static Boolean isParticipant(Id tmId, Id conversationId) {
        List<Conversation_Participant__c> participants =
                ConversationParticipantRepository.getParticipantsByConversationId(
                        conversationId);
        for (Conversation_Participant__c participant : participants) {
            if (participant.Team_Member__c == tmId) {
                return true;
            }
        }
        return false;
    }

    /**
     * For a Conversation ID and a subject ID, link the two with a junction
     * object and return a SubjectModel.
     */
    @TestVisible
    private static SubjectModel linkSubject(Id conversationId, Id subjectId) {

        // Acquire conversation handler
        ConversationHandler handler =
                ConversationHandlerRegistry.getHandlerForSubject(subjectId);

        // Create junction object
        ConversationSubjectUtils.createJunction(conversationId, handler);

        // Return SubjectModel
        return handler.createSubject();
    }

    /**
     * Creates a SubjectModel for the given Conversation.
     */
    public static SubjectModel createSubjectForConversation(Id conversationId) {
        return ConversationHandlerRegistry.getHandlerForConversationId(conversationId)
                .createSubject();
    }

    /**
     * Finds the ID of a conversation, given its subject ID. Will return the first
     * match found.
     */
    public static Id findBySubject(Id subjectId) {
        List<Conversation_Subject__c> junctions =
                ConversationSubjectRepository.getSubjectsWithLinkedId(subjectId);
        return junctions.isEmpty() ? null : junctions.get(0).Conversation__c;
    }

    /**
     * Find all participants in a Conversation and return as PersonModels.
     */
    public static List<PersonModel> getParticipants(Id conversationId) {

        // Get the junction objects
        List<Conversation_Participant__c> participants =
                ConversationParticipantRepository.getParticipantsByConversationId(
                        conversationId);

        // Get Team Member details
        Set<Id> tmIds = new Set<Id>();
        for (Conversation_Participant__c participant : participants) {
            tmIds.add(participant.Team_Member__c);
        }
        List<fHCM2__Team_Member__c> tms = TeamMemberRepository.get(tmIds);

        // Create models
        List<PersonModel> models = new List<PersonModel>();
        for (fHCM2__Team_Member__c tm : tms) {
            models.add(TeamMemberUtils.createPerson(tm));
        }
        return models;
    }

    /**
     * Gets the IDs of the Conversations for which one TM is a participant, and
     * one of the subject TMs is the subject, in the form
     * subject ID => Conversation ID.
     *
     * N.B. This returns an arbitrary match found in each case, with the assumption
     * that there will only be one for each subject.
     */
    public static Map<Id, Id> findConversationsWithParticipantForSubjects(
            Id participantId, Set<Id> subjectIds) {

        // Find Conversations involving the participant
        List<Conversation_Participant__c> participants =
                ConversationParticipantRepository.getParticipantsByTeamMemberId(
                        participantId);

        // Find Conversations where the one of the TMs is the subject
        List<Conversation_Subject__c> subjects =
                ConversationSubjectRepository.getSubjectsWithTeamMemberIds(subjectIds);

        // Match subjects with conversations
        Map<Id, Id> conversationsByTm = new Map<Id, Id>();
        for (Conversation_Participant__c participant : participants) {
            for (Conversation_Subject__c subject : subjects) {
                if (participant.Conversation__c == subject.Conversation__c) {
                    conversationsByTm.put(subject.Team_Member__c, subject.Conversation__c);
                }
            }
        }
        return conversationsByTm;
    }

    /**
     * Gets the ID of the Conversation between one TM (the subject) and another
     * TM (the other participant).
     *
     * N.B. This returns the first match found, with the assumption that there
     * will only be one.
     */
    public static Id findTmConversationBetween(Id subjectId, Id participantId) {

        // Find Conversations about the subject
        List<Conversation_Subject__c> subjects =
                ConversationSubjectRepository.getSubjectsWithTeamMemberIds(
                        new Set<Id>{subjectId});
        if (subjects.isEmpty()) {
            return null;
        }

        // Find Conversations involving the other participant
        List<Conversation_Participant__c> participants =
                ConversationParticipantRepository.getParticipantsByTeamMemberId(
                        participantId);

        // Find the Conversation in common
        for (Conversation_Participant__c participant : participants) {
            if (subjects.get(0).Conversation__c == participant.Conversation__c) {
                return participant.Conversation__c;
            }
        }

        return null;
    }
}