--グリード
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--reg
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DRAW)
	e2:SetCondition(s.drcon)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	--damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT)~=0
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local flag=(ep==0 and id or id+1)
	local ct=c:GetFlagEffectLabel(flag)
	if ct then
		c:SetFlagEffectLabel(flag,ct+ev)
	else
		c:RegisterFlagEffect(flag,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,ev)
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(id)>0 or c:GetFlagEffect(id+1)>0
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local ct1=c:GetFlagEffectLabel(id)
	local ct2=c:GetFlagEffectLabel(id+1)
	if ct1 and ct2 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
	elseif ct1 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,0,ct1*500)
	elseif ct2 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1,ct2*500)
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ct1=c:GetFlagEffectLabel(id+tp)
	local ct2=c:GetFlagEffectLabel(id+1-tp)
	if ct1 then Duel.Damage(tp,ct1*500,REASON_EFFECT,true) end
	if ct2 then Duel.Damage(1-tp,ct2*500,REASON_EFFECT,true) end
	Duel.RDComplete()
end
