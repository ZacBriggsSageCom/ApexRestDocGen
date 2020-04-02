@isTest
public class EditedCommentNotificationTest {

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

        // AND some edit that has been made about it
        Comment_Version__c newVersion = new Comment_Version__c(
                Comment__c = feedback.id,
                Content__c = '<p>Well hello there</p>',
                Version__c = 2
        );
        insert newVersion;

        Comment__c feedbackRecord = FeedbackRepository.getFeedback(feedback.id);
        feedbackRecord.Current_Version__c = 2;
        update feedbackRecord;

        feedback.content = newVersion.Content__c;

        // WHEN I build the body for the Notification about it
        Notification notification = EditedCommentNotification.create(
                feedbackRecord.Versions__r[1], feedback);

        // THEN it is of the expected format
        System.assert(Pattern.matches(
                '(?s)'                                  // make dot match newlines
                        + 'Wilma Worm'
                        + '.*\\.'                       // end of intro line
                        + '<p>.*?'
                        + '<p>Hello there</p>'          // previous content
                        + '</p><br /><p>.*?'
                        + '<p>Well hello there</p>'     // new content
                        + '</p><br />.*?'
                        + String.valueOf(subject.Id)    // subject Id in link
                        + '.*?',
                notification.body
        ));
    }
}