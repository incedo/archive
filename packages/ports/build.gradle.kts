plugins {
    kotlin("jvm")
    kotlin("plugin.serialization")
}

dependencies {
    implementation(project(":packages:domain"))
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.8.0")
}
