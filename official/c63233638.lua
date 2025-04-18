--メガリス・ファレグ
--Megalith Phaleg
--Scripted by ahtelel
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	local ritual_target_params={handler=c,lvtype=RITPROC_GREATER,filter=function(ritual_c) return ritual_c:IsSetCard(SET_MEGALITH) and ritual_c~=c end,forcedselection=s.forcedselection}
	local ritual_operation_params={handler=c,lvtype=RITPROC_GREATER,filter=function(ritual_c) return ritual_c:IsSetCard(SET_MEGALITH) end}
	--Ritual Summon 1 "Megalith" Ritual Monster from your hand, by Tributing monsters from your hand or field whose total Levels equal or exceed its Level
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(Ritual.Target(ritual_target_params))
	e1:SetOperation(Ritual.Operation(ritual_operation_params))
	c:RegisterEffect(e1)
	--Monsters you control gain 300 ATK/DEF for each Ritual Monster in your GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(function(e,c) return 300*Duel.GetMatchingGroupCount(Card.IsRitualMonster,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil) end)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MEGALITH}
function s.forcedselection(e,tp,g,sc)
	local c=e:GetHandler()
	return not g:IsContains(c),g:IsContains(c)
end