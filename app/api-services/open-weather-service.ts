const API_KEY = process.env.WEATHER_API_KEY
const TEN_MINUTES = 1000 * 60 * 10

const resultsCache: Record<string, { lastFetch: number; data: unknown }> = {}

function isDataStale(lastFetch: number) {
  return Date.now() - lastFetch > TEN_MINUTES
}

interface FetchWeatherDataParams {
  lat: number
  lon: number
  units: string
}

export async function fetchWeatherData({ lat, lon, units }: FetchWeatherDataParams) {
  const baseURL = 'https://api.openweathermap.org/data/2.5/weather'
  const queryString = `lat=${lat}&lon=${lon}&units=${units}&appid=${API_KEY}`
  const cacheEntry = resultsCache[queryString]

  if (cacheEntry && !isDataStale(cacheEntry.lastFetch)) {
    return cacheEntry.data
  }

  const response = await fetch(`${baseURL}?${queryString}`)
  const data = await response.json()
  resultsCache[queryString] = { lastFetch: Date.now(), data }
  return data
}
