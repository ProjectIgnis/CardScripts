--ディメンション・ワンダラー (Anime)
--Dimension Wanderer (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--When a monster you control is banished by a card effect: You can send this card from your hand to the Graveyard, then target 2 banished monsters; inflict damage to your opponent equal to the total ATK of those targets.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62107612,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.condition)
	e1:SetCost(Cost.SelfToGrave)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) 
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() and chkc:IsLocation(LOCATION_REMOVED) and chkc:HasNonZeroAttack() end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.HasNonZeroAttack),tp,LOCATION_REMOVED,LOCATION_REMOVED,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.HasNonZeroAttack),tp,LOCATION_REMOVED,LOCATION_REMOVED,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetSum(Card.GetAttack))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	if #g==2 then
		local sum=g:GetSum(Card.GetAttack)
		Duel.Damage(1-tp,sum,REASON_EFFECT)
	end
end
