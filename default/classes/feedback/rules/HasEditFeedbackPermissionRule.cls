/**
 * Validation rule for determining whether a viewer has permission to edit
 * a Feedback item.
 */
public class HasEditFeedbackPermissionRule implements ValidationRule {

    protected Viewport viewport;
    private FeedItemModel item;

    public HasEditFeedbackPermissionRule(FeedItemModel item) {
        this.item = item;
    }

    public Boolean isValid() {

        viewport = new Viewport();

        Id tmId = viewport.getViewerTeamMemberId();
        Comment__c feedback = FeedbackRepository.getFeedback(item.id);

        if (feedback.Author__c != tmId) {
            // Current user is not the author
            return false;
        }

        // Check permissions in viewer policy
        return new Viewport().canViewerEditFeedback();
    }

    public ErrorModel createErrorModel() {
        return new ErrorModel(
                HttpUtils.STATUS_FORBIDDEN, Label.Comment_Edit_Denied, '');
    }

}
