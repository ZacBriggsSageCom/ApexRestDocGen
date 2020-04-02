@isTest
public class EqualsFilterTest {

    @isTest
    private static void testIsAllowed_True() {
        // GIVEN an EqualsFilter with some value
        Filter filter = new EqualsFilter(5);

        // WHEN determining if that same value is allowed
        // THEN it is
        System.assertEquals(true, filter.isAllowed(5));
    }

    @isTest
    private static void testIsAllowed_False() {
        // GIVEN an EqualsFilter with some value
        Filter filter = new EqualsFilter(5);

        // WHEN determining if a different value is allowed
        // THEN it isn't
        System.assertEquals(false, filter.isAllowed(6));
    }

}
