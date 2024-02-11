--聖霊獣騎 レイラウタリ
--Ritual Beast Ulti-Reirautari
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon Procedure
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),3)
	--Neither player can Tribute cards to activate a card effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_RELEASE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,1)
	e1:SetTarget(function(e,c,rp,r,re) return r&REASON_COST>0 and re and re:IsActivated() end)
	c:RegisterEffect(e1)
	--Return 1 "Ritual Beast" card to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TOEXTRA+CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Banish 1 of your "Ritual Beast" cards and 1 of your opponent's cards
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e3:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e3:SetTarget(s.rmvtg)
	e3:SetOperation(s.rmvop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_RITUAL_BEAST}
function s.thfilter(c)
	return c:IsSetCard(SET_RITUAL_BEAST) and c:IsFaceup() and (c:IsAbleToHand() or c:IsAbleToExtra())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local tc=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil):GetFirst()
	local category=tc:IsType(TYPE_EXTRA) and CATEGORY_TOEXTRA or CATEGORY_TOHAND
	Duel.SetOperationInfo(0,category,tc,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.nsfilter(c)
	return c:IsSetCard(SET_RITUAL_BEAST) and c:IsSummonable(true,nil)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND|LOCATION_EXTRA)) then return end
	if tc:IsLocation(LOCATION_HAND) then Duel.ShuffleHand(tp) end
	if Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local g=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND,0,1,1,nil)
		if #g>0 then
			Duel.Summon(tp,g:GetFirst(),true,nil)
		end
	end
end
function s.rmvfilter(c,e,tp)
	return c:IsAbleToRemove() and c:IsCanBeEffectTarget(e)
		and ((c:IsFaceup() and c:IsSetCard(SET_RITUAL_BEAST)) or c:IsControler(1-tp))
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsControler,nil,tp)==1
end
function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.rmvfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e,tp)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE)
	Duel.SetTargetCard(rg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,#rg,0,0)
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end