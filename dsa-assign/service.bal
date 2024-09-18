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
    string programmeCode;
    int nqfLevel;
    string faculty;
    string department;
    string title;
    time:Date registrationDate;
    Course[] courses;
};

map<Programme> programmes = {};
int reviewPeriodInYears = 4;

service /dsa_assignment on new http:Listener(9090) {
    resource function get .(string programmeCode) returns Programme?|error {
        if (!programmes.hasKey(programmeCode)) {
            return programmes[programmeCode];
        }
        return error("programme with that progrmmeCode can't be found");

    }
}

function post(@http:Payload Programme newProgramme) returns http:Created|http:Error {
    if (programmes.hasKey(newProgramme.programmeCode)) {
        return error("Programme already exists");
    }
    programmes[newProgramme.programmeCode] = newProgramme;
    return http:CREATED;
}

function put(string programmeCode, @http:Payload Programme updatedProgramme) returns http:Ok|error? {
    if (!programmes.hasKey(programmeCode)) {
        return error("The programme cannot be found!!");
    }
    programmes[programmeCode] = updatedProgramme;
    return http:OK;

}

function delete(string programmeCode) returns error|http:NoContentError{
    if (!programmes.hasKey(programmeCode)) {
        return  error("Programme not found!!");
    }
    