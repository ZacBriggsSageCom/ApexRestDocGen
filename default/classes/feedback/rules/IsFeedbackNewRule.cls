/**
 * Validation rule for determining whether a Feedback record is new, i.e. where
 * the failure condition is that the Feedback already exists.
 */
public class IsFeedbackNewRule extends IsRecordNewRule {

    public IsFeedbackNewRule(String feedbackId) {
        super(feedbackId, Label.Comment_Already_Exists);
    }
}
