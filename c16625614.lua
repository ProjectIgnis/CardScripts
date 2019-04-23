--ダーク・サンクチュアリ
--Dark Sanctuary
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--update effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.chcon1)
	e2:SetOperation(s.chop1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_ACTIVATING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.chcon2)
	e3:SetOperation(s.chop2)
	c:RegisterEffect(e3)
	--negate attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCategory(CATEGORY_COIN)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(s.condition)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
s.toss_coin=true
function s.chcon1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return re:GetHandlerPlayer()==tp and re:IsHasCategory(CATEGORY_TOFIELD) and re:GetLabel()==94212438 and re:GetValue()~=nil
end
function s.chop1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1,ev)
end
function s.chcon2(e,tp,eg,ep,ev,re,r,rp)
	return ev==e:GetHandler():GetFlagEffectLabel(id)
end
function s.chop2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.ChangeChainOperation(ev,re:GetValue())
end
function s.efilter(e,te)
	local tc=te:GetHandler()
	return not tc:IsCode(94212438)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetAttacker()
	local coin=Duel.TossCoin(tp,1)
	if coin==1 then
		if Duel.NegateAttack() then
			Duel.Damage(1-tp,math.ceil(tc:GetAttack()/2),REASON_EFFECT)
		end
	end
end