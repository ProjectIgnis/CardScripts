--電動蟲スプレッド女王
--Motor Worm Spreader Queen
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_INSECT),2)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93503294,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--cannot be battle target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(aux.TargetBoolFunction(Card.IsCode,511009659))
	c:RegisterEffect(e3)
end
s.listed_names={511009659}
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
function s.value(e,c)
	return Duel.GetMatchingGroupCount(s.filter,0,LOCATION_MZONE,LOCATION_MZONE,nil)*700
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return e:GetHandler():GetLinkedGroupCount()==0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zone=e:GetHandler():GetLinkedZone(tp)
		return zone~=0 and Duel.IsPlayerCanSpecialSummonMonster(tp,511009659,(0x3e|0x537),TYPES_TOKEN,0,0,1,RACE_INSECT,ATTRIBUTE_LIGHT) 
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	if zone~=0 and Duel.IsPlayerCanSpecialSummonMonster(tp,511009659,(0x3e|0x537),TYPES_TOKEN,0,0,1,RACE_INSECT,ATTRIBUTE_LIGHT) then
		local token=Duel.CreateToken(tp,511009659)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
