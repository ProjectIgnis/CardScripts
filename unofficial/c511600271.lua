--コードブレイカー・ゼロデイ
--Codebreaker Zero Day
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--reverse atk/def
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	if not zeroDay then zeroDay={} end
	if not zeroDayReff then zeroDayReff={} end
end
s.listed_series={0x23b}
function s.filter(c,ec)
	return c:IsLinkMonster() and not c:IsSetCard(0x23b) and c:GetLinkedGroup():IsContains(ec)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e:GetHandler())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandler())
	for lc in aux.Next(lg) do
		local effs={lc:GetCardEffect(EFFECT_UPDATE_ATTACK)}
		for _,eff in ipairs(effs) do
			if eff:GetOwner()==lc and zeroDay[eff]==nil and not zeroDayReff[eff] then
				local reff=eff:Clone()
				reff:SetCondition(function(reff) if not lc:GetLinkedGroup():IsContains(c) then reff:Reset() return false end if eff:GetCondition() then return eff:GetCondition()(reff) else return true end end)
				reff:SetValue(function(reff,rc) if type(eff:GetValue())=='function' then return -eff:GetValue()(reff,rc)*2 else return -eff:GetValue()*2 end end)
				lc:RegisterEffect(reff)
				zeroDay[eff]=reff
				zeroDayReff[reff]=true
			end
		end
		local effs={lc:GetCardEffect(EFFECT_UPDATE_DEFENSE)}
		for _,eff in ipairs(effs) do
			if eff:GetOwner()==lc and zeroDay[eff]==nil and not zeroDayReff[eff] then
				local reff=eff:Clone()
				reff:SetCondition(function(reff) if not lc:GetLinkedGroup():IsContains(c) then reff:Reset() return false end if eff:GetCondition() then return eff:GetCondition()(reff) else return true end end)
				reff:SetValue(function(reff,rc) if type(eff:GetValue())=='function' then return -eff:GetValue()(reff,rc)*2 else return -eff:GetValue()*2 end end)
				lc:RegisterEffect(reff)
				zeroDay[eff]=reff
				zeroDayReff[reff]=true
			end
		end
	end
end
function s.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousSetCard(0x23b)
		and c:GetPreviousTypeOnField()&(TYPE_MONSTER+TYPE_LINK)==(TYPE_MONSTER+TYPE_LINK)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
