@isTest
public class ProcessDetailsControllerTest {

    private static fHCM2__Team_Member__c tm;
    private static fHCM2__Category__c service;
    private static fHCM2__Process_Instance__c procInstance;

    ////////////////////////////////////////////////////////////////////////////
    // Setup
    ////////////////////////////////////////////////////////////////////////////

    private static void setupTeamMember() {
        
        // Create a Policy
        fHCM2__Policy__c pol = new fHCM2__Policy__c(
            Name = 'Test Policy',
            fHCM2__Performance_Overview_Is_Active__c = true
        );
        insert pol;

        // Create a Team Member
        tm = new fHCM2__Team_Member__c(
                Name = 'Deepti',
                fHCM2__User__c = UserInfo.getUserId(),
                fHCM2__Policy__c = pol.Id
        );
        insert tm;
    }

    /**
     * Registers the Performance Overview process.
     */
    public static void registerProcess() {
        fHCM2.HCMProcesses.register('Performance Overview', 'FairsailProfile',
                'Performance_Overview_Is_Active__c',
                null, null, true, true, false, 4.5, false);
        fHCM2.HCMProcesses.saveRegistered();
    }

    /**
     * Creates a process instance for Performance Overview.
     */
    public static void createProcessInstance(fHCM2.Viewport view) {

        // Create the service
        service = new fHCM2__Category__c(
                Name = 'Test Service',
                fHCM2__Order__c = 0
        );
        insert service;

        // Create the process instance
        procInstance = new fHCM2__Process_Instance__c(
                fHCM2__Label__c = 'Performance Overview',
                fHCM2__Category__c = service.Id,
                fHCM2__Order__c = 0,
                fHCM2__Active__c = true,
                fHCM2__Process__c = 'Performance Overview'
        );
        insert procInstance;
    }

    ////////////////////////////////////////////////////////////////////////////
    // Tests
    ////////////////////////////////////////////////////////////////////////////

    @isTest
    private static void testGetPerformanceOverviewDetails_Success() {

        // GIVEN a Team Member with a Policy where Performance Overview is
        // enabled
        setupTeamMember();
        fHCM2.Viewport view = new fHCM2.Viewport(tm.Id);

        // AND a Performance Overview process has been configured
        registerProcess();
        createProcessInstance(view);

        // WHEN getting the process details
        ProcessDetailsResponseModel response =
                ProcessDetailsController.getPerformanceOverviewDetails(tm.Id);

        // THEN no error is returned
        System.assertEquals(null, response.error);

        // AND the process details are returned
        System.assertEquals(service.Id, response.serviceId);
        System.assertEquals(procInstance.Id, response.processId);
    }

    @isTest
    private static void testGetPerformanceOverviewDetails_NoProcessInstances() {

        // GIVEN a Team Member with a Policy where Performance Overview is
        // enabled, but no Performance Overview process exists
        setupTeamMember();

        // WHEN getting the process details
        ProcessDetailsResponseModel response =
                ProcessDetailsController.getPerformanceOverviewDetails(tm.Id);

        // THEN an error is returned
        System.assert(response.error != null);
        System.assertEquals(HttpUtils.STATUS_INTERNAL_SERVER_ERROR,
                response.error.statusCode);
        System.assertEquals('No Process Instances found!',
                response.error.error);
    }

}