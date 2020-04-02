/**
 * Helper for building ObjectiveModels from Objective__c records.
 */
public class ObjectiveModelBuilder {

    /**
     * Given a list of Objective__c records, builds a list of ObjectiveModels.
     */
    public static List<ObjectiveModel> build(List<Objective__c> objectives) {

        // Build creator models
        Set<Id> creatorUsers = new Set<Id>();
        for (Objective__c objective : objectives) {
            creatorUsers.add(objective.CreatedById);
        }

        // Locate conversations
        Map<Id, Objective__c> objectivesById = new Map<Id, Objective__c>(objectives);
        Map<Id, Id> conversationsByObjectiveId =
                ObjectiveUtils.getConversationIds(objectivesById.keySet());

        // Find team member records for creators
        List<fHCM2__Team_Member__c> creators =
                TeamMemberRepository.getTeamMembersForUsers(creatorUsers);

        // Find collaborators
        Map<Id, List<ObjectiveCollaboratorModel>> collaborators =
                ObjectiveCollaboratorUtils.getCollaboratorsFor(objectives);

        // Match creators to objectives
        Map<Objective__c, fHCM2__Team_Member__c> creatorsByObjective =
                new Map<Objective__c, fHCM2__Team_Member__c>();
        for (Objective__c objective : objectives) {
            for (fHCM2__Team_Member__c creator : creators) {
                if (objective.CreatedById == creator.fHCM2__User__c) {
                    creatorsByObjective.put(objective, creator);
                }
            }
        }

        // Build models
        List<ObjectiveModel> models = new List<ObjectiveModel>();
        for (Objective__c objective : objectives) {
            models.add(build(
                    objective,
                    creatorsByObjective.get(objective),
                    collaborators.get(objective.Id),
                    conversationsByObjectiveId.get(objective.Id)
            ));
        }
        return models;
    }

    /**
     * Given an Objective__c record, builds an ObjectiveModel.
     */
    public static ObjectiveModel build(Objective__c objective) {
        return build(
                objective,
                TeamMemberRepository.getTeamMemberForUser(objective.CreatedById),
                ObjectiveCollaboratorUtils.getCollaboratorsFor(objective),
                ObjectiveUtils.getConversationId(objective.Id)
        );
    }

    /**
     * Builds an ObjectiveModel from its components:
     *  - Objective record
     *  - Creator
     *  - Collaborators
     *  - Conversation ID
     */
    public static ObjectiveModel build(
            Objective__c objective,
            fHCM2__Team_Member__c creator,
            List<ObjectiveCollaboratorModel> collaborators,
            Id conversationId) {

        ObjectiveModel model = new ObjectiveModel();

        model.id = objective.Id;
        model.conversationId = conversationId;
        model.title = objective.Title__c;
        model.status = objective.Status__c;
        model.tmId = objective.Team_Member__c;
        model.priority = objective.Priority__c;
        model.category = objective.Category__c;
        model.companyObjective = objective.Company_Objective__c;
        model.visibility = objective.Visibility__c;
        model.description = objective.Description__c;
        model.creator = TeamMemberUtils.createPerson(creator);
        model.endDate = DateUtils.datetimeToStringInUserTimeZone(objective.End_Date__c);
        model.createdDate = DateUtils.datetimeToStringInUserTimeZone(objective.Created_Date__c);
        model.closedDate = DateUtils.datetimeToStringInUserTimeZone(objective.Closed_Date__c);
        model.reviewDate = DateUtils.datetimeToStringInUserTimeZone(objective.Review_Date__c);
        model.tasks = TaskModelBuilder.buildTasks(objective.Tasks__r);
        model.collaborators = collaborators;

        return model;
    }

}