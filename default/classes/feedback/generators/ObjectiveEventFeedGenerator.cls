/**
 * Object for generating event feeds stemming from Objectives for a common subject.
 */
public class ObjectiveEventFeedGenerator implements FeedGenerator {

    private Map<Id, Objective__c> objectivesById;
    private List<Feed_Event__c> events;
    private Map<String, PersonModel> actorsById;
    private Map<String, FeedEventBuilder> buildersByType;
    private Map<Objective__c, List<Feed_Event__c>> eventListsByObjective;

    public ObjectiveEventFeedGenerator(List<Objective__c> objectives) {
        objectivesById = new Map<Id, Objective__c>(objectives);
    }

    public List<FeedItemModel> generate() {

        // Query for all events relating to our objectives
        events = FeedEventRepository.getBySubjects(objectivesById.keySet());

        // Arrange events against their objectives
        eventListsByObjective = collectFeedEventsByObjective();

        // Build up the actors we will need
        actorsById = getActorsByIdForEvents();

        // Get builder objects to handle the event types we have
        buildersByType = getBuildersByType();

        // Use our generators to create the events
        return buildEventItems();
    }

    /**
     * Arranges our feed events against our stored objectives in the form
     * Objective => List of FeedItems.
     */
    private Map<Objective__c, List<Feed_Event__c>> collectFeedEventsByObjective() {
        Map<Objective__c, List<Feed_Event__c>> eventListsByObjective =
                new Map<Objective__c, List<Feed_Event__c>>();
        for (Feed_Event__c event : events) {
            Objective__c objective = objectivesById.get(event.Subject__c);
            List<Feed_Event__c> groupedEvents = eventListsByObjective.get(objective);

            if (groupedEvents == null) {
                groupedEvents = new List<Feed_Event__c>();
            }

            groupedEvents.add(event);
            eventListsByObjective.put(objective, groupedEvents);
        }
        return eventListsByObjective;
    }

    /**
     * For our events, build a map representing the actors who have caused them,
     * in the form TM ID => PersonModel.
     */
    private Map<String, PersonModel> getActorsByIdForEvents() {

        // Build actors
        Set<Id> actorIds = new Set<Id>();
        for (Feed_Event__c event : events) {
            actorIds.add(event.Actor__c);
        }
        List<PersonModel> actors = TeamMemberUtils.createPeople(actorIds);

        // Arrange by ID
        Map<String, PersonModel> personByActorId = new Map<String, PersonModel>();
        for (PersonModel actor : actors) {
            personByActorId.put(actor.id, actor);
        }
        return personByActorId;
    }

    /**
     * For each of the unique types of event we have in our list, maps an
     * appropriate builder object.
     */
    private Map<String, FeedEventBuilder> getBuildersByType() {
        Map<String, FeedEventBuilder> buildersByType =
                new Map<String, FeedEventBuilder>();
        for (String eventType : enumerateEventTypes()) {
            buildersByType.put(
                    eventType,
                    FeedEventBuilderRegistry.getFor(eventType)
            );
        }
        return buildersByType;
    }

    /**
     * List the unique "types" of our events.
     */
    private Set<String> enumerateEventTypes() {
        Set<String> eventTypes = new Set<String>();
        for (Feed_Event__c event : events) {
            eventTypes.add(event.Type__c);
        }
        return eventTypes;
    }

    /**
     * Builds a list of event items, using the following stored maps:
     *  - Objective => Events
     *  - Event type => FeedEventBuilder
     *  - Actor ID => PersonModel representing that actor
     */
    private List<FeedItemModel> buildEventItems() {
        Id viewerId = TeamMemberUtils.getTeamMemberId(UserInfo.getUserId());
        List<FeedItemModel> eventItems = new List<FeedItemModel>();
        for (Objective__c objective : eventListsByObjective.keySet()) {
            for (Feed_Event__c event : eventListsByObjective.get(objective)) {
                FeedEventBuilder generator = buildersByType.get(event.Type__c);
                if (generator == null) {
                    System.debug('No generator found for event of type ' + event.Type__c);
                } else {
                    eventItems.add(generator.generate(
                            actorsById.get(event.Actor__c), event, viewerId, objective));
                }
            }
        }
        return eventItems;
    }
}