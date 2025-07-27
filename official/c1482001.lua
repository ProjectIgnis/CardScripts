--副話術士クララ＆ルーシカ
--Clara & Rushka, the Ventriloduo
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 1 Normal Summoned/Set monster
	Link.AddProcedure(c,aux.FilterBoolFunction(Card.IsSummonType,SUMMON_TYPE_NORMAL),1,1,nil,nil,s.splimit)
	--Cannot be Link Summoned except during Main Phase 2
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
end
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_LINK)~=SUMMON_TYPE_LINK or Duel.IsPhase(PHASE_MAIN2)
end