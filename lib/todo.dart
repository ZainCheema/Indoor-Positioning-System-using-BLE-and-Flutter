/* TODO: There needs to be an init method that is called before the screens are shown,  
  creating the User object, performing suitable checks, and instantiating suitable paths,
  this would be done in the initState() of app.dart */


/* TODO:  A store has to be made to hold data that needs to be exposed between both screens,
such as nearby users, User object, beacon hash map etc.*/


/* TODO: Make it such that the User is created when bluetooth and wifi is on, 
and the beacon is advertising. If any of these are turned off, a
 dialog is sprung to turn these back on, 
 and the user is temporarily removed from the database
*/

/* TODO: The UUID of the advertised Beacon should be the same as the users UUID. IBeacon uses the
full UUID, but Eddystone only uses the first 20, so a different check will have to be implemented for
those on Android to add them to the list of users */

/* TODO: When the app is closed, remove the User json from the database. 
There should be zero data kept in the firestore database when all instances of the app are closed*/

/* TODO: The direction of the user is stored in firestore, and tied to User. Distance isn't stored
in firestore, tied to beacon hash*/