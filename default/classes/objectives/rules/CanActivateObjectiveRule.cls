public class CanActivateObjectiveRule implements ValidationRule {

    private String objectiveId;

    public CanActivateObjectiveRule(String objectiveId) {
        this.objectiveId = objectiveId;
    }

    public Boolean isValid() {
        return ObjectiveRepository.get(objectiveId).CreatedById == UserInfo.getUserId();
    }

    public ErrorModel createErrorModel() {
        return new ErrorModel(HttpUtils.STATUS_FORBIDDEN, Label.Objective_Activate_Denied, '');
    }
}
