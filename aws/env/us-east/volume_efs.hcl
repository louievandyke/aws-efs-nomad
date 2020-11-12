# volume registration
type = "csi"
id = "efs-example"
name = "efs-example"
external_id = "fs-87489472"
access_mode = "single-node-writer"
attachment_mode = "file-system"
plugin_id = "aws-efs0"

# volume registration
type = "csi"
id = "elnino"
name = "elnino"
external_id = "fs-0609d2f3"
access_mode = "multi-node-multi-writer"
attachment_mode = "file-system"
plugin_id = "aws-efs0"