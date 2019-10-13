--戦華史略－孫劉同盟
--Senka Legend - The Sun-Liu Alliance
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--declare attribute
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.nacon)
	e2:SetTarget(s.natg)
	e2:SetOperation(s.naop)
	c:RegisterEffect(e2)
	--increase atk
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetCondition(s.atkcon1)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(aux.chainreg)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_CHAIN_SOLVED)
	e5:SetCondition(s.atkcon2)
	c:RegisterEffect(e5)
end
s.listed_series={0x137}
function s.nacon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsSetCard,0x137),tp,LOCATION_MZONE,0,nil)
	return #g>1 and g:GetClassCount(Card.GetAttribute)>1
end
function s.natg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local att=0
	local t=g:GetClass(Card.GetAttribute)
	for _,i in ipairs(t) do
		att=att|i
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local rc=Duel.AnnounceAttribute(tp,1,att)
	e:SetLabel(rc)
end
function s.naop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local att=e:GetLabel()
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsAttribute,att),tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
function s.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and e:GetHandler():GetFlagEffect(1)>0 and re:GetHandler():IsSetCard(0x137) and re:GetHandler():IsType(TYPE_MONSTER)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x137),tp,LOCATION_MZONE,0,1,nil) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsSetCard,0x137),tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		tc:UpdateAttack(#g*300,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,c)
	end
end

