/**
 * Tests exercising the Feedback Repository.
 */
@isTest
public class FeedbackRepositoryTest {

    private static Conversation__c conversation;

    private static void setUp() {
        conversation = new Conversation__c();
        insert conversation;
    }

    @isTest
    private static void testGetFeedback() {

        // GIVEN some saved Feedback
        setUp();
        fHCM2__Team_Member__c author =
                new TeamMemberTestUtils.TeamMemberBuilder().build();

        Comment__c savedFeedback = new Comment__c(
            Author__c = author.Id,
            Conversation__c = conversation.Id
        );
        insert savedFeedback;

        // WHEN I retrieve its properties
        Comment__c retrievedFeedback =
                FeedbackRepository.getFeedback(savedFeedback.Id);

        // THEN I get the same information back
        System.assertEquals(savedFeedback.Id, retrievedFeedback.Id);
        System.assertEquals(savedFeedback.Author__c, retrievedFeedback.Author__c);
    }

    @isTest
    private static void testGetFeedbackWithIds() {

        // GIVEN two saved Feedback items
        setUp();
        Comment__c firstFeedback = new Comment__c(Conversation__c = conversation.Id);
        Comment__c secondFeedback = new Comment__c(Conversation__c = conversation.Id);
        insert new List<Comment__c>{firstFeedback, secondFeedback};

        // AND a set containing their Ids
        Set<Id> ids = new Set<Id>{firstFeedback.Id, secondFeedback.Id};

        // WHEN I retrieve all Feedback items with Ids in this set
        List<Comment__c> feedback = FeedbackRepository.getFeedbackWithIds(ids);

        // THEN I receive a list of two items
        System.assertEquals(2, feedback.size());

        // AND they are my original pair
        Set<Id> retrievedIds = SObjectUtils.getIds((List<SObject>) feedback);
        System.assert(retrievedIds.contains(firstFeedback.Id));
        System.assert(retrievedIds.contains(secondFeedback.Id));
    }
}