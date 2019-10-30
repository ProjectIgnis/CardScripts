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
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetCode(id)
	e2:SetRange(LOCATION_FZONE)
	c:RegisterEffect(e2)
	--negate attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_COIN)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_DESTINY_BOARD}
s.toss_coin=true
function s.chcon1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return re:GetHandlerPlayer()==tp and re:IsHasCategory(CATEGORY_TOFIELD) and re:GetLabel()==CARD_DESTINY_BOARD and re:GetValue()~=nil
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
	return not tc:IsCode(CARD_DESTINY_BOARD)
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