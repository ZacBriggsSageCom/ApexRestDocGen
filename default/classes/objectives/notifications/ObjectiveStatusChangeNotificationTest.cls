@isTest
public class ObjectiveStatusChangeNotificationTest {

    private static fHCM2__Team_Member__c subject;
    private static fHCM2__Team_Member__c viewer;
    private static ObjectiveModel objective;

    private static void setUp() {

        viewer = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setName('Wilma Worm')
                .build();

        subject = new TeamMemberTestUtils.TeamMemberBuilder()
                .setManager(viewer.Id)
                .setUser(TeamMemberTestUtils.createUser('Terrence', 'Tenrec').Id)
                .setName('Terrence Tenrec')
                .build();

        objective = new ObjectiveTestUtils.ObjectiveBuilder()
                .setTeamMember(subject.Id)
                .setTitle('Title')
                .setStatus(ObjectiveUtils.STATUS_ACTIVE)
                .save()
                .build();
    }

    @isTest
    private static void testBuildBody() {

        // GIVEN some Objective about a Team Member
        setUp();

        // AND the status has been changed
        Objective__c changedObjective = new Objective__c(
            Id = objective.Id,
            Title__c = objective.title,
            Status__c = ObjectiveUtils.STATUS_CLOSED,
            Team_Member__c = subject.Id
        );
        update changedObjective;
        changedObjective = ObjectiveRepository.get(changedObjective.Id);

        // WHEN I build the body for the Notification about it
        Notification notification = ObjectiveStatusChangeNotification.create(
                ObjectiveModelBuilder.build(changedObjective));

        // THEN it is of the expected format
        System.assert(Pattern.matches(
                '<p>Wilma Worm'
                +  '.?'
                +  'closed'
                +  '.*?'
                +  'Title'
                +  '.*?'
                +  String.valueOf(subject.Id)
                +  '.*?'
                +  String.valueOf(objective.Id),
                notification.body
        ));
    }
}