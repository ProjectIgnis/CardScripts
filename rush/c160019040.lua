--ダイスマイトギャム・ダブルアップチロリ
--Dicemite Gyame Double-Up Chirori
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160016016,160019007)
	--dice
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_SPECIAL_SUMMON|CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.roll_dice=true
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.filter(c,e,tp,lvl)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevelBelow(lvl) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local c=e:GetHandler()
	local d1,d2=Duel.TossDice(tp,2)
	local sum=d1+d2
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,sum)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp,sum)
		if #sg>0 then
			local tc=sg:GetFirst()
			Duel.BreakEffect()
			if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) and tc:GetBaseAttack()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				--Gain ATK
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(tc:GetBaseAttack())
				e1:SetReset(RESETS_STANDARD_PHASE_END)
				c:RegisterEffect(e1)
			end
		end
	end
end