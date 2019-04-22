--Ritual of the Sibylla
local s,id=GetID()
function s.initial_effect(c)
	aux.AddRitualProcGreater(c,aux.FilterBoolFunction(Card.IsCode,id+1))
end
