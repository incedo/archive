plugins {
    kotlin("jvm")
}

dependencies {
    implementation(project(":packages:domain"))
    implementation(project(":packages:ports"))

    testImplementation(kotlin("test"))
}
