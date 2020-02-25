--アルカナフォースEX－THE DARK RULER
--Arcana Force EX - The Dark Ruler
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--special summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--cannot special summon
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	--coin register
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_COIN)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(s.cointg)
	e3:SetOperation(s.coinop)
	c:RegisterEffect(e3)
end
s.toss_coin=true
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,nil)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and #rg>2 and aux.SelectUnselectGroup(rg,e,tp,3,3,nil,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,3,3,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g or #g~=3 then return end
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local res=0
	if c:IsHasEffect(73206827) then
		res=1-Duel.SelectOption(tp,60,61)
	else res=Duel.TossCoin(tp,1) end
	s.arcanareg(c,res)
end
function s.arcanareg(c,coin)
	--coin effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetCondition(s.macon)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.poscon)
	e2:SetOperation(s.posop)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetOperation(s.desop1)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
	--
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetOperation(s.desop2)
	e4:SetReset(RESET_EVENT+RESETS_CANNOT_ACT)
	c:RegisterEffect(e4)
	c:RegisterFlagEffect(36690018,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,coin,63-coin)
end
function s.macon(e)
	return e:GetHandler():GetFlagEffectLabel(36690018)==1
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffectLabel(36690018)==1 and c:GetAttackAnnouncedCount()>=2
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_COPY_INHERIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	c:RegisterEffect(e1)
end
function s.desop1(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetFlagEffectLabel(36690018)==0 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_CANNOT_ACT,0,1)
	end
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id)~=0 then
		local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
