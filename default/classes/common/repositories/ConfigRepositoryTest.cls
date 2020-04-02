/**
 * Tests exercising methods dealing with the Global Configuration custom setting.
 */
@isTest
public class ConfigRepositoryTest {

    private static void setSuppression(Boolean suppress) {
        Global_Configuration__c config = new Global_Configuration__c(
            Suppress_Emails__c = suppress
        );
        insert config;
    }

    @isTest
    private static void testGetGlobalConfig() {

        // GIVEN one Global Configuration with Suppress Emails enabled
        setSuppression(true);

        // WHEN I get the most recent Global Config
        Global_Configuration__c config = ConfigRepository.getGlobalConfig();

        // THEN I receive one
        System.assertNotEquals(null, config);

        // AND its Suppress Emails flag is enabled
        System.assertEquals(true, config.Suppress_Emails__c);
    }

}