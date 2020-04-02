/**
 * Utility methods for working with objective collaborators.
 */
public class ObjectiveCollaboratorUtils {

    public static final String ACCESS_LEVEL_OWNER = 'Owner';

    /**
     * Creates collaborators for an objective.
     */
    public static List<ObjectiveCollaboratorModel> getCollaboratorsFor(
            Objective__c objective) {

        // Generate collaborator objects for subject and subject's manager
        List<ObjectiveCollaboratorModel> collaborators =
                createSubjectAndManagerCollaborators(
                        objective.Id,
                        TeamMemberRepository.get(objective.Team_Member__c),
                        TeamMemberRepository.getPrimaryManager(objective.Team_Member__c));

        // Add saved collaborators
        collaborators.addAll(ObjectiveCollaboratorModelBuilder.build(
                        ObjectiveCollaboratorRepository.getForObjective(objective.Id)));

        return collaborators;
    }

    /**
     * Creates collaborators for objectives in the form:
     *     Objective ID => List of ObjectiveCollaboratorModels
     */
    public static Map<Id, List<ObjectiveCollaboratorModel>> getCollaboratorsFor(
            List<Objective__c> objectives) {

        // Find subjects for objectives
        Map<Id, fHCM2__Team_Member__c> subjectsById =
                new Map<Id, fHCM2__Team_Member__c>(ObjectiveUtils.getSubjects(objectives));

        // Find these subjects' managers
        Map<Id, fHCM2__Team_Member__c> managersById = new Map<Id, fHCM2__Team_Member__c>(
                TeamMemberUtils.getManagersOf(subjectsById.values()));

        // Create map of Objective ID => collaborator models
        Map<Id, Objective__c> objectivesById = new Map<Id, Objective__c>(objectives);
        Map<Id, List<ObjectiveCollaboratorModel>> collaboratorsByObjectiveId =
                createEmptyMapping(objectivesById.keySet());

        // Build collaborators from subjects and managers, adding to map
        for (Id objectiveId : objectivesById.keySet()) {
            fHCM2__Team_Member__c subjectTm =
                    subjectsById.get(objectivesById.get(objectiveId).Team_Member__c);
            collaboratorsByObjectiveId.get(objectiveId).addAll(
                    createSubjectAndManagerCollaborators(
                            objectiveId,
                            subjectTm,
                            managersById.get(subjectTm.fHCM2__Manager__c)));
        }

        // Add saved collaborators
        List<ObjectiveCollaboratorModel> models = ObjectiveCollaboratorModelBuilder.build(
                ObjectiveCollaboratorRepository.getForObjectives(objectivesById.keySet()));
        for (ObjectiveCollaboratorModel model : models) {
            collaboratorsByObjectiveId.get(model.objectiveId).add(model);
        }

        return collaboratorsByObjectiveId;
    }

    /**
     * Creates ObjectiveCollaboratorModels for an Objective's subject and manager.
     */
    private static List<ObjectiveCollaboratorModel> createSubjectAndManagerCollaborators(
            Id objectiveId,
            fHCM2__Team_Member__c subject,
            fHCM2__Team_Member__c manager) {

        List<ObjectiveCollaboratorModel> collaborators =
                new List<ObjectiveCollaboratorModel>();

        collaborators.add(ObjectiveCollaboratorModelBuilder.build(
                objectiveId, ACCESS_LEVEL_OWNER, subject));
        if (manager != null) {
            collaborators.add(ObjectiveCollaboratorModelBuilder.build(
                    objectiveId, ACCESS_LEVEL_OWNER, manager));
        }

        return collaborators;
    }

    /**
     * Creates a map of ID => List of ObjectiveCollaboratorModel, with empty
     * lists against each of the provided IDs.
     */
    private static Map<Id, List<ObjectiveCollaboratorModel>> createEmptyMapping(
            Set<Id> ids) {
        Map<Id, List<ObjectiveCollaboratorModel>> collaboratorsById =
                new Map<Id, List<ObjectiveCollaboratorModel>>();
        for (Id id : ids) {
            collaboratorsById.put(id, new List<ObjectiveCollaboratorModel>());
        }
        return collaboratorsById;
    }
}