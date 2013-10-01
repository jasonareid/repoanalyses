module("jason.message_spec", package.seeall)

function accept_all()
	return MessageSpec.new(nil)
end

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
	return self.filter_words == nil or jason.utils.find(self.filter_words, function(w)
		lw = string.lower(w)
		lmessage = string.lower(message)
		return string.find(lmessage, lw)
	end)
end