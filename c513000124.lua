--Infernity Zero (Anime)
--scripted by Keddy
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--connot special summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	--Survive
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(511002521)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_LOSE_LP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--battle indestructable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--counter
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_DAMAGE)
	e4:SetCondition(s.ctcon)
	e4:SetOperation(s.ctop)
	c:RegisterEffect(e4)
	--self destroy
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_SELF_DESTROY)
	e6:SetCondition(s.sdcon)
	c:RegisterEffect(e6)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_CANNOT_LOSE_LP)
		ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		ge1:SetTargetRange(1,0)
		ge1:SetLabel(0)
		ge1:SetCondition(s.con2)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetLabel(1)
		Duel.RegisterEffect(ge2,1)
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_ADJUST)
		ge3:SetOperation(s.op)
		Duel.RegisterEffect(ge3,0)
	end)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(e:GetLabel(),511002521)>0
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	if Duel.GetLP(0)<=0 and ph~=PHASE_DAMAGE then
		Duel.RaiseEvent(Duel.GetMatchingGroup(nil,0,0xff,0,nil),511002521,e,0,0,0,0)
		Duel.ResetFlagEffect(0,511002521)
	end
	if Duel.GetLP(1)<=0 and ph~=PHASE_DAMAGE then
		Duel.RaiseEvent(Duel.GetMatchingGroup(nil,1,0xff,0,nil),511002521,e,0,0,0,0)
		Duel.ResetFlagEffect(1,511002521)
	end
	if Duel.GetLP(0)>0 and Duel.GetFlagEffect(0,511002521)==0 then
		Duel.RegisterFlagEffect(0,511002521,0,0,1)
	end
	if Duel.GetLP(1)>0 and Duel.GetFlagEffect(1,511002521)==0 then
		Duel.RegisterFlagEffect(1,511002521,0,0,1)
	end
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		g:RemoveCard(e:GetHandler())
		return #g>0 and g:FilterCount(Card.IsDiscardable,nil)==#g
	end
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	g:RemoveCard(e:GetHandler())
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_CHAIN)
	e1:SetCode(EFFECT_CANNOT_LOSE_LP)
	Duel.RegisterEffect(e1,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	elseif Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) then
		Duel.SendtoGrave(c,REASON_RULE)
	end
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=math.floor(ev/500)
	e:GetHandler():AddCounter(0x1097,ct)
end
function s.sdcon(e)
	return e:GetHandler():GetCounter(0x1097)>=3
end
