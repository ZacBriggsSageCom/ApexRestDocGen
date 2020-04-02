/**
 * Class for registering new types of feed events against their builders, and
 * providing said builders.
 */
public class FeedEventBuilderRegistry {

    private static final Map<String, Type> BUILDER_TYPES = new Map<String, Type>{
        FeedEventTypes.OBJECTIVE_ACTIVATED => Type.forName('ObjectiveActivatedEventBuilder'),
        FeedEventTypes.OBJECTIVE_CLOSED => Type.forName('ObjectiveClosedEventBuilder')
    };

    /**
     * Provides a FeedEventBuilder appropriate for the given feed event type.
     */
    public static FeedEventBuilder getFor(String eventType) {
        Type t = BUILDER_TYPES.get(eventType);
        return t == null ? null : (FeedEventBuilder) t.newInstance();
    }
}