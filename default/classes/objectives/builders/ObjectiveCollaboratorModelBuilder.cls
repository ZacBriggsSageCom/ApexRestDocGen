/**
 * Helper for building ObjectiveCollaboratorModels from various sources.
 */
public class ObjectiveCollaboratorModelBuilder {

    /**
     * Builds models from a list of junction objects.
     */
    public static List<ObjectiveCollaboratorModel> build(
            List<Objective_Collaborator__c> junctions) {

        Set<Id> tmIds = new Set<Id>();
        for (Objective_Collaborator__c junction : junctions) {
            tmIds.add(junction.Team_Member__c);
        }
        return build(junctions, TeamMemberRepository.get(tmIds));
    }

    /**
     * Builds models from junction objects and their related Team Members.
     */
    public static List<ObjectiveCollaboratorModel> build(
            List<Objective_Collaborator__c> junctions, List<fHCM2__Team_Member__c> tms) {

        Map<Id, fHCM2__Team_Member__c> tmsById = new Map<Id, fHCM2__Team_Member__c>(tms);
        List<ObjectiveCollaboratorModel> models = new List<ObjectiveCollaboratorModel>();
        for (Objective_Collaborator__c junction : junctions) {
            models.add(build(
                    junction.Objective__c,
                    junction.Access_Type__c,
                    tmsById.get(junction.Team_Member__c)));
        }
        return models;
    }

    /**
     * Builds a model given an objective ID, an access type and a Team Member.
     */
    public static ObjectiveCollaboratorModel build(
            Id objectiveId, String accessType, fHCM2__Team_Member__c tm) {

        ObjectiveCollaboratorModel model = new ObjectiveCollaboratorModel();
        model.accessType = accessType;
        model.objectiveId = objectiveId;
        model.person = TeamMemberUtils.createPerson(tm);
        return model;
    }
}