--Tinsight Silencer
--AlphaKretin
function c210310212.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--supress effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(c210310212.actcon)
	e2:SetValue(c210310212.actlimit)
	c:RegisterEffect(e2)
end
function c210310212.actcon(e,c)
	return Duel.IsExistingMatchingCard(c210310212.confilter,tp,LOCATION_MZONE,0,1,nil) and Duel.GetCurrentPhase()==PHASE_BATTLE
end
function c210310212.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end