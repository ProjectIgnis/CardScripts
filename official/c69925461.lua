--トイ・タンク
--Toy Tank
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Can be Set as a Spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	--Special Summon itself if it was sent to the GY while it was Set in the Spell/Trap Zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.selfspcon)
	e2:SetTarget(s.selfsptg)
	e2:SetOperation(s.selfspop)
	c:RegisterEffect(e2)
	--Special Summon 1 Level 6 or lower monster from your hand or GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(Cost.SelfTribute)
	e3:SetTarget(s.lv6sptg)
	e3:SetOperation(s.lv6spop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_TOY_BOX,id}
function s.selfspcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_STZONE) and c:IsPreviousPosition(POS_FACEDOWN)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then 
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.lv6spfilter(c,e,tp)
	return c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsLocation(LOCATION_HAND) or not c:IsCode(id))
end
function s.lv6sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local hasbox=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_TOY_BOX),tp,LOCATION_ONFIELD,0,1,nil)
	local locations=hasbox and LOCATION_HAND|LOCATION_GRAVE or LOCATION_HAND
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		and Duel.IsExistingMatchingCard(s.lv6spfilter,tp,locations,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,locations)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.lv6spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local hasbox=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_TOY_BOX),tp,LOCATION_ONFIELD,0,1,nil)
	local locations=hasbox and LOCATION_HAND|LOCATION_GRAVE or LOCATION_HAND
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.lv6spfilter),tp,locations,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end