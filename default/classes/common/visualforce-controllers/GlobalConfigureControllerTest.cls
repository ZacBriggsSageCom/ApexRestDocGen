/**
 * Test class exercising the Performance Management Global Config Page controller.
 */
@isTest
public class GlobalConfigureControllerTest {

    @isTest
    private static void testEnableConversations() {

        // GIVEN a Policy which does not have Conversations enabled
        fHCM2__Policy__c pol = new fHCM2__Policy__c(
            Conversations_Is_Active__c = false
        );
        insert pol;

        // WHEN I enable Conversations in all Policies
        GlobalConfigureController.enableConversationsInAllPolicies();

        // THEN it gets enabled
        List<fHCM2__Policy__c> pols = PolicyRepository.getAllPolicies();
        System.assertEquals(1, pols.size());
        System.assertEquals(true, pols.get(0).Conversations_Is_Active__c);

        // AND a confirmation message is added
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size());
        System.assertEquals(ApexPages.Severity.CONFIRM, messages[0].getSeverity());
    }

    @isTest
    private static void testDisableConversations() {

        // GIVEN a Policy which has Conversations enabled
        fHCM2__Policy__c pol = new fHCM2__Policy__c(
            Conversations_Is_Active__c = true
        );
        insert pol;

        // WHEN I disable Conversations in all Policies
        GlobalConfigureController.disableConversationsInAllPolicies();

        // THEN it gets disabled
        List<fHCM2__Policy__c> pols = PolicyRepository.getAllPolicies();
        System.assertEquals(1, pols.size());
        System.assertEquals(false, pols.get(0).Conversations_Is_Active__c);

        // AND a confirmation message is added
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size());
        System.assertEquals(ApexPages.Severity.CONFIRM, messages[0].getSeverity());
    }

    @isTest
    private static void testEnableObjectives() {

        // GIVEN a Policy which does not have Objectives enabled
        fHCM2__Policy__c pol = new fHCM2__Policy__c(
            Conversations_Is_Active__c = true,
            Objectives_Is_Active__c = false
        );
        insert pol;

        // WHEN I enable Objectives in all Policies
        GlobalConfigureController.enableObjectivesInAllPolicies();

        // THEN it gets enabled
        List<fHCM2__Policy__c> pols = PolicyRepository.getAllPolicies();
        System.assertEquals(1, pols.size());
        System.assertEquals(true, pols.get(0).Objectives_Is_Active__c);

        // AND a confirmation message is added
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size());
        System.assertEquals(ApexPages.Severity.CONFIRM, messages[0].getSeverity());
    }

    @isTest
    private static void testDisableObjectives() {

        // GIVEN a Policy which has Objectives enabled
        fHCM2__Policy__c pol = new fHCM2__Policy__c(
            Conversations_Is_Active__c = true,
            Objectives_Is_Active__c = true
        );
        insert pol;

        // WHEN I disable Objectives in all Policies
        GlobalConfigureController.disableObjectivesInAllPolicies();

        // THEN it gets disabled
        List<fHCM2__Policy__c> pols = PolicyRepository.getAllPolicies();
        System.assertEquals(1, pols.size());
        System.assertEquals(false, pols.get(0).Objectives_Is_Active__c);

        // AND a confirmation message is added
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size());
        System.assertEquals(ApexPages.Severity.CONFIRM, messages[0].getSeverity());
    }

    @isTest
    private static void testCannotDisableConversationsIfObjectivesEnabled() {

        // GIVEN a Policy which has Objectives enabled
        fHCM2__Policy__c pol = new fHCM2__Policy__c(
            Conversations_Is_Active__c = true,
            Objectives_Is_Active__c = true
        );
        insert pol;

        // WHEN I disable Conversations in all Policies
        GlobalConfigureController.disableConversationsInAllPolicies();

        // THEN it does not get disabled
        List<fHCM2__Policy__c> pols = PolicyRepository.getAllPolicies();
        System.assertEquals(1, pols.size());
        System.assertEquals(true, pols.get(0).Conversations_Is_Active__c);

        // AND a warning is added
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size());
        System.assertEquals(ApexPages.Severity.WARNING, messages[0].getSeverity());
    }

    @isTest
    private static void testCannotEnableObjectivesWithoutConversations() {

        // GIVEN a Policy which does not have Conversations enabled
        fHCM2__Policy__c pol = new fHCM2__Policy__c(
            Conversations_Is_Active__c = false,
            Objectives_Is_Active__c = false
        );
        insert pol;

        // WHEN I enable Objectives in all Policies
        GlobalConfigureController.enableObjectivesInAllPolicies();

        // THEN it does not get enabled
        List<fHCM2__Policy__c> pols = PolicyRepository.getAllPolicies();
        System.assertEquals(1, pols.size());
        System.assertEquals(false, pols.get(0).Objectives_Is_Active__c);

        // AND a warning is added
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size());
        System.assertEquals(ApexPages.Severity.WARNING, messages[0].getSeverity());
    }

    @isTest
    private static void testCanDisableConversations_AlreadyDisabled() {
        // GIVEN a Policy which has Conversations already disabled
        fHCM2__Policy__c pol = new fHCM2__Policy__c(
            Conversations_Is_Active__c = false
        );
        // THEN Conversations can be disabled
        System.assertEquals(true,
            GlobalConfigureController.canDisableConversations(pol));
    }

    @isTest
    private static void testCanDisableConversations_ObjectivesDisabled() {
        // GIVEN a Policy which has Objectives disabled
        fHCM2__Policy__c pol = new fHCM2__Policy__c(
            Conversations_Is_Active__c = true
        );
        // THEN Conversations can be disabled
        System.assertEquals(true,
            GlobalConfigureController.canDisableConversations(pol));
    }

    @isTest
    private static void testCanDisableConversations_ObjectivesEnabled() {
        // GIVEN a Policy which has Objectives enabled
        fHCM2__Policy__c pol = new fHCM2__Policy__c(
            Conversations_Is_Active__c = true,
            Objectives_Is_Active__c = true
        );
        // THEN Conversations cannot be disabled
        System.assertEquals(false,
            GlobalConfigureController.canDisableConversations(pol));
    }

    @isTest
    private static void testCanEnableObjectives_AlreadyEnabled() {
        // GIVEN a Policy which has Objectives already enabled
        fHCM2__Policy__c pol = new fHCM2__Policy__c(
            Conversations_Is_Active__c = true,
            Objectives_Is_Active__c = true
        );
        // THEN Objectives can be enabled
        System.assertEquals(true,
            GlobalConfigureController.canEnableObjectives(pol));
    }

    @isTest
    private static void testCanEnableObjectives_ConversationsEnabled() {
        // GIVEN a Policy which has Conversations enabled
        fHCM2__Policy__c pol = new fHCM2__Policy__c(
            Conversations_Is_Active__c = true,
            Objectives_Is_Active__c = false
        );
        // THEN Objectives can be enabled
        System.assertEquals(true,
            GlobalConfigureController.canEnableObjectives(pol));
    }

    @isTest
    private static void testCanEnableObjectives_ConversationsDisabled() {
        // GIVEN a Policy which has Conversations disabled
        fHCM2__Policy__c pol = new fHCM2__Policy__c(
            Conversations_Is_Active__c = false,
            Objectives_Is_Active__c = false
        );
        // THEN Objectives cannot be enabled
        System.assertEquals(false,
            GlobalConfigureController.canEnableObjectives(pol));
    }

}