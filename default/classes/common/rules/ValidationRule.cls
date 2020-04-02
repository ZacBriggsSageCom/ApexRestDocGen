/**
 * Interface representing a rule for validating a part of a request.
 */
public interface ValidationRule {

    /**
     * Check whether the rule is satisfied.
     *
     * @return Boolean
     */
    Boolean isValid();

    /**
     * Create and return an ErrorModel containing an appropriate error message 
     * and status code representing a breaking of the rule.
     *
     * @return ErrorModel
     */
    ErrorModel createErrorModel();

}
