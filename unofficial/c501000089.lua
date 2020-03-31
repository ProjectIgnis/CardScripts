--黒き森の航天閣 
--Skyfaring Castle of the Black Forest
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.filter,3)
	--match kill
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATCH_KILL)
	e1:SetCondition(s.con)
	c:RegisterEffect(e1)
	--spsummon condition
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(aux.lnklimit)
	c:RegisterEffect(e3)
end
function s.con(e)
	return e:GetHandler():IsExtraLinked()
end
function s.filter(c,lc,sumtype,tp)
	return c:IsType(TYPE_EFFECT,lc,sumtype,tp) and c:IsRace(RACE_ROCK,lc,sumtype,tp)
end