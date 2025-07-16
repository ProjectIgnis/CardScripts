--オーバーレイ・ウェッジ
--Overlay Wedge
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Negate an effect that was activated by detaching an Xyz Monster's own Xyz Material(s)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--Check for effects that detach material
	aux.GlobalCheck(s,function()
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
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)==s[0] and re:GetHandler():IsType(TYPE_XYZ) and Duel.IsChainDisablable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
	--Cannot detach for the rest of this turn
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(1,1)
	e2:SetValue(s.aclimit)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.aclimit(e,re)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_XYZ),0,LOCATION_MZONE,LOCATION_MZONE,nil)
	return re:HasDetachCost() and not g:GetMaxGroup(Card.GetRank):IsContains(re:GetHandler())
end