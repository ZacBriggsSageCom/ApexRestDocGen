/**
 * Builder for producing Objective__c records from ObjectiveModels.
 */
public class ObjectiveRecordBuilder {

    private Objective__c objective;

    public ObjectiveRecordBuilder(ObjectiveModel om) {
        objective = new Objective__c(
            Id = om.id,
            Category__c = om.category,
            Company_Objective__c = om.companyObjective,
            Description__c = om.description,
            End_Date__c = DateUtils.stringToDate(om.endDate),
            Priority__c = om.priority,
            Review_Date__c = DateUtils.stringToDate(om.reviewDate),
            Team_Member__c = om.tmId,
            Title__c = om.title,
            Visibility__c = ObjectiveUtils.VISIBILITY_PRIVATE
        );
    }

    public ObjectiveRecordBuilder setStatus(String status) {
        objective.Status__c = status;
        return this;
    }

    public ObjectiveRecordBuilder save() {

        if (objective.Id == null) {
            // Set the artificial created date (SPPLDEV-5734)
            objective.Created_Date__c = Datetime.now();
        }

        upsert objective;
        objective = ObjectiveRepository.get(objective.Id);
        return this;
    }

    public Objective__c build() {
        return objective;
    }
}