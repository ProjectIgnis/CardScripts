--Multiplying Thorns
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(s.descon)
	c:RegisterEffect(e2)
	--damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	--Self Damage (when thorn counter is removed)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_REMOVE_COUNTER+0x1104)
	e4:SetOperation(s.damop1)
	c:RegisterEffect(e4)
	--Self Damage 2 (when monster with Thorn counter leave the field)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetOperation(s.damop2)
	c:RegisterEffect(e5)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local p=Duel.GetTurnPlayer()
	local ct=Duel.GetCounter(p,LOCATION_ONFIELD,0,0x1104)
	Duel.SetTargetPlayer(p)
	Duel.SetTargetParam(ct*400)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,p,ct*400)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.descon(e)
	return Duel.GetCounter(0,1,0,0x1104)==0
end
function s.damop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(tp,ev*100,REASON_EFFECT)
end
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	local count=0
	local c=eg:GetFirst()
	while c~=nil do
		if c:IsPreviousLocation(LOCATION_ONFIELD) then
			count=count+c:GetCounter(0x1104)
		end
		c=eg:GetNext()
	end
	if count>0 then
		Duel.Damage(tp,count*100,REASON_EFFECT)
	end
end
