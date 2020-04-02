/**
 * Model representing a response to a request for a search of people or groups
 */
public class SearchPeopleResponseModel extends BaseResponseModel {

    public List<PersonModel> people;

    public SearchPeopleResponseModel() {}

    public SearchPeopleResponseModel(ErrorModel error) {
        super(error);
    }

    public SearchPeopleResponseModel(List<PersonModel> people) {
        this.people = people;
    }
}