/**
 * Validation rule for determining whether a record exists, i.e. where the
 * failure condition is that the record does not exist.
 */
public virtual class DoesRecordExistRule implements ValidationRule {

    private String recordId;
    private String errorMessage;

    public DoesRecordExistRule(String recordId, String errorMessage) {
        this.recordId = recordId;
        this.errorMessage = errorMessage;
    }

    public Boolean isValid() {
        if (recordId != null && SObjectUtils.isValidId(recordId)) {
            String recordType = SObjectUtils.getTypeNameOf(Id.valueOf(recordId));
            return SObjectRepository.doesRecordExist(recordId, recordType);
        }
        return false;
    }

    public ErrorModel createErrorModel() {
        return new ErrorModel(HttpUtils.STATUS_NOT_FOUND, errorMessage, '');
    }

}
