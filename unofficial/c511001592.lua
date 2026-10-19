--ハーフ・ライフ
--Half Life
local s,id=GetID()
function s.initial_effect(c)
	--Target 1 monster on the field. Once during this turn, if the targeted monster would be destroyed by battle, you can halve its original ATK instead.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0 and not c:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.cfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and not tc:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EFFECT_DESTROY_REPLACE)
		e1:SetCountLimit(1)
		e1:SetLabelObject(tc)
		e1:SetTarget(s.desreptg)
		e1:SetOperation(s.desrepop)
		e1:SetValue(function(e,c) return s.desrepfilter(c,e) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.desrepfilter(c,e)
	return c==e:GetLabelObject() and c:IsReason(REASON_BATTLE) and not c:IsReason(REASON_REPLACE|REASON_RULE) and c:GetEffectCount(EFFECT_INDESTRUCTABLE_BATTLE)==0
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.desrepfilter,1,nil,e) end
	if Duel.SelectEffectYesNo(tp,c,96) then return true end
	return false
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	e1:SetValue(tc:GetBaseAttack()/2)
	tc:RegisterEffect(e1)
end
