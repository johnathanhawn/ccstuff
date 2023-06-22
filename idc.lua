local ws, err = http.websocket("wss://your-websocket-server-url")

if ws then
  print("WebSocket server connected")

  -- Send a welcome message to the client
  ws.send("Welcome to the WebSocket server!")

  while true do
    local message = ws.receive()

    if message then
      -- Process the received command
      local response = processCommand(message)

      -- Send the response back to the client
      ws.send(response)
    end
  end

  ws.close()
  print("WebSocket server disconnected")
else
  print("Failed to connect to the WebSocket server: " .. err)
end

function processCommand(command)
  -- Run the command on the turtle shell
  local success, result = pcall(loadstring(command))

  -- Check if the command execution was successful
  if success then
    -- Return the result of the command
    return "Command executed successfully: " .. tostring(result)
  else
    -- Return the error message if command execution failed
    return "Command execution error: " .. tostring(result)
  end
end
