--デス・ペタル・カウントダウン
--Doom Petal Countdown
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE,0)
	c:RegisterEffect(e1)
	--Damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(s.damcon)
	e2:SetCost(s.damcost)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	--Destroy itself
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetCondition(s.sdcon)
	c:RegisterEffect(e3)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp)
end
function s.cfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,c) end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	c:RegisterFlagEffect(e:GetFieldID(),RESET_CHAIN,0,1,c:GetFlagEffect(id))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(300)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if e:GetHandler():IsRelateToEffect(e) then
		local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		Duel.Damage(p,d,REASON_EFFECT)
	end
	local ct=e:GetHandler():GetFlagEffectLabel(e:GetFieldID())
	if not Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,1,nil,RACE_PLANT) and ct then
		Duel.Damage(p,ct*300,REASON_EFFECT)
	end
end
function s.sdcon(e)
	return not Duel.IsExistingMatchingCard(Card.IsRace,e:GetHandler():GetControler(),LOCATION_GRAVE,0,1,nil,RACE_PLANT)
end