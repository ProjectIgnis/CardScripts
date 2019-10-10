--ハイドライブ・プロテクション
--Hydradrive Protection
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--leave field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(s.protcon)
	e2:SetOperation(s.protop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
function s.monfilter(c)
	return c:IsLinkMonster() and c:IsSetCard(0x577) and c:IsFaceup()
end
function s.stfilter(c)
	return c:GetSequence()<5 and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.monfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(s.stfilter,tp,LOCATION_SZONE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,s.monfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g2=Duel.SelectTarget(tp,s.stfilter,tp,LOCATION_SZONE,0,1,1,e:GetHandler())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #tg<1 then return end
	local tc1=tg:GetFirst()
	tc1:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	local tc2=tg:GetNext()
	tc2:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	--cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e1:SetTarget(aux.TargetBoolFunction(s.protfilter))
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	c:SetCardTarget(tc1)
	c:SetCardTarget(tc2)
end
function s.protfilter(c)
	return c:GetFlagEffect(id)>0
end
function s.protcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.protfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	return g and #g>=1
end
function s.protop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.protfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	--cannot destroy
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc1:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc2:RegisterEffect(e2)
end