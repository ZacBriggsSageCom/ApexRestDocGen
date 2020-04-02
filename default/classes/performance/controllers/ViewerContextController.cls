public class ViewerContextController {

    public static ViewerContextResponseModel getViewerContext() {
        fHCM2__Team_Member__c currentTm =
                TeamMemberRepository.getTeamMemberForUser(UserInfo.getUserId());

        if (currentTm == null) {
            return new ViewerContextResponseModel(new ErrorModel(
                HttpUtils.STATUS_FORBIDDEN,
                Label.Error_No_Team_Member_For_User,
                ''
            ));
        }

        Viewport view = new Viewport();

        ViewerContextModel data = ( ViewerContextModel) TeamMemberUtils.populatePersonModel(
                new ViewerContextModel(), currentTm);

        data.isManager = view.hasDirectReports();

        // Add model for viewer's manager
        if (view.getManagerId() != null) {
            data.manager = TeamMemberUtils.createPerson(view.getManagerId());
        }

        // Add models for viewer's direct reports, if any
        if (data.isManager) {
            // Collect direct reports
            List<fHCM2__Team_Member__c> directReports =
                    TeamMemberRepository.getDirectReports(currentTm.Id);
            data.directReports = TeamMemberUtils.createPeople(directReports);
        }
        return new ViewerContextResponseModel(data);
    }

}