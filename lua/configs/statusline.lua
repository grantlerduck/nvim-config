local M = {}

-- Cache for CPU and RAM values to avoid constant recalculation
local cache = {
  cpu = { value = 0, last_update = 0 },
  ram = { value = 0, last_update = 0 },
  cpu_cores = nil,
}

-- Get number of CPU cores
local function get_cpu_cores()
  if cache.cpu_cores then
    return cache.cpu_cores
  end

  local handle = io.popen("sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 1")
  if handle then
    local result = handle:read("*a")
    handle:close()
    cache.cpu_cores = tonumber(result) or 1
  else
    cache.cpu_cores = 1
  end
  return cache.cpu_cores
end

-- Get CPU usage (percentage, normalized by core count)
local function get_cpu_usage()
  local current_time = vim.loop.now()
  -- Update every 2 seconds
  if current_time - cache.cpu.last_update < 2000 then
    return cache.cpu.value
  end

  local handle = io.popen("ps -A -o %cpu | awk '{s+=$1} END {print s}'")
  if handle then
    local result = handle:read("*a")
    handle:close()
    local total_cpu = tonumber(result) or 0
    local cores = get_cpu_cores()
    -- Normalize by number of cores
    cache.cpu.value = math.floor((total_cpu / cores) + 0.5)
    cache.cpu.last_update = current_time
  end
  return cache.cpu.value
end

-- Get RAM usage (percentage)
local function get_ram_usage()
  local current_time = vim.loop.now()
  -- Update every 2 seconds
  if current_time - cache.ram.last_update < 2000 then
    return cache.ram.value
  end

  -- macOS command - correctly calculate memory usage
  -- Page size on macOS is typically 16384 bytes (16KB)
  local handle = io.popen([[
    vm_stat | awk '
      BEGIN { page_size=16384 }
      /Pages free:/ {free=$3}
      /Pages active:/ {active=$3}
      /Pages inactive:/ {inactive=$3}
      /Pages wired down:/ {wired=$4}
      /Pages occupied by compressor:/ {comp=$5}
      END {
        gsub(/\./,"",free)
        gsub(/\./,"",active)
        gsub(/\./,"",inactive)
        gsub(/\./,"",wired)
        gsub(/\./,"",comp)
        # Used = active + wired + compressed
        # Total = free + active + inactive + wired
        used = active + wired + comp
        total = free + active + inactive + wired
        if (total>0) print int((used/total)*100)
        else print 0
      }'
  ]])

  if handle then
    local result = handle:read("*a")
    handle:close()
    cache.ram.value = tonumber(result) or 0
    cache.ram.last_update = current_time
  end
  return cache.ram.value
end

-- CPU usage component
M.cpu = function()
  local cpu = get_cpu_usage()
  local color = "%#St_cpu#"

  -- Change color based on usage
  if cpu > 80 then
    color = "%#St_cpu_high#"
  elseif cpu > 50 then
    color = "%#St_cpu_medium#"
  end

  return color .. " CPU: " .. cpu .. "%% "
end

-- RAM usage component
M.ram = function()
  local ram = get_ram_usage()
  local color = "%#St_ram#"

  -- Change color based on usage
  if ram > 80 then
    color = "%#St_ram_high#"
  elseif ram > 50 then
    color = "%#St_ram_medium#"
  end

  return color .. " RAM: " .. ram .. "%% "
end

return M
