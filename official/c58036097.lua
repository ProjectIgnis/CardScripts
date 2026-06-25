--どきどきメルフィータイム
--Exciting Melffy Time
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Target 1 "Melffy" monster in your field or GY; return it to the hand, then you can Fusion Summon 1 Beast Fusion Monster from your Extra Deck, using monsters from your hand or field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--If you control a "Melffy" Xyz Monster: You can banish this card from your GY; "Melffy" monsters you control that were Special Summoned from the Extra Deck are unaffected by your opponent's activated effects this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.immcon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetOperation(s.immop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MELFFY}
function s.rthfilter(c)
	return c:IsSetCard(SET_MELFFY) and c:IsMonster() and c:IsFaceup() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and chkc:IsControler(tp) and s.rthfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rthfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.rthfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_FUSION_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		Duel.ShuffleHand(tc:GetControler())
		local fusion_params={handler=c,fusfilter=aux.FilterBoolFunction(Card.IsRace,RACE_BEAST)}
		if Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Fusion.SummonEffOP(fusion_params)(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end
function s.immconfilter(c)
	return c:IsSetCard(SET_MELFFY) and c:IsXyzMonster() and c:IsFaceup()
end
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.immconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,3))
	--"Melffy" monsters you control that were Special Summoned from the Extra Deck are unaffected by your opponent's activated effects this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsSetCard(SET_MELFFY) and c:IsSummonLocation(LOCATION_EXTRA) and c:IsFaceup() end)
	e1:SetValue(function(e,re) return re:GetHandlerPlayer()==1-e:GetHandlerPlayer() and re:IsActivated() end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end