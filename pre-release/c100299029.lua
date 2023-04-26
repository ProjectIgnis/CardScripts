--コード・ハック
--Code Hack
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Cyberse Link monsters you control cannot be destroyed by your opponent's card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(aux.AND(Card.IsRace,Card.IsLinkMonster),RACE_CYBERSE))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Change ATK to 0
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(TIMING_BATTLE_PHASE)
	e3:SetCountLimit(1)
	e3:SetCondition(function() return Duel.GetCurrentPhase()==PHASE_BATTLE_STEP end)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	--Negate the activation of an opponent's effect in the Damage Step
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(s.negcon)
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_CODE_TALKER}
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sc,oc=Duel.GetBattleMonster(tp)
	if chk==0 then return sc and oc and oc:IsFaceup() and oc:GetAttack()>0 end
	Duel.SetTargetCard(Group.FromCards(oc,sc))
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		local oc=tg:GetFirst()
		if oc:IsControler(tp) then oc=tg:GetNext() end
		if oc and oc:IsFaceup() then
			--Change ATK to 0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			oc:RegisterEffect(e1)
		end
		--Cannot be destroyed by that battle
		for tc in tg:Iter() do
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
			tc:RegisterEffect(e2)
		end
	end
	--Take no battle damage from that battle
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetTargetRange(1,1)
	e3:SetReset(RESET_PHASE|PHASE_DAMAGE)
	Duel.RegisterEffect(e3,tp)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentPhase()&(PHASE_DAMAGE|PHASE_DAMAGE_CAL)==0 or Duel.IsDamageCalculated() then return false end
	local a=Duel.GetAttacker()
	return a:IsControler(tp) and a:IsSetCard(SET_CODE_TALKER) and ep==1-tp and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(Duel.GetAttacker())
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		local tc=Duel.GetFirstTarget()
		if tc:IsFaceup() and tc:IsRelateToBattle() then
			--Gains 700 ATK
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(700)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end