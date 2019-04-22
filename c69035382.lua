--奈落との契約
local s,id=GetID()
function s.initial_effect(c)
	aux.AddRitualProcEqual(c,s.ritual_filter)
end
function s.ritual_filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsAttribute(ATTRIBUTE_DARK) 
end
