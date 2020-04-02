@isTest
public class NewCommentNotificationTest {

    private static fHCM2__Team_Member__c subject;
    private static fHCM2__Team_Member__c viewer;
    private static FeedItemModel feedback;
    private static ConversationModel conversation;

    private static void setUp() {
        fHCM2__Policy__c pol = new fHCM2__Policy__c(Allow_Edit_Feedback__c = true);
        insert pol;

        viewer = new TeamMemberTestUtils.TeamMemberBuilder()
                .setName('Wilma Worm')
                .setPolicy(pol.Id)
                .setUser(UserInfo.getUserId())
                .build();
        subject = viewer;

        conversation = new FeedbackTestUtils.ConversationBuilder()
                .setSubject(subject.Id)
                .addParticipant(subject)
                .addParticipant(viewer)
                .save()
                .build();

        feedback = new FeedbackTestUtils.FeedbackBuilder()
                .setAuthor(viewer.Id)
                .setContent('<p>Hello there</p>')
                .setConversation(conversation.id)
                .save()
                .build();
    }

    @isTest
    private static void testBuildBody() {

        // GIVEN some Feedback about a Team Member
        setUp();

        // WHEN I build the body for a Notification about it
        Notification notification = NewCommentNotification.create(feedback);

        // THEN it is of the expected format
        System.assert(Pattern.matches(
                '(?s)'                                  // make dot match newlines
                        + 'Wilma Worm'
                        + '.*:'                         // end of intro line
                        + '<p>'
                        + '<p>Hello there</p>'          // content
                        + '</p><br />.*?'
                        + String.valueOf(subject.Id)    // subject Id in link
                        + '.*?',
                notification.body
        ));
    }
}