public class CanDeleteObjectiveRule implements ValidationRule {

    private String objectiveId;

    public CanDeleteObjectiveRule(String objectiveId) {
        this.objectiveId = objectiveId;
    }

    public Boolean isValid() {
        return ObjectiveRepository.get(objectiveId).CreatedById == UserInfo.getUserId();
    }

    public ErrorModel createErrorModel() {
        return new ErrorModel(HttpUtils.STATUS_FORBIDDEN, Label.Objective_Delete_Denied, '');
    }
}
