local ws = require("websocket")
local fs = require("filesystem")

-- Read connection string from file
local csFile = "cs.txt"
local cs = fs.open(csFile, "r")
if not cs then
  print("Connection string not found.")
  return
end
local connectionStr = cs.readAll()
cs.close()

-- Get all files in /disk/ directory
local directory = "/disk/"
local files = {}
for _, file in ipairs(fs.list(directory)) do
  local filePath = directory .. file
  if not fs.isDirectory(filePath) then
    local fileContent = fs.open(filePath, "r")
    if fileContent then
      files[file] = fileContent.readAll()
      fileContent.close()
    else
      print("Unable to read file:", file)
    end
  end
end

-- WebSocket client
local client = ws()

-- Event handlers
client:on_connected(function()
  print("Connected to server")
  client:send(textutils.serializeJSON(files))
end)

client:on_disconnected(function()
  print("Disconnected from server")
end)

client:on_error(function(err)
  print("Error:", err)
end)

-- Connect to server using the provided connection string
client:connect(connectionStr)

-- Wait for the connection to establish and message to be sent
while not client:is_connected() do
  os.sleep(0.1)
end

-- Wait for response or timeout (10 seconds)
local timeout = os.time() + 10
while not client:is_received() and os.time() < timeout do
  os.sleep(0.1)
end

-- Check if the message was received by the server
if client:is_received() then
  print("File contents sent successfully.")
else
  print("Timeout: Unable to send file contents.")
end

-- Disconnect from the server
client:disconnect()
