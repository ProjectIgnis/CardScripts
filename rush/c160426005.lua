--強者の愉悦
--Delight of the Mighty
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return ep==1-tp and tc:IsFaceup() and tc:HasLevel() and tc:IsLocation(LOCATION_MZONE)
		and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.atkfilter),tp,LOCATION_MZONE,0,1,nil) end
	tc:CreateEffectRelation(e)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:HasLevel()) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local ac=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.atkfilter),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if ac then
		Duel.HintSelection(ac)
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetLevel()*100)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		ac:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		ac:RegisterEffect(e2)
	end
end