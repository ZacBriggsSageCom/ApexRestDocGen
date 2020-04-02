/**
 * Class that controls the visibility of the Performance Management process.
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global class PerformanceVisibilityController
        implements fHCM2.StandaloneAppVisibilityController {

    @TestVisible
    private static final String TEAM_TM = 'Team Member';

    /**
     * Determines if a Performance Management process instance should be visible.
     *
     * @param view
     * @param record
     * @param team The current team being viewed.
     *
     * One of:
     *  - Team Member
     *  - All Reports
     *  - Direct Reports
     *  - Cross Reports
     *  - Actions Digest
     */
    global Boolean isProcessVisible(
            fHCM2.Viewport hcmViewport,
            fHCM2__Process_Instance__c record,
            String team) {

        // Process only supported for Team Member view
        if (team != TEAM_TM) {
            return false;
        }

        Viewport view = new Viewport(hcmViewport);
        fHCM2__Policy__c subjectPolicy = view.getSubjectPolicy();

        // Process should only be available if one of the new features is
        // enabled in the subject policy
        return subjectPolicy.Conversations_Is_Active__c == true
                || subjectPolicy.Objectives_Is_Active__c == true;
    }

}