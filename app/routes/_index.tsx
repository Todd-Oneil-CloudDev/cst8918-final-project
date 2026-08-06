import { json } from '@remix-run/node'
import type { MetaFunction } from '@remix-run/node'
import { useLoaderData } from '@remix-run/react'
import { fetchWeatherData } from '../api-services/open-weather-service'
import { capitalizeFirstLetter } from '../utils/text-formatting'

export const meta: MetaFunction = () => [
  { title: 'Remix Weather' },
  { name: 'description', content: 'A demo web app using Remix and OpenWeather API.' },
]

const location = { lat: 45.3211, lon: -75.7391 }

export async function loader() {
  const data = await fetchWeatherData({ lat: location.lat, lon: location.lon, units: 'metric' })
  return json({ currentConditions: data })
}

export default function CurrentConditions() {
  const { currentConditions } = useLoaderData<typeof loader>()

  if (!currentConditions?.weather?.[0] || !currentConditions?.main) {
    return (
      <main style={{ padding: '1.5rem', fontFamily: 'system-ui, sans-serif' }}>
        <h1>Remix Weather</h1>
        <p>No weather data available.</p>
        <h2>Raw API Response</h2>
        <pre>{JSON.stringify(currentConditions, null, 2)}</pre>
      </main>
    )
  }

  const weather = currentConditions.weather[0]
  return (
    <main style={{ padding: '1.5rem', fontFamily: 'system-ui, sans-serif', lineHeight: '1.8' }}>
      <h1>Remix Weather</h1>
      <p>
        For Algonquin College, Woodroffe Campus<br />
        <span style={{ color: 'hsl(220, 23%, 60%)' }}>
          (LAT: {location.lat}, LON: {location.lon})
        </span>
      </p>
      <h2>Current Conditions</h2>
      <div style={{ display: 'flex', gap: '2rem', alignItems: 'center' }}>
        <img src={getWeatherIconUrl(weather.icon)} alt="" />
        <div style={{ fontSize: '2rem' }}>{currentConditions.main.temp.toFixed(1)}°C</div>
      </div>
      <p style={{ fontSize: '1.2rem' }}>
        {capitalizeFirstLetter(weather.description)}. Feels like{' '}
        {currentConditions.main.feels_like.toFixed(1)}°C.
      </p>
      <h2>Raw Data</h2>
      <pre>{JSON.stringify(currentConditions, null, 2)}</pre>
    </main>
  )
}

function getWeatherIconUrl(iconCode: string) {
  return `https://openweathermap.org/img/wn/${iconCode}@2x.png`
}
