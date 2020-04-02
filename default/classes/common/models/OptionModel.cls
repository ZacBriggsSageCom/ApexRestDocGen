/**
 * Model representing an option for a picklist.
 *
 * Based on fHCM2.SelectDTO.Option.
 *
 * We can't re-use the HCM class because Salesforce does not allow a managed
 * package to serialise classes from another package; attempting to serialise
 * any model that contains an fHCM2.SelectDTO.Option results in the error:
 *
 *  "Cannot serialize type from package: fHCM2.SelectDTO.Option"
 */
public class OptionModel {

    public String name;
    public String value;
    public Boolean isDefault;

    public OptionModel(String name, String value, Boolean isDefault) {
        this.name = name;
        this.value = value;
        this.isDefault = isDefault;
    }

}