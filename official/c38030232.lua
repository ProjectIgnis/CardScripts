--天威龍-サハスラーラ
--Tenyi Spirit - Sahasrara
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_WYRM),2)
	--Cannot be targeted
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.con)
	e1:SetValue(s.tg)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.tg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
function s.con(e)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsNonEffectMonster),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
function s.tg(e,c)
	return s.filter(c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x12c,TYPES_TOKEN,-2,0,4,RACE_WYRM,ATTRIBUTE_LIGHT)
		and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x12c,TYPES_TOKEN,-2,0,4,RACE_WYRM,ATTRIBUTE_LIGHT) then
		local token=Duel.CreateToken(tp,id+1)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(tc:GetBaseAttack())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1)
		end
	Duel.SpecialSummonComplete()
	end
end

