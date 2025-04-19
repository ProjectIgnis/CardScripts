--死霊の残像
--Spirit Illusion
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={id+1}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local eq=e:GetHandler():GetEquipTarget()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and eq:HasLevel()
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,eq:GetAttack(),eq:GetDefense(),
			eq:GetLevel(),eq:GetRace(),eq:GetAttribute())
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local eq=c:GetEquipTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not eq:HasLevel()
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,eq:GetAttack(),eq:GetDefense(),
			eq:GetLevel(),eq:GetRace(),eq:GetAttribute()) then return end
	local token=Duel.CreateToken(tp,id+1)
	--There can only be 1 "Doppelganger Token" on the field
	token:SetUniqueOnField(1,1,id+1)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(1,1)
	e0:SetTarget(function(_,_c) return _c:IsCode(id+1) end)
	e0:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TOFIELD)
	token:RegisterEffect(e0)
	--Add monster properties
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(eq:GetAttack())
	e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TOFIELD)
	token:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	e2:SetValue(eq:GetDefense())
	token:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CHANGE_LEVEL)
	e3:SetValue(eq:GetLevel())
	token:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CHANGE_RACE)
	e4:SetValue(eq:GetRace())
	token:RegisterEffect(e4)
	local e5=e1:Clone()
	e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e5:SetValue(eq:GetAttribute())
	token:RegisterEffect(e5)
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
		--Cannot be tributed
		local e6=Effect.CreateEffect(c)
		e6:SetDescription(3303)
		e6:SetType(EFFECT_TYPE_SINGLE)
		e6:SetCode(EFFECT_UNRELEASABLE_SUM)
		e6:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e6:SetValue(1)
		e6:SetReset(RESET_EVENT|RESETS_STANDARD)
		token:RegisterEffect(e6)
		local e7=e6:Clone()
		e7:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		token:RegisterEffect(e7)
		--Gain effects
		if eq:IsOriginalType(TYPE_EFFECT) then
			token:CopyEffect(eq:GetOriginalCode(),RESET_EVENT|RESETS_STANDARD)
			local e8=Effect.CreateEffect(c)
			e8:SetType(EFFECT_TYPE_SINGLE)
			e8:SetCode(EFFECT_ADD_TYPE)
			e8:SetValue(TYPE_EFFECT)
			e8:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e8)
		end
	end
	Duel.SpecialSummonComplete()
end