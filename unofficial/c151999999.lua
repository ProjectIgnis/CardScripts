--Action Field Generator
local s,id=GetID()
function s.initial_effect(c)
	aux.EnableExtraRules(c,s,s.ActionStart)
end
function s.ActionStart()
	Duel.LoadCardScript("c151000000.lua")
end