/**
 * Validation rule for determining whether an Objective exists.
 */
public class DoesObjectiveExistRule extends DoesRecordExistRule {

    public DoesObjectiveExistRule(String objectiveId) {
        super(objectiveId, Label.Objective_Does_Not_Exist);
    }
}
