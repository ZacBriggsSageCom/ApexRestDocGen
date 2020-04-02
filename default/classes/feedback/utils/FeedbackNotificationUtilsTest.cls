/**
 * Tests exercising utilities for creating Notifications about Feedback events.
 */
@isTest
public class FeedbackNotificationUtilsTest {

    private static fHCM2__Team_Member__c subject;
    private static fHCM2__Team_Member__c viewer;
    private static FeedItemModel feedback;
    private static ConversationModel conversation;

    private static void setUp() {
        fHCM2__Policy__c pol = new fHCM2__Policy__c(Allow_Edit_Feedback__c = true);
        insert pol;

        viewer = new TeamMemberTestUtils.TeamMemberBuilder()
                .setUser(UserInfo.getUserId())
                .setName('Wilma Worm')
                .setPolicy(pol.Id)
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
    private static void testBuildLink() {

        // GIVEN some comment
        setUp();

        // WHEN I build a link section pointing to it in its enclosing conversation
        String linkSection = UrlTestUtils.replaceWithTestDomain(
                FeedbackNotificationUtils.buildLinkSection(feedback));

        // THEN it is of the expected format
        System.assert(Pattern.matches(
                '(?s)'                                      // make dot match newlines
                        + '.*?'                             // initial text in label
                        + '<br />'                          // line break before link
                        + UrlTestUtils.TEST_DOMAIN
                        + '/apex/Performance#/tm/'
                        + subject.id
                        + '.*?'                             // rest of URI before fragment
                        + '#'                               // fragment identifier
                        + feedback.id,
                linkSection
        ));
    }
}