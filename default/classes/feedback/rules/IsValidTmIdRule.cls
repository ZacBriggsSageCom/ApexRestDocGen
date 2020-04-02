/**
 * Created by zac.briggs on 06/11/2019.
 */

public class IsValidTmIdRule implements ValidationRule {
    private String tmId;

    public IsValidTmIdRule () {}

    public IsValidTmIdRule (String tmID) {
        this.tmId = tmId;
    }

    public Boolean isValid() {
        return (tmId != null);
    }

    public ErrorModel createErrorModel() {
        return new ErrorModel(
                HttpUtils.STATUS_BAD_REQUEST, Label.Error_Invalid_Team_Member_Id_Supplied, '');
    }
}