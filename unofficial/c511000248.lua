--ディフェンド・スライム (Manga)
--Jam Defender (Manga)
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	c:RegisterEffect(e1)
	--Slime's Defense
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSlime()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Group.FromCards(Duel.GetAttacker(),Duel.GetAttackTarget())
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) and not g:IsContains(chkc) end
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,g)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SELF_ATTACK)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,1)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		Duel.RegisterEffect(e1,tp)
		Duel.ChangeAttackTarget(tc)
	end
end