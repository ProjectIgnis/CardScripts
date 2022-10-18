--六世壊根清浄
--Kshatri-La Big Bang
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Make both players banish monsters face-down so they control only 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START+TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmvcond)
	e1:SetTarget(s.rmvtg)
	e1:SetOperation(s.rmvop)
	c:RegisterEffect(e1)
	--Return 1 monster attached to the hand and Special Summon it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_KSHATRI_LA}
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_KSHATRI_LA)
end
function s.rmvcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.rmfilter(c,p)
	return Duel.IsPlayerCanRemove(p,c) and not c:IsType(TYPE_TOKEN)
end
function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,0,nil,tp)
	local g2=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_MZONE,nil,1-tp)
	if chk==0 then return (#g1>1 and not Duel.IsPlayerAffectedByEffect(tp,30459350))
		or (#g2>1 and not Duel.IsPlayerAffectedByEffect(1-tp,30459350)) end
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	local p1=Duel.GetTurnPlayer() --used to make the turn player banish first
	local p2=1-Duel.GetTurnPlayer()
	local g1=Duel.GetMatchingGroup(s.rmfilter,p1,LOCATION_MZONE,0,nil,p1)
	if not Duel.IsPlayerAffectedByEffect(p1,30459350) and #g1>1 then
		local ct=#g1-1
		Duel.Hint(HINT_SELECTMSG,p1,HINTMSG_REMOVE)
		local sg=g1:FilterSelect(p1,Card.IsAbleToRemove,ct,ct,nil,p1,POS_FACEDOWN,REASON_RULE)
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE)
	end
	local g2=Duel.GetMatchingGroup(s.rmfilter,p2,LOCATION_MZONE,0,nil,p2)
	if not Duel.IsPlayerAffectedByEffect(p2,30459350) and #g2>1 then
		local ct=#g2-1
		Duel.Hint(HINT_SELECTMSG,p2,HINTMSG_REMOVE)
		local sg=g2:FilterSelect(p2,Card.IsAbleToRemove,ct,ct,nil,p2,POS_FACEDOWN,REASON_RULE)
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE)
	end
end
function s.thfilter(c,tp)
	return c:IsMonster() and c:IsSetCard(SET_KSHATRI_LA) and c:GetOwner()==tp and c:IsAbleToHand() 
end
function s.tgfilter(c,tp)
	if not (c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_KSHATRI_LA)) then return false end
	local g=c:GetOverlayGroup()
	return g:IsExists(s.thfilter,1,nil,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and s.tgfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_OVERLAY)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local g=tc:GetOverlayGroup()
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=g:FilterSelect(tp,s.thfilter,1,1,nil,tp):GetFirst()
	if sc and Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.ShuffleHand(tp)
		if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
		Duel.BreakEffect()
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end