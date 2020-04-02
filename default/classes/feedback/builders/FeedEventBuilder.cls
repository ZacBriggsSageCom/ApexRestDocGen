/**
 * Specifies an object that can create feed events. Subclasses must have an
 * empty constructor, to allow dynamic instantiation.
 */
public abstract class FeedEventBuilder {

    public FeedItemModel generate(
            PersonModel actor,
            Feed_Event__c event,
            Id viewerId,
            SObject subject) {
        return addDetails(createBaseEvent(actor, event), viewerId, subject);
    }

    @TestVisible
    private FeedItemModel createBaseEvent(PersonModel actor, Feed_Event__c event) {
        FeedItemModel item = new FeedItemModel();
        item.event = new FeedEventModel();
        item.id = event.Id;
        item.itemDate = DateUtils.datetimeToStringInUserTimeZone(event.Date__c);
        item.event.actor = actor;
        return item;
    }

    /**
     * Adds event-specific details to the item.
     */
    protected abstract FeedItemModel addDetails(
            FeedItemModel item, Id viewerId, SObject subject);
}