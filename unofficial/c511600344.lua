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
	--"Code Talker" monsters you control cannot be destroyed by card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_CODE_TALKER))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--ATK change
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	--Negate
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCondition(s.negcon)
	e4:SetCost(Cost.SelfBanish)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_CODE_TALKER}
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local sc,oc=Duel.GetBattleMonster(tp)
	if not oc or Duel.GetCurrentPhase()~=PHASE_BATTLE_STEP then return false end
	e:SetLabelObject(oc)
	return sc and sc:IsFaceup() and sc:IsSetCard(SET_CODE_TALKER)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return tc and tc:IsFaceup() and tc:GetAttack()>0 end
	Duel.SetTargetCard(tc)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		--Change ATK to 0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
		e1:SetValue(0)
		tc:RegisterEffect(e1)
	end
	--Cannot be destroyed by that battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(1)
	e2:SetTarget(function(_,_c) return _c:IsRelateToBattle() end)
	e2:SetReset(RESET_PHASE|PHASE_DAMAGE)
	Duel.RegisterEffect(e2,tp)
	--Take no battle damage from that battle
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetReset(RESET_PHASE|PHASE_DAMAGE)
	Duel.RegisterEffect(e3,tp)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentPhase()&(PHASE_DAMAGE|PHASE_DAMAGE_CAL)==0 or Duel.IsDamageCalculated() then return false end
	local sc=Duel.GetBattleMonster(tp)
	return sc and sc:IsFaceup() and sc:IsSetCard(SET_CODE_TALKER) and ep==1-tp
		and Duel.IsChainNegatable(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		local c=e:GetHandler()
		local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_CODE_TALKER),tp,LOCATION_MZONE,0,nil)
		for tc in g:Iter() do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(700)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end