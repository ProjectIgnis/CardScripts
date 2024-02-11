--バック・トゥ・ザ☆フュージョン
--Back to The Fusion
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Fusion" from the graveyard to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_FUSION}
function s.filter(c,g)
	return g:IsExists(s.filter2,1,c,c:GetCode())
end
function s.filter2(c,code)
	return c:IsCode(code) and not c:IsMaximumMode()
end
function s.condition(e,tp,eg,ev,ep,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return g:IsExists(s.filter,1,nil,g)
end
function s.thfilter(c)
	return c:IsCode(CARD_FUSION) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thfilter2(c,tp)
	return c:IsType(TYPE_NORMAL) and c:IsMonster() and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,c,c:GetCode())
end
function s.cfilter(c,code)
	return c:IsType(TYPE_NORMAL) and c:IsMonster() and c:IsCode(code)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local dg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #dg>0 then
		Duel.HintSelection(dg,true)
		Duel.SendtoHand(dg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,dg)
		local g=Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_GRAVE,0,nil,tp)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g2=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil,tp)
			if #g2>0 then
				Duel.HintSelection(g2,true)
				Duel.SendtoHand(g2,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g2)
			end
		end
	end
end