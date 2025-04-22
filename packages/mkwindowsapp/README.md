# mkWindowsApp

from https://github.com/emmanuelrosa/erosanix

`mkWindowsApp` is a Nix function whichinstallsWine-compatibleWindowsapplications on [NixOS](https://nixos.org).`mkWindowsApp`retains someof thebenefits provided by NixOS in the way Windowsapplicationsareinstalled.Namely:

- Multiple versions of a Windows application canbeinstalledsimultaneously;Although only one can be active in the environment,ofcourse.
- Windows applications can be *rolled back* along withothernativeLinuxapplications installed with Nix.
- Installations are reproducible; Though sometimes not to the sameextentasnativeapplications.

`mkWindowsApp` now also features improved support for Windowsgamesthroughthe`enableVulkan` and `enableHUD` attributes.

## How does it work?

`mkWindowsApp` dynamically creates $WINEPREFIX-es (aka. WineBottles)atruntimeusing an overlay filesystem. The overlay filesystem consistsofthreefilesystemlayers (listed from lowest to highest):

1.  The *Windows* layer: This layer consists of an initialized WineBottle.Itcanbe used by multiple Windows applications, but no applications(otherthanthedefaults installed by Wine) are installed in this layer.Duringruntimethislayer is mounted read-only.
2.  The *App* layer: This layer consists of theinstalledWindowsapplication.During runtime this layer is mounted read-only.
3.  The *Read/Write* layer: This layer can be written to and servesastheupperlayer of the overlay. This layer is created at runtime andisdiscardedwhenthe Windows application terminates.

These layers are stored not in the Nix store,butratherin`$HOME/.cache/mkWindows`. Hence, what actually happens is`mkWindows`createsascript[^1] which when executed installs and then runs aWindowsapplication.Thesaid script will create the necessary layers and then usethem tocreate aWineBottle for the application to run in. Once theapplicationterminates,theentire Wine Bottle is discarded, but the layers areleft intact.

## FAQ

### What is mkWindowsAppNoCC?

There are two variants of the mkWindowsApp function:

1.  `mkWindowsApp` - This is the original version and itusesNixpkgs'`stdenv`,which includes the `gcc` compiler.
2.  `mkWindowsAppNoCC` - This is the same as `mkWindowsApp` exceptthatitusesNixpkgs' `stdenvNoCC`, therefore it doesn't include the`gcc`compiler.Thisreduces the number of dependencies, making thederivation"lighter." Youcanprobably use this variant and it will work justfine.

### Since Wine Bottles are temporary, what happens to files created when a Windows application is running?

-Any files not saved outside of the Wine Bottle are discardedaswell.Therefore,package maintainers must account for where importantfilesarestored, such asconfiguration files, to ensure they are stored outsideoftheWine Bottle;Seethesection[How to persist settings](#how-to-persist-settings). Inaddition,usersmustensure to use the Z:\ drive when saving important information.

### Do the layers need to be garbage-collected?

Yes, the package `mkwindowsapp-tools` has a garbage collector whichshouldberunafter `nix-collect-garbage`. You can runitasfollows:`nix run github:emmanuelrosa/erosanix#mkwindows-tools`

### How does the garbage collector know what can be deleted?

When the launcher script runs, it appends the path to the hiddencopyofitselfinto the *references file* of the windows and applayers.These_referencesfiles_ act like the Nix store roots; They *point* tocontent, inthiscase,layers. The garbage collector simply checks if the pathsinthe_referencesfiles_ still exist in the Nix store. If they do, whichindicatesthatthelauncher script still exists, then the garbage collectorknowsthatparticularlayer must not be deleted.

### How does an app know which layers to use?

Each layer is identified by an input hash, which similar toNix,encapsulatesthedependencies of the layer. The Windows layer input hashpre-imageis theNixstore path to Wine, DLL overrides, and the internal`mkWindowsApp`APInumber.The app layer input hash pre-image is simply thescriptgeneratedby`mkWindowsApp`, which encapsulates all of the inputs relatedtotheapplicationbeing installed.

### How do you install a Windows application that uses `mkWindowsApp`?

The same way you install any other Nix package. But note thatinstallingtheNixpackage doesn't actually install the Windowsapplication.TheWindowsapplication is installed when you run the (launcher)script whichisinstalledby the Nix package. When a Windows applicationisinstallednon-interactively,it somewhat gives the illusion of havinginstalledtheapplication before-hand.However, there's a noticeable lag in startuptimeiflayers need to be created.

### As an end-user, how will this work in practice?

Let's use Notepad++ as an example:

1.  First you need to have a NixOS system built as a Nix Flake, since thisrepoisaNix Flake.
2.  Next, you add the Nix Flake `github:emmanuelrosa/erosanix` asaninput;Irecommend setting it up to follow your Nixpkgs input.
3.  Then, you add thepackage`erosanix.packages."${system}".notepad-plus-plus`toyour`environment.systemPackages`.
4.  Next, run `nixos-rebuilt switch`.
5.  Use your favorite app launcher UI (or the command line)torun`notepad++`.Alternatively, you can use `xdg-open` or a file managertoopen atext file.
6.  If a *Windows layer* needs to be created, you'll see anotificationfromWine.Then, Notepad++ will be installed and launched.

### How can I package a Windows application with `mkWindowsApp`?

I recommendstudyingtheexample[sumatrapdf-nix](https://github.com/emmanuelrosa/sumatrapdf-nix).It'saNixFlake which uses `mkWindowsApp` to package SumatraPDF.

## How to persist settings

Early releases of `mkWindowsApp` required package maintainerstohandlethepersistance of files which need to be retainedacrossmultipleexecutions.Usually, these are configuration files, or the entireuserregistry(user.reg).However, newer releases of `mkWindowsApp` providetheattribute`fileMap` whichlets package maintainers easily set up what filestolink intothe $WINEPREFIX.Here's an example of how to use the attribute:

```
mkWindowsApp rec {
  ...
  fileMap = { "$HOME/.config/Notepad++" = "drive_c/users/$USER/Application Data/Notepad++"; 
  };
```

Using the example above, here's an explanation of what will happenwhenusersrunthe launcher script:

1.  Before running Notepad++, `mkWindowsApp`willlookfor$HOME/.config/Notepad++, and if it exists, it will create a symlink to it at$WINEPREFIX/drive_c/users/$USER/Application Data/Notepad++. Alternatively, if$WINEPREFIX/drive_c/users/$USER/Application Data/Notepad++ exists but$HOME/.config/Notepad++doesn't,thenthe file/directory will be copied outfrom the $WINEPREFIX intothe"source"path, and then symlinked as describedearlier.
2.  After Notepad++ terminates, `mkWindowsApp` will cycle through thesamelistofmappings and copy any of the files/directories which did notexistwhentheapplication was launched, to the "source" path. Thiseffectivelypersistssuchfiles so that they can be symlinked the next time theapplicationislaunched.

By default, the Wine registry is not persisted. To enableautomaticpersistenceofthe Wine registry files, set the `persistRegistry`attribute inyour packageto`true`. The registry filesaresavedat`$HOME/.config/mkWindowsApp/wine-$wineMajorVersion/${pname}`.

The registry files used to be savedat`$HOME/.config/mkWindowsApp/${pname}`,butnow they are versioned according totheWine major version. This is to keepupwith Wine changes to the defaultregistrysettings.

For areal-worldexamplesee[sumatrapdf-nix](https://github.com/emmanuelrosa/sumatrapdf-nix).

## How can I access Wine tools such as winecfg?

NOTICE: By default, the Wine registry is not persisted, so if youwanttousewinecfg to tweak things you need to enable registry persistence.Seethesection_How to persist settings_.

There's now an environment variable which can be used to get droppedintoashellafter setting up the WINEPREFIX. Simply settheenvironmentvariable`WA_RUN_APP=0` before running the app (launcher).When`WA_RUN_APP` isnot setto `1`, the WINEPREFIX is set up, but the app isnotexecuted. Once intheshell, you can run Wine tools; The WINEPREFIX willalreadybe set.

## If my build fails during the winAppInstall phase, how can I clean things up?

There's now an environment variable you can set to cause thelauncherscripttodelete the app layer. Simply set the `WA_CLEAN_APP` environmentvariableto`1`.

Note that the Windows layer will not be deleted.

[^1]: The script isconceptuallybasedon[wrapWine](https://github.com/lucasew/nixcfg/blob/fd523e15ccd7ec2fd86a3c9bc4611b78f4e51608/packages/wrapWine.nix).
