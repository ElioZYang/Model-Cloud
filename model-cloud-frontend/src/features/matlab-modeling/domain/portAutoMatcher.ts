export type MatchablePort = {
  name: string
  type?: string
  unit?: string
  shape?: number[]
  description?: string
  semanticKey?: string
  displayName?: string
}

const normalized = (value?: string) => String(value || '').trim().toLocaleLowerCase()
const sameShape = (a?: number[], b?: number[]) => !a?.length || !b?.length
  || (a.length === b.length && a.every((value, index) => value === b[index]))

export const portMatchScore = (source: MatchablePort, target: MatchablePort): number => {
  const sourceType = normalized(source.type) || 'unknown'
  const targetType = normalized(target.type) || 'unknown'
  if (sourceType !== targetType && sourceType !== 'unknown' && targetType !== 'unknown') return -1
  if (!sameShape(source.shape, target.shape)) return -1
  if (source.unit && target.unit && normalized(source.unit) !== normalized(target.unit)) return -1
  if (source.semanticKey && source.semanticKey === target.semanticKey) return 500
  const sourceNames = [source.name, source.displayName, source.description].map(normalized).filter(Boolean)
  const targetNames = [target.name, target.displayName, target.description].map(normalized).filter(Boolean)
  if (sourceNames.some(name => targetNames.includes(name))) return 400
  if (sourceType !== 'unknown' && targetType !== 'unknown'
    && source.unit && target.unit && sameShape(source.shape, target.shape)) return 300
  if (sourceType !== 'unknown' && sourceType === targetType) return 200
  return sourceType === 'unknown' || targetType === 'unknown' ? 100 : -1
}

/** Stable greedy matching; ties retain target declaration order. */
export const matchPortsInDeclarationOrder = <S extends MatchablePort, T extends MatchablePort>(
  sources: S[], targets: T[],
  isTargetAvailable: (target: T) => boolean = () => true
) => {
  const used = new Set<T>()
  return sources.flatMap(source => {
    let best: T | undefined
    let bestScore = -1
    for (const target of targets) {
      if (used.has(target) || !isTargetAvailable(target)) continue
      const score = portMatchScore(source, target)
      if (score > bestScore) { best = target; bestScore = score }
    }
    if (!best || bestScore < 0) return []
    used.add(best)
    return [{ source, target: best, score: bestScore }]
  })
}
