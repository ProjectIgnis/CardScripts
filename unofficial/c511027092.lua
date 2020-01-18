--裁きの賽渦
--Judgment Roll
--Scripted by The Razgriz, Rundas, Revenant, andre and Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)  
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Activate from hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.con)
	c:RegisterEffect(e2)
	--Destroys itself in End Phase
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
function s.lkfilter(c,p)
	return s.cfilter(c,p) and c:IsType(TYPE_LINK)
end
function s.con(e)
	local g=Duel.GetChainInfo(Duel.GetCurrentChain(),CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.lkfilter,1,nil,e:GetHandlerPlayer())
end
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and re:GetHandler():IsType(TYPE_MONSTER)) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.cfilter,1,nil,tp)
end
function s.filter(c,sg)
	return sg:IsContains(c) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):Filter(s.cfilter,nil,tp)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.filter,1,false,nil,nil,sg) end
	local g=Duel.SelectReleaseGroupCost(tp,s.filter,1,1,false,nil,nil,sg)
	Duel.Release(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,1-tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
function s.atkfilter(c)
	return math.max(c:GetBaseAttack(),0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if chk==0 then return true end
	local c=e:GetHandler()
	local dice=Duel.TossDice(1-tp,1)
	local att=math.pow(2,dice-1)
	local tg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local g=Group.CreateGroup()
	for tc in aux.Next(tg) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if tc:IsAttribute(att) then
			e1:SetValue(2*tc:GetAttack())
		else
			if tc:GetAttack()~=0 then g:AddCard(tc) end
			e1:SetValue(0)
		end
		tc:RegisterEffect(e1)
	end
	if #g>0 then
		local dg=g:Filter(aux.NOT(aux.nzatk),nil)
		local dam1=dg:Filter(Card.IsControler,nil,tp):GetSum(s.atkfilter)
		local dam2=dg:Filter(Card.IsControler,nil,1-tp):GetSum(s.atkfilter)
		Duel.Damage(tp,dam1,REASON_EFFECT,true)
		Duel.Damage(1-tp,dam2,REASON_EFFECT,true)
		Duel.RDComplete()
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
