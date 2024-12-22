--Ｅ・ＨＥＲＯ ボルテック・ウィングマン
--Elemental HERO Voltic Wingman
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:AddMustBeFusionSummoned()
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,21844576,20721928)
	--Miracle Fusion
	local params = {s.filter,s.mfilter,s.fextra,Fusion.ShuffleMaterial}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e) return e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN) end)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e1)
end
function s.filter(c)
	local e=c:IsHasEffect(EFFECT_SPSUMMON_CONDITION)
	return c:IsRace(RACE_WARRIOR) and c:IsLevelBetween(6,8) and e and e:GetValue()==aux.fuslimit
end
function s.mfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsAbleToDeck()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
end