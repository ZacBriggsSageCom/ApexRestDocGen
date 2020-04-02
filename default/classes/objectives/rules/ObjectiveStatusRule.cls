/**
 * Validation rule for determining whether an Objective is in the desired status.
 */
public class ObjectiveStatusRule implements ValidationRule {

    private String objectiveId;
    private String status;

    public ObjectiveStatusRule(String objectiveId, String status) {
        this.objectiveId = objectiveId;
        this.status = status;
    }

    public Boolean isValid() {
        Objective__c record = ObjectiveRepository.get(objectiveId);
        return record != null && record.Status__c == status;
    }

    public ErrorModel createErrorModel() {
        String errorMessage = String.format(
                Label.Objective_Status_Not_As_Expected,
                new List<String>{ status }
        );
        return new ErrorModel(HttpUtils.STATUS_FORBIDDEN, errorMessage, '');
    }
}
