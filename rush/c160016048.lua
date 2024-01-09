--プライム・コール
--Prime Call
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 monster from the grave to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_FUSION,160016001}
function s.cfilter(c)
	return c:IsMonster() and not c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsMonster,tp,LOCATION_GRAVE,0,1,nil)
		and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.thfilter(c)
	return c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thfilter2(c)
	return c:IsCode(CARD_FUSION) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local dg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #dg>0 then
		Duel.SendtoHand(dg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,dg)
		local g=Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_GRAVE,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			local g2=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
			if #g2>0 then
				Duel.SendtoHand(g2,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g2)
			end
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.aclimit(e,re,tp)
	return re:IsMonsterEffect() and not re:GetHandler():IsCode(160016001)
end