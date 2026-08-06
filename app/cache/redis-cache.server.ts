import { createClient } from 'redis'

const DEFAULT_REDIS_PORT = 6380
const CONNECT_TIMEOUT_MS = 3_000

let client: ReturnType<typeof createClient> | null = null
let connectionAttempt: Promise<ReturnType<typeof createClient> | null> | null = null

function redisIsConfigured() {
  return Boolean(process.env.REDIS_HOST)
}

function createRedisClient() {
  const host = process.env.REDIS_HOST as string
  const password = process.env.REDIS_PASSWORD
  const port = Number(process.env.REDIS_PORT || DEFAULT_REDIS_PORT)
  const protocol = process.env.REDIS_TLS === 'false' ? 'redis' : 'rediss'
  const credentials = password ? `:${encodeURIComponent(password)}@` : ''
  const url = `${protocol}://${credentials}${host}:${port}`

  const redisClient = createClient({
    url,
    socket: {
      connectTimeout: CONNECT_TIMEOUT_MS,
      reconnectStrategy: false,
    },
  })

  redisClient.on('error', (error) => {
    console.error('Redis client error:', error instanceof Error ? error.message : error)
  })

  return redisClient
}

async function getRedisClient() {
  if (!redisIsConfigured()) {
    return null
  }

  if (client?.isReady) {
    return client
  }

  if (!connectionAttempt) {
    client = createRedisClient()
    connectionAttempt = client
      .connect()
      .then(() => client)
      .catch((error) => {
        console.warn(
          'Redis is unavailable; using in-memory caching:',
          error instanceof Error ? error.message : error
        )
        client = null
        return null
      })
      .finally(() => {
        connectionAttempt = null
      })
  }

  return connectionAttempt
}

export async function getCachedJson<T>(key: string): Promise<T | null> {
  const redisClient = await getRedisClient()
  if (!redisClient) return null

  try {
    const cachedValue = await redisClient.get(key)
    if (cachedValue) console.info('Redis cache hit:', key)
    return cachedValue ? (JSON.parse(cachedValue) as T) : null
  } catch (error) {
    console.warn(
      'Unable to read from Redis; using in-memory caching:',
      error instanceof Error ? error.message : error
    )
    return null
  }
}

export async function setCachedJson(key: string, value: unknown, ttlSeconds: number) {
  const redisClient = await getRedisClient()
  if (!redisClient) return

  try {
    await redisClient.set(key, JSON.stringify(value), { EX: ttlSeconds })
    console.info('Saved weather data to Redis:', key)
  } catch (error) {
    console.warn(
      'Unable to write to Redis; using in-memory caching:',
      error instanceof Error ? error.message : error
    )
  }
}
