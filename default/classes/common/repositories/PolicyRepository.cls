public class PolicyRepository {

    /**
     * Gets the Policy fields required for the Policy page.
     */
    public static List<fHCM2__Policy__c> get(Set<Id> policyIds) {
        return [
            SELECT
                Id,
                Conversations_Is_Active__c,
                Allow_Edit_Feedback__c,
                Objectives_Is_Active__c
            FROM fHCM2__Policy__c
            WHERE Id IN :policyIds
        ];
    }

    /**
     * Gets the Policy fields required for the Policy page.
     */
    public static fHCM2__Policy__c getPolicyForPolicyPage(Id policyId) {
        List<fHCM2__Policy__c> policies = [
            SELECT
                Id,
                Conversations_Is_Active__c,
                Allow_Edit_Feedback__c,
                Objectives_Is_Active__c
            FROM fHCM2__Policy__c
            WHERE Id =: policyId
        ];
        return !policies.isEmpty() ? policies.get(0) : null;
    }

    /**
     * Gets the Policy fields required by the Viewport, for the viewer.
     */
    public static fHCM2__Policy__c getViewerPolicy(Id policyId) {
        List<fHCM2__Policy__c> policies = [
            SELECT
                Id,
                Allow_Edit_Feedback__c
            FROM fHCM2__Policy__c
            WHERE Id =: policyId
        ];
        return !policies.isEmpty() ? policies.get(0) : null;
    }

    /**
     * Get all Policies in the org, with Performance Management-related fields
     * populated.
     */
    public static List<fHCM2__Policy__c> getAllPolicies() {
        return [
            SELECT
                Id,
                Name,
                Allow_Edit_Feedback__c,
                Conversations_Is_Active__c,
                Objectives_Is_Active__c
            FROM fHCM2__Policy__c
        ];
    }

}