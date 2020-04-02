@isTest
public class ObjectiveTestUtils {

    public class ObjectiveBuilder {
        private Objective__c item;

        public ObjectiveBuilder() {
            item = new Objective__c();
        }

        public ObjectiveBuilder setCategory(String category) {
            item.Category__c = category;
            return this;
        }

        public ObjectiveBuilder setDescription(String description) {
            item.Description__c = description;
            return this;
        }

        public ObjectiveBuilder setPriority(String priority) {
            item.Priority__c = priority;
            return this;
        }

        public ObjectiveBuilder setEndDate(Date endDate) {
            item.End_Date__c = endDate;
            return this;
        }

        public ObjectiveBuilder setReviewDate(Date reviewDate) {
            item.Review_Date__c = reviewDate;
            return this;
        }

        public ObjectiveBuilder setStatus(String status) {
            item.Status__c = status;
            return this;
        }

        public ObjectiveBuilder setTeamMember(Id tmId) {
            item.Team_Member__c = tmId;
            return this;
        }

        public ObjectiveBuilder setTitle(String title) {
            item.Title__c = title;
            return this;
        }

        public ObjectiveBuilder setVisibility(String visibility) {
            item.Visibility__c = visibility;
            return this;
        }

        public ObjectiveBuilder save() {
            upsert item;
            item = ObjectiveRepository.get(item.Id);
            return this;
        }

        public ObjectiveModel build() {
            return ObjectiveModelBuilder.build(item);
        }
    }

    public static ObjectiveModel getMockObjective() {
        fHCM2__Team_Member__c viewer = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setName('Wilma Worm')
                .build();

        ObjectiveModel om = new ObjectiveModel();

        // Populate with some mock data
        om.category = 'Category';
        om.description = 'Some description';
        om.endDate = '2019-11-12';
        om.priority = 'High';
        om.companyObjective = 'Customer Focus';
        om.reviewDate = '2019-11-12';
        om.status = 'Draft';
        om.tmId = viewer.Id;
        om.title = 'Something I might do';
        om.visibility = 'Private';
        om.tasks = new List<TaskModel>();

        return om;
    }

    public static void addMockTask(ObjectiveModel om, String content) {
        TaskModel taskModel = createTaskModel(content, false);
        om.tasks.add(taskModel);
    }

    public static TaskModel createTaskModel(String content, Boolean complete) {
        TaskModel taskModel = new TaskModel();
        taskModel.content = content;
        taskModel.complete = complete;
        return taskModel;
    }

}