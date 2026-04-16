plugins {
    kotlin("jvm")
    kotlin("plugin.serialization")
}

dependencies {
    implementation(project(":packages:adapters-api"))
    implementation(project(":packages:application"))
    implementation("io.ktor:ktor-serialization-kotlinx-json-jvm:3.0.3")
}
