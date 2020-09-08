--ＤＤＤ エクシーズ
--D/D/D Xyz
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
s.listed_series={0x10af}
s.listed_names={47198668}
function s.filter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsSetCard(0x10af)
		and c:IsType(TYPE_PENDULUM) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.xyzfilter(c,sg,e,tp)
	local ct=#sg
	local mc=e:GetHandler()
	local e1=nil
	if sg:IsExists(Card.IsCode,1,nil,47198668) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		e1=Effect.CreateEffect(mc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(511002116)
		e1:SetReset(RESET_CHAIN)
		mc:RegisterEffect(e1,true)
		sg:AddCard(mc)
	end
	local res=c:IsXyzSummonable(nil,sg,ct,ct) and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0
	if e1 then e1:Reset() sg:RemoveCard(mc) end
	return res
end
function s.rescon(mft,exft,ft)
	return function(sg,e,tp,mg)
				local exct=sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
				local mct=sg:FilterCount(aux.NOT(Card.IsLocation),nil,LOCATION_EXTRA)
				return exft>=exct and mft>=mct and ft>=#sg 
					and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,sg,sg,e,tp)
			end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e,tp)
	local ftex=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ftt=Duel.GetUsableMZoneCount(tp)
	ftex=math.min(ftex,aux.CheckSummonGate(tp) or ftex)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ftt=math.min(ftt,1) ftex=math.min(ftex,1) ft=math.min(ft,1) end
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2) and ftt>0 and (ft>0 or ftex>0)
		and aux.SelectUnselectGroup(mg,e,tp,nil,ftt,s.rescon(ft,ftex,ftt),0) end
	local sg=aux.SelectUnselectGroup(mg,e,tp,nil,ftt,s.rescon(ft,ftex,ftt),1,tp,HINTMSG_SPSUMMON,s.rescon(ft,ftex,ftt))
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,#sg+1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and #g>1 then return end
	local ftex=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	local ftt=Duel.GetUsableMZoneCount(tp)
	ftex=math.min(ftex,aux.CheckSummonGate(tp) or ftex)
	if ftt<#g or g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)>ftex then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local sg=aux.SelectUnselectGroup(g,e,tp,nil,ftt,s.rescon(ft,ftex,ftt),1,tp,HINTMSG_SPSUMMON,s.rescon(ft,ftex,ftt))
		if #sg<=0 then return false end
		g=sg
	end
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) > 0 then
		for tc in aux.Next(g) do
			if tc:IsLocation(LOCATION_MZONE) then
				s.disop(tc,e:GetHandler())
			end
		end
	else
		return
	end
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,g,g,e,tp)
	if #xyzg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		if c:IsRelateToEffect(e) and e:IsHasType(EFFECT_TYPE_ACTIVATE) and g:IsExists(Card.IsCode,1,nil,47198668) then
			e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(511002116)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1,true)
			g:AddCard(c)
		end
		Duel.XyzSummon(tp,xyz,nil,g)
	end
end
function s.disop(tc,c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	tc:RegisterEffect(e2)
end
