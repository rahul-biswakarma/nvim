--[[
  PIN Handler Module
  
  Manages PIN entry, validation, and unlock state.
]]

local M = {}

-- Configuration
local PIN = '3562'

-- State
local state = {
  entered_pin = '',
  is_unlocked = false,
  wrong_pin = false,
}

-- Initialize the handler
function M.init()
  state.entered_pin = ''
  state.is_unlocked = false
  state.wrong_pin = false
end

-- Get current PIN display (masked)
function M.get_pin_display()
  return string.rep('*', #state.entered_pin) .. string.rep('_', 4 - #state.entered_pin)
end

-- Get error message
function M.get_error_message()
  return state.wrong_pin and 'Wrong PIN! Try again...' or ''
end

-- Add digit to PIN
function M.add_digit(digit)
  if #state.entered_pin < 4 then
    state.wrong_pin = false
    state.entered_pin = state.entered_pin .. tostring(digit)
    return true
  end
  return false
end

-- Remove last digit (backspace)
function M.backspace()
  if #state.entered_pin > 0 then
    state.wrong_pin = false
    state.entered_pin = state.entered_pin:sub(1, -2)
    return true
  end
  return false
end

-- Validate PIN
function M.validate_pin()
  if #state.entered_pin == 4 then
    if state.entered_pin == PIN then
      state.is_unlocked = true
      return true
    else
      state.wrong_pin = true
      state.entered_pin = ''
      return false
    end
  end
  return false
end

-- Check if unlocked
function M.is_unlocked()
  return state.is_unlocked
end

-- Get full state (for debugging)
function M.get_state()
  return state
end

return M

