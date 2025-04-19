--スカブ・スカーナイト (Anime)
--Scab Scarknight (Anime)
--Scripted by urielkama
--Rescripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,c:Alias())
	--must attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e2:SetValue(s.atklimit)
	c:RegisterEffect(e2)
	--battle indestructable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetCondition(s.indescon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--counter
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(s.ctcon)
	e4:SetTarget(s.cttg)
	e4:SetOperation(s.ctop)
	c:RegisterEffect(e4)
	--control
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_CONTROL)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.cltg)
	e5:SetOperation(s.clop)
	c:RegisterEffect(e5)
	--negate
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_DISABLE)
	e6:SetType(EFFECT_TYPE_QUICK_F)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.ngcon)
	e6:SetTarget(s.ngtg)
	e6:SetOperation(s.ngop)
	c:RegisterEffect(e6)
end
function s.atklimit(e,c)
	return c==e:GetHandler()
end
function s.indescon(e)
	return e:GetHandler():IsAttackPos()
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tc and not tc:IsControler(tp) and tc:IsRelateToBattle()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,e:GetHandler():GetBattleTarget(),1,1-tp,0x109a)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc and tc:IsRelateToBattle() then
		tc:AddCounter(0x109a,1)
	end
end
function s.cfilter(c)
	return c:GetCounter(0x109a)>0 and c:IsControlerCanBeChanged()
end
function s.cltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,#g,1-tp,LOCATION_MZONE)
end
function s.clop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_MZONE,nil)
	Duel.GetControl(g,tp)
end
function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainDisablable(ev) then return false end
	for p=0,1 do
		local e1=Duel.IsPlayerAffectedByEffect(p,EFFECT_REVERSE_DAMAGE)
		local e2=Duel.IsPlayerAffectedByEffect(p,EFFECT_REVERSE_RECOVER)
		local rd=e1 and not e2
		local rr=not e1 and e2
		local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_RECOVER)
		if ex and (cp==p or cp==PLAYER_ALL) and not rr then
			return true
		end
		ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
		if ex and (cp==p or cp==PLAYER_ALL) and rd then
			return true
		end
	end
	return false
end
function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end