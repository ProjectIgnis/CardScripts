--封魔閃光
--Radiance of the Forbidden Spell
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Make 1 Monster Zone unusable
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.disfieldcond)
	e2:SetOperation(s.disfieldop)
	c:RegisterEffect(e2)
	--Make all your Monster Zones usuable an increase the ATK of your battling monster by 800 per zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(s.atkcond)
	e3:SetCost(s.atkcost)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	--Inflict damage equal to the number of zones unusable due to this card's effects
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end
function s.disfieldcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp)
end
function s.disfieldop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,LOCATION_REASON_COUNT)<=0 then return end
	--Make one of the turn player's Monster Zones unusable
	local zone=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local c=e:GetHandler()
	if Duel.IsTurnPlayer(1-c:GetControler()) then
		zone=zone<<16
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetOperation(function(e,tp) return zone end)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	--e1:SetLabel(zone)
	c:RegisterEffect(e1)
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
end
function s.atkcond(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPhase(PHASE_DAMAGE) or Duel.IsDamageCalculated() then return false end
	return Duel.GetBattleMonster(tp)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function s.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local at=Duel.GetBattleMonster(tp)
	if chk==0 then return at and not at:HasFlagEffect(id)
		and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_COUNT) end
	Duel.SetTargetCard(at)
	at:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE,0,1)
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,tp,POS_DEFENSE)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,at,1,tp,800)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local zonect=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_COUNT)
	if zonect==0 then return end
	local c=e:GetHandler()
	--Make all your Monster Zones usuable your monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(s.disallop)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
	e:GetHandler():RegisterEffect(e1)
	--Increase the ATK of your monster but destroy it during at the End of the Damage Step
	local at=Duel.GetBattleMonster(tp)
	if at and at:IsFaceup() and at:IsRelateToBattle() then
		--Gain 800 ATK per zone
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(zonect*800)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		at:RegisterEffect(e2)
		--Destroy it during the End of the Damage Step and change the opponent's monsters to Defense position
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,3))
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EVENT_DAMAGE_STEP_END)
		e3:SetCountLimit(1)
		e3:SetOperation(s.desop)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
		at:RegisterEffect(e3,true)
	end
end
function s.disallop(e,tp)
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_COUNT)
	local zones=Duel.SelectDisableField(tp,ct,LOCATION_MZONE,0,0)
	for i=1,ct do
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
	end
	return zones
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT) then
		local g=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_FACEUP_ATTACK)
		if #g==0 then return end
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=e:GetHandler():GetFlagEffect(id)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,ct*500)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetFlagEffect(id)
	Duel.Damage(tp,ct*500,REASON_EFFECT)
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
end