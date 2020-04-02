@isTest
public class CommonRemotingTest {

    @isTest
    private static void testUserLocale() {

        // GIVEN a CommonRemoting
        CommonRemoting remoting = new CommonRemoting();

        // WHEN I check its locale, THEN it has the current user's one
        System.assertEquals(fHCM2.CurrentUser.locale(), remoting.userLocale);
    }

    @isTest
    private static void testGetTranslations() {
        System.assert(!CommonRemoting.getTranslations('en_GB').isEmpty());
    }

    @isTest
    private static void testGetFileLinks() {

        // GIVEN a File
        Conversation__c conversation = new Conversation__c();
        insert conversation;
        Comment__c feedback = new Comment__c(Conversation__c = conversation.Id);
        insert feedback;

        ContentVersion version = FileTestUtils.createDefaultFileLinkedTo(feedback.Id);
        ContentDocument document =
                FileRepository.getContentDocumentById(version.ContentDocumentId);

        // WHEN I ask for the link to it, THEN the response is not null
        System.assertNotEquals(null, CommonRemoting.getFileLink(document.Id));
    }

    @isTest
    private static void testSearchPeople() {

        // GIVEN two Team Members
        fHCM2__Team_Member__c tm1 = new TeamMemberTestUtils.TeamMemberBuilder()
            .setUser(TeamMemberTestUtils.createUser('Terrence', 'Tenrec').Id)
            .setName('Terrence Tenrec')
            .build();

        fHCM2__Team_Member__c tm2 = new TeamMemberTestUtils.TeamMemberBuilder()
            .setUser(TeamMemberTestUtils.createUser('Jaden', 'Smith').Id)
            .setName('Jaden Smith')
            .build();

        // WHEN I make a search that matches one of them
        SearchPeopleResponseModel results = CommonRemoting.searchPeople('Terr');

        // THEN the response is not null
        System.assertNotEquals(null, results);

        // AND the TM is retrieved
        System.assertEquals(tm1.Name, results.people[0].name);

        // AND that is the only TM retrieved
        System.assertEquals(1, results.people.size());
    }
}