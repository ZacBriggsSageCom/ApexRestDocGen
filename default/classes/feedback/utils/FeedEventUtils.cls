public class FeedEventUtils {

    /**
     * Creates a Feed Event, with the current viewer as the actor.
     */
    public static Feed_Event__c create(Id subjectId, String eventType) {
        Feed_Event__c event = new Feed_Event__c(
            Actor__c = TeamMemberUtils.getTeamMemberId(UserInfo.getUserId()),
            Date__c = Datetime.now(),
            Subject__c = subjectId,
            Type__c = eventType
        );
        return FeedEventRepository.insertRecord(event);
    }
}