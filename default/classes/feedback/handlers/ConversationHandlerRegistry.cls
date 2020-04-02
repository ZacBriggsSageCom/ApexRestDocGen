/**
 * Class responsible for registering the kinds of Conversations we allow, and
 * delivering concrete ConversationHandlers for subjects.
 */
public class ConversationHandlerRegistry {

    // SObject type name => ConversationHandler for subjects of that type
    private static final Map<String, Type> PROVIDER_TYPES = new Map<String, Type>();

    // Destination fields on the Conversation Subject junction object
    private static final List<String> JUNCTION_OBJECT_FIELDS = new List<String>();

    /**
     * Registers known conversation types.
     */
    static {

        // Team Member conversations
        register(
                TeamMemberUtils.TEAM_MEMBER_TYPE,
                Type.forName('TeamMemberConversationHandler'),
                ConversationSubjectUtils.TEAM_MEMBER_FIELD
        );

        // Objective conversations
        register(
                ObjectiveUtils.OBJECTIVE_TYPE,
                Type.forName('ObjectiveConversationHandler'),
                ConversationSubjectUtils.OBJECTIVE_FIELD
        );
    }

    /**
     * Adds the given subject type to the registry.
     */
    private static void register(String typeName, Type type, String junctionField) {
        PROVIDER_TYPES.put(typeName, type);
        JUNCTION_OBJECT_FIELDS.add(junctionField);
    }

    /**
     * Determines whether an ID is one of the types we permit for Conversation
     * subjects.
     */
    public static Boolean isAcceptableSubjectType(Id subjectId) {
        return PROVIDER_TYPES.keySet().contains(SObjectUtils.getTypeNameOf(subjectId));
    }

    /**
     * Delivers an appropriate ConversationHandler for a Conversation ID.
     */
    public static ConversationHandler getHandlerForConversationId(Id conversationId) {
        return getHandler(getSubjectId(conversationId), conversationId);
    }

    /**
     * Delivers an appropriate ConversationHandler for a subject ID.
     */
    public static ConversationHandler getHandlerForSubject(Id subjectId) {
        return getHandler(subjectId, getConversationId(subjectId));
    }

    private static ConversationHandler getHandler(Id subjectId, Id conversationId) {
        if (subjectId == null) {
            return null;
        }

        Type t = PROVIDER_TYPES.get(SObjectUtils.getTypeNameOf(subjectId));
        if (t == null) {
            return null;
        }

        ConversationHandler handler = (ConversationHandler) t.newInstance();
        handler.setSubject(subjectId);
        handler.setRecord(ConversationRepository.getConversationById(conversationId));
        return handler;
    }

    private static Id getSubjectId(Id conversationId) {
        Conversation_Subject__c junction =
                ConversationSubjectRepository.getSubjectByConversationId(conversationId);
        for (String field : JUNCTION_OBJECT_FIELDS) {
            if (junction.get(field) != null) {
                return (Id) junction.get(field);
            }
        }
        return null;
    }

    private static Id getConversationId(Id subjectId) {
        List<Conversation_Subject__c> junctions =
                ConversationSubjectRepository.getSubjectsWithLinkedId(subjectId);
        return junctions.isEmpty() ? null : junctions[0].Conversation__c;
    }
}