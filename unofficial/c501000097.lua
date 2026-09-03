--JP name
--Silver Belfry Battery Bastion
local s,id=GetID()
function s.initial_effect(c)
	c:AddCannotBeSpecialSummoned()
	--Requires 3 Machine Tributes to Normal Summon (cannot be Normal Set)
	aux.AddNormalSummonProcedure(c,true,false,3,3)
	aux.AddNormalSetProcedure(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRIBUTE_LIMIT)
	e1:SetValue(function(e,c)
		return not c:IsRace(RACE_MACHINE)
	end)
	c:RegisterEffect(e1)
	--If this card attacks your opponent directly and reduces their LP to 0, you win the Match
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_MATCH_KILL)
	c:RegisterEffect(e2)
end