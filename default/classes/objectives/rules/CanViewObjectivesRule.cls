public class CanViewObjectivesRule implements ValidationRule {

    private String tmId;

    public CanViewObjectivesRule(String tmId) {
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
        return new ErrorModel(HttpUtils.STATUS_FORBIDDEN, Label.Objective_Access_Denied, '');
    }

}
