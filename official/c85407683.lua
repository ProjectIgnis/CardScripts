--星満ちる新世壊
--New World Stars
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Prevent destruction of monsters by battle once each turn while you control "Visas Starfrost"
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.indescond)
	e2:SetValue(s.indesval)
	c:RegisterEffect(e2)
	--Shuffle monster into the Deck during your End Phase
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetHintTiming(TIMING_END_PHASE,0)
	e3:SetCondition(s.tdcond)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_VISAS_STARFROST}
function s.indescond(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_VISAS_STARFROST),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.indesval(e,re,r,rp)
	if (r&REASON_BATTLE)~=0 then
		return 1
	else
		return 0
	end
end
function s.tdcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and Duel.IsPhase(PHASE_END)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_VISAS_STARFROST),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.tdfilter(c,tohand)
	return c:IsMonster() and (c:IsAbleToDeck() or (tohand and c:IsAbleToHand()))
end
function s.tunersyncfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER) and c:IsType(TYPE_SYNCHRO)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tohand=Duel.IsExistingMatchingCard(s.tunersyncfilter,tp,LOCATION_MZONE,0,1,nil)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc,tohand) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil,tohand) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil,tohand)
	if not tohand then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local tohand=Duel.IsExistingMatchingCard(s.tunersyncfilter,tp,LOCATION_MZONE,0,1,nil)
	if tohand then
		aux.ToHandOrElse(tc,tp,
				function() return tc:IsAbleToDeck() end,
				function() Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end,
				aux.Stringid(id,1)
		)
	else
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end