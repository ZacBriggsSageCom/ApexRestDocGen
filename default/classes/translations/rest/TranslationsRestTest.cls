/**
 * This class exists primarily for coverage purposes;
 * the logic behind the REST requests is already tested elsewhere.
 */
@isTest
public class TranslationsRestTest {

    @isTest
    private static void testGet() {
        RestTestUtils.setupRestContext('GET',
                '/performance-management/translations/en_GB');
        System.assertNotEquals(null, TranslationsRest.getTranslations());
    }

}
