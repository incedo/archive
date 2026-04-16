rootProject.name = "archive"

include(
    ":packages:domain",
    ":packages:application",
    ":packages:ports",
    ":packages:adapters-api",
    ":packages:adapters-compat",
    ":packages:adapters-postgres",
    ":apps:archive-api",
)
