Space Test v0.15
Superfrugal autotest framework, in case you got stranded on a dead planet

Features:

- ...umm, supports spaces in test case names?

  (But seriously: make tools (and many other utilities) are traditionally
  hostile to files with spaces in their names, so in order to keep the chilling
  frugality of this tool (to only depend on whatever sh-like shell it can find
  to run itself), and its stubbornness to just run, dammit, no matter what,
  constantly overcoming space-issues all the way through has been perhaps
  the single biggest challenge. (See e.g. GH issue #25, #42...)
  Oh, BTW, see, even GitHub still can't support spaces in repo names! ;) )

Anyway:

- Very small, frugal, self-containing (just a bunch of shell scripts
  + some change)

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
  `run_cases` for all, or `run_cases some*`, or `run_cases this "and that"`

- "GitHub-Actions-ready" MSVC and GCC autobuild (for both test-subject
  and custom test-case code)
  BTW, I've hacked this together just for this exact purpose, in fact.
  (It's ridiculously primitive and limited yet, and C++ only, etc.,
  but good enough for sales...)

- Doesn't require CMake (e.g. to replace trivial single-line compiler
  commands with multi-100 megs of opaque, fragile, ugly complexity)
