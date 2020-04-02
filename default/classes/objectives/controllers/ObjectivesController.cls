/**
 * Controller for the Objectives module.
 */
public class ObjectivesController {

    /**
     * Gets all of a Team Member's Objectives.
     */
    public static ObjectiveListResponseModel getObjectives(String tmId) {

        // Validate request
        RequestValidator validator = new RequestValidator()
                .addRule(new ValidTeamMemberIdRule(tmId))
                .addRule(new CanViewObjectivesRule(tmId));
        if (!validator.isValid()) {
            return new ObjectiveListResponseModel(validator.getErrorModel());
        }

        // Retrieve objectives
        return new ObjectiveListResponseModel(
                ObjectiveUtils.getVisibleObjectives(tmId));
    }

    /**
     * Saves a new Objective.
     */
    public static EditObjectiveResponseModel createObjective(ObjectiveModel om) { // nom nom

        // Validate request
        RequestValidator validator = new RequestValidator()
                .addRule(new IsObjectiveNewRule(om.Id))
                .addRule(new CanCreateObjectiveRule(om.tmId));
        if (!validator.isValid()) {
            return new EditObjectiveResponseModel(validator.getErrorModel());
        }

        // Create the Objective record
        Objective__c objective = ObjectiveUtils.createObjective(om);

        // Create Task records
        ObjectiveUtils.buildAndUpsertTasks(objective.Id, om.tasks);

        // Query all fields as some are populated on insert
        objective = ObjectiveRepository.get(objective.Id);

        // Populate the ObjectiveModel with any newly-set fields
        om.id = objective.Id;
        om.createdDate =
                DateUtils.datetimeToStringInUserTimeZone(objective.Created_Date__c);

        // Populate the ObjectiveModel with our Tasks, now that they have IDs
        om.tasks = TaskModelBuilder.buildTasks(objective.Tasks__r);

        // Add creator from context
        om.creator = TeamMemberUtils.getViewerPerson();

        // Create the response
        return new EditObjectiveResponseModel(om);
    }

    /**
     * Edits an existing Objective.
     */
    public static EditObjectiveResponseModel editObjective(ObjectiveModel om) {

        // Validate request
        RequestValidator validator = new RequestValidator()
                .addRule(new ValidObjectiveIdRule(om.id))
                .addRule(new DoesObjectiveExistRule(om.id))
                .addRule(new CanObjectiveBeEditedRule(om.status))
                .addRule(new CanEditObjectiveRule(om.tmId));
        if (!validator.isValid()) {
            return new EditObjectiveResponseModel(validator.getErrorModel());
        }

        // Perform the update
        Objective__c objective = ObjectiveUtils.updateObjective(om);
        List<Task__c> tasks =
                ObjectiveUtils.buildAndUpsertTasks(om.id, om.tasks);

        // Recreate the TaskModels (to populate the IDs of new Tasks)
        om.tasks = TaskModelBuilder.buildTasks(tasks);

        // Delete any Tasks that were deleted in the front-end
        ObjectiveUtils.deleteMissingTasks(om.id, om.tasks);

        // Add creator from context
        om.creator = TeamMemberUtils.getViewerPerson();

        return new EditObjectiveResponseModel(om);
    }

    /**
     * Deletes a draft Objective by ID.
     */
    public static BaseResponseModel deleteObjective(String objectiveId) {

        // Validate request
        RequestValidator validator = new RequestValidator()
                .addRule(new ValidObjectiveIdRule(objectiveId))
                .addRule(new DoesObjectiveExistRule(objectiveId))
                .addRule(new ObjectiveStatusRule(objectiveId, ObjectiveUtils.STATUS_DRAFT))
                .addRule(new CanDeleteObjectiveRule(objectiveId));
        if (!validator.isValid()) {
            return new BaseResponseModel(validator.getErrorModel());
        }

        ObjectiveUtils.deleteObjective(objectiveId);
        return new BaseResponseModel();
    }

    /**
     * Activates a draft Objective.
     */
    public static EditObjectiveResponseModel activateObjective(ObjectiveModel om) {

        // Validate request
        RequestValidator validator = new RequestValidator()
                .addRule(new ValidObjectiveIdRule(om.id))
                .addRule(new DoesObjectiveExistRule(om.id))
                .addRule(new ObjectiveStatusRule(om.id, ObjectiveUtils.STATUS_DRAFT))
                .addRule(new CanActivateObjectiveRule(om.id));
        if (!validator.isValid()) {
            return new EditObjectiveResponseModel(validator.getErrorModel());
        }

        // Perform the update
        Objective__c objective = ObjectiveUtils.updateObjectiveAndActivate(om);
        ObjectiveUtils.buildAndUpsertTasks(om.id, om.tasks);

        // Add creator from context
        om.creator = TeamMemberUtils.getViewerPerson();
        om.status = ObjectiveUtils.STATUS_ACTIVE;
        return new EditObjectiveResponseModel(om);
    }

    /**
     * Closes an active Objective.
     */
    public static EditObjectiveResponseModel closeObjective(String objectiveId) {

        // Validate request
        RequestValidator validator = new RequestValidator()
                .addRule(new ValidObjectiveIdRule(objectiveId))
                .addRule(new DoesObjectiveExistRule(objectiveId))
                .addRule(new ObjectiveStatusRule(objectiveId, ObjectiveUtils.STATUS_ACTIVE))
                .addRule(new CanCloseObjectiveRule(objectiveId));
        if (!validator.isValid()) {
            return new EditObjectiveResponseModel(validator.getErrorModel());
        }

        return new EditObjectiveResponseModel(ObjectiveUtils.closeObjective(objectiveId));
    }
}
