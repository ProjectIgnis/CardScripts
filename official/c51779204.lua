--アブソリュート・パワーフォース
--Absolute Powerforce
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Apply effects when the targeted "Red Dragon Archfiend" you control battles an opponent's monster this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(function() return (Duel.IsAbleToEnterBP() or (Duel.IsBattlePhase() and not Duel.IsPhase(PHASE_BATTLE))) and aux.StatChangeDamageStepCondition() end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_RED_DRAGON_ARCHFIEND}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCode(CARD_RED_DRAGON_ARCHFIEND) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsCode,CARD_RED_DRAGON_ARCHFIEND),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsCode,CARD_RED_DRAGON_ARCHFIEND),tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local c=e:GetHandler()
	local fid=tc:GetFieldID()
	--If it battles an opponent's monster this turn while you control it, apply these effects
	local function condition()
			return (Duel.GetAttacker()==tc or Duel.GetAttackTarget()==tc) and tc:GetBattleTarget() and tc:GetBattleTarget():IsControler(1-tp)
				and tc:HasFlagEffect(id) and tc:GetFlagEffectLabel(id)==fid and tc:IsControler(tp)
		end
	--It gains 1000 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(condition)
	e1:SetTarget(condition)
	e1:SetValue(1000)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	if not tc:HasFlagEffect(id) then
		tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,1))
		--Your opponent cannot activate cards or effects
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetTargetRange(0,1)
		e2:SetCondition(condition)
		e2:SetValue(1)
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
		--If it attacks a Defense Position monster, inflict piercing battle damage to your opponent
		local e3=e1:Clone()
		e3:SetCode(EFFECT_PIERCE)
		Duel.RegisterEffect(e3,tp)
		--Any battle damage your opponent takes from that battle is doubled
		local e4=e1:Clone()
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e4:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
		Duel.RegisterEffect(e4,tp)
	end
end