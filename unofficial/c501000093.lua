--JP name
--Elttaes, the MASTER of DUELS
local s,id=GetID()
function s.initial_effect(c)
	c:AddCannotBeSpecialSummoned()
	--Normal Summon with 3 Tributes (cannot be Normal Set)
	aux.AddNormalSummonProcedure(c,true,false,3,3)
	aux.AddNormalSetProcedure(c)
	--Can only Tribute Cyberse monsters for its Normal Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRIBUTE_LIMIT)
	e1:SetValue(function(e,c) return not c:IsRace(RACE_CYBERSE) end)
	c:RegisterEffect(e1)
	--Win the Match
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_MATCH_KILL)
	c:RegisterEffect(e2)
end