/**
 * Validation rule for determining whether a Feedback record exists, i.e. where
 * the failure condition is that the Feedback does not exist.
 */
public class DoesFeedbackExistRule extends DoesRecordExistRule {

    public DoesFeedbackExistRule(String feedbackId) {
        super(feedbackId, Label.Comment_Does_Not_Exist);
    }
}
