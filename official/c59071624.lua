--アロメルスの蟲惑魔
--Traptrix Allomerus
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,4,2,nil,nil,99)
	--Unaffected by trap effects while has material(s) attached
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(s.imcon)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--Detach 2 materials; special summon 1 level 4 plant/insect from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--If an opponent's monster is in GY/banished due to your effect, special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetCost(s.sscost)
	e3:SetCondition(s.sscon)
	e3:SetTarget(s.sstg)
	e3:SetOperation(s.ssop)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
	local e4=e3:Clone()
	e4:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e4,false,REGISTER_FLAG_DETACH_XMAT)
end
	--Part of "Traptrix" archetype
s.listed_series={0x108a}

	--Has material(s) attached
function s.imcon(e)
	return e:GetHandler():GetOverlayCount()>0
end
	--Trap effects
function s.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
	--Detach 2 materials as cost
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
	--Check for level 4 plant/insect monster
function s.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsRace(RACE_PLANT+RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
	--Activation legality
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
	--Special summon 1 level 4 plant/insect monster from GY
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
	--Check if ever happened
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
	--Detach 1 material as cost
function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
	--Check for opponent's monster that sent there by your effect
function s.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER)
		and c:GetPreviousControler()==1-tp and c:IsPreviousLocation(LOCATION_MZONE) 
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==tp
end
	--Check for opponent's sent monster in GY/banished
function s.ssfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and s.cfilter(c,tp)
		and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end
	--Activation legality
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.ssfilter,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 end
	local c=nil
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		c=g:Select(tp,1,1,nil):GetFirst()
	else
		c=g:GetFirst()
	end
	Duel.SetTargetCard(c)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,g:GetFirst():GetLocation())
end
	--If an opponent's monster is in GY/banished due to your effect, special summon
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

