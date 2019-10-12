--Infernity Zero (Anime)
--Scripted by Belisk 
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:EnableCounterPermit(0x1097,LOCATION_MZONE)
	--Special Summon Restrict
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--Special Summon + Survive
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Condition
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetCode(id)
	e3:SetLabel(0)
	e3:SetLabelObject(e2)
	e3:SetCondition(s.econ)
	Duel.RegisterEffect(e3,0)
	local e4=e3:Clone()
	e4:SetLabel(1)
	Duel.RegisterEffect(e4,1)
	--Indes. Battle
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--Counters
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_DAMAGE)
	e6:SetCondition(s.ctcon)
	e6:SetOperation(s.ctop)
	c:RegisterEffect(e6)
	--Self-Destruction
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_SELF_DESTROY)
	e7:SetCondition(s.descon)
	c:RegisterEffect(e7)
	if not s.global_check then
		--Check for Raise
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(s.zeroop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.econ(e,tp)
	return e:GetLabelObject():IsActivatable(e:GetLabel())
end
function s.spcon(e,tp)
	return Duel.GetLP(tp)<=0
end
function s.zeroop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLP(0)<=0 and not Duel.IsPlayerAffectedByEffect(0,EFFECT_CANNOT_LOSE_LP) 
		and Duel.GetFlagEffect(0,id+1)==0 and Duel.IsPlayerAffectedByEffect(0,id)
		and ep==0 and r&REASON_EFFECT==REASON_EFFECT then
		local iz1=Effect.CreateEffect(c)
		iz1:SetType(EFFECT_TYPE_FIELD)
		iz1:SetCode(EFFECT_CANNOT_LOSE_LP)
		iz1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		iz1:SetTargetRange(1,0)
		Duel.RegisterEffect(iz1,0)
		local iz2=Effect.CreateEffect(c)
		iz2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		iz2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
		iz2:SetCode(EVENT_ADJUST)
		iz2:SetLabelObject(iz1)
		iz2:SetLabel(0)
		iz2:SetOperation(s.zeroresetop)
		Duel.RegisterEffect(iz2,0)
		Duel.RaiseEvent(Duel.GetMatchingGroup(aux.TRUE,0,0xff,0,nil),EVENT_CUSTOM+id,nil,0,0,0,0)
		Duel.RegisterFlagEffect(0,id+1,0,0,1)
	end
	if Duel.GetLP(1)<=0 and not Duel.IsPlayerAffectedByEffect(1,EFFECT_CANNOT_LOSE_LP) 
		and Duel.GetFlagEffect(1,id+1)==0 and Duel.IsPlayerAffectedByEffect(1,id)
		and ep==1 and r&REASON_EFFECT==REASON_EFFECT then
		local iz1=Effect.CreateEffect(c)
		iz1:SetType(EFFECT_TYPE_FIELD)
		iz1:SetCode(EFFECT_CANNOT_LOSE_LP)
		iz1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		iz1:SetTargetRange(1,0)
		Duel.RegisterEffect(iz1,1)
		local iz2=Effect.CreateEffect(c)
		iz2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		iz2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
		iz2:SetCode(EVENT_ADJUST)
		iz2:SetLabelObject(iz1)
		iz2:SetLabel(0)
		iz2:SetOperation(s.zeroresetop)
		Duel.RegisterEffect(iz2,1)
		Duel.RaiseEvent(Duel.GetMatchingGroup(aux.TRUE,0,0xff,0,nil),EVENT_CUSTOM+id,nil,0,0,1,0)
		Duel.RegisterFlagEffect(1,id+1,0,0,1)
	end
end
function s.zeroresetop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentChain()==0 or e:GetLabel()>0 then
		local ct=e:GetLabel()+1
		e:SetLabel(ct)
	end
	if (e:GetLabel()==2 and Duel.GetCurrentPhase()&PHASE_DAMAGE==0) or e:GetLabel()==3 then
		e:GetLabelObject():Reset()
		e:Reset()
		Duel.ResetFlagEffect(tp,id+1)
	end
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	g:RemoveCard(e:GetHandler())
	if chk==0 then return #g>0 and g:FilterCount(Card.IsDiscardable,nil)==#g end
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_CHAIN)
	e1:SetCode(EFFECT_CANNOT_LOSE_LP)
	Duel.RegisterEffect(e1,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	local tp=e:GetHandlerPlayer()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_LOSE_LP)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetLabelObject(c)
		e2:SetCondition(s.lcon)
		e2:SetTargetRange(1,0)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.lcon(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetLabelObject()
	local py = e:GetHandlerPlayer()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(py)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=math.floor(ev/500)
	e:GetHandler():AddCounter(0x1097,ct)
end
function s.descon(e)
	return e:GetHandler():GetCounter(0x1097)>=3
end
