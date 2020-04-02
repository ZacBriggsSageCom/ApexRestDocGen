/**
 * REST endpoint for searches
 */
@RestResource(urlMapping='/search/*')
global class SearchRest {

    /**
     * From the URL: finds which 'type' of search is being made, returning the part of the
     * url between the final '/' and '?={query}' portion.
     * E.g. run with url ending '/search/people?term=Alis' will return 'people'
     * whereas a url ending '/search/objectives?CreatedDate=01-05-2018' will return 'objectives'
     */
    public static String getSearchType() {
        String url = RestContext.request.requestURI;

        if (!url.contains('?')) {
            throw new RestUtils.StringNotFoundException(
                    'Unable to find start of search query in url');
        }

        List<String> segments = url.split('/');
        String typeSegment = segments.get(segments.size() - 1);
        String searchType = typeSegment.substring(0, typeSegment.indexOf('?'));
        return searchType;
    }

    @HttpGet
    global static void search() {
        try {
            String searchType = getSearchType();

            switch on searchType {
                when 'people' {
                    searchPeople();
                }
                when else { // The searchType does not match any known search types
                    RestUtils.setResponseBody(
                            new BaseResponseModel(new ErrorModel(
                                    HttpUtils.STATUS_NOT_FOUND,
                                    'Could not find search endpoint',
                                    'URL did not match any known search endpoints')));
                }
            }
        } catch (Exception e) {
            RestUtils.setResponseBody(new BaseResponseModel(), e);
        }
    }

    /**
     * When called looks for a term query parameter in the URL and
     * serves a search with the given value for the term as a response.
     */
    private static void searchPeople() {
        Map<String, String> queryParams = RestUtils.getUrlQueryParams();
        String queryParamName = 'term';

        if (queryParams.containsKey(queryParamName)) {
            RestUtils.setResponseBody(SearchController.searchPeople(queryParams.get(queryParamName)));
        } else {
            RestUtils.setResponseBody(new SearchPeopleResponseModel());
        }
    }
}