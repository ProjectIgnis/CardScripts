--コードブレイカー・ウイルスバーサーカー
--Codebreaker Virus Berserker
--Anime version scripted by Larry126, updated by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,3,s.lcheck)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_series={0x13c}
function s.lcheck(g,lc,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x13c,lc,SUMMON_TYPE_LINK,tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMutualLinkedGroupCount()>0
end
function s.spfilter(c,e,tp,p,zones)
	return c:IsSetCard(0x13c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p,zones[p])
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zones={}
	zones[0]=Duel.GetLinkedZone(0)&0x1f
	zones[1]=Duel.GetLinkedZone(1)&0x1f
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,tp,zones) or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,1-tp,zones) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local zones={}
	zones[0]=Duel.GetLinkedZone(0)&0x1f
	zones[1]=Duel.GetLinkedZone(1)&0x1f
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp,tp,zones)+Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp,1-tp,zones)
	if #g==0 then return end
	local ft=Duel.GetLocationCount(0,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zones[0])+Duel.GetLocationCount(1,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zones[1])
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and 1 or math.min(ft,2),nil)
	for tc in aux.Next(sg) do
		local p
		if s.spfilter(tc,e,tp,tp,zones) and s.spfilter(tc,e,tp,1-tp,zones) then
			p=Duel.SelectYesNo(tp,aux.Stringid(id,2)) and 1-tp or tp
		elseif s.spfilter(tc,e,tp,tp,zones) then
			p=tp
		else
			p=1-tp
		end
		Duel.SpecialSummonStep(tc,0,tp,p,false,false,POS_FACEUP,zones[p])
	end
	Duel.SpecialSummonComplete()
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13c) and c:IsLinked()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil),nil,TYPE_SPELL+TYPE_TRAP)
	if #g>0 then 
		Duel.Destroy(g,REASON_EFFECT)
	end
end

