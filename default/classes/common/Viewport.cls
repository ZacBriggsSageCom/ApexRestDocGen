/**
 * Wrapper around the HCM Viewport.
 *
 * This is valuable for a number of reasons:
 *
 * 1) Methods from the HCM Viewport can be supplemented, overridden or renamed,
 *     where the original functionality is sub-optimal, unintuitive or lacking.
 *
 * 2) It is easy to see what functionality we are relying on from the HCM
 *     Viewport.
 *
 * 3) We can easily change the functionality later, if required, without
 *     requiring changes to HCM.
 */
public class Viewport {

    // The internal HCM Viewport
    private fHCM2.Viewport viewport { private get; private set; }

    private fHCM2__Policy__c viewerPolicy;

    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Constructs a Viewport with no subject.
     *
     * In this case, HCM sets the subject to be the viewer's Team Member.
     *
     * If the viewer has no Team Member, it will fall back to the CEO, or if no
     * CEO, then basically an arbitrary Team Member.
     */
    public Viewport() {
        this.viewport = new fHCM2.Viewport(null);
    }

    /**
     * Constructs a Viewport with a subject.
     *
     * @param subjectId The Team Member ID of the subject.
     */
    public Viewport(Id subjectId) {
        this.viewport = new fHCM2.Viewport(subjectId);
    }

    /**
     * Constructs a Viewport to wrap an fHCM2.Viewport.
     */
    public Viewport(fHCM2.Viewport viewport) {
        this.viewport = viewport;
    }

    ////////////////////////////////////////////////////////////////////////////
    // General
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Gets the underlying fHCM2.Viewport.
     */
    public fHCM2.Viewport getHcmViewport() {
        return viewport;
    }

    /**
     * Return a string representing the relationship of viewer -> subject.
     */
    public String getRelationshipType() {
        if (isTeamMember()) {
            return TeamMemberUtils.SELF;
        } else if (isManager()) {
            return TeamMemberUtils.MANAGER;
        }
        return null;
    }

    /**
     * Gets the Id of the viewer's Team Member.
     */
    public Id getViewerTeamMemberId() {
        return viewport.viewerId;
    }

    /**
     * Determines if the viewer is associated with a Team Member.
     */
    public Boolean isTeamMember() {
        return viewport.isTeamMember;
    }

    /**
     * Determines if the viewer is the subject's manager.
     */
    public Boolean isManager() {
        return viewport.isPrimaryManager;
    }

    /**
     * Determines if the viewer is the subject's cross-reporting manager.
     */
    public Boolean isCrossReportingManager() {
        return viewport.isCrossReportManager;
    }

    /**
     * Determines if the viewer is the subject's higher manager.
     */
    public Boolean isHigherManager() {
        return viewport.isHigherManager;
    }

    /**
     * Determines if the viewer is the subject's colleague.
     */
    public Boolean isColleague() {
        return viewport.isColleague;
    }

    /**
     * Determines if the viewer has any direct reports.
     */
    public Boolean hasDirectReports() {
        return viewport.hasDirectReports;
    }

    /**
     * Gets the viewer's Policy (all fields).
     */
    public fHCM2__Policy__c getViewerPolicy() {
        if (viewerPolicy == null) {
            // HCM's Viewport only queries a handful of fields for the viewer
            // policy, so we need to do our own query here.
            viewerPolicy = PolicyRepository.getViewerPolicy(
                    viewport.viewerPolicy.Id);
        }
        return viewerPolicy;
    }

    /**
     * Gets the subject's Policy (all fields).
     */
    public fHCM2__Policy__c getSubjectPolicy() {
        // HCM's Viewport queries all policy fields for the subject policy.
        // Despite the name, this will use the Team Member's Policy__c field
        // rather than the department policy, if set.
        return viewport.departmentPolicy;
    }

    /**
     * Gets the ID of the subject's manager from HCM.
     */
    public Id getManagerId() {
        return viewport.primaryManager == null
                ? null
                : viewport.primaryManager.id;
    }

    /**
     * Gets the IDs of all the subject's direct reports from HCM.
     *
     * This will filter out Team Members who:
     *  - Have left
     *  - Are pre-boarders
     *  - Have an Employment status that is configured as hidden
     */
    public Set<Id> getDirectReportIds() {
        Set<Id> directReportIds = new Set<Id>();
        for (fHCM2.Viewport.Person directReport : viewport.directReports) {
            directReportIds.add(directReport.id);
        }
        return directReportIds;
    }

    ////////////////////////////////////////////////////////////////////////////
    // Conversations
    ////////////////////////////////////////////////////////////////////////////

    public Boolean canViewerEditFeedback() {
        return getViewerPolicy().Allow_Edit_Feedback__c == true;
    }

}