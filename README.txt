Space Test v0.05

Features:

- ...umm, supports spaces in test case names?

  (But seriously: `make` tools are traditionally incapable of handling
  files with spaces in their names, so in order to keep the chilling
  frugality of this tool (to only depend on BusyBox, plus either
  gnumake or nmake (both tiny executables that I might just toss into
  the repo later* "for completeness"...)), so, basically: overcoming
  that was the single biggest challenge in putting this together.
  Oh, BTW, see, even GitHub still can't support spaces in repo names! ;) )

  ----
  * Well, NMAKE.EXE is linked against a bunch of DLLs (still <1MB total,
    260K compressed!), so that's a shaky prospect, but as a figure of speech,
    it's still competitive...

Anyway:

- Everything-agnostic, can help testing anything (and anywhere, with a
  working (a)sh shell)

- Frugal & self-containing; depends on basically nothing (but BusyBox,
  and optionally gnumake/nmake, if you also want to autobuild stuff;
  and even the built-in `make` of BusyBox would suffice if you didn't
  allow spaces in filenames -- but who'd want to torture themselves?...)

- Extremely small (2.5 shell scripts + some change; <500 lines total)

- Still fairly comfy & flexible test case support:
  - single-file or subdir test cases
  - cases can have a custom variation (build) of the (common) test subject
  - or basically any arbitrary test env/setup whatsoever
  - trivially lean & simple script format:

    RUN some exe
    EXPECT some result

  - or running shell commands:

    SH echo -n this
    EXPECT this

    SH echo this with newline
    EXPECT "this with newline
    "

    SH "echo command 1; echo command 2"
    SH echo command 3
    EXPECT "command 1
    command 2
    command 3
    "

  - or mix with anything in normal BB .sh (ash) syntax, as usual:

    if [ -n "$SOME_FLAG" ]; then
        prepare_something         # no output captured
        RUN stuff
        EXPECT "one thing"        # Quoting these is a good habit.
    else
        prepare_something_else    # (again, with off-band outputs)
        RUN stuff
        EXPECT "other thing"
    fi

- Multiple test (variation) runs in a single case:

    RUN some command
    RUN other command
    RUN command --with-params

    EXPECT "some result
    some other results
    accumulated
    " # (Assuming those commands print with trailing newlines.)

    or, equivalently:

    RUN some command
    EXPECT "some result
    "
    RUN other command
    EXPECT "some other results
    "
    RUN command --with-params
    EXPECT "accumulated
    "

  - Or standalone "expect" files, too.

- "GitHub-Actions-ready" MSVC and GCC autobuild (for both test-subject
  and custom test-case code)
  BTW, I've hacked this together for this exact purpose, in fact.
  (It's ridiculously primitive and limited yet, and C++ only, etc.,
  but good enough for sales...)

- Doesn't require CMake (e.g. to replace trivial single one-liner compiler
  commands with multi-100 megs of opaque, fragile, ugly complexity).
