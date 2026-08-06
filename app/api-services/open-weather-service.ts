import { getCachedJson, setCachedJson } from '../cache/redis-cache.server'

const CACHE_TTL_SECONDS = 60 * 10
const CACHE_TTL_MS = CACHE_TTL_SECONDS * 1000

const resultsCache: Record<string, { lastFetch: number; data: unknown }> = {}

function isDataStale(lastFetch: number) {
  return Date.now() - lastFetch > CACHE_TTL_MS
}

interface FetchWeatherDataParams {
  lat: number
  lon: number
  units: string
}

export async function fetchWeatherData({ lat, lon, units }: FetchWeatherDataParams) {
  const apiKey = process.env.WEATHER_API_KEY
  if (!apiKey) {
    throw new Error('WEATHER_API_KEY is required')
  }

  const baseURL = 'https://api.openweathermap.org/data/2.5/weather'
  const cacheKey = `weather:${lat}:${lon}:${units}`
  const redisResult = await getCachedJson<unknown>(cacheKey)
  if (redisResult) {
    return redisResult
  }

  const cacheEntry = resultsCache[cacheKey]

  if (cacheEntry && !isDataStale(cacheEntry.lastFetch)) {
    return cacheEntry.data
  }

  const query = new URLSearchParams({
    lat: String(lat),
    lon: String(lon),
    units,
    appid: apiKey,
  })
  const response = await fetch(`${baseURL}?${query}`)
  const data = await response.json()
  resultsCache[cacheKey] = { lastFetch: Date.now(), data }
  await setCachedJson(cacheKey, data, CACHE_TTL_SECONDS)
  return data
}
