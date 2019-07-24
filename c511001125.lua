--Life Shaver
local s,id=GetID()
function s.initial_effect(c)
	--discard
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(1082946)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.resetop)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		--register
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_SSET)
		ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_IMMEDIATELY_APPLY)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
		--counter
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_TURN_END)
		ge2:SetCountLimit(1)
		ge2:SetOperation(s.ctop)
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsCode,nil,id)
	local tc=g:GetFirst()
	while tc do
		tc:ResetFlagEffect(id)
		tc:RegisterFlagEffect(511001124,RESET_EVENT+RESETS_STANDARD,0,1)
		tc=g:GetNext()
	end
end
function s.regfilter(c)
	return c:GetFlagEffect(511001124)>0 and c:IsOriginalCode(id) and c:IsFacedown()
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()~=e:GetOwner():GetOwner() then return end
	local g=Duel.GetMatchingGroup(s.regfilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		tc=g:GetNext()
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetFlagEffect(id)
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_HAND,ct,e:GetHandler()) end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,ct)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.DiscardHand(p,nil,ct,ct,REASON_EFFECT+REASON_DISCARD)
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
	local ct=c:GetFlagEffect(id)
	c:SetTurnCounter(ct)
end
