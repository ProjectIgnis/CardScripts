--フリッグのリンゴ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,-2,-2,1,RACE_FIEND,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rec=Duel.Recover(tp,ev,REASON_EFFECT)
	if rec~=ev or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,-2,-2,1,RACE_FIEND,ATTRIBUTE_DARK) then return end
	local token=Duel.CreateToken(tp,id+1)
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(ev)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		token:RegisterEffect(e2,true)
	end
	Duel.SpecialSummonComplete()
end
