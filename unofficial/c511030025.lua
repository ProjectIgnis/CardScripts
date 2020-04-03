--天装の闘技場
--Armatos Colosseum
--scripted by pyrQ
--name handling adapted from サイバネット・コーデック Cynet Codec by EerieCode
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--register names
	aux.GlobalCheck(s,function()
		s.name_list={}
		s.name_list[0]={}
		s.name_list[1]={}
		aux.AddValuesReset(function()
							s.name_list[0]={}
							s.name_list[1]={}
							end)
		end)
end
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x578) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(7044562,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.costfilter(c,e,tp)
	local code=c:GetCode()
	return not table.includes(s.name_list[tp],code) and c:IsSetCard(0x578) and c:IsLevelBelow(4) and c:IsAbleToGraveAsCost() 
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,code)
end
function s.tgfilter(c,e,tp,code)
	local zone=c:GetFreeLinkedZone()&0x1f
	return c:IsSetCard(0x578) and c:IsLinkMonster() and c:IsCanBeEffectTarget(e) and zone>0 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,code,zone)
end
function s.spfilter(c,e,tp,code,zone)
	return c:IsSetCard(0x578) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,zone)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetCode())
	Duel.SendtoGrave(g,REASON_COST)
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tg=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(#sg) and sg:GetClassCount(Card.GetCode)==#sg
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local code=e:GetLabel()
	table.insert(s.name_list[tp],code)
	local tc=Duel.GetFirstTarget()
	local zone=tc:GetFreeLinkedZone()&0x1f
	if zone==0 then return end
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,code,zone)
	if #sg<=0 then return end
	local sg_unq=sg:GetClassCount(Card.GetCode)
	local count=s.zone_count(zone)
	if #sg<count then count=#sg end
	if sg_unq<count then count=sg_unq end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then count=1 end
	if tc and tc:IsRelateToEffect(e) and zone~=0 then
		local g=aux.SelectUnselectGroup(sg,e,tp,count,count,s.rescon,1,tp,HINTMSG_SPSUMMON)
		if #g>0 then
			for tcg in aux.Next(g) do
				Duel.SpecialSummon(tcg,0,tp,tp,false,false,POS_FACEUP_DEFENSE,zone)
			end
		end
	end
end
function s.zone_count(z)
	local c=0
	while z>0 do
		c=c+1
		z=z&(z-1)
	end
	return c
end
if not table.includes then
	--binary search
	function table.includes(t,val)
		if #t<1 then return false end
		if #t==1 then return t[1]==val end --saves sorting for efficiency
		table.sort(t)
		local left=1
		local right=#t
		while left<=right do
			local middle=(left+right)//2
			if t[middle]==val1 then return true
			elseif t[middle]<val then left=middle+1
			else right=middle-1 end
		end
		return false
	end
end
