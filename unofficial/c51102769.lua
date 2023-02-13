--G.O.D.-Eyes Phantom Dragon
--All-Eyes-Eyes Phantom Dragon (Manga)
--Made By Beetron-1 Beetletop
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--Cannot be normal summoned/set
	c:EnableUnsummonable()
	--Cannot be pend summoned from hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.limit)
	c:RegisterEffect(e1)
	--special summon procedure
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--atk change for non direct attack
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetLabelObject(e2)
	e3:SetCondition(s.atkcon1)
	e3:SetTarget(s.atktg1)
	e3:SetOperation(s.atkop1)
	c:RegisterEffect(e3)
	--atk change for direct attack
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetLabelObject(e2)
	e4:SetCondition(s.atkcon2)
	e4:SetTarget(s.atktg2)
	e4:SetOperation(s.atkop2)
	c:RegisterEffect(e4)
	--turn skip
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_ATTACK_DISABLED)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.skipcon)
	e5:SetOperation(s.skipop)
	c:RegisterEffect(e5)
	--negate
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_NEGATE)
		e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_CHAINING)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.discon)
	e6:SetCost(s.discost)
	e6:SetTarget(s.distg)
	e6:SetOperation(s.disop)
	c:RegisterEffect(e6)
end

--special summon condition

function s.limit(e,se,sp,st)
    if (st&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM then
        return not e:GetHandler():IsLocation(LOCATION_HAND)
    end
    return true
end

--special summon proc

function s.cfilter(c)
	return c:GetSequence()<5
end

function s.pfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsRace(RACE_DRAGON)
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local rg=Duel.GetReleaseGroup(tp)
	return (#g>0 or #rg>0) and g:FilterCount(Card.IsReleasable,nil)==#g and #g>0 and g:IsExists(s.pfilter,1,nil)
		and g:FilterCount(s.cfilter,nil)+Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end

function s.matfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_PENDULUM)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetReleaseGroup(tp)
	local o=Group.FilterCount(g,s.matfilter,nil)
	e:SetLabel(o)
	Duel.Release(g,REASON_COST)
	e:GetHandler():RegisterFlagEffect(id,0,0,0)
end

--atk change for non direct attack

function s.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return e:GetHandler():GetFlagEffect(id)~=0 and tc and tc:IsFaceup()
end

function s.atktg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():GetBattleTarget()~=nil end
	e:GetHandler():GetBattleTarget():CreateEffectRelation(e)
end

function s.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	local g=e:GetLabelObject()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetLabelObject(g)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(s.atkupval)
		c:RegisterEffect(e1)	
	end
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)	
		e2:SetLabelObject(g)
		e2:SetValue(s.atkdownval)
		tc:RegisterEffect(e2)
		end
end

function s.atkupval(e,tp,eg,ep,ev,re,r,rp)
	local v=e:GetLabelObject():GetLabel()	
	return v*1000
end

function s.atkdownval(e,tp,eg,ep,ev,re,r,rp)
	local v=e:GetLabelObject():GetLabel()
	return -v*1000
end

--atk change for direct attack

function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end

function s.atktg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():GetBattleTarget()==nil end
end

function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=e:GetLabelObject()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetLabelObject(g)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(s.atkupval)
		c:RegisterEffect(e1)	
	end
end

--skip turn

function s.skipcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst()==e:GetHandler()
end

function s.skipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SkipPhase(tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetCode(EFFECT_CANNOT_ACTIVATE)
	e0:SetTargetRange(0,1)
	e0:SetValue(1)
	e0:SetReset(RESET_PHASE+PHASE_BATTLE+PHASE_END)
	Duel.RegisterEffect(e0,tp)
	Duel.SkipPhase(tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(tp,PHASE_END,RESET_PHASE+PHASE_END,1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_TURN)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	Duel.RegisterEffect(e1,tp)
	Duel.SkipPhase(tp,PHASE_DRAW,RESET_PHASE+PHASE_END,2)
	Duel.SkipPhase(tp,PHASE_STANDBY,RESET_PHASE+PHASE_END,2)
	Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,2)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_EP)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_MAIN1+RESET_SELF_TURN)
	Duel.RegisterEffect(e2,tp)
end

--negate

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return ep~=tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end

function s.disfilter(c)
	return c:IsAbleToGraveAsCost()
end

function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local tc=re:GetHandler()
	local x
	if tc:IsOnField() then x=true end
	if not tc:IsOnField() then x=false end
	if Duel.NegateActivation(ev) and tc:IsSSetable() or tc:IsType(TYPE_PENDULUM) then
		if tc:IsFaceup() and x==true then
			tc:CancelToGrave()
			Duel.ChangePosition(tc,POS_FACEDOWN)
			Duel.RaiseEvent(tc,EVENT_SSET,e,REASON_EFFECT,1-tp,1-tp,0)
		end
		if x==false then
			Duel.SSet(1-tp,tc)
			Duel.RaiseEvent(tc,EVENT_SSET,e,REASON_EFFECT,1-tp,1-tp,0)
		end
	end
local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_CANNOT_ACT+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
end