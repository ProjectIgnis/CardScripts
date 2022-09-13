--オーバーレイ・ウェッジ
--Overlay Wedge
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Check for effects that detach material
	aux.GlobalCheck(s,function()
		s[0]=nil
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DETACH_MATERIAL)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local cid=Duel.GetCurrentChain()
	if cid>0 then
		s[0]=Duel.GetChainInfo(cid,CHAININFO_CHAIN_ID)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)==s[0] and re:GetHandler():IsType(TYPE_XYZ) and Duel.IsChainDisablable(ev) 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
	 --Cannot detach for the rest of this turn
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetCondition(s.accon)
	e2:SetValue(s.aclimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_XYZ),0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.aclimit(e,re)
	local g=Duel.GetMatchingGroup(s.acfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	if not re:IsActiveType(TYPE_XYZ) or g:GetMaxGroup(Card.GetRank):IsContains(re:GetHandler()) then return false end
	local eff={re:GetHandler():GetCardEffect(511002571)}
	for _,ree in ipairs(eff) do
		local te=ree:GetLabelObject()
		if te:GetCode()&511001822==511001822 or te:GetLabel()==511001822 then te=te:GetLabelObject() end
		if re==te then return true end
	end
	return false
end
