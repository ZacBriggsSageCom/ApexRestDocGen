@IsTest
public class TranslationsBuilderTest {

    @IsTest
    private static void testGetTranslations() {
        System.assert(!TranslationsBuilder.getTranslations('en_GB').isEmpty());
    }

    @isTest
    private static void testGetSObjectLabels() {
        Map<String, String> labelMap = TranslationsBuilder.getSObjectLabels(
                TranslationsBuilder.SOBJECT_OBJECTIVE);
        System.assert(labelMap.containsKey('spperfmgmt__Objective__c'));
        System.assert(labelMap.containsKey('spperfmgmt__Objective__c.spperfmgmt__category__c'));
    }

}
