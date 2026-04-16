plugins {
    kotlin("jvm")
    kotlin("plugin.serialization")
}

dependencies {
    implementation(project(":packages:adapters-api"))
    implementation(project(":packages:application"))
    implementation(project(":packages:domain"))
    implementation(project(":packages:ports"))
    implementation("io.ktor:ktor-server-core-jvm:3.0.3")
    implementation("io.ktor:ktor-serialization-kotlinx-json-jvm:3.0.3")
}
