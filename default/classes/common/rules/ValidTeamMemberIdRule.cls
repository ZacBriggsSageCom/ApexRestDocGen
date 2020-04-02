/**
 * Validation rule for determining whether a Team Member Id is valid.
 */
public class ValidTeamMemberIdRule extends ValidIdRule {

    public ValidTeamMemberIdRule(String teamMemberId) {
        super(teamMemberId, Label.Error_Team_Member_Id_Invalid);
    }

    public override Boolean isValid() {
        return super.isValid()
                && SObjectUtils.isOfType(recordId, TeamMemberUtils.TEAM_MEMBER_TYPE);
    }
}
