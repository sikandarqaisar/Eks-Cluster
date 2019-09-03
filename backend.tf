// terraform {
//   required_version = "~> 0.10"
//   backend "s3"{
//     bucket                 = "bryan.recinos"
//     region                 = "us-east-1"
//     key                    = "backend.tfstate"
//     workspace_key_prefix   = "eks"
//     dynamodb_table         = "terraform-lock"
//   }
// }