public class ManagerDashboardController {

    public static ManagerDashboardResponseModel getDirectReportsDetails() {
        fHCM2__Team_Member__c currentTm =
                TeamMemberRepository.getTeamMemberForUser(UserInfo.getUserId());

        if (currentTm == null) {
            return new ManagerDashboardResponseModel(new ErrorModel(
                HttpUtils.STATUS_FORBIDDEN,
                Label.Error_No_Team_Member_For_User,
                ''
            ));
        }

        List<fHCM2__Team_Member__c> directReports =
                TeamMemberRepository.getDirectReports(currentTm.Id);

        if (directReports.isEmpty()) {
            System.debug('No direct reports for the Manager with Id: '+ currentTm.Id);
            return new ManagerDashboardResponseModel(new List<TeamMemberSummaryModel> ());
        }

        return new ManagerDashboardResponseModel(
                TeamMemberUtils.createTeamMemberSummary(directReports));
    }

}