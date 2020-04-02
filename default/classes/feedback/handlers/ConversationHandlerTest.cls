@isTest
public class ConversationHandlerTest {

    public class MockConversationHandler extends ConversationHandler {
        public override SubjectModel createSubject() {
            return null;
        }

        public override Id getTmId() {
            return null;
        }

        public override String getJunctionField() {
            return null;
        }

        public override String getLinkToComment(Id commentId, Id tmId) {
            return null;
        }
    }

    @isTest
    private static void testGetFeed() {

        // GIVEN a conversation with one comment
        fHCM2__Policy__c pol = new fHCM2__Policy__c();
        insert pol;
        fHCM2__Team_Member__c tm = new TeamMemberTestUtils.TeamMemberBuilder()
                .setName('Roger Rhino')
                .setUser(UserInfo.getUserId())
                .setPolicy(pol.Id)
                .build();
        ConversationModel conversation = new FeedbackTestUtils.ConversationBuilder()
                .addParticipant(tm)
                .setSubject(tm.Id)
                .save()
                .build();
        FeedItemModel comment = new FeedbackTestUtils.FeedbackBuilder()
                .setConversation(conversation.id)
                .setContent('Poor distance vision')
                .setAuthor(tm)
                .save()
                .build();

        // AND a handler for it
        ConversationHandler handler = new MockConversationHandler();
        handler.setRecord(ConversationRepository.getConversationById(conversation.id));

        // WHEN I get the conversation's feed of comments
        List<FeedItemModel> feed = handler.getFeed();

        // THEN I get one
        System.assertEquals(1, feed.size());

        // AND it has the correct ID
        System.assertEquals(comment.id, feed[0].id);
    }
}