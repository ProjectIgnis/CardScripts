--虹眼の星猫
--Rainbow-Eyes Star Cat
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Mill
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsDefense(200)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SUMMON_TURN) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,c)
end
function s.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and not c:IsMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeck(tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
function s.thfilter(c)
	return c:IsLevel(7) and c:IsDefense(200) and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.DiscardDeck(tp,ct,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:FilterCount(Card.IsMonster,nil)>0
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,2,nil)
		if #g2>0 then
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g2)
		end
	end
end