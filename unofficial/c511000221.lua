--幻影の器
--Vessel of Illusion
local s,id=GetID()
local TOKEN_SPIRIT=id+1
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={id+1}
function s.cfilter(c,tp,e)
	return c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsType(TYPE_SPIRIT) and c:IsLocation(LOCATION_GRAVE) 
		and (not e or c:IsRelateToEffect(e))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.cfilter,nil,tp)==1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=eg:Filter(s.cfilter,nil,tp):GetFirst()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_SPIRIT,0,TYPES_TOKEN,ec:GetBaseAttack(),ec:GetBaseDefense(),ec:GetOriginalLevel(),ec:GetOriginalRace(),ec:GetOriginalAttribute()) end
	Duel.SetTargetCard(ec)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:Filter(s.cfilter,nil,tp):GetFirst()
	if not ec or not ec:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_SPIRIT,0,TYPES_TOKEN,ec:GetBaseAttack(),ec:GetBaseDefense(),ec:GetOriginalLevel(),ec:GetOriginalRace(),ec:GetOriginalAttribute()) then return end
	local token=Duel.CreateToken(tp,TOKEN_SPIRIT)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(ec:GetBaseAttack())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	token:RegisterEffect(e1,true)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	e2:SetValue(ec:GetBaseDefense())
	token:RegisterEffect(e2,true)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CHANGE_LEVEL)
	e3:SetValue(ec:GetOriginalLevel())
	token:RegisterEffect(e3,true)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CHANGE_RACE)
	e4:SetValue(ec:GetOriginalRace())
	token:RegisterEffect(e4,true)
	local e5=e1:Clone()
	e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e5:SetValue(ec:GetOriginalAttribute())
	token:RegisterEffect(e5,true)
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
