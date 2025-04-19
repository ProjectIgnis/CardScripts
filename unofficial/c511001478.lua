--ナイト・オブ・ペンタクルス
--Knight of Pentacles
local s,id=GetID()
function s.initial_effect(c)
	--Toss a coin on Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97574404,0))
	e1:SetCategory(CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.cointg)
	e1:SetOperation(s.coinop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
s.toss_coin=true
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local res=Duel.TossCoin(tp,1)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD_DISABLE,EFFECT_FLAG_CLIENT_HINT,1,0,aux.GetCoinEffectHintString(res))
	if res==COIN_TAILS then
		--Cannot attack
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		--destroy if attacked
		local e2=Effect.CreateEffect(c)
		e2:SetCategory(CATEGORY_DESTROY)
		e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
		e2:SetCode(EVENT_DAMAGE_STEP_END)
		e2:SetCondition(s.descon)
		e2:SetTarget(s.destg)
		e2:SetOperation(s.desop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e2)
	elseif res==COIN_HEADS then
		--Cannot be destroyed by battle
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e3)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and Duel.GetAttackTarget() and c==Duel.GetAttackTarget()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end