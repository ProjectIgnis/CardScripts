--海晶乙女 マンダリン (Anime)
--Marincess Mandarin (Anime)
--scripted by Larry126
local s,id,alias=GetID()
function s.initial_effect(c)
	alias=c:GetOriginalCodeRule()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(alias,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(s.condition)
	e1:SetValue(s.spval)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x12b}
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_MARINCESS) and c:IsType(TYPE_LINK) and c:IsMonster()
end
function s.condition(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local zone=aux.GetMMZonesPointedTo(tp,Card.IsSetCard,LOCATION_MZONE,0,nil,SET_MARINCESS)
	return #g>1 and zone>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.spval(e,c)
	return 0,aux.GetMMZonesPointedTo(e:GetHandlerPlayer(),Card.IsSetCard,LOCATION_MZONE,0,nil,SET_MARINCESS)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1,true)
end