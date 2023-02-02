Space Test v0.11

Features:

- ...umm, supports spaces in test case names?

  (But seriously: `make` tools are traditionally incapable of handling
  files with spaces in their names, so in order to keep the chilling
  frugality of this tool (to only depend on BusyBox, plus optionally on
  gnumake or nmake (both small executables that I might just toss into
  the repo later* "for completeness"...)), so, basically: overcoming
  that was the single biggest challenge in putting this together.
  Oh, BTW, see, even GitHub still can't support spaces in repo names! ;) )

  ----
  * Well, NMAKE.EXE is linked against a bunch of DLLs (still <1MB total,
    260K compressed!), so that's a shaky prospect, but as a figure of speech,
    it's still competitive...

Anyway:

- Very small, frugal, self-containing (just a bunch of shell scripts
  + some change, <1000 lines total)

- Depends on basically nothing (but BusyBox, and of course the toolset
  you may want to use for (auto)building stuff before testing)

- Everything-agnostic, can help testing anything (and basically anywhere)

- Despite the minimalism and early stage, still fairly comfy & flexible:
  - single-file or subdir test cases
  - cases can have a custom variation (build) of the (common) test subject
  - or basically any arbitrary test env/setup whatsoever
  - trivially lean & simple script format:

    RUN something
    EXPECT some result

  - or as shell commands:

    SH echo -n this
    EXPECT this

    SH echo newline
    EXPECT "newline
    "

    SH "echo Dir list:; ls -r"
    SH echo command 3
    EXPECT "Dir list:
    Hi from the test case dir!
    CASE
    command 3
    "

  - or mix in any normal .sh (BB ash) syntax:

    if [ -n "$SOME_FLAG" ]; then
        prepare_something         # no output capture
        RUN stuff                 # output captured as usual
        EXPECT "one thing"        # quoting these is a good habit!
    else
        prepare_something_else
        RUN stuff
        EXPECT "other thing"
    fi

- Multiple test (variant) runs in a single case:

    RUN some command
    RUN other command
    RUN command --with-params

    EXPECT "some result
    some other results
    accumulated
    " # (Assuming those commands print with trailing newlines.)

    or, equivalently, with interleaved EXPECTs:

    RUN some command
    EXPECT "some result
    "
    RUN other command
    EXPECT "some other results
    "
    RUN command --with-params
    EXPECT "accumulated
    "

  - or standalone "EXPECT" files (overriding any EXPECT clauses)

- Arbitrary multi-level test tree hierarchy

- Flexible runner:
  `run_cases` for all, or `run_cases some*`, or `run_cases test-this "and this"`,
  or with direct paths: `run_cases *.case`, or `run_cases ./here/tc-4.case`

- "GitHub-Actions-ready" MSVC and GCC autobuild (for both test-subject
  and custom test-case code)
  BTW, I've hacked this together just for this exact purpose, in fact.
  (It's ridiculously primitive and limited yet, and C++ only, etc.,
  but good enough for sales...)

- Doesn't require CMake (e.g. to replace trivial single-line compiler
  commands with multi-100 megs of opaque, fragile, ugly complexity)
