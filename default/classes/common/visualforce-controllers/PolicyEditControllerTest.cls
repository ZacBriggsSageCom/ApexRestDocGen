@isTest
public class PolicyEditControllerTest {

    @isTest
    public static void testSave_ObjectivesAndConversationsEnabled() {

        // GIVEN a Policy with Objectives and Conversations enabled
        fHCM2__Policy__c pol = new fHCM2__Policy__c(
            Conversations_Is_Active__c = true,
            Objectives_Is_Active__c = true
        );
        insert pol;

        // WHEN I try to save this Policy
        ApexPages.StandardController stdCtrl =
                new ApexPages.StandardController(pol);
        PolicyEditController ctrl = new PolicyEditController(stdCtrl);
        PageReference pageRef = ctrl.save();

        // THEN no errors are added to the page
        ApexPages.Message[] errors = ApexPages.getMessages();
        System.assertEquals(0, errors.size());
    }

    @isTest
    public static void testSave_CantDisableConversationsIfObjectivesIsEnabled() {

        // GIVEN a Policy with Objectives and Conversations enabled
        fHCM2__Policy__c pol = new fHCM2__Policy__c(
            Conversations_Is_Active__c = true,
            Objectives_Is_Active__c = true
        );
        insert pol;

        // WHEN I try to disable Conversations
        pol.Conversations_Is_Active__c = false;
        ApexPages.StandardController stdCtrl =
                new ApexPages.StandardController(pol);
        PolicyEditController ctrl = new PolicyEditController(stdCtrl);
        PageReference pageRef = ctrl.save();

        // THEN no redirect is returned
        System.assertEquals(null, pageRef);

        // AND an error is added to the page
        ApexPages.Message[] errors = ApexPages.getMessages();
        System.assertEquals(1, errors.size());
        System.assertEquals(Label.Error_Cant_Disable_Conversations,
                errors[0].getSummary());
    }

    @isTest
    public static void testSave_CantEnableObjectivesWithoutConversations() {

        // GIVEN a Policy with Objectives enabled and Conversations disabled
        fHCM2__Policy__c pol = new fHCM2__Policy__c(
            Conversations_Is_Active__c = false,
            Objectives_Is_Active__c = true
        );
        insert pol;

        // WHEN I try to save this Policy
        ApexPages.StandardController stdCtrl =
                new ApexPages.StandardController(pol);
        PolicyEditController ctrl = new PolicyEditController(stdCtrl);
        PageReference pageRef = ctrl.save();

        // THEN no redirect is returned
        System.assertEquals(null, pageRef);

        // AND an error is added to the page
        ApexPages.Message[] errors = ApexPages.getMessages();
        System.assertEquals(1, errors.size());
        System.assertEquals(Label.Error_Objectives_Requires_Conversations,
                errors[0].getSummary());
    }

}