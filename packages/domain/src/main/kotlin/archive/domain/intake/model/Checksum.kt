package archive.domain.intake.model

import kotlinx.serialization.Serializable

@Serializable
data class Checksum(
    val algorithm: String,
    val value: String,
) {
    init {
        require(algorithm.isNotBlank()) { "Checksum algorithm cannot be blank" }
        require(value.isNotBlank()) { "Checksum value cannot be blank" }
    }
}
