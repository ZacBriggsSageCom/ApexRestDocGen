/**
 * Controller for searches
 */
public class SearchController {

    public static SearchPeopleResponseModel searchPeople(String query) {

        // Retrieve search
        return new SearchPeopleResponseModel(
                TeamMemberUtils.createPeople(TeamMemberRepository.searchByName(query))
        );
    }
}