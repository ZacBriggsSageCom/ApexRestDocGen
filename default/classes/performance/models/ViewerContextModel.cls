/**
 * Model representing details about who the viewer is.
 */
public class ViewerContextModel extends PersonModel {

    // Whether the viewer is the manager of anyone
    public Boolean isManager;

    // If the viewer has direct reports, list them
    public List<PersonModel> directReports;

    // If the viewer has a manager, include them
    public PersonModel manager;
}
