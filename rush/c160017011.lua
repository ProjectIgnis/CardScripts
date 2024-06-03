--ダイスキー・クゥ
--Dice Key Kuu
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Add to the hand 1 "Dice Key Nel" from the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e)return e:GetHandler():IsStatus(STATUS_SUMMON_TURN)end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.roll_dice=true
s.listed_names={160211068}
function s.thfilter(c)
	return c:IsCode(160211068) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.filter(c)
	return c:IsFaceup() and c:IsDefensePos() and c:IsNotMaximumModeSide() and c:IsAbleToDeck()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		local sg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
		local d=Duel.TossDice(tp,1)
		if d==6 and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
			local sc=Group.Select(sg,tp,1,1,nil)
			if #sc==0 then return end
			Duel.HintSelection(sc)
			Duel.BreakEffect()
			Duel.SendtoDeck(sc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end