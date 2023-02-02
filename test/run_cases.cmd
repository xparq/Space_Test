@echo off
rem Windows frontend for the real `run_cases` main script

rem Here's some pretty questionable heuristics for desperately trying to escape
rem to a proper shell, based on the assumption that folks using this are more
rem than likely also using Git, but even if not, they still may have a stray
rem instance of BusyBox hanging around on the PATH somewhere...
rem
rem But it's a minefield... E.g. if things are not set up favorably, FIND.EXE
rem may come first on the path, and if any unknown sh instance was picked up
rem (i.e. other than Git's?...), it would use the wrong command executables!
rem
rem (Alternatively, we might as well just ship a BB instance eventually...
rem It's just so big!... ;) Well then, maybe we can download one on-the-fly?)


rem !! Should start with an existing SHELL var first!...
rem !! And perhaps we should actually start with BB, and only fall back to Git!

setlocal enabledelayedexpansion

rem !!?? How to do this idiomatically, with an `if`?
sh --help 2>nul 1>nul && (
rem	On my pretty vanilla setup this is Git's GITROOT/usr/bin/sh.exe.
rem	And it differs from Git/bin/sh in that it won't find its fellow POSIX commands
rem	at Git/usr/bin (if that dir is not on the PATH)! So, it's unusable.
rem	set _sh_=sh
rem	goto endif
)
rem else
rem	This, however, will run the Git GNU commands first:
	if not exist "%PROGRAMFILES%\Git\bin\sh.exe" (
	set _sh_="%PROGRAMFILES%\Git\bin\sh.exe"
		rem See at the end, why not set "name=val"!
	echo Using Git's ^(hopefully^) "POSIX-enforcing" sh variant...
) else (
	set BB_IN_SPACE=%~dp0_engine/busybox.exe

	if exist "!BB_IN_SPACE!" (
		set _sh_="!BB_IN_SPACE!" sh
			rem See at the end, why not set "name=val"!
		echo Using a local BusyBox ^("!BB_IN_SPACE!"^) for shell...
		goto endif
	)

	rem Try downloading BB... ;)
	rem Oh yeah, except...:
	rem - PS scripting seems to be disabled by deafult in Windows!
	rem   But... Even more surprisingly, it means nothing, as it can be overridden indiscriminately! :)
	rem ! Also: DO NOT run it in the same console window, because it could fuck up its layout!... :-o
	rem ! And don't forget /wait to make it synchronous, for checking its result!

	start /wait /min PowerShell -ExecutionPolicy Bypass -File _engine/download_file.ps1 "https://frippery.org/files/busybox/busybox.exe" "!BB_IN_SPACE!"
	rem if not errorlevel 1 goto endif
	rem - Perhaps more robust and on the point:
	if not exist "!BB_IN_SPACE!" (

		echo - ERROR: Failed to download BusyBox^!

		busybox sh --help 2>nul 1>nul && (
			set _sh_=busybox sh
				rem See at the end, why not set "name=val"!
			echo ...but found one on the PATH, using it:
			where busybox
			goto endif
		)

		echo Giving up.
		exit 1
	)

	set _sh_="!BB_IN_SPACE!" sh
		rem See at the end, why not set "name=val"!
	echo Using a downloaded BusyBox ^("!BB_IN_SPACE!"^) for shell...
)
:endif

rem NOTE: _sh_ is not a single word, but the entire command string!
rem       So it can't be quoted here, because it would be treated as a filename...
rem       So, the cmd filename itself must already be quoted!
%_sh_% %~pd0run_cases %*
