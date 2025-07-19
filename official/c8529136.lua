--スクラップ・フィスト
--Scrap Fist
local s,id=GetID()
function s.initial_effect(c)
	--Apply effects if 1 "Junk Warrior" you control battles this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_PHASE)
	e1:SetCondition(function() return Duel.IsAbleToEnterBP() or (Duel.IsBattlePhase() and not Duel.IsPhase(PHASE_BATTLE)) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_JUNK_WARRIOR}
function s.tgfilter(c)
	return c:IsCode(CARD_JUNK_WARRIOR) and c:IsFaceup() and not c:HasFlagEffect(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local c=e:GetHandler()
	local fid=tc:GetFieldID()
	local function condition()
			return (Duel.GetAttacker()==tc or Duel.GetAttackTarget()==tc) and tc:GetBattleTarget() and tc:HasFlagEffect(id) and tc:GetFlagEffectLabel(id)==fid and tc:IsControler(tp)
		end
	--If it battles an opponent's monster this turn while you control it, apply these effects
	if not tc:HasFlagEffect(id) then
		tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,1))
		--Your opponent cannot activate cards or effects until the end of the Damage Step
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(0,1)
		e1:SetCondition(condition)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		--If it attacks a Defense Position monster, inflict piercing battle damage to your opponent
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetCondition(condition)
		e2:SetTarget(condition)
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
		--Double any battle damage your opponent takes
		local e3=e2:Clone()
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
		Duel.RegisterEffect(e3,tp)
		--It cannot be destroyed by battle
		local e4=e2:Clone()
		e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e4:SetValue(1)
		Duel.RegisterEffect(e4,tp)
	end
	--Destroy the opponent's monster that battled it at the end of the Damage Step
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_DAMAGE_STEP_END)
	e5:SetCondition(function() return condition() and tc:GetBattleTarget():IsRelateToBattle() end)
	e5:SetOperation(function() Duel.Hint(HINT_CARD,0,id) Duel.Destroy(tc:GetBattleTarget(),REASON_EFFECT) end)
	e5:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e5,tp)
end