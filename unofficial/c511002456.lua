--Refracting Prism
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)-1
	local tc=Duel.GetFieldGroup(tp,LOCATION_MZONE,0):GetFirst()
	if chk==0 then return ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct and tc 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,tc:GetCode(),0,tc:GetType(),tc:GetAttack(),tc:GetDefense()
		,tc:GetLevel(),tc:GetRace(),tc:GetAttribute()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)-1
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if ct<=0 or ft<ct or #g~=1 
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,tc:GetCode(),0,tc:GetType(),tc:GetAttack(),tc:GetDefense()
		,tc:GetLevel(),tc:GetRace(),tc:GetAttribute()) then return end
	for i=1,ct do
		local token=Duel.CreateToken(tp,tc:GetCode())
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,tc:GetPosition())
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(tc:GetDefense())
		token:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CHANGE_LEVEL)
		e3:SetValue(tc:GetLevel())
		token:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CHANGE_RACE)
		e4:SetValue(tc:GetRace())
		token:RegisterEffect(e4)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e5:SetValue(tc:GetAttribute())
		token:RegisterEffect(e5)
		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_SINGLE)
		e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e6:SetReset(RESET_EVENT+RESETS_STANDARD)
		e6:SetCode(EFFECT_CHANGE_CODE)
		e6:SetValue(tc:GetOriginalCode())
		token:RegisterEffect(e6)
	end
	Duel.SpecialSummonComplete()
end
