--Rank-Up-Magic Admiration of the Thousands (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x1048}
function s.filter(c,e)
	return c:IsSetCard(0x1048) and c:IsType(TYPE_XYZ) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and (c:GetRank()>0 or c:IsStatus(STATUS_NO_LEVEL)) 
end
function s.xyzfilter(c,sg,e,tp)
	if not c:IsSetCard(0x1048) or Duel.GetLocationCountFromEx(tp,tp,sg,c)<=0 then return false end
	if c.rum_limit and not sg:IsExists(function(mc) return c.rum_limit(mc,e) end,1,nil) then return false end
	local se=nil
	if c.rum_xyzsummon then
		se=c.rum_xyzsummon(c)
	end
	local res=c:IsXyzSummonable(nil,sg,#sg,#sg)
	if se then
		se:Reset()
	end
	return res
end
function s.chkfilter(c,g,sg,e,tp)
	sg:AddCard(c)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetValue(c:GetRank()+1)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	local e2=nil
	if c:IsControler(1-tp) then
		e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_XYZ_MATERIAL)
		e2:SetReset(RESET_CHAIN)
		c:RegisterEffect(e2)
	end
	local res=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,sg,e,tp) 
		or g:IsExists(s.chkfilter,1,sg,g,sg,e,tp)
	e1:Reset()
	if e2 then e2:Reset() end
	sg:RemoveCard(c)
	return res
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local sg=Group.CreateGroup()
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,LOCATION_GRAVE+LOCATION_ONFIELD,nil)
	if chk==0 then return mg:IsExists(s.chkfilter,1,nil,mg,sg,e,tp) end
	local reset={}
	local tc
	local e1
	local e2
	::start::
		local cancel=#sg>0 and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,sg,e,tp)
		local tg=mg:Filter(s.chkfilter,sg,mg,sg,e,tp)
		if #tg<=0 then goto jump end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		tc=Group.SelectUnselect(tg,sg,tp,cancel,cancel)
		if not tc then goto jump end
		if sg:IsContains(tc) then
			sg:RemoveCard(tc)
			reset[tc][0]:Reset()
			if reset[tc][1] then
				reset[tc][1]:Reset()
			end
			reset[tc]=nil
		else
			sg:AddCard(tc)
			reset[tc]={}
			e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_XYZ_LEVEL)
			e1:SetValue(tc:GetRank()+1)
			e1:SetReset(RESET_CHAIN)
			tc:RegisterEffect(e1)
			reset[tc][0]=e1
			e2=nil
			if tc:IsControler(1-tp) then
				e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_XYZ_MATERIAL)
				e2:SetReset(RESET_CHAIN)
				tc:RegisterEffect(e2)
			end
			reset[tc][1]=e2
		end
		goto start
	::jump::
	Duel.SetTargetCard(sg)
	for _,t in ipairs(reset) do
		t[0]:Reset()
		if t[1] then t[1]:Reset() end
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_XYZ_LEVEL)
		e1:SetValue(tc:GetRank()+1)
		e1:SetReset(RESET_CHAIN)
		tc:RegisterEffect(e1)
		if tc:IsControler(1-tp) then
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_XYZ_MATERIAL)
			e2:SetReset(RESET_CHAIN)
			tc:RegisterEffect(e2)
		end
		tc=g:GetNext()
	end
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,g,e,tp)
	if #xyzg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,xyz,nil,g)
		xyz:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
	end
end
