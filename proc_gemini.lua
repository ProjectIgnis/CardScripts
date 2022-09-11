Gemini={}

Card.IsGeminiStatus=Card.IsGeminiState
Card.EnableGeminiStatus=Card.EnableGeminiState

function Gemini.AddProcedure(c)
	--Can be Normal Summoned again
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_GEMINI_SUMMONABLE)
	c:RegisterEffect(e1)
	--Becomes Normal Type if not yet summoned twice
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e2:SetCondition(Gemini.NormalStatusCondition)
	e2:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_REMOVE_TYPE)
	e3:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e3)
end

function Gemini.EffectStatusCondition(effect)
	local c=effect:GetHandler()
	return not c:IsDisabled() and c:IsGeminiStatus()
end

function Gemini.NormalStatusCondition(effect)
	local c=effect:GetHandler()
	return c:IsFaceup() and not c:IsGeminiStatus()
end