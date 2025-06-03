package mobile;

#if android
import lime.system.JNI;
#end
import haxe.io.Path;
import lime.system.System;
import lime.app.Application;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

/** 
* @author MaysLastPlay, MarioMaster (MasterX-39)
* @version: 0.1.4
**/

class MobileUtil {
    public static var currentDirectory:String = null;
    public static var path:String = '';

    public static function getDirectory():String {
        #if android
        currentDirectory = getExternalStorageDirectory() + '/.' + Application.current.meta.get('file');
        #elseif ios
        currentDirectory = System.applicationStorageDirectory;
        #end
        return currentDirectory;
    }

    #if android
    // Métodos JNI para acceder a funcionalidades de Android
    private static var getExternalStorageDirectory_jni = JNI.createStaticMethod("android/os/Environment", "getExternalStorageDirectory", "()Ljava/io/File;");
    private static var getAbsolutePath_jni = JNI.createStaticMethod("java/io/File", "getAbsolutePath", "()Ljava/lang/String;");
    private static var getSdkInt_jni = JNI.createStaticMethod("android/os/Build$VERSION", "SDK_INT", "()I");
    private static var requestPermissions_jni = JNI.createStaticMethod("org/haxe/lime/GameActivity", "requestPermissions", "([Ljava/lang/String;)V");
    private static var isExternalStorageManager_jni = JNI.createStaticMethod("android/os/Environment", "isExternalStorageManager", "()Z");
    private static var requestManageMedia_jni = JNI.createStaticMethod("org/haxe/extension/Permissions", "requestSetting", "(Ljava/lang/String;)V");

    public static function getExternalStorageDirectory():String {
        var file = getExternalStorageDirectory_jni();
        return getAbsolutePath_jni(file);
    }

    public static function getSdkInt():Int {
        return getSdkInt_jni();
    }

    public static function requestPermissions(permissions:Array<String>):Void {
        requestPermissions_jni(permissions);
    }

    public static function isExternalStorageManager():Bool {
        return isExternalStorageManager_jni();
    }

    public static function requestSetting(setting:String):Void {
        requestManageMedia_jni(setting);
    }

    public static function getPermissions():Void {
        path = Path.addTrailingSlash(getExternalStorageDirectory() + '/.' + Application.current.meta.get('file'));
  
        if(getSdkInt() >= 33) {
            requestPermissions(['android.permission.READ_MEDIA_IMAGES', 
                              'android.permission.READ_MEDIA_VIDEO', 
                              'android.permission.READ_MEDIA_AUDIO']);
            
            if (!isExternalStorageManager()) {
                requestSetting('MANAGE_EXTERNAL_STORAGE');
            }
        } else {
            requestPermissions(['android.permission.READ_EXTERNAL_STORAGE', 
                              'android.permission.WRITE_EXTERNAL_STORAGE']);
        }

        try {
            if(!FileSystem.exists(getDirectory()))
                FileSystem.createDirectory(getDirectory());
        } catch (e:Dynamic) {
            trace(e);
            Application.current.window.alert("Seems like you didn't accept the Permissions. Please accept them to be able to run the game.", 'Uncaught Error');
            System.exit(0);
        }
    }

    public static function save(fileName:String = 'Ye', fileExt:String = '.json', fileData:String = 'you didnt cooked, try again!') {
        if (!FileSystem.exists(getDirectory() + 'saved-content'))
            FileSystem.createDirectory(getDirectory() + 'saved-content');

        File.saveContent(getDirectory() + 'saved-content/' + fileName + fileExt, fileData);
    }
    #end
}
