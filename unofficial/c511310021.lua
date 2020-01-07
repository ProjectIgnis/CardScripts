--Soul Infusing Sculptor
--AlphaKretin
--Credit to edo9300 for implementing the Ice Pillar mechanic
Duel.LoadScript("c422.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:IsFaceup()
		and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),c:GetSetCard(),TYPES_TOKEN,0,0,0,RACE_AQUA,ATTRIBUTE_WATER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) and CheckPillars(tp,1) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not CheckPillars(tp,1) then return end
	IcePillarZone[tp+1]=IcePillarZone[tp+1] & ~Duel.SelectFieldZone(tp,1,LOCATION_MZONE,LOCATION_MZONE,~IcePillarZone[tp+1])
	local g = Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	if #g>0 then 
		local tc = g:GetFirst()
		local token = Duel.CreateToken(tp,511310022)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(tc:GetCode())
		e1:SetReset(RESETS_STANDARD)
		token:RegisterEffect(e1)
		Duel.SpecialSummonComplete()
	end
end
