package archive.app

import io.ktor.client.request.forms.MultiPartFormDataContent
import io.ktor.client.request.forms.formData
import io.ktor.client.request.get
import io.ktor.client.request.post
import io.ktor.http.ContentType
import io.ktor.http.HttpStatusCode
import io.ktor.http.contentType
import io.ktor.http.Headers
import io.ktor.server.testing.testApplication
import kotlin.test.Test
import kotlin.test.assertEquals

class ArchiveApiApplicationTest {
    @Test
    fun `generic intake endpoint registers document`() = testApplication {
        application {
            archiveModule()
        }

        val response = client.post("/api/v1/documents/intake") {
            setBody(
                MultiPartFormDataContent(
                    formData {
                        append("file", "hello world".toByteArray(), Headers.build {
                            append("Content-Disposition", "filename=contract.pdf")
                            append("Content-Type", "application/pdf")
                        })
                        append("documentTypeHint", "contract")
                        append("sourceSystem", "manual-upload")
                        append("businessKey", "CTR-2026-0001")
                    }
                )
            )
        }

        assertEquals(HttpStatusCode.Created, response.status)
    }

    @Test
    fun `alfresco compatibility endpoint transforms and registers document`() = testApplication {
        application {
            archiveModule()
        }

        val response = client.post("/alfresco/api/-default-/public/alfresco/versions/1/nodes/-root-/children") {
            setBody(
                MultiPartFormDataContent(
                    formData {
                        append("file", "hello world".toByteArray(), Headers.build {
                            append("Content-Disposition", "filename=invoice-1001.pdf")
                            append("Content-Type", "application/pdf")
                        })
                        append("name", "invoice-1001.pdf")
                        append("nodeType", "cm:content")
                        append("archive:businessKey", "INV-1001")
                        append("archive:sourceSystem", "legacy-alfresco")
                    }
                )
            )
        }

        assertEquals(HttpStatusCode.Created, response.status)
    }
}
