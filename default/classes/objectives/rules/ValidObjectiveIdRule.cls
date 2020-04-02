/**
 * Validation rule for determining whether a Objective Id is valid.
 */
public class ValidObjectiveIdRule extends ValidIdRule {

    public ValidObjectiveIdRule(String objectiveId) {
        super(objectiveId, Label.Objective_Id_Invalid);
    }

    public override Boolean isValid() {
        return super.isValid()
                && SObjectUtils.isOfType(recordId, ObjectiveUtils.OBJECTIVE_TYPE);
    }
}