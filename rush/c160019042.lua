--ロードスター・グラディマギア
--Roadstar Gladimagia
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_SEVENS_ROAD_MAGICIAN,160204021)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,nil,nil,SUMMON_TYPE_FUSION,nil,false)
	--Decrease ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Gain piercing damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCost(s.cost)
	e2:SetTarget(s.piercetg)
	e2:SetOperation(s.pierceop)
	c:RegisterEffect(e2)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAbleToDeckOrExtraAsCost),tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.atkfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_GRAVE,0,nil):GetClassCount(Card.GetLevel)
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,0,LOCATION_MZONE,1,nil) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local sg=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,0,LOCATION_MZONE,1,1,nil)
	if #sg==0 then return end
	Duel.HintSelection(sg)
	--Decrease ATK
	local ct=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_GRAVE,0,nil):GetClassCount(Card.GetLevel)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	e1:SetValue(-400*ct)
	sg:GetFirst():RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	sg:GetFirst():RegisterEffect(e2)
end
function s.piercetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CanGetPiercingRush() end
end
function s.pierceop(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Effect
	e:GetHandler():AddPiercing(RESETS_STANDARD_PHASE_END)
end