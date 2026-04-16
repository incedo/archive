package archive.domain.intake.model

import kotlinx.serialization.Serializable

@Serializable
data class DocumentMetadata(
    val sourceSystem: String,
    val businessKey: String,
) {
    init {
        require(sourceSystem.isNotBlank()) { "sourceSystem is required" }
        require(businessKey.isNotBlank()) { "businessKey is required" }
    }
}
