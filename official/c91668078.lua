--雪沓の 跡追うひとつ またひとつ
--In Papa's Footsteps
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Banish up to 5 cards from your GY face-down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={id}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(aux.NOT(Card.IsCode),1,nil,id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,nil,tp,POS_FACEDOWN,REASON_EFFECT) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local your_rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,5,nil,tp,POS_FACEDOWN,REASON_EFFECT)
	if #your_rg==0 then return end
	Duel.HintSelection(your_rg,true)
	if Duel.Remove(your_rg,POS_FACEDOWN,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_REMOVED,0,7,nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil,1-tp,POS_FACEDOWN,REASON_EFFECT) then
		local oppo_rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil,1-tp,POS_FACEDOWN,REASON_EFFECT)
		if #oppo_rg>5 then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
			oppo_rg=oppo_rg:FilterSelect(1-tp,Card.IsAbleToRemove,5,5,nil,1-tp,POS_FACEDOWN,REASON_EFFECT)
		end
		Duel.HintSelection(oppo_rg,true)
		Duel.BreakEffect()
		Duel.Remove(oppo_rg,POS_FACEDOWN,REASON_EFFECT,nil,1-tp)
	end
end