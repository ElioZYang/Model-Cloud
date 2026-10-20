export interface EngineConfigurationCatalogEntry {
  catalogOrder?: number
  name: string
}

export function compareEngineConfigurationCatalogOrder(
  left: EngineConfigurationCatalogEntry,
  right: EngineConfigurationCatalogEntry
): number {
  const leftOrder = Number.isFinite(left.catalogOrder) ? left.catalogOrder! : Number.MAX_SAFE_INTEGER
  const rightOrder = Number.isFinite(right.catalogOrder) ? right.catalogOrder! : Number.MAX_SAFE_INTEGER
  return leftOrder - rightOrder || left.name.localeCompare(right.name, 'zh-CN')
}
