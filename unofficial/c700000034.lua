--Scripted by Eerie Code
--Ancient Gear Chaos Fusion
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x7}
s.listed_names={CARD_POLYMERIZATION}
function s.cfilter(c)
	return c:IsCode(CARD_POLYMERIZATION) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.matfilter(c,e,tp,fc,se)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial(fc) and (not se or not c:IsImmuneToEffect(se)) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) 
end
function s.spfilter(c,e,tp,rg,se)
	if not c:IsType(TYPE_FUSION) or not c:IsSetCard(0x7) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) then return false end
	local minc=c.min_material_count
	local maxc=c.max_material_count
	if not minc then return false end
	local mg2=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,nil,e,tp,c,se)
	if Duel.IsPlayerAffectedByEffect(tp,69832741) then
		local maxc2=math.min(#rg,maxc)
		local mft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then maxc2=math.min(ft,1) mft=math.min(mft,1) end
		return minc>0 and maxc2>=minc and aux.SelectUnselectGroup(rg,e,tp,minc,maxc2,s.resconse1(c,mft,mg2,se),0)
	else
		local ft=Duel.GetUsableMZoneCount(tp)
		local mft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local exft=Duel.GetLocationCountFromEx(tp)
		local gate=Duel.GetMetatable(CARD_SUMMON_GATE)
		local ect=gate and Duel.IsPlayerAffectedByEffect(tp,CARD_SUMMON_GATE) and (gate[tp] - 1)
		if ect then exft=math.min(exft,ect) end
		maxc=math.min(maxc,ft)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=math.min(ft,1) mft=math.min(mft,1) exft=math.min(exft,1) end
		return minc>0 and maxc>=minc and aux.SelectUnselectGroup(rg,e,tp,minc,maxc,s.rescon1(c,mft,exft,ft,mg2,se),0)
	end
end
function s.rescon1(fc,mft,exft,ft,mg2,se)
	return	function(sg,e,tp,mg)
				local mg3=mg2:Filter(aux.TRUE,sg)
				return ft>=#sg and aux.SelectUnselectGroup(mg3,e,tp,#sg,#sg,s.rescon2(fc,mft,exft),0)
			end
end
function s.rescon2(fc,mft,exft)
	return	function(sg,e,tp,mg)
				Fusion.CheckExact=#sg
				local res=exft>=sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA) and mft>=sg:FilterCount(aux.NOT(Card.IsLocation),nil,LOCATION_EXTRA)
					and fc:CheckFusionMaterial(sg,nil,tp)
				Fusion.CheckExact=nil
				return res
			end
end
function s.resconse1(fc,mft,mg2,se)
	return	function(sg,e,tp,mg)
				local mg3=mg2:Filter(aux.TRUE,sg)
				return aux.SelectUnselectGroup(mg3,e,tp,#sg,#sg,s.resconse2(fc,sg,mft),0)
			end
end
function s.resconse2(fc,rg,mft)
	return	function(sg,e,tp,mg)
				local gate=Duel.GetMetatable(CARD_SUMMON_GATE)
				local ect=gate and Duel.IsPlayerAffectedByEffect(tp,CARD_SUMMON_GATE) and (gate[tp] - 1)
				local exct=sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA) 
				Fusion.CheckExact=#sg
				local res=Duel.GetLocationCountFromEx(tp,tp,rg)>=exct and (not ect or exct<ect) 
					and rg:FilterCount(aux.MZFilter,nil,tp)+mft>=sg:FilterCount(aux.NOT(Card.IsLocation),nil,LOCATION_EXTRA)
					and fc:CheckFusionMaterial(sg,nil,tp)
				Fusion.CheckExact=nil
				return res
			end
end
function s.rmfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsAbleToRemove() and aux.SpElimFilter(c,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then return Duel.GetUsableMZoneCount(tp)>-1 and Duel.IsPlayerCanSpecialSummonCount(tp,2) 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,rg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local fg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,rg)
	Duel.ConfirmCards(1-tp,fg:GetFirst())
	Duel.SetTargetCard(fg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local fc=Duel.GetFirstTarget()
	local rg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if not fc or not fc:IsRelateToEffect(e) or not s.spfilter(fc,e,tp,rg,e) then return end
	local minc=fc.min_material_count
	local maxc=fc.max_material_count
	local rsg
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.matfilter),tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,nil,e,tp,fc,e)
	if Duel.IsPlayerAffectedByEffect(tp,69832741) then
		local maxc2=math.min(#rg,maxc)
		local mft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then maxc2=math.min(ft,1) mft=math.min(mft,1) end
		if minc<=0 or maxc2<minc then return end
		rsg=aux.SelectUnselectGroup(rg,e,tp,minc,maxc2,s.resconse1(c,mft,mg,e),1,tp,HINTMSG_REMOVE,s.resconse1(c,mft,mg,e))
		if #rsg<=0 then return end
	else
		local ft=Duel.GetUsableMZoneCount(tp)
		local mft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local exft=Duel.GetLocationCountFromEx(tp)
		local gate=Duel.GetMetatable(CARD_SUMMON_GATE)
		local ect=gate and Duel.IsPlayerAffectedByEffect(tp,CARD_SUMMON_GATE) and (gate[tp] - 1)
		if ect then exft=math.min(exft,ect) end
		maxc=math.min(maxc,ft)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=math.min(ft,1) mft=math.min(mft,1) exft=math.min(exft,1) end
		if minc<=0 or maxc<minc then return end
		rsg=aux.SelectUnselectGroup(rg,e,tp,minc,maxc,s.rescon1(fc,mft,exft,ft,mg,e),1,tp,HINTMSG_REMOVE,s.rescon1(fc,mft,exft,ft,mg,e))
		if #rsg<=0 then return end
	end
	local ct=Duel.Remove(rsg,POS_FACEUP,REASON_EFFECT)
	if ct<#rsg then return end
	local mft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local exft=Duel.GetLocationCountFromEx(tp)
	local gate=Duel.GetMetatable(CARD_SUMMON_GATE)
	local ect=gate and Duel.IsPlayerAffectedByEffect(tp,CARD_SUMMON_GATE) and (gate[tp] - 1)
	if ect then exft=math.min(exft,ect) end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then mft=math.min(mft,1) exft=math.min(exft,1) end
	mg:Sub(rsg)
	local matg=aux.SelectUnselectGroup(mg,e,tp,ct,ct,s.rescon2(fc,mft,exft),1,tp,HINTMSG_SPSUMMON)
	if Duel.SpecialSummon(matg,0,tp,tp,false,false,POS_FACEUP) > 0 then
		for tc in aux.Next(matg) do
			if tc:IsLocation(LOCATION_MZONE) then
				s.disop(tc,e:GetHandler())
			end
		end
	else
		return
	end
	Duel.BreakEffect()
	fc:SetMaterial(matg)
	Duel.SendtoGrave(matg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()
	Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp,tc)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DISABLE_EFFECT)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e3)
end
