/**
 * Object for generating comment feeds stemming from Conversations about
 * Objectives for a common subject.
 */
public class ObjectiveCommentFeedGenerator implements FeedGenerator {

    private Map<Id, Objective__c> objectivesById;
    private List<Conversation__c> conversations;
    private List<Conversation_Subject__c> junctions;
    private Map<Id, Conversation__c> conversationsById;
    private Map<Conversation__c, Objective__c> objectivesByConversation;

    public ObjectiveCommentFeedGenerator(List<Objective__c> objectives) {
        objectivesById = new Map<Id, Objective__c>(objectives);
    }

    public List<FeedItemModel> generate() {

        // Find junction objects linking objectives to conversations
        junctions = ConversationSubjectRepository.getSubjectsWithObjectiveIds(
                objectivesById.keySet());

        // Find conversations
        conversations = ConversationSubjectUtils.getLinkedConversations(junctions);

        // Index conversations by ID
        conversationsById = new Map<Id, Conversation__c>(conversations);

        // Match conversations against objectives
        objectivesByConversation = mapConversationsToObjectives();

        // Build feed items from conversation comments
        List<FeedItemModel> items = createFeedItemsForConversations();

        // Collect feed items against their objectives
        Map<Objective__c, List<FeedItemModel>> itemsByObjective =
                collectFeedItemsByObjective(items);

        // Create conversation handlers to assist adding detail
        Map<Objective__c, ConversationHandler> handlerByObjective =
                getHandlersByObjective();

        // Add event details to each, using partnered objective
        for (Objective__c objective : itemsByObjective.keySet()) {
            for (FeedItemModel item : itemsByObjective.get(objective)) {
                addEventDetails(item, objective, handlerByObjective.get(objective));
            }
        }

        return items;
    }

    /**
     * Creates a map of Conversation => Objective from our working objects.
     */
    private Map<Conversation__c, Objective__c> mapConversationsToObjectives() {
        Map<Conversation__c, Objective__c> objectivesByConversation =
                new Map<Conversation__c, Objective__c>();
        for (Conversation_Subject__c junction : junctions) {
            objectivesByConversation.put(
                conversationsById.get(junction.Conversation__c),
                objectivesById.get(junction.Objective__c));
        }
        return objectivesByConversation;
    }

    /**
     * Combines comments from all stored Conversations to produce a single list
     * of FeedItemModels.
     */
    private List<FeedItemModel> createFeedItemsForConversations() {
        Set<Id> commentIds = new Set<Id>();
        for (Conversation__c conversation : conversations) {
            for (Comment__c comment : conversation.Comments__r) {
                commentIds.add(comment.Id);
            }
        }
        return FeedbackUtils.getFeedback(commentIds);
    }

    /**
     * Given some FeedItems, arranges them against our stored objectives in the
     * form Objective => List of FeedItems.
     */
    private Map<Objective__c, List<FeedItemModel>> collectFeedItemsByObjective(
            List<FeedItemModel> items) {

        Map<Objective__c, List<FeedItemModel>> itemsByObjective =
                new Map<Objective__c, List<FeedItemModel>>();
        for (FeedItemModel item : items) {
            Objective__c objective = objectivesByConversation.get(
                    conversationsById.get(item.conversationId));
            List<FeedItemModel> destinationItems = itemsByObjective.get(objective);

            if (destinationItems == null) {
                destinationItems = new List<FeedItemModel>();
            }

            destinationItems.add(item);
            itemsByObjective.put(objective, destinationItems);
        }
        return itemsByObjective;
    }

    /**
     * For each of our objectives, creates and maps an ObjectiveConversationHandler
     * pointing to the objective.
     */
    private Map<Objective__c, ConversationHandler> getHandlersByObjective() {
        Map<Objective__c, ConversationHandler> handlerByObjective =
                new Map<Objective__c, ConversationHandler>();
        for (Objective__c objective : objectivesById.values()) {
            ConversationHandler handler = new ObjectiveConversationHandler();
            handler.setSubject(objective.Id);
            handlerByObjective.put(objective, handler);
        }
        return handlerByObjective;
    }

    /**
     * Adds details to a feed item to mark it as an event.
     */
    @TestVisible
    private FeedItemModel addEventDetails(
            FeedItemModel item,
            Objective__c objective,
            ConversationHandler handler) {
        item.event = new FeedEventModel();
        item.event.processTitle = Label.Objectives_Process_Name;
        item.event.actor = item.comment.author;
        item.event.linkText = objective.Title__c;
        item.event.url = handler.getLinkToComment(item.id, objective.Team_Member__c);

        // Strip paragraph tags from content, to display in-line on front-end
        if (item.content.startsWith('<p>') && item.content.endsWith('</p>')) {
            item.content = item.content.removeStart('<p>').removeEnd('</p>');
        }
        return item;
    }
}