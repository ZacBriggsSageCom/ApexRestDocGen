@isTest
public class ObjectiveRecordBuilderTest {

    @isTest
    private static void testBuild() {

        // GIVEN an objective to build
        ObjectiveModel objective = ObjectiveTestUtils.getMockObjective();

        // WHEN I build it to a record, including a status override
        Objective__c record = new ObjectiveRecordBuilder(objective)
                .setStatus('Closed')
                .save()
                .build();

        // THEN it has the expected properties
        System.assertNotEquals(null, record.Id);
        System.assertEquals(objective.title, record.Title__c);
        System.assertEquals(objective.description, record.Description__c);
        System.assertEquals(objective.category, record.Category__c);
        System.assertEquals(objective.companyObjective, record.Company_Objective__c);
        System.assertEquals(DateUtils.stringToDate(objective.endDate), record.End_Date__c);
        System.assertEquals(objective.priority, record.Priority__c);
        System.assertEquals('Closed', record.Status__c);
        System.assertEquals(objective.tmId, record.Team_Member__c);
        System.assertEquals(objective.visibility, record.Visibility__c);
        System.assertEquals(DateUtils.stringToDate(objective.reviewDate),record.Review_Date__c);
    }
}
