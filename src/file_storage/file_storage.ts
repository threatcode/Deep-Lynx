import Result from "../result"
import {Readable} from "stream";
import Config from "../config"
import AzureBlobImpl from "./azure_blob_impl";
import MockFileStorageImpl from "./mock_impl";

export interface FileStorage {
    uploadPipe(filepath:string, filename: string, stream: Readable | null, contentType?:string, encoding?:string,): Promise<Result<FileUploadResponse>>
    deleteFile(filepath:string): Promise<Result<boolean>>
    name(): string
}

export type FileUploadResponse = {
    filename: string
    filepath: string
    size: number // size in KB
    metadata: {[key:string]: any} // adapter specific metadata if needed
    adapter_name: string
}

// Returns an instantiated FileStorage provider if provider method is set, or user
// can provide a specific adapter name to fetch an instance of specified adapter
export default function FileStorageProvider(adapterName?: string): FileStorage | null {
    switch ((adapterName) ? adapterName : Config.file_storage_method) {
        case "azure_blob_storage": {
            return new AzureBlobImpl(Config.azure_blob_connection_string, Config.azure_blob_container_name)
        }

        case "mock": {
            return new MockFileStorageImpl()
        }

    }

    return null
}
