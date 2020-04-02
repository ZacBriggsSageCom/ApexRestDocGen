@isTest
public class SchemaUtilsTest {

    @isTest
    private static void testGetFieldLabel_RealField() {
        //  GIVEN I have field map
        Map<String, Schema.SObjectField> fieldMap =
                SchemaUtils.getFieldMap(TeamMemberUtils.TEAM_MEMBER_TYPE);
      
        //  WHEN I get the field
        String label = SchemaUtils.getFieldLabel(
            fieldMap,
            'fhcm2__age__c');

        // We can't reliably test the value here, because we do not control
        // the labels. However, we can at least test that we get *a* value.
        System.assert(!String.isBlank(label));
        System.assertNotEquals('fhcm2__age__c', label);
    }

    @isTest
    private static void testGetFieldLabel_UnknownField() {
        //  GIVEN I have field map
        Map<String, Schema.SObjectField> fieldMap =
                SchemaUtils.getFieldMap(TeamMemberUtils.TEAM_MEMBER_TYPE);

        String label = SchemaUtils.getFieldLabel(
            fieldMap,
            'fhcm2__fake_field__c');
        System.assertEquals('fhcm2__fake_field__c', label);
    }

    @isTest
    private static void testGetSObjectLabel() {
        String objLabel = SchemaUtils.getSObjectLabel(
                TeamMemberUtils.TEAM_MEMBER_TYPE);
        
        // We can't reliably test the value here, because we do not control
        // the labels. However, we can at least test that we get *a* value.
        System.assert(!String.isBlank(objLabel));
    }

}