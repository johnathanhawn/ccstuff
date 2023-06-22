local csFilePath = "cs.txt"

-- Check if the cs.txt file exists
if not fs.exists(csFilePath) then
  -- File doesn't exist, create it
  local csFile = fs.open(csFilePath, "w")
  csFile.writeLine("wss://your-websocket-server-url") -- Replace with your desired default server URL
  csFile.close()
  print("cs.txt file created. Please update the WebSocket server URL in cs.txt.")
  return
end

-- Read the server URL from the cs.txt file
local csFile = fs.open(csFilePath, "r")
local serverURL = csFile.readAll()
csFile.close()

-- Connect to the WebSocket server
local ws, err = http.websocket(serverURL)

if ws then
  print("WebSocket server connected")

  -- Send a welcome message to the client
  ws.send("Hello, client!")

  while true do
    local message = ws.receive()

    if message then
      -- Print the received command
      print("Received command:", message)

      -- Process the received command
      local success, result = pcall(loadstring(message))

      -- Check if the command is a movement command
      local isMovementCommand = false
      if message == "turtle.forward()" or message == "turtle.back()" or message == "turtle.left()" or message == "turtle.right()" or message == "turtle.up()" or message == "turtle.down()" then
        isMovementCommand = true
      end

      -- If it's a movement command, inspect surroundings
      if isMovementCommand then
        local inspectResult = turtle.inspect()
        if inspectResult then
          ws.send("Inspect result: " .. inspectResult.name)
        else
          ws.send("Unable to inspect surroundings")
        end
      end

      -- Check if the command execution was successful
      if success then
        -- Return the result of the command
        ws.send("Command executed successfully: " .. tostring(result))
      else
        -- Return the error message if command execution failed
        ws.send("Command execution error: " .. tostring(result))
      end
    end
  end

  ws.close()
  print("WebSocket server disconnected")
else
  print("Failed to connect to the WebSocket server: " .. err)
end
