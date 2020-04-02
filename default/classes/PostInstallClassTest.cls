@isTest
public class PostInstallClassTest {

    @TestSetup
    private static void setup() {

        // Team Members
        fHCM2__Team_Member__c manager = new fHCM2__Team_Member__c(
            Name = 'Manager'
        );
        insert manager;
        fHCM2__Team_Member__c tm1 = new fHCM2__Team_Member__c(
            Name = 'Alfred',
            fHCM2__Manager__c = manager.Id
        );
        fHCM2__Team_Member__c tm2 = new fHCM2__Team_Member__c(
            Name = 'Betty',
            fHCM2__Manager__c = manager.Id
        );
        insert new List<fHCM2__Team_Member__c> { tm1, tm2 };

        // Feedback Items
        Feedback__c feedback1 = new Feedback__c(
            Author__c = tm1.Id,
            Author_Type__c = 'Self',
            Current_Version__c = 2
        );
        Feedback__c feedback2 = new Feedback__c(
            Author__c = tm2.Id,
            Author_Type__c = 'Self',
            Current_Version__c = 2
        );
        insert new List<Feedback__c> { feedback1, feedback2 };

        // Override the CreatedDate of the Feedback Items
        Test.setCreatedDate(feedback1.Id, DateTime.newInstance(2020, 1, 1));
        Test.setCreatedDate(feedback2.Id, DateTime.newInstance(2020, 2, 2));

        // Feedback Versions
        Feedback_Version__c feedback1v1 = new Feedback_Version__c(
            Content__c = 'Feedback on Alfred (v1)',
            Feedback_Item__c = feedback1.Id,
            Version__c = 1
        );
        Feedback_Version__c feedback1v2 = new Feedback_Version__c(
            Content__c = 'Feedback on Alfred (v2)',
            Feedback_Item__c = feedback1.Id,
            Version__c = 2
        );
        Feedback_Version__c feedback2v1 = new Feedback_Version__c(
            Content__c = 'Feedback on Betty (v1)',
            Feedback_Item__c = feedback2.Id,
            Version__c = 1
        );
        Feedback_Version__c feedback2v2 = new Feedback_Version__c(
            Content__c = 'Feedback on Betty (v2)',
            Feedback_Item__c = feedback2.Id,
            Version__c = 2
        );
        insert new List<Feedback_Version__c> {
                feedback1v1, feedback1v2, feedback2v1, feedback2v2 };

        // Override the CreatedDate of the Feedback Versions
        Test.setCreatedDate(feedback1v1.Id, DateTime.newInstance(2020, 1, 1));
        Test.setCreatedDate(feedback1v2.Id, DateTime.newInstance(2020, 2, 2));
        Test.setCreatedDate(feedback2v1.Id, DateTime.newInstance(2020, 3, 3));
        Test.setCreatedDate(feedback2v2.Id, DateTime.newInstance(2020, 4, 4));

        // Team Member Feedback (junctions)
        Team_Member_Feedback__c junction1 = new Team_Member_Feedback__c(
            Feedback__c = feedback1.Id,
            Team_Member__c = tm1.Id
        );
        Team_Member_Feedback__c junction2 = new Team_Member_Feedback__c(
            Feedback__c = feedback2.Id,
            Team_Member__c = tm2.Id
        );
        insert new List<Team_Member_Feedback__c> { junction1, junction2 };
    }

    @isTest
    private static void testMigrateLegacyFeedback() {

        // GIVEN some legacy Feedback Items (see @TestSetup method)
        //  (Here we are retrieving the already-inserted records)
        List<fHCM2__Team_Member__c> tms = [
            SELECT Id,
                Name
            FROM fHCM2__Team_Member__c
            ORDER BY Name
        ];
        fHCM2__Team_Member__c tm1 = tms[0];
        fHCM2__Team_Member__c tm2 = tms[1];

        // WHEN the migration is carried out
        Test.startTest();
        PostInstallClass.migrateLegacyFeedback();
        Integer numSoqlQueries = Limits.getQueries();
        Integer numDmlStatements = Limits.getDMLStatements();
        Test.stopTest();

        // THEN a Conversation is created for each subject
        List<Conversation__c> convos = [
            SELECT Id
            FROM Conversation__c
        ];
        System.assertEquals(2, convos.size());

        // AND a Conversation Participant is created for each subject
        // and their manager
        List<Conversation_Participant__c> convoParticipants = [
            SELECT Id
            FROM Conversation_Participant__c
        ];
        System.assertEquals(4, convoParticipants.size());

        // AND a Comment is created for each Feedback Item
        List<Comment__c> comments = [
            SELECT
                Id,
                Author__c,
                Author_Type__c,
                Created_Date__c,
                Current_Version__c
            FROM Comment__c
            ORDER BY Created_Date__c
        ];
        System.assertEquals(2, comments.size());

        // AND all fields are set correctly
        System.assertEquals(tm1.Id, comments[0].Author__c);
        System.assertEquals(tm2.Id, comments[1].Author__c);
        System.assertEquals('Self', comments[0].Author_Type__c);
        System.assertEquals('Self', comments[1].Author_Type__c);
        System.assertEquals(
                DateTime.newInstance(2020, 1, 1), comments[0].Created_Date__c);
        System.assertEquals(
                DateTime.newInstance(2020, 2, 2), comments[1].Created_Date__c);
        System.assertEquals(2, comments[0].Current_Version__c);
        System.assertEquals(2, comments[1].Current_Version__c);

        // AND a Comment Version is created for each Feedback Version
        List<Comment_Version__c> commentVersions = [
            SELECT
                Id,
                Created_Date__c,
                Comment__c,
                Content__c,
                Version__c
            FROM Comment_Version__c
            ORDER BY Created_Date__c
        ];
        System.assertEquals(4, commentVersions.size());

        // AND all fields are set correctly
        System.assertEquals(
                DateTime.newInstance(2020, 1, 1),
                commentVersions[0].Created_Date__c);
        System.assertEquals(
                DateTime.newInstance(2020, 2, 2),
                commentVersions[1].Created_Date__c);
        System.assertEquals(
                DateTime.newInstance(2020, 3, 3),
                commentVersions[2].Created_Date__c);
        System.assertEquals(
                DateTime.newInstance(2020, 4, 4),
                commentVersions[3].Created_Date__c);
        System.assertEquals(comments[0].Id, commentVersions[0].Comment__c);
        System.assertEquals(comments[0].Id, commentVersions[1].Comment__c);
        System.assertEquals(comments[1].Id, commentVersions[2].Comment__c);
        System.assertEquals(comments[1].Id, commentVersions[3].Comment__c);
        System.assertEquals(
                'Feedback on Alfred (v1)', commentVersions[0].Content__c);
        System.assertEquals(
                'Feedback on Alfred (v2)', commentVersions[1].Content__c);
        System.assertEquals(
                'Feedback on Betty (v1)', commentVersions[2].Content__c);
        System.assertEquals(
                'Feedback on Betty (v2)', commentVersions[3].Content__c);
        System.assertEquals(1, commentVersions[0].Version__c);
        System.assertEquals(2, commentVersions[1].Version__c);
        System.assertEquals(1, commentVersions[2].Version__c);
        System.assertEquals(2, commentVersions[3].Version__c);

        // AND the Team Member Feedback junction objects are deleted
        List<Team_Member_Feedback__c> junctions =
                [ SELECT Id FROM Team_Member_Feedback__c ];
        System.assertEquals(0, junctions.size());

        // AND the Feedback Items are deleted
        List<Feedback__c> feedbackItems =
                [ SELECT Id FROM Feedback__c ];
        System.assertEquals(0, feedbackItems.size());

        // AND the Feedback Versions are deleted
        // (due to being children of a master-detail relationship)
        List<Feedback_Version__c> feedbackVersions =
                [ SELECT Id FROM Feedback_Version__c ];
        System.assertEquals(0, feedbackVersions.size());

        // AND only 4 queries were carried out
        System.assertEquals(4, numSoqlQueries);

        // AND only 6 DML statements were carried out
        // (5 inserts and 2 deletes)
        System.assertEquals(7, numDmlStatements);
    }

}