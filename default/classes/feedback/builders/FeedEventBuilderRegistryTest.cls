@isTest
public class FeedEventBuilderRegistryTest {

    @isTest
    private static void testGetForValidType() {
        // GIVEN a valid builder type
        // WHEN I get a FeedEventBuilder for it, THEN the builder exists
        System.assertNotEquals(
                null,
                FeedEventBuilderRegistry.getFor(FeedEventTypes.OBJECTIVE_ACTIVATED)
        );
    }

    @isTest
    private static void testGetForInvalidType() {
        // GIVEN an invalid builder type
        // WHEN I get a FeedEventBuilder for it, THEN I get nothing
        System.assertEquals(null, FeedEventBuilderRegistry.getFor('Potato'));
    }
}