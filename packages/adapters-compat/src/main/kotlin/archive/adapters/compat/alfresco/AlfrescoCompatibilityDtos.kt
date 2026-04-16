package archive.adapters.compat.alfresco

import kotlinx.serialization.Serializable

data class AlfrescoMultipartIntakePayload(
    val name: String,
    val nodeType: String?,
    val content: String,
    val sourceSystem: String,
    val businessKey: String,
    val contentType: String,
)

@Serializable
data class AlfrescoNodeEntry(
    val id: String,
    val name: String,
    val nodeType: String,
    val isFile: Boolean,
)

@Serializable
data class AlfrescoCreateNodeResponse(
    val entry: AlfrescoNodeEntry,
)
