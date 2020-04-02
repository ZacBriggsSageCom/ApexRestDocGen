/**
 * Tests exercising utilities related to the package namespace.
 */
@isTest
public class NamespaceUtilsTest {

    @isTest
    private static void testGetNamespaceString() {
        // WHEN I ask for the current namespace, THEN it is not null
        System.assertNotEquals(null, NamespaceUtils.getNamespaceString());
    }

    @isTest
    private static void testGetNamespacePrefix() {
        // WHEN I ask for the namespace prefix, THEN it is not null
        System.assertNotEquals(null, NamespaceUtils.getNamespacePrefix());
    }

    @isTest
    private static void testReplaceNamespace() {
        // WHEN I replace the namespace in the base URL, THEN I get the correct URL
        System.assertEquals(
                    'https://potato.pretendforce.com',
                    NamespaceUtils.replaceNamespace('spperfmgmt', 'potato'));
    }

    @isTest
    private static void testReplaceNamespaceWithDefault() {
        // WHEN I replace the namespace in the base URL, but do not provide a
        // replacement, THEN I get the correct URL
        System.assertEquals(
                'https://c.pretendforce.com',
                NamespaceUtils.replaceNamespace('spperfmgmt', null));
    }

    @isTest
    private static void testToggleNamespace_WithNamespace() {
        System.assertEquals('str', NamespaceUtils.toggleNamespace('spperfmgmt__str'));
    }

    @isTest
    private static void testToggleNamespace_WithoutNamespace() {
        System.assertEquals('spperfmgmt__str', NamespaceUtils.toggleNamespace('str'));
    }

}
