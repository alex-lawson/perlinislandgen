local function printTable(t, indent)
  if not indent then
    indent = ""
    print("Printing table...")
  end
  local tnames = {}
  for k,v in pairs(t) do
    tnames[#tnames + 1] = k
  end
  table.sort(tnames, function(a, b) return a < b end)
  for _, key in ipairs(tnames) do
    if type(t[key]) == "table" then
      print(indent.."table "..key)
      printTable(t[key], indent.."  ")
    elseif type(t[key]) == "function" then
      print(indent.."function "..key)
    else
      print(indent..type(t[key]).." "..key.." = "..tostring(t[key]))
    end
  end
end

function copy(v)
  if type(v) ~= "table" then
    return v
  else
    local c = {}
    for k,v in pairs(v) do
      c[k] = copy(v)
    end
    setmetatable(c, getmetatable(v))
    return c
  end
end

function seedTime()
  return math.floor((os.time() + (os.clock() % 1)) * 1000)
end

-- range(a) returns an iterator from 1 to a (step = 1)
-- range(a, b) returns an iterator from a to b (step = 1)
-- range(a, b, step) returns an iterator from a to b, counting by step.
local function range(a, b, step)
  if not b then
    b = a
    a = 1
  end
  step = step or 1
  local f =
    step > 0 and
      function(_, lastvalue)
        local nextvalue = lastvalue + step
        if nextvalue <= b then return nextvalue end
      end or
    step < 0 and
      function(_, lastvalue)
        local nextvalue = lastvalue + step
        if nextvalue >= b then return nextvalue end
      end or
      function(_, lastvalue) return lastvalue end
  return f, nil, a - step
end

function nrandf(stddev, mean)
  local rand1, rand2, distSqr

  repeat
    rand1 = 2 * math.random() - 1
    rand2 = 2 * math.random() - 1
    distSqr = rand1 * rand1 + rand2 * rand2
  until distSqr >= 1

  mapping = math.sqrt(2 * math.log(distSqr) / distSqr)
  return (rand1 * mapping * stddev + mean)
end

return {
  printTable = printTable,
  range = range,
  copy = copy,
  seedTime = seedTime,
  nrandf = nrandf
}
