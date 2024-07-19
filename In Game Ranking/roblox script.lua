--[[
Copyright 2024 zgr2575

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Join Us

Created by zgr2575, ping me in the server for support.
]]--

local requiredRank = 255 -- Minimum rank allowed to use commands
local groupId = 11717434 -- Set this as your group ID
local server = '' -- URL of your QBOT instance EG: http:<ip>:3001
local apiKey = '' -- Replace with your actual API key
local commandPrefix = "!" -- Set this to your desired command prefix

local HttpService = game:GetService('HttpService')
local Players = game:GetService('Players')

function slice(tbl, first, last, step)
	local sliced = {}

	for i = first or 1, last or #tbl, step or 1 do
		sliced[#sliced + 1] = tbl[i]
	end

	return sliced
end

local function postRequest(endpoint, data)
	local headers = {
		["Content-Type"] = "application/json",
		["Authorization"] = apiKey
	}
	local options = {
		Url = server .. endpoint,
		Method = "POST",
		Headers = headers,
		Body = HttpService:JSONEncode(data)
	}
	local success, response = pcall(function()
		
		return HttpService:RequestAsync(options)
	end)
	if success then
		print(success)
		print(response)
		return response
	else
		warn("HTTP request failed: " .. tostring(response))
	end
end

local function getUserIdFromUsername(username)
	local success, result = pcall(function()
		print(Players:GetUserIdFromNameAsync(username))
		return Players:GetUserIdFromNameAsync(username)
	end)
	if success then
		return result
	else
		warn("Failed to get user ID from username: " .. tostring(result))
		return nil
	end
end

game.Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(msg)
		local args = msg:split(" ")
		local command = args[1]:sub(1, #commandPrefix)

		if command == commandPrefix then
			local cmd = args[1]:sub(#commandPrefix + 1)

			if cmd == "setrank" then
				local username = args[2]
				local userId = getUserIdFromUsername(username)
				local rank = slice(args, 3)
				rank = table.concat(rank, ' ')
				if userId and rank and userId ~= player.UserId then
					if player:GetRankInGroup(groupId) >= requiredRank then
						postRequest('/setrank', {
							id = userId,
							role = rank
						})
					end
				end
			elseif cmd == "promote" then
				local username = args[2]
				local userId = getUserIdFromUsername(username)
				if userId and userId ~= player.UserId then
					if player:GetRankInGroup(groupId) >= requiredRank then
						postRequest('/promote', {
							id = userId
						})
					end
				end
			elseif cmd == "demote" then
				local username = args[2]
				local userId = getUserIdFromUsername(username)
				if userId and userId ~= player.UserId then
					if player:GetRankInGroup(groupId) >= requiredRank then
						postRequest('/demote', {
							id = userId
						})
					end
				end
			elseif cmd == "fire" then
				local username = args[2]
				local userId = getUserIdFromUsername(username)
				if userId and userId ~= player.UserId then
					if player:GetRankInGroup(groupId) >= requiredRank then
						postRequest('/fire', {
							id = userId
						})
					end
				end
			elseif cmd == "shout" then
				table.remove(args, 1)
				local msg = table.concat(args, ' ')
				if player:GetRankInGroup(groupId) >= requiredRank then
					postRequest('/shout', {
						content = msg
					})
				end
			elseif cmd == "suspend" then
				local username = args[2]
				local userId = getUserIdFromUsername(username)
				local duration = tonumber(args[3])
				if userId and duration and userId ~= player.UserId then
					if player:GetRankInGroup(groupId) >= requiredRank then
						postRequest('/suspend', {
							id = userId,
							duration = duration
						})
					end
				end
			elseif cmd == "unsuspend" then
				local username = args[2]
				local userId = getUserIdFromUsername(username)
				if userId and userId ~= player.UserId then
					if player:GetRankInGroup(groupId) >= requiredRank then
						postRequest('/unsuspend', {
							id = userId
						})
					end
				end
			elseif cmd == "addxp" then
				local username = args[2]
				local userId = getUserIdFromUsername(username)
				local amount = tonumber(args[3])
				if userId and amount and userId ~= player.UserId then
					if player:GetRankInGroup(groupId) >= requiredRank then
						postRequest('/xp/add', {
							id = userId,
							amount = amount
						})
					end
				end
			elseif cmd == "removexp" then
				local username = args[2]
				local userId = getUserIdFromUsername(username)
				local amount = tonumber(args[3])
				if userId and amount and userId ~= player.UserId then
					if player:GetRankInGroup(groupId) >= requiredRank then
						postRequest('/xp/remove', {
							id = userId,
							amount = amount
						})
					end
				end
			end
		end
	end)
end)
