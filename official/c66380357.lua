--機塊テスト
--Appliancer Test
--Anime version scripted by pyrQ, updated by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_APPLIANCER}
function s.filter(c,e,tp)
	return c:IsSetCard(SET_APPLIANCER) and c:IsLinkMonster() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
end
function s.spfilter(c,e,tp,fc)
	local zone=fc:GetFreeLinkedZone()&ZONES_MMZ
	return c:IsSetCard(SET_APPLIANCER) and c:IsLinkMonster() and c:IsLink(1)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp,g:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetHandler():GetFieldID()
	local c=Duel.GetFirstTarget()
	local zone=c:GetFreeLinkedZone()&ZONES_MMZ
	local count=s.zone_count(zone)
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,c)
	if #sg<count then count=#sg end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then count=1 end
	if c and c:IsFaceup() and c:IsRelateToEffect(e) and zone~=0 then
		for i=0,count,1 do
			local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,c):GetFirst()
			if tc then
				local zone=c:GetFreeLinkedZone()&ZONES_MMZ
				if zone>0 and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP,zone) then
					tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1,fid)
				end
			end
		end
		Duel.SpecialSummonComplete()
		--banish them during this End Phase
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetLabel(fid)
		e1:SetOperation(s.rmop)
		e1:SetReset(RESET_PHASE|PHASE_END)
		e1:SetCountLimit(1)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.rmfilter(c,e)
	return c:GetFlagEffectLabel(id)==e:GetLabel()
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,0,nil,e)
	if #g>0 then Duel.Remove(g,POS_FACEUP,REASON_EFFECT) end
end
function s.zone_count(z)
	local c=0
	while z>0 do
		c=c+1
		z=z&(z-1)
	end
	return c
end