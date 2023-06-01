# volume registration
type = "csi"
id = "efs-example"
name = "efs-example"
external_id = "fs-0e4c15c09c3a09ca5"
capability {
access_mode = "multi-node-multi-writer"
attachment_mode = "file-system"
}
plugin_id = "aws-efs0"
