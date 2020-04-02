@isTest
public class ViewportTest {

    @isTest
    private static void testCanViewerEditFeedback_EditNotAllowed() {

        // GIVEN a department policy that does not allow editing Feedback
        fHCM2__Policy__c pol = new fHCM2__Policy__c(
            Allow_Edit_Feedback__c = false
        );
        insert pol;
        fHCM2__Department__c dept = new fHCM2__Department__c(
            fHCM2__Policy__c = pol.Id
        );
        insert dept;

        // AND the viewer is a Team Member in this department
        fHCM2__Team_Member__c tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setName('Deepti Harish')
                .setUser(UserInfo.getUserId())
                .setDepartment(dept.Id)
                .build();

        // WHEN checking whether this Team Member can edit feedback
        // THEN they cannot
        Viewport view = new Viewport(tm.Id);
        System.assertEquals(false, view.canViewerEditFeedback());
    }

    @isTest
    private static void testCanViewerEditFeedback_EditAllowedByDepartmentPolicy() {

        // GIVEN a department policy that allows editing Feedback
        fHCM2__Policy__c pol = new fHCM2__Policy__c(
            Allow_Edit_Feedback__c = true
        );
        insert pol;
        fHCM2__Department__c dept = new fHCM2__Department__c(
            fHCM2__Policy__c = pol.Id
        );
        insert dept;

        // AND the viewer is a Team Member in this department
        fHCM2__Team_Member__c tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setName('Deepti Harish')
                .setUser(UserInfo.getUserId())
                .setDepartment(dept.Id)
                .build();

        // WHEN checking whether this Team Member can edit feedback
        // THEN they can
        Viewport view = new Viewport(tm.Id);
        System.assertEquals(true, view.canViewerEditFeedback());
    }

    @isTest
    private static void testCanViewerEditFeedback_EditAllowedByTmPolicy() {

        // GIVEN a policy that allows editing Feedback
        fHCM2__Policy__c pol = new fHCM2__Policy__c(
            Allow_Edit_Feedback__c = true
        );
        insert pol;

        // AND the viewer is a Team Member with this policy
        fHCM2__Team_Member__c tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setName('Deepti Harish')
                .setUser(UserInfo.getUserId())
                .setPolicy(pol.Id)
                .build();

        // WHEN checking whether this Team Member can edit feedback
        // THEN they can
        Viewport view = new Viewport(tm.Id);
        System.assertEquals(true, view.canViewerEditFeedback());
    }

    @isTest
    private static void testCanViewerEditFeedback_TmPolicyOverridesDepartment() {

        // GIVEN a department policy that does not allow editing Feedback
        fHCM2__Policy__c polWithoutEditing = new fHCM2__Policy__c(
            Allow_Edit_Feedback__c = false
        );
        insert polWithoutEditing;
        fHCM2__Department__c dept = new fHCM2__Department__c(
            fHCM2__Policy__c = polWithoutEditing.Id
        );
        insert dept;

        // AND a second policy that allows editing Feedback
        fHCM2__Policy__c polWithEditing = new fHCM2__Policy__c(
            Allow_Edit_Feedback__c = true
        );
        insert polWithEditing;

        // AND the viewer is a Team Member in this department,
        // with the department policy overridden
        fHCM2__Team_Member__c tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setName('Deepti Harish')
                .setUser(UserInfo.getUserId())
                .setPolicy(polWithEditing.Id)
                .setDepartment(dept.Id)
                .build();

        // WHEN checking whether this Team Member can edit feedback
        // THEN they can
        Viewport view = new Viewport(tm.Id);
        System.assertEquals(true, view.canViewerEditFeedback());
    }

}