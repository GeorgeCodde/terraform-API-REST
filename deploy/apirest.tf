
# Build a API rest

resource "aws_api_gateway_rest_api" "MyDemoAPI" {
  name        = "MyDemoAPI"
  description = "This is my API for demonstration purposes"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

#Define resource
resource "aws_api_gateway_resource" "MyDemoResource" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  parent_id   = aws_api_gateway_rest_api.MyDemoAPI.root_resource_id
  path_part   = "dragons"
}

# Define method GET
resource "aws_api_gateway_method" "MyDemoMethod" {
  rest_api_id   = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id   = aws_api_gateway_resource.MyDemoResource.id
  http_method   = "GET"
  authorization = "NONE"
}
#Define integration of method GET
resource "aws_api_gateway_integration" "MyDemoIntegration" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id = aws_api_gateway_resource.MyDemoResource.id
  http_method = aws_api_gateway_method.MyDemoMethod.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = <<EOF
    {"statusCode": 200}
   EOF
   }
}
#Define response of method GET
resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id = aws_api_gateway_resource.MyDemoResource.id
  http_method = aws_api_gateway_method.MyDemoMethod.http_method
  status_code = "200"
}

# Define integration response of method GET
resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id = aws_api_gateway_resource.MyDemoResource.id
  http_method = aws_api_gateway_method.MyDemoMethod.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  # Transforms the backend JSON
  response_templates = {
    "application/json" = <<EOF
[
   #if( $input.params('family') == "red" )
      {
         "description_str":"Xanya is the fire tribe's banished general. She broke ranks and has been wandering ever since.",
         "dragon_name_str":"Xanya",
         "family_str":"red",
         "location_city_str":"las vegas",
         "location_country_str":"usa",
         "location_neighborhood_str":"e clark ave",
         "location_state_str":"nevada"
      }, {
         "description_str":"Eislex flies with the fire sprites. He protects them and is their guardian.",
         "dragon_name_str":"Eislex",
         "family_str":"red",
         "location_city_str":"st. cloud",
         "location_country_str":"usa",
         "location_neighborhood_str":"breckenridge ave",
         "location_state_str":"minnesota"      }
   #elseif( $input.params('family') == "blue" )
      {
         "description_str":"Protheus is a wise and ancient dragon that serves on the grand council in the sky world. He uses his power to calm those near him.",
         "dragon_name_str":"Protheus",
         "family_str":"blue",
         "location_city_str":"brandon",
         "location_country_str":"usa",
         "location_neighborhood_str":"e morgan st",
         "location_state_str":"florida"
       }
   #elseif( $input.params('dragonName') == "Atlas" )
      {
         "description_str":"From the northern fire tribe, Atlas was born from the ashes of his fallen father in combat. He is fearless and does not fear battle.",
         "dragon_name_str":"Atlas",
         "family_str":"red",
         "location_city_str":"anchorage",
         "location_country_str":"usa",
         "location_neighborhood_str":"w fireweed ln",
         "location_state_str":"alaska"
      }
   #else
      {
         "description_str":"From the northern fire tribe, Atlas was born from the ashes of his fallen father in combat. He is fearless and does not fear battle.",
         "dragon_name_str":"Atlas",
         "family_str":"red",
         "location_city_str":"anchorage",
         "location_country_str":"usa",
         "location_neighborhood_str":"w fireweed ln",
         "location_state_str":"alaska"
      },
      {
         "description_str":"Protheus is a wise and ancient dragon that serves on the grand council in the sky world. He uses his power to calm those near him.",
         "dragon_name_str":"Protheus",
         "family_str":"blue",
         "location_city_str":"brandon",
         "location_country_str":"usa",
         "location_neighborhood_str":"e morgan st",
         "location_state_str":"florida"
      },
      {
         "description_str":"Xanya is the fire tribe's banished general. She broke ranks and has been wandering ever since.",
         "dragon_name_str":"Xanya",
         "family_str":"red",
         "location_city_str":"las vegas",
         "location_country_str":"usa",
         "location_neighborhood_str":"e clark ave",
         "location_state_str":"nevada"
      }, 
      {
         "description_str":"Eislex flies with the fire sprites. He protects them and is their guardian.",
         "dragon_name_str":"Eislex",
         "family_str":"red",
         "location_city_str":"st. cloud",
         "location_country_str":"usa",
         "location_neighborhood_str":"breckenridge ave",
         "location_state_str":"minnesota"
      }
   #end
 ]

EOF
  }
}

#TODO:  Define method POST


# built the deployment of API REST 
resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.MyDemoResource.id  ,
      aws_api_gateway_method.MyDemoMethod.id,
      aws_api_gateway_integration.MyDemoIntegration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
# Define stage name of the deployment
resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.MyDemoAPI.id
  stage_name    = "example"
}