--ＣＡＮ－Ｓｔ：Ｄ
--CAN - St:D
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Return 1 card on the field to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND|CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_CAN_D}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)
	return #g>0 and not g:IsExists(aux.NOT(Card.IsRace),1,nil,RACE_PSYCHIC|RACE_OMEGAPSYCHIC)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(tg,REASON_COST)==0 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #tc>0 then
		tc=tc:AddMaximumCheck()
		Duel.HintSelection(tc,true)
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_CAN_D) then
			Duel.BreakEffect()
			Duel.Recover(tp,700,REASON_EFFECT)
		end
	end
end
