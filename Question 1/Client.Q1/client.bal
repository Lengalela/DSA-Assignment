import ballerina/io;
import ballerina/http;

type Course record {
    readonly string courseCode;
    string courseName;
    int nqfLevel;
};

type Programme record {
    string programmeCode;
    string nqfLevel;
    string faculty;
    string department;
    string title;
    int registrationDate;
    Course[] courses;
};

http:Client client_q1 = check new ("localhost:9090/dsa_assignment");

public function main() returns error?{
    io:println("NUSTs Programme Development Unit");
    io:println("---------------------------------\n");
    io:println("Choose an action from below with specified digit");
    io:println("1. Add a new programme.");
    io:println("2. Retrieve a list of all programme within the Programme Development Unit.");
    io:println("3. Update an existing programme's information according to the programme code.");
    io:println("4. Retrieve the details of a specific programme by their programme code.");
    io:println("5. Delete a programme's record by their programme code.");
    io:println("6. Retrieve all the programme that are due for review.");
    io:println("7. Retrieve all the programmes that belong to the same faculty");
    io:println("8. Exit");
    while true {
        string cli = io:readln("Choose an action from(1-8)> ");
        if cli == "8" {
            io:println("Goodbye!");
            break;
        }
        _ = check CLI(cli);
    }
}

function CLI(string cli) returns error?{
    
    match cli{
        "1" => {
            string programmeCode = io:readln("Programme Code: ");
            string title= io:readln("Title of Programme: ");
            string nqfLevel = io:readln("NQF Level of Programme: ");
            string faculty=io:readln("Enter the faculty: ");
            string department=io:readln("Department of Programme: ");
            string input = io:readln("Year of registration: ");
            int registrationDate = check int:fromString(input);
            string NumC = io:readln("Number of courses: ");
            int numOfCourse = check int:fromString(NumC);
            Programme programme = {
                programmeCode: programmeCode,
                title: title,
                nqfLevel: nqfLevel,
                faculty: faculty,
                department: department,
                registrationDate: registrationDate,
                courses: []
            };

            foreach int i in 0...numOfCourse-1 {
                io:println("Add course " + (i+1).toString() + " of " + numOfCourse.toString());
                string courseCode = io:readln("Course Code: ");
                string courseName = io:readln("Course Name: ");
                string nqfinput = io:readln("NQF level: ");
                int nqfLevel2 = check int:fromString(nqfinput);
                Course course = {courseCode:courseCode, courseName:courseName, nqfLevel:nqfLevel2};
                programme.courses.push(course);
            }

            Programme programmeResponse = check client_q1->/addition.post(programme); 
           io:println(programmeResponse);
        }

        "2" => {
            table<Programme> programmestable = check client_q1->/all;
            io:println("All programmes\n");
            io:println(programmestable);
        }

        "3" => {
            string programmeCode = io:readln("Programme Code: ");
            string title= io:readln("Title of Programme: ");
            string nqfLevel = io:readln("NQF Level of Programme: ");
            string faculty=io:readln("Enter the faculty: ");
            string department=io:readln("Department of Programme: ");
            string input = io:readln("Year of registration");
            int registrationDate = check int:fromString(input);
            string NumC = io:readln("Number of courses: ");
            int numOfCourse = check int:fromString(NumC);
            Programme programme = {
                programmeCode: programmeCode,
                title: title,
                nqfLevel: nqfLevel,
                faculty: faculty,
                department: department,
                registrationDate: registrationDate,
                courses: []
            };
            foreach int i in 0...numOfCourse-1 {
                io:println("Add course " + (i+1).toString() + " of " + numOfCourse.toString());
                string courseCode = io:readln("Course Code: ");
                string courseName = io:readln("Course Name: ");
                string nqfinput = io:readln("NQF level: ");
                int nqfLevel2 = check int:fromString(nqfinput);
                Course course = {courseCode:courseCode, courseName:courseName, nqfLevel:nqfLevel2};
                programme.courses.push(course);
            }
            Programme programmeResp = check client_q1->/update.put(programme); 
           io:println(programmeResp);
        }

        "4" => {
            string programmeCode = io:readln("Programme Code: ");
            Programme programme = check client_q1->/programmestable/[programmeCode];
            io:println(programme);
        }

        "5" => {
            string programmeCode = io:readln("Programme Code: ");
            Programme programme = check client_q1->/delete(programmeCode=programmeCode);
            io:println(programme.toJsonString());
        }

        "6" => {
            io:println("All programs which are due:");
            Programme programme = check client_q1->/due;
            io:println(programme);
        }

        "7" => {
            io:println("Retrieving all programs which are due...");
            Programme[] programme = check client_q1->/due;
            io:println(programme);
        }
    }
}

