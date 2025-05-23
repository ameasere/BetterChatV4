local cache = {
	stored = {}
}

function cache:store(object)
	cache.stored[object.ClassName] = cache.stored[object.ClassName] or {}
	table.insert(cache.stored[object.ClassName],object)
	object.Parent = nil
end

function cache:get(className)
	local stored = cache.stored[className]
	if stored and stored[1] then
		local toGive = stored[1]
		table.remove(stored,1)
		return toGive
	else
		return Instance.new(className)
	end
end

return cache