@isTest
public class GlobalConfigControllerTest {

    ////////////////////////////////////////////////////////////////////////////
    // Setup
    ////////////////////////////////////////////////////////////////////////////

    @TestSetup
    private static void setup() {
        // User always needs an associated Team Member!
        fHCM2__Team_Member__c me = new fHCM2__Team_Member__c(
            fHCM2__User__c = UserInfo.getUserId()
        );
        insert me;
    }

    ////////////////////////////////////////////////////////////////////////////
    // Data
    ////////////////////////////////////////////////////////////////////////////

    private static fHCM2__Team_Member__c getLoggedInTeamMember() {
        return [SELECT Id FROM fHCM2__Team_Member__c LIMIT 1];
    }

    ////////////////////////////////////////////////////////////////////////////
    // Tests
    ////////////////////////////////////////////////////////////////////////////

    @isTest
    private static void testGetGlobalConfig() {

        // WHEN I get the Global Configuration
        GlobalConfigResponseModel resp =
                GlobalConfigController.getGlobalConfig();

        // THEN a value is returned
        System.assertNotEquals(null, resp.cfg);

        // AND the picklist options therein have some value
        System.assertNotEquals(null, resp.cfg.companyObjectiveOptions);
        System.assertNotEquals(null, resp.cfg.objectiveCategoryOptions);
        System.assertNotEquals(null, resp.cfg.objectivePriorityOptions);
    }

    @isTest
    private static void testCreateSelectOptions() {

        // WHEN I call `createSelectOptions` with a multi-line String
        List<OptionModel> options =
                GlobalConfigController.createSelectOptions('A\r\nB\r\nC');

        // THEN a SelectDTO is created for each line
        System.assertEquals(3, options.size());
        System.assertEquals('A', options[0].name);
        System.assertEquals('B', options[1].name);
        System.assertEquals('C', options[2].name);
    }

    @isTest
    private static void testCreateSelectOptions_Null() {

        // WHEN I call `createSelectOptions` with a null value
        List<OptionModel> options =
                GlobalConfigController.createSelectOptions(null);

        // THEN an empty list is returned
        System.assertEquals(0, options.size());
    }

    @isTest
    private static void testCreateSelectOptions_Empty() {

        // WHEN I call `createSelectOptions` with an empty String
        List<OptionModel> options =
                GlobalConfigController.createSelectOptions('');

        // THEN an empty list is returned
        System.assertEquals(0, options.size());
    }

    @isTest
    private static void testCreatePolicyModels_NoDirectReports() {

        // GIVEN I have no direct reports
        fHCM2__Policy__c pol = new fHCM2__Policy__c();
        insert pol;

        fHCM2__Team_Member__c manager = getLoggedInTeamMember();
        manager.fHCM2__Policy__c = pol.Id;
        update manager;

        // WHEN getting the list of PolicyModels
        List<PolicyModel> policyModels =
                GlobalConfigController.createPolicyModels();

        // THEN only one PolicyModel is returned, for myself
        System.assertEquals(1, policyModels.size());
        System.assertEquals(pol.Id, policyModels.get(0).policyId);
    }

    @isTest
    private static void testCreatePolicyModels() {

        // GIVEN I am a manager with direct reports on different policies
        fHCM2__Policy__c pol1 = new fHCM2__Policy__c();
        fHCM2__Policy__c pol2 = new fHCM2__Policy__c();
        fHCM2__Policy__c pol3 = new fHCM2__Policy__c();
        insert new List<fHCM2__Policy__c> { pol1, pol2, pol3 };

        fHCM2__Team_Member__c manager = getLoggedInTeamMember();
        manager.fHCM2__Policy__c = pol1.Id;
        update manager;

        fHCM2__Team_Member__c dr1 = new fHCM2__Team_Member__c(
            fHCM2__Manager__c = manager.Id,
            fHCM2__Policy__c = pol2.Id
        );
        fHCM2__Team_Member__c dr2 = new fHCM2__Team_Member__c(
            fHCM2__Manager__c = manager.Id,
            fHCM2__Policy__c = pol2.Id // intentional duplicate
        );
        fHCM2__Team_Member__c dr3 = new fHCM2__Team_Member__c(
            fHCM2__Manager__c = manager.Id,
            fHCM2__Policy__c = pol3.Id
        );
        insert new List<fHCM2__Team_Member__c> { dr1, dr2, dr3 };

        // WHEN getting the list of PolicyModels
        List<PolicyModel> policyModels =
                GlobalConfigController.createPolicyModels();

        // THEN a PolicyModel is returned for each unique policy
        System.assertEquals(3, policyModels.size());
        List<Id> policyIds = new List<Id> { pol1.Id, pol2.Id, pol3.Id };
        for (Id policyId : policyIds) {
            Boolean found = false;
            for (PolicyModel policyModel : policyModels) {
                if (policyId == policyModel.policyId) {
                    found = true;
                }
            }
            System.assert(found);
        }
    }

}