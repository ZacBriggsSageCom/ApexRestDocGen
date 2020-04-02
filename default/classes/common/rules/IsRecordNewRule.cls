/**
 * Validation rule for determining whether a record is new, i.e. where the 
 * failure condition is that the record already exists.
 */
public virtual class IsRecordNewRule implements ValidationRule {

    private String recordId;
    private String errorMessage;

    public IsRecordNewRule(String recordId, String errorMessage) {
        this.recordId = recordId;
        this.errorMessage = errorMessage;
    }

    public Boolean isValid() {
        if (recordId != null && SObjectUtils.isValidId(recordId)) {
            String recordType = SObjectUtils.getTypeNameOf(Id.valueOf(recordId));
            return !SObjectRepository.doesRecordExist(recordId, recordType);
        }
        return true;
    }

    public ErrorModel createErrorModel() {
        return new ErrorModel(HttpUtils.STATUS_CONFLICT, errorMessage, '');
    }

}
