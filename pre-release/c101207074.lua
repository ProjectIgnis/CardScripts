--原質の臨界超過
--Materiactor Critical
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 card attached to 1 "Materiactor" Xyz Monster you control to your hand and negate the activation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_NEGATE+CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.thnegcon)
	e1:SetTarget(s.thnegtg)
	e1:SetOperation(s.thnegop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_MATERIACTOR}
function s.thnegcon(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsMonsterEffect() or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function s.xyzthfilter(c,tp)
	return s.materiactorxyzfilter(c) and c:GetOverlayGroup():IsExists(s.thfilter,1,nil,tp)
end
function s.materiactorxyzfilter(c)
	return c:IsSetCard(SET_MATERIACTOR) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
function s.thfilter(c,tp)
	return c:IsOwner(tp) and c:IsAbleToHand()
end
function s.thnegtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzthfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_OVERLAY)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.thnegop(e,tp,eg,ep,ev,re,r,rp)
	local xyzg=Duel.GetMatchingGroup(s.xyzthfilter,tp,LOCATION_MZONE,0,nil,tp)
	if #xyzg==0 then return end
	local og=Duel.GetOverlayGroup(tp,1,0,xyzg)
	if #og==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=og:FilterSelect(tp,s.thfilter,1,1,nil,tp):GetFirst()
	if sc and Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,sc)
		Duel.ShuffleHand(tp)
		if not Duel.NegateActivation(ev) then return end
		if sc:IsMonster() then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
			if #dg>0 then
				Duel.BreakEffect()
				Duel.SendtoDeck(dg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
		elseif sc:IsSpell() then
			Duel.BreakEffect()
			local atkg=Duel.GetMatchingGroup(s.materiactorxyzfilter,tp,LOCATION_MZONE,0,nil)
			for tc in atkg:Iter() do
				tc:UpdateAttack(1000)
			end
		elseif sc:IsTrap() and sc:IsSSetable() and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.SSet(tp,sc)
		end
	end
end