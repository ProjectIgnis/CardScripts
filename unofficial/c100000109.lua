--ザ・ヘブンズ・ロード
--The Sky Lord
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	--Special Summon 1 "Arcana Force EX - The Light Ruler" from your hand, Deck, or GY, ignoring its Summoning conditions
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ARCANA_FORCE}
s.listed_names={100000107,100000108,5861892}
function s.confilter(c)
	return c:IsSetCard(SET_ARCANA_FORCE) and c:IsLevelAbove(7)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.costfilter(c)
	return c:IsFaceup() and c:IsCode(100000107,100000108) and c:IsAbleToGraveAsCost()
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsCode,1,nil,100000107) and sg:IsExists(Card.IsCode,1,nil,100000108)
		and Duel.GetMZoneCount(tp,sg+e:GetHandler())>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local cg=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return c:IsAbleToGraveAsCost() and aux.SelectUnselectGroup(cg,e,tp,2,2,s.rescon,0) end
	local g=aux.SelectUnselectGroup(cg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(g+c,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsCode(5861892) and c:IsCanBeSpecialSummoned(e,0,tp,true,c:IsOriginalCode(511003201))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	local ignore_sum_cond=tc:IsOriginalCode(511003201)
	if Duel.SpecialSummon(tc,0,tp,tp,true,ignore_sum_cond,POS_FACEUP)>0 and ignore_sum_cond then
		tc:CompleteProcedure()
	end
end