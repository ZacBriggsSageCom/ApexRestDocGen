public class CanCreateObjectiveRule implements ValidationRule {

    private String tmId;

    public CanCreateObjectiveRule(String tmId) {
        this.tmId = tmId;
    }

    public Boolean isValid() {
        Viewport viewport;

        try {
            viewport = new Viewport(tmId);
        } catch (Exception e) {
            return false;
        }

        return viewport.isTeamMember() || viewport.isManager();
    }

    public ErrorModel createErrorModel() {
        return new ErrorModel(
            HttpUtils.STATUS_FORBIDDEN, Label.Objective_Create_Denied, '');
    }

}
