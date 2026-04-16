package archive.domain.intake.model

import java.util.UUID

@JvmInline
value class DocumentId(val value: String) {
    init {
        require(value.isNotBlank()) { "DocumentId cannot be blank" }
    }

    companion object {
        fun generate(): DocumentId = DocumentId(UUID.randomUUID().toString())
    }
}
