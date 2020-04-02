/**
 * Utilities for working with objectives.
 */
public class ObjectiveUtils {

    public class ObjectiveNotFoundException extends Exception {}

    public static final String OBJECTIVE_TYPE =
            NamespaceUtils.getNamespacePrefix() + 'Objective__c';

    private static final String OBJECTIVES_PAGE =
            '/apex/Performance#/tm/{0}/objectives/{1}';

    public static final String OBJECTIVES_PROCESS_NAME = 'Objectives';

    public static final String STATUS_DRAFT = 'Draft';
    public static final String STATUS_ACTIVE = 'Active';
    public static final String STATUS_CLOSED = 'Closed';
    public static final String VISIBILITY_PRIVATE = 'Private';
    public static final String VISIBILITY_PUBLIC = 'Public';

    /**
     * Given a TM ID, finds and builds all objectives which are visible to the
     * viewer.
     */
    public static List<ObjectiveModel> getVisibleObjectives(Id tmId) {

        // Get all objectives
        List<Objective__c> objectives = ObjectiveRepository.getForTeamMember(tmId);

        // Remove those which aren't visible to me
        Id viewerUserId = UserInfo.getUserId();
        List<Objective__c> filteredObjectives = new List<Objective__c>();
        for (Objective__c objective : objectives) {
            if (isVisibleToMe(objective, viewerUserId)) {
                filteredObjectives.add(objective);
            }
        }

        // Build models & return
        return ObjectiveModelBuilder.build(filteredObjectives);
    }

    /**
     * Creates a new objective in the database, in DRAFT state.
     */
    public static Objective__c createObjective(ObjectiveModel om) {
        return new ObjectiveRecordBuilder(om)
                .setStatus(ObjectiveUtils.STATUS_DRAFT)
                .save()
                .build();
    }

    /**
     * Updates an existing objective in the database, without respecting status
     * changes.
     */
    public static Objective__c updateObjective(ObjectiveModel om) {
        return new ObjectiveRecordBuilder(om)
                .save()
                .build();
    }

    /**
     * Updates an existing objective in the database, respecting status
     * changes.
     */
    public static Objective__c updateObjectiveAndActivate(ObjectiveModel om) {
        Objective__c objective = new ObjectiveRecordBuilder(om)
                .setStatus(ObjectiveUtils.STATUS_ACTIVE)
                .save()
                .build();

        // Send notification to the recipients
        Notification notification = ObjectiveStatusChangeNotification.create(
                ObjectiveModelBuilder.build(objective));
        notification.send();

        // Save an event
        FeedEventUtils.create(objective.Id, FeedEventTypes.OBJECTIVE_ACTIVATED);

        return objective;
    }

    /**
     * Given an objective and a user ID, checks whether the objective should be
     * visible to the user.
     */
    @TestVisible
    private static Boolean isVisibleToMe(Objective__c objective, Id viewerUserId) {
        return objective.Status__c == STATUS_DRAFT
                ? objective.CreatedById == viewerUserId
                : true;
    }

    /**
     * Deletes an objective by ID, if it exists.
     */
    public static void deleteObjective(String objectiveId) {
        Objective__c objective = ObjectiveRepository.get(objectiveId);
        if (objective == null) {
            throw new ObjectiveNotFoundException(
                    'Objective not found with objective id: ' + objectiveId);
        }

        ObjectiveRepository.deleteRecord(objective);
    }

    /**
     * Changes the status of an active objective to Closed.
     */
    public static ObjectiveModel closeObjective(String objectiveId) {
        Objective__c objective = ObjectiveRepository.get(objectiveId);
        if (objective == null) {
            throw new ObjectiveNotFoundException(
                    'Objective not found with objective id: ' + objectiveId);
        }

        objective.Closed_Date__c = Datetime.now();
        objective.Status__c = STATUS_CLOSED;
        update objective;

        // Send notification to the recipients
        Notification notification = ObjectiveStatusChangeNotification.create(
                ObjectiveModelBuilder.build(objective));
        notification.send();

        // Save an event
        FeedEventUtils.create(objective.Id, FeedEventTypes.OBJECTIVE_CLOSED);

        return ObjectiveModelBuilder.build(objective);
    }

    /**
     * Builds a SubjectModel representing an objective.
     */
    public static SubjectModel createObjectiveAsSubject(Id objectiveId) {
        Objective__c objective = ObjectiveRepository.get(objectiveId);
        SubjectModel subject = new SubjectModel();
        subject.id = objectiveId;
        subject.name = objective.Title__c;
        subject.tmId = objective.Team_Member__c;
        return subject;
    }

    /**
     * Given an objective ID, gets the ID of its linked conversation (if it exists).
     */
    public static Id getConversationId(Id objectiveId) {
        return getConversationIds(new Set<Id>{objectiveId}).get(objectiveId);
    }

    /**
     * Given some objective IDs, builds a map of their linked conversations in
     * the form Objective ID => Conversation ID.
     */
    public static Map<Id, Id> getConversationIds(Set<Id> objectiveIds) {

        // Find junction objects
        List<Conversation_Subject__c> junctions =
        ConversationSubjectRepository.getSubjectsWithObjectiveIds(objectiveIds);

        // Match objectives to linked conversations
        Map<Id, Id> conversationsByObjectives = new Map<Id, Id>();
        for (Conversation_Subject__c junction : junctions) {
            conversationsByObjectives.put(
                    junction.Objective__c, junction.Conversation__c);
        }
        return conversationsByObjectives;
    }

    /**
     * Gets the URL of a Objective.
     */
    public static String getObjectivePageUrl(Id tmId, Id objectiveId) {
        return fHCM2.UrlHelper.getFullUrl(
                String.format(
                        OBJECTIVES_PAGE,
                        new List<String>{
                                String.valueOf(tmId),
                                String.valueOf(objectiveId)
                        }
                )
        );
    }

    /**
     * Builds a list of Tasks from a list of TaskModels and upserts them.
     */
    public static List<Task__c> buildAndUpsertTasks(
            Id objectiveId, List<TaskModel> taskModels) {

        List<Task__c> tasks = new List<Task__c>();
        Integer index = 0;

        for (TaskModel taskModel : taskModels) {
            Task__c task = new Task__c(
                Id = taskModel.id,
                Objective__c = objectiveId,
                Content__c = taskModel.content,
                Status__c = TaskUtils.getTaskStatus(taskModel),
                Order__c = index
            );
            index++;
            tasks.add(task);
        }

        upsert tasks;
        return tasks;
    }

    /**
     * Deletes any Tasks for an Objective that are missing from the given list.
     */
    public static void deleteMissingTasks(
            Id objectiveId, List<TaskModel> taskModels) {

        // Get IDs from all provided TaskModels
        Set<Id> taskIds = new Set<Id>();
        for (TaskModel taskModel : taskModels) {
            taskIds.add(taskModel.id);
        }

        // Find all missing Tasks
        List<Task__c> tasks =
                TaskRepository.getMissingTasks(objectiveId, taskIds);

        // ... and delete them
        TaskRepository.deleteTasks(tasks);
    }

    /**
     * Finds the Team Members who are the subjects of a list of Objectives.
     */
    public static List<fHCM2__Team_Member__c> getSubjects(List<Objective__c> objectives) {
        Set<Id> subjectIds = new Set<Id>();
        for (Objective__c objective : objectives) {
            subjectIds.add(objective.Team_Member__c);
        }
        return TeamMemberRepository.get(subjectIds);
    }
}