--絶望の究極の布陣
--Ultimate Battle Formation of Despair
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={44095762,62279055,61740673}
s.chants={"Cringe before Hanoi's noble power!",
"Sink into the abyss of bottomless despair!"}
s.extraLink="This is a duel in the extreme domain! Manifest! Extra Link!"
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsLink,tp,LOCATION_MZONE,0,1,nil,4)
end
function s.GetZones(c,tp,e)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local zone=0
	for tc in aux.Next(g) do
		zone=zone|tc:GetToBeLinkedZone(c,tp,true,true)   
	end
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,0x20) then zone=zone&0x5f end
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,0x40) then zone=zone&0x3f end
	return zone
end
function s.spfilter(c,e,tp)
	local zone=s.GetZones(c,tp,e)
	return zone>0 and c:IsLink(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,LOCATION_EXTRA)
end
function s.rvfilter(c,codes)
	return #codes>0 and c:IsCode(table.unpack(codes)) and not c:IsPublic()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		local zone=s.GetZones(tc,tp,e)
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)~=0 then
			Debug.Message("I'll show you a duel in the extreme domain that transcends knowledge!")
			local ex=false
			if tc:IsExtraLinked() then Debug.Message(s.extraLink)
			else ex=true end
			local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
			local codes={44095762,62279055,61740673}
			local rg=Duel.GetMatchingGroup(s.rvfilter,tp,LOCATION_SZONE,0,nil,codes)
			local i=1
			while #sg>0 and #rg>0 and Duel.SelectYesNo(tp,aux.Stringid(1040,1)) do
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
				local rc=rg:Select(tp,1,1,nil):GetFirst()
				Duel.ConfirmCards(1-tp,rc)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sc=sg:Select(tp,1,1,nil):GetFirst()
				local szone=s.GetZones(sc,tp,e)
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP,szone)
				if s.chants[i]~=nil then Debug.Message(s.chants[i]) end
				i=i+1
				if ex and sc:IsExtraLinked() then Debug.Message(s.extraLink) ex=false end
				--remove code from table
				local newCodes={}
				local n=#codes
				for i=1,n do
					if codes[i]~=rc:GetCode() then
						table.insert(newCodes,codes[i])
					end
				end
				codes=newCodes
				rg=Duel.GetMatchingGroup(s.rvfilter,tp,LOCATION_SZONE,0,nil,codes)
				sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
			end
		end
	end
end
