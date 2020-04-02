/**
 * Helper methods for tests involving URLs.
 */
@isTest
public class UrlTestUtils {

    public static final String TEST_DOMAIN =
            'https://test-domain-fhcm2.my.salesforce.com';

    /**
     * Given some URL, replace the domain with our test domain.
     *
     * @param url
     * @return String
     */
    public static String replaceWithTestDomain(String url) {
        return url.replaceAll('https://.*?/', TEST_DOMAIN + '/');
    }
}
