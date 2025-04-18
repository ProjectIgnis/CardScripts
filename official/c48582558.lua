--バウンサー・ガード
--Bounzer Guard
local s,id=GetID()
function s.initial_effect(c)
	--Targeted "Bounzer" monster cannot be targeted by card effect, also cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMING_BATTLE_START)
	c:RegisterEffect(e1)
end
s.listed_series={SET_BOUNZER}
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_BOUNZER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		--Cannot be destroyed by battle
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3000)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		--Cannot be targeted by card effects
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(3002)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetValue(1)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
		e3:SetTargetRange(0,LOCATION_MZONE)
		e3:SetValue(s.atklimit)
		e3:SetLabel(tc:GetRealFieldID())
		e3:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.atklimit(e,c)
	return c:GetRealFieldID()==e:GetLabel()
end