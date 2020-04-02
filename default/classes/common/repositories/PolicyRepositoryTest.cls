/**
 * Tests exercising methods for dealing with Policy objects.
 */
@isTest
public class PolicyRepositoryTest {

    private static fHCM2__Policy__c pol;

    private static void setUp() {
        pol = new fHCM2__Policy__c(
            Conversations_Is_Active__c = true,
            Allow_Edit_Feedback__c = true,
            Objectives_Is_Active__c = true
        );
        insert pol;
    }

    @isTest
    private static void testGetPolicyForPolicyPage() {

        // GIVEN the Id of a Policy
        setUp();

        // WHEN I get the object itself
        fHCM2__Policy__c policy = PolicyRepository.getPolicyForPolicyPage(pol.Id);

        // THEN it has the expected properties
        System.assertNotEquals(null, policy);
        System.assertEquals(true, policy.Conversations_Is_Active__c);
        System.assertEquals(true, policy.Allow_Edit_Feedback__c);
        System.assertEquals(true, policy.Objectives_Is_Active__c);
    }

    @isTest
    private static void testGetPolicyForPolicyPageWhenPolicyDoesNotExist() {

        // GIVEN the Id of a Policy which does not exist
        setUp();
        delete pol;

        // WHEN I try to get the object itself
        // THEN I receive nothing
        System.assertEquals(null, PolicyRepository.getPolicyForPolicyPage(pol.Id));
    }

    @isTest
    private static void testGetViewerPolicy() {

        // GIVEN the Id of a Policy
        setUp();

        // WHEN I get the object itself
        fHCM2__Policy__c policy = PolicyRepository.getViewerPolicy(pol.Id);

        // THEN it has the expected properties
        System.assertNotEquals(null, policy);
        System.assertEquals(true, policy.Allow_Edit_Feedback__c);
    }

    @isTest
    private static void testGetViewerPolicyWhenPolicyDoesNotExist() {

        // GIVEN the Id of a Policy which does not exist
        setUp();
        delete pol;

        // WHEN I try to get the object itself
        // THEN I receive nothing
        System.assertEquals(null, PolicyRepository.getViewerPolicy(pol.Id));
    }

    @isTest
    private static void testGetAllPolicies() {

        // GIVEN a Policy
        setUp();

        // WHEN I get all Policies in the org
        List<fHCM2__Policy__c> policies = PolicyRepository.getAllPolicies();

        // THEN I receive a list of one
        System.assertEquals(1, policies.size());

        // AND it has the expected properties
        System.assertEquals(true, policies.get(0).Conversations_Is_Active__c);
        System.assertEquals(true, policies.get(0).Allow_Edit_Feedback__c);
        System.assertEquals(true, policies.get(0).Objectives_Is_Active__c);
    }
}