/**
 * Validation rule for determining whether an objective's status qualifies it to
 * be edited.
 */
public class CanObjectiveBeEditedRule implements ValidationRule {

    private String status;

    public CanObjectiveBeEditedRule(String status) {
        this.status = status;
    }

    public Boolean isValid() {
        return status == ObjectiveUtils.STATUS_DRAFT
                || status == ObjectiveUtils.STATUS_ACTIVE;
    }

    public ErrorModel createErrorModel() {
        return new ErrorModel(
                HttpUtils.STATUS_BAD_REQUEST,
                Label.Objective_Edit_Invalid_Status, '');
    }

}