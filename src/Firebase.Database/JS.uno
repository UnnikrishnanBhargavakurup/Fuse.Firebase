using Uno;
using Uno.UX;
using Uno.Threading;
using Uno.Text;
using Uno.Platform;
using Uno.Compiler.ExportTargetInterop;
using Uno.Collections;
using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;

namespace Firebase.Database.JS
{
  /**
   *  
   */
  [UXGlobalModule]
  public sealed class DatabaseModule : NativeEventEmitterModule
  {

    static readonly DatabaseModule _instance;

    public DatabaseModule() 
      : base(true, "onDataChange")
    {
      if(_instance != null) {
        return;
      }

      Firebase.Database.RealtimeDatabase.onChanged += OnChanged;
      Firebase.Database.RealtimeDatabase.OnError += OnError;

      Resource.SetGlobalKey(_instance = this, "Firebase/Database");
      
      AddMember(new NativePromise<string, string>("Put", Put));
      AddMember(new NativeFunction("Listen", (NativeCallback)Listen));
    }
    
    /**
     * Push data to firebase database.
     */
    Future<string> Put(object[] args)
    {
      Firebase.Database.RealtimeDatabase mDB = new Firebase.Database.RealtimeDatabase();
      mDB.Put((string)args[0], (string)args[1]);
      return mDB;
    }

    /**
     * Listen to firebase database events.
     */
    static object Listen(Context c, object[] args)
    {
      var arg = args[0] as string;
      if (arg != null) {
        RealtimeDatabase.AttachEvents(arg);
      }
      else {
        throw new Exception("Listen() requires exactly 1 parameter.");
      }
      return null;
    }

    private void OnChanged(string data)
    {
      debug_log data; 
      Emit("onDataChange", data);
    }

    private void OnError(string data)
    {
      Emit("onDataChange", data);
    }
  }
}
