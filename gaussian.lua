local class = require("class")
local Gaussian = class:derive("Gaussian")

-- Box-Muller transform (basic).
function Gaussian:gaussian_basic(mean, variance)
  return (math.sqrt(-2 * variance * math.log(math.random())) *
          math.cos(2 * math.pi * math.random()) + mean)
end

-- Box-Muller transform (polar).
function Gaussian:gaussian(mu, sigma)
  local x1, x2, w, y1, y2
  repeat
    x1 = 2.0 * math.random() - 1.0
    x2 = 2.0 * math.random() - 1.0
    w = x1 * x1 + x2 * x2
  until (w < 1.0)

  w = math.sqrt((-2.0 * math.log(w)) / w)
  y1 = x1 * w
  y2 = x2 * w
  return y1 * sigma + mu, y2 * sigma + mu
end

function Gaussian:mean(t)
  local sum = 0
  for k, v in pairs(t) do
    sum = sum + v
  end
  return sum / #t
end

function Gaussian:std(t)
  local squares, avg = 0, mean(t)
  for k, v in pairs(t) do
    squares = squares + ((avg - v)^2)
  end
  local variance = squares / #t
  return math.sqrt(variance)
end

function Gaussian:show_histogram(t)
  local lo = math.ceil(math.min(unpack(t)))
  local hi = math.floor(math.max(unpack(t)))
  local hist, barScale = {}, 200
  for i = lo, hi do
    hist[i] = 0
    for k, v in pairs(t) do
      if math.ceil(v - 0.5) == i then
        hist[i] = hist[i] + 1
      end
    end
    io.write(i .. "\t" .. string.rep('=', hist[i] / #t * barScale))
    print(" " .. hist[i])
  end
end

return Gaussian
