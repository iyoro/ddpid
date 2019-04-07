-- Change the target FPS here. See README.md for notes on choosing a value.
local targetFps = 50

-- Change this if you want the addon to mess with the FPS counter. This is turned off by default because it's hacky
-- and ugly.
local hackTheFpsCounter = false

local DDPID = {}
DDPID.version = 1
DDPID.name = "DDPID"

function DDPID:New(control)
  instance = {}
  instance.control = control
  setmetatable(instance, { __index = DDPID })
  instance:Initialise()
  return instance
end

function DDPID:Initialise()  
  -- PID control terms.
  self.Kp = 1
  self.Ki = 0.8
  self.Kd = 0
  self.outMax = 100
  self.outMin = 40
  self:InitialiseSetPoint(targetFps)
  self.enabled = false
    
  if hackTheFpsCounter then
    -- Make some vanilla UI controls wider.
    local dW = 20
    ZO_PerformanceMetersFramerateMeter:SetWidth(ZO_PerformanceMetersFramerateMeter:GetWidth() + dW)
    ZO_PerformanceMetersBg:SetWidth(ZO_PerformanceMetersBg:GetWidth() + dW)
    ZO_PerformanceMeters:SetWidth(ZO_PerformanceMeters:GetWidth() + dW)
    -- Alter the layout. FPS and ping meters are centre-anchored in their parent; switch them to left and right.
    ZO_PerformanceMetersFramerateMeter:SetAnchor(LEFT, ZO_PerformanceMeters, LEFT, 0, 0)
    ZO_PerformanceMetersLatencyMeter:SetAnchor(LEFT, ZO_PerformanceMetersFramerateMeter, RIGHT, 0, 0)
    -- Replace FPS counter setText with our own which delegates to the original.
    local SetFpsText = ZO_PerformanceMetersFramerateMeterLabel["SetText"]
    local SurrogateSetFpsText = function(it, text)
      local stext = string.format("%s/%2.0f", text, self.output or -1)
      SetFpsText(it, stext)
    end
    ZO_PerformanceMetersFramerateMeterLabel["SetText"] = SurrogateSetFpsText
  end
end

-- Init or re-init the set point.
function DDPID:InitialiseSetPoint(sp)
  self.setPoint = sp
  self.output = zo_lerp(self.outMin, self.outMax, 0.5)
  self.iTerm = 0 -- Accumulator for integral term.
  self.lastT = GetGameTimeMilliseconds() -- Do not initialise at 0 to avoid big time leap on first tick.
  self.lastInput = GetFramerate() -- Initial measurement.
end

-- Set draw distance, should be in the range 0..100 which is mapped onto 0.4..2.0 (the measured range of the slider).
function DDPID:ChangeDD(output)
  local value = zo_lerp(0.4, 2.0, output/100)
  SetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_VIEW_DISTANCE, value, 1)
end

-- Handles the slash command.
function DDPID:SlashCommand(arg)
  if arg == nil or arg == '' then
    self.enabled = not self.enabled
    d("View distance PID control is now " .. (self.enabled and "ON" or "OFF"))
  else
    local sp = math.max(25, math.floor(tonumber(arg)))
    d("View distance control target FPS is now " .. sp)
    self:InitialiseSetPoint(sp)
  end
end

function DDPID:OnUpdate(_)
  if not self.enabled then return end
  local t = GetGameTimeMilliseconds()
  local dT = t - self.lastT
  -- Framerate only updates once per second, so only respond to changes.
  local input = GetFramerate()
  if (input == self.lastInput) then return end
  -- Remainder of this func runs approx 1/sec.
  local e = input - self.setPoint
  self.iTerm = self.iTerm + (self.Ki * e)
  -- Clamp the integral term to prevent wind-up.
  if (self.iTerm > self.outMax) then
    self.iTerm = self.outMax
  elseif self.iTerm < self.outMin then
    self.iTerm = self.outMin
  end
  local dInput = input - self.lastInput
  self.output = self.Kp * e + self.iTerm - self.Kd * dInput
  if (self.output > self.outMax) then
    self.output = self.outMax
  elseif self.output < self.outMin then
    self.output = self.outMin
  end
  --d(string.format("input=%.3f, e=%.3f, iTerm=%.3f, dI=%.3f => %.1f", input, e, self.iTerm, dInput, self.output))
  self:ChangeDD(self.output)
  self.lastInput = input
  self.lastT = t
end

function DDPID_OnInitialized(self)
  DrawDistancePID = DDPID:New(self)
  SLASH_COMMANDS["/ddpid"] = function(arg) DrawDistancePID:SlashCommand(arg) end
  DrawDistancePID:SlashCommand()
end
