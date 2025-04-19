--魔封印の宝札
--Card of Spell Containment
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.checkop1)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_MSET)
		ge2:SetOperation(s.checkop2)
		Duel.RegisterEffect(ge2,0)
		local ge3=ge2:Clone()
		ge3:SetCode(EVENT_SSET)
		Duel.RegisterEffect(ge3,0)
		local ge4=Effect.CreateEffect(c)
		ge4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge4:SetCode(EVENT_CHANGE_POS)
		ge4:SetOperation(s.checkop3)
		Duel.RegisterEffect(ge4,0)
		local ge5=Effect.CreateEffect(c)
		ge5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge5:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge5:SetOperation(s.checkop4)
		Duel.RegisterEffect(ge5,0)
	end)
end
function s.checkop1(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_SPELL) then
		Duel.RegisterFlagEffect(rp,id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.checkop2(e,tp,eg,ep,ev,re,r,rp)
	for ec in aux.Next(eg) do
		Duel.RegisterFlagEffect(ec:GetReasonPlayer(),id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.checkop3(e,tp,eg,ep,ev,re,r,rp)
	for ec in aux.Next(eg) do
		if ec:IsPreviousPosition(POS_FACEUP) and ec:IsFacedown() then
			Duel.RegisterFlagEffect(ec:GetReasonPlayer(),id,RESET_PHASE|PHASE_END,0,1)
		end
	end
end
function s.checkop4(e,tp,eg,ep,ev,re,r,rp)
	for ec in aux.Next(eg) do
		if ec:IsFacedown() then
			Duel.RegisterFlagEffect(ec:GetSummonPlayer(),id,RESET_PHASE|PHASE_END,0,1)
		end
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_MSET)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(aux.TRUE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SSET)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_TURN_SET)
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetTarget(s.sumlimit)
	Duel.RegisterEffect(e4,tp)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetTargetRange(1,0)
	e5:SetValue(s.aclimit)
	e5:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e5,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,0),nil)
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsSpell()
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return (sumpos&POS_FACEDOWN)~=0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end