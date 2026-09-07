--真竜魔王マスターＰ
--Master Peace, the True Dracoverlord
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Requires 3 Tributes to Normal Summon (cannot be Normal Set)
	local e0a=aux.AddNormalSummonProcedure(c,true,false,3,3,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0))
	local e0b=aux.AddNormalSetProcedure(c)
	--To Tribute Summon this card face-up, you can Tribute Continuous Spells/Traps you control, as well as monsters
	local e0c=Effect.CreateEffect(c)
	e0c:SetType(EFFECT_TYPE_SINGLE)
	e0c:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0c:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e0c:SetTargetRange(LOCATION_SZONE,0)
	e0c:SetTarget(aux.TargetBoolFunction(Card.IsContinuousSpellTrap))
	e0c:SetValue(POS_FACEUP)
	c:RegisterEffect(e0c)
	--Negate the activation of an opponent's monster effect activated in the hand or field, and if you do, destroy that card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--Skip your opponent's next Main Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.skipcon)
	e2:SetOperation(s.skipop)
	c:RegisterEffect(e2)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local trig_loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep==1-tp and re:IsMonsterEffect() and trig_loc&(LOCATION_HAND|LOCATION_MZONE)>0 and c:IsTributeSummoned()
		and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=re:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.skipcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and rp==1-tp)) and c:IsTributeSummoned()
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
function s.skipop(e,tp,eg,ep,ev,re,r,rp)
	local oppo_main1_flag=nil
	local effect_code=0
	local turn_count=Duel.GetTurnCount()
	local current_phase=Duel.GetCurrentPhase()
	local reset_count=(Duel.IsTurnPlayer(1-tp) and (current_phase==PHASE_MAIN1 or current_phase>=PHASE_MAIN2)) and 2 or 1
	if Duel.IsTurnPlayer(tp) or current_phase<=PHASE_STANDBY or current_phase>=PHASE_MAIN2 then
		effect_code=EFFECT_SKIP_M1
	elseif Duel.IsTurnPlayer(1-tp) and Duel.IsBattlePhase() then
		effect_code=EFFECT_SKIP_M2
	else
		oppo_main1_flag=true
		effect_code=EFFECT_SKIP_M1
	end
	local c=e:GetHandler()
	--Skip your opponent's next Main Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(effect_code)
	e1:SetTargetRange(0,1)
	e1:SetCondition(function() return not oppo_main1_flag or turn_count~=Duel.GetTurnCount() end)
	e1:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,reset_count)
	Duel.RegisterEffect(e1,tp)
	if oppo_main1_flag then
		--If this effect was used during the opponent's Main Phase 1 which Main Phase gets skipped depends on what they do
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SKIP_M2)
		e2:SetCondition(aux.TRUE)
		e2:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,1)
		Duel.RegisterEffect(e2,tp)
		--Reset the effect that skips their Main Phase 1 if they enter the Battle Phase that turn
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e3:SetCountLimit(1)
		e3:SetCondition(function() return Duel.IsTurnPlayer(1-tp) end)
		e3:SetOperation(function() e1:Reset() end)
		e3:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end
end