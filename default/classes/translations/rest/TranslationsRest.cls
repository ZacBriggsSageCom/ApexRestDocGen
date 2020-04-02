/**
 * REST endpoint for retrieving translations.
 *
 * NOTE: The Apex remoting endpoint is in CommonRemoting.
 * 
 * The "performance-management" prefix is redundant, since Salesforce already
 * prepends the namespace to REST URLs, but a REST URL cannot be changed once a
 * file is part of a managed package:
 * https://salesforce.stackexchange.com/a/113672
 */
@RestResource(urlMapping='/performance-management/translations/*')
global class TranslationsRest {

    @TestVisible
    private static final String LANG_PARAM = 'translations';

    @HttpGet
    global static Map<String, String> getTranslations() {
        String lang = RestUtils.getUrlParam(LANG_PARAM);
        return TranslationsBuilder.getTranslations(lang);
    }

}
