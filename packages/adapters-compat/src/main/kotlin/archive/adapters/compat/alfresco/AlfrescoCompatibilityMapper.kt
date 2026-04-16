package archive.adapters.compat.alfresco

import archive.adapters.api.GenericMultipartIntakePayload
import archive.domain.intake.model.DocumentMetadata
import archive.ports.readmodel.DocumentIngestView

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

    fun toCompatibilityResponse(view: DocumentIngestView): AlfrescoCreateNodeResponse =
        AlfrescoCreateNodeResponse(
            entry = AlfrescoNodeEntry(
                id = view.documentId,
                name = view.fileName,
                nodeType = view.documentTypeHint ?: "cm:content",
                isFile = true,
            )
        )
}
