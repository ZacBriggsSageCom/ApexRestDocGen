/**
 * Controller for the Global Config page.
 */
public class GlobalConfigureController {

    private class FailedPolicyUpdateException extends Exception {}

    public Global_Configuration__c cfg { get; private set; }

    public GlobalConfigureController() {
        cfg = ConfigRepository.getGlobalConfig();
    }

    /**
     * Enables or disables Conversations in all Policies.
     */
    private static void setConversationsEnabled(Boolean enabled) {

        List<fHCM2__Policy__c> allPolicies = PolicyRepository.getAllPolicies();
        List<fHCM2__Policy__c> successfulPolicies = new List<fHCM2__Policy__c>();
        Set<fHCM2__Policy__c> failedPolicies = new Set<fHCM2__Policy__c>();

        for (fHCM2__Policy__c policy : allPolicies) {
            if (!enabled && !canDisableConversations(policy)) {
                failedPolicies.add(policy);
            } else {
                policy.Conversations_Is_Active__c = enabled;
                successfulPolicies.add(policy);
            }
        }

        update successfulPolicies;

        // Generate a warning if some policies could not be changed
        if (!failedPolicies.isEmpty()) {
            String warning =
                    'Conversations cannot be disabled if Enhanced Objectives is enabled.'
                    + ' Therefore, the following Policies could not be changed:\n';
            warning += createHtmlPolicyList(failedPolicies);
            throw new FailedPolicyUpdateException(warning);
        }
    }

    /**
     * Enables or disables Objectives in all Policies.
     */
    private static void setObjectivesEnabled(Boolean enabled) {

        List<fHCM2__Policy__c> allPolicies = PolicyRepository.getAllPolicies();
        List<fHCM2__Policy__c> successfulPolicies = new List<fHCM2__Policy__c>();
        Set<fHCM2__Policy__c> failedPolicies = new Set<fHCM2__Policy__c>();

        for (fHCM2__Policy__c policy : allPolicies) {
            if (enabled && !canEnableObjectives(policy)) {
                failedPolicies.add(policy);
            } else {
                policy.Objectives_Is_Active__c = enabled;
                successfulPolicies.add(policy);
            }
        }

        update successfulPolicies;

        // Generate a warning if some policies could not be changed
        if (!failedPolicies.isEmpty()) {
            String warning =
                    'Enhanced Objectives cannot be enabled unless Conversations is enabled.'
                    + ' Therefore, the following Policies could not be changed:\n';
            warning += createHtmlPolicyList(failedPolicies);
            throw new FailedPolicyUpdateException(warning);
        }
    }

    /**
     * Determines if Conversations can be disabled in the given Policy.
     */
    @TestVisible
    private static Boolean canDisableConversations(fHCM2__Policy__c policy) {
        // Cannot disable Conversations if Objectives is enabled!
        return policy.Conversations_Is_Active__c == false
                || policy.Objectives_Is_Active__c == false;
    }

    /**
     * Determines if Objectives can be disabled in the given Policy.
     */
    @TestVisible
    private static Boolean canEnableObjectives(fHCM2__Policy__c policy) {
        // Cannot enable Objectives if Conversations is disabled!
        return policy.Objectives_Is_Active__c == true
                || policy.Conversations_Is_Active__c == true;
    }

    /**
     * Produces an HTML list of Policies.
     */
    private static String createHtmlPolicyList(Set<fHCM2__Policy__c> policies) {
        String text = '<ul>';
        for (fHCM2__Policy__c policy : policies) {
            text += '<li>' + policy.Name + '</li>';
        }
        text += '</ul>';
        return text;
    }

    /**
     * Enables Conversations in all Policies.
     */
    public static void enableConversationsInAllPolicies() {
        try {
            setConversationsEnabled(true);
            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.CONFIRM,
                    'Conversations enabled in all policies'));
        } catch (FailedPolicyUpdateException ex) {
            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.WARNING,
                    ex.getMessage()));
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'Failed to enable Conversations in all policies'));
        }
    }

    /**
     * Disables Conversations in all Policies.
     */
    public static void disableConversationsInAllPolicies() {
        try {
            setConversationsEnabled(false);
            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.CONFIRM,
                    'Conversations disabled in all policies'));
        } catch (FailedPolicyUpdateException ex) {
            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.WARNING,
                    ex.getMessage()));
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'Failed to disable Conversations in all policies'));
        }
    }

    /**
     * Enables Objectives in all Policies.
     */
    public static void enableObjectivesInAllPolicies() {
        try {
            setObjectivesEnabled(true);
            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.CONFIRM,
                    'Objectives enabled in all policies'));
        } catch (FailedPolicyUpdateException ex) {
            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.WARNING,
                    ex.getMessage()));
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'Failed to enable Objectives in all policies'));
        }
    }

    /**
     * Disables Objectives in all Policies.
     */
    public static void disableObjectivesInAllPolicies() {
        try {
            setObjectivesEnabled(false);
            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.CONFIRM,
                    'Objectives disabled in all policies'));
        } catch (FailedPolicyUpdateException ex) {
            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.WARNING,
                    ex.getMessage()));
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'Failed to disable Objectives in all policies'));
        }
    }

    public String getCategoryPlaceholder() {
        return Label.Configure_Category_Placeholder;
    }

    public String getCompanyObjectivePlaceholder() {
        return Label.Configure_Company_Objective_Placeholder;
    }

    public String getPriorityPlaceholder() {
        return Label.Configure_Priority_Placeholder;
    }

    public PageReference save() {
        upsert cfg;
        return null;
    }

}