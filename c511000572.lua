--Jinzo (DM)
--Scripted by edo9300
Duel.LoadScript("c300.lua")
local s,id=GetID()
function s.initial_effect(c)
	--cannot trigger
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0xa,0xa)
	e1:SetCondition(s.con)
	e1:SetTarget(s.distg)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e2:SetCondition(s.con)
	e2:SetTarget(s.distg)
	c:RegisterEffect(e2)
	--disable effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.con)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	--disable trap monster
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetCondition(s.con)
	e4:SetTarget(s.distg)
	c:RegisterEffect(e4)
	--negate and destroy
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(51100567,10))
	e8:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetCode(EVENT_CHAINING)
	e8:SetRange(0xff)
	e8:SetCountLimit(1,id)
	e8:SetCost(s.cost)
	e8:SetCondition(s.condition)
	e8:SetTarget(s.target)
	e8:SetOperation(s.activate)
	c:RegisterEffect(e8)
end
s.dm=true
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsLocation(0x400)
end
function s.distg(e,c)
	return c:IsType(TYPE_TRAP)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if tl==LOCATION_SZONE and re:IsActiveType(TYPE_TRAP) then
		Duel.NegateEffect(ev)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,51100567)==0 end
	if Duel.GetTurnPlayer()==tp then
		Duel.RegisterFlagEffect(tp,51100567,RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1)
	else
		Duel.RegisterFlagEffect(tp,51100567,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=ep and re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev) and e:GetHandler():IsDeckMaster()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ng=Group.CreateGroup()
	local dg=Group.CreateGroup()
	for i=1,ev do
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		local tc=te:GetHandler()
		ng:AddCard(tc)
		if tc:IsType(TYPE_TRAP) and tc:IsRelateToEffect(te) then
			dg:AddCard(tc)
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
function s.distg2(c)
	return c:IsType(TYPE_TRAP)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local dg=Group.CreateGroup()
	for i=1,ev do
		Duel.NegateActivation(i)
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		local tc=te:GetHandler()
		if tc:IsRelateToEffect(e) and tc:IsRelateToEffect(te) and tc:IsControler(1-tp) then
			dg:AddCard(tc)
		end
	end
	local g=Duel.GetMatchingGroup(s.distg2,tp,0,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	Duel.Destroy(g,REASON_EFFECT)
end
