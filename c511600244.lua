--ブリッツ・ドローン
--Blitz Drone
--scripted by Larry126
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(1122)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.damcon)
	e2:SetCost(s.damcost)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
function s.filter(c,tp)
	return c:IsFaceup() and c:IsDrone() and c:IsControler(tp)
		and c:IsSummonLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp)
end
function s.cfilter(c,eg,tp)
	return eg:Filter(s.filter,nil,tp):IsContains(c)
end
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,eg,tp)
	end
	local tc=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,eg,tp):GetFirst()
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(tc:GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,tc:GetAttack())
	Duel.Release(tc,REASON_COST)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
