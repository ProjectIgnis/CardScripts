--クローン複製
--Cloning
local s,id=GetID()
local TOKEN_CLONE=id+1
function s.initial_effect(c)
	--When your opponent Normal or Flip Summons a monster that has a Level: Target that face-up monster; Special Summon 1 "Clone Token", with the same original Type, Attribute, Level, ATK, and DEF as that target
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==1-tp end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
s.listed_names={TOKEN_CLONE} --"Clone Token"
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=eg:GetFirst()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and ec:IsFaceup() and ec:IsLocation(LOCATION_MZONE)
		and ec:GetOriginalLevel()>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_CLONE,0,TYPES_TOKEN,ec:GetBaseAttack(),ec:GetBaseDefense(),ec:GetOriginalLevel(),ec:GetOriginalRace(),ec:GetOriginalAttribute()) end
	ec:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	if not ec:IsRelateToEffect(e) or ec:IsFacedown() then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_CLONE,0,TYPES_TOKEN,ec:GetBaseAttack(),ec:GetBaseDefense(),
			ec:GetOriginalLevel(),ec:GetOriginalRace(),ec:GetOriginalAttribute()) then return end
	ec:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_EXC_GRAVE,0,0)
	local token=Duel.CreateToken(tp,TOKEN_CLONE)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(ec:GetBaseAttack())
	e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TOFIELD))
	token:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	e2:SetValue(ec:GetBaseDefense())
	token:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CHANGE_LEVEL)
	e3:SetValue(ec:GetOriginalLevel())
	token:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CHANGE_RACE)
	e4:SetValue(ec:GetOriginalRace())
	token:RegisterEffect(e4)
	local e5=e1:Clone()
	e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e5:SetValue(ec:GetOriginalAttribute())
	token:RegisterEffect(e5)
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	--When that target is destroyed and sent to the GY, destroy this Token
	local de=Effect.CreateEffect(e:GetHandler())
	de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	de:SetRange(LOCATION_MZONE)
	de:SetCode(EVENT_TO_GRAVE)
	de:SetCondition(s.descon)
	de:SetOperation(s.desop)
	de:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TOFIELD))
	token:RegisterEffect(de)
end
function s.dfilter(c)
	return c:IsReason(REASON_DESTROY) and c:GetFlagEffect(id)~=0
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.dfilter,1,nil)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end