--
--Masterful Magician, Servant of the Sanctuary
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be Special Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	--Normal Summon with 3 Tributes (cannot be Normal Set)
	aux.AddNormalSummonProcedure(c,true,false,3,3)
	aux.AddNormalSetProcedure(c)
	--Can only Tribute Spellcaster monsters for its Normal Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRIBUTE_LIMIT)
	e1:SetValue(function(_e,_c) return not _c:IsRace(RACE_SPELLCASTER) end)
	c:RegisterEffect(e1)
	--Win the Match
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_MATCH_KILL)
	c:RegisterEffect(e2)
end