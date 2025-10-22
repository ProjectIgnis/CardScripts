--Ｒ－ＡＣＥクイック・アタッカー
--Rescue-ACE Quick Attacker
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Add 1 "Rescue-ACE" monster from your Deck to your hand, then you can Special Summon it if only your opponent controls a monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfTribute)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_RESCUE_ACE}
function s.spcostfilter(c,tp)
	return c:IsSetCard(SET_RESCUE_ACE) and c:IsAbleToDeckAsCost() and Duel.GetMZoneCount(tp,c)>0
		and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sc=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,c,tp):GetFirst()
	if sc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,sc)
	else
		Duel.HintSelection(sc)
	end
	Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_RESCUE_ACE) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if sc and Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,sc)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
			and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	local c=e:GetHandler()
	--You cannot Special Summon from the Extra Deck for the rest of this turn, except FIRE monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsAttribute(ATTRIBUTE_FIRE) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--"Clock Lizard" check
	aux.addTempLizardCheck(c,tp,function(e,c) return not c:IsOriginalAttribute(ATTRIBUTE_FIRE) end)
end