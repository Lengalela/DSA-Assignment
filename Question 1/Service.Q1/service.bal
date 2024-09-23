import ballerina/http;


type Course record {
    string courseCode;
    string courseName;
    int nqfLevel;
};

type Programme record {
    readonly string programmeCode;
    string nqfLevel;
    string faculty;
    string department;
    string title;
    string registrationYear;
    Course[] courses;
};

table<Programme> key(programmeCode) programmestable = table [];
int reviewPeriodInYears = 5;

service /dsa_assignment on new http:Listener(9090) {

    

    // Add a new programme
    resource function post addition(Programme newProgramme) returns Programme|error {
    if (programmestable.hasKey(newProgramme.programmeCode)) {
        return error("Programme already exists");
    }
    programmestable.put(newProgramme);
    return newProgramme;
    }

    //Return all programmes with specific programme code
    resource function get specificProg(string programmeCode) returns Programme?|error {
        if (!programmestable.hasKey(programmeCode)) {
            return error("Programme with that programmeCode can't be found");
        }
        return programmestable[programmeCode];

    }

    //Return all programmes with specific faculty
    resource function get specificFac(string faculty) returns Programme[]|error {
        Programme[] facprogram = [];

        foreach var programme in programmestable {
            if (programme.faculty == faculty) {
                facprogram.push(programme);
            }
        }
        if (facprogram.length() == 0) {
            return error("No programmes found in the specified faculty");
        }
        return facprogram;
    }

    // Retrieve a list of all programme within the Programme Development Unit.
    resource function get all() returns Programme[] {
        Programme[] allProgrammes = [];
        foreach Programme programme in programmestable {
            allProgrammes.push(programme);
        }
        return allProgrammes;   
    }

    // Update an existing programme's info
    resource function put update(string programmeCode, @http:Payload Programme updatedProgramme) returns http:Ok|error? {
        Programme? existingProgrammeOpt = programmestable[programmeCode];

        if existingProgrammeOpt is Programme {
            Programme existingProgramme = existingProgrammeOpt;  // Now it's safely cast to `Programme`.

            // Update only the fields that are provided in the `updatedProgramme`
            if updatedProgramme.nqfLevel != "" {
                existingProgramme.nqfLevel = updatedProgramme.nqfLevel;
            }
            if updatedProgramme.faculty != "" {
                existingProgramme.faculty = updatedProgramme.faculty;
            }
            if updatedProgramme.department != "" {
                existingProgramme.department = updatedProgramme.department;
            }
            if updatedProgramme.title != "" {
                existingProgramme.title = updatedProgramme.title;
            }
            if updatedProgramme.registrationYear != "" {
                existingProgramme.registrationYear = updatedProgramme.registrationYear;
            }
            if updatedProgramme.courses.length() > 0 {
                existingProgramme.courses = updatedProgramme.courses;
            }

            // Save the updated programme back to the table
            programmestable.put(existingProgramme);
            return http:OK;

        } else {
            // If the programme is not found, return an error.
            return error("The programme cannot be found!!");
        }
    }

    // Delete a programme by its specific programme code
    resource function delete removeP(string programmeCode) returns error|Programme{
    if (!programmestable.hasKey(programmeCode)) {
        return error("Programme not found!!");
    }
    Programme programme = programmestable.remove(programmeCode);
    return programme;
    }

    //Retrieve all the programmes that are due for review
    resource function get due() returns Programme[]|string|error {
        int currentYear = 2024;
        
        Programme[] dueForReview = [];
        
        foreach Programme programme in programmestable {
            // Check if the programme is older than the review period
            string newRYear = programme.registrationYear;
            int newRYearr = check int:fromString(newRYear);
            if ((currentYear - newRYearr) >= reviewPeriodInYears) {
                dueForReview.push(programme);
            }
        }

        if (dueForReview.length() > 0) {
            return dueForReview;
        } else {
            return "No programmes are due for review!";
        }
    }

}  