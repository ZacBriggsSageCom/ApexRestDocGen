@isTest
public class SObjectToFieldMapperTest {

    @isTest
    private static void testApply() {
        // GIVEN an SObjectToFieldMapper with some field
        Mapper mapper = new SObjectToFieldMapper('Name');

        // WHEN the mapper is applied to an SObject
        String fieldValue = (String) mapper.apply(
                new fHCM2__Team_Member__c(Name = 'Deepti'));

        // THEN the desired field is extracted
        System.assertEquals('Deepti', fieldValue);
    }

}