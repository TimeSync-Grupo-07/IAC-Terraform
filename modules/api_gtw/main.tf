

resource "aws_api_gateway_rest_api" "timesync-api_gateway-publico-acesso_pipefy" {
  name        = "timesync-api_gateway-publico-acesso_pipefy"  
}

resource "aws_api_gateway_resource" "timesync-api_gateway-publico-recurso-nome_bucket" {
  rest_api_id = aws_api_gateway_rest_api.timesync-api_gateway-publico-acesso_pipefy.id
  parent_id   = aws_api_gateway_rest_api.timesync-api_gateway-publico-acesso_pipefy.root_resource_id
  path_part   = "{bucket}"
}

resource "aws_api_gateway_resource" "timesync-api_gateway-publico-recurso-nome_diretorio" {
  rest_api_id = aws_api_gateway_rest_api.timesync-api_gateway-publico-acesso_pipefy.id
  parent_id   = aws_api_gateway_resource.timesync-api_gateway-publico-recurso-nome_bucket.id
  path_part   = "{diretorio}"
}

resource "aws_api_gateway_resource" "timesync-api_gateway-publico-recurso-nome_arquivo" {
  rest_api_id = aws_api_gateway_rest_api.timesync-api_gateway-publico-acesso_pipefy.id
  parent_id   = aws_api_gateway_resource.timesync-api_gateway-publico-recurso-nome_diretorio.id
  path_part   = "{arquivo}"
}

resource "aws_api_gateway_method" "timesync-api_gateway-publico-metodo-insercao-arquivos-pipefy" {
  rest_api_id   = aws_api_gateway_rest_api.timesync-api_gateway-publico-acesso_pipefy.id
  resource_id   = aws_api_gateway_resource.timesync-api_gateway-publico-recurso-nome_arquivo.id
  http_method   = "PUT"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.path.bucket" = true
    "method.request.path.diretorio" = true
    "method.request.path.arquivo" = true
  }

}

resource "aws_api_gateway_integration" "timesync-api_gateway-publico-integracao-s3" {
  rest_api_id = aws_api_gateway_rest_api.timesync-api_gateway-publico-acesso_pipefy.id
  resource_id = aws_api_gateway_method.timesync-api_gateway-publico-metodo-insercao-arquivos-pipefy.resource_id
  http_method = aws_api_gateway_method.timesync-api_gateway-publico-metodo-insercao-arquivos-pipefy.http_method

  integration_http_method = "PUT"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:us-east-1:s3:path/{bucket}/{diretorio}/{arquivo}"
  credentials             = "arn:aws:iam::005948301962:role/LabRole"

  request_parameters = {
    "integration.request.path.bucket"    = "method.request.path.bucket"
    "integration.request.path.diretorio" = "method.request.path.diretorio"
    "integration.request.path.arquivo"   = "method.request.path.arquivo"
  }

  passthrough_behavior = "WHEN_NO_MATCH"
}


resource "aws_api_gateway_deployment" "timesync-api_gateway-publico-deploy" {
    depends_on = [ aws_api_gateway_method.timesync-api_gateway-publico-metodo-insercao-arquivos-pipefy ]

  rest_api_id = aws_api_gateway_rest_api.timesync-api_gateway-publico-acesso_pipefy.id
}

resource "aws_api_gateway_stage" "timesync-api_gateway-publico-estagio_api" {
  deployment_id = aws_api_gateway_deployment.timesync-api_gateway-publico-deploy.id
  rest_api_id   = aws_api_gateway_rest_api.timesync-api_gateway-publico-acesso_pipefy.id
  stage_name    = "Homolog"
}