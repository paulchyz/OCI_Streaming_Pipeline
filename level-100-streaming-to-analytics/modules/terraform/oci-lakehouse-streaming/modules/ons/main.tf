resource "oci_ons_notification_topic" "ons_topic" {
    #Required
    compartment_id = var.compartment_id
    name = var.ons_topic_name
}

resource "oci_ons_subscription" "ons_subscription" {
    #Required
    compartment_id = var.compartment_id
    endpoint = var.ons_subscription_endpoint
    protocol = var.ons_subscription_protocol
    topic_id = oci_ons_notification_topic.ons_topic.id
}