// Shared user-defined types for the Zero Trust foundation.

@export()
@description('A Microsoft Defender for Cloud plan to enable on the subscription.')
type defenderPlan = {
  @description('Plan name, for example CloudPosture, VirtualMachines, StorageAccounts, KeyVaults, Arm or Containers.')
  name: string

  @description('Optional sub-plan, for example P2 for VirtualMachines or DefenderForStorageV2 for StorageAccounts.')
  subPlan: string?
}
