--セブンスロード・エンチャンター
--Sevens Road Enchanter
local s,id=GetID()
function s.initial_effect(c)
	--Return 1 spellcaster to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand() and not c:IsLevel(3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	g=g:AddMaximumCheck()
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		if g:GetFirst():IsCode(CARD_SEVENS_ROAD_MAGICIAN) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end