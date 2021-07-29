/*
resource "aws_ses_email_identity" "email_identity" {
  count = var.cluster_type == "app_cluster" ? 1 : 0
  email = var.email_address
}*/
resource "aws_cognito_user_pool" "user_pool" {
  count = var.cluster_type == "app_cluster" ? 1 : 0
  name = "${local.stdname}-${var.userpool_name}"
  dynamic "account_recovery_setting" {
    for_each = length(var.userpool_recovery_mechanisms) == 0 ? [] : [1]
    content {
      dynamic "recovery_mechanism" {
        for_each = var.userpool_recovery_mechanisms
        content {
          name     = lookup(recovery_mechanism.value, "name")
          priority = lookup(recovery_mechanism.value, "priority")
        }
      }
    }
  }
  admin_create_user_config {
    allow_admin_create_user_only = var.userpool_allow_admin_create_user_only
    invite_message_template {
      email_message = "Dear {username}, your verification code is {####}."
      email_subject = "Your temporary password"
      sms_message   = "Your username is {username} and temporary password is {####}."
    }
  }
  #alias_attributes = var.userpool_alais_attributes
  username_attributes      = var.userpool_username_attributes
  auto_verified_attributes = var.userpool_auto_verified_attributes
  device_configuration {
    challenge_required_on_new_device      = var.userpool_challenge_required_on_new_device
    device_only_remembered_on_user_prompt = var.userpool_device_only_remembered_on_user_prompt
  }
  /*
  email_configuration {
    reply_to_email_address = lookup(var.userpool_email_config, "reply_to_email_address")
    source_arn             = lookup(var.userpool_email_config, "source_arn")
    email_sending_account  = lookup(var.userpool_email_config, "email_sending_account")
    from_email_address     = lookup(var.userpool_email_config, "from_email_address")
  }
  email_configuration {
    reply_to_email_address = var.email_address
    source_arn             = aws_ses_email_identity.email_identity.arn
    email_sending_account  = "DEVELOPER"
    from_email_address     = var.email_address
  }*/

  email_verification_subject = var.userpool_email_verficiation_subject != "" ? var.userpool_email_verficiation_subject : "Here, your verification code baby"
  email_verification_message = var.userpool_email_verficiation_message != "" ? var.userpool_email_verficiation_message : "Dear {username}, your verification code is {####}."
  mfa_configuration          = var.userpool_mfa_configuration
  software_token_mfa_configuration {
    enabled = var.userpool_software_token_mfa_enabled
  }
  password_policy {
    minimum_length                   = var.password_policy_minimum_length
    require_lowercase                = var.password_policy_require_lowercase
    require_numbers                  = var.password_policy_require_numbers
    require_symbols                  = var.password_policy_require_symbols
    require_uppercase                = var.password_policy_require_uppercase
    temporary_password_validity_days = var.password_policy_temporary_password_validity_days
  }
  sms_authentication_message = "Your username is {username} and temporary password is {####}."
  sms_verification_message   = "This is the verification message {####}."
  tags                       = local.tags
  user_pool_add_ons {
    advanced_security_mode = var.userpool_advanced_security_mode
  }
  username_configuration {
    case_sensitive = var.userpool_enable_username_case_sensitivity
  }
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }
}
#aws cognito application client definition
resource "aws_cognito_user_pool_client" "cognito_app_client" {
  count = var.cluster_type == "app_cluster" ? 1 : 0
  name                                 = "${local.stdname}-${var.client_app_name}"
  user_pool_id                         = aws_cognito_user_pool.user_pool[0].id
  allowed_oauth_flows                  = var.client_allowed_oauth_flows
  allowed_oauth_flows_user_pool_client = var.client_allowed_oauth_flows_user_pool_client
  allowed_oauth_scopes                 = var.client_allowed_oauth_scopes
  callback_urls                        = var.client_callback_urls
  default_redirect_uri                 = var.client_default_redirect_url
  explicit_auth_flows                  = var.client_explicit_auth_flows
  generate_secret                      = var.client_generate_secret
  logout_urls                          = var.client_logout_urls
  read_attributes                      = var.client_read_attributes
  refresh_token_validity               = var.client_refresh_token_validity
  supported_identity_providers         = var.client_supported_idp
  prevent_user_existence_errors        = var.client_prevent_user_existence_errors
  id_token_validity                    = var.client_id_token_validity
  write_attributes                     = var.client_write_attributes
  access_token_validity                = var.client_access_token_validity
  token_validity_units {
    access_token  = lookup(var.client_token_validity_units, "access_token", null)
    id_token      = lookup(var.client_token_validity_units, "id_token", null)
    refresh_token = lookup(var.client_token_validity_units, "refresh_token", null)
  }
}
/*
#aws cognito domain (custom/out-of-box) specification
resource "aws_cognito_user_pool_domain" "domain" {
  count = var.cluster_type == "app_cluster" ? 1 : 0
  domain          = var.cognito_domain
# certificate_arn = var.acm_cert_arn #activate when custom domain is required
  user_pool_id    = aws_cognito_user_pool.user_pool[0].id

}
#aws cognito user interface customization resource definition
resource "aws_cognito_user_pool_ui_customization" "cognito_ui_cust" {
  count = var.cluster_type == "app_cluster" ? 1 : 0
  client_id    = aws_cognito_user_pool_client.cognito_app_client[0].id
  image_file   = filebase64("resources/aais_logo.png")
  user_pool_id = aws_cognito_user_pool.user_pool[0].id
  depends_on   = [aws_cognito_user_pool_client.cognito_app_client, aws_cognito_user_pool_domain.domain]
}
*/