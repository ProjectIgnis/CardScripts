--ワイト男爵
--Baron Wight
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "Skull Servant" in the Graveyard
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(s.condition)
	e1:SetValue(CARD_SKULL_SERVANT)
	c:RegisterEffect(e1)
	--Send to GY
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.condition(e)
	return Duel.IsTurnPlayer(1-e:GetHandlerPlayer())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAttackPos() and c:IsCanChangePositionRush() end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE,0,0,0)<1 then return end
	--Effect
	if Duel.DiscardDeck(tp,1,REASON_EFFECT)==0 then return end
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_SKULL_SERVANT,36021814)
		and Duel.IsPlayerCanDiscardDeck(tp,2) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.DiscardDeck(tp,2,REASON_EFFECT)
	end
end