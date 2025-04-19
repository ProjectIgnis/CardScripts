--Ｄスケイル・チャフ
--D-Scale Chaff
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x579}
function s.cfilter(c,lk)
	return c:IsFaceup() and c:IsSetCard(0x579) and c:IsLink(lk)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND|LOCATION_MZONE)
	return ct>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,ct)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local resets=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
	local g=Duel.GetMatchingGroup(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,nil)
	for tc in g:Iter() do
		--Negate its effects
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(resets)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(resets)
		tc:RegisterEffect(e2)
		--Cannot attack
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(resets)
		tc:RegisterEffect(e3)
	end
	local g2=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
	for tc in g2:Iter() do
		--Negate its effects
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_DISABLE)
		e4:SetReset(resets)
		tc:RegisterEffect(e4)
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_DISABLE_EFFECT)
		e5:SetValue(RESET_TURN_SET)
		e5:SetReset(resets)
		tc:RegisterEffect(e5)
	end
end