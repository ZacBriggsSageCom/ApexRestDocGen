/**
 * Class for combining and evaluating Validation Rules about elements of
 * requests.
 */
public class RequestValidator {

    private List<ValidationRule> rules;
    private ErrorModel error;

    public RequestValidator() {
        rules = new List<ValidationRule>();
    }

    /**
     * Adds the supplied Validation Rule to the stored list and return the
     * validator.
     */
    public RequestValidator addRule(ValidationRule rule) {
        rules.add(rule);
        return this;
    }

    /**
     * Checks through all stored validation rules and determine whether they are
     * all satisfied.
     */
    public Boolean isValid() {
        for (ValidationRule rule : rules) {
            if (!rule.isValid()) {
                error = rule.createErrorModel();
                return false;
            }
        }
        return true;
    }

    /**
     * Returns the stored ErrorModel produced by the most recently failed rule.
     */
    public ErrorModel getErrorModel() {
        return error;
    }
}
