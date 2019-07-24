--Ritual of the Sibylla
local s,id=GetID()
function s.initial_effect(c)
	Ritual.AddProcGreater(c,aux.FilterBoolFunction(Card.IsCode,id+1))
end
