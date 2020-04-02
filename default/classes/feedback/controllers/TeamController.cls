/**
 * Logic for retrieving subjects.
 */
public class TeamController {

    public static ConversationSelectionsResponseModel getTeam() {

        // Get the Team Member for the logged-in User
        fHCM2__Team_Member__c currentTm =
                TeamMemberRepository.getTeamMemberForUser(UserInfo.getUserId());
        if (currentTm == null) {
            return new ConversationSelectionsResponseModel(new ErrorModel(
                HttpUtils.STATUS_FORBIDDEN,
                Label.Error_No_Team_Member_For_User,
                ''
            ));
        }

        // Determine the IDs of everyone in the team
        Viewport view = new Viewport(currentTm.Id);
        Id selfId = currentTm.Id;
        Id managerId = view.getManagerId();
        Set<Id> directReportIds = view.getDirectReportIds();
        Set<Id> allTmIds = new Set<Id> { selfId };
        if (managerId != null) {
            allTmIds.add(managerId);
        }
        allTmIds.addAll(directReportIds);

        // Retrieve the details we need for these Team Members
        List<fHCM2__Team_Member__c> tms =
                TeamMemberRepository.get(allTmIds);
        Map<Id, fHCM2__Team_Member__c> tmsById =
                new Map<Id, fHCM2__Team_Member__c>(tms);

        // Create selection models for each Team Member
        List<ConversationSelectionModel> team = new List<ConversationSelectionModel>();

        // Self
        fHCM2__Team_Member__c self = tmsById.get(selfId);
        PersonModel selfModel = TeamMemberUtils.createPerson(self);
        selfModel.relationship = TeamMemberUtils.SELF;
        team.add(new ConversationSelectionModel(selfModel));

        // Manager
        if (managerId != null) {
            fHCM2__Team_Member__c manager = tmsById.get(managerId);
            PersonModel managerModel = TeamMemberUtils.createPerson(manager);
            managerModel.relationship = TeamMemberUtils.MANAGER;
            team.add(new ConversationSelectionModel(
                ConversationUtils.findTmConversationBetween(selfId, managerId),
                managerModel
            ));
        }

        // Direct Reports
        Map<Id, Id> conversationsByTm =
                ConversationUtils.findConversationsWithParticipantForSubjects(
                        selfId, directReportIds);
        for (Id tmId : directReportIds) {
            fHCM2__Team_Member__c tm = tmsById.get(tmId);
            PersonModel report = TeamMemberUtils.createPerson(tm);
            report.relationship = TeamMemberUtils.DIRECT_REPORT;
            team.add(new ConversationSelectionModel(
                conversationsByTm.get(tmId), report));
        }

        // Create the response model
        return new ConversationSelectionsResponseModel(team);
    }

}