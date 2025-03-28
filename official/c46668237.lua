--森の番人グリーン・バブーン
--Green Baboon, Defender of the Forest
local s,id=GetID()
function s.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.condition)
	e1:SetCost(Cost.PayLP(1000))
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp)
	return c:IsMonster() and c:IsRace(RACE_BEAST) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousLocation(LOCATION_MZONE) and (c:GetPreviousRaceOnField()&RACE_BEAST)~=0
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter,1,nil,tp) and (r&REASON_DESTROY)~=0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end