/**
 * Validation rule for determining whether a Feedback Id is valid.
 */
public class ValidFeedbackIdRule extends ValidIdRule {

    public ValidFeedbackIdRule(String feedbackId) {
        super(feedbackId, Label.Comment_Id_Invalid);
    }

    public override Boolean isValid() {
        return super.isValid()
                && SObjectUtils.isOfType(recordId, FeedbackUtils.FEEDBACK_TYPE);
    }
}