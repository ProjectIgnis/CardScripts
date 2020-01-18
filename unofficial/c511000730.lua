--Chronic Déjà Vu
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.filter(c,tp)
	return c:IsFaceup() and c:GetSummonPlayer()~=tp
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.filter,1,nil,tp) end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,#eg,0,0)
end
function s.filter2(c,e,tp)
	return c:IsFaceup() and not c:IsSummonPlayer(tp) and c:IsRelateToEffect(e) 
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.filter2,nil,e,tp)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local code=tc:GetOriginalCode()
		local token=Duel.CreateToken(tp,code)
		Duel.SpecialSummonStep(token,0,tp,tp,true,false,tc:GetPosition())
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_MONSTER)
		token:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end
