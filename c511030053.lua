--トポロジーナ・ハニカム・ビーワックス
--Topologina Beeswax
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x114a)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--avoid damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetValue(s.damval)
	c:RegisterEffect(e2)
	--remove counter
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.rctcon)
	e3:SetOperation(s.rctop)
	c:RegisterEffect(e3)
end
function s.desfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT) and c:IsLinkMonster()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return eg:IsExists(s.desfilter,1,nil,tp)
		and Duel.IsCanAddCounter(tp,0x114a,1,e:GetHandler()) end
	local ct=0
	for tc in aux.Next(eg) do
		ct=ct+tc:GetLink()
	end
	e:SetLabel(ct)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ct,0,0x114a)
end
function s.ctfilter(c)
	return c:IsSetCard(0x57b) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel() 
	if c:IsRelateToEffect(e) and c:AddCounter(0x114a,ct) then
		local g=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_REMOVED,0,nil)
		if #g>0 then
			Duel.BreakEffect()
			c:AddCounter(0x114a,#g)
		end
	end
end
function s.damval(e,re,val,r,rp,rc)
	local ct=e:GetHandler():GetCounter(0x114a)*500
	if not re and val<=ct then return 0 else return val end
end
function s.rctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x114a)~=0
end
function s.rctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsCanRemoveCounter(tp,0x114a,1,REASON_EFFECT) then
		c:RemoveCounter(tp,0x114a,1,REASON_EFFECT)
		if c:GetCounter(0x114a)<=0 then
			Duel.Destroy(c,REASON_EFFECT)
		end
	end
end