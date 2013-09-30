module("jason.message_spec", package.seeall)


function include(filter_words)
	return MessageSpec.new(filter_words)
end

MessageSpec = {}
function MessageSpec.new(filter_words)
	local self = {}
	setmetatable(self, {__index = MessageSpec})
	
	self.filter_words = filter_words
	return self
end

function MessageSpec:accepts(message)
	return filter_words == nil
--	return jason.utils.find(self.filter_words, function(v) return v == message end)
end