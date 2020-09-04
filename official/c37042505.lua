--不朽の特殊合金
--Special Dititanium Metal
--scripted by André
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.condition2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_JINZO}
function s.condition1(e,tp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,CARD_JINZO),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_MACHINE),tp,LOCATION_MZONE,0,1,nil) end
end
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsRace,RACE_MACHINE),tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(s.efilter)
		tc:RegisterEffect(e1)
	end
end
function s.efilter(e,re,rp)
	return e:GetHandlerPlayer()==1-rp
end
function s.tgfilter(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_MONSTER)
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	if not s.condition1(e,tp) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(s.tgfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
