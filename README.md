# BetterReminders
A simple reminders app with advanced features

This app is meant for school students on multi day schedueles(A day/B day/C day etc.)

Requires iOS 10
## Swift 3
This app has been written in scratch from the ground up using Swift 3.0

This app makes use of Apples latest and greatest frameworks such as UNNotifcation and UIFeedbackGenerator
## Goals
When creating this app I had two main goals in mind: Create an app that reminds you to write down your homework and create an app that estimates how long it will take to finish homework. This app meets both those goals perfectly. First for notifications. This app provides a notificatoin at the end of every class the user has defined asking for any homework. The notification can then add homework to the app from the notification. Now for estimated time, the app asks the user for the estimated time to complete each task and then displays the total time to the user in several different ways allowing for the user to allot their time easily.
## Features
- Add as many customizable "classes" as the user would like with the following attributes
  - Name
  - Start Time
  - End Time
  - School Day
- Add "tasks" for each school class, tasks have the following attributes:
  - Name
  - Due Date
  - Estimated Time to Complpete
  - Completed
- Clean and classy PopoverUI to add classes and tasks
- Ability to edit classes and tasks
- Multiple task view modes
  - Show all tasks
  - Show uncompleted tasks
  - Show completed tasks
- Classes ordered by school day and by start time
- Ability to mark all tasks for a given class done in a single tap
- Estimated time to complete
  - User can guess how long each assingment will take allowing for better time allocation
  - Estimated time to complete for the following
    - Individual task - Displayed on task detail label
    - All tasks in a class - Displayed on class detail label and large label on task view
    - All tasks in all classes - Displayed on large label on class view
- Notification Support
  - Notifcations master toggle
  - Notification to user at the end of each class
  - Notifications trigger every week day as long as notifications are enabled
  - Notifications have a text box that takes a string takes string and it is parsed for the following atributes:
    - (format: `"className="Physics" name="read" dueDate="4/1/17" timeToComplete="1:15""`)
    - `className`
    - `dueDate`
    - `timeToComplete`
    - `name`
  - Notification body contains arguments and how to use them so as not to confuse the user
  - Parsed notification string turns into task for the given class with the given attributes
- Given a file "Classes.json", in the correct format, the user can load classes from a json if compiling from source for easy and quick adding of classes
- 3D Touch Peek and Pop Support
- Full support for all iOS 10 devices
- Large focus on clean code and stability
    - Each function is fully documented using swift markup
    - Code is organized via mark up (MARK, TODO, etc)
## TODO
- Dark mode UI
- Quick add tasks
- Add reminders reminding user to complete task near due date
- Imporve optional checking
