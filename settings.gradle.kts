rootProject.name = "archive"

include(
    ":packages:domain",
    ":packages:application",
    ":packages:ports",
    ":packages:adapters-api",
    ":packages:adapters-compat",
    ":apps:archive-api",
)
