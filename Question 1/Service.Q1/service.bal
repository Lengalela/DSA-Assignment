import ballerina/http;
import ballerina/time;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + name - name as a string or nil
    # + return - string name with hello message or error
    resource function get greeting(string? name) returns string|error {
        // Send a response back to the caller.
        if name is () {
            return error("name should not be empty!");
        }
        return string `Hello, ${name}`;
    }
}

type Course record {
    string courseCode;
    string courseName;
    int nqfLevel;
};

type Programme record {
    readonly string programmeCode;
    int nqfLevel;
    string faculty;
    string department;
    string title;
    time:Date registrationDate;
    Course[] courses;
};

map<Programme> programmes = {};
int reviewPeriodInYears = 5;

service /dsa_assignment on new http:Listener(9090) {

    table<Programme> key(programmeCode) programmestable = table [];

    //Return all programmes with specific programme code
    resource function get .(string programmeCode) returns Programme?|error {
        if (!programmes.hasKey(programmeCode)) {
            return error("Programme with that programmeCode can't be found");
        }
        return programmes[programmeCode];

    }

    // Add a new programme
    function post(@http:Payload Programme newProgramme) returns http:Created|http:Error {
    if (programmes.hasKey(newProgramme.programmeCode)) {
        return error("Programme already exists");
    }
    programmes[newProgramme.programmeCode] = newProgramme;
    return http:CREATED;
    }

    // Update an existing programme's info
    function put(string programmeCode, @http:Payload Programme updatedProgramme) returns http:Ok|error? {
    if (!programmes.hasKey(programmeCode)) {
        return error("The programme cannot be found!!");
    }
    programmes[programmeCode] = updatedProgramme;
    return http:OK;

    }

    // Delete a programme
    function delete(string programmeCode) returns error|Programme{
    if (!programmes.hasKey(programmeCode)) {
        return  error("Programme not found!!");
    }
    Programme programme = self.programmestable.remove(programmeCode);
    return programme;
    }
}  