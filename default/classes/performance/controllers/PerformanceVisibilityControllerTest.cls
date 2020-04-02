@isTest
public class PerformanceVisibilityControllerTest {

    ////////////////////////////////////////////////////////////////////////////
    // Setup
    ////////////////////////////////////////////////////////////////////////////

    @TestSetup
    private static void setup() {

        fHCM2__Policy__c managerPolicy = new fHCM2__Policy__c(
            Name = 'Manager Policy',
            Conversations_Is_Active__c = false,
            Objectives_Is_Active__c = false
        );
        fHCM2__Policy__c tmPolicy = new fHCM2__Policy__c(
            Name = 'Direct Report Policy',
            Conversations_Is_Active__c = false,
            Objectives_Is_Active__c = false
        );
        insert new List<fHCM2__Policy__c> { managerPolicy, tmPolicy };

        fHCM2__Team_Member__c manager = new fHCM2__Team_Member__c(
            Name = 'Manager',
            fHCM2__Policy__c = managerPolicy.Id
        );
        insert manager;

        fHCM2__Team_Member__c directReport = new fHCM2__Team_Member__c(
            Name = 'Direct Report',
            fHCM2__Policy__c = tmPolicy.Id,
            fHCM2__Manager__c = manager.Id
        );
        insert directReport;
    }

    ////////////////////////////////////////////////////////////////////////////
    // Data
    ////////////////////////////////////////////////////////////////////////////

    private static fHCM2__Policy__c getManagerPolicy() {
        return [
            SELECT Id
            FROM fHCM2__Policy__c
            WHERE Name = 'Manager Policy'
        ];
    }

    private static fHCM2__Policy__c getDirectReportPolicy() {
        return [
            SELECT Id
            FROM fHCM2__Policy__c
            WHERE Name = 'Direct Report Policy'
        ];
    }

    private static fHCM2__Team_Member__c getManager() {
        return [
            SELECT Id
            FROM fHCM2__Team_Member__c
            WHERE Name = 'Manager'
        ];
    }

    private static fHCM2__Team_Member__c getDirectReport() {
        return [
            SELECT Id
            FROM fHCM2__Team_Member__c
            WHERE Name = 'Direct Report'
        ];
    }

    ////////////////////////////////////////////////////////////////////////////
    // Tests
    ////////////////////////////////////////////////////////////////////////////

    @isTest
    private static void testProcessNotVisibleForTeam() {

        // GIVEN I am a manager looking at myself
        fHCM2.Viewport view = new fHCM2.Viewport(getManager().Id);

        // WHEN trying to view the process from the team view
        PerformanceVisibilityController ctrl =
                new PerformanceVisibilityController();
        Boolean visible = ctrl.isProcessVisible(view, null, 'Team');

        // THEN it is not visible
        System.assert(!visible);
    }

    @isTest
    private static void testProcessNotVisibleForSubjectWithoutConversations() {

        // GIVEN I am a manager looking at my direct report
        // AND no features of Performance Management are enabled
        fHCM2.Viewport view = new fHCM2.Viewport(getManager().Id);

        // WHEN trying to view the process
        PerformanceVisibilityController ctrl =
                new PerformanceVisibilityController();
        Boolean visible = ctrl.isProcessVisible(view, null, 'Team Member');

        // THEN it is not visible
        System.assert(!visible);
    }

    @isTest
    private static void testProcessVisibleForSubjectWithConversations() {

        // GIVEN Conversations is enabled in my direct report's policy
        fHCM2__Policy__c subjectPolicy = getDirectReportPolicy();
        subjectPolicy.Conversations_Is_Active__c = true;
        update subjectPolicy;

        // AND I am a manager looking at this direct report
        fHCM2.Viewport view = new fHCM2.Viewport(getDirectReport().Id);

        // WHEN trying to view the process
        PerformanceVisibilityController ctrl =
                new PerformanceVisibilityController();
        Boolean visible = ctrl.isProcessVisible(view, null, 'Team Member');

        // THEN it is visible
        System.assert(visible);
    }

}