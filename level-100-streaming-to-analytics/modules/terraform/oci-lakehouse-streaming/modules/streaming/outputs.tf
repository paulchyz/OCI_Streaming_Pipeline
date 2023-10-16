output "stream_pool_id" {
  value = oci_streaming_stream_pool.stream_pool.id
}
output "stream_id" {
  value = oci_streaming_stream.stream.id
}
output "stream_messages_endpoint" {
  value = oci_streaming_stream.stream.messages_endpoint
}
