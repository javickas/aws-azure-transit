#########################################################
############## MCNA Azure Transit             ###########
#########################################################

module "azure_transit_C1" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.4.1"

  cloud                  = "azure"
  region                 = var.azure-region-C1
  cidr                   = var.azure_transitC1_cidr
  account                = var.azureaccount
  resource_group         = var.rg
  name                   = var.azure_trst_c1_name
  enable_transit_firenet = true

}

#########################################################
############## MCNA Azure Spoke               ###########
#########################################################

module "spoke_azure_C1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.5.0"

  cloud          = "Azure"
  name           = var.azure_spk1_c1_name
  cidr           = var.azure_spokeC1_cidr
  region         = var.azure-region-C1
  account        = var.azureaccount
  resource_group = var.rg
  transit_gw     = module.azure_transit_C1.transit_gateway.gw_name # <<<--- Use object reference in stead of hardcoding the name
}



#########################################################
############## MCNA AWS Transit      ####################
#########################################################



module "mc_transit_use1" {
  source        = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version       = "2.4.1"
  cloud         = "AWS"
  name          = "trnst-use1-01"
  region        = var.aws-east1
  cidr          = var.transit-east1-cidr
  account       = var.awsaccount
  instance_size = var.firenet_tgw_sz
  #firewall_image = var.pan_image
  #enable_transit_firenet = "true"
  #enable_egress_transit_firenet = "false"


}

#########################################################
############## MCNA AWS SPOKE      ######################
#########################################################

module "aws-spoke1-use1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.5.0"

  cloud      = "AWS"
  name       = "spk1-use1-01"
  cidr       = var.spoke-east1-cidr
  region     = var.aws-east1
  account    = var.awsaccount
  transit_gw = module.mc_transit_use1.transit_gateway.gw_name
  #attached        = "false"



}


##############################
#### Transit Peering #########

# Create an Aviatrix Transit Gateway Peering


resource "aviatrix_transit_gateway_peering" "transit_gateway_peering_1" {
  transit_gateway_name1 = module.mc_transit_use1.transit_gateway.gw_name
  transit_gateway_name2 = module.azure_transit_C1.transit_gateway.gw_name
}
