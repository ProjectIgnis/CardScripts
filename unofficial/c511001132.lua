--Mirage Ruler
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
   	--Special Summon destroyed monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27769400,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_BATTLE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.retcon)
	e2:SetCost(s.retcost)
	e2:SetTarget(s.rettg)
	e2:SetOperation(s.retop)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PHASE_START+PHASE_BATTLE_START)
		ge1:SetCountLimit(1)
		ge1:SetOperation(s.startop)
		Duel.RegisterEffect(ge1,0)
		local ge4=Effect.GlobalEffect()
		ge4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge4:SetCode(EVENT_DESTROYED)
		ge4:SetOperation(s.checkop)
		Duel.RegisterEffect(ge4,0)
	end)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function s.startop(e,tp,eg,ep,ev,re,r,rp)
	s[0]=Duel.GetLP(0)
	s[1]=Duel.GetLP(1)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	eg:ForEach(function(tc)
		if rp~=tc:GetPreviousControler() then
			tc:RegisterFlagEffect(id+tc:GetPreviousControler(),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
		end
	end)
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
function s.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.filter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:GetFlagEffect(id+c:GetPreviousControler())>0
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED+LOCATION_EXTRA,LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED+LOCATION_EXTRA,nil)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=#g and s[tp]>=1000 end
	local sg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,#sg,0,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED+LOCATION_EXTRA,LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED+LOCATION_EXTRA,nil)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if #g<=0 or ft<#g then return end
	for tc in aux.Next(g) do
		Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,tc:GetPreviousPosition(),true)
		tc:SetStatus(STATUS_FORM_CHANGED,true)
	end
	if Duel.GetLP(tp)~=s[tp] then
		Duel.SetLP(tp,s[tp],REASON_EFFECT)
		Duel.BreakEffect()
		Duel.PayLPCost(tp,1000)
	end
end
