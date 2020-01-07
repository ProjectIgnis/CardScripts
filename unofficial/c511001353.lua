--Wild Half
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={86188410}
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(86188410)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.filter(c,tp)
	return c:IsFaceup() and c:GetLevel()>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,c:GetAttack(),c:GetDefense(),c:GetLevel(),c:GetRace(),c:GetAttribute(),
			POS_FACEUP,1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc,tp) end
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 
		and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local ea=Effect.CreateEffect(e:GetHandler())
	ea:SetType(EFFECT_TYPE_SINGLE)
	ea:SetCode(EFFECT_SET_BASE_ATTACK)
	ea:SetReset(RESET_EVENT+0x1fe000)
	ea:SetValue(tc:GetBaseAttack()/2)
	tc:RegisterEffect(ea)
	local ed=Effect.CreateEffect(e:GetHandler())
	ed:SetType(EFFECT_TYPE_SINGLE)
	ed:SetCode(EFFECT_SET_BASE_DEFENSE)
	ed:SetReset(RESET_EVENT+0x1fe000)
	ed:SetValue(tc:GetBaseDefense()/2)
	tc:RegisterEffect(ed)
	if tc:IsImmuneToEffect(ea) or tc:IsImmuneToEffect(ed) or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,tc:GetAttack(),tc:GetDefense(),
			tc:GetLevel(),tc:GetRace(),tc:GetAttribute(),POS_FACEUP,1-tp) then return end
	Duel.BreakEffect()
	local token=Duel.CreateToken(tp,id+1)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(tc:GetAttack())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
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
	Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
	if not tc:IsType(TYPE_TRAPMONSTER) then
		token:CopyEffect(tc:GetCode(),RESET_EVENT+RESETS_STANDARD,1)
	end	
end
