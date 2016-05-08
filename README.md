# Project Title: Timeline Thing
http://opls16projects.github.io/Timeline-Thing/

### Demo Instructions
When you run the application from main.rkt, it should open up a page that says "Welcome Back! ... Sign in to access your timelines". The default email and password in the DB are "admin@opl.com" and "admin", respectively. Upon entering that and clicking the blue "Sign In" button, the page should automatically authenticate that email/pass combination on the backend and then redirect you to another page that reads "Timelines". On the top right hand corner, there is a Sign Out link, that unsets the logged in state and signs out the user. While our efforts demonstrated one side of the database interaction (authentication and API for talking with the DB). The ty-main.rkt & tyimodel.rkt files illustrated the other side, specifically the insertion of posts (which utilize a forked version of our APIs).

#### Demo Download
https://github.com/oplS16projects/Timeline-Thing/releases

### Statement
A Timeline builder to help plan large scale projects

### Analysis
The idea is based on building a timeline from an existing database, so we will be working with databases like the ones from earlier in the semester.

### Data set or other source materials
Racket libraries:

`racket/include`

`racket/format`

`racket-include`

`racket/runtime-path`
  
`racket/date`

`web-server/formlets`

`web-server/templates`

`web-server/servlet`

`web-server/servlet-env`

`web-server/http`

`parser-tools/lex`

`xml`

`racket/list`

`db`

### Deliverable and Demonstration
A timeline builder that will allow users to create and edit timelines in real time.

### Evaluation of Results
We will know it will be successful if it works.

## Architecture Diagram
![Architecture] (https://github.com/oplS16projects/Timeline-Thing/blob/master/architecture.JPG?raw=true)

## Schedule

### First Milestone (Fri Apr 15)
Basic webpage and database structure.

### Second Milestone (Fri Apr 22)
Continued work on the front-end of the webpage.

### Final Presentation (last week of semester)
Functional timeline builder that allows the user to create and edit timelines.

## Group Responsibilities

### Jacob Suarez @Onamar
Jake is the team lead. Additionally, Jake will work on the database and backend.

### Tyrone Turrel @tturrell
Will work on user input and the front-end.

### Saurabh Verma @sv-uml
Saurabh will be working on the front-end (HTML and CSS) as well as assisting the team in the development of the backend architecture.
