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
    string registrationYear;
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
            string registrationYear = io:readln("Year of registration: ");
            string NumC = io:readln("Number of courses: ");
            int numOfCourse = check int:fromString(NumC);
            Programme programme = {
                programmeCode: programmeCode,
                title: title,
                nqfLevel: nqfLevel,
                faculty: faculty,
                department: department,
                registrationYear: registrationYear,
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

            Programme programmeResp = check client_q1->/addition.post(programme); 
           io:println(programmeResp);
        }

        "2" => {
            table<Programme> programmestables = check client_q1->/all;
            io:println("All programmes\n");
            io:println(programmestables);
        }

        "3" => {
            string programmeCode = io:readln("Programme Code: ");
            string title= io:readln("Title of Programme: ");
            string nqfLevel = io:readln("NQF Level of Programme: ");
            string faculty=io:readln("Enter the faculty: ");
            string department=io:readln("Department of Programme: ");
            string registrationYear = io:readln("Year of registration");
            string NumC = io:readln("Number of courses: ");
            int numOfCourse = check int:fromString(NumC);
            Programme programme = {
                programmeCode: programmeCode,
                title: title,
                nqfLevel: nqfLevel,
                faculty: faculty,
                department: department,
                registrationYear: registrationYear,
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
            Programme programmeResp = check client_q1->/update.put(programme, programmeCode=programmeCode); 
           io:println(programmeResp);
        }

        "4" => {
            string programmeCode = io:readln("Programme Code: ");
            Programme programme = check client_q1->/specificProg.get(programmeCode=programmeCode);
            io:println(programme);
        }

        "5" => {
            string programmeCode = io:readln("Programme Code: ");
            Programme programme = check client_q1->/removeP.delete(programmeCode=programmeCode);
            io:println("Removed Programme: " + programme.toJsonString());
        }

        "6" => {
            io:println("All programmes which are due:");
            Programme[] dueProgrammes = check client_q1->/due;
            
            // Check if there are any programmes due and print them
            if (dueProgrammes.length() > 0) {
                foreach Programme programme in dueProgrammes {
                    io:println(programme.toJsonString());
                }
            } else {
                io:println("No programmes are due for review!");
                }
        }

        "7" => {
            io:println("All programmes which belong to Faculty..");
            string faculty = io:readln("Faculty: ");
            Programme[] programmes = check client_q1->/specificFac(faculty=faculty);
            io:println("Programmes under faculty: " + faculty);

            foreach Programme programme in programmes {
                io:println(programme.toJsonString());
                }
        }
}
}
