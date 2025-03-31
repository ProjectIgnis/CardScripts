--アブソリュート・パワーフォース
--Absolute Powerforce
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Apply effects to 1 "Red Dragon Archfiend" you control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_RED_DRAGON_ARCHFIEND}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP() or (Duel.IsBattlePhase() and aux.StatChangeDamageStepCondition())
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_RED_DRAGON_ARCHFIEND) and not c:HasFlagEffect(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:HasFlagEffect(id) then return end
	local c=e:GetHandler()
	tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
	--Gains 1000 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.effcon)
	e1:SetValue(1000)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e1)
	--Opponent cannot activate cards or effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.effcon)
	e2:SetValue(1)
	e2:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e2)
	--Deals piercing damage
	local e3=e1:Clone()
	e3:SetCode(EFFECT_PIERCE)
	tc:RegisterEffect(e3)
	--Any battle damage the opponent takes is doubled
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e4:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	tc:RegisterEffect(e4)
end
function s.effcon(e)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local tp=e:GetHandlerPlayer()
	return c:IsRelateToBattle() and bc and bc:IsControler(1-tp) and e:GetOwnerPlayer()==tp
end