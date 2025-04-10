--セリオンズ・クロス
--Therion Cross
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_ARGYRO_SYSTEM}
s.listed_series={SET_THERION}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_THERION),tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local b1=Duel.IsChainDisablable(ev) and not rc:IsDisabled()
	local b2=rc:IsAbleToRemove() and rc:IsRelateToEffect(re) and not rc:IsLocation(LOCATION_REMOVED)
	local b3=b1 and b2 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_ARGYRO_SYSTEM)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)},
		{b3,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DISABLE)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	elseif op==2 then
		Duel.SetTargetCard(rc)
		e:SetCategory(CATEGORY_REMOVE)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,1-tp,rc:GetLocation())
	elseif op==3 then
		Duel.SetTargetCard(rc)
		e:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,1-tp,rc:GetLocation())
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local rc=re:GetHandler()
	--Negate that effect
	if op==1 then
		Duel.NegateEffect(ev)
	--Banish that monster
	elseif op==2 then
		if rc:IsRelateToEffect(e) then
			Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
		end
	--Activate both, in sequence
	elseif op==3 then
		if Duel.NegateEffect(ev) and rc:IsRelateToEffect(e) then
			Duel.BreakEffect()
			Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
		end
	end
end