--コード・ハック
--Code Hack
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Cyberse Link monsters you control cannot be destroyed by your opponent's card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsRace(RACE_CYBERSE) and c:IsLinkMonster() end)
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	--Make that opponent's monster's ATK becomes 0 until the end of this turn, also for that battle, monsters cannot be destroyed by battle and neither player takes battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(TIMING_BATTLE_PHASE)
	e2:SetCondition(function() return Duel.IsPhase(PHASE_BATTLE_STEP) end)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--Negate the activation of an opponent's effect in the Damage Step
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(s.negcon)
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
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
			local e0=Effect.CreateEffect(c)
			e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetCode(EFFECT_SET_ATTACK_FINAL)
			e0:SetValue(0)
			e0:SetReset(RESETS_STANDARD_PHASE_END)
			oc:RegisterEffect(e0)
		end
		--Cannot be destroyed by that battle
		for tc in tg:Iter() do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
			tc:RegisterEffect(e1)
		end
	end
	--Take no battle damage from that battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetTargetRange(1,1)
	e2:SetReset(RESET_PHASE|PHASE_DAMAGE)
	Duel.RegisterEffect(e2,tp)
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
			local e0=Effect.CreateEffect(e:GetHandler())
			e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetCode(EFFECT_UPDATE_ATTACK)
			e0:SetValue(700)
			e0:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e0)
		end
	end
end