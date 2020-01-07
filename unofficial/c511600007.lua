--Cloning (Anime)
--scripted by Larry126
--fixed by MLD
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
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)	
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return #eg==1 and tc:IsSummonPlayer(1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=eg:GetFirst()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,ec:GetOriginalCode(),0,ec:GetOriginalType(),ec:GetTextAttack(),ec:GetTextDefense(),
		ec:GetOriginalLevel()+ec:GetOriginalRank(),ec:GetOriginalRace(),ec:GetOriginalAttribute()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,ec:GetOriginalCode(),0,ec:GetOriginalType(),ec:GetTextAttack(),ec:GetTextDefense(),
		ec:GetOriginalLevel()+ec:GetOriginalRank(),ec:GetOriginalRace(),ec:GetOriginalAttribute()) then return end
	local tc=Duel.CreateToken(tp,ec:GetOriginalCode())
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
end
