--心の友だち
--Endless Partner
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_EQUAL,filter=s.ritualfil,matfilter=s.forcedgroup,extraop=s.extraop,stage2=s.stage2})
	c:RegisterEffect(e1)
end
function s.matfilter(c,code)
	return c:IsRace(RACE_GALAXY) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and not c:IsCode(code)
end
function s.ritualfil(c)
	local tp=c:GetOwner()
	local loc=LOCATION_MZONE
	if Duel.IsExistingMatchingCard(s.submatenabler,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
		loc=LOCATION_MZONE|LOCATION_GRAVE
	end
	local g=Duel.GetMatchingGroup(s.matfilter,tp,loc,0,nil,c:GetCode())
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_GALAXY) and Ritual.Filter(c,nil,nil,Effect.CreateEffect(c),tp,g,Group.CreateGroup())
end
function s.submatenabler(c)
	return c:IsFaceup() and c:IsHasEffect(160024052)
end
function s.forcedgroup(c,e,tp)
	local loc=LOCATION_MZONE
	if Duel.IsExistingMatchingCard(s.submatenabler,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
		loc=LOCATION_MZONE|LOCATION_GRAVE
	end
	return c:IsLocation(loc) and c:IsRace(RACE_GALAXY) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local rg=mat:Filter(Card.IsFacedown,nil)
	local hg=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE|LOCATION_REMOVED)
	if #rg>0 then Duel.ConfirmCards(1-tp,rg) end
	if #hg>0 then Duel.HintSelection(hg) end
	local tg=mat:AddMaximumCheck()
	Duel.SendtoDeck(tg,nil,2,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
	mat:Clear()
end
function s.stage2(mg,e,tp,eg,ep,ev,re,r,rp,tc)
	local ct=math.min(Duel.GetFieldGroupCount(tp,0,LOCATION_DECK),tc:GetMaterialCount())
	if ct>0 and Duel.IsPlayerCanDiscardDeck(1-tp,ct) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local t={}
		for i=1,ct do t[i]=i end
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		local ac=Duel.AnnounceNumber(tp,table.unpack(t))
		Duel.DiscardDeck(1-tp,ac,REASON_EFFECT)
	end
end