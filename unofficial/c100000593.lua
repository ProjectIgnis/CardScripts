--ダークネス ３
--Darkness 3
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
s.listed_names={100000591,100000592}
function s.cfilter(c)
	return c:IsFaceup() and (c:IsCode(100000591) or c:IsCode(100000592) or c:IsCode(id))
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_ONFIELD,0,nil)
	if ct>0 and Duel.GetFlagEffect(tp,100000590)~=0 then
		Duel.SetTargetPlayer(1-tp)
		Duel.SetTargetParam(ct*1000)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*1000)
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_ONFIELD,0,nil)
	Duel.Damage(p,ct*1000,REASON_EFFECT)
end
