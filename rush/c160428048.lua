--未知との邂逅
--Cross Target
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Return to hand an attack target and a monster from GY to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160006013}
function s.psyfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and (c:IsRace(RACE_PSYCHIC) or c:IsRace(RACE_OMEGAPSYCHIC))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	return tc:IsControler(1-tp) and tc:IsLevelBelow(8) and tc:IsAbleToHand()
		and Duel.IsExistingMatchingCard(s.psyfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=Duel.GetAttacker()
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thfilter(c)
	return c:IsLevelBelow(3) and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc:IsRelateToBattle() and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)
		and	Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,160006013),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end	
end