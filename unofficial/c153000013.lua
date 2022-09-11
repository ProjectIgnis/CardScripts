--人造人間－サイコ・ショッカー (Deck Master)
--Jinzo (Deck Master)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	if not DeckMaster then
		return
	end
	--Deck Master Ability
	local dme1=Effect.CreateEffect(c)
	dme1:SetType(EFFECT_TYPE_FIELD)
	dme1:SetCode(EFFECT_DISABLE)
	dme1:SetTargetRange(0,LOCATION_ONFIELD)
	dme1:SetCondition(function(e) return Duel.IsDeckMaster(e:GetOwnerPlayer(),id) end)
	dme1:SetTarget(aux.TargetBoolFunction(Card.IsTrap))
	local dme2=dme1:Clone()
	dme2:SetCode(EFFECT_DISABLE_EFFECT)
	local dme3=dme1:Clone()
	dme3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	local dme4=Effect.CreateEffect(c)
	dme4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	dme4:SetCode(EVENT_ADJUST)
	dme4:SetCondition(s.dmcon)
	dme4:SetOperation(s.dmop)
	DeckMaster.RegisterAbilities(c,dme1,dme2,dme3,dme4)
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsTrap))
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.condition)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e6)
	local e7=e4:Clone()
	e7:SetCode(EVENT_ADJUST)
	c:RegisterEffect(e7)
end
function s.filter(c)
	return c:IsTrap() and c:IsDisabled()
end
function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(s.filter),tp,0,LOCATION_ONFIELD,1,nil) and Duel.IsDeckMaster(tp,id)
end
function s.dmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(s.filter),tp,0,LOCATION_ONFIELD,nil)
	Duel.Destroy(g,REASON_EFFECT)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.Destroy(g,REASON_EFFECT)
end
