package archive.adapters.compat.alfresco

import archive.adapters.api.GenericMultipartIntakePayload
import archive.application.intake.result.DocumentIngestResult
import archive.domain.intake.model.DocumentMetadata

object AlfrescoCompatibilityMapper {
    fun toGenericRequest(request: AlfrescoMultipartIntakePayload): GenericMultipartIntakePayload =
        GenericMultipartIntakePayload(
            fileName = request.name,
            contentType = request.contentType,
            content = request.content,
            documentTypeHint = request.nodeType,
            metadata = DocumentMetadata(
                sourceSystem = request.sourceSystem,
                businessKey = request.businessKey,
            ),
        )

    fun toCompatibilityResponse(result: DocumentIngestResult): AlfrescoCreateNodeResponse =
        AlfrescoCreateNodeResponse(
            entry = AlfrescoNodeEntry(
                id = result.documentId,
                name = result.fileName,
                nodeType = result.documentTypeHint ?: "cm:content",
                isFile = true,
            )
        )
}
