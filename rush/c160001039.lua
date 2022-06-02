--ロード・マジック－テンペスト
--Road Magic - Tempest

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Change the positions of up to 3 opponent's monsters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
	--Check for level 7+ spellcaster
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(7)
end
	--If the player controls a level 7+ spellcaster
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
	--Check for WIND monster
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
	--Check for WIND monster to send to GY
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanChangePositionRush,tp,0,LOCATION_MZONE,1,nil) end
end
	--Send 1 WIND monster from hand to GY to change the positions of up to 3 opponent's monsters
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,(s.costfilter),tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
	--Effect
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,3,nil)
		Duel.HintSelection(g)
		if #g>0 then
			Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		end
	end
end