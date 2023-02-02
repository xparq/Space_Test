@echo off

rem Here's some pretty pathetic heuristics for desperately trying to escape
rem to a proper shell, based on the assumption that folks using this are more
rem than likely also using Git, but even if not, they still may have a stray
rem instance of BusyBox hanging around on the PATH somewhere...
rem
rem But it's a minefield... E.g. if things are not set up favorably, FIND.EXE
rem may come first on the path, and a "random" sh instance found (e.g. that
rem of Git's) could pick up that, instead of the "real" `find` installed
rem alongside it!... :-o )
rem
rem (Alterantively, we might as well just ship a BB instance eventually...)

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
       if exist  "%PROGRAMFILES%\Git\bin\sh.exe" (
	set _sh_="%PROGRAMFILES%\Git\bin\sh.exe"
	echo Using Git's ^(hopefully^) "POSIX-enforcing" sh variant...
) else (
	busybox sh --help 2>nul 1>nul && (
		set _sh_=busybox sh
		echo Using BusyBox...
		goto endif
	)

	echo - ERROR: No 'sh' or 'busybox' was found on the PATH, giving up.
	rem Try to download it or something... ;)
	exit 1
)
:endif

%_sh_% %~pd0run_cases %*
