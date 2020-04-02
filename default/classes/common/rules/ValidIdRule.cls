/**
 * Validation rule for determining whether a supplied Id is valid.
 */
public virtual class ValidIdRule implements ValidationRule {

    protected String recordId;
    private String errorMessage;

    public ValidIdRule(String recordId, String errorMessage) {
        this.recordId = recordId;
        this.errorMessage = errorMessage;
    }

    public virtual Boolean isValid() {
        return SObjectUtils.isValidId(recordId);
    }

    public ErrorModel createErrorModel() {
        return new ErrorModel(HttpUtils.STATUS_BAD_REQUEST, errorMessage, '');
    }
}
