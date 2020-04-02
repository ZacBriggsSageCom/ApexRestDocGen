public class CanCloseObjectiveRule implements ValidationRule {

    private String objectiveId;

    public CanCloseObjectiveRule(String objectiveId) {
        this.objectiveId = objectiveId;
    }

    public Boolean isValid() {
        Objective__c objective = ObjectiveRepository.get(objectiveId);
        Viewport viewport;

        try {
            viewport = new Viewport(objective.Team_Member__c);
        } catch (Exception e) {
            return false;
        }

        return viewport.isTeamMember() || viewport.isManager();
    }

    public ErrorModel createErrorModel() {
        return new ErrorModel(HttpUtils.STATUS_FORBIDDEN, Label.Objective_Close_Denied, '');
    }

}
