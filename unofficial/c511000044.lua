--Imitation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:IsType(TYPE_TOKEN) and Duel.IsPlayerCanSpecialSummonMonster(tp,500000148,0,TYPES_TOKEN,c:GetBaseAttack(),c:GetBaseDefense(),
		c:GetOriginalLevel(),c:GetOriginalRace(),c:GetOriginalAttribute(),POS_FACEUP,1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsOnField() and s.filter(chkc,tp) end
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 
		or not Duel.IsPlayerCanSpecialSummonMonster(1-tp,500000148,0,TYPES_TOKEN,tc:GetBaseAttack(),tc:GetBaseDefense(),
			tc:GetOriginalLevel(),tc:GetOriginalRace(),tc:GetOriginalAttribute()) then return end
	local token=Duel.CreateToken(tp,500000148)
	if Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(tc:GetBaseDefense())
		token:RegisterEffect(e2,true)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CHANGE_LEVEL)
		e3:SetValue(tc:GetOriginalLevel())
		token:RegisterEffect(e3,true)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CHANGE_RACE)
		e4:SetValue(tc:GetOriginalRace())
		token:RegisterEffect(e4,true)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e5:SetValue(tc:GetOriginalAttribute())
		token:RegisterEffect(e5,true)
	end
	Duel.SpecialSummonComplete()
	Duel.BreakEffect()
	Duel.Damage(1-tp,tc:GetAttack()/2,REASON_EFFECT)
end
