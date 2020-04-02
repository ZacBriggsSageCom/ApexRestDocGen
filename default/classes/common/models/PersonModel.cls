/**
 * Model representing a person.
 */
public virtual class PersonModel {

    // The person's Team Member ID
    public String id { get; set; }

    // The person's full name
    public String name { get; set; }

    // The first name of the person
    public String firstName  { get; set; }

    // The URL for the TM Picture of this person
    public String pictureUrl { get; set; }

    // Relationship to the viewer
    public String relationship { get; set; }

    // ID of this Team Member's policy
    public String policyId { get; set; }

}