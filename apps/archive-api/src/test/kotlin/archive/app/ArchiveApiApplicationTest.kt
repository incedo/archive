package archive.app

import io.ktor.client.request.forms.MultiPartFormDataContent
import io.ktor.client.request.forms.formData
import io.ktor.client.request.get
import io.ktor.client.request.post
import io.ktor.client.statement.bodyAsText
import io.ktor.client.request.setBody
import io.ktor.http.ContentType
import io.ktor.http.HttpStatusCode
import io.ktor.http.contentType
import io.ktor.http.Headers
import io.ktor.server.testing.testApplication
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

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

        val ingestLocation = response.bodyAsText()
        assertTrue(ingestLocation.contains("\"status\":\"REGISTERED\""))
        assertTrue(ingestLocation.contains("\"checksumAlgorithm\":\"SHA-256\""))
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

    @Test
    fun `registered document can be queried by id`() = testApplication {
        application {
            archiveModule()
        }

        val createResponse = client.post("/api/v1/documents/intake") {
            setBody(
                MultiPartFormDataContent(
                    formData {
                        append("file", byteArrayOf(0x00, 0x01, 0x02, 0x03), Headers.build {
                            append("Content-Disposition", "filename=evidence.bin")
                            append("Content-Type", "application/octet-stream")
                        })
                        append("sourceSystem", "scanner")
                        append("businessKey", "BIN-0001")
                    }
                )
            )
        }

        val body = createResponse.bodyAsText()
        val documentId = """"documentId":"([^"]+)"""".toRegex()
            .find(body)
            ?.groupValues
            ?.get(1)
            ?: error("documentId missing from response")

        val getResponse = client.get("/api/v1/documents/$documentId/ingest")

        assertEquals(HttpStatusCode.OK, getResponse.status)
        assertTrue(getResponse.bodyAsText().contains("evidence.bin"))
    }

    @Test
    fun `generic intake endpoint returns bad request when required metadata is missing`() = testApplication {
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
                        append("sourceSystem", "manual-upload")
                    }
                )
            )
        }

        assertEquals(HttpStatusCode.BadRequest, response.status)
        assertTrue(response.bodyAsText().contains("businessKey is required"))
    }
}
