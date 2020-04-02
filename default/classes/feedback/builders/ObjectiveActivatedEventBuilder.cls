public class ObjectiveActivatedEventBuilder extends FeedEventBuilder {

    public override FeedItemModel addDetails(
            FeedItemModel item,
            Id viewerId,
            SObject subject) {

        Objective__c objective = (Objective__c) subject;
        item.event.processTitle = Label.Objectives_Process_Name;
        item.event.url = ObjectiveUrlUtils.getObjectivePageUrl(
                objective.Team_Member__c, objective.Id);
        item.event.linkText = objective.Title__c;
        item.content = getContent(viewerId, item.event.actor);
        return item;
    }

    @TestVisible
    private String getContent(Id viewerId, PersonModel actor) {
        return viewerId == actor.id
                ? Label.Objective_Activated_Event_Message_You
                : String.format(
                        Label.Objective_Activated_Event_Message_Named,
                        new List<String>{actor.firstName}
                );
    }
}