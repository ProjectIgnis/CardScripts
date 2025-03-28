--かっとビング・チャレンジ
--Hi-Five the Sky
local s,id=GetID()
function s.initial_effect(c)
	--Make 1 of your Xyz monsters, that already attack this turn, make a second attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(TIMING_BATTLE_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and Duel.IsBattlePhase()
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetAttackedCount()==1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		--Can make a second attack
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3201)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
		tc:RegisterEffect(e1)
		--Opponent cannot activate cards/effects until end of damage step
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetTargetRange(0,1)
		e2:SetValue(s.aclimit)
		e2:SetCondition(s.actcon)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
		tc:RegisterEffect(e2)
	end
end
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end
function s.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsMonsterEffect()
end