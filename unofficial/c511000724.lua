--エクスプロージョン・ウィング
--Explosion Wing
--Rescripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Card destruction register
    	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
        	local ge1=Effect.CreateEffect(c)
        	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        	ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
        	ge1:SetCode(EVENT_DESTROYED)
        	ge1:SetOperation(s.checkop)
        	Duel.RegisterEffect(ge1,0)
        	local ge2=Effect.CreateEffect(c)
        	ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        	ge2:SetCode(EVENT_ADJUST)
		ge2:SetCondition(function(e) return Duel.GetCurrentPhase()==PHASE_END end)
        	ge2:SetCountLimit(1)
        	ge2:SetOperation(s.clear)
        	Duel.RegisterEffect(ge2,0)
    	end)
	--Inflict 500 damage to your opponent for each card destroyed this turn
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.dfilter(c)
	return c:GetReason()&REASON_EFFECT==REASON_EFFECT
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    	if ep==tp and eg:FilterCount(s.dfilter,nil)>0 then
        	s[tp]=s[tp]+eg:FilterCount(s.dfilter,nil)
    	end
    	if ep==1-tp and eg:FilterCount(s.dfilter,nil)>0 then
        	s[1-tp]=s[1-tp]+eg:FilterCount(s.dfilter,nil)
    	end
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
    	s[0]=0
    	s[1]=0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    	if chk==0 then return s[tp]>0 or s[1-tp]>0 end
    	local ct1=s[tp]
    	local ct2=s[1-tp]
    	local ct=ct1+ct2
    	Duel.SetTargetPlayer(1-tp)
    	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*500)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
    	local ct1=s[tp]
    	local ct2=s[1-tp]
    	local ct=ct1+ct2
	Duel.Damage(p,ct*500,REASON_EFFECT)
end
