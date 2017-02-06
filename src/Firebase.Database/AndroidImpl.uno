using Uno;
using Uno.UX;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;
using Fuse;
using Fuse.Triggers;
using Fuse.Controls;
using Fuse.Controls.Native;
using Fuse.Controls.Native.Android;
using Uno.Threading;

namespace Firebase.Database
{

  [ForeignInclude(Language.Java, "android.util.Log", 
                  "java.util.ArrayList", 
                  "java.util.List", 
                  "android.graphics.Color",
                  "com.google.firebase.database.DatabaseReference",
                  "com.google.firebase.database.DatabaseReference.CompletionListener",
                  "com.google.firebase.database.DatabaseException",
                  "com.google.firebase.database.FirebaseDatabase",
                  "com.google.firebase.database.ValueEventListener",
                  "com.google.firebase.database.DatabaseError",
                  "com.google.firebase.database.DataSnapshot",
                  "com.google.firebase.auth.FirebaseAuth"
                  )]
  [Require("Gradle.Dependency.ClassPath", "com.google.gms:google-services:3.0.0")]
  [Require("Gradle.Dependency.Compile", "com.google.firebase:firebase-core:9.2.0")]    
  [Require("Gradle.Dependency.Compile", "com.google.android.gms:play-services-auth:10.0.0")]
  [Require("Gradle.Dependency.Compile", "com.google.firebase:firebase-crash:10.0.0")]
  [Require("Gradle.Dependency.Compile", "com.google.firebase:firebase-auth:10.0.0")]
  [Require("Gradle.Dependency.Compile", "com.google.firebase:firebase-database:10.0.0")]
  [Require("Gradle.BuildFile.End", "apply plugin: 'com.google.gms.google-services'")]
  extern(android)
  internal class RealtimeDatabase : Promise<string>
  {
      
    private static String TAG = "Firebase.Database";
    internal static event Action<string> onChanged;
    internal static event Action<string> OnError;

    public RealtimeDatabase() {
      
    }   

    /**
     * Attach event listners to the path.
     */
    [Foreign(Language.Java)]
    public static void AttachEvents(string path)
    @{
        DatabaseReference mDatabase = FirebaseDatabase.getInstance().getReference().child(path);
        // Read from the database
        mDatabase.addValueEventListener(new ValueEventListener() {
          @Override
          public void onDataChange(DataSnapshot dataSnapshot) {
            // This method is called once with the initial value and again
            // whenever data at this location is updated.
            String value = dataSnapshot.getValue(String.class);
            @{triggeronDataChange(string):Call(value)};
            Log.d(@{TAG}, "Value is: " + value);
          }
          @Override
          public void onCancelled(DatabaseError error) {
            // Failed to read value
            @{triggerCancelled(string):Call(error.getDetails())};
            Log.d(@{TAG}, "Failed to read value.", error.toException());
          }
        });
    @}

    /**
     * Push data to doucument.
     * @param path
     *  path path
     */
    [Foreign(Language.Java)]
    public void Put(string path, string data)
    @{
        DatabaseReference mDatabase = FirebaseDatabase.getInstance().getReference();
        try {
          mDatabase.child(path).setValue(data, new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError error, DatabaseReference ref) {
              if (error != null) {
                @{RealtimeDatabase:Of(_this).Reject(string):Call("Data could not be saved. " + error.getMessage())};
              } else {
                @{RealtimeDatabase:Of(_this).Resolve(string):Call("Data saved successfully.")};
              }
            }
          });
        } catch (DatabaseException error) {
          @{RealtimeDatabase:Of(_this).Reject(string):Call("Error occurred. " + error.getMessage())};
          Log.e(@{TAG}, "Error occurred", error);
        }
    @}

    /**
     * Rais onchage event.
     */ 
    private static void triggeronDataChange(string data)
    {
      var handler = onChanged;
      if (handler != null) {
        handler(data);
      }
    }

    /**
     * Rais onerror event.
     */ 
    private static void triggerCancelled(string error)
    {
      var handler = OnError;
      if (handler != null) {
        handler(error);
      }
    }

    void Reject(string reason) { 
      Reject(new Exception(reason)); 
    }
  }
  
  /**
   * For client side fanout
   */
  [ForeignInclude(Language.Java, "android.util.Log", 
                  "java.util.ArrayList", 
                  "java.util.List", 
                  "android.graphics.Color",
                  "com.google.firebase.database.DatabaseReference",
                  "com.google.firebase.database.DatabaseReference.CompletionListener",
                  "com.google.firebase.database.DatabaseException",
                  "com.google.firebase.database.FirebaseDatabase",
                  "com.google.firebase.database.ValueEventListener",
                  "com.google.firebase.database.DatabaseError",
                  "com.google.firebase.database.DataSnapshot",
                  "com.google.firebase.auth.FirebaseAuth"
                  )]
  [Require("Gradle.Dependency.ClassPath", "com.google.gms:google-services:3.0.0")]
  [Require("Gradle.Dependency.Compile", "com.google.firebase:firebase-core:9.2.0")]    
  [Require("Gradle.Dependency.Compile", "com.google.android.gms:play-services-auth:10.0.0")]
  [Require("Gradle.Dependency.Compile", "com.google.firebase:firebase-crash:10.0.0")]
  [Require("Gradle.Dependency.Compile", "com.google.firebase:firebase-auth:10.0.0")]
  [Require("Gradle.Dependency.Compile", "com.google.firebase:firebase-database:10.0.0")]
  [Require("Gradle.BuildFile.End", "apply plugin: 'com.google.gms.google-services'")]
  extern(android)
  internal class FanOut
  {

  }
}
